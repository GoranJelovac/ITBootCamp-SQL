# Part_d -  Zadatak 4
## Model: zvezda za disciplinu

Model je zvezdasta šema sa tabelom `fact_card` u centru i četiri dimenzije oko nje: `dim_team`, `dim_date`, `dim_player` i `dim_referee`.

**Jedan red u `fact_card` je jedan karton** (događaj tipa `yellow_card`, `second_yellow` ili `red_card` iz `match_events`). Tabela ima 2.678 redova, koliko ima i kartonskih događaja.

**Ključevi:**
- `event_id` je primarni ključ, jedinstveno identifikuje karton.
- `team_id` vodi na `dim_team`, klub igrača koji je dobio karton.
- `player_id` vodi na `dim_player`. Događaji sa igračem kog nema u `players` (njih 2, `player_id = 99999`) dobijaju `player_id = -1`, pa se vezuju za član "nepoznat" i ne gube se.
- `referee_id` vodi na `dim_referee`, sudija te utakmice.
- `date_key` vodi na `dim_date`, datum utakmice.
- `match_id` je samo identifikator utakmice (nema svoju dimenziju), a vrsta kartona je običan opis u samoj činjeničnoj tabeli.

**Zašto kartoni imaju svoju tabelu činjenica:** karton je poseban događaj koji se dešava u određenom trenutku i vezan je za više entiteta odjednom (igrača, klub, sudiju i datum). Uprava lige želi da ih posmatra iz sva četiri ugla, i zato je najbolje da svaki karton bude jedan red, a dimenzije daju kontekst. Tako se jednostavnim spajanjem i grupisanjem dobija broj kartona po sudiji, klubu, igraču ili datumu, bez dodatnog računanja u `match_events`, gde su pomešani i golovi, izmene i ostali događaji.