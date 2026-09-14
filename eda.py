"""
Data Vortex - Round 1, Phase 1
Exploratory Data Analysis (EDA)

Runs on the cleaned datasets to uncover analytical insights.

Author: Sahil Khetal
"""

import pandas as pd
import matplotlib.pyplot as plt

pd.set_option('display.max_columns', None)

posts = pd.read_csv('Social_Engine_Posts_Cleaned.csv', parse_dates=['timestamp'])
users = pd.read_csv('Social_Engine_Users_Cleaned.csv')

# ---------------------------------------------------------------------------
# 1. Basic overview
# ---------------------------------------------------------------------------
print("=== POSTS OVERVIEW ===")
print(posts.describe(include='all'))
print("\n=== USERS OVERVIEW ===")
print(users.describe(include='all'))

# ---------------------------------------------------------------------------
# 2. Platform distribution
# ---------------------------------------------------------------------------
platform_counts = posts['platform'].value_counts()
print("\n=== POSTS PER PLATFORM ===")
print(platform_counts)

plt.figure(figsize=(8, 5))
platform_counts.plot(kind='bar', color='#14213d')
plt.title('Number of Posts per Platform')
plt.xlabel('Platform')
plt.ylabel('Post Count')
plt.tight_layout()
plt.savefig('chart_platform_distribution.png')
plt.close()

# ---------------------------------------------------------------------------
# 3. Engagement analysis (likes, shares, comments) by platform
# ---------------------------------------------------------------------------
engagement_by_platform = posts.groupby('platform')[['likes', 'shares', 'comments']].mean().round(1)
print("\n=== AVG ENGAGEMENT BY PLATFORM ===")
print(engagement_by_platform)

engagement_by_platform.plot(kind='bar', figsize=(9, 5))
plt.title('Average Engagement by Platform')
plt.ylabel('Average Count')
plt.tight_layout()
plt.savefig('chart_engagement_by_platform.png')
plt.close()

# ---------------------------------------------------------------------------
# 4. Posting trend over time
# ---------------------------------------------------------------------------
posts['date'] = posts['timestamp'].dt.date
daily_posts = posts.groupby('date').size()

plt.figure(figsize=(10, 5))
daily_posts.plot()
plt.title('Post Volume Over Time')
plt.xlabel('Date')
plt.ylabel('Number of Posts')
plt.tight_layout()
plt.savefig('chart_posts_over_time.png')
plt.close()

# ---------------------------------------------------------------------------
# 5. Users joined with posts - engagement vs follower count
# ---------------------------------------------------------------------------
merged = posts.merge(users, on='user_id', how='left')
corr = merged[['follower_count', 'likes', 'shares', 'comments']].corr()
print("\n=== CORRELATION: follower_count vs engagement ===")
print(corr)

# ---------------------------------------------------------------------------
# 6. Top locations by post volume
# ---------------------------------------------------------------------------
top_locations = merged['location'].value_counts().head(10)
print("\n=== TOP 10 LOCATIONS BY POST COUNT ===")
print(top_locations)

# ---------------------------------------------------------------------------
# 7. Language distribution among active users
# ---------------------------------------------------------------------------
lang_dist = merged['language'].value_counts()
print("\n=== POSTS BY USER LANGUAGE ===")
print(lang_dist)

print("\nEDA complete. Charts saved as PNG files.")
