# Main Metrics

## Monthly Transactions

Buat tabel rangkuman hasil transaksi bulanan, yakni jumlah transaksi (_transaction_count_) dan total nilai transaksi (_total_transaction_value_), beserta pertumbuhan tiap bulannya (_m_o_m_: month-on-month growth).

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```sql
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

</details>

</br>

> Result

<details>

<summary> <i>Lihat result</i> </summary>

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

</details> </br>


> Data Visualization (via Power BI)

![Monthly Transactions](/assets/monthly-trx.png)

## User Retention Rate

Buat tabel _user retention rate_ bulanan yang terinpirasi dari artikel [berikut](https://medium.com/cube-dev/customer-retention-analysis-93af9daee46b).

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```sql
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

</details>

</br>

> Result

<details>

<summary> <i>Lihat result</i> </summary>

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

</details> </br>

> Data Visualization (via Metabase)

![Monthly Retention Rate](/assets/monthly-retention.png)

## User Retention Rate (Another Technique)

Dalam perhitungan _user retention rate_ sebelumnya, kita memperoleh informasi berapa persen user di bulan tertentu yang akan kembali lagi melakukan transaksi tepat di bulan berikutnya. 

Ada cara lain untuk menghitung _user retention rate_, yaitu menghitung berapa persen user di bulan ini yang statusnya 'retained' dari bulan lalu. Selain dari user yang 'retained', keseluruhan user di bulan tertentu juga tersusun dari user 'new' dan 'returning'. User 'new' adalah user yang baru terakuisisi di bulan tertentu, sedangkan user 'returning' merupakan user yang kembali lagi bertransaksi setelah 'hilang' selama lebih dari 1 bulan. 

Dengan cara seperti ini, tim marketing dapat lebih mudah menargetkan inisiatif berdasarkan kepentingannya: apakah ingin memberikan reward kepada user 'retained' agar tetap bertransaksi di bulan berikutnya, menargetkan promo kepada user 'returning' agar lebih sering bertransaksi, dan sebagainya.

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```sql
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

</details>

</br>

> Result

<details>

<summary> <i>Lihat result</i> </summary>

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

</details> </br>

> Data Visualization (via Metabase)

![Monthly Users](/assets/monthly-users.png)

## Monthly User Cohort

Buat tabel monthly user cohort untuk menggambarkan retention rate secara lebih komprehensif.

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```sql
-- Kita buat view user_cohort berdasarkan rangkaian CTE berikut
drop view if exists user_cohort;
create view user_cohort as (
-- Pertama, kita buat tabel untuk merangkum kapan saja user melakukan transaksi tiap bulan
-- Kali ini, kita juga menambahkan informasi first_trx_month_
with user_monthly_transaction as (
    select distinct
    	date_trunc('month', o.created_at) as month_,
    	first_value(date_trunc('month', o.created_at)) over(
    		partition by o.buyer_id
    		order by o.created_at
    		range between unbounded preceding 
    			and unbounded following 
    	) as first_trx_month_,
    	o.buyer_id
    from orders o
),
-- Selanjutnya, kita buat CTE untuk merangkum bulan retentionnya
umt_retention_month as (
	select
		first_trx_month_,
		(
			extract(year from age(month_, first_trx_month_)) * 12 +
			extract(month from age(month_, first_trx_month_))
		) as retention_month_,
		buyer_id
	from user_monthly_transaction
),
-- Untuk jaga2 apabila ada suatu bulan yang mana tidak ada 'new users' atau sama sekali tidak ada user yang 'retained',
-- kita gunakan generate_series (Anda bisa skip CTE ini dan di tahap berikutnya, tidak perlu menggunakan CTE 'month_series')
month_series as (
	select
		first_trx_month_,
		retention_month_
	from (
		select 
			m::date as first_trx_month_
		from generate_series(
			(select min(first_trx_month_) from umt_retention_month)::date,
			(select max(first_trx_month_) from umt_retention_month)::date,
			interval '1 month'
		) as m
	) as ftm_series
	cross join (
		select
			m as retention_month_
		from generate_series(
			(select min(retention_month_) from umt_retention_month),
			(select max(retention_month_) from umt_retention_month),
			1
		) as m
	) as rm_series
)

-- Berikutnya, kita hitung jumlah user berdasarkan first_trx_month_ dan retention_month_-nya
select 
	m.first_trx_month_, 
	'month-' || lpad(m.retention_month_::varchar, 2, '0') as retention_month_, 
	count(u.buyer_id) as user_count
from month_series m
left join umt_retention_month u
	on m.first_trx_month_ = u.first_trx_month_
		and m.retention_month_ = u.retention_month_
group by 1,2
order by 1,2
);

