# Part_a

### 1. Koliko utakmica je odigrano u februaru 2025?

```sql
SELECT
    COUNT(match_id) AS total_matches
FROM itbootcamp.northern_star.matches
WHERE status = 'played'
    AND kickoff_ts >= '2025-02-01'
    AND kickoff_ts < '2025-03-01';
```
- 40 utakmica.

---

### 2. Koji stadion ima najveći kapacitet, a koji je najveći stadion nekog kluba?

#### 2.1 Svi stadioni
```sql
SELECT 
    stadium_name,
    capacity
FROM itbootcamp.northern_star.stadiums
ORDER BY capacity DESC;
```
| stadium_name     | capacity | team_name |
|------------------|----------|-----------|
| National Stadium | 80000    | /         |

#### 2.2 Stadion kluba
```sql
SELECT 
    s.stadium_name,
    s.capacity,
    t.team_name
FROM itbootcamp.northern_star.stadiums AS s
JOIN itbootcamp.northern_star.teams AS t
    ON s.stadium_id = t.stadium_id
ORDER BY s.capacity DESC;
```
| stadium_name    | capacity | team_name        |
|-----------------|----------|------------------|
| Harbourside Park | 52000   | Northport United |

---

### 3. Koliko igrača u ligi ima srpsko državljanstvo (nationality = 'Serbia')?

```sql
SELECT DISTINCT nationality FROM itbootcamp.northern_star.players;

SELECT
    COUNT(player_id) AS total_players
FROM itbootcamp.northern_star.players
WHERE nationality = 'Serbia';
```
- 42 igraca.

---

### 4. Koliko utakmica je završeno rezultatom 1:1?

```sql
SELECT
    COUNT(match_id) AS total_matches
FROM itbootcamp.northern_star.matches
WHERE home_goals = 1 
    AND away_goals = 1;
```
- 94 utakmica.

---

### 5. Kolika je prosečna poseta po sezoni?

```sql
SELECT * FROM itbootcamp.northern_star.matches;

SELECT
    season,
    ROUND(AVG(attendance), 2) AS avg_attendance
FROM itbootcamp.northern_star.matches
WHERE status = 'played'
GROUP BY season
ORDER BY season;
```
| season  | avg_attendance |
|---------|----------------|
| 2023/24 | 24276.2        |
| 2024/25 | 24199.49       |

---

### 6. Koliko golova je dato iz penala po sezoni?

```sql
SELECT DISTINCT event_type FROM itbootcamp.northern_star.match_events;

SELECT
    m.season,
    COUNT(me.event_id) AS penalty_goal
FROM itbootcamp.northern_star.matches AS m
JOIN itbootcamp.northern_star.match_events AS me
    ON m.match_id = me.match_id
WHERE me.event_type = 'penalty_goal'
    AND m.status = 'played'
GROUP BY m.season
ORDER BY m.season;
```
| season  | penalty_goal |
|---------|--------------|
| 2023/24 | 104          |
| 2024/25 | 109          |

---

### 7. Koliko različitih igrača je dalo bar jedan gol u sezoni 2024/25?

```sql
SELECT
    COUNT(DISTINCT me.player_id) AS total_players
FROM itbootcamp.northern_star.match_events AS me
JOIN itbootcamp.northern_star.matches AS m
    ON me.match_id = m.match_id
WHERE m.season = '2024/25'
    AND m.status = 'played'
    AND me.event_type IN ('goal', 'penalty_goal');
```
- 308 igraca.

---

### 8. Koji sudija je najviše puta sudio utakmice kluba Northport United?

```sql
SELECT team_name FROM itbootcamp.northern_star.teams;

SELECT
    r.referee_name,
    COUNT(m.match_id) AS total_matches
FROM itbootcamp.northern_star.matches AS m
JOIN itbootcamp.northern_star.referees AS r
    ON m.referee_id = r.referee_id
JOIN itbootcamp.northern_star.teams AS t
    ON m.home_team_id = t.team_id
        OR m.away_team_id = t.team_id
WHERE t.team_name = 'Northport United'
    AND m.status = 'played'
GROUP BY r.referee_id, r.referee_name
ORDER BY total_matches DESC;
```
- Sudija Peter Lindgren je sudio 9 meceva.

---

### 9. Koji sudija je u sezoni 2024/25 imao najveći udeo utakmica u kojima je dosuđen bar jedan penal, dat ili promašen?

```sql
SELECT DISTINCT event_type FROM itbootcamp.northern_star.match_events;

WITH penalty_matches AS (
    SELECT DISTINCT
        match_id
    FROM itbootcamp.northern_star.match_events
    WHERE event_type IN ('penalty_miss', 'penalty_goal')
)
SELECT 
    r.referee_name,
    COUNT(m.match_id) AS total_matches,
    COUNT(pm.match_id) AS penalty_matches,
    ROUND(penalty_matches / total_matches * 100, 2) AS penalty_pct
FROM itbootcamp.northern_star.referees AS r
JOIN itbootcamp.northern_star.matches AS m
    ON r.referee_id = m.referee_id
LEFT JOIN penalty_matches AS pm
    ON m.match_id = pm.match_id
WHERE m.season = '2024/25'
    AND m.status = 'played'
GROUP BY r.referee_id, r.referee_name
ORDER BY penalty_pct DESC;
```
| referee_name   | total_matches | penalty_matches | penalty_pct |
|----------------|---------------|-----------------|-------------|
| Peter Lindgren | 20            | 9               | 45          |

---

### 10. Koji trener je osvojio najviše bodova u utakmicama u kojima je njegov tim gubio na poluvremenu? Računajte i domaće i gostujuće utakmice.

```sql
WITH teams_losing_ht AS (
    SELECT
        match_id,
        kickoff_ts,
        home_team_id AS team_id,
        home_goals AS goals_for,
        away_goals AS goals_against
    FROM itbootcamp.northern_star.matches
    WHERE status = 'played'
        AND home_goals_ht < away_goals_ht

    UNION ALL

    SELECT
        match_id,
        kickoff_ts,
        away_team_id AS team_id,
        away_goals AS goals_for,
        home_goals AS goals_against
    FROM itbootcamp.northern_star.matches
    WHERE status = 'played'
        AND away_goals_ht < home_goals_ht
)
SELECT
    ms.manager_name,
    SUM(
        CASE
            WHEN tlh.goals_for > tlh.goals_against THEN 3
            WHEN tlh.goals_for = tlh.goals_against THEN 1
            ELSE 0
        END
    ) AS total_points
FROM teams_losing_ht AS tlh
JOIN itbootcamp.northern_star.manager_spells AS ms
    ON tlh.team_id = ms.team_id
        AND DATE(tlh.kickoff_ts) BETWEEN ms.start_date
            AND COALESCE(ms.end_date, DATE'9999-12-31')
GROUP BY ms.manager_name
ORDER BY total_points DESC;
```
- Najvise je osvojio Zoran Tosic, 18 poena.
