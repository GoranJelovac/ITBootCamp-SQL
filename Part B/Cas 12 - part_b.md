# Part_b

## Sezona 2024/25 u brojkama

### 1. Pregled sezone: broj utakmica i golova, prosečan broj golova po utakmici, udeo pobeda domaćina, nerešenih i pobeda gostiju.

```sql
SELECT
    COUNT(match_id) AS total_matches,
    SUM(home_goals + away_goals) AS total_goals,
    ROUND(AVG(home_goals + away_goals), 2) AS avg_goals_per_match,
    ROUND(COUNT_IF(home_goals > away_goals) / total_matches * 100, 2) AS home_win_pct,
    ROUND(COUNT_IF(home_goals = away_goals) / total_matches * 100, 2) AS draw_pct,
    ROUND(COUNT_IF(home_goals < away_goals) / total_matches * 100, 2) AS away_win_pct
FROM itbootcamp.northern_star.matches
WHERE season = '2024/25'
    AND status = 'played';
```
| total_matches | total_goals | avg_goals_per_match | home_win_pct | draw_pct | away_win_pct |
|---------------|-------------|---------------------|--------------|----------|--------------|
| 380           | 1092        | 2.87                | 41.32        | 25       | 33.68        |

---

### 2. Po mesecima: broj utakmica i golova po mesecima, i prosečan broj golova po utakmici u svakom mesecu. Koji mesec se izdvaja?

```sql
SELECT
    DATE_FORMAT(kickoff_ts, 'MM') AS kickoff_month,
    COUNT(match_id) AS total_matches,
    SUM(home_goals + away_goals) AS total_goals,
    ROUND(AVG(home_goals + away_goals), 2) AS avg_goals_per_match
FROM itbootcamp.northern_star.matches 
WHERE season = '2024/25'
    AND status = 'played'
GROUP BY kickoff_month
ORDER BY kickoff_month;
```

---

### 3. Publika: prosečna poseta i popunjenost po stadionu; utakmice bez podatka o poseti i utakmica bez publike.

#### 3.1 Stadioni sa podacima
```sql
SELECT
    s.stadium_name,
    s.capacity,
    ROUND(AVG(m.attendance), 2) AS avg_attendance,
    ROUND(AVG(m.attendance) / s.capacity * 100, 2) AS occupacy_pct
FROM itbootcamp.northern_star.matches AS m
JOIN itbootcamp.northern_star.stadiums AS s
    ON m.stadium_id = s.stadium_id
WHERE m.season = '2024/25'
    AND m.status = 'played'
GROUP BY s.stadium_id, s.stadium_name, s.capacity
ORDER BY occupacy_pct DESC;
```

#### 3.2 Stadioni bez podataka
```sql
SELECT
    match_id,
    DATE_FORMAT(kickoff_ts, 'dd/MM/y') AS kickoff_date,
    attendance
FROM itbootcamp.northern_star.matches
WHERE season = '2024/25'
    AND status = 'played'
    AND attendance IS NULL;
```
- 9 utakmica bez podataka o publici.

#### 3.3 Stadioni bez podataka
```sql
SELECT
    match_id,
    DATE_FORMAT(kickoff_ts, 'dd/MM/y') AS kickoff_date,
    attendance
FROM itbootcamp.northern_star.matches
WHERE season = '2024/25'
    AND status = 'played'
    AND attendance = 0;
```
- Nema utakmice bez gledalaca u 2024/25

---

### 4. Sudije: za svakog sudiju broj utakmica i kartoni po utakmici.

```sql
SELECT DISTINCT event_type FROM itbootcamp.northern_star.match_events;

WITH cards_per_match AS (
    SELECT
        me.match_id,
        COUNT(me.event_id) AS total_cards
    FROM itbootcamp.northern_star.match_events AS me
    WHERE me.event_type IN('yellow_card', 'second_yellow', 'red_card')
    GROUP BY match_id
)
SELECT
    r.referee_name,
    COUNT(m.match_id) AS total_matches,
    COALESCE(SUM(cpm.total_cards), 0) AS total_cards,
    ROUND(AVG(COALESCE(cpm.total_cards, 0)), 2) AS cards_per_match
FROM itbootcamp.northern_star.matches AS m
JOIN itbootcamp.northern_star.referees AS r
    ON m.referee_id = r.referee_id
LEFT JOIN cards_per_match AS cpm
    ON m.match_id = cpm.match_id
WHERE m.season = '2024/25'
    AND m.status = 'played'
GROUP BY r.referee_id, r.referee_name
ORDER BY cards_per_match DESC;
```
| referee_name   | total_matches | total_cards | cards_per_match |
|----------------|---------------|-------------|-----------------|
| Peter Lindgren | 20            | 85          | 4.25            |

---

### 5. Igrači: pet najboljih strelaca i pet najboljih asistenata.

#### 5.1 Najbolji strelci
```sql
SELECT
    p.first_name,
    p.last_name,
    COUNT(me.event_id) AS total_goals
FROM itbootcamp.northern_star.match_events AS me
JOIN itbootcamp.northern_star.matches AS m
    ON me.match_id = m.match_id
JOIN itbootcamp.northern_star.players AS p
    ON me.player_id = p.player_id
WHERE m.season = '2024/25'
    AND m.status = 'played'
    AND me.event_type IN ('goal', 'penalty_goal')
GROUP BY p.player_id, p.first_name, p.last_name
ORDER BY total_goals DESC;
```
| first_name | last_name | total_goals |
|------------|-----------|-------------|
| Mattéo     | O'Brien   | 34          |
| Leo        | Marsh     | 32          |
| José       | Muñoz     | 24          |
| Marko      | Stanković | 17          |
| Leo        | Marsh     | 16          |

#### 5.2 Najbolji Asistenti
```sql
SELECT
    p.first_name,
    p.last_name,
    COUNT(me.event_id) AS total_assists
FROM itbootcamp.northern_star.match_events AS me
JOIN itbootcamp.northern_star.matches AS m
    ON me.match_id = m.match_id
JOIN itbootcamp.northern_star.players AS p
    ON me.related_player_id = p.player_id
WHERE m.season = '2024/25'
    AND m.status = 'played'
    AND me.event_type = 'goal'
    AND me.related_player_id IS NOT NULL
GROUP BY p.player_id, p.first_name, p.last_name
ORDER BY total_assists DESC;
```
| first_name | last_name | total_assists |
|------------|-----------|---------------|
| Pablo      | Fernández | 9             |
| Filip      | Petrović  | 7             |
| Lucas      | Pereira   | 7             |
| Eirik      | Solberg   | 7             |
| Mikkel     | Nielsen   | 6             |

---

### 6. Kvalitet podataka: bar dva problema na koja ste naišli u podacima (na primer utakmica čiji rezultat se ne slaže sa događajima, događaji sa nepostojećim igračem, dan bez trenera), sa upitima koji ih pronalaze

#### 6.1 Podaci o sudijama
```sql
SELECT 
    *
FROM itbootcamp.northern_star.referees;
```
- Sve sudije sem Paul Tierney-Ross imaju lose podatke o debut_season koloni.

#### 6.2 Dogadjaji sa nepostojecim igracem
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
- Zuti kartoni za player_id 9999 kojeg nema u players.
