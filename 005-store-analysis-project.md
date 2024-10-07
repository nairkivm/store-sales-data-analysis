# Store Analysis Project

## Data Prepration

### Add rating column into orders table

<details>

<summary> <i>Lihat query</i> </summary>

```sql
-- Add 'rating' column
alter table orders
add column rating int;

-- Fill `rating` column with random ratings value in range 0-5
-- and add some right-skewness (with factor of 0.4) to the data distribution
update orders
set rating = floor((random() ^ 0.4) * 6)::int;

-- Move some '3-rate' values to the `0-rate` to make the data more 'realistic'
update orders 
set rating = 0
where rating = 3 and random() < 0.5;
```

</details> <br>

### Add latitude and longitude columns into users table

