# Customer dimension (customer_unique_id level)

## Purpose

`dim_customers_unique` summarizes delivered order data at the `customer_unique_id` level.

It contains one row per unique customer.

This table enables repeat purchase, retention, and lifetime value analysis.

---

## Grain

One row per `customer_unique_id`.

Unlike `customer_id`, which often represents an order instance,
`customer_unique_id` represents the same customer across multiple orders.

This makes it suitable for lifecycle and long term analysis.

---

## Data sources

This table is built from:

- `orders_fact`
- `customers`

The `customers` table is used to map `customer_id` to `customer_unique_id`.

All metrics are calculated only from delivered orders with valid item data.

---

## Result

Total rows in `dim_customers_unique`: **93,358**

Additional observations:

- Customers with more than one order: **2,801**
- Maximum number of orders by a single customer: **15**

This confirms that a subset of customers placed repeat orders.

---

## Metrics included

- `first_order_date`  
  Earliest purchase date for the customer.

- `last_order_date`  
  Most recent purchase date for the customer.

- `total_orders`  
  Number of delivered orders linked to the customer.

- `gross_revenue_total`  
  Sum of item price plus freight across all orders.

- `paid_revenue_total`  
  Sum of recorded payments across all orders.

- `gross_aov`  
  Average gross order value.

- `paid_aov`  
  Average paid order value.

- `avg_delivery_days`  
  Average time from purchase to delivery.

- `avg_approval_days`  
  Average time from purchase to payment approval.

- `orders_missing_payment`  
  Number of orders without a recorded payment total.

- `paid_to_gross_ratio`  
  Ratio between paid revenue and gross revenue.

---

## Interpretation

Most customers placed only one delivered order.

A smaller group of customers placed multiple orders.
This allows customer level analysis such as:

- Repeat purchase rate
- Customer lifetime value
- Order frequency
- Time between first and last order

Because revenue consistency was previously measured,
both gross and paid revenue metrics are retained for transparency.

---

## Analytical importance

This table enables customer level analysis beyond single transactions.

It separates order level activity from customer level behavior,
which is essential for retention and lifecycle analytics.