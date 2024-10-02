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

> Data Visualization (via Power BI)

![Monthly Transactions](/assets/monthly-trx.png)

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
	round(count(
		case 
			when user_type = 'retained' then user_id 
		end
	) / count(user_id)::numeric, 4) as retention,
	count(user_id) as user_count
from user_retention_summary
group by 1
order by 1;
```

> Result

|year_month|retention|user_count|
|----------|---------|----------|
|201901|0.0256|117|
|201902|0.0514|350|
|201903|0.0565|655|
|201904|0.0907|959|
|201905|0.1089|1423|
|201906|0.1390|1820|
|201907|0.1636|2476|
|201908|0.2196|3005|
|201909|0.2648|3822|
|201910|0.3297|4799|
|201911|0.4320|5919|
|201912|0.2725|7718|
|202001|0.3125|4823|
|202002|0.3711|5549|
|202003|0.3886|6847|
|202004|0.3141|7486|
|202005|0.0000|9610|

> Data Visualization (via Metabase)

![Monthly Retention Rate]/assets/monthly-retention.png)

# User Retention Rate (Another Technique)

Dalam perhitungan _user retention rate_ sebelumnya, kita memperoleh informasi berapa persen user di bulan tertentu yang akan kembali lagi melakukan transaksi tepat di bulan berikutnya. 

Ada cara lain untuk menghitung _user retention rate_, yaitu menghitung berapa persen user di bulan ini yang statusnya 'retained' dari bulan lalu. Selain dari user yang 'retained', keseluruhan user di bulan tertentu juga tersusun dari user 'new' dan 'returning'. User 'new' adalah user yang baru terakuisisi di bulan tertentu, sedangkan user 'returning' merupakan user yang kembali lagi bertransaksi setelah 'hilang' selama lebih dari 1 bulan. 

Dengan cara seperti ini, tim marketing dapat lebih mudah menargetkan inisiatif berdasarkan kepentingannya: apakah ingin memberikan reward kepada user 'retained' agar tetap bertransaksi di bulan berikutnya, menargetkan promo kepada user 'returning' agar lebih sering bertransaksi, dan sebagainya.

> Query

```postgresql
-- Pertama, kita buat tabel untuk merangkum kapan saja user melakukan transaksi tiap bulan
with user_monthly_transaction as (
    select distinct
    	date_trunc('month', o.created_at) as month_,
    	o.buyer_id
    from orders o
),

-- Selanjutnya, kita buat tabel untuk rangkuman retentionnya menggunakan case + lag function. 
-- Btw, umt = user_monthly_transaction
umt_lag_month as (
	select
		month_,
		lag(month_, 1) over(
			partition by buyer_id 
			order by buyer_id, month_
		) as lag_month_,
		buyer_id
	from user_monthly_transaction
),
umt_delta_month as (
	select
		month_,
		lag_month_,
		(
			extract(year from age(month_, lag_month_)) * 12 +
			extract(month from age(month_, lag_month_))
		) as delta_month_,
		buyer_id
	from umt_lag_month
),
user_retention_summary as (
    select
    	buyer_id as user_id,
    	month_,
    	lag_month_,
    	delta_month_,
    	case
    		when delta_month_ = 1 then 'retained'
    		when delta_month_ > 1 then 'returning'
    		when delta_month_ is null then 'new'
    	end as user_type
    from umt_delta_month
)

-- Terakhir, kita bisa menghitung jumlah user di bulan tertentu yang kembali lagi bertransaksi dari transaksi di bulan sebelumnya,
-- jumlah user baru, dan jumlah user yang kembali lagi dari setelah transaksi > 1 bulan lalu
select
	to_char(month_, 'YYYYMM') year_month,
	count(
		case 
			when user_type = 'retained' then user_id 
		end
	) as retained,
	count(
		case 
			when user_type = 'returning' then user_id 
		end
	) as returning,
	count(
		case 
			when user_type = 'new' then user_id 
		end
	) as new,
	count(user_id) as user_count
from user_retention_summary
group by 1
order by 1;
```

> Result

|year_month|retained|returning|new|user_count|
|----------|--------|---------|---|----------|
|201901|0|0|117|117|
|201902|3|0|347|350|
|201903|18|4|633|655|
|201904|37|24|898|959|
|201905|87|86|1250|1423|
|201906|155|176|1489|1820|
|201907|253|391|1832|2476|
|201908|405|648|1952|3005|
|201909|660|1144|2018|3822|
|201910|1012|1820|1967|4799|
|201911|1582|2487|1850|5919|
|201912|2557|3594|1567|7718|
|202001|2103|2178|542|4823|
|202002|1507|3562|480|5549|
|202003|2059|4403|385|6847|
|202004|2661|4557|268|7486|
|202005|2351|6977|282|9610|

> Data Visualization (via Metabase)

![Monthly Users](/assets/monthly-users.png)