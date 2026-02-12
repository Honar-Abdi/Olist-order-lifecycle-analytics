from pathlib import Path
import duckdb


"""
Ingest-vaihe.

Tämän skriptin tarkoitus on tuoda Olistin raaka CSV-data
DuckDB-tietokantaan sellaisenaan ilman liiketoimintalogiikkaa.

Tässä vaiheessa:
- ei tehdä siivousta
- ei yhdistetä tauluja
- ei rajata tilauksia

Tavoitteena on toistettava ja läpinäkyvä lähtöpiste analyysille.
"""


BASE_DIR = Path(__file__).resolve().parents[1]
RAW_DIR = BASE_DIR / "data" / "raw"
PROCESSED_DIR = BASE_DIR / "data" / "processed"
DB_PATH = PROCESSED_DIR / "olist.duckdb"


# CSV-tiedostojen ja kohdettaulujen välinen eksplisiittinen mapping.
# Tämä tekee ingestistä deterministisen ja helposti tarkistettavan.
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

    # Tulostetaan käytetyt polut, jotta mahdollinen väärä projektihakemisto
    # havaitaan heti eikä vasta myöhemmin analyysivaiheessa.
    print(f"Project root {BASE_DIR}")
    print(f"Raw data dir {RAW_DIR}")
    print(f"Processed dir {PROCESSED_DIR}")
    print(f"DuckDB path {DB_PATH}")
    print()

    # Varmistetaan että processed-kansio on olemassa ennen tietokannan luontia.
    PROCESSED_DIR.mkdir(parents=True, exist_ok=True)

    # Tarkistetaan että kaikki odotetut CSV-tiedostot löytyvät.
    # Ingest keskeytetään, jos lähdedata ei ole täydellinen.
    missing_files = [f for f in TABLES.values() if not (RAW_DIR / f).exists()]
    if missing_files:
        raise FileNotFoundError(
            "Seuraavat CSV-tiedostot puuttuvat data/raw-kansiosta\n"
            + "\n".join(missing_files)
        )

    # Yhdistetään DuckDB-tietokantaan.
    # Tietokanta luodaan automaattisesti, jos sitä ei ole olemassa.
    con = duckdb.connect(str(DB_PATH))

    try:
        # Jokainen CSV luetaan sellaisenaan omaan tauluunsa.
        # create or replace tekee ingestistä idempotentin,
        # eli skripti voidaan ajaa uudelleen ilman manuaalista siivousta.
        for table_name, file_name in TABLES.items():
            csv_path = (RAW_DIR / file_name).resolve().as_posix()

            con.execute(
                f"""
                create or replace table {table_name} as
                select *
                from read_csv_auto('{csv_path}');
                """
            )

        print("DuckDB-tietokanta luotu ja taulut päivitetty")
        print()

        # Perusrivimäärät toimivat ensimmäisenä eheyden tarkistuksena.
        print("Taulujen rivimäärät")
        for table_name in TABLES.keys():
            row_count = con.execute(
                f"select count(*) from {table_name}"
            ).fetchone()[0]
            print(f"{table_name} {row_count}")

        # Tarkistetaan orders ja order_items välinen suhde.
        # Tämä ei vielä tee analyysipäätöksiä, vaan tuo esiin mahdolliset poikkeamat.
        orders_count = con.execute(
            "select count(distinct order_id) from orders"
        ).fetchone()[0]

        items_count = con.execute(
            "select count(distinct order_id) from order_items"
        ).fetchone()[0]

        missing_in_items = con.execute(
            """
            select count(*)
            from orders o
            left join order_items i
              on o.order_id = i.order_id
            where i.order_id is null
            """
        ).fetchone()[0]

        print()
        print("Orders ja order_items välinen tarkistus")
        print(f"Orders-taulun uniikit tilaukset {orders_count}")
        print(f"Order_items-taulun uniikit tilaukset {items_count}")
        print(f"Tilaukset ilman item-rivejä {missing_in_items}")

    finally:
        # Yhteys suljetaan aina, myös virhetilanteessa.
        con.close()


if __name__ == "__main__":
    main()
