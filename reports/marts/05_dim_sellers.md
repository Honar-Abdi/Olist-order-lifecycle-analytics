# Seller dimension

## Purpose

`dim_sellers` summarizes delivered order activity at the seller level.

It contains one row per `seller_id`.

This table supports seller performance analysis based on delivered orders.

---

## Grain

One row per `seller_id`.

---

## Data sources

Built from:

- `orders_fact`
- `order_items`
- `sellers`

Only delivered orders with valid item data are included.

---

## Result

Total rows in `dim_sellers`: **2,970**

---

## Revenue definition used here

Revenue is computed from seller item rows:

- `items_price_total_seller` = sum of item prices for the seller
- `freight_total_seller` = sum of freight values for the seller
- `seller_gross_value_total` = item price + freight for the seller

Payment totals are not allocated to sellers in this step.
Allocating payments to sellers would require an explicit allocation rule.

---

## Key metrics

- `total_orders`  
  Number of delivered orders that include this seller.

- `total_item_rows`  
  Number of item rows sold by the seller.

- `distinct_products_sold`  
  Number of distinct products sold by the seller.

- `first_order_date`, `last_order_date`  
  First and last purchase dates for delivered orders.

- `avg_delivery_days`  
  Average delivery time for orders that include the seller.

- `avg_approval_days`  
  Average time from purchase to approval for orders that include the seller.

---

## Validation

Two checks are used:

1. Grain check  
   Confirms one row per seller_id.

2. Total consistency check  
   Confirms that the sum of seller gross values matches the delivered item gross total
   within a small rounding tolerance.