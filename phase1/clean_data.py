"""
Data Vortex - Round 1, Phase 1
Data Intake Restoration - Cleaning Script

This script cleans the corrupted Social_Engine_Posts_Corrupted.csv dataset
and produces a cleaned, analysis-ready output.

Author: Sahil Khetal
"""

import pandas as pd
import numpy as np
import html

# ---------------------------------------------------------------------------
# STEP 0: Load raw data
# ---------------------------------------------------------------------------
users = pd.read_csv('Social_Engine_Users.csv')
posts = pd.read_csv('Social_Engine_Posts_Corrupted.csv')

print(f"Raw posts shape: {posts.shape}")
print(f"Raw users shape: {users.shape}")

# ---------------------------------------------------------------------------
# STEP 1: Remove exact duplicate rows
# ---------------------------------------------------------------------------
# Justification: 360 rows in the posts dataset were found to be complete
# duplicates (identical post_id and all other fields). Since post_id should
# be a unique identifier for a single post, these are treated as accidental
# re-insertions during the intake failure and are safely dropped.
before = len(posts)
posts = posts.drop_duplicates()
print(f"Dropped {before - len(posts)} exact duplicate rows.")

# ---------------------------------------------------------------------------
# STEP 2: Standardize the 'timestamp' column
# ---------------------------------------------------------------------------
# Justification: The timestamp column was found in THREE different formats,
# consistent with a corrupted intake pipeline merging logs from different
# sources:
#   1. ISO 8601      -> "2025-02-03T02:09:31"
#   2. Unix epoch     -> "1731041269"           (seconds since 1970-01-01)
#   3. DD-MM-YYYY     -> "28-05-2024"           (date only, no time)
# All three are parsed and converted into a single standard datetime format
# (pandas Timestamp), so that time-based analysis (trends, sorting, grouping)
# is possible in Phase 2.

def parse_timestamp(ts):
    ts = str(ts).strip()
    # Unix epoch (10-digit numeric string)
    if ts.isdigit() and len(ts) == 10:
        return pd.to_datetime(int(ts), unit='s')
    # DD-MM-YYYY
    try:
        return pd.to_datetime(ts, format='%d-%m-%Y')
    except (ValueError, TypeError):
        pass
    # ISO 8601 (and anything else pandas can natively parse)
    try:
        return pd.to_datetime(ts)
    except (ValueError, TypeError):
        return pd.NaT

posts['timestamp'] = posts['timestamp'].apply(parse_timestamp)
print(f"Timestamps unparsable after conversion: {posts['timestamp'].isna().sum()}")

# ---------------------------------------------------------------------------
# STEP 3: Fix negative 'likes' values
# ---------------------------------------------------------------------------
# Justification: 525 rows had negative like counts, which is impossible for
# a real engagement metric. This is treated as a sign-flip corruption
# (e.g., a parsing/encoding error during the pipeline failure) rather than
# genuine data, so the absolute value is taken to recover the intended
# magnitude instead of discarding the row's other valid engagement data.
neg_count = (posts['likes'] < 0).sum()
posts['likes'] = posts['likes'].abs()
print(f"Corrected {neg_count} negative 'likes' values via abs().")

# ---------------------------------------------------------------------------
# STEP 4: Impute missing 'likes' with the column median
# ---------------------------------------------------------------------------
# Justification: 'likes' is a numeric engagement metric with a right-skewed
# distribution (a few posts go viral). The median is robust to this skew,
# unlike the mean, making it a safer central-tendency estimate for filling
# missing values without artificially deflating or inflating engagement.
likes_median = posts['likes'].median()
missing_likes = posts['likes'].isna().sum()
posts['likes'] = posts['likes'].fillna(likes_median)
print(f"Filled {missing_likes} missing 'likes' values with median ({likes_median}).")

# ---------------------------------------------------------------------------
# STEP 5: Fill missing categorical / text fields with explicit placeholders
# ---------------------------------------------------------------------------
# Justification: 'platform' and 'text_content' are non-numeric fields, so a
# statistical fill (mean/median) is not meaningful. Rather than dropping
# these rows (which would discard otherwise-valid engagement metrics for
# that post), missing values are replaced with explicit placeholders so the
# rows remain usable for numeric analysis, while missingness itself remains
# visible and auditable (rather than silently guessing a platform/caption).
missing_platform = posts['platform'].isna().sum()
missing_text = posts['text_content'].isna().sum()
posts['platform'] = posts['platform'].fillna('Unknown')
posts['text_content'] = posts['text_content'].fillna('[No content]')
print(f"Filled {missing_platform} missing 'platform' and {missing_text} missing 'text_content' values.")

# ---------------------------------------------------------------------------
# STEP 6: Decode HTML entities in text_content
# ---------------------------------------------------------------------------
# Justification: 341 posts contained raw HTML entities (e.g. '&amp;') instead
# of the actual character ('&'), consistent with text that was HTML-escaped
# during storage/transmission but never decoded on intake. Decoding restores
# the original human-readable text for accurate text-based analysis.
posts['text_content'] = posts['text_content'].apply(html.unescape)

# ---------------------------------------------------------------------------
# STEP 7: Data type standardization
# ---------------------------------------------------------------------------
posts['shares'] = posts['shares'].astype(int)
posts['comments'] = posts['comments'].astype(int)
posts['likes'] = posts['likes'].astype(int)

# ---------------------------------------------------------------------------
# STEP 8: Referential integrity check against Users table
# ---------------------------------------------------------------------------
# Justification: Every post should belong to a known user. This check
# confirms there are no orphaned posts referencing a user_id that doesn't
# exist in the Users table (important for the Phase 2 SQL join work).
orphan_posts = set(posts['user_id']) - set(users['user_id'])
print(f"Posts referencing unknown user_id: {len(orphan_posts)}")

# ---------------------------------------------------------------------------
# STEP 9: Save cleaned dataset
# ---------------------------------------------------------------------------
posts.to_csv('Social_Engine_Posts_Cleaned.csv', index=False)
users.to_csv('Social_Engine_Users_Cleaned.csv', index=False)

print("\nCleaning complete.")
print(f"Final posts shape: {posts.shape}")
print(posts.head())
