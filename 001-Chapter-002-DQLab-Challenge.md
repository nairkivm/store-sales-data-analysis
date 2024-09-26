# Products

## Ada 4 kolom pada data produk?

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

## Ada 1,145 baris pada data produk?

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
