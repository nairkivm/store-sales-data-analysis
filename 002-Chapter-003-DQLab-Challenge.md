# Chapter 003

- [Chapter 003](#chapter-003)
	- [10 Transaksi terbesar user 10977](#10-transaksi-terbesar-user-10977)
	- [Transaksi per bulan (5 bulan terakhir)](#transaksi-per-bulan-5-bulan-terakhir)
	- [Pengguna dengan rata-rata transaksi terbesar di Januari 2020 (min. 2x transaksi)](#pengguna-dengan-rata-rata-transaksi-terbesar-di-januari-2020-min-2x-transaksi)
	- [Transaksi besar di Desember 2019 (min. 20 jt)](#transaksi-besar-di-desember-2019-min-20-jt)
	- [Kategori Produk Terlaris di 2020](#kategori-produk-terlaris-di-2020)

## 10 Transaksi terbesar user 10977

> Query

```postgresql
select seller_id, buyer_id, total as nilai_transaksi, created_at as tanggal_transaksi
from orders
where buyer_id = 10977
order by 3 desc
limit 10
```

> Result

|seller_id|buyer_id|nilai_transaksi|tanggal_transaksi|
|---------|--------|---------------|-----------------|
|62|10977|7458000|2020-03-14|
|5|10977|5249000|2020-05-22|
|66|10977|2432000|2019-06-09|
|62|10977|1172000|2019-11-03|
|60|10977|780000|2019-11-24|
|68|10977|693000|2019-09-24|
|39|10977|363000|2019-07-24|
|12|10977|239000|2019-07-14|
|10|10977|126000|2019-10-13|
|67|10977|68000|2019-02-04|

## Transaksi per bulan (5 bulan terakhir)

> Query

```postgresql
select to_char(created_at, 'YYYYMM') as tahun_bulan, count(1) as jumlah_transaksi, sum(total) as total_nilai_transaksi
from orders
group by 1
order by 1 desc 
limit 5
```

> Result

|tahun_bulan|jumlah_transaksi|total_nilai_transaksi|
|-----------|----------------|---------------------|
|202005|10026|31288823000|
|202004|7955|21219233750|
|202003|7323|17189378400|
|202002|5872|12665113550|
|202001|5062|9941756800|


## Pengguna dengan rata-rata transaksi terbesar di Januari 2020 (min. 2x transaksi)

> Query

```postgresql
select buyer_id, count(1) as jumlah_transaksi, avg(total) as avg_nilai_transaksi
from orders
where created_at>='2020-01-01' and created_at<'2020-02-01'
group by 1
having count(1)>= 2
order by 3 desc
limit 10
```

> Result

|buyer_id|jumlah_transaksi|avg_nilai_transaksi|
|--------|----------------|-------------------|
|11140|2|11719500.000000000000|
|7905|2|10440000.000000000000|
|12935|2|8556500.000000000000|
|12916|2|7747000.000000000000|
|17282|2|6797500.000000000000|
|1418|2|6741000.000000000000|
|5418|2|5336000.000000000000|
|11906|2|5309500.000000000000|
|12533|2|5218500.000000000000|
|841|2|5052500.000000000000|


## Transaksi besar di Desember 2019 (min. 20 jt)

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