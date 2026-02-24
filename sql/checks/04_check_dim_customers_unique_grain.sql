select
    count(*) as dim_rows,
    count(distinct customer_unique_id) as distinct_ids,
    sum(case when total_orders > 1 then 1 else 0 end) as customers_with_repeat_orders,
    max(total_orders) as max_orders_per_customer
from dim_customers_unique;