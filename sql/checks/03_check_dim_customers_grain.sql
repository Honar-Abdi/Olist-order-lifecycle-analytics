select
    count(*) as dim_rows,
    count(distinct customer_id) as distinct_customer_ids
from dim_customers;