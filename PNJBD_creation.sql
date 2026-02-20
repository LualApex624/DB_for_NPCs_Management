-- ============================================================
-- PROJECT   : Fantasy NPC Database (DB_FOR_PNJ)
-- AUTHOR    : Paul-Alex Yao — EFREI Paris
-- VERSION   : 2.0 (Professional Edition)
-- DESCRIPTION: Relational database for managing NPCs, quests,
--              locations and extensions in a fantasy video game.
-- ============================================================

DROP SCHEMA IF EXISTS `fantasy_npcs`;
CREATE SCHEMA `fantasy_npcs`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `fantasy_npcs`;

-- ============================================================
-- TABLE: Region
-- Purpose: Top-level geographic grouping
-- ============================================================
CREATE TABLE Region (
    id_region     INT           NOT NULL AUTO_INCREMENT,
    nom_region    VARCHAR(50)   NOT NULL UNIQUE,
    description   VARCHAR(255),
    PRIMARY KEY (id_region)
);

-- ============================================================
-- TABLE: Localisation
-- Purpose: Fine-grained geographic location for NPCs
-- ============================================================
CREATE TABLE Localisation (
    id_localisation  INT          NOT NULL AUTO_INCREMENT,
    id_region        INT          NOT NULL,
    contree          VARCHAR(50)  NOT NULL,
    lieu             VARCHAR(50)  NOT NULL UNIQUE,
    PRIMARY KEY (id_localisation),
    CONSTRAINT fk_loc_region
        FOREIGN KEY (id_region) REFERENCES Region (id_region)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Index for frequent region-based filtering
CREATE INDEX idx_localisation_region ON Localisation (id_region);

-- ============================================================
-- TABLE: Extension
-- Purpose: DLC / expansion packs that quests belong to
-- ============================================================
CREATE TABLE Extension (
    id_extension    INT          NOT NULL AUTO_INCREMENT,
    nom_extension   VARCHAR(50)  NOT NULL UNIQUE,
    date_sortie     DATE,
    PRIMARY KEY (id_extension)
);

-- ============================================================
-- TABLE: Quete
-- Purpose: Quests available in the game world
-- ============================================================
CREATE TABLE Quete (
    id_quete      INT           NOT NULL AUTO_INCREMENT,
    nom_quete     VARCHAR(100)  NOT NULL UNIQUE,
    type_quete    ENUM('Principale', 'Annexe') NOT NULL,
    difficulte    TINYINT       NOT NULL,
    id_extension  INT,
    PRIMARY KEY (id_quete),
    CONSTRAINT chk_quete_difficulte
        CHECK (difficulte BETWEEN 1 AND 5),
    CONSTRAINT fk_quete_extension
        FOREIGN KEY (id_extension) REFERENCES Extension (id_extension)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE INDEX idx_quete_type       ON Quete (type_quete);
CREATE INDEX idx_quete_difficulte ON Quete (difficulte);

-- ============================================================
-- TABLE: PNJ
-- Purpose: Non-Playable Characters and their attributes
-- ============================================================
CREATE TABLE PNJ (
    id_pnj          INT           NOT NULL AUTO_INCREMENT,
    nom_pnj         VARCHAR(50)   NOT NULL UNIQUE,
    race            ENUM('Humaine', 'Elfe', 'Nain', 'Orc', 'Gobelin',
                         'Ange', 'Démon', 'Esprit')  NOT NULL,
    classe          ENUM('Voleur', 'Mage', 'Protecteur', 'Assassin',
                         'Épéiste', 'Guérisseur', 'Soutien')  NOT NULL,
    niveau          TINYINT UNSIGNED  NOT NULL,
    metier          VARCHAR(50),
    vitalite        SMALLINT UNSIGNED NOT NULL DEFAULT 100,
    force_stat      SMALLINT UNSIGNED NOT NULL DEFAULT 50,
    sagesse         SMALLINT UNSIGNED NOT NULL DEFAULT 50,
    agilite         SMALLINT UNSIGNED NOT NULL DEFAULT 50,
    id_localisation INT           NOT NULL,
    created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_pnj),
    CONSTRAINT chk_pnj_niveau
        CHECK (niveau BETWEEN 1 AND 100),
    CONSTRAINT chk_pnj_vitalite
        CHECK (vitalite > 0),
    CONSTRAINT fk_pnj_localisation
        FOREIGN KEY (id_localisation) REFERENCES Localisation (id_localisation)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_pnj_race    ON PNJ (race);
CREATE INDEX idx_pnj_classe  ON PNJ (classe);
CREATE INDEX idx_pnj_niveau  ON PNJ (niveau);
CREATE INDEX idx_pnj_loc     ON PNJ (id_localisation);

-- ============================================================
-- TABLE: Intervenir
-- Purpose: Many-to-many association between NPCs and quests
--          Tracks the role each NPC plays in a quest
-- ============================================================
CREATE TABLE Intervenir (
    id_pnj    INT          NOT NULL,
    id_quete  INT          NOT NULL,
    role_pnj  ENUM('Donneur de quête', 'Allié', 'Ennemi',
                   'Boss', 'Marchand')  NOT NULL,
    PRIMARY KEY (id_pnj, id_quete),
    CONSTRAINT fk_interv_pnj
        FOREIGN KEY (id_pnj)   REFERENCES PNJ   (id_pnj)   ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_interv_quete
        FOREIGN KEY (id_quete) REFERENCES Quete (id_quete) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX idx_intervenir_quete ON Intervenir (id_quete);
CREATE INDEX idx_intervenir_role  ON Intervenir (role_pnj);

-- ============================================================
-- VIEWS — Expose pre-joined, business-ready datasets
-- ============================================================

-- VIEW: Full NPC profile with location details
CREATE OR REPLACE VIEW v_pnj_profil AS
SELECT
    p.id_pnj,
    p.nom_pnj,
    p.race,
    p.classe,
    p.niveau,
    p.metier,
    p.vitalite,
    p.force_stat,
    p.sagesse,
    p.agilite,
    l.lieu,
    l.contree,
    r.nom_region
FROM PNJ p
JOIN Localisation l ON p.id_localisation = l.id_localisation
JOIN Region       r ON l.id_region       = r.id_region;

-- VIEW: Quest participation summary per NPC
CREATE OR REPLACE VIEW v_pnj_participation AS
SELECT
    p.nom_pnj,
    p.race,
    p.classe,
    COUNT(i.id_quete)                                          AS nb_quetes,
    SUM(i.role_pnj = 'Boss')                                   AS nb_boss,
    SUM(i.role_pnj = 'Ennemi')                                 AS nb_ennemi,
    SUM(i.role_pnj = 'Allié')                                  AS nb_allie,
    SUM(i.role_pnj = 'Donneur de quête')                       AS nb_donneur,
    SUM(i.role_pnj = 'Marchand')                               AS nb_marchand
FROM PNJ p
LEFT JOIN Intervenir i ON p.id_pnj = i.id_pnj
GROUP BY p.id_pnj, p.nom_pnj, p.race, p.classe;

-- VIEW: Quest details with extension name and NPC count
CREATE OR REPLACE VIEW v_quete_details AS
SELECT
    q.id_quete,
    q.nom_quete,
    q.type_quete,
    q.difficulte,
    COALESCE(e.nom_extension, 'Jeu de base') AS extension,
    COUNT(i.id_pnj)                           AS nb_pnj_impliques
FROM Quete q
LEFT JOIN Extension  e ON q.id_extension = e.id_extension
LEFT JOIN Intervenir i ON q.id_quete     = i.id_quete
GROUP BY q.id_quete, q.nom_quete, q.type_quete, q.difficulte, e.nom_extension;

-- ============================================================
-- STORED PROCEDURES
-- ============================================================

DELIMITER //

-- PROC: Retrieve all NPCs in a given region with their quest count
CREATE PROCEDURE sp_pnj_par_region(IN p_region VARCHAR(50))
BEGIN
    SELECT
        p.nom_pnj,
        p.race,
        p.classe,
        p.niveau,
        l.lieu,
        COUNT(i.id_quete) AS nb_quetes
    FROM PNJ p
    JOIN Localisation l ON p.id_localisation = l.id_localisation
    JOIN Region       r ON l.id_region       = r.id_region
    LEFT JOIN Intervenir i ON p.id_pnj = i.id_pnj
    WHERE r.nom_region = p_region
    GROUP BY p.id_pnj, p.nom_pnj, p.race, p.classe, p.niveau, l.lieu
    ORDER BY p.niveau DESC;
END //

-- PROC: Get the top N most involved NPCs (by quest participation)
CREATE PROCEDURE sp_top_pnj(IN p_limit INT)
BEGIN
    SELECT
        p.nom_pnj,
        p.race,
        p.classe,
        COUNT(i.id_quete) AS nb_quetes
    FROM PNJ p
    JOIN Intervenir i ON p.id_pnj = i.id_pnj
    GROUP BY p.id_pnj, p.nom_pnj, p.race, p.classe
    ORDER BY nb_quetes DESC
    LIMIT p_limit;
END //

DELIMITER ;

-- ============================================================
-- TRIGGERS
-- ============================================================

DELIMITER //

-- TRIGGER: Prevent inserting a Boss NPC at difficulty < 3
CREATE TRIGGER trg_check_boss_difficulte
BEFORE INSERT ON Intervenir
FOR EACH ROW
BEGIN
    DECLARE v_difficulte TINYINT;
    IF NEW.role_pnj = 'Boss' THEN
        SELECT difficulte INTO v_difficulte
        FROM Quete WHERE id_quete = NEW.id_quete;
        IF v_difficulte < 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Un Boss ne peut pas être assigné à une quête de difficulté inférieure à 3.';
        END IF;
    END IF;
END //

-- TRIGGER: Auto-scale NPC vitality when level exceeds 80 (Divine-tier guard)
CREATE TRIGGER trg_divine_tier_vitalite
BEFORE INSERT ON PNJ
FOR EACH ROW
BEGIN
    IF NEW.niveau >= 80 AND NEW.vitalite < 200 THEN
        SET NEW.vitalite = 200;
    END IF;
END //

DELIMITER ;
