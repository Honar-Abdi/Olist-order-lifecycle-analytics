/*
Canonical order-level fact table.

Tämä taulu toimii analyysin perustana. 
Yksi rivi per order.

Rajaukset:
- Vain delivered tilaukset
- Vain tilaukset joilla on vähintään yksi item-rivi

Tarkoitus on erottaa:
- raakadata (orders, order_items, order_payments)
- analyysitaso (orders_fact)
*/


create or replace table orders_fact as

with delivered_orders as (

    /* 
    Rajataan analyysiin vain toimitetut tilaukset.
    Tämä määrittelee mitä pidetään completed orderina.
    */

    select
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date
    from orders
    where order_status = 'delivered'

),

items_agg as (

    /*
    Aggregoidaan item-tason data order-tasolle.
    Tämä muodostaa tilauksen rahallisen arvon.
    */

    select
        order_id,
        count(*) as item_row_count,
        count(distinct product_id) as distinct_product_count,
        count(distinct seller_id) as distinct_seller_count,
        sum(price) as items_price_total,
        sum(freight_value) as freight_total,
        sum(price + freight_value) as order_gross_value
    from order_items
    group by order_id

),

payments_agg as (

    /*
    Maksut aggregoidaan order-tasolle.
    Näin voidaan verrata laskennallista order-arvoa ja maksettua summaa.
    */

    select
        order_id,
        count(*) as payment_row_count,
        sum(payment_value) as payment_value_total
    from order_payments
    group by order_id

),

reviews_agg as (

    /*
    Review data liitetään mukaan analyysia varten,
    mutta ei vaikuta orderin olemassaoloon.
    */

    select
        order_id,
        avg(review_score) as avg_review_score,
        count(*) as review_row_count
    from order_reviews
    group by order_id

)

select
    o.order_id,
    o.customer_id,
    o.order_status,

    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    i.item_row_count,
    i.distinct_product_count,
    i.distinct_seller_count,
    i.items_price_total,
    i.freight_total,
    i.order_gross_value,

    p.payment_row_count,
    p.payment_value_total,

    r.avg_review_score,
    r.review_row_count,

    /* Johdetut aikamittarit analyysia varten */

    date_diff('day', o.order_purchase_timestamp, o.order_delivered_customer_date) as delivery_days,
    date_diff('day', o.order_purchase_timestamp, o.order_approved_at) as approval_days

from delivered_orders o

/* 
Inner join varmistaa, että mukana on vain tilaukset,
joilla on item-rivejä.
*/

inner join items_agg i
    on o.order_id = i.order_id

left join payments_agg p
    on o.order_id = p.order_id

left join reviews_agg r
    on o.order_id = r.order_id
;
