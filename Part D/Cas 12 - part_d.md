# Part_d

### 1. Pravljenje dim_team tabele

```sql
CREATE OR REPLACE TABLE itbootcamp.northern_star.dim_team AS 
SELECT * FROM itbootcamp.northern_star.teams;
```

---

### 2. dim_date

#### 2.1 Najranija i najkasnija utakmica
```sql
SELECT
    MIN(kickoff_ts) AS earliest_match,
    MAX(kickoff_ts) AS latest_match
FROM itbootcamp.northern_star.matches;
```

#### 2.2 Pravljenje dim_date tabele
```sql
CREATE OR REPLACE TABLE itbootcamp.northern_star.dim_date AS
SELECT
    CAST(DATE_FORMAT(d, 'yyyyMMdd') AS INT) AS date_key,
    d AS full_date,
    DATE_FORMAT(d, 'EEEE') AS weekday_name,
    DAYOFWEEK(d) IN (1, 7) AS is_weekend,
    CASE
        WHEN MONTH(d) >= 7 THEN CONCAT(YEAR(d), '/', SUBSTRING(CAST(YEAR(d) + 1 AS STRING), 3, 2))
        ELSE CONCAT(YEAR(d) - 1, '/', SUBSTRING(CAST(YEAR(d) AS STRING), 3, 2))
    END AS season
FROM (
    SELECT EXPLODE(SEQUENCE(DATE'2023-08-11', DATE'2025-05-19', INTERVAL 1 DAY)) AS d
);
```

---

### 3. dim player

#### 3.1 Pravljenje dim_player tabele
```sql
CREATE OR REPLACE TABLE itbootcamp.northern_star.dim_player AS 
SELECT * FROM itbootcamp.northern_star.players;
```

#### 3.2 Dodavanje nepoznatog igraca
```sql
INSERT INTO itbootcamp.northern_star.dim_player
    (player_id, first_name, last_name)
VALUES
    (-1, 'Unknown', 'Player');
```

#### 3.3 Provera dim_player tabele
```sql
SELECT * 
FROM itbootcamp.northern_star.dim_player
WHERE player_id = -1;
```

---

### 4. dim_referee

#### 4.1 Pravljenje dim_referee tabele
```sql
CREATE OR REPLACE TABLE itbootcamp.northern_star.dim_referee AS
SELECT *
FROM itbootcamp.northern_star.referees;
```

#### 4.2 Provera dim_referee tabele
```sql
SELECT *
FROM itbootcamp.northern_star.dim_referee;
```

---

### 5 Pravljenje fact_card

#### 5.1 Pravljenje fact_card tabele

```sql
CREATE OR REPLACE TABLE itbootcamp.northern_star.fact_card AS 
SELECT
    me.event_id,
    me.match_id,
    dd.date_key,
    me.team_id,
    COALESCE(p.player_id, -1) AS player_id,
    m.referee_id,
    me.event_type AS card_type
FROM itbootcamp.northern_star.match_events AS me
JOIN itbootcamp.northern_star.matches AS m
    ON me.match_id = m.match_id
JOIN itbootcamp.northern_star.dim_date AS dd
    ON dd.full_date = DATE(m.kickoff_ts)
LEFT JOIN itbootcamp.northern_star.players AS p
    ON me.player_id = p.player_id
WHERE me.event_type IN ('yellow_card', 'second_yellow', 'red_card');
```

#### 5.2 Provera fact_card tabele
```sql
SELECT *
FROM itbootcamp.northern_star.fact_card;
````
