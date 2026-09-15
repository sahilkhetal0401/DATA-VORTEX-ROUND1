# Data Vortex — Round 1, Phase 1
## Exploratory Data Analysis Report

**Team/Participant:** Sahil Khetal
**Dataset:** Social Engine — Users & Posts (recovered from Archive Node 07)

---

## 1. Data Cleaning Summary

The recovered `Social_Engine_Posts_Corrupted.csv` (12,360 rows, 8 columns) contained
the following corruption patterns, all resolved in `clean_data.py`:

| Issue | Rows Affected | Resolution |
|---|---|---|
| Exact duplicate rows | 360 | Dropped |
| Missing `platform` | 1,784 (after dedup) | Filled with `'Unknown'` |
| Missing `text_content` | 1,688 (after dedup) | Filled with `'[No content]'` |
| Missing `likes` | 1,814 (after dedup) | Filled with column median (2,498) |
| Negative `likes` values | 509 (after dedup) | Corrected via absolute value |
| Mixed timestamp formats (ISO 8601 / Unix epoch / DD-MM-YYYY) | All 12,360 | Standardized to a single datetime format |
| HTML-escaped text (e.g. `&amp;`) | 341 | Decoded to plain text |

`Social_Engine_Users.csv` (1,500 rows) required no cleaning — no missing values,
no duplicate `user_id`s, and every `user_id` referenced in Posts exists in Users
(0 orphaned records), confirming referential integrity between the two tables.

**Final cleaned dataset:** 12,000 posts × 8 columns.

---

## 2. Key Insights

### 2.1 Platform Distribution
Posts are fairly evenly spread across all five recovered platforms
(Facebook, YouTube, Twitter, Reddit, Instagram — roughly 2,000–2,074 posts each).
The `Unknown` category (platform not recoverable) accounts for 1,784 posts
(~14.9% of the cleaned dataset), which should be treated as a data-quality
caveat in any platform-specific conclusion.

### 2.2 Engagement by Platform
Average engagement (likes/shares/comments) is remarkably **consistent across
platforms** — no platform dramatically outperforms another:

| Platform | Avg Likes | Avg Shares | Avg Comments |
|---|---|---|---|
| Facebook | 2,524.1 | 984.2 | 506.9 |
| YouTube | 2,514.7 | 1,011.8 | 504.4 |
| Reddit | 2,489.5 | 1,002.2 | 511.2 |
| Twitter | 2,447.2 | 1,005.4 | 506.1 |
| Instagram | 2,500.5 | 1,040.8 | 499.8 |

This uniformity suggests engagement in this dataset is not platform-driven —
other factors (content type, timing, user base) likely matter more.

### 2.3 Follower Count vs Engagement — No Correlation
Correlation analysis between a user's `follower_count` and their post's
`likes`, `shares`, and `comments` shows **near-zero correlation** across the
board (all coefficients between -0.014 and +0.009). This is a notable
finding: **having more followers does not predict higher engagement** in
this dataset, contrary to typical social media assumptions.

### 2.4 Geographic Spread
Posting activity is broadly global, with the top locations (Los Angeles,
Munich, Shanghai, Barcelona, Houston) each contributing 400+ posts, and no
single location dominating — consistent with a globally distributed
simulated user base.

### 2.5 Language Distribution
All 10 languages in the Users table are represented fairly evenly in post
volume (1,119–1,369 posts each), with Chinese (`zh`), Japanese (`ja`), and
Hindi (`hi`) speakers contributing marginally more posts than English (`en`)
speakers.

### 2.6 Temporal Trend
Post timestamps span **May 2024 to April 2025**, after timestamp
standardization. (See `chart_posts_over_time.png` for the full daily trend.)

---

## 3. Assumptions Made

1. **Negative likes** were assumed to be a sign-corruption artifact (e.g., a
   parsing error), not intentionally negative data, since "likes" cannot be
   negative in any real system — hence `abs()` was applied rather than
   dropping these rows.
2. **Missing `platform`/`text_content`** were treated as "unrecoverable"
   fields rather than dropped, since the numeric engagement data (likes,
   shares, comments) for those rows remained valid and usable.
3. **Median (not mean)** was used to impute missing `likes` because the
   distribution is not heavily skewed at the tails (min 0, max 5,000) but
   median remains the more standard, defensible robust estimator for
   engagement metrics.
4. Exact duplicate rows were assumed to be **re-transmission artifacts**
   from the corrupted intake pipeline, not genuine repeated posts, since
   every field (including `post_id`) was identical.

---

## 4. Files Included

- `clean_data.py` — cleaning script with inline justification comments
- `eda.py` — EDA script generating all statistics and charts
- `Social_Engine_Posts_Cleaned.csv` — cleaned posts dataset
- `Social_Engine_Users_Cleaned.csv` — users dataset (unchanged, verified clean)
- `chart_platform_distribution.png`
- `chart_engagement_by_platform.png`
- `chart_posts_over_time.png`
- `EDA_Report.md` — this report
