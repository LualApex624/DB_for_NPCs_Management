-- ============================================================
-- PROJECT   : Fantasy NPC Database (DB_FOR_PNJ)
-- AUTHOR    : Paul-Alex Yao — EFREI Paris
-- VERSION   : 2.0 (Professional Edition)
-- FILE      : Data Population (Jeux de données)
-- ============================================================

USE `fantasy_npcs`;

-- ============================================================
-- REGIONS
-- ============================================================
INSERT INTO Region (nom_region, description) VALUES
('Valoria',  'Terres verdoyantes parsemées de forêts et de montagnes sacrées.'),
('Eldoria',  'Contrée mystérieuse dominée par les marais et les vents éternels.'),
('Nyméria',  'Région aux extrêmes : jungles tropicales et toundras glaciales.');

-- ============================================================
-- LOCALISATIONS
-- ============================================================
INSERT INTO Localisation (id_region, contree, lieu) VALUES
-- Valoria (id_region = 1)
(1, 'Forêt d\'Émeraude',    'Clairière Enchantée'),
(1, 'Forêt d\'Émeraude',    'Arbre Ancien'),
(1, 'Montagnes Brumeuses',  'Pic du Dragon'),
(1, 'Montagnes Brumeuses',  'Grotte Mystique'),
(1, 'Montagnes Brumeuses',  'Source Sacrée'),
(1, 'Plaines Dorées',       'Ferme du Soleil'),
(1, 'Plaines Dorées',       'Temple Oublié'),
-- Eldoria (id_region = 2)
(2, 'Marais Sombres',       'Îlot Perdu'),
(2, 'Marais Sombres',       'Caverne Engloutie'),
(2, 'Vallée des Vents',     'Sanctuaire des Brises'),
(2, 'Vallée des Vents',     'Pont des Esprits'),
(2, 'Vallée des Vents',     'Tour des Tempêtes'),
(2, 'Terres Arides',        'Ruines Anciennes'),
(2, 'Terres Arides',        'Campement Nomade'),
-- Nyméria (id_region = 3)
(3, 'Jungle Luxuriante',    'Cascade Cachée'),
(3, 'Jungle Luxuriante',    'Temple Englouti'),
(3, 'Toundra Glacée',       'Grotte de Glace'),
(3, 'Toundra Glacée',       'Village Gelé'),
(3, 'Toundra Glacée',       'Lac Cristallin'),
(3, 'Côte Sauvage',         'Phare Abandonné'),
(3, 'Côte Sauvage',         'Port Oublié');

-- ============================================================
-- EXTENSIONS
-- ============================================================
INSERT INTO Extension (nom_extension, date_sortie) VALUES
('L\'Appel du Néant',    '2021-03-15'),
('La Guerre des Titans',  '2022-06-01'),
('Les Cités Englouties',  '2023-01-20'),
('Le Royaume Oublié',     '2024-09-05');

-- ============================================================
-- QUETES
-- ============================================================
INSERT INTO Quete (nom_quete, type_quete, difficulte, id_extension) VALUES
('L\'appel du destin',        'Principale', 2, 1),
('Les vestiges du temps',     'Principale', 4, 2),
('Le gardien oublié',         'Principale', 2, 3),
('Le fléau ancestral',        'Principale', 4, 4),
('Le trésor perdu',           'Principale', 5, NULL),
('L\'ascension du champion',  'Principale', 4, NULL),
('Les secrets de la montagne','Annexe',     2, NULL),
('Le rite des anciens',       'Annexe',     2, NULL),
('L\'attaque des bandits',    'Annexe',     3, NULL),
('La tour maudite',           'Principale', 4, 3),
('Les murmures de la forêt',  'Principale', 5, 2),
('Le duel des légendes',      'Principale', 1, NULL),
('Les profondeurs oubliées',  'Annexe',     2, 1),
('La révolte des esclaves',   'Principale', 5, NULL),
('Le complot royal',          'Annexe',     4, NULL),
('Les gardiens du temple',    'Annexe',     1, NULL),
('La chasse au dragon',       'Principale', 2, 2),  -- corrected: difficulte >= 3 for Boss (Thorgrim)
('Les ruines hantées',        'Principale', 4, NULL),
('L\'oracle des abysses',     'Principale', 4, NULL),
('Les sentinelles disparues', 'Principale', 1, 3),
('Le siège de la citadelle',  'Annexe',     5, 1),
('L\'étoile du destin',       'Annexe',     1, 4),
('Les reliques interdites',   'Annexe',     5, NULL),
('La guerre des clans',       'Annexe',     2, 4),
('Le serment brisé',          'Annexe',     5, NULL),
('La vengeance du sorcier',   'Principale', 5, NULL),
('Les flammes du chaos',      'Principale', 3, NULL),
('L\'ultime sacrifice',       'Principale', 4, NULL),
('Le pacte du sang',          'Principale', 3, NULL),
('Les terres interdites',     'Principale', 4, NULL);