select * from user_cohort;
```

</details>

</br>

> Result

<details>

<summary> <i>Lihat result</i> </summary>

|first_trx_month_|retention_month_|user_count|
|----------------|----------------|----------|
|2019-01-01|month-00|117|
|2019-01-01|month-01|3|
|2019-01-01|month-02|4|
|2019-01-01|month-03|8|
|2019-01-01|month-04|17|
|2019-01-01|month-05|16|
|2019-01-01|month-06|9|
|2019-01-01|month-07|22|
|2019-01-01|month-08|22|
|2019-01-01|month-09|18|
|2019-01-01|month-10|45|
|2019-01-01|month-11|52|
|2019-01-01|month-12|26|
|2019-01-01|month-13|36|
|2019-01-01|month-14|49|
|2019-01-01|month-15|44|
|2019-01-01|month-16|58|
|2019-02-01|month-00|347|
|2019-02-01|month-01|18|
|2019-02-01|month-02|16|
|2019-02-01|month-03|32|
|2019-02-01|month-04|37|
|2019-02-01|month-05|42|
|2019-02-01|month-06|65|
|2019-02-01|month-07|75|
|2019-02-01|month-08|103|
|2019-02-01|month-09|110|
|2019-02-01|month-10|151|
|2019-02-01|month-11|71|
|2019-02-01|month-12|111|
|2019-02-01|month-13|132|
|2019-02-01|month-14|144|
|2019-02-01|month-15|181|
|2019-02-01|month-16|0|
|2019-03-01|month-00|633|
|2019-03-01|month-01|37|
|2019-03-01|month-02|48|
|2019-03-01|month-03|51|
|2019-03-01|month-04|93|
|2019-03-01|month-05|113|
|2019-03-01|month-06|144|
|2019-03-01|month-07|162|
|2019-03-01|month-08|196|
|2019-03-01|month-09|258|
|2019-03-01|month-10|158|
|2019-03-01|month-11|198|
|2019-03-01|month-12|255|
|2019-03-01|month-13|263|
|2019-03-01|month-14|345|
|2019-03-01|month-15|0|
|2019-03-01|month-16|0|
|2019-04-01|month-00|898|
|2019-04-01|month-01|76|
|2019-04-01|month-02|87|
|2019-04-01|month-03|113|
|2019-04-01|month-04|138|
|2019-04-01|month-05|189|
|2019-04-01|month-06|246|
|2019-04-01|month-07|289|
|2019-04-01|month-08|382|
|2019-04-01|month-09|246|
|2019-04-01|month-10|273|
|2019-04-01|month-11|342|
|2019-04-01|month-12|372|
|2019-04-01|month-13|472|
|2019-04-01|month-14|0|
|2019-04-01|month-15|0|
|2019-04-01|month-16|0|
|2019-05-01|month-00|1250|
|2019-05-01|month-01|140|
|2019-05-01|month-02|174|
|2019-05-01|month-03|178|
|2019-05-01|month-04|257|
|2019-05-01|month-05|344|
|2019-05-01|month-06|412|
|2019-05-01|month-07|533|
|2019-05-01|month-08|352|
|2019-05-01|month-09|401|
|2019-05-01|month-10|478|
|2019-05-01|month-11|533|
|2019-05-01|month-12|655|
|2019-05-01|month-13|0|
|2019-05-01|month-14|0|
|2019-05-01|month-15|0|
|2019-05-01|month-16|0|
|2019-06-01|month-00|1489|
|2019-06-01|month-01|213|
|2019-06-01|month-02|242|
|2019-06-01|month-03|308|
|2019-06-01|month-04|388|
|2019-06-01|month-05|464|
|2019-06-01|month-06|627|
|2019-06-01|month-07|391|
|2019-06-01|month-08|462|
|2019-06-01|month-09|565|
|2019-06-01|month-10|633|
|2019-06-01|month-11|803|
|2019-06-01|month-12|0|
|2019-06-01|month-13|0|
|2019-06-01|month-14|0|
|2019-06-01|month-15|0|
|2019-06-01|month-16|0|
|2019-07-01|month-00|1832|
|2019-07-01|month-01|295|
|2019-07-01|month-02|378|
|2019-07-01|month-03|476|
|2019-07-01|month-04|596|
|2019-07-01|month-05|799|
|2019-07-01|month-06|486|
|2019-07-01|month-07|540|
|2019-07-01|month-08|689|
|2019-07-01|month-09|757|
|2019-07-01|month-10|982|
|2019-07-01|month-11|0|
|2019-07-01|month-12|0|
|2019-07-01|month-13|0|
|2019-07-01|month-14|0|
|2019-07-01|month-15|0|
|2019-07-01|month-16|0|
|2019-08-01|month-00|1952|
|2019-08-01|month-01|431|
|2019-08-01|month-02|534|
|2019-08-01|month-03|662|
|2019-08-01|month-04|832|
|2019-08-01|month-05|523|
|2019-08-01|month-06|584|
|2019-08-01|month-07|743|
|2019-08-01|month-08|837|
|2019-08-01|month-09|1048|
|2019-08-01|month-10|0|
|2019-08-01|month-11|0|
|2019-08-01|month-12|0|
|2019-08-01|month-13|0|
|2019-08-01|month-14|0|
|2019-08-01|month-15|0|
|2019-08-01|month-16|0|
|2019-09-01|month-00|2018|
|2019-09-01|month-01|561|
|2019-09-01|month-02|665|
|2019-09-01|month-03|837|
|2019-09-01|month-04|565|
|2019-09-01|month-05|612|
|2019-09-01|month-06|773|
|2019-09-01|month-07|814|
|2019-09-01|month-08|1097|
|2019-09-01|month-09|0|
|2019-09-01|month-10|0|
|2019-09-01|month-11|0|
|2019-09-01|month-12|0|
|2019-09-01|month-13|0|
|2019-09-01|month-14|0|
|2019-09-01|month-15|0|
|2019-09-01|month-16|0|
|2019-10-01|month-00|1967|
|2019-10-01|month-01|630|
|2019-10-01|month-02|869|
|2019-10-01|month-03|547|
|2019-10-01|month-04|603|
|2019-10-01|month-05|734|
|2019-10-01|month-06|819|
|2019-10-01|month-07|1075|
|2019-10-01|month-08|0|
|2019-10-01|month-09|0|
|2019-10-01|month-10|0|
|2019-10-01|month-11|0|
|2019-10-01|month-12|0|
|2019-10-01|month-13|0|
|2019-10-01|month-14|0|
|2019-10-01|month-15|0|
|2019-10-01|month-16|0|
|2019-11-01|month-00|1850|
|2019-11-01|month-01|811|
|2019-11-01|month-02|476|
|2019-11-01|month-03|612|
|2019-11-01|month-04|698|
|2019-11-01|month-05|765|
|2019-11-01|month-06|967|
|2019-11-01|month-07|0|
|2019-11-01|month-08|0|
|2019-11-01|month-09|0|
|2019-11-01|month-10|0|
|2019-11-01|month-11|0|
|2019-11-01|month-12|0|
|2019-11-01|month-13|0|
|2019-11-01|month-14|0|
|2019-11-01|month-15|0|
|2019-11-01|month-16|0|
|2019-12-01|month-00|1567|
|2019-12-01|month-01|440|
|2019-12-01|month-02|478|
|2019-12-01|month-03|611|
|2019-12-01|month-04|658|
|2019-12-01|month-05|844|
|2019-12-01|month-06|0|
|2019-12-01|month-07|0|
|2019-12-01|month-08|0|
|2019-12-01|month-09|0|
|2019-12-01|month-10|0|
|2019-12-01|month-11|0|
|2019-12-01|month-12|0|
|2019-12-01|month-13|0|
|2019-12-01|month-14|0|
|2019-12-01|month-15|0|
|2019-12-01|month-16|0|
|2020-01-01|month-00|542|
|2020-01-01|month-01|159|
|2020-01-01|month-02|213|
|2020-01-01|month-03|241|
|2020-01-01|month-04|283|
|2020-01-01|month-05|0|
|2020-01-01|month-06|0|
|2020-01-01|month-07|0|
|2020-01-01|month-08|0|
|2020-01-01|month-09|0|
|2020-01-01|month-10|0|
|2020-01-01|month-11|0|
|2020-01-01|month-12|0|
|2020-01-01|month-13|0|
|2020-01-01|month-14|0|
|2020-01-01|month-15|0|
|2020-01-01|month-16|0|
|2020-02-01|month-00|480|
|2020-02-01|month-01|180|
|2020-02-01|month-02|188|
|2020-02-01|month-03|238|
|2020-02-01|month-04|0|
|2020-02-01|month-05|0|
|2020-02-01|month-06|0|
|2020-02-01|month-07|0|
|2020-02-01|month-08|0|
|2020-02-01|month-09|0|
|2020-02-01|month-10|0|
|2020-02-01|month-11|0|
|2020-02-01|month-12|0|
|2020-02-01|month-13|0|
|2020-02-01|month-14|0|
|2020-02-01|month-15|0|
|2020-02-01|month-16|0|
|2020-03-01|month-00|385|
|2020-03-01|month-01|150|
|2020-03-01|month-02|183|
|2020-03-01|month-03|0|
|2020-03-01|month-04|0|
|2020-03-01|month-05|0|
|2020-03-01|month-06|0|
|2020-03-01|month-07|0|
|2020-03-01|month-08|0|
|2020-03-01|month-09|0|
|2020-03-01|month-10|0|
|2020-03-01|month-11|0|
|2020-03-01|month-12|0|
|2020-03-01|month-13|0|
|2020-03-01|month-14|0|
|2020-03-01|month-15|0|
|2020-03-01|month-16|0|
|2020-04-01|month-00|268|
|2020-04-01|month-01|97|
|2020-04-01|month-02|0|
|2020-04-01|month-03|0|
|2020-04-01|month-04|0|
|2020-04-01|month-05|0|
|2020-04-01|month-06|0|
|2020-04-01|month-07|0|
|2020-04-01|month-08|0|
|2020-04-01|month-09|0|
|2020-04-01|month-10|0|
|2020-04-01|month-11|0|
|2020-04-01|month-12|0|
|2020-04-01|month-13|0|
|2020-04-01|month-14|0|
|2020-04-01|month-15|0|
|2020-04-01|month-16|0|
|2020-05-01|month-00|282|
|2020-05-01|month-01|0|
|2020-05-01|month-02|0|
|2020-05-01|month-03|0|
|2020-05-01|month-04|0|
|2020-05-01|month-05|0|
|2020-05-01|month-06|0|
|2020-05-01|month-07|0|
|2020-05-01|month-08|0|
|2020-05-01|month-09|0|
|2020-05-01|month-10|0|
|2020-05-01|month-11|0|
|2020-05-01|month-12|0|
|2020-05-01|month-13|0|
|2020-05-01|month-14|0|
|2020-05-01|month-15|0|
|2020-05-01|month-16|0|

</details> </br>

> Data Visualization (via Metabase)

![Monthly User Cohort](/assets/monthly-user-cohort.png)

## Monthly User Cohort (%)

Umumnya, ketika membicarakan cohort, kita berbicara mengenai persentase user yang diakuisi di bulan tertentu dan melakukan transaksi kembali di bulan-bulan setelahnya. Oleh karena itu, buat kembali tabel cohort yang memenuhi kebutuhan tersebut.

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```sql
drop view if exists user_cohort_new;
create view user_cohort_new as (
select 
	u.*,
	u.user_count::numeric / u.new_user_count as retention_rate
from (
	select 
		first_trx_month_,
		retention_month_,
		user_count,
		first_value(user_count) over(
			partition by first_trx_month_
			order by first_trx_month_, retention_month_
			range between unbounded preceding 
				and unbounded following 
		) as new_user_count
	from user_cohort
	order by 1,2
) u
);

