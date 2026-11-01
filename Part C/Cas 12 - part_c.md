# Part_c

### 1. Koliki udeo u ukupnom broju golova lige u sezoni 2024/25 ima svaki klub? Ko ima najveći udeo?

```sql
WITH team_goals AS(
    SELECT 
        tm.team_id,
        SUM(tm.goals_for) AS total_goals
    FROM itbootcamp.northern_star.team_matches AS tm
    WHERE tm.season = '2024/25'
    GROUP BY tm.team_id
)
SELECT
    t.team_name,
    tg.total_goals,
    ROUND(100 * tg.total_goals / SUM(tg.total_goals) OVER(), 2) AS goals_share_pct
FROM team_goals AS tg
JOIN itbootcamp.northern_star.teams AS t
    ON tg.team_id = t.team_id
ORDER BY goals_share_pct DESC;
```
- Najveci udeo ima Kingsbridge City sa 83 gola i 7,6%.

---

### 2. Koja su tri stadiona sa najvećom prosečnom posetom u sezoni 2024/25?

```sql
WITH stadium_attendance AS (
    SELECT
        s.stadium_name,
        ROUND(AVG(m.attendance), 2) AS avg_attendance
    FROM itbootcamp.northern_star.matches AS m
    JOIN itbootcamp.northern_star.stadiums AS s
        ON m.stadium_id = s.stadium_id
    WHERE m.season = '2024/25'
        AND m.status = 'played'
    GROUP BY s.stadium_id, s.stadium_name
)
SELECT
    sa.stadium_name,
    sa.avg_attendance,
    ROW_NUMBER() OVER(ORDER BY sa.avg_attendance DESC) AS stadium_rank
FROM stadium_attendance AS sa
QUALIFY stadium_rank <= 3
ORDER BY stadium_rank;
```
| stadium_name        | avg_attendance | stadium_rank |
|---------------------|----------------|--------------|
| Harbourside Park    | 44074.05       | 1            |
| Kingsbridge Stadium | 37968.42       | 2            |
| Northport Arena     | 36250.17       | 3            |

---

### 3. Za svaki klub, ko je dao poslednji gol kluba u sezoni 2024/25 i kada? Koji klub je poslednji gol dao najranije?

```sql
WITH last_goal AS (
    SELECT
        t.team_name,
        p.first_name,
        p.last_name,
        DATE_FORMAT(m.kickoff_ts, 'dd/MM/y') AS kickoff_date,
        me.minute,
        ROW_NUMBER() OVER(
            PARTITION BY me.team_id
            ORDER BY m.kickoff_ts DESC, me.minute DESC, me.event_id DESC
        ) rn
    FROM itbootcamp.northern_star.match_events AS me
    JOIN itbootcamp.northern_star.matches AS m
        ON me.match_id = m.match_id
    JOIN itbootcamp.northern_star.players AS p
        ON me.player_id = p.player_id
    JOIN itbootcamp.northern_star.teams AS t
        ON me.team_id = t.team_id
    WHERE m.season = '2024/25'
        AND m.status = 'played'
        AND me.event_type IN ('goal', 'penalty_goal')
)
SELECT
    lg.team_name,
    lg.first_name,
    lg.last_name,
    lg.kickoff_date,
    lg.minute
FROM last_goal AS lg
WHERE lg.rn = 1
ORDER BY lg.kickoff_date ASC, lg.minute ASC;
```
- Poslednji gold je najranije dala ekipa Elmsworth Wanderers, igrac Marko Stanković, datum 03/05/2025 u 27 minutu.

---

### 4. Za domaće utakmice kluba Northport United u sezoni 2024/25 prikažite posetu i promenu u odnosu na prethodnu domaću utakmicu. Gde je najveći pad?

```sql
WITH home_matches AS (
    SELECT
        m.match_id,
        DATE_FORMAT(m.kickoff_ts, 'dd/MM/y') AS kickoff_date,
        m.attendance,
        LAG(m.attendance) OVER (
            ORDER BY m.kickoff_ts, m.match_id
        ) AS previous_attendance
    FROM itbootcamp.northern_star.matches AS m
    JOIN itbootcamp.northern_star.teams AS t
        ON m.home_team_id = t.team_id
    WHERE t.team_name = 'Northport United'
        AND m.season = '2024/25'
        AND m.status = 'played'
)
SELECT
    hm.match_id,
    hm.kickoff_date,
    hm.attendance,
    hm.previous_attendance,
    hm.attendance - hm.previous_attendance AS attendance_change
FROM home_matches AS hm
ORDER BY attendance_change;
```
- Najveci pad je bio 10/11/2024 na utakmici broj ID = 2078, kada je sa 49419 gledanost pala na 39152 odnosno za 10267 gledalaca.

---

### 5. Pratite bodove kluba Northport City utakmicu po utakmicu u sezoni 2024/25. U kojoj utakmici po redu i kog datuma je prešao 50 bodova?

```sql
WITH cumulative_points AS (
    SELECT
        tm.match_id,
        DATE_FORMAT(tm.kickoff_ts, 'dd/MM/y') AS kickoff_date,
        ROW_NUMBER() OVER(
            ORDER BY tm.kickoff_ts, tm.match_id
        ) AS match_number,
        tm.points,
        SUM(tm.points) OVER(
            ORDER BY tm.kickoff_ts, tm.match_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS total_points
    FROM itbootcamp.northern_star.team_matches AS tm
    JOIN itbootcamp.northern_star.teams AS t
        ON tm.team_id = t.team_id
    WHERE t.team_name = 'Northport City'
        AND tm.season = '2024/25'
)
SELECT
    cp.match_number,
    cp.match_id,
    cp.kickoff_date,
    cp.points,
    cp.total_points
FROM cumulative_points AS cp
WHERE cp.total_points > 50
ORDER BY cp.match_number;
```
- Northport City je presao 50 poena na utakmici redni broj 21, match_id = 2210, datum utakmice je 12/01/2025.
