# Olist Order Lifecycle Analytics

End-to-end analytical pipeline built on the Olist Brazilian e-commerce dataset.

The goal of this project is to transform raw transactional data into a structured,
auditable analytical layer that supports business-level revenue and lifecycle analysis.

This is not a dashboard project.
The focus is on data correctness, modeling decisions, and explicit analytical reasoning.

---

## Dataset

Source: Kaggle – Olist Brazilian E-commerce dataset  
Time range: 2016–2018  
Size: ~100k orders

The dataset contains:

- orders
- order_items
- order_payments
- order_reviews
- customers
- sellers
- products
- geolocation

---

## Project Architecture

The project follows a layered structure.

data/raw  
Raw CSV files downloaded from Kaggle. Never modified.

data/processed  
DuckDB database generated from raw data.

src  
Python scripts responsible for ingestion.

sql  
Analytical SQL queries and modeling steps.

reports  
Markdown documentation of each analytical decision.

---

## Current Pipeline Status

### 1. Ingest Layer

Script: `src/01_ingest_duckdb.py`

- Loads all raw CSV files into DuckDB
- Creates one table per dataset
- Performs basic row-count validation
- Verifies relationship between orders and order_items

Result:
- 99,441 total orders
- 775 orders without item rows

---

### 2. Reconciliation Analysis

File: `sql/00_reconcile_orders_vs_items.sql`  
Report: `reports/00_reconciliation.md`

Goal:
Investigate orders that exist in `orders` but have no matching rows in `order_items`.

Finding:
775 orders have no associated item rows.
These orders are excluded from analytical fact tables.

---

### 3. Canonical Order-Level Fact Table

File: `sql/01_build_orders_fact.sql`  
Report: `reports/01_orders_fact.md`

Definition:

Completed order = order_status = 'delivered'

The `orders_fact` table:

- One row per delivered order
- Excludes orders without item rows
- Aggregates item-level data to order level
- Aggregates payment data to order level
- Adds lifecycle metrics such as:
  - delivery_days
  - approval_days

Result:
96,478 delivered orders with valid item data.

---

### 4. Revenue Consistency Check

File: `sql/02_check_payments_vs_gross.sql`  
Report: `reports/02_check_payments_vs_gross.md`

Goal:
Measure differences between:

- order_gross_value (item price + freight)
- payment_value_total (actual payments)

Findings:
The vast majority of orders match within small rounding tolerance.
A small number of orders show larger discrepancies, requiring explicit metric choice.

---

## Key Design Principles

- Raw data is never modified
- Every modeling decision is documented
- Each SQL layer has a corresponding report
- Analytical definitions are explicit and reproducible
- Revenue metric decisions are based on measured evidence

---

## Next Steps

- Inspect revenue discrepancies in detail
- Decide authoritative revenue metric
- Build KPI layer on top of orders_fact
- Introduce customer-level and seller-level aggregates
- Perform lifecycle timing analysis
