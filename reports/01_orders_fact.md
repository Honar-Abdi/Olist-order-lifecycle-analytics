# Orders fact table

## What this table is

orders_fact is the canonical order level fact table used for analysis.
It contains one row per order.

## Scope and filters

Completed order is defined as order_status delivered.
Orders without item rows are excluded by construction via an inner join to aggregated items.

## Build inputs

orders
order_items
order_payments
order_reviews

## Result

Row count in orders_fact is 96478.

## Key metrics included

order_gross_value is computed as sum of item price plus freight at order level.
payment_value_total is computed as sum of payment_value at order level.
delivery_days is computed from purchase timestamp to delivered customer date.
approval_days is computed from purchase timestamp to approved at.

## Notes

Payment totals and gross value should generally align but can differ due to rounding or edge cases.
A separate consistency check quantifies the magnitude and frequency of these differences.
