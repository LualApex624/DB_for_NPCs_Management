-- ============================================================
-- PROJECT   : Fantasy NPC Database (DB_FOR_PNJ)
-- AUTHOR    : Paul-Alex Yao — EFREI Paris
-- VERSION   : 2.0 (Professional Edition)
-- FILE      : Data Exploration & Analytics
-- ============================================================

USE `fantasy_npcs`;

-- ============================================================
-- SECTION 1 — BASIC FILTERING
-- ============================================================

-- 1.1 All NPCs sorted alphabetically
SELECT nom_pnj, race, classe, niveau
FROM PNJ
ORDER BY nom_pnj ASC;

-- 1.2 NPCs of a given class (parameterisable example: 'Mage')
SELECT nom_pnj, race, niveau
FROM PNJ
WHERE classe = 'Mage'
ORDER BY niveau DESC;

-- 1.3 NPCs with vitality above 200 (elite / divine tier)
SELECT nom_pnj, race, classe, vitalite
FROM PNJ
WHERE vitalite > 200
ORDER BY vitalite DESC;

-- 1.4 Quests with difficulty below 3, sorted ascending
SELECT nom_quete, type_quete, difficulte
FROM Quete
WHERE difficulte < 3
ORDER BY difficulte ASC, nom_quete ASC;

-- 1.5 How many quests does a specific NPC participate in?
SELECT
    p.nom_pnj,
    COUNT(i.id_quete) AS nombre_interventions
FROM PNJ p
LEFT JOIN Intervenir i ON p.id_pnj = i.id_pnj
WHERE p.nom_pnj = 'Elyndor'
GROUP BY p.id_pnj, p.nom_pnj;


-- ============================================================
-- SECTION 2 — JOINS
-- ============================================================

-- 2.1 NPCs involved in a specific quest with their roles
SELECT
    p.nom_pnj,
    p.race,
    i.role_pnj,
    l.lieu        AS localisation
FROM PNJ p
JOIN Intervenir i ON p.id_pnj   = i.id_pnj
JOIN Quete      q ON i.id_quete = q.id_quete
JOIN Localisation l ON p.id_localisation = l.id_localisation
WHERE q.nom_quete = 'L\'appel du destin'
ORDER BY i.role_pnj;

-- 2.2 Alchemist NPCs above level 20 with their location
SELECT
    r.nom_region,
    l.lieu,
    p.nom_pnj,
    p.niveau
FROM PNJ p
JOIN Localisation l ON p.id_localisation = l.id_localisation
JOIN Region       r ON l.id_region       = r.id_region
WHERE p.metier = 'Alchimiste'
  AND p.niveau > 20
ORDER BY p.niveau DESC;

-- 2.3 NPCs in 'Eldoria' above level 30
SELECT
    p.nom_pnj,
    p.race,
    p.classe,
    p.niveau,
    l.lieu
FROM PNJ p
JOIN Localisation l ON p.id_localisation = l.id_localisation
JOIN Region       r ON l.id_region       = r.id_region
WHERE r.nom_region = 'Eldoria'
  AND p.niveau > 30
ORDER BY p.niveau DESC;

-- 2.4 Distinct quests involving at least one Elf NPC
SELECT DISTINCT
    q.nom_quete,
    q.type_quete,
    q.difficulte
FROM Quete q
JOIN Intervenir i ON q.id_quete = i.id_quete
JOIN PNJ        p ON i.id_pnj   = p.id_pnj
WHERE p.race = 'Elfe'
ORDER BY q.difficulte DESC;

-- 2.5 NPCs with no quest participation (LEFT JOIN anti-pattern)
SELECT
    p.nom_pnj,
    p.race,
    p.classe,
    p.niveau
FROM PNJ p
LEFT JOIN Intervenir i ON p.id_pnj = i.id_pnj
WHERE i.id_quete IS NULL
ORDER BY p.niveau DESC;

-- 2.6 NPCs in difficulty-5 quests with their region
SELECT
    p.nom_pnj,
    p.race,
    i.role_pnj,
    q.nom_quete,
    r.nom_region
FROM PNJ p
JOIN Intervenir i  ON p.id_pnj   = i.id_pnj
JOIN Quete      q  ON i.id_quete = q.id_quete
JOIN Localisation l ON p.id_localisation = l.id_localisation
JOIN Region       r ON l.id_region       = r.id_region
WHERE q.difficulte = 5
ORDER BY p.nom_pnj;


-- ============================================================
-- SECTION 3 — AGGREGATION & GROUP BY
-- ============================================================

-- 3.1 Average vitality per race
SELECT
    race,
    COUNT(*)                              AS effectif,
    ROUND(AVG(vitalite), 1)              AS vitalite_moyenne,
    MAX(vitalite)                         AS vitalite_max,
    ROUND(AVG(niveau), 1)                AS niveau_moyen
