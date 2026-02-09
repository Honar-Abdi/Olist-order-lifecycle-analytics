/* 
Tämä kysely tarkastelee tilauksia, jotka esiintyvät orders-taulussa
mutta joilla ei ole yhtään vastaavaa riviä order_items-taulussa.

Tarkoitus on ymmärtää, missä order_status-luokissa
tällaiset tilaukset painottuvat.
*/

select
    o.order_status,
    count(*) as orders_missing_items
from orders o
left join order_items i
    on o.order_id = i.order_id
where i.order_id is null
group by o.order_status
order by orders_missing_items desc;


/*
Tässä kyselyssä tarkastellaan samoja tilauksia aikaleimojen näkökulmasta.

Tavoite on nähdä, kuinka pitkälle nämä tilaukset ovat edenneet
order lifecycle -prosessissa ennen kuin item-rivit puuttuvat.

Jos aikaleimat puuttuvat varhaisessa vaiheessa,
se viittaa keskeytyneeseen prosessiin eikä tekniseen virheeseen.
*/

select
    count(*) as total_orders_missing_items,
    sum(case when order_purchase_timestamp is null then 1 else 0 end) as missing_purchase_timestamp,
    sum(case when order_approved_at is null then 1 else 0 end) as missing_approved_timestamp,
    sum(case when order_delivered_customer_date is null then 1 else 0 end) as missing_delivered_timestamp
from orders o
left join order_items i
    on o.order_id = i.order_id
where i.order_id is null;
