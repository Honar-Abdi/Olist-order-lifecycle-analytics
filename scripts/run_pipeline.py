"""
Pipeline-ajuri.

Tämä skripti ajaa projektin vaiheet määritellyssä järjestyksessä:

1. Ingest-vaihe:
   - Lataa raakadata DuckDB-tietokantaan.
   - Luo tai päivittää taulut data/processed/olist.duckdb -tiedostoon.

2. SQL-vaiheet:
   - Ajaa mallinnus- ja tarkistuskyselyt sql-kansiosta.
   - Rakentaa orders_fact-taulun.
   - Suorittaa eheyden ja revenue-tarkistukset.

Skriptin tarkoitus on tehdä koko analyysiputkesta toistettava.
Yhdellä komennolla saadaan sama lopputulos joka ajokerralla.
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parents[1]
SQL_DIR = BASE_DIR / "sql"


SQL_STEPS = [
    # Staging
    "staging/00_reconcile_orders_vs_items.sql",

    # Marts
    "marts/01_build_orders_fact.sql",
    "marts/03_build_dim_customers.sql",
    "marts/04_build_dim_customers_unique.sql",
    "marts/05_build_dim_sellers.sql",
    "marts/06_build_dim_products.sql",
    "marts/07_kpi_order_lifecycle_summary.sql",

    # Checks
    "checks/02_check_payments_vs_gross.sql",
    "checks/03_check_dim_customers_grain.sql",
    "checks/04_check_dim_customers_unique_grain.sql",
    "checks/05_check_dim_sellers_grain.sql",
    "checks/05_check_seller_gross_totals.sql",
    "checks/06_check_dim_products_grain.sql",
    "checks/06_check_product_gross_totals.sql",
    "checks/07_check_kpi_rowcount.sql",
]

def run_ingest() -> None:
    """
    Ajaa ingest-skriptin, joka luo tai päivittää DuckDB-tietokannan.
    """
    ingest_path = BASE_DIR / "src" / "01_ingest_duckdb.py"

    if not ingest_path.exists():
        raise FileNotFoundError(f"Ingest-skripti puuttuu: {ingest_path}")

    print("Running ingest step")
    subprocess.run([sys.executable, str(ingest_path)], check=True)
    print()


def run_sql_steps() -> None:
    """
    Ajaa SQL-tiedostot määritellyssä järjestyksessä.

    Jokainen tiedosto suoritetaan erikseen,
    jotta mahdollinen virhe pysäyttää pipeline-ajon selkeästi.
    """
    runner = BASE_DIR / "scripts" / "run_sql.py"

    if not runner.exists():
        raise FileNotFoundError(f"SQL-ajuri puuttuu: {runner}")

    for fname in SQL_STEPS:
        path = SQL_DIR / fname

        if not path.exists():
            raise FileNotFoundError(f"SQL-tiedosto puuttuu: {path}")

        print(f"Running sql/{fname}")
        subprocess.run([sys.executable, str(runner), str(path)], check=True)
        print()


def main() -> None:
    print(f"Project root: {BASE_DIR}")
    print()

    run_ingest()
    run_sql_steps()

    print("Pipeline finished successfully.")


if __name__ == "__main__":
    main()