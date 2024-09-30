# Main Metrics

## Monthly Transactions

Buat tabel rangkuman hasil transaksi bulanan, yakni jumlah transaksi (_transaction_count_) dan total nilai transaksi (_total_transaction_value_), beserta pertumbuhan tiap bulannya (_m_o_m_: month-on-month growth).

> Query

```postgresql
with order_summary as (
	select
		to_char(created_at, 'YYYYMM') as month,
		count(1) as transaction_count,
		sum(total) as total_transaction_value
	from orders
	group by 1
	order by 1
)

select 
	month,
	transaction_count,
	round(1::numeric * (transaction_count - 
		lag(transaction_count) over(order by month)) /
		lag(transaction_count) over(order by month), 2) as m_o_m_trx_count,
	total_transaction_value,
	round(1::numeric * (total_transaction_value - 
		lag(total_transaction_value) over(order by month)) /
		lag(total_transaction_value) over(order by month), 2) as m_o_m_total_trx_value
from order_summary
```

> Result

|month|transaction_count|m_o_m_trx_count|total_transaction_value|m_o_m_total_trx_value|
|-----|-----------------|---------------|-----------------------|---------------------|
|201901|117||145511000||
|201902|354|2.03|305881150|1.10|
|201903|668|0.89|679822000|1.22|
|201904|984|0.47|1031096250|0.52|
|201905|1462|0.49|1593491550|0.55|
|201906|1913|0.31|2123578300|0.33|
|201907|2667|0.39|3140933100|0.48|
|201908|3274|0.23|4163502050|0.33|
|201909|4327|0.32|5789167100|0.39|
|201910|5577|0.29|8220707650|0.42|
|201911|7162|0.28|11599678600|0.41|
|201912|10131|0.41|17765555200|0.53|
|202001|5062|-0.50|9941756800|-0.44|
|202002|5872|0.16|12665113550|0.27|
|202003|7323|0.25|17189378400|0.36|
|202004|7955|0.09|21219233750|0.23|
|202005|10026|0.26|31288823000|0.47|

# User Retention Rate

Buat tabel _user retention rate_ bulanan yang terinpirasi dari artikel [berikut](https://medium.com/cube-dev/customer-retention-analysis-93af9daee46b).

> Query

```postgresql
-- Pertama, kita buat tabel untuk merangkum kapan saja user melakukan transaksi tiap bulan
drop table if exists user_monthly_transaction;
create temporary table user_monthly_transaction as
select distinct
	date_trunc('month', o.created_at) as month_,
	o.buyer_id
from orders o;

-- Selanjutnya, kita buat tabel untuk rangkuman retentionnya menggunakan case + lead function. 
-- Btw, umt = user_monthly_transaction
drop table if exists user_retention_summary;
create temporary table user_retention_summary as
with umt_lead_month as (
	select
		month_,
		lead(month_, 1) over(
			partition by buyer_id 
			order by buyer_id, month_
		) as lead_month_,
		buyer_id
	from user_monthly_transaction
),
umt_delta_month as (
	select
		month_,
		lead_month_,
		(
			extract(year from age(lead_month_, month_)) * 12 +
			extract(month from age(lead_month_, month_))
		) as delta_month_,
		buyer_id
	from umt_lead_month
)
select
	buyer_id as user_id,
	month_,
	lead_month_,
	delta_month_,
	case
		when delta_month_ = 1 then 'retained'
		when delta_month_ > 1 then 'lagger'
		when delta_month_ is null then 'lost'
	end as user_type
from umt_delta_month;

-- Terakhir, kita bisa menghitung jumlah user di bulan tertentu yang kembali lagi bertransaksi di bulan depan
select
	to_char(month_, 'YYYYMM') year_month,
	count(
		case 
			when user_type = 'retained' then user_id 
		end
	) / count(user_id)::numeric as retention,
	count(user_id) as user_count
from user_retention_summary
group by 1
order by 1;
```

> Result

|year_month|retention|user_count|
|----------|---------|----------|
|201901|0.02564102564102564103|117|
|201902|0.05142857142857142857|350|
|201903|0.05648854961832061069|655|
|201904|0.09071949947862356621|959|
|201905|0.10892480674631061138|1423|
|201906|0.13901098901098901099|1820|
|201907|0.16357027463651050081|2476|
|201908|0.21963394342762063228|3005|
|201909|0.26478283621140763998|3822|
|201910|0.32965201083559074807|4799|
|201911|0.43199864842034127386|5919|
|201912|0.27247991707696294377|7718|
|202001|0.31246112378187849886|4823|
|202002|0.37105784826094791854|5549|
|202003|0.38863735942748649043|6847|
|202004|0.31405289874432273577|7486|
|202005|0.00000000000000000000|9610|
