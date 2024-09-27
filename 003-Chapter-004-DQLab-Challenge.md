# Chapter 004

## Mencari pembeli high value

> Query

```postgresql
-- Buatlah SQL query untuk mencari pembeli yang sudah bertransaksi lebih dari 5 kali, 
-- dan setiap transaksi lebih dari 2,000,000.

-- Tampilkan nama_pembeli, jumlah_transaksi, total_nilai_transaksi, min_nilai_transaksi. 
-- Urutkan dari total_nilai_transaksi terbesar!

select 
	nama_user as nama_pembeli,
	count(1) as jumlah_transaksi,
	sum(total) as total_nilai_transaksi,
	min(total) as min_nilai_transaksi
from orders 
join users 
	on buyer_id = user_id
group by buyer_id, nama_user
having count(1) > 5
	and min(total) > 2000000
order by 3 desc
```

> Result

|nama_pembeli|jumlah_transaksi|total_nilai_transaksi|min_nilai_transaksi|
|------------|----------------|---------------------|-------------------|
|R. Tirta Nasyidah|6|25117800|2308800|
|Martani Laksmiwati|6|24858000|2144000|

## Mencari Dropshipper

> Query

```postgresql
-- Dropshipper: pembeli yang membeli barang akan tetapi dikirim ke orang lain. 
-- Ciri-cirinya yakni transaksinya banyak, dengan alamat yang berbeda-beda.

-- Cari pembeli dengan 10 kali transaksi atau lebih yang alamat pengiriman 
-- transaksi selalu berbeda setiap transaksi.

-- Tampilkan nama_pembeli, jumlah_transaksi, distinct_kodepos, 
-- total_nilai_transaksi, avg_nilai_transaksi. Urutkan dari jumlah transaksi terbesar

select
	nama_user as nama_pembeli,
	count(1) as jumlah_transaksi,
	count(distinct orders.kodepos) as distinct_kodepos,
	sum(total) as total_nilai_transaksi,
	avg(total) as avg_nilai_transaksi
from orders
inner join users
	on user_id = buyer_id
group by user_id, nama_user
having count(distinct orders.kodepos) >= 10
	and count(1) = count(distinct orders.kodepos)
order by count(1) desc
```

> Result

|nama_pembeli|jumlah_transaksi|distinct_kodepos|total_nilai_transaksi|avg_nilai_transaksi|
|------------|----------------|----------------|---------------------|-------------------|
|Anastasia Gunarto|10|10|7899000|789900.000000000000|
|R.M. Setya Waskita|10|10|30595000|3059500.000000000000|

## Mencari Reseller Offline

> Query

```postgresql
-- Reseller offline: pembeli yang sering sekali membeli barang dan 
-- seringnya dikirimkan ke alamat yang sama. Pembelian juga dengan
-- quantity produk yang banyak. Sehingga kemungkinan barang ini 
-- akan dijual lagi.

-- Jadi buatlah SQL query untuk mencari pembeli yang punya 8 atau 
-- lebih transaksi yang alamat pengiriman transaksi sama dengan 
-- alamat pengiriman utama, dan rata-rata total quantity per 
-- transaksi lebih dari 10.

-- Tampilkan nama_pembeli, jumlah_transaksi, total_nilai_transaksi, 
-- avg_nilai_transaksi, avg_quantity_per_transaksi. Urutkan dari 
-- total_nilai_transaksi yang paling besar

select
	nama_user as nama_pembeli,
	count(1) as jumlah_transaksi,
	sum(total) as total_nilai_transaksi,
	avg(total) as avg_nilai_transaksi,
	avg(total_quantity) as avg_quantity_per_transaksi
from orders
inner join users on user_id = buyer_id
inner join (select order_id, sum(quantity) as total_quantity from order_details group by 1) as summary_order using(order_id)
where orders.kodepos = users.kodepos
group by user_id, nama_user
having count(1)>=8 and avg(total_quantity)>10
order by 3 desc
```

> Result

|nama_pembeli|jumlah_transaksi|total_nilai_transaksi|avg_nilai_transaksi|avg_quantity_per_transaksi|
|------------|----------------|---------------------|-------------------|--------------------------|
|R. Prima Laksmiwati, S.Gz|8|17269000|2158625.000000000000|100.2500000000000000|
|Dt. Radika Winarno|8|16320000|2040000.000000000000|90.5000000000000000|
|Kayla Astuti|12|15953250|1329437.500000000000|80.6666666666666667|
|Ajiman Haryanti|8|15527000|1940875.000000000000|95.0000000000000000|
|Luhung Pradipta|8|11272000|1409000.000000000000|131.2500000000000000|

## Pembeli sekaligus penjual

> Query

```postgresql
select users.nama_user as nama_pembeli, orders.total as nilai_transaksi, orders.created_at as tanggal_transaksi
from orders
inner join users on buyer_id = user_id
where created_at>='2019-12-01' and created_at<'2020-01-01'
and total >= 2e7
order by 1
```

> Result

|nama_pembeli|nilai_transaksi|tanggal_transaksi|
|------------|---------------|-----------------|
|Diah Mahendra|21142000|2019-12-24|
|Dian Winarsih|22966000|2019-12-21|
|dr. Yulia Waskita|29930000|2019-12-28|
|drg. Kajen Siregar|27893500|2019-12-10|
|Drs. Ayu Lailasari|22300000|2019-12-09|
|Hendri Habibi|21815000|2019-12-19|
|Kartika Habibi|25760000|2019-12-22|
|Lasmanto Natsir|22845000|2019-12-27|
|R.A. Betania Suryono|20523000|2019-12-07|
|Syahrini Tarihoran|29631000|2019-12-05|
|Tgk. Hamima Sihombing, M.Kom.|29351400|2019-12-25|
|Tgk. Lidya Lazuardi, S.Pt|20447000|2019-12-16|

## Kategori Produk Terlaris di 2020

> Query

```postgresql
select category, sum(quantity) as total_quantity, sum(price) as total_price
from orders
inner join order_details using(order_id)
inner join products using(product_id)
where created_at>='2020-01-01'
and delivery_at is not null
group by 1
order by 2 desc
limit 5
```

> Result

|category|total_quantity|total_price|
|--------|--------------|-----------|
|Kebersihan Diri|1646452|2332980000|
|Fresh Food|519996|1382720000|
|Makanan Instan|487580|118202000|
|Bahan Makanan|376422|206334000|
|Minuman Ringan|369494|109364000|