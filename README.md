# 🎮 Fantasy NPC Database — DB_FOR_PNJ

> Academic project improvement (version pro) — EFREI Paris | Paul-Alex Yao  
> A relational database for managing Non-Playable Characters in a fantasy video game universe.

---

## 📐 Schema Overview

```
Region ──< Localisation ──< PNJ >── Intervenir ──< Quete >── Extension
```

The schema is fully normalized to **3NF**, with geographic data now split between a `Region` table and `Localisation` to eliminate partial dependencies and enable cleaner regional aggregations.

| Table | Description |
|---|---|
| `Region` | Top-level geographic grouping (Valoria, Eldoria, Nyméria) |
| `Localisation` | Fine-grained locations (pays, contrée, lieu) |
| `Extension` | DLC / expansion packs |
| `Quete` | Quests with type, difficulty and extension |
| `PNJ` | NPC characters with stats and location |
| `Intervenir` | Many-to-many: NPC ↔ Quest with role tracking |

---

## 🗂️ File Structure

```
DB_FOR_PNJ/
├── PNJBD_creation.sql        # DDL: schema, tables, indexes, views, procedures, triggers
├── PNJBD_jeux_donnees.sql    # DML: full data population (40 NPCs, 30 quests, 4 extensions)
├── PNJBD_exploration.sql     # DQL: 8 sections of analytics queries
└── README.md
```

---

## ⚙️ Key Design Decisions

### Constraints & Data Integrity
- `AUTO_INCREMENT` primary keys throughout — no manual ID management
- `ENUM` types on `race`, `classe`, `type_quete`, `role_pnj` — enforces valid domain values at the DB level
- `CHECK` constraints: NPC level capped to [1–100], quest difficulty to [1–5]
- `ON DELETE RESTRICT` on Localisation FK — prevents orphan NPCs from silent cascades

### Indexes
Strategic indexes on high-filter columns: `race`, `classe`, `niveau`, `type_quete`, `difficulte`, and all FK columns — optimising the most frequent JOIN and WHERE patterns.

### Views
| View | Purpose |
|---|---|
| `v_pnj_profil` | Full NPC profile with location hierarchy |
| `v_pnj_participation` | Per-NPC quest role breakdown |
| `v_quete_details` | Quest summary with extension name and NPC count |

### Stored Procedures
| Procedure | Signature |
|---|---|
| `sp_pnj_par_region` | `(p_region VARCHAR)` — NPCs in a region with quest count |
| `sp_top_pnj` | `(p_limit INT)` — Top N most involved NPCs |

### Triggers
| Trigger | Logic |
|---|---|
| `trg_check_boss_difficulte` | Prevents assigning a Boss to a quest with difficulty < 3 |
| `trg_divine_tier_vitalite` | Auto-raises vitality ≥ 200 for NPCs with level ≥ 80 |

---

## 🔍 Query Highlights (exploration.sql)

The exploration file is structured in **8 sections**, from basic filtering to advanced analytics:

1. **Basic Filtering** — WHERE, ORDER BY
2. **Joins** — multi-table JOINs with full location hierarchy
3. **Aggregation** — GROUP BY with HAVING, multi-stat summaries
4. **Negation** — NOT EXISTS anti-joins (more robust than NOT IN on nullable FKs)
5. **Relational Division** — "NPCs who participated in ALL main quests"
6. **Advanced Analytics** — CTEs, RANK/DENSE_RANK window functions, correlated subqueries, activity scoring
7. **Procedure calls** — demo usage of stored procedures
8. **View queries** — leveraging pre-built views for clean reporting

---

## 🛠️ Tech Stack

- **MySQL 8.0+** (required for window functions and CTEs)
- `utf8mb4` charset — full Unicode support including emojis and accented characters

## 🚀 Getting Started

```sql
-- 1. Run schema creation
SOURCE PNJBD_creation.sql;

-- 2. Populate data
SOURCE PNJBD_jeux_donnees.sql;

-- 3. Run exploration queries
SOURCE PNJBD_exploration.sql;
```

---

*Project developed as part of the Databases module — EFREI Paris*
