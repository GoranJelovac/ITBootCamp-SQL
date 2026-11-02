# IT Bootcamp – SQL završni projekat

**Ime i prezime:** Goran Jelovac

## Opis projekta

Ovaj repozitorijum sadrži SQL upite i izveštaj izrađene u okviru završnog projekta Data Engineering IT Bootcamp programa.

Projekat je podeljen na sledeće delove:

- **Deo A:** SQL upiti (`part_a.sql`)
- **Deo B:** SQL upiti (`part_b.sql`) i izveštaj (`report.md`)
- **Deo C:** SQL upiti (`part_v.sql`)
- **Deo D:** Modelovanje zvezdaste šeme za analizu kartona (`part_d.sql`)
- **Deo E:** Analiza zvezdaste šeme kartona (`part_d.sql`)

---
***

# Part_d -  Zadatak 4
## Model: zvezda za disciplinu

Model je zvezdasta šema sa tabelom `fact_card` u centru i četiri dimenzije oko nje: `dim_team`, `dim_date`, `dim_player` i `dim_referee`.

**Jedan red u `fact_card` je jedan karton** (događaj tipa `yellow_card`, `second_yellow` ili `red_card` iz `match_events`). Tabela ima 2.678 redova, koliko ima i kartonskih događaja.

**Ključevi:**
- `event_id` je primarni ključ, jedinstveno identifikuje karton.
- `team_id` vodi na `dim_team`, klub igrača koji je dobio karton.
- `player_id` vodi na `dim_player`. Događaji sa igračem kog nema u `players`
- `referee_id` vodi na `dim_referee`, sudija te utakmice.
- `date_key` vodi na `dim_date`, datum utakmice.
- `match_id` je samo identifikator utakmice.

**Zašto kartoni imaju svoju tabelu činjenica:** karton je poseban događaj koji se dešava u određenom trenutku i vezan je za više stvari odjednom (igrača, klub, sudiju i datum). S obzirom da ih često posmatramo iz sva četiri ugla, zato je najbolje da svaki karton bude jedan red. Tako se jednostavnim spajanjem i grupisanjem dobija broj kartona po sudiji, klubu, igraču ili datumu, bez dodatnog računanja u `match_events`, gde su pomešani i golovi, izmene i ostali događaji.