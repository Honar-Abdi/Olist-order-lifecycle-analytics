# Orders without order_items reconciliation

## Background

During the initial data ingestion, a mismatch was observed between the number of orders
in the `orders` table and the number of distinct `order_id` values present in
the `order_items` table.

This document records the reconciliation results and the reasoning behind how these
orders are treated in subsequent analyses.

---

## Reconciliation results

A total of **775 orders** exist in the `orders` table without any corresponding rows
in the `order_items` table.

To better understand the nature of these orders, their lifecycle timestamps were examined.

Summary of findings:

- Total orders missing order_items: **775**
- Orders missing purchase timestamp: **0**
- Orders missing approval timestamp: **146**
- Orders missing delivery timestamp: **775**

---

## Interpretation

All orders missing item rows have a recorded purchase timestamp, indicating that they
were created beyond the initial checkout phase.

However, none of these orders were delivered to customers, and a subset of them also
lacks a payment approval timestamp.

This pattern suggests that these orders represent interrupted or failed order lifecycles
rather than simple data loss or incomplete ingestion.

---

## Analytical decision

For analyses that assume a completed order lifecycle, these orders are excluded.

They are retained in the raw data layer and remain accessible for process-level
investigation, but they are not considered valid completed orders for revenue,
delivery, or fulfillment analyses.

---

## Notes

This reconciliation step is intentionally separated from later modeling logic.
Its purpose is to make explicit which assumptions are applied before constructing
order-level analytical metrics.
