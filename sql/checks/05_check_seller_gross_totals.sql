/*
Consistency check: seller gross totals.

Tarkistaa, että dim_sellers-taulun myyjäkohtainen gross-summa
täsmää order_items-taulusta lasketun summan kanssa delivered-tilauksissa.

Erot voivat olla hyvin pieniä pyöristyksen vuoksi.
*/

with delivered_items as (
    select
        sum(oi.price + oi.freight_value) as items_gross_total
    from order_items oi
    join orders_fact f
      on oi.order_id = f.order_id
),

sellers_dim as (
    select
        sum(seller_gross_value_total) as sellers_gross_total
    from dim_sellers
)

select
    round(d.items_gross_total, 2) as items_gross_total_2dp,
    round(s.sellers_gross_total, 2) as sellers_gross_total_2dp,
    round(abs(d.items_gross_total - s.sellers_gross_total), 6) as abs_diff,
    case
        when abs(d.items_gross_total - s.sellers_gross_total) <= 0.01 then true
        else false
    end as is_within_tolerance
from delivered_items d
cross join sellers_dim s
;