select * from user_cohort_new;
```

</details>

</br>

> Result

<details>

<summary> <i>Lihat result</i> </summary>

|first_trx_month_|retention_month_|user_count|new_user_count|retention_rate|
|----------------|----------------|----------|--------------|--------------|
|2019-01-01|month-00|117|117|1.00000000000000000000|
|2019-01-01|month-01|3|117|0.02564102564102564103|
|2019-01-01|month-02|4|117|0.03418803418803418803|
|2019-01-01|month-03|8|117|0.06837606837606837607|
|2019-01-01|month-04|17|117|0.14529914529914529915|
|2019-01-01|month-05|16|117|0.13675213675213675214|
|2019-01-01|month-06|9|117|0.07692307692307692308|
|2019-01-01|month-07|22|117|0.18803418803418803419|
|2019-01-01|month-08|22|117|0.18803418803418803419|
|2019-01-01|month-09|18|117|0.15384615384615384615|
|2019-01-01|month-10|45|117|0.38461538461538461538|
|2019-01-01|month-11|52|117|0.44444444444444444444|
|2019-01-01|month-12|26|117|0.22222222222222222222|
|2019-01-01|month-13|36|117|0.30769230769230769231|
|2019-01-01|month-14|49|117|0.41880341880341880342|
|2019-01-01|month-15|44|117|0.37606837606837606838|
|2019-01-01|month-16|58|117|0.49572649572649572650|
|2019-02-01|month-00|347|347|1.00000000000000000000|
|2019-02-01|month-01|18|347|0.05187319884726224784|
|2019-02-01|month-02|16|347|0.04610951008645533141|
|2019-02-01|month-03|32|347|0.09221902017291066282|
|2019-02-01|month-04|37|347|0.10662824207492795389|
|2019-02-01|month-05|42|347|0.12103746397694524496|
|2019-02-01|month-06|65|347|0.18731988472622478386|
|2019-02-01|month-07|75|347|0.21613832853025936599|
|2019-02-01|month-08|103|347|0.29682997118155619597|
|2019-02-01|month-09|110|347|0.31700288184438040346|
|2019-02-01|month-10|151|347|0.43515850144092219020|
|2019-02-01|month-11|71|347|0.20461095100864553314|
|2019-02-01|month-12|111|347|0.31988472622478386167|
|2019-02-01|month-13|132|347|0.38040345821325648415|
|2019-02-01|month-14|144|347|0.41498559077809798271|
|2019-02-01|month-15|181|347|0.52161383285302593660|
|2019-02-01|month-16|0|347|0.00000000000000000000|
|2019-03-01|month-00|633|633|1.00000000000000000000|
|2019-03-01|month-01|37|633|0.05845181674565560821|
|2019-03-01|month-02|48|633|0.07582938388625592417|
|2019-03-01|month-03|51|633|0.08056872037914691943|
|2019-03-01|month-04|93|633|0.14691943127962085308|
|2019-03-01|month-05|113|633|0.17851500789889415482|
|2019-03-01|month-06|144|633|0.22748815165876777251|
|2019-03-01|month-07|162|633|0.25592417061611374408|
|2019-03-01|month-08|196|633|0.30963665086887835703|
|2019-03-01|month-09|258|633|0.40758293838862559242|
|2019-03-01|month-10|158|633|0.24960505529225908373|
|2019-03-01|month-11|198|633|0.31279620853080568720|
|2019-03-01|month-12|255|633|0.40284360189573459716|
|2019-03-01|month-13|263|633|0.41548183254344391785|
|2019-03-01|month-14|345|633|0.54502369668246445498|
|2019-03-01|month-15|0|633|0.00000000000000000000|
|2019-03-01|month-16|0|633|0.00000000000000000000|
|2019-04-01|month-00|898|898|1.00000000000000000000|
|2019-04-01|month-01|76|898|0.08463251670378619154|
|2019-04-01|month-02|87|898|0.09688195991091314031|
|2019-04-01|month-03|113|898|0.12583518930957683742|
|2019-04-01|month-04|138|898|0.15367483296213808463|
|2019-04-01|month-05|189|898|0.21046770601336302895|
|2019-04-01|month-06|246|898|0.27394209354120267261|
|2019-04-01|month-07|289|898|0.32182628062360801782|
|2019-04-01|month-08|382|898|0.42538975501113585746|
|2019-04-01|month-09|246|898|0.27394209354120267261|
|2019-04-01|month-10|273|898|0.30400890868596881960|
|2019-04-01|month-11|342|898|0.38084632516703786192|
|2019-04-01|month-12|372|898|0.41425389755011135857|
|2019-04-01|month-13|472|898|0.52561247216035634744|
|2019-04-01|month-14|0|898|0.00000000000000000000|
|2019-04-01|month-15|0|898|0.00000000000000000000|
|2019-04-01|month-16|0|898|0.00000000000000000000|
|2019-05-01|month-00|1250|1250|1.00000000000000000000|
|2019-05-01|month-01|140|1250|0.11200000000000000000|
|2019-05-01|month-02|174|1250|0.13920000000000000000|
|2019-05-01|month-03|178|1250|0.14240000000000000000|
|2019-05-01|month-04|257|1250|0.20560000000000000000|
|2019-05-01|month-05|344|1250|0.27520000000000000000|
|2019-05-01|month-06|412|1250|0.32960000000000000000|
|2019-05-01|month-07|533|1250|0.42640000000000000000|
|2019-05-01|month-08|352|1250|0.28160000000000000000|
|2019-05-01|month-09|401|1250|0.32080000000000000000|
|2019-05-01|month-10|478|1250|0.38240000000000000000|
|2019-05-01|month-11|533|1250|0.42640000000000000000|
|2019-05-01|month-12|655|1250|0.52400000000000000000|
|2019-05-01|month-13|0|1250|0.00000000000000000000|
|2019-05-01|month-14|0|1250|0.00000000000000000000|
|2019-05-01|month-15|0|1250|0.00000000000000000000|
|2019-05-01|month-16|0|1250|0.00000000000000000000|
|2019-06-01|month-00|1489|1489|1.00000000000000000000|
|2019-06-01|month-01|213|1489|0.14304902619207521827|
|2019-06-01|month-02|242|1489|0.16252518468770987240|
|2019-06-01|month-03|308|1489|0.20685023505708529214|
|2019-06-01|month-04|388|1489|0.26057756883814640698|
|2019-06-01|month-05|464|1489|0.31161853593015446608|
|2019-06-01|month-06|627|1489|0.42108797850906648758|
|2019-06-01|month-07|391|1489|0.26259234385493619879|
|2019-06-01|month-08|462|1489|0.31027535258562793821|
|2019-06-01|month-09|565|1489|0.37944929482874412357|
|2019-06-01|month-10|633|1489|0.42511752854264607119|
|2019-06-01|month-11|803|1489|0.53928811282740094023|
|2019-06-01|month-12|0|1489|0.00000000000000000000|
|2019-06-01|month-13|0|1489|0.00000000000000000000|
|2019-06-01|month-14|0|1489|0.00000000000000000000|
|2019-06-01|month-15|0|1489|0.00000000000000000000|
|2019-06-01|month-16|0|1489|0.00000000000000000000|
|2019-07-01|month-00|1832|1832|1.00000000000000000000|
|2019-07-01|month-01|295|1832|0.16102620087336244541|
|2019-07-01|month-02|378|1832|0.20633187772925764192|
|2019-07-01|month-03|476|1832|0.25982532751091703057|
|2019-07-01|month-04|596|1832|0.32532751091703056769|
|2019-07-01|month-05|799|1832|0.43613537117903930131|
|2019-07-01|month-06|486|1832|0.26528384279475982533|
|2019-07-01|month-07|540|1832|0.29475982532751091703|
|2019-07-01|month-08|689|1832|0.37609170305676855895|
|2019-07-01|month-09|757|1832|0.41320960698689956332|
|2019-07-01|month-10|982|1832|0.53602620087336244541|
|2019-07-01|month-11|0|1832|0.00000000000000000000|
|2019-07-01|month-12|0|1832|0.00000000000000000000|
|2019-07-01|month-13|0|1832|0.00000000000000000000|
|2019-07-01|month-14|0|1832|0.00000000000000000000|
|2019-07-01|month-15|0|1832|0.00000000000000000000|
|2019-07-01|month-16|0|1832|0.00000000000000000000|
|2019-08-01|month-00|1952|1952|1.00000000000000000000|
|2019-08-01|month-01|431|1952|0.22079918032786885246|
|2019-08-01|month-02|534|1952|0.27356557377049180328|
|2019-08-01|month-03|662|1952|0.33913934426229508197|
|2019-08-01|month-04|832|1952|0.42622950819672131148|
|2019-08-01|month-05|523|1952|0.26793032786885245902|
|2019-08-01|month-06|584|1952|0.29918032786885245902|
|2019-08-01|month-07|743|1952|0.38063524590163934426|
|2019-08-01|month-08|837|1952|0.42879098360655737705|
|2019-08-01|month-09|1048|1952|0.53688524590163934426|
|2019-08-01|month-10|0|1952|0.00000000000000000000|
|2019-08-01|month-11|0|1952|0.00000000000000000000|
|2019-08-01|month-12|0|1952|0.00000000000000000000|
|2019-08-01|month-13|0|1952|0.00000000000000000000|
|2019-08-01|month-14|0|1952|0.00000000000000000000|
|2019-08-01|month-15|0|1952|0.00000000000000000000|
|2019-08-01|month-16|0|1952|0.00000000000000000000|
|2019-09-01|month-00|2018|2018|1.00000000000000000000|
|2019-09-01|month-01|561|2018|0.27799801783944499504|
|2019-09-01|month-02|665|2018|0.32953419226957383548|
|2019-09-01|month-03|837|2018|0.41476709613478691774|
|2019-09-01|month-04|565|2018|0.27998017839444995045|
|2019-09-01|month-05|612|2018|0.30327056491575817641|
|2019-09-01|month-06|773|2018|0.38305252725470763132|
|2019-09-01|month-07|814|2018|0.40336967294350842418|
|2019-09-01|month-08|1097|2018|0.54360753221010901883|
|2019-09-01|month-09|0|2018|0.00000000000000000000|
|2019-09-01|month-10|0|2018|0.00000000000000000000|
|2019-09-01|month-11|0|2018|0.00000000000000000000|
|2019-09-01|month-12|0|2018|0.00000000000000000000|
|2019-09-01|month-13|0|2018|0.00000000000000000000|
|2019-09-01|month-14|0|2018|0.00000000000000000000|
|2019-09-01|month-15|0|2018|0.00000000000000000000|
|2019-09-01|month-16|0|2018|0.00000000000000000000|
|2019-10-01|month-00|1967|1967|1.00000000000000000000|
|2019-10-01|month-01|630|1967|0.32028469750889679715|
|2019-10-01|month-02|869|1967|0.44178952719877986782|
|2019-10-01|month-03|547|1967|0.27808845958312150483|
|2019-10-01|month-04|603|1967|0.30655821047280122013|
|2019-10-01|month-05|734|1967|0.37315709201830198271|
|2019-10-01|month-06|819|1967|0.41637010676156583630|
|2019-10-01|month-07|1075|1967|0.54651753940010167768|
|2019-10-01|month-08|0|1967|0.00000000000000000000|
|2019-10-01|month-09|0|1967|0.00000000000000000000|
|2019-10-01|month-10|0|1967|0.00000000000000000000|
|2019-10-01|month-11|0|1967|0.00000000000000000000|
|2019-10-01|month-12|0|1967|0.00000000000000000000|
|2019-10-01|month-13|0|1967|0.00000000000000000000|
|2019-10-01|month-14|0|1967|0.00000000000000000000|
|2019-10-01|month-15|0|1967|0.00000000000000000000|
|2019-10-01|month-16|0|1967|0.00000000000000000000|
|2019-11-01|month-00|1850|1850|1.00000000000000000000|
|2019-11-01|month-01|811|1850|0.43837837837837837838|
|2019-11-01|month-02|476|1850|0.25729729729729729730|
|2019-11-01|month-03|612|1850|0.33081081081081081081|
|2019-11-01|month-04|698|1850|0.37729729729729729730|
|2019-11-01|month-05|765|1850|0.41351351351351351351|
|2019-11-01|month-06|967|1850|0.52270270270270270270|
|2019-11-01|month-07|0|1850|0.00000000000000000000|
|2019-11-01|month-08|0|1850|0.00000000000000000000|
|2019-11-01|month-09|0|1850|0.00000000000000000000|
|2019-11-01|month-10|0|1850|0.00000000000000000000|
|2019-11-01|month-11|0|1850|0.00000000000000000000|
|2019-11-01|month-12|0|1850|0.00000000000000000000|
|2019-11-01|month-13|0|1850|0.00000000000000000000|
|2019-11-01|month-14|0|1850|0.00000000000000000000|
|2019-11-01|month-15|0|1850|0.00000000000000000000|
|2019-11-01|month-16|0|1850|0.00000000000000000000|
|2019-12-01|month-00|1567|1567|1.00000000000000000000|
|2019-12-01|month-01|440|1567|0.28079132099553286535|
|2019-12-01|month-02|478|1567|0.30504148053605615826|
|2019-12-01|month-03|611|1567|0.38991703892788768347|
|2019-12-01|month-04|658|1567|0.41991065730695596682|
|2019-12-01|month-05|844|1567|0.53860880663688576899|
|2019-12-01|month-06|0|1567|0.00000000000000000000|
|2019-12-01|month-07|0|1567|0.00000000000000000000|
|2019-12-01|month-08|0|1567|0.00000000000000000000|
|2019-12-01|month-09|0|1567|0.00000000000000000000|
|2019-12-01|month-10|0|1567|0.00000000000000000000|
|2019-12-01|month-11|0|1567|0.00000000000000000000|
|2019-12-01|month-12|0|1567|0.00000000000000000000|
|2019-12-01|month-13|0|1567|0.00000000000000000000|
|2019-12-01|month-14|0|1567|0.00000000000000000000|
|2019-12-01|month-15|0|1567|0.00000000000000000000|
|2019-12-01|month-16|0|1567|0.00000000000000000000|
|2020-01-01|month-00|542|542|1.00000000000000000000|
|2020-01-01|month-01|159|542|0.29335793357933579336|
|2020-01-01|month-02|213|542|0.39298892988929889299|
|2020-01-01|month-03|241|542|0.44464944649446494465|
|2020-01-01|month-04|283|542|0.52214022140221402214|
|2020-01-01|month-05|0|542|0.00000000000000000000|
|2020-01-01|month-06|0|542|0.00000000000000000000|
|2020-01-01|month-07|0|542|0.00000000000000000000|
|2020-01-01|month-08|0|542|0.00000000000000000000|
|2020-01-01|month-09|0|542|0.00000000000000000000|
|2020-01-01|month-10|0|542|0.00000000000000000000|
|2020-01-01|month-11|0|542|0.00000000000000000000|
|2020-01-01|month-12|0|542|0.00000000000000000000|
|2020-01-01|month-13|0|542|0.00000000000000000000|
|2020-01-01|month-14|0|542|0.00000000000000000000|
|2020-01-01|month-15|0|542|0.00000000000000000000|
|2020-01-01|month-16|0|542|0.00000000000000000000|
|2020-02-01|month-00|480|480|1.00000000000000000000|
|2020-02-01|month-01|180|480|0.37500000000000000000|
|2020-02-01|month-02|188|480|0.39166666666666666667|
|2020-02-01|month-03|238|480|0.49583333333333333333|
|2020-02-01|month-04|0|480|0.00000000000000000000|
|2020-02-01|month-05|0|480|0.00000000000000000000|
|2020-02-01|month-06|0|480|0.00000000000000000000|
|2020-02-01|month-07|0|480|0.00000000000000000000|
|2020-02-01|month-08|0|480|0.00000000000000000000|
|2020-02-01|month-09|0|480|0.00000000000000000000|
|2020-02-01|month-10|0|480|0.00000000000000000000|
|2020-02-01|month-11|0|480|0.00000000000000000000|
|2020-02-01|month-12|0|480|0.00000000000000000000|
|2020-02-01|month-13|0|480|0.00000000000000000000|
|2020-02-01|month-14|0|480|0.00000000000000000000|
|2020-02-01|month-15|0|480|0.00000000000000000000|
|2020-02-01|month-16|0|480|0.00000000000000000000|
|2020-03-01|month-00|385|385|1.00000000000000000000|
|2020-03-01|month-01|150|385|0.38961038961038961039|
|2020-03-01|month-02|183|385|0.47532467532467532468|
|2020-03-01|month-03|0|385|0.00000000000000000000|
|2020-03-01|month-04|0|385|0.00000000000000000000|
|2020-03-01|month-05|0|385|0.00000000000000000000|
|2020-03-01|month-06|0|385|0.00000000000000000000|
|2020-03-01|month-07|0|385|0.00000000000000000000|
|2020-03-01|month-08|0|385|0.00000000000000000000|
|2020-03-01|month-09|0|385|0.00000000000000000000|
|2020-03-01|month-10|0|385|0.00000000000000000000|
|2020-03-01|month-11|0|385|0.00000000000000000000|
|2020-03-01|month-12|0|385|0.00000000000000000000|
|2020-03-01|month-13|0|385|0.00000000000000000000|
|2020-03-01|month-14|0|385|0.00000000000000000000|
|2020-03-01|month-15|0|385|0.00000000000000000000|
|2020-03-01|month-16|0|385|0.00000000000000000000|
|2020-04-01|month-00|268|268|1.00000000000000000000|
|2020-04-01|month-01|97|268|0.36194029850746268657|
|2020-04-01|month-02|0|268|0.00000000000000000000|
|2020-04-01|month-03|0|268|0.00000000000000000000|
|2020-04-01|month-04|0|268|0.00000000000000000000|
|2020-04-01|month-05|0|268|0.00000000000000000000|
|2020-04-01|month-06|0|268|0.00000000000000000000|
|2020-04-01|month-07|0|268|0.00000000000000000000|
|2020-04-01|month-08|0|268|0.00000000000000000000|
|2020-04-01|month-09|0|268|0.00000000000000000000|
|2020-04-01|month-10|0|268|0.00000000000000000000|
|2020-04-01|month-11|0|268|0.00000000000000000000|
|2020-04-01|month-12|0|268|0.00000000000000000000|
|2020-04-01|month-13|0|268|0.00000000000000000000|
|2020-04-01|month-14|0|268|0.00000000000000000000|
|2020-04-01|month-15|0|268|0.00000000000000000000|
|2020-04-01|month-16|0|268|0.00000000000000000000|
|2020-05-01|month-00|282|282|1.00000000000000000000|
|2020-05-01|month-01|0|282|0.00000000000000000000|
|2020-05-01|month-02|0|282|0.00000000000000000000|
|2020-05-01|month-03|0|282|0.00000000000000000000|
|2020-05-01|month-04|0|282|0.00000000000000000000|
|2020-05-01|month-05|0|282|0.00000000000000000000|
|2020-05-01|month-06|0|282|0.00000000000000000000|
|2020-05-01|month-07|0|282|0.00000000000000000000|
|2020-05-01|month-08|0|282|0.00000000000000000000|
|2020-05-01|month-09|0|282|0.00000000000000000000|
|2020-05-01|month-10|0|282|0.00000000000000000000|
|2020-05-01|month-11|0|282|0.00000000000000000000|
|2020-05-01|month-12|0|282|0.00000000000000000000|
|2020-05-01|month-13|0|282|0.00000000000000000000|
|2020-05-01|month-14|0|282|0.00000000000000000000|
|2020-05-01|month-15|0|282|0.00000000000000000000|
|2020-05-01|month-16|0|282|0.00000000000000000000|

</details> </br>

> Data Visualization (via Metabase)

![Monthly User Cohort New](/assets/monthly-user-cohort-new.png)


Kita bisa memasukkan data ini langsung ke pemvisualisasi data, tetapi jika kita ingin membentuk pivot tabel dari hasil query, kita bisa menggunakan fungsi _crosstab_ dari ekstensi _tablefunc_ yang merupakan salah satu ekstensi dari PostgreSQL.

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```sql
-- Selanjutnya, kita membutuhkan dynamic query dengan PL/pgSQL untuk membuat tabel hasil crosstab.

