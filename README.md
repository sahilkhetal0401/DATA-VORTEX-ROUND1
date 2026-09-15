# Data Vortex — Round 1 (AARUUSH'26)

**Participant:** Sahil Khetal
**Theme:** Rebuilding the Social Engine

This repository contains my complete Round 1 submission, covering both phases
of the Data Vortex hackathon.

## Repository Structure
├── phase1/ # Phase 1 — Data Intake Restoration
│ # (dataset recovery, cleaning, EDA)
│
├── phase2/ # Phase 2 — Analytical Core Rebuild
│ # (SQL tables + 16 analytical queries)
│
└── README.md # This file

## Phase 1 — Data Intake Restoration
Recovered a corrupted social-media-style dataset, cleaned it (duplicates,
missing values, mixed timestamp formats, negative values, HTML entities),
and performed exploratory data analysis.
**See:** [`phase1/README.md`](./phase1/README.md) for full details.

## Phase 2 — Analytical Core Rebuild
Converted the cleaned dataset into SQL tables (SQLite) and solved 16
analytical reasoning challenges across Easy, Medium, and Hard difficulty
levels — covering trend detection, ranking, anomaly discovery, and
correlation analysis.
**See:** [`phase2/README_Phase2.md`](./phase2/README_Phase2.md) for full details.

## Key Highlights Across Both Phases
- Cleaned 12,360 raw posts down to a fully validated 12,000-row dataset
- Identified and resolved 4,536 anomalous rows (missing fields, negative
  values, HTML-escaped text, mixed timestamp formats)
- Found that **follower count does not predict engagement** in this dataset
- Verified (not assumed) that no viral outlier posts or "super-user"
  accounts exist, using two independent statistical checks
