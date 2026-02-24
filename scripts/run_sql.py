"""
SQL-ajuri.

Tämä skripti suorittaa annetun SQL-tiedoston
data/processed/olist.duckdb -tietokantaa vasten.

Käyttö:
    python scripts/run_sql.py polku/sql_tiedostoon.sql

Skripti:
- avaa DuckDB-yhteyden
- lukee SQL-tiedoston sisällön
- suorittaa kyselyn
- tulostaa tulosjoukon, jos kysely palauttaa rivejä
- sulkee yhteyden
"""

from __future__ import annotations

import sys
from pathlib import Path

import duckdb


BASE_DIR = Path(__file__).resolve().parents[1]
DB_PATH = BASE_DIR / "data" / "processed" / "olist.duckdb"


def main() -> None:
    if len(sys.argv) != 2:
        raise ValueError(
            "Anna suoritettava SQL-tiedosto argumenttina.\n"
            "Esimerkki: python scripts/run_sql.py sql/01_build_orders_fact.sql"
        )

    sql_file_path = Path(sys.argv[1]).resolve()

    if not sql_file_path.exists():
        raise FileNotFoundError(f"SQL-tiedostoa ei löydy: {sql_file_path}")

    if not DB_PATH.exists():
        raise FileNotFoundError(
            f"DuckDB-tietokantaa ei löydy: {DB_PATH}\n"
            "Aja ensin ingest-vaihe."
        )

    print(f"Using database: {DB_PATH}")
    print(f"Running SQL file: {sql_file_path}")
    print()

    con = duckdb.connect(str(DB_PATH))

    try:
        sql_text = sql_file_path.read_text(encoding="utf-8")
        result = con.execute(sql_text)

        # Kaikki SQL-komennot eivät palauta tulosjoukkoa.
        # SELECT palauttaa rivejä, CREATE TABLE ei välttämättä.
        if result is not None and result.description is not None:
            rows = result.fetchall()
            columns = [col[0] for col in result.description]

            print("Query result:")
            print(columns)

            for row in rows:
                print(row)

        print()
        print("SQL execution completed.")

    finally:
        con.close()


if __name__ == "__main__":
    main()