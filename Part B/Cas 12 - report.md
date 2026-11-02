
# Izveštaj o sezoni 2024/25

## 1. Pregled sezone:

Sezona je bila vrlo zanimljiva sa skoro 3 gola po utakmici.

- Odigrane utakmice: **380**
- Ukupno golova: **1092**
- Prosečno golova po utakmici: **2.87**
- Procentualni pobednik domaćin: **41,32**
- Procentualno nerešnih utakmica: **25**
- Procentualni pobednik gost: **33,68**

## 2. Po mesecima:

Neki meseci su bili manje zanimljivi, neki više, ali je Avgust bio neprikosnoven sa čak **3,54 golova** po utakmici

| Mesec     | Broj utakmica | Ukupno golova | Prosek golova po utakmici |
|-----------|--------------:|--------------:|-------------------------:|
| Januar    | 51            | 137           | 2,69                     |
| Februar   | 40            | 119           | 2,98                     |
| Mart      | 40            | 113           | 2,83                     |
| April     | 40            | 124           | 3,10                     |
| Maj       | 30            | 79            | 2,63                     |
| Avgust    | 28            | 99            | 3,54                     |
| Septembar | 32            | 78            | 2,44                     |
| Oktobar   | 30            | 102           | 3,40                     |
| Novembar  | 37            | 96            | 2,59                     |
| Decembar  | 52            | 145           | 2,79                     |


## 3. Publika:

Najveću podršku je imao klub na stadionu **Elmsworth Lane** sa neverovatnom prosečnom posećenosti od preko 90%, dok je najviše gledalaca bilo na stadionu **Harbourside Park**.

Ukupno 9 utakmica bez podataka o posečenosti, dok su na svim zabeleženim utakmicama prisustvovali gledaoci.

## 4. Sudije:

Sve sudije su sudile po 20 utakmica. Najviše kartona je dodelio sudija Peter Lindgren, čak **85** kartona, u proseku **4,25** po utakmici, dok je najmanje dodelio Samuel Achebe, cak 30 manje.

## 5. Igrači

### Najbolji strelci

| Ime | Prezime | broj golova |
|---|---|---:|
| Mattéo | O'Brien | 34 |
| Leo | Marsh | 32 |
| José | Muñoz | 24 |
| Marko | Stanković | 17 |
| Leo | Marsh | 16 |

### Najbolji asistenti

| Ime | Prezime | broj golova |
|---|---|---:|
| Pablo | Fernández | 9 |
| Filip | Petrović | 7 |
| Lucas | Pereira | 7 |
| Eirik | Solberg | 7 |
| Mikkel | Nielsen | 6 |

## 6. Kvalitet podataka

Tokom analize identifikovana su dva problema sa kvalitetom podataka.

### 6.1. Neispravni podaci o debitantskoj sezoni sudija
```sql
SELECT *
FROM itbootcamp.northern_star.referees;
```

Pregledom tabele `referees` utvrđeno je da sve sudije, osim **Paul Tierney-Ross**, imaju neispravne podatke u koloni `debut_season`, što ukazuje na problem sa tačnošću podataka o njihovim debitantskim sezonama.

### 6.2. Događaji povezani sa nepostojećim igračem
```sql
SELECT
    me.event_id,
    me.match_id,
    me.minute,
    me.event_type,
    me.player_id
FROM itbootcamp.northern_star.match_events AS me
LEFT JOIN itbootcamp.northern_star.players AS p
    ON me.player_id = p.player_id
WHERE me.player_id IS NOT NULL
    AND p.player_id IS NULL;
```

Upitom su identifikovani događaji žutih kartona povezani sa `player_id = 9999`, koji ne postoji u tabeli `players`. Ovaj problem ukazuje na neusklađenost podataka između tabela match_events i players, jer se događaji odnose na igrača koji ne postoji u evidenciji igrača.
