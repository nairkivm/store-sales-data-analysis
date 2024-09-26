# Chapter 002

## Products

### Ada berapa kolom pada data produk?

> Query

```postgresql
select
	count(1)
from information_schema.columns 
where table_schema = 'public'
	and table_name = 'products'
```

> Result

| count |
|:-----:|
|4|

### Ada berapa baris pada data produk?

> Query

```postgresql
select
	count(1)
from products p 
```

> Result

| count |
|:-----:|
|1,145|


### Ada berapa jenis kategori produk

> Query

```postgresql
select
	count(1)
from products p 
```

> Result

| count |
|:-----:|
|12|

### Ada berapa variabel yang mempunyai nilai NULL / kosong

> Query

```postgresql
select
	sum(case when product_id is null then 1 else 0 end) as product_id_null_count,
	sum(case when desc_product is null then 1 else 0 end) as desc_product_null_count,
	sum(case when category is null then 1 else 0 end) as category_null_count,
	sum(case when base_price is null then 1 else 0 end) as base_price_null_count
from products p 
```

> Result

| product_id_null_count | desc_product_null_count | category_null_count | base_price_null_count |
|:-----:|:-----:|:-----:|:-----:|
|0|0|0|0|

Tidak ada variabel yang mempunyai nilai NULL / kosong

## Orders

### Ada berapa kolom / variabel pada data order?

> Query

```postgresql
select
	count(1)
from information_schema.columns 
where table_schema = 'public'
	and table_name = 'orders'
```

> Result

| count |
|:-----:|
|10|

### Ada berapa baris pada data order?

> Query

```postgresql
select
	count(1)
from orders o 
```

> Result

| count |
|:-----:|
|74,874|


### Ada berapa variabel yang mempunyai nilai NULL / kosong

> Query

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

> Result

```log
Column 'paid_at' contains NULL values
Column 'delivery_at' contains NULL values
Columns containing NULL values: 2
```

### Ada berapa variabel yang berisi data amount (rupiah)

> Result

Variabel yang berisi data amount (rupiah): 3 (`subtotal`, `discount`, `total`)

### Ada berapa variabel yang berisi data tanggal

> Query

```postgresql
select
	count(1)
from information_schema.columns 
where table_schema = 'public'
	and table_name = 'orders'
    and data_type = 'date'
```

> Result

| count |
|:-----:|
|3|

## Transaksi Bulanan

### Ada berapa transaksi setiap bulan?

> Query

```postgresql
select
	date_trunc('month', created_at) as date_trunc_month,
	to_char(created_at, 'Mon YYYY') as month_year,
    count(1)
from orders o
group by 1, 2
order by 1
```

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

```postgresql
select 
	count(1)
from orders o 
where paid_at is null
```

> Result

| count |
|:-----:|
|5,046|

### Ada berapa transaksi yang sudah dibayar tapi tidak dikirim?

> Query

```postgresql
select 
	count(1)
from orders o 
where paid_at is not null
	and delivery_at is null 
```

> Result

| count |
|:-----:|
|4,744|

### Ada berapa transaksi yang tidak dikrim, baik sudah dibayar maupun belum?

> Query

```postgresql
select 
	count(1)
from orders o 
where delivery_at is null 
```

> Result

| count |
|:-----:|
|9,790|

### Ada berapa transaksi yang dikirim pada hari yang sama dengan tangal dibayar?

> Query

```postgresql
select 
	count(1)
from orders o 
where delivery_at = paid_at  
```

> Result

| count |
|:-----:|
|4,588|

## Pengguna bertransaksi

### Ada berapa total pengguna?

> Query

```postgresql
select 
	count(1)
from users u
```

> Result

| count |
|:-----:|
|17,936|

### Ada berapa total pengguna yang pernah bertransaksi sebagai pembeli?

> Query

```postgresql
select 
	count(distinct buyer_id)
from orders o 
```

> Result

| count |
|:-----:|
|17,877|

### Ada berapa total pengguna yang pernah bertransaksi sebagai pembeli?

> Query

```postgresql
select 
	count(distinct buyer_id)
from orders o 
```

> Result

| count |
|:-----:|
|17,877|