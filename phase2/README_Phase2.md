# Data Vortex — Round 1, Phase 2: Analytical Core Rebuild

**Participant:** Sahil Khetal

## Overview
This phase converts the Phase 1 cleaned dataset into SQL tables and answers
16 analytical reasoning challenges (5 Easy, 5 Medium, 6 Hard) using SQLite 3.

## Files
- `build_database.py` — loads the cleaned CSVs (+ original corrupted CSV) into a SQLite database
- `social_engine.db` — the resulting SQLite database (3 tables: `users`, `posts`, `posts_raw`)
- `queries.sql` — all 16 SQL queries, fully commented with logic and results
- `H5_full_anomaly_detail.csv` — complete 4,536-row detail backing the H5 summary

## Table Design
| Table | Rows | Purpose |
|---|---|---|
| `users` | 1,500 | Cleaned user data (verified: no nulls, no duplicates) |
| `posts` | 12,000 | **Cleaned** posts data — used for all queries except H5 |
| `posts_raw` | 12,360 | **Original corrupted** posts data — used only for H5, since Phase 1 cleaning already resolved the exact anomalies H5 asks to detect |

## Key Findings
1. **Facebook** has the most posts (2,074), but **Instagram** has the highest average engagement per post (4,041.13).
2. **Follower count does not predict
