/*
Seller dimension.

Tämä taulu kokoaa myyjäkohtaiset mittarit delivered-tilauksista.
Yksi rivi per seller_id.

Revenue lasketaan myyjän item-riveistä:
- items_price_total_seller
- freight_total_seller
- seller_gross_value_total = items + freight

Huomio:
Payment-tietoa ei jaeta myyjille tässä vaiheessa, koska se vaatisi
erillisen allokointisäännön.
*/

create or replace table dim_sellers as

with delivered_orders as (
    select
        order_id,
        order_purchase_timestamp,
        order_delivered_customer_date,
        delivery_days,
        approval_days
    from orders_fact
),

seller_order_items as (
    /*
    Rajataan order_items delivered-tilauksiin ja tuodaan seller_id mukaan.
    Tämä muodostaa myyjän item-tason faktat.
    */
    select
        oi.seller_id,
        oi.order_id,
        oi.product_id,
        oi.price,
        oi.freight_value,
        d.order_purchase_timestamp,
        d.order_delivered_customer_date,
        d.delivery_days,
        d.approval_days
    from order_items oi
    join delivered_orders d
      on oi.order_id = d.order_id
),

seller_agg as (
    select
        seller_id,

        count(distinct order_id) as total_orders,
        count(*) as total_item_rows,

        count(distinct product_id) as distinct_products_sold,

        min(cast(order_purchase_timestamp as date)) as first_order_date,
        max(cast(order_purchase_timestamp as date)) as last_order_date,

        sum(price) as items_price_total_seller,
        sum(freight_value) as freight_total_seller,
        sum(price + freight_value) as seller_gross_value_total,

        avg(delivery_days) as avg_delivery_days,
        avg(approval_days) as avg_approval_days
    from seller_order_items
    group by seller_id
)

select
    a.seller_id,

    s.seller_zip_code_prefix,
    s.seller_city,
    s.seller_state,

    a.total_orders,
    a.total_item_rows,
    a.distinct_products_sold,

    a.first_order_date,
    a.last_order_date,

    a.items_price_total_seller,
    a.freight_total_seller,
    a.seller_gross_value_total,

    a.avg_delivery_days,
    a.avg_approval_days

from seller_agg a
left join sellers s
  on a.seller_id = s.seller_id
;