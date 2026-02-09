from pathlib import Path
import duckdb


# Tämä skripti vastaa projektin ingest-vaiheesta.
# Tarkoitus on lukea raaka CSV-data sellaisenaan DuckDB-tietokantaan
# ilman liiketoimintalogiikkaa tai datan muokkausta.


BASE_DIR = Path(__file__).resolve().parents[1]
RAW_DIR = BASE_DIR / "data" / "raw"
PROCESSED_DIR = BASE_DIR / "data" / "processed"
DB_PATH = PROCESSED_DIR / "olist.duckdb"


TABLES = {
    "customers": "olist_customers_dataset.csv",
    "geolocation": "olist_geolocation_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "order_payments": "olist_order_payments_dataset.csv",
    "order_reviews": "olist_order_reviews_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "product_category_name_translation": "product_category_name_translation.csv",
}


def main() -> None:
    PROCESSED_DIR.mkdir(parents=True, exist_ok=True)

    missing_files = [
        filename
        for filename in TABLES.values()
        if not (RAW_DIR / filename).exists()
    ]

    if missing_files:
        raise FileNotFoundError(
            "Seuraavat CSV-tiedostot puuttuvat data/raw-kansiosta:\n"
            + "\n".join(missing_files)
        )

    con = duckdb.connect(DB_PATH)

    for table_name, file_name in TABLES.items():
        csv_path = RAW_DIR / file_name

        con.execute(
            f"""
            CREATE OR REPLACE TABLE {table_name} AS
            SELECT *
            FROM read_csv_auto('{csv_path.as_posix()}');
            """
        )

    print("DuckDB-tietokanta luotu")
    print(f"Tietokannan sijainti: {DB_PATH}")
    print()
    print("Taulujen rivimäärät")

    for table_name in TABLES.keys():
        row_count = con.execute(
            f"SELECT COUNT(*) FROM {table_name}"
        ).fetchone()[0]

        print(f"{table_name}: {row_count}")

    orders_count = con.execute(
        "SELECT COUNT(DISTINCT order_id) FROM orders"
    ).fetchone()[0]

    items_count = con.execute(
        "SELECT COUNT(DISTINCT order_id) FROM order_items"
    ).fetchone()[0]

    missing_in_items = con.execute(
        """
        SELECT COUNT(*)
        FROM orders o
        LEFT JOIN order_items i
        ON o.order_id = i.order_id
        WHERE i.order_id IS NULL
        """
    ).fetchone()[0]

    print()
    print("Orders ja order_items välinen tarkistus")
    print(f"Orders-taulun uniikit tilaukset: {orders_count}")
    print(f"Order_items-taulun uniikit tilaukset: {items_count}")
    print(f"Tilaukset ilman item-rivejä: {missing_in_items}")

    con.close()


if __name__ == "__main__":
    main()
