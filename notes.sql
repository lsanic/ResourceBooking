--- tok:
--Docker diže Postgres bazu te pokrene init skripte -> Python se spaja, povlači podatke o resursima => racuna iskoristenost
-- koristeci PL/pgSQL funkciju za prijasnjih 30 dana Python cisti sve NULL vrijednosti, doda alarme (Kriticno/Optimalno/Lose) gdje su potrebni i onda
-- sprema lokalni CSV te simulira slanje na S3

--- dodatne natuknice:
-- problem s kruznom ovisnosti (USERS, DEPARTMENT) = rijeseno kroz ALTER TABLE
-- ON DELETE SET NULL osigurava da brisanje menadžera ne obriše cijeli odjel.

---Kontrola konkurentnosti => okidac/trigger sprjecava double-booking 
  
-- koristen je TIMESTAMPTZ kod funkcije fnc_calculate_utilization ; ona prima vremensku zonu da se slaze s Pythonovim timestamp-ovima 

---Optimizacija / query tuning:
-- Koristim EXPLAIN ANALYZE za provjeru plana upita => cilj je potvrditi Index Scan umjesto sporog Seq Scan-a.