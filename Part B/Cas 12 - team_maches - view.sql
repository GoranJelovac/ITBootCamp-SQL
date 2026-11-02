-- Pravljenje novog View-a team_matches
CREATE OR REPLACE VIEW itbootcamp.northern_star.team_matches AS 
WITH sides AS (
    SELECT 
        match_id,
        season,
        matchday,
        kickoff_ts,
        home_team_id AS team_id,
        away_team_id AS opponent_id,
        'home' AS venue,
        home_goals AS goals_for,
        away_goals AS goals_against
    FROM itbootcamp.northern_star.matches 
    WHERE status = 'played'

    UNION ALL

    SELECT 
        match_id,
        season,
        matchday,
        kickoff_ts,
        away_team_id,
        home_team_id,
        'away',
        away_goals,
        home_goals
    FROM itbootcamp.northern_star.matches 
    WHERE status = 'played'
)
SELECT 
    *,
    CASE 
        WHEN goals_for > goals_against THEN 'W'
        WHEN goals_for = goals_against THEN 'D' 
        ELSE 'L' 
    END AS result,
    CASE
        WHEN goals_for > goals_against THEN 3
        WHEN goals_for = goals_against THEN 1 
        ELSE 0 
    END AS points
FROM sides;