-- 1. U part_d.sql napravite i napunite tabele
-- Uradjeno.

-- 2. Upitom pokažite da fact_card ima isto redova koliko ima kartonskih događaja
-- 2.1 Provera match_event
SELECT
    COUNT(*) AS total_cards
FROM itbootcamp.northern_star.match_events
WHERE event_type IN ('yellow_card', 'second_yellow', 'red_card');

-- 2.2 Provera fact_card
SELECT 
    COUNT(*) AS total_fact_cards
FROM itbootcamp.northern_star.fact_card;

-- 3. Koliko kartona ima player_id = -1?
SELECT
    COUNT(*) AS unkown_players_cards
FROM itbootcamp.northern_star.fact_card
WHERE player_id = -1;
-- 2 kartona.

-- 4. U README.md, u par rečenica opišite model: šta je jedan red u fact_card, koji su ključevi (veze) i zašto mislite da kartoni imaju svoju tabelu činjenica.
-- Upisano u Readme.md