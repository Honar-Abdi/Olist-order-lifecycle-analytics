# Customer dimension (customer_id level)

## Purpose

`dim_customers` summarizes order level information at the `customer_id` level.

It contains one row per `customer_id`.

This table supports basic customer level metrics based on the order instance stored in the dataset.

---

## Grain

One row per `customer_id`.

Important note:

In this dataset, `customer_id` is often unique per order.
It does not necessarily represent a single long term customer.

For lifecycle and repeat purchase analysis, `customer_unique_id` should be used instead.

---

## Data source

This table is built from:

- `orders_fact`

All metrics are aggregated from delivered orders with valid item data.

---

## Result

Total rows in `dim_customers`: **96,478**

This matches the number of rows in `orders_fact`, because most `customer_id` values appear only once.

---

## Metrics included

- `first_order_date`  
  Earliest purchase date for the customer_id.

- `last_order_date`  
  Latest purchase date for the customer_id.

- `total_orders`  
  Number of delivered orders linked to the customer_id.

- `gross_revenue_total`  
  Sum of item price plus freight across orders.

- `paid_revenue_total`  
  Sum of recorded payments across orders.

- `gross_aov`  
  Average gross order value.

- `paid_aov`  
  Average paid order value.

- `avg_delivery_days`  
  Average number of days from purchase to delivery.

- `avg_approval_days`  
  Average number of days from purchase to payment approval.

- `orders_missing_payment`  
  Number of orders without a recorded payment total.

- `paid_to_gross_ratio`  
  Ratio between paid revenue and gross revenue.

---

## Interpretation

Because `customer_id` is typically unique per order in this dataset,
this table mostly mirrors order level data.

It is useful for validating aggregation logic and understanding dataset structure.

However, it should not be used for long term customer retention analysis.

For true customer lifecycle analysis, `dim_customers_unique`
based on `customer_unique_id` is required.