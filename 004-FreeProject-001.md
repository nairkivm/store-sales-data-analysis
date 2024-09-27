# Main Metrics

## Monthly Transactions

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

