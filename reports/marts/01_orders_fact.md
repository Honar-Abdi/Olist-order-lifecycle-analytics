# Orders fact table

## Purpose

`orders_fact` is the main analytical table used for order level analysis.

It contains one row per delivered order with at least one item.

This table is the foundation for revenue, lifecycle, and customer level analysis.

---

## Grain

One row per `order_id`.

Only orders that:

- Have `order_status = delivered`
- Have at least one row in `order_items`

Orders without item rows are excluded based on the reconciliation step.

---

## Data sources

The table is built from the following inputs:

- `orders`
- `order_items`
- `order_payments`
- `order_reviews`

Item level data and payment data are aggregated to order level before joining.

---

## Result

Total rows in `orders_fact`: **96,478**

This represents all delivered orders with valid item data.

---

## Key metrics

- `order_gross_value`  
  Sum of item price plus freight at order level.

- `payment_value_total`  
  Sum of payment_value at order level.

- `delivery_days`  
  Number of days between purchase timestamp and delivery to customer.

- `approval_days`  
  Number of days between purchase timestamp and payment approval.

---

## Revenue consistency

In most cases, `order_gross_value` and `payment_value_total` are aligned.

Small differences may occur due to rounding or specific payment situations.

A separate consistency check measures:

- How often differences occur
- The size of those differences

This ensures that revenue related decisions are based on measured evidence.