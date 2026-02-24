# Revenue consistency check

## Purpose

This check compares two order level revenue measures:

- `order_gross_value`
- `payment_value_total`

The goal is to measure how often these values differ and how large the differences are.

No decision is made in this step.  
This step only measures and documents the differences.

---

## Definitions

- `order_gross_value`  
  Sum of item price plus freight at order level.

- `payment_value_total`  
  Sum of all recorded payments at order level.

Both values are calculated in the `orders_fact` table.

---

## Results

Total delivered orders analyzed: **96,478**

Summary of differences:

- Orders with missing payment total: **1**
- Orders where difference is less than or equal to 0.01: **96,103**
- Orders where difference is between 0.01 and 1.00: **128**
- Orders where difference is between 1.00 and 10.00: **149**
- Orders where difference is greater than 10.00: **98**
- Maximum absolute difference observed: **182.81**

---

## Interpretation

The vast majority of orders show no meaningful difference between gross value and payment total.

Only a small number of orders show larger differences.

One order has a missing payment total.

This indicates that both revenue measures are generally aligned, but edge cases exist.

---

## Analytical implication

Revenue definitions should be chosen explicitly.

Because differences are measured and documented:

- Either metric can be used with awareness of edge cases.
- If strict financial accuracy is required, `payment_value_total` may be preferred.
- If product and logistics level analysis is the focus, `order_gross_value` may be preferred.

This check ensures that revenue decisions are based on observed data rather than assumptions.