do $$
declare 
	crosstab_cols text;
	final_cols text;
	query text;
begin
	-- Drop the view
	drop view if exists user_cohort_pivoted;

	-- Dynamically generate the list of columns
	select 
		string_agg(formatted_retention_month_, ', ' order by formatted_retention_month_)
	into crosstab_cols
	from (select distinct format('"%s" numeric', retention_month_) as formatted_retention_month_ from user_cohort_new) subquery;
	
-- Dynamically generate the list of columns
	select 
		string_agg(formatted_retention_month_, ', ' order by formatted_retention_month_)
	into final_cols
	from (select distinct format('ct."%s"', retention_month_) as formatted_retention_month_ from user_cohort_new) subquery;

-- Construct the final crosstab query + create view with proper escaping
	query:= format('
	create view user_cohort_pivoted as (
	select
		ct.first_month,
		u.new_user_count as new_user,
		%s
	from crosstab(
		''select first_trx_month_, retention_month_, round(100*retention_rate, 2) from user_cohort_new order by 1, 2'',
		''select distinct retention_month_ from user_cohort_new order by 1''
	) as ct(first_month date, %s)
	left join (
		select distinct 
			first_trx_month_, 
			new_user_count 
		from user_cohort_new
	) u
		on ct.first_month = u.first_trx_month_::date
	);',
	final_cols, crosstab_cols);
	raise info '%s', query;
	
	-- Execute the query
	execute query;
