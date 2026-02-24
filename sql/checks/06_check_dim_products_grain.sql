/*
Sanity check dim_products.

Tarkistaa:
- grain (1 rivi per product_id)
- peruslukujen järkevyyttä
*/

select
    count(*) as dim_rows,
    count(distinct product_id) as distinct_product_ids,
    sum(case when product_id is null then 1 else 0 end) as null_product_ids,
    sum(case when total_orders <= 0 then 1 else 0 end) as products_with_non_positive_orders,
    max(total_orders) as max_orders_per_product,
    max(total_item_rows) as max_item_rows_per_product
from dim_products;