"""
Data Vortex - Round 1, Phase 2
Builds the SQLite database from Phase 1's cleaned datasets.

Three tables are created:
  - users      : cleaned user data
  - posts      : cleaned posts data (used for all queries except H5)
  - posts_raw  : original corrupted posts data (used only for H5, since
                 Phase 1 cleaning already resolved the anomalies H5 detects)

Author: Sahil Khetal
"""

import sqlite3
import pandas as pd

conn = sqlite3.connect('social_engine.db')

users = pd.read_csv('Social_Engine_Users_Cleaned.csv')
posts = pd.read_csv('Social_Engine_Posts_Cleaned.csv')
posts_raw = pd.read_csv('Social_Engine_Posts_Corrupted.csv')

users.to_sql('users', conn, if_exists='replace', index=False)
posts.to_sql('posts', conn, if_exists='replace', index=False)
posts_raw.to_sql('posts_raw', conn, if_exists='replace', index=False)

print(f"users table: {len(users)} rows")
print(f"posts table (cleaned): {len(posts)} rows")
print(f"posts_raw table (original/corrupted): {len(posts_raw)} rows")
print("\nDatabase built: social_engine.db")

conn.close()
