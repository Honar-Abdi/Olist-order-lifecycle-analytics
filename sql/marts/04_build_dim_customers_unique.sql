/*
Customer dimension customer_unique_id -tasolle.

Tavoite:
- Yksi rivi per customer_unique_id
- Kokoaa saman henkilön tilaukset yhteen
- Mahdollistaa retention- ja LTV-tyyppiset analyysit

Lähteet:
- orders_fact
- customers
*/

create or replace table dim_customers_unique as

with orders_enriched as (
    select
        f.*,
        c.customer_unique_id
    from orders_fact f
    join customers c
      on f.customer_id = c.customer_id
),

agg as (
    select
        customer_unique_id,
        min(cast(order_purchase_timestamp as date)) as first_order_date,
        max(cast(order_purchase_timestamp as date)) as last_order_date,
        count(*) as total_orders,
        sum(order_gross_value) as gross_revenue_total,
        sum(payment_value_total) as paid_revenue_total,
        avg(order_gross_value) as gross_aov,
        avg(payment_value_total) as paid_aov,
        avg(delivery_days) as avg_delivery_days,
        avg(approval_days) as avg_approval_days,
        sum(case when payment_value_total is null then 1 else 0 end) as orders_missing_payment
    from orders_enriched
    group by customer_unique_id
)

select
    customer_unique_id,
    first_order_date,
    last_order_date,
    total_orders,
    gross_revenue_total,
    paid_revenue_total,
    gross_aov,
    paid_aov,
    avg_delivery_days,
    avg_approval_days,
    orders_missing_payment,
    case
        when paid_revenue_total is null then null
        when gross_revenue_total = 0 then null
        else paid_revenue_total / gross_revenue_total
    end as paid_to_gross_ratio
from agg
;