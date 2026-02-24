# Orders without order_items reconciliation

## Background

During data ingestion, a difference was found between:

- The total number of orders in the `orders` table  
- The number of distinct `order_id` values in the `order_items` table  

Total orders in dataset: 99,441.

This document explains the findings and how these orders are handled in the analytical layer.

---

## Reconciliation results

A total of **775 orders (0.78%)** exist in the `orders` table without any matching rows in `order_items`.

Lifecycle timestamp inspection shows:

- Orders missing order_items: **775**
- Orders missing purchase timestamp: **0**
- Orders missing approval timestamp: **146**
- Orders missing delivery timestamp: **775**

---

## Interpretation

All 775 orders have a purchase timestamp.  
This means the orders were created in the system.

However:

- None of these orders have a delivery timestamp.
- 146 of them also do not have an approval timestamp.

This indicates that these orders did not complete the normal order lifecycle.  
They likely represent cancelled, interrupted, or failed transactions rather than data errors.

---

## Analytical decision

Orders without item rows are excluded from the `orders_fact` table.

The fact table:

- Includes only orders with `order_status = 'delivered'`
- Requires at least one item row

These orders remain available in the raw data layer, but they are excluded from revenue and delivery analysis.

---

## Reason for separation

This reconciliation step is documented separately from modeling logic.

The goal is to make filtering decisions clear and visible before building analytical tables.