# Chapter 002

- [Chapter 002](#chapter-002)
	- [Products](#products)
		- [Ada berapa kolom pada data produk?](#ada-berapa-kolom-pada-data-produk)
		- [Ada berapa baris pada data produk?](#ada-berapa-baris-pada-data-produk)
		- [Ada berapa jenis kategori produk](#ada-berapa-jenis-kategori-produk)
		- [Ada berapa variabel yang mempunyai nilai NULL / kosong](#ada-berapa-variabel-yang-mempunyai-nilai-null--kosong)
	- [Orders](#orders)
		- [Ada berapa kolom / variabel pada data order?](#ada-berapa-kolom--variabel-pada-data-order)
		- [Ada berapa baris pada data order?](#ada-berapa-baris-pada-data-order)
		- [Ada berapa variabel yang mempunyai nilai NULL / kosong](#ada-berapa-variabel-yang-mempunyai-nilai-null--kosong-1)
		- [Ada berapa variabel yang berisi data amount (rupiah)](#ada-berapa-variabel-yang-berisi-data-amount-rupiah)
		- [Ada berapa variabel yang berisi data tanggal](#ada-berapa-variabel-yang-berisi-data-tanggal)
	- [Transaksi Bulanan](#transaksi-bulanan)
		- [Ada berapa transaksi setiap bulan?](#ada-berapa-transaksi-setiap-bulan)
	- [Status Transaksi](#status-transaksi)
		- [Ada berapa transaksi yang tidak dibayar?](#ada-berapa-transaksi-yang-tidak-dibayar)
		- [Ada berapa transaksi yang sudah dibayar tapi tidak dikirim?](#ada-berapa-transaksi-yang-sudah-dibayar-tapi-tidak-dikirim)
		- [Ada berapa transaksi yang tidak dikrim, baik sudah dibayar maupun belum?](#ada-berapa-transaksi-yang-tidak-dikrim-baik-sudah-dibayar-maupun-belum)
		- [Ada berapa transaksi yang dikirim pada hari yang sama dengan tangal dibayar?](#ada-berapa-transaksi-yang-dikirim-pada-hari-yang-sama-dengan-tangal-dibayar)
	- [Pengguna bertransaksi](#pengguna-bertransaksi)
		- [Ada berapa total pengguna?](#ada-berapa-total-pengguna)
		- [Ada berapa total pengguna yang pernah bertransaksi sebagai pembeli?](#ada-berapa-total-pengguna-yang-pernah-bertransaksi-sebagai-pembeli)
		- [Ada berapa total pengguna yang pernah bertransaksi sebagai penjual?](#ada-berapa-total-pengguna-yang-pernah-bertransaksi-sebagai-penjual)
		- [Ada berapa total pengguna yang pernah bertransaksi sebagai pembeli dan pernah sebagai penjual?](#ada-berapa-total-pengguna-yang-pernah-bertransaksi-sebagai-pembeli-dan-pernah-sebagai-penjual)
		- [Ada berapa total pengguna yang tidak pernah bertransaksi sebagai pembeli maupun penjual?](#ada-berapa-total-pengguna-yang-tidak-pernah-bertransaksi-sebagai-pembeli-maupun-penjual)
	- [Top Buyer all time](#top-buyer-all-time)
		- [Siapakah 5 top pembeli dengan dengan total pembelian terbesar (berdasarkan total harga barang setelah diskon)?](#siapakah-5-top-pembeli-dengan-dengan-total-pembelian-terbesar-berdasarkan-total-harga-barang-setelah-diskon)
	- [Frequent Buyer](#frequent-buyer)
		- [Siapakah pengguna yang tidak pernah menggunakan diskon ketika membeli barang dan merupakan 5 top pembeli dengan transaksi terbanyak?](#siapakah-pengguna-yang-tidak-pernah-menggunakan-diskon-ketika-membeli-barang-dan-merupakan-5-top-pembeli-dengan-transaksi-terbanyak)
	- [Big Frequent Buyer 2020](#big-frequent-buyer-2020)
		- [Siapakah pengguna yang bertransaksi setidaknya 1 kali setiap bulan di tahun 2020 dengan rata-rata total amount per transaksi lebih dari 1 Juta](#siapakah-pengguna-yang-bertransaksi-setidaknya-1-kali-setiap-bulan-di-tahun-2020-dengan-rata-rata-total-amount-per-transaksi-lebih-dari-1-juta)
	- [Domain email dari penjual](#domain-email-dari-penjual)
		- [Apa saja domain email dari penjual?](#apa-saja-domain-email-dari-penjual)
	- [Top 5 Product Desember 2019](#top-5-product-desember-2019)
		- [Apa saja top 5 produk yang dibeli di bulan desember 2019 berdasarkan total quantity?](#apa-saja-top-5-produk-yang-dibeli-di-bulan-desember-2019-berdasarkan-total-quantity)


## Products

### Ada berapa kolom pada data produk?

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
select
	count(1)
from information_schema.columns 
where table_schema = 'public'
	and table_name = 'products'
```

</details>

</br>

> Result

| count |
|:-----:|
|4|

### Ada berapa baris pada data produk?

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
select
	count(1)
from products p 
```

</details>

</br>

> Result

| count |
|:-----:|
|1,145|


### Ada berapa jenis kategori produk

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
select
	count(1)
from products p 
```

</details>

</br>

> Result

| count |
|:-----:|
|12|

### Ada berapa variabel yang mempunyai nilai NULL / kosong

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
select
	sum(case when product_id is null then 1 else 0 end) as product_id_null_count,
	sum(case when desc_product is null then 1 else 0 end) as desc_product_null_count,
	sum(case when category is null then 1 else 0 end) as category_null_count,
	sum(case when base_price is null then 1 else 0 end) as base_price_null_count
from products p 
```

</details>

</br>

> Result

| product_id_null_count | desc_product_null_count | category_null_count | base_price_null_count |
|:-----:|:-----:|:-----:|:-----:|
|0|0|0|0|

Tidak ada variabel yang mempunyai nilai NULL / kosong

## Orders

### Ada berapa kolom / variabel pada data order?

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
select
	count(1)
from information_schema.columns 
where table_schema = 'public'
	and table_name = 'orders'
```

</details>

</br>

> Result

| count |
|:-----:|
|10|

### Ada berapa baris pada data order?

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
select
	count(1)
from orders o 
```

</details>

</br>

> Result

| count |
|:-----:|
|74,874|


### Ada berapa variabel yang mempunyai nilai NULL / kosong

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
DO $$ 
DECLARE 
    r RECORD;
    v_sql TEXT;
    v_count INTEGER;
    table_schema_ TEXT := 'public';
    table_name_ TEXT := 'orders';
BEGIN
    FOR r IN (SELECT column_name 
              FROM information_schema.columns 
              WHERE table_schema = table_schema_
              AND table_name = table_name_) 
    LOOP
        v_sql := 'SELECT COUNT(*) FROM ' || table_name_ || ' WHERE ' || r.column_name || ' IS NULL;';
        EXECUTE v_sql INTO v_count;
        IF v_count > 0 THEN
            RAISE NOTICE 'Column ''%'' contains NULL values', r.column_name;
        END IF;
    END LOOP;
END $$;
```

</details>

</br>

> Result

```log
Column 'paid_at' contains NULL values
Column 'delivery_at' contains NULL values
Columns containing NULL values: 2
```

### Ada berapa variabel yang berisi data amount (rupiah)

> Query

<details>

<summary> <i>Lihat query</i> </summary>

</details>

</br>

> Result

Variabel yang berisi data amount (rupiah): 3 (`subtotal`, `discount`, `total`)

### Ada berapa variabel yang berisi data tanggal

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
select
	count(1)
from information_schema.columns 
where table_schema = 'public'
	and table_name = 'orders'
    and data_type = 'date'
```

</details>

</br>

> Result

| count |
|:-----:|
|3|

## Transaksi Bulanan

### Ada berapa transaksi setiap bulan?

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
select
	date_trunc('month', created_at) as date_trunc_month,
	to_char(created_at, 'Mon YYYY') as month_year,
    count(1)
from orders o
group by 1, 2
order by 1
```

</details>

</br>

> Result

|date_trunc_month      |month_year|count|
|----------------------|----------|-----|
|2019-01-01 00:00:00+07|Jan 2019  |117  |
|2019-02-01 00:00:00+07|Feb 2019  |354  |
|2019-03-01 00:00:00+07|Mar 2019  |668  |
|2019-04-01 00:00:00+07|Apr 2019  |984  |
|2019-05-01 00:00:00+07|May 2019  |1462 |
|2019-06-01 00:00:00+07|Jun 2019  |1913 |
|2019-07-01 00:00:00+07|Jul 2019  |2667 |
|2019-08-01 00:00:00+07|Aug 2019  |3274 |
|2019-09-01 00:00:00+07|Sep 2019  |4327 |
|2019-10-01 00:00:00+07|Oct 2019  |5577 |
|2019-11-01 00:00:00+07|Nov 2019  |7162 |
|2019-12-01 00:00:00+07|Dec 2019  |10131|
|2020-01-01 00:00:00+07|Jan 2020  |5062 |
|2020-02-01 00:00:00+07|Feb 2020  |5872 |
|2020-03-01 00:00:00+07|Mar 2020  |7323 |
|2020-04-01 00:00:00+07|Apr 2020  |7955 |
|2020-05-01 00:00:00+07|May 2020  |10026|

## Status Transaksi

### Ada berapa transaksi yang tidak dibayar?

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
select 
	count(1)
from orders o 
where paid_at is null
```

</details>

</br>

> Result

| count |
|:-----:|
|5,046|

### Ada berapa transaksi yang sudah dibayar tapi tidak dikirim?

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
select 
	count(1)
from orders o 
where paid_at is not null
	and delivery_at is null 
```

</details>

</br>

> Result

| count |
|:-----:|
|4,744|

### Ada berapa transaksi yang tidak dikrim, baik sudah dibayar maupun belum?

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
select 
	count(1)
from orders o 
where delivery_at is null 
```

</details>

</br>

> Result

| count |
|:-----:|
|9,790|

### Ada berapa transaksi yang dikirim pada hari yang sama dengan tangal dibayar?

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
select 
	count(1)
from orders o 
where delivery_at = paid_at  
```

</details>

</br>

> Result

| count |
|:-----:|
|4,588|

## Pengguna bertransaksi

### Ada berapa total pengguna?

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
select 
	count(1)
from users u
```

</details>

</br>

> Result

| count |
|:-----:|
|17,936|

### Ada berapa total pengguna yang pernah bertransaksi sebagai pembeli?

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
select 
	count(distinct buyer_id)
from orders o 
```

</details>

</br>

> Result

| count |
|:-----:|
|17,877|

### Ada berapa total pengguna yang pernah bertransaksi sebagai penjual?

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
select 
	count(distinct seller_id)
from orders o 
```

</details>

</br>

> Result

| count |
|:-----:|
|69|

### Ada berapa total pengguna yang pernah bertransaksi sebagai pembeli dan pernah sebagai penjual?

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
with user_exp as (
	select 
		u.user_id,
		count(distinct o_buy.buyer_id) buy_exp,
		count(distinct o_sell.seller_id) sell_exp
	from users u 
	left join orders o_buy
		on o_buy.buyer_id = u.user_id 
	left join orders o_sell
		on o_sell.seller_id = u.user_id 
	group by 1
)

select 
	count(1)
from user_exp
where buy_exp > 0
	and sell_exp > 0
```

</details>

</br>

> Result

| count |
|:-----:|
|69|

### Ada berapa total pengguna yang tidak pernah bertransaksi sebagai pembeli maupun penjual?

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
with user_exp as (
	select 
		u.user_id,
		count(distinct o_buy.buyer_id) buy_exp,
		count(distinct o_sell.seller_id) sell_exp
	from users u 
	left join orders o_buy
		on o_buy.buyer_id = u.user_id 
	left join orders o_sell
		on o_sell.seller_id = u.user_id 
	group by 1
)

select 
	count(1)
from user_exp
where buy_exp = 0
	and sell_exp = 0
```

</details>

</br>

> Result

| count |
|:-----:|
|59|

## Top Buyer all time

### Siapakah 5 top pembeli dengan dengan total pembelian terbesar (berdasarkan total harga barang setelah diskon)?

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
select
	u.user_id,
	u.nama_user,
	sum(o.total) as total_revenue
from orders o 
left join users u 
	on o.buyer_id = u.user_id 
group by 1, 2
order by 3 desc
limit 5
```

</details>

</br>

> Result

|user_id|nama_user|total_revenue|
|-------|---------|-------------|
|14411|Jaga Puspasari|54102250|
|11140|R.A. Yulia Padmasari, S.I.Kom|52743200|
|15915|Sutan Agus Ardianto, S.Kom|49141800|
|2908|Septi Melani, S.Ked|49033000|
|10355|Kartika Habibi|48868000|

## Frequent Buyer

### Siapakah pengguna yang tidak pernah menggunakan diskon ketika membeli barang dan merupakan 5 top pembeli dengan transaksi terbanyak?

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
with top_5_frequent_buyer as (
	select
		u.user_id,
		u.nama_user,
		count(1) as transactions_count,
		sum(o.discount) as total_discount_usage
	from orders o 
	left join users u 
		on o.buyer_id = u.user_id 
	group by 1, 2
	order by 3 desc
	limit 5
)

select
	*
from top_5_frequent_buyer
where total_discount_usage = 0
```

</details>

</br>

> Result

|user_id|nama_user|transactions_count|total_discount_usage|
|-------|---------|------------------|--------------------|
|12476|Yessi Wibisono|13|0|
|10977|Drs. Pandu Mansur, M.TI.|12|0|
|12577|Umay Latupono|12|0|

## Big Frequent Buyer 2020

### Siapakah pengguna yang bertransaksi setidaknya 1 kali setiap bulan di tahun 2020 dengan rata-rata total amount per transaksi lebih dari 1 Juta

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
select
	u.user_id,
	u.nama_user,
	u.email
from orders o 
left join users u 
	on o.buyer_id = u.user_id 
where date_part('year', o.created_at) = 2020
group by 1, 2, 3
having count(distinct date_trunc('month', o.created_at)) = 12
	and avg(o.total) > 1e6
```

</details>

</br>

> Result

_None_

## Domain email dari penjual

### Apa saja domain email dari penjual?

*domain adalah nama unik setelah tanda @, biasanya menggambarkan nama organisasi dan imbuhan internet standar (seperti .com, .co.id dan lainnya)

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
select distinct
	split_part(u.email, '@', 2) as email_domain 
from orders o 
join users u 
	on o.seller_id = u.user_id
```

</details>

</br>

> Result

|email_domain|
|------------|
|gmail.com|
|ud.go.id|
|pd.sch.id|
|pd.ac.id|
|hotmail.com|
|perum.mil|
|perum.int|
|pd.mil.id|
|pt.net.id|
|cv.co.id|
|perum.edu|
|pd.org|
|pd.my.id|
|pd.web.id|
|pd.go.id|
|pd.net|
|ud.id|
|ud.net.id|
|cv.web.id|
|yahoo.com|
|ud.net|
|pt.mil.id|
|ud.edu|
|pt.gov|
|cv.mil|
|perum.mil.id|
|cv.id|

## Top 5 Product Desember 2019

### Apa saja top 5 produk yang dibeli di bulan desember 2019 berdasarkan total quantity?

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
select
	p.desc_product,
	sum(od.quantity) as total_quantity 
from orders o 
left join order_details od 
	on o.order_id = od.order_id 
left join products p 
	on od.product_id = p.product_id 
where date_trunc('month', o.created_at) = '2019-12-01'
group by 1
order by 2 desc 
limit 5
```

</details>

</br>

> Result

|desc_product|total_quantity|
|------------|--------------|
|QUEEN CEFA BRACELET LEATHER|5100|
|SHEW SKIRTS BREE|2846|
|ANNA FAITH LEGGING GLOSSY|2646|
|Cdr Vitamin C 10'S|2484|
|RIDER CELANA DEWASA SPANDEX ANTI BAKTERI R325BW|2372|