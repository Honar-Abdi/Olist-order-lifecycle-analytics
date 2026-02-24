# Olist Order Lifecycle Analytics

End-to-end analytical pipeline built on the Olist Brazilian e-commerce dataset.

The project transforms raw transactional CSV data into a structured and validated analytical layer using DuckDB and SQL.

The focus is on data correctness, modeling discipline, and explicit analytical decisions.

🇫🇮 Finnish summary: [README.fi.md](README.fi.md)

---

## TLDR

This project demonstrates:

- Deterministic data ingestion into DuckDB  
- Explicit reconciliation of data inconsistencies  
- Canonical fact table modeling  
- Dimension tables with verified grain  
- Revenue consistency validation  
- A final KPI summary table for business-level insight  

The result is a fully reproducible analytics engineering pipeline from raw data to executive-level metrics.

---

## Dataset

Source: Kaggle – Olist Brazilian E-commerce dataset  
Time range: 2016–2018  
Size: approximately 100,000 orders  

Main tables:

- orders  
- order_items  
- order_payments  
- order_reviews  
- customers  
- sellers  
- products  
- geolocation  

---

## Architecture

The project follows a layered structure.

### data/raw  
Original CSV files. Never modified.

### data/processed  
DuckDB database generated from raw data.

### src  
Python ingestion script. Responsible only for loading data.

### sql  
Structured into:

- staging  
- marts  
- checks  

### reports  
Markdown documentation for each modeling decision.

---

## Pipeline Overview

### 1. Ingest Layer

Script: `src/01_ingest_duckdb.py`

- Loads all CSV files into DuckDB  
- Creates one table per dataset  
- Validates row counts  
- Verifies relationship between orders and order_items  

Result:
- 99,441 total orders  
- 775 orders without item rows  

No business filtering occurs at this stage.

---

### 2. Reconciliation

File: `sql/staging/00_reconcile_orders_vs_items.sql`  
Report: `reports/00_reconciliation.md`

Purpose:
Investigate orders that exist in `orders` but not in `order_items`.

Finding:
775 orders have no item rows.  
These represent incomplete lifecycles and are excluded from analytical fact tables.

This decision is documented before modeling.

---

### 3. Canonical Fact Table

File: `sql/marts/01_build_orders_fact.sql`  
Report: `reports/01_orders_fact.md`

Definition:

Completed order = order_status = delivered

The `orders_fact` table:

- One row per delivered order  
- Excludes orders without item rows  
- Aggregates item-level data to order level  
- Aggregates payment data  
- Adds lifecycle metrics such as delivery_days and approval_days  

Result:
96,478 delivered and valid orders.

This table is the analytical core of the project.

---

### 4. Dimension Tables

Built from the fact layer:

- dim_customers  
- dim_customers_unique  
- dim_sellers  
- dim_products  

Each dimension:

- Has a clearly defined grain  
- Includes validation checks  
- Preserves revenue consistency  

Grain checks confirm one row per entity.  
Total checks confirm no revenue distortion.

---

### 5. Revenue Consistency Validation

File: `sql/checks/02_check_payments_vs_gross.sql`

Purpose:
Measure differences between:

- Calculated gross order value  
- Actual payment totals  

Finding:
The vast majority of orders match within small rounding tolerance.  
Edge cases are measured and documented.

Revenue metrics are not assumed. They are verified.

---

### 6. KPI Summary

File: `sql/marts/07_kpi_order_lifecycle_summary.sql`  
Report: `reports/marts/07_kpi_order_lifecycle_summary.md`

One-row business summary including:

- Total delivered orders  
- Total gross and paid revenue  
- Average order value  
- Average delivery time  
- Total customers  
- Repeat customer rate  
- Total sellers  
- Total products  

This provides an executive-level overview of marketplace performance.

---

## Design Principles

- Raw data is immutable  
- All modeling decisions are documented  
- Grain is explicitly defined  
- Revenue is validated before analysis  
- Each transformation step is reproducible  
- Checks are integrated into the pipeline  

This is an analytics engineering project, not a dashboard project.

---

## How to Run

Place Kaggle CSV files into data/raw before running the pipeline.

1. Activate virtual environment  
2. Run the full pipeline  

```bash
python scripts/run_pipeline.py
```

## Production considerations

In a production setting, this pipeline would include:

- Automated ingestion runs with environment-specific configuration  
- Data quality checks that fail the pipeline on critical integrity breaks  
- Scheduled orchestration and run logs for traceability  
- Versioned analytical models and reproducible builds  
- Alerting for metric drift and coverage changes such as missing item lines or payment anomalies  

The core modeling approach would remain similar.
The difference would be operational controls, monitoring, and repeatable execution.

---

## Conclusion

This project is built around a simple idea:
analytics is only as reliable as the definitions and validation steps behind it.

So far, the work shows that:

- Raw data must be ingested without hidden transformations  
- Data completeness issues must be measured and documented  
- Completed order definitions must be explicit  
- Order-level facts should be constructed in a dedicated analytical layer  
- Revenue-related fields must be validated before KPI reporting  

With these foundations in place, the next steps can focus on business questions
without needing to re-litigate what the data represents.