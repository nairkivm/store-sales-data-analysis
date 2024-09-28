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

Buat tabel _user retention rate_ bulanan dengan menggunakan rumus (total pembeli akhir bulan - pembeli baru) / total pembeli awal bulan.

> Query

```postgresql
-- Pertama, buat CTE/temp table untuk menampung data new orders
-- Note: gunakan windows function untuk mendapat order_id pertama setiap user
with new_orders as (
	select distinct
		buyer_id,
		first_value(order_id) over(
			partition by buyer_id
			order by created_at
			rows between unbounded preceding 
				and unbounded following 
		) as first_order_id
	from orders
),
-- Selanjutnya, buat CTE/temp table untuk menampung user summary yang mengandung
-- jumlah total users dan new users
user_summary as (
	select
		to_char(created_at, 'YYYYMM') as year_month,
		count(distinct u.user_id) as total_users,
		count(distinct n.buyer_id) as total_new_users
	from orders o
	join users u
		on o.buyer_id = u.user_id
	left join new_orders n
		on o.buyer_id = n.first_order_id 
	group by 1
)
-- Terakhir, buat query untuk perhitungan user retention
-- Note: gunakan fungsi lag
select 
	year_month,
	total_users,
	total_new_users,
	round(1::numeric*(total_users - total_new_users)/lag(total_users) over(
		order by year_month
	), 3) as user_retention_rate
from user_summary
order by year_month
```

> Result

|year_month|total_users|total_new_users|user_retention_rate|
|----------|-----------|---------------|-------------------|
|201901|117|4||
|201902|350|17|2.846|
|201903|655|28|1.791|
|201904|959|38|1.406|
|201905|1423|46|1.436|
|201906|1820|65|1.233|
|201907|2476|86|1.313|
|201908|3005|116|1.167|
|201909|3822|133|1.228|
|201910|4799|170|1.211|
|201911|5919|229|1.186|
|201912|7718|288|1.255|
|202001|4823|192|0.600|
|202002|5549|219|1.105|
|202003|6847|255|1.188|
|202004|7486|259|1.055|
|202005|9610|377|1.233|
