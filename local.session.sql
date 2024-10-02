-- Pertama, kita buat tabel untuk merangkum kapan saja user melakukan transaksi tiap bulan
with user_monthly_transaction as (
    select distinct
    	date_trunc('month', o.created_at) as month_,
    	o.buyer_id
    from orders o
),

-- Selanjutnya, kita buat tabel untuk rangkuman retentionnya menggunakan case + lead function. 
-- Btw, umt = user_monthly_transaction
umt_lead_month as (
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
),
user_retention_summary as (
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
    from umt_delta_month
)

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