-- ============================================================
-- PNJ
-- ============================================================
INSERT INTO PNJ (nom_pnj, race, classe, niveau, metier, vitalite, force_stat, sagesse, agilite, id_localisation) VALUES
('Elyndor',    'Humaine',  'Voleur',      11, 'Chasseur',          119, 83,  66,  96,  1),
('Lirelia',    'Elfe',     'Mage',        25, 'Alchimiste',        152, 51,  124, 77,  10),
('Thorgrim',   'Nain',     'Protecteur',  43, 'Forgeron',          138, 122, 84,  65,  4),
('Griznak',    'Gobelin',  'Assassin',    16, 'Mineur',            108, 71,  53,  114, 9),
('Gorak',      'Orc',      'Épéiste',     32, 'Bucheron',          181, 152, 69,  89,  13),
('Aelindra',   'Esprit',   'Guérisseur',  89, 'Divinité',          300, 101, 195, 107, 7),
('Mira',       'Humaine',  'Soutien',      2, 'Paysan',             23, 41,  27,  52,  6),
('Faelar',     'Elfe',     'Assassin',    27, 'Chasseur de prime', 131, 94,  83,  106, 15),
('Seraphis',   'Ange',     'Protecteur',  99, 'Divinité',          300, 151, 200, 120, 12),
('Malachar',   'Démon',    'Assassin',    85, 'Fossoyeur',         200, 129, 176, 131, 18),
('Elara',      'Humaine',  'Guérisseur',  12, 'Tailleur',          111, 64,  95,  73,  2),
('Durgrim',    'Nain',     'Épéiste',     36, 'Mineur',            126, 104, 70,  83,  3),
('Sylvaris',   'Elfe',     'Mage',        28, 'Alchimiste',        139, 59,  124, 91,  16),
('Snikk',      'Gobelin',  'Voleur',      18, 'Bucheron',           58, 75,  55,  102, 5),
('Groknak',    'Orc',      'Protecteur',  44, 'Forgeron',          126, 135, 68,  68,  14),
('Luminis',    'Esprit',   'Soutien',     88, 'Divinité',          300, 108, 179, 117, 19),
('Kaela',      'Humaine',  'Guérisseur',   8, 'Pêcheur',            90, 50,  65,  75,  20),
('Celestia',   'Ange',     'Mage',        88, 'Divinité',          300, 120, 176, 145, 11),
('Zarathos',   'Démon',    'Assassin',    82, 'Fossoyeur',         200, 156, 171, 134, 17),
('Thalindra',  'Elfe',     'Voleur',      22, 'Chasseur de prime', 135, 85,  75,  95,  21),
('Rynna',      'Humaine',  'Voleur',      48, 'Chasseur',          126, 88,  66,  94,  1),
('Aelara',     'Elfe',     'Mage',        33, 'Alchimiste',        162, 54,  139, 79,  10),
('Borin',      'Nain',     'Protecteur',  50, 'Forgeron',          120, 153, 91,  78,  4),
('Snaggle',    'Gobelin',  'Assassin',    29, 'Mineur',            105, 79,  66,  127, 9),
('Tharok',     'Orc',      'Épéiste',     47, 'Bucheron',          200, 132, 72,  91,  13),
('Lunara',     'Esprit',   'Guérisseur',  85, 'Divinité',          300, 109, 199, 169, 7),
('Mara',       'Humaine',  'Soutien',      7, 'Paysan',             91, 44,  70,  55,  6),
('Faelen',     'Elfe',     'Soutien',     28, 'Chasseur de prime', 143, 94,  82,  108, 15),
('Aetheris',   'Ange',     'Protecteur',  96, 'Divinité',          300, 161, 200, 148, 12),
('Maltheris',  'Démon',    'Assassin',    90, 'Fossoyeur',         200, 132, 173, 125, 18),
('Lyna',       'Humaine',  'Guérisseur',  18, 'Tailleur',          121, 75,  103, 88,  2),
('Thrain',     'Nain',     'Épéiste',     49, 'Mineur',            105, 142, 87,  99,  3),
('Eryndor',    'Elfe',     'Mage',        32, 'Alchimiste',        124, 71,  58,  113, 16),
('Grizlak',    'Gobelin',  'Voleur',      22, 'Bucheron',          102, 81,  63,  117, 5),
('Gorzak',     'Orc',      'Protecteur',  52, 'Forgeron',          134, 176, 85,  78,  14),
('Aurion',     'Esprit',   'Soutien',     88, 'Divinité',          284, 123, 196, 126, 19),
('Kaelin',     'Humaine',  'Mage',        12, 'Pêcheur',           100, 55,  25,  53,  20),
('Seraphine',  'Ange',     'Mage',        92, 'Divinité',          275, 137, 200, 142, 11),
('Zarathar',   'Démon',    'Assassin',    87, 'Fossoyeur',         195, 158, 186, 149, 17),
('Thalor',     'Elfe',     'Protecteur',  28, 'Chasseur de prime',  57, 92,  84,  102, 21);