FROM PNJ
GROUP BY race
ORDER BY vitalite_moyenne DESC;

-- 3.2 Number of NPCs per quest, sorted descending
SELECT
    q.nom_quete,
    q.type_quete,
    q.difficulte,
    COUNT(i.id_pnj) AS nb_pnj
FROM Quete q
LEFT JOIN Intervenir i ON q.id_quete = i.id_quete
GROUP BY q.id_quete, q.nom_quete, q.type_quete, q.difficulte
ORDER BY nb_pnj DESC;

-- 3.3 Races with more than 5 NPCs
SELECT
    race,
    COUNT(*) AS nombre_pnj
FROM PNJ
GROUP BY race
HAVING COUNT(*) > 5
ORDER BY nombre_pnj DESC;

-- 3.4 Maximum strength stat per race
SELECT
    race,
    MAX(force_stat)  AS force_max,
    MAX(sagesse)     AS sagesse_max,
    MAX(agilite)     AS agilite_max
FROM PNJ
GROUP BY race
ORDER BY force_max DESC;

-- 3.5 Role distribution across all quest interventions
SELECT
    role_pnj,
    COUNT(*) AS occurrences,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct
FROM Intervenir
GROUP BY role_pnj
ORDER BY occurrences DESC;


-- ============================================================
-- SECTION 4 — NEGATION / EXCLUSION
-- ============================================================

-- 4.1 NPCs who have never been a quest giver
SELECT p.nom_pnj, p.race, p.classe
FROM PNJ p
WHERE NOT EXISTS (
    SELECT 1
    FROM Intervenir i
    WHERE i.id_pnj  = p.id_pnj
      AND i.role_pnj = 'Donneur de quête'
)
ORDER BY p.nom_pnj;

-- 4.2 NPCs who never participated in a side quest ('Annexe')
SELECT p.nom_pnj, p.race
FROM PNJ p
WHERE NOT EXISTS (
    SELECT 1
    FROM Intervenir i
    JOIN Quete q ON i.id_quete = q.id_quete
    WHERE i.id_pnj     = p.id_pnj
      AND q.type_quete = 'Annexe'
)
ORDER BY p.nom_pnj;

-- 4.3 NPCs who never faced a difficulty-5 quest
SELECT p.nom_pnj, p.race, p.niveau
FROM PNJ p
WHERE NOT EXISTS (
    SELECT 1
    FROM Intervenir i
    JOIN Quete q ON i.id_quete = q.id_quete
    WHERE i.id_pnj    = p.id_pnj
      AND q.difficulte = 5
)
ORDER BY p.niveau DESC;


-- ============================================================
-- SECTION 5 — RELATIONAL DIVISION
-- ============================================================

-- 5.1 NPCs who participated in ALL main quests ('Principale')
SELECT p.nom_pnj
FROM PNJ p
WHERE NOT EXISTS (
    SELECT q.id_quete
    FROM Quete q
    WHERE q.type_quete = 'Principale'
      AND NOT EXISTS (
          SELECT 1
          FROM Intervenir i
          WHERE i.id_quete = q.id_quete
            AND i.id_pnj   = p.id_pnj
      )
);

-- 5.2 NPCs who participated in all quests where 'Elyndor' intervened
SELECT p.nom_pnj
FROM PNJ p
WHERE p.nom_pnj <> 'Elyndor'
  AND NOT EXISTS (
    SELECT i_ref.id_quete
    FROM Intervenir i_ref
    WHERE i_ref.id_pnj = (SELECT id_pnj FROM PNJ WHERE nom_pnj = 'Elyndor')
      AND NOT EXISTS (
          SELECT 1
          FROM Intervenir i2
          WHERE i2.id_quete = i_ref.id_quete
            AND i2.id_pnj   = p.id_pnj
      )
  );


-- ============================================================
-- SECTION 6 — ADVANCED ANALYTICS (CTEs & Window Functions)
-- ============================================================

-- 6.1 NPC ranking by level within each race
SELECT
    race,
    nom_pnj,
    niveau,
    RANK() OVER (PARTITION BY race ORDER BY niveau DESC) AS rang_dans_race
FROM PNJ
ORDER BY race, rang_dans_race;

