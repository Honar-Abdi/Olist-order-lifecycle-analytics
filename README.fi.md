# Olist Order Lifecycle Analytics – Tiivistelmä

## TLDR

Tässä projektissa rakennetaan kerroksellinen analytiikkaputki Olistin verkkokauppadatasta Pythonin, SQL:n ja DuckDB:n avulla.

Raaka CSV-transaktiodata ingestataan sellaisenaan tietokantaan, validoidaan eheystarkistuksilla ja mallinnetaan canonical fact- ja dimension-tauluiksi. Revenue-mittarit tarkistetaan eksplisiittisesti ennen KPI-raportointia.

Painopiste on mallinnuksen kurinalaisuudessa, datan laadun mittaamisessa ja toistettavassa analytiikassa.

Projekti soveltuu erityisesti analytics engineering- ja data engineering -rooleihin, joissa korostuvat oikeellisuus, selkeä datamalli ja liiketoimintalogiikan ymmärrys.

---

## 1. Lähtökohta

Verkkokauppadata koostuu useista toisiinsa liittyvistä tauluista, kuten:

- orders  
- order_items  
- order_payments  
- order_reviews  

Näiden välillä voi esiintyä:

- puuttuvia rivejä  
- ristiriitaisia summia  
- keskeneräisiä elinkaarivaiheita  

Jos mallinnuslogiikkaa ei määritellä eksplisiittisesti, sama liikevaihto voidaan raportoida eri tavoin riippuen siitä, mihin tauluun tai määritelmään tukeudutaan.

Projektin keskeinen kysymys on:

Miten raakamuotoinen verkkokauppadata mallinnetaan luotettavaksi analytiikkakerrokseksi siten, että mittarit ovat johdonmukaisia ja toistettavia?

---

## 2. Arkkitehtuuri

Projekti noudattaa kerroksellista rakennetta:

data/raw  
Alkuperäinen CSV-data. Ei muokata.

data/processed  
DuckDB-tietokanta, johon ingest tehdään.

sql/staging  
Eheystarkistukset ja alustava validointi.

sql/marts  
Fact- ja dimension-taulut.

sql/checks  
Mittareiden ja aggregaatioiden konsistenssitarkistukset.

reports  
Dokumentoidut mallinnuspäätökset ja havainnot.

scripts  
Koko pipeline ajettavissa yhdellä komennolla.

Rakenne erottaa raakadatan, mallinnuslogiikan ja validoinnin selkeästi toisistaan.

---

## 3. Ingestointi ja eheystarkistus

Kaikki CSV-tiedostot ladataan deterministisesti DuckDB:hen ilman liiketoimintasuodatuksia.

Ingest-vaiheessa:

- luodaan yksi taulu per lähdedatasetti  
- validoidaan rivimäärät  
- tarkistetaan orders- ja order_items-taulujen välinen suhde  

Analyysissä havaittiin, että osa tilauksista esiintyy orders-taulussa ilman vastaavaa order_items-riviä.

Nämä tilaukset eivät ole analyysikelpoisia toimitettuina tilauksina, ja niiden käsittely dokumentoidaan ennen faktataulun rakentamista.

---

## 4. Canonical fact -taulu

Projektin ydin on orders_fact-taulu.

Määritelmä:

Completed order = order_status = delivered

orders_fact sisältää:

- yhden rivin per toimitettu tilaus  
- item-tason aggregoinnin order-tasolle  
- payment-tason aggregoinnin order-tasolle  
- elinkaarimittarit kuten delivery_days ja approval_days  

Grain määritellään eksplisiittisesti. Yksi rivi vastaa yhtä toimitettua tilausta.

Tämä taulu toimii analytiikan perustana.

---

## 5. Dimension-taulut

Fact-taulun päälle rakennetaan:

- dim_customers  
- dim_customers_unique  
- dim_sellers  
- dim_products  

Jokaiselle taululle määritellään selkeä grain.

Rakenteen tavoitteena on:

- estää duplikaatit  
- varmistaa, ettei revenue vääristy join-operaatioissa  
- mahdollistaa analyysi asiakas-, myyjä- ja tuotetasolla  

Dimension-taulut validoidaan tarkistuskyselyillä.

---

## 6. Revenue-validointi

Liikevaihtoa tarkastellaan kahdesta näkökulmasta:

1. Laskettu bruttosumma item- ja freight-kentistä  
2. Maksutietoihin perustuva payment_value_total  

Valtaosa tilauksista täsmää lähes täydellisesti, mutta pieni joukko poikkeamia havaitaan.

Poikkeamat:

- mitataan  
- luokitellaan  
- dokumentoidaan  

Revenue-mittaria ei oleteta oikeaksi. Se validoidaan ennen KPI-kerrosta.

---

## 7. KPI-yhteenveto

Lopuksi rakennetaan yhden rivin liiketoimintayhteenveto, joka sisältää:

- toimitettujen tilausten määrä  
- kokonaistulot  
- keskiostoksen arvo  
- keskimääräinen toimitusaika  
- asiakasmäärä  
- toistuvien asiakkaiden osuus  
- myyjien ja tuotteiden määrä  

Tämä kerros soveltuu johdon tason tarkasteluun.

---

## 8. Mitä projekti osoittaa

Projekti osoittaa:

- kyvyn rakentaa kerroksellinen analytiikkaputki  
- vahvan SQL-pohjaisen mallinnusosaamisen  
- grainin eksplisiittisen määrittelyn  
- datalaadun systemaattisen käsittelyn  
- mittarien validoinnin ennen raportointia  
- mallinnuspäätösten dokumentoinnin  

Kyse ei ole visualisointiprojektista, vaan analytiikan perustan rakentamisesta.

---

## 9. Tuotantoympäristön näkökulma

Tuotannossa kokonaisuutta laajennettaisiin:

- automatisoidulla ajoituksella  
- jatkuvalla datalaadun seurannalla  
- testauksella ja versionhallinnalla  
- poikkeamien hälytyksillä  

Mallinnusperiaatteet pysyisivät samoina. Erot syntyisivät operatiivisesta kontrollista ja monitoroinnista.

---

## Johtopäätös

Tämä projekti osoittaa, että luotettava analytiikka rakentuu rakenteesta, ei yksittäisistä kyselyistä.

Kun:

- raaka data ingestataan muuttamattomana  
- eheysongelmat mitataan ennen mallinnusta  
- grain määritellään eksplisiittisesti  
- fact- ja dimension-taulut erotetaan selkeästi  
- revenue validoidaan ennen KPI-raportointia  

syntyy analytiikkakerros, joka on johdonmukainen ja toistettavissa.

Projektin keskeinen arvo ei ole yksittäinen mittari, vaan mallinnuskurinalaisuus, joka tekee mittareista vertailukelpoisia ja liiketoiminnallisesti luotettavia.

Ilman tätä rakennetta raportointi voi näyttää oikealta, vaikka sen taustalla oleva logiikka ei olisi eksplisiittisesti määritelty tai validoitu.