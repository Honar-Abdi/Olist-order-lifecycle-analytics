/*
KPI summary table.

Yksi rivi koko analysoidulle datasetille.

Tämä taulu kokoaa tärkeimmät liiketoimintamittarit:
- Tilaukset
- Revenue
- Keskimääräinen tilauksen arvo
- Toimitusajat
- Asiakkaiden määrä
- Repeat rate
- Myyjien määrä
- Tuotteiden määrä
*/

create or replace table kpi_order_lifecycle_summary as

with order_metrics as (
    select
        count(*) as total_delivered_orders,
        sum(order_gross_value) as total_gross_revenue,
        sum(payment_value_total) as total_paid_revenue,
        avg(order_gross_value) as avg_gross_order_value,
        avg(payment_value_total) as avg_paid_order_value,
        avg(delivery_days) as avg_delivery_days,
        avg(approval_days) as avg_approval_days
    from orders_fact
),

customer_metrics as (
    select
        count(*) as total_customers,
        sum(case when total_orders > 1 then 1 else 0 end) as repeat_customers
    from dim_customers_unique
),

seller_metrics as (
    select
        count(*) as total_sellers
    from dim_sellers
),

product_metrics as (
    select
        count(*) as total_products
    from dim_products
)

select
    o.total_delivered_orders,
    o.total_gross_revenue,
    o.total_paid_revenue,
    o.avg_gross_order_value,
    o.avg_paid_order_value,
    o.avg_delivery_days,
    o.avg_approval_days,

    c.total_customers,
    c.repeat_customers,
    case
        when c.total_customers = 0 then null
        else cast(c.repeat_customers as double) / c.total_customers
    end as repeat_customer_rate,

    s.total_sellers,
    p.total_products

from order_metrics o
cross join customer_metrics c
cross join seller_metrics s
cross join product_metrics p
;