-- 6.2 CTE — Average stats per class, compared to global average
WITH class_stats AS (
    SELECT
        classe,
        ROUND(AVG(vitalite),   1) AS avg_vitalite,
        ROUND(AVG(force_stat), 1) AS avg_force,
        ROUND(AVG(sagesse),    1) AS avg_sagesse,
        ROUND(AVG(agilite),    1) AS avg_agilite
    FROM PNJ
    GROUP BY classe
),
global_avg AS (
    SELECT
        ROUND(AVG(vitalite),   1) AS g_vitalite,
        ROUND(AVG(force_stat), 1) AS g_force,
        ROUND(AVG(sagesse),    1) AS g_sagesse,
        ROUND(AVG(agilite),    1) AS g_agilite
    FROM PNJ
)
SELECT
    c.classe,
    c.avg_vitalite,
    ROUND(c.avg_vitalite - g.g_vitalite, 1) AS delta_vitalite,
    c.avg_force,
    ROUND(c.avg_force    - g.g_force,    1) AS delta_force,
    c.avg_sagesse,
    ROUND(c.avg_sagesse  - g.g_sagesse,  1) AS delta_sagesse,
    c.avg_agilite,
    ROUND(c.avg_agilite  - g.g_agilite,  1) AS delta_agilite
FROM class_stats c
CROSS JOIN global_avg g
ORDER BY c.avg_vitalite DESC;

-- 6.3 CTE — Quest difficulty distribution with cumulative percentage
WITH diff_count AS (
    SELECT
        difficulte,
        COUNT(*) AS nb_quetes
    FROM Quete
    GROUP BY difficulte
)
SELECT
    difficulte,
    nb_quetes,
    ROUND(nb_quetes * 100.0 / SUM(nb_quetes) OVER (), 1)       AS pct,
    SUM(nb_quetes) OVER (ORDER BY difficulte)                    AS cumul
FROM diff_count
ORDER BY difficulte;

-- 6.4 NPCs with above-average strength for their race (correlated subquery)
SELECT
    p.nom_pnj,
    p.race,
    p.force_stat,
    ROUND(avg_race.avg_force, 1) AS force_moyenne_race
FROM PNJ p
JOIN (
    SELECT race, AVG(force_stat) AS avg_force
    FROM PNJ
    GROUP BY race
) avg_race ON p.race = avg_race.race
WHERE p.force_stat > avg_race.avg_force
ORDER BY p.race, p.force_stat DESC;

-- 6.5 NPC activity score: weighted combination of quests and role severity
WITH pnj_score AS (
    SELECT
        p.nom_pnj,
        p.race,
        p.classe,
        COUNT(i.id_quete) AS nb_quetes,
        SUM(
            CASE i.role_pnj
                WHEN 'Boss'            THEN 5
                WHEN 'Ennemi'          THEN 3
                WHEN 'Allié'           THEN 2
                WHEN 'Donneur de quête'THEN 2
                WHEN 'Marchand'        THEN 1
                ELSE 0
            END
        ) AS score_activite
    FROM PNJ p
    LEFT JOIN Intervenir i ON p.id_pnj = i.id_pnj
    GROUP BY p.id_pnj, p.nom_pnj, p.race, p.classe
)
SELECT
    nom_pnj,
    race,
    classe,
    nb_quetes,
    score_activite,
    DENSE_RANK() OVER (ORDER BY score_activite DESC) AS classement
FROM pnj_score
ORDER BY classement
LIMIT 10;

-- 6.6 Quests with no NPC assigned (data quality check)
SELECT
    q.id_quete,
    q.nom_quete,
    q.type_quete,
    q.difficulte
FROM Quete q
LEFT JOIN Intervenir i ON q.id_quete = i.id_quete
WHERE i.id_pnj IS NULL
ORDER BY q.difficulte DESC;

-- 6.7 Geographic distribution — NPCs per region and contree
SELECT
    r.nom_region,
    l.contree,
    COUNT(p.id_pnj)           AS nb_pnj,
    ROUND(AVG(p.niveau), 1)  AS niveau_moyen,
    MAX(p.niveau)             AS niveau_max
FROM Region r
JOIN Localisation l ON r.id_region       = l.id_region
LEFT JOIN PNJ     p ON l.id_localisation = p.id_localisation
GROUP BY r.nom_region, l.contree
ORDER BY r.nom_region, nb_pnj DESC;


-- ============================================================
-- SECTION 7 — STORED PROCEDURE CALLS (demo)
-- ============================================================

-- Get all NPCs in 'Valoria' with their quest count
CALL sp_pnj_par_region('Valoria');

-- Get top 5 most involved NPCs
CALL sp_top_pnj(5);


-- ============================================================
-- SECTION 8 — VIEWS USAGE (demo)
-- ============================================================

-- Full NPC profiles
SELECT * FROM v_pnj_profil ORDER BY niveau DESC LIMIT 10;

-- Quest overview with participation counts
SELECT * FROM v_quete_details ORDER BY nb_pnj_impliques DESC;

-- NPC participation breakdown
SELECT * FROM v_pnj_participation ORDER BY nb_quetes DESC LIMIT 10;
