# KPI summary

## Purpose

`kpi_order_lifecycle_summary` is a one row table that summarizes the main metrics
for the delivered order dataset.

The goal is to provide a clear overview of volume, revenue, delivery speed,
and repeat purchase behavior.

---

## Grain

One row for the full dataset.

---

## Data sources

Built from:

- `orders_fact`
- `dim_customers_unique`
- `dim_sellers`
- `dim_products`

Only delivered orders with valid item data are included (same scope as `orders_fact`).

---

## KPI results

- Total delivered orders: **96,478**
- Total gross revenue (items + freight): **15,419,773.75**
- Total paid revenue (sum of payments): **15,422,461.77**
- Average gross order value: **159.83**
- Average paid order value: **159.86**
- Average delivery time (days): **12.50**
- Average approval time (days): **0.51**
- Total unique customers (`customer_unique_id`): **93,358**
- Repeat customers (more than one delivered order): **2,801**
- Repeat customer rate: **0.0300**
- Total sellers: **2,970**
- Total products: **32,216**

---

## Interpretation

Most customers placed only one delivered order in this dataset.
Repeat purchase behavior exists but the repeat customer rate is low.

Gross revenue and paid revenue are closely aligned at dataset level.
Small differences can occur due to rounding and payment edge cases,
which were measured in the revenue consistency check.

---

## Validation

A row count check confirms that this table contains exactly one row.