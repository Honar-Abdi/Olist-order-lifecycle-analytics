/*
Sanity check dim_sellers.

Tarkistaa:
- grain (1 rivi per seller_id)
- puuttuvat seller_id:t
- peruslukujen järkevyyttä
*/

select
    count(*) as dim_rows,
    count(distinct seller_id) as distinct_seller_ids,
    sum(case when seller_id is null then 1 else 0 end) as null_seller_ids,
    sum(case when total_orders <= 0 then 1 else 0 end) as sellers_with_non_positive_orders,
    max(total_orders) as max_orders_per_seller,
    max(total_item_rows) as max_item_rows_per_seller
from dim_sellers;