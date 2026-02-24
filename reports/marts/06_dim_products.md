# Product dimension

## Purpose

`dim_products` summarizes delivered order activity at the product level.

It contains one row per `product_id`.

This table supports product performance and category level analysis.

---

## Grain

One row per `product_id`.

---

## Data sources

Built from:

- `orders_fact`
- `order_items`
- `products`
- `product_category_name_translation`

Only delivered orders with valid item data are included.

---

## Result

Total rows in `dim_products`: **32,216**

---

## Revenue definition used here

Revenue is computed from product item rows:

- `items_price_total_product` = sum of item prices for the product
- `freight_total_product` = sum of freight values for the product
- `product_gross_value_total` = item price + freight for the product

Payment totals are not allocated to products in this step.

---

## Key metrics

- `total_orders`  
  Number of delivered orders that include the product.

- `total_item_rows`  
  Number of item rows for the product.

- `distinct_sellers`  
  Number of sellers that sold the product.

- `first_order_date`, `last_order_date`  
  First and last purchase dates for delivered orders.

- `avg_item_price`, `avg_item_freight`  
  Average item price and freight for the product.

- `avg_delivery_days`, `avg_approval_days`  
  Average lifecycle timing for orders that include the product.

- `product_category_name`, `product_category_name_english`  
  Category fields for grouping and reporting.

---

## Validation

Two checks are used:

1. Grain check  
   Confirms one row per product_id.

2. Total consistency check  
   Confirms that the sum of product gross values matches the delivered item gross total
   within a small rounding tolerance.