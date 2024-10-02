# Chapter 004

- [Chapter 004](#chapter-004)
	- [Mencari pembeli high value](#mencari-pembeli-high-value)
	- [Mencari Dropshipper](#mencari-dropshipper)
	- [Mencari Reseller Offline](#mencari-reseller-offline)
	- [Pembeli sekaligus penjual](#pembeli-sekaligus-penjual)
	- [Lama transaksi dibayar](#lama-transaksi-dibayar)

## Mencari pembeli high value

> Query

<details>

<summary> <i>Lihat query</i> </summary>

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

</details>

</br>

> Result

|nama_pembeli|jumlah_transaksi|total_nilai_transaksi|min_nilai_transaksi|
|------------|----------------|---------------------|-------------------|
|R. Tirta Nasyidah|6|25117800|2308800|
|Martani Laksmiwati|6|24858000|2144000|

## Mencari Dropshipper

> Query

<details>

<summary> <i>Lihat query</i> </summary>

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

</details>

</br>

> Result

|nama_pembeli|jumlah_transaksi|distinct_kodepos|total_nilai_transaksi|avg_nilai_transaksi|
|------------|----------------|----------------|---------------------|-------------------|
|Anastasia Gunarto|10|10|7899000|789900.000000000000|
|R.M. Setya Waskita|10|10|30595000|3059500.000000000000|

## Mencari Reseller Offline

> Query

<details>

<summary> <i>Lihat query</i> </summary>

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

</details>

</br>

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

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
-- Cari penjual yang juga pernah bertransaksi sebagai pembeli minimal 7 kali.

select
	nama_user as nama_pengguna,
	jumlah_transaksi_beli,
	jumlah_transaksi_jual
from users
inner join (select buyer_id, count(1) as jumlah_transaksi_beli from orders group by 1) as buyer on buyer_id = user_id
inner join (select seller_id, count(1) as jumlah_transaksi_jual from orders group by 1) as seller on seller_id = user_id
where jumlah_transaksi_beli >= 7
order by 1
```

</details>

</br>

> Result

|nama_pengguna|jumlah_transaksi_beli|jumlah_transaksi_jual|
|-------------|---------------------|---------------------|
|Bahuwirya Haryanto|8|1032|
|Dr. Adika Kusmawati, S.Pt|7|1098|
|Gandi Rahmawati|8|1078|
|Jaka Hastuti|7|1094|
|R.M. Prayogo Damanik, S.Pt|8|1044|

## Lama transaksi dibayar

> Query

<details>

<summary> <i>Lihat query</i> </summary>

```postgresql
-- Hitung rata-rata lama waktu dari transaksi dibuat sampai dibayar, dikelompokkan per bulan.
select to_char(created_at, 'YYYYMM') as tahun_bulan, count(1) as jumlah_transaksi,
avg(extract('day' from age(paid_at, created_at))) as avg_lama_dibayar,
min(extract('day' from age(paid_at, created_at))) min_lama_dibayar,
max(extract('day' from age(paid_at, created_at))) max_lama_dibayar
from orders
where paid_at is not null
group by 1
order by 1
```

</details>

</br>


> Result

|tahun_bulan|jumlah_transaksi|avg_lama_dibayar|min_lama_dibayar|max_lama_dibayar|
|-----------|----------------|----------------|----------------|----------------|
|201901|107|7.0467289719626168|1|14|
|201902|326|7.5398773006134969|1|14|
|201903|628|7.4601910828025478|1|14|
|201904|914|7.2910284463894967|1|14|
|201905|1357|7.3691967575534267|1|14|
|201906|1798|7.5728587319243604|1|14|
|201907|2504|7.4548722044728435|1|14|
|201908|3050|7.6216393442622951|1|14|
|201909|4037|7.5021055239038890|1|14|
|201910|5170|7.4705996131528046|1|14|
|201911|6683|7.5187789914708963|1|14|
|201912|9451|7.4980425351814623|1|14|
|202001|4718|7.4152183128444256|1|14|
|202002|5501|7.5091801490638066|1|14|
|202003|6814|7.4674200176108013|1|14|
|202004|7443|7.4792422410318420|1|14|
|202005|9327|7.4549158357456846|1|14|