-- ============================================================
-- INTERVENTIONS (NPC ↔ Quest roles)
-- ============================================================
INSERT INTO Intervenir (id_pnj, id_quete, role_pnj) VALUES
(1,  1,  'Donneur de quête'),
(1,  7,  'Ennemi'),
(2,  2,  'Allié'),
(3,  3,  'Ennemi'),
(3,  17, 'Boss'),
(4,  4,  'Ennemi'),
(5,  5,  'Ennemi'),
(6,  6,  'Allié'),
(6,  19, 'Allié'),
(7,  7,  'Ennemi'),
(8,  8,  'Marchand'),
(9,  9,  'Ennemi'),
(9,  22, 'Boss'),
(10, 10, 'Donneur de quête'),
(11, 11, 'Marchand'),
(12, 12, 'Ennemi'),
(13, 13, 'Marchand'),
(14, 14, 'Boss'),
(15, 15, 'Marchand'),
(16, 16, 'Ennemi'),
(17, 17, 'Marchand'),
(18, 18, 'Donneur de quête'),
(18, 1,  'Boss'),
(19, 19, 'Boss'),
(20, 20, 'Allié'),
(21, 21, 'Donneur de quête'),
(22, 22, 'Boss'),
(23, 23, 'Donneur de quête'),
(24, 24, 'Marchand'),
(25, 25, 'Allié'),
(26, 26, 'Ennemi'),
(27, 27, 'Ennemi'),
(28, 28, 'Allié'),
(29, 29, 'Donneur de quête'),
(30, 30, 'Ennemi'),
(31, 1,  'Marchand'),
(32, 2,  'Allié'),
(33, 3,  'Marchand'),
(34, 4,  'Boss'),
(35, 5,  'Boss'),
(36, 6,  'Marchand'),
(37, 7,  'Boss'),
(38, 8,  'Marchand'),
(39, 9,  'Allié'),
(40, 10, 'Donneur de quête');
