# Sustav za Rezervaciju i Analitiku Resursa
Ovaj projekt predstavlja rješenje za upravljanje i analitiku korporativnih resursa (npr. dvorane, vozila, opreme) unutar organizacije. 
Sustav je dizajniran prema modernim Data Engineering načelima


* **Baza podataka:** PostgreSQL 15 (PL/pgSQL za baznu logiku)
* **Kontejnerizacija i infrastruktura :** Docker & Docker Compose
* **ETL Pipeline:** Python 3 (knjižnice: `psycopg2` (za DB), `boto3` (za Cloud))
* **Cloud Pohrana:** AWS S3
* **Automatizacija:** Windows Batch skripte (`.bat`)

---

## Arhitektura sustava i tok podataka (ETL)

Sustav je podijeljen na dva dijela kako bi se izbjeglo opterećenje transakcijske baze:
1. **OLTP (Transakcijski dio):** PostgreSQL u Dockeru koji mi služi za upisivanje rezervacija, mijenjanje statusa, itd... Tablice su povezane stranim ključevima i optimizirane indeksima za brze upite.
2. **OLAP / Data Lake (Analitički dio):** Python skripta koja odrađuje ETL korake. Izvlači podatke iz baze, transformira ih kroz poslovnu logiku i sprema ih na AWS S3 u obliku CSV izvještaja za analitiku.

### ETL:
**Extract :** Python skripta se spaja na PostgreSQL i povlači podatke o iskorištenosti resursa pozivajući ugrađenu bazičnu funkciju `fnc_calculate_utilization`.
**Transform:** Unutar Pythona se provodi validacija kvalitete podataka (Data Quality) te se nadopunjuju poslovni alarmi (`KRITIČNO`, `OPTIMALNO`, `LOŠE`) na temelju postotka iskorištenosti.
**Load:** Podaci se lokalno strukturiraju u CSV te se preko `boto3` SDK-a šalju izravno na AWS S3 Bucket.




### 1. Sprječavanje Race Conditiona i Duplih Rezervacija (Concurrency Control)
Umjesto oslanjanja na trigger za provjeru preklapanja termina (što u većini sustava stvara problem s konkurentnošću), logika je implementirana unutar procedure `prc_reserve_resource` koristeći **eksplicitno zaključavanje redaka (`SELECT ... FOR UPDATE`)**. Time se nad određenim resursom stvara red čekanja na razini baze i u potpunosti eliminira mogućnost dvostruke rezervacije istog termina.

### 2. Praćenje Povijesti Podataka (Audit Trail)
Implementiran je `AFTER UPDATE` row-level trigger koji se aktivira isključivo ako dođe do stvarne izmjene statusa rezervacije. Trigger kroz zasebnu funkciju izolirano bilježi povijesno stanje (`OLD.status`) i novo stanje (`NEW.status`), bilježeći točan vremenski žig i korisnika koji je izvršio izmjenu.

### 3. Sigurnost i Retencijska Politika (Backup & Maintenance)
Kroz Windows Batch skriptu automatiziran je logički backup baze podataka pomoću `pg_dump` alata. Unutar skripte je implementirana retencijska politika koja automatski čisti s diska datoteke starije od 7 dana, čime se sprječava zagušenje memorije servera.



## Pokretanje projekta
Cijeli sustav je u potpunosti kontejneriziran

1. Pozicionirati se u korijenski direktorij projekta.
2. Pokrenuti: sljedeću naredbu u terminalu:
   ```bash
   docker compose up -d