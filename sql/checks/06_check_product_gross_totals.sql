/*
Consistency check: product gross totals.

Tarkistaa, että dim_products-taulun tuotekohtainen gross-summa
täsmää order_items-taulusta lasketun summan kanssa delivered-tilauksissa.
*/

with delivered_items as (
    select
        sum(oi.price + oi.freight_value) as items_gross_total
    from order_items oi
    join orders_fact f
      on oi.order_id = f.order_id
),

products_dim as (
    select
        sum(product_gross_value_total) as products_gross_total
    from dim_products
)

select
    round(d.items_gross_total, 2) as items_gross_total_2dp,
    round(p.products_gross_total, 2) as products_gross_total_2dp,
    round(abs(d.items_gross_total - p.products_gross_total), 6) as abs_diff,
    case
        when abs(d.items_gross_total - p.products_gross_total) <= 0.01 then true
        else false
    end as is_within_tolerance
from delivered_items d
cross join products_dim p
;