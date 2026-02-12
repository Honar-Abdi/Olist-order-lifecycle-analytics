/*
Tarkistetaan kuinka usein maksettujen summien ja item plus freight summien välillä on eroa.

Tämä ei ole vielä päätös siitä mikä on oikea raha mittari.
Tavoite on ensin mitata ero ja sen suuruusluokka.
*/

with diffs as (
    select
        order_id,
        order_gross_value,
        payment_value_total,
        abs(coalesce(payment_value_total, 0) - order_gross_value) as abs_diff
    from orders_fact
)
select
    count(*) as orders_total,
    sum(case when payment_value_total is null then 1 else 0 end) as missing_payment_total,
    sum(case when abs_diff <= 0.01 then 1 else 0 end) as diff_le_0_01,
    sum(case when abs_diff > 0.01 and abs_diff <= 1.00 then 1 else 0 end) as diff_0_01_to_1,
    sum(case when abs_diff > 1.00 and abs_diff <= 10.00 then 1 else 0 end) as diff_1_to_10,
    sum(case when abs_diff > 10.00 then 1 else 0 end) as diff_gt_10,
    max(abs_diff) as max_abs_diff
from diffs;
