# Data Vortex — Round 1: Data Intake Restoration

**Participant:** Sahil Khetal
**Event:** Data Vortex, AARUUSH'26 — Theme: Rebuilding the Social Engine

## Overview
This repository contains the recovery, cleaning, and exploratory data
analysis work for Round 1, Phase 1 of the Data Vortex hackathon. The
corrupted `Social_Engine_Posts_Corrupted.csv` dataset was recovered from the
event's Archive Node 07 terminal, then cleaned and analyzed.

## Repository Structure
```
├── Social_Engine_Users.csv              # Original recovered users dataset
├── Social_Engine_Posts_Corrupted.csv    # Original recovered (corrupted) posts dataset
├── clean_data.py                        # Cleaning pipeline with justifications
├── eda.py                               # Exploratory data analysis script
├── Social_Engine_Posts_Cleaned.csv      # Output: cleaned posts dataset
├── Social_Engine_Users_Cleaned.csv      # Output: verified users dataset
├── EDA_Report.md                        # Full write-up of findings & insights
├── chart_platform_distribution.png      # Posts per platform
├── chart_engagement_by_platform.png     # Avg engagement per platform
├── chart_posts_over_time.png            # Post volume trend over time
└── README.md                            # This file
```

## How to Reproduce
```bash
pip install pandas numpy matplotlib
python3 clean_data.py   # produces cleaned CSVs
python3 eda.py           # produces charts + printed insights
```

## Summary of Data Issues Found & Fixed
1. 360 exact duplicate rows — dropped
2. Missing `platform` (1,784 rows) — filled with `'Unknown'`
3. Missing `text_content` (1,688 rows) — filled with `'[No content]'`
4. Missing `likes` (1,814 rows) — filled with column median
5. Negative `likes` values (509 rows) — corrected via absolute value
6. Three mixed timestamp formats (ISO 8601, Unix epoch, DD-MM-YYYY) — standardized
7. HTML-escaped text entities (341 rows) — decoded to plain text

Full reasoning for every transformation is documented inline in `clean_data.py`
and summarized in `EDA_Report.md`.

## Key Findings
- Engagement (likes/shares/comments) is nearly uniform across all five platforms.
- Follower count shows **no meaningful correlation** with post engagement.
- User activity is geographically well-distributed with no single dominant location.
- All 10 supported languages are represented fairly evenly in post volume.

See `EDA_Report.md` for full details, assumptions, and methodology.
