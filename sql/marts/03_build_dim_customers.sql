/*
Customer-dimension.

Tämä taulu kokoaa customer_id -tason mittarit orders_fact-taulusta.
Yksi rivi per customer_id.

Mukana pidetään sekä gross- että paid-revenue, jotta revenue-määritelmä
voidaan valita myöhemmin mitattuun dataan nojaten.
*/

create or replace table dim_customers as

with base as (
    select
        customer_id,
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
    from orders_fact
    group by customer_id
)

select
    customer_id,
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

    /* paid_revenue_total voi olla null jos kaikki customerin tilaukset puuttuvat paymentista */
    case
        when paid_revenue_total is null then null
        when gross_revenue_total = 0 then null
        else paid_revenue_total / gross_revenue_total
    end as paid_to_gross_ratio

from base
;