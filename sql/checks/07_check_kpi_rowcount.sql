/*
Sanity check KPI table.

KPI-taulussa tulee olla yksi rivi.
*/

select
    count(*) as row_count
from kpi_order_lifecycle_summary;