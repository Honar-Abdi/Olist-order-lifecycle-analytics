/*
Product dimension.

Tämä taulu kokoaa tuotekohtaiset mittarit delivered-tilauksista.
Yksi rivi per product_id.

Tuoteluokka tuodaan mukaan products-taulusta ja käännöstaulusta.
Revenue lasketaan tuotteen item-riveistä (price + freight).
*/

create or replace table dim_products as

with delivered_orders as (
    select
        order_id,
        order_purchase_timestamp,
        delivery_days,
        approval_days
    from orders_fact
),

delivered_items as (
    select
        oi.product_id,
        oi.order_id,
        oi.seller_id,
        oi.price,
        oi.freight_value,
        d.order_purchase_timestamp,
        d.delivery_days,
        d.approval_days
    from order_items oi
    join delivered_orders d
      on oi.order_id = d.order_id
),

product_enriched as (
    select
        di.*,
        p.product_category_name,
        t.product_category_name_english
    from delivered_items di
    left join products p
      on di.product_id = p.product_id
    left join product_category_name_translation t
      on p.product_category_name = t.product_category_name
),

agg as (
    select
        product_id,

        count(distinct order_id) as total_orders,
        count(*) as total_item_rows,
        count(distinct seller_id) as distinct_sellers,

        min(cast(order_purchase_timestamp as date)) as first_order_date,
        max(cast(order_purchase_timestamp as date)) as last_order_date,

        sum(price) as items_price_total_product,
        sum(freight_value) as freight_total_product,
        sum(price + freight_value) as product_gross_value_total,

        avg(price) as avg_item_price,
        avg(freight_value) as avg_item_freight,

        avg(delivery_days) as avg_delivery_days,
        avg(approval_days) as avg_approval_days,

        any_value(product_category_name) as product_category_name,
        any_value(product_category_name_english) as product_category_name_english
    from product_enriched
    group by product_id
)

select
    product_id,
    product_category_name,
    product_category_name_english,

    total_orders,
    total_item_rows,
    distinct_sellers,

    first_order_date,
    last_order_date,

    items_price_total_product,
    freight_total_product,
    product_gross_value_total,

    avg_item_price,
    avg_item_freight,

    avg_delivery_days,
    avg_approval_days
from agg
;