end $$;

select * from user_cohort_pivoted;
```

</details>

</br>

> Result

<details>

<summary> <i>Lihat result</i> </summary>

|first_month|new_user|month-00|month-01|month-02|month-03|month-04|month-05|month-06|month-07|month-08|month-09|month-10|month-11|month-12|month-13|month-14|month-15|month-16|
|-----------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|
|2019-01-01|117|100.00|2.56|3.42|6.84|14.53|13.68|7.69|18.80|18.80|15.38|38.46|44.44|22.22|30.77|41.88|37.61|49.57|
|2019-02-01|347|100.00|5.19|4.61|9.22|10.66|12.10|18.73|21.61|29.68|31.70|43.52|20.46|31.99|38.04|41.50|52.16|0.00|
|2019-03-01|633|100.00|5.85|7.58|8.06|14.69|17.85|22.75|25.59|30.96|40.76|24.96|31.28|40.28|41.55|54.50|0.00|0.00|
|2019-04-01|898|100.00|8.46|9.69|12.58|15.37|21.05|27.39|32.18|42.54|27.39|30.40|38.08|41.43|52.56|0.00|0.00|0.00|
|2019-05-01|1250|100.00|11.20|13.92|14.24|20.56|27.52|32.96|42.64|28.16|32.08|38.24|42.64|52.40|0.00|0.00|0.00|0.00|
|2019-06-01|1489|100.00|14.30|16.25|20.69|26.06|31.16|42.11|26.26|31.03|37.94|42.51|53.93|0.00|0.00|0.00|0.00|0.00|
|2019-07-01|1832|100.00|16.10|20.63|25.98|32.53|43.61|26.53|29.48|37.61|41.32|53.60|0.00|0.00|0.00|0.00|0.00|0.00|
|2019-08-01|1952|100.00|22.08|27.36|33.91|42.62|26.79|29.92|38.06|42.88|53.69|0.00|0.00|0.00|0.00|0.00|0.00|0.00|
|2019-09-01|2018|100.00|27.80|32.95|41.48|28.00|30.33|38.31|40.34|54.36|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|
|2019-10-01|1967|100.00|32.03|44.18|27.81|30.66|37.32|41.64|54.65|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|
|2019-11-01|1850|100.00|43.84|25.73|33.08|37.73|41.35|52.27|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|
|2019-12-01|1567|100.00|28.08|30.50|38.99|41.99|53.86|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|
|2020-01-01|542|100.00|29.34|39.30|44.46|52.21|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|
|2020-02-01|480|100.00|37.50|39.17|49.58|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|
|2020-03-01|385|100.00|38.96|47.53|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|
|2020-04-01|268|100.00|36.19|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|
|2020-05-01|282|100.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|0.00|

</details> </br>

