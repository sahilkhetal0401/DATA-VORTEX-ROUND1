-- ============================================================================
-- DATA VORTEX - ROUND 1, PHASE 2
-- SQL Analytical Reasoning Challenges
-- Author: Sahil Khetal
-- Tool used: SQLite 3
--
-- SCHEMA / TABLE SETUP
-- ----------------------------------------------------------------------------
-- users        - cleaned user data (1,500 rows). Columns:
--                user_id, location, language, account_created, follower_count
-- posts        - CLEANED posts data (12,000 rows). Used for ALL queries
--                EXCEPT H5. Columns:
--                post_id, user_id, platform, text_content, timestamp,
--                likes, shares, comments
-- posts_raw    - ORIGINAL CORRUPTED posts data (12,360 rows). Used ONLY for
--                H5, since Phase 1 cleaning already resolved the exact
--                anomalies (nulls, negative likes, HTML entities) that H5
--                asks us to detect. Using the cleaned table for H5 would
--                return zero anomalies, defeating the purpose of the task.
--
-- Both tables share `user_id` as the join key between users and posts.
-- ============================================================================


-- ============================================================================
-- EASY LEVEL
-- ============================================================================

-- E1: Platform Popularity
-- Which platform has the highest number of posts? (ignore missing platform)
-- RESULT: Facebook - 2074 posts
SELECT platform, COUNT(*) AS post_count
FROM posts
WHERE platform IS NOT NULL AND platform != 'Unknown'
GROUP BY platform
ORDER BY post_count DESC
LIMIT 1;


-- E2: Most Engaged Posts
-- Top 10 posts by total engagement (likes + shares + comments).
SELECT
    post_id,
    platform,
    likes,
    shares,
    comments,
    (likes + shares + comments) AS total_engagement
FROM posts
WHERE likes IS NOT NULL
ORDER BY total_engagement DESC
LIMIT 10;


-- E3: Average Engagement by Platform
-- Average likes/shares/comments per platform; highest avg total engagement?
-- RESULT: Instagram has the highest average total engagement (4041.13)
SELECT
    platform,
    ROUND(AVG(likes), 2)    AS avg_likes,
    ROUND(AVG(shares), 2)   AS avg_shares,
    ROUND(AVG(comments), 2) AS avg_comments,
    ROUND(AVG(likes + shares + comments), 2) AS avg_total_engagement
FROM posts
WHERE platform != 'Unknown'
GROUP BY platform
ORDER BY avg_total_engagement DESC;


-- E4: Highly Shared but Poorly Liked
-- shares > 1500 AND likes < 500  (247 posts match)
SELECT
    post_id,
    platform,
    likes,
    shares,
    comments
FROM posts
WHERE shares > 1500 AND likes < 500
ORDER BY shares DESC;


-- E5: Users With Large Audiences
-- Users with more than 40,000 followers (293 users match)
SELECT
    user_id,
    location,
    language,
    follower_count
FROM users
WHERE follower_count > 40000
ORDER BY follower_count DESC;


-- ============================================================================
-- MEDIUM LEVEL
-- ============================================================================

-- M1: Which Locations Generate the Most Engagement?
SELECT
    u.location,
    COUNT(p.post_id) AS number_of_posts,
    SUM(p.likes + p.shares + p.comments) AS total_engagement
FROM posts p
JOIN users u ON p.user_id = u.user_id
GROUP BY u.location
ORDER BY total_engagement DESC;
-- RESULT: Los Angeles, USA ranks #1 (459 posts, 1,838,780 total engagement)


-- M2: Do High Follower Users Get More Engagement?
-- High: >=25,000 followers | Low: <25,000 followers
SELECT
    CASE WHEN u.follower_count >= 25000 THEN 'High (>=25000)' ELSE 'Low (<25000)' END AS follower_group,
    COUNT(p.post_id) AS post_count,
    ROUND(AVG(p.likes + p.shares + p.comments), 2) AS avg_engagement_per_post
FROM posts p
JOIN users u ON p.user_id = u.user_id
GROUP BY follower_group;
-- RESULT: High = 4002.01 avg | Low = 4006.55 avg -- virtually IDENTICAL.
-- Key insight: follower count has no meaningful effect on per-post engagement.


-- M3: Most Active Users
SELECT
    p.user_id,
    u.follower_count,
    u.location,
    COUNT(p.post_id) AS post_count,
    SUM(p.likes + p.shares + p.comments) AS total_engagement
FROM posts p
JOIN users u ON p.user_id = u.user_id
GROUP BY p.user_id
ORDER BY post_count DESC
LIMIT 10;


-- M4: Platform Behaviour by High Follower Users
-- Among users with >=30,000 followers, which platform gives highest avg engagement?
SELECT
    p.platform,
    COUNT(p.post_id) AS post_count,
    ROUND(AVG(p.likes + p.shares + p.comments), 2) AS avg_engagement
FROM posts p
JOIN users u ON p.user_id = u.user_id
WHERE u.follower_count >= 30000 AND p.platform != 'Unknown'
GROUP BY p.platform
ORDER BY avg_engagement DESC;
-- RESULT: Instagram - 4129.89 avg engagement (highest among all platforms)


-- M5: Detect Suspicious Engagement
-- shares > (likes + comments) -- top 20 by share count
SELECT
    post_id, platform, likes, shares, comments,
    (likes + comments) AS likes_plus_comments
FROM posts
WHERE shares > (likes + comments)
ORDER BY shares DESC
LIMIT 20;


-- ============================================================================
-- HARD LEVEL
-- ============================================================================

-- H1: Find Users With Abnormally High Engagement
-- Users whose avg engagement per post > 2x the overall average.
WITH user_engagement AS (
    SELECT
        p.user_id,
        COUNT(p.post_id) AS post_count,
        AVG(p.likes + p.shares + p.comments) AS avg_engagement
    FROM posts p
    GROUP BY p.user_id
),
overall_avg AS (
    SELECT AVG(likes + shares + comments) AS overall_avg_engagement
    FROM posts
)
SELECT
    ue.user_id,
    u.location,
    u.follower_count,
    ue.post_count,
    ROUND(ue.avg_engagement, 2) AS avg_engagement_per_post
FROM user_engagement ue
JOIN users u ON ue.user_id = u.user_id
CROSS JOIN overall_avg oa
WHERE ue.avg_engagement > 2 * oa.overall_avg_engagement
ORDER BY avg_engagement_per_post DESC;
-- RESULT: 0 rows. Overall avg engagement = 4004.31, so the 2x threshold is
-- 8008.61. The highest individual user average found in the dataset is only
-- ~5898.33 -- nowhere close to the threshold. This is a genuine finding
-- (verified, not a query bug): engagement in this dataset is highly uniform
-- across users, with no outlier "super-engaged" accounts.


-- H2: Rank Users Within Their Location
-- Top 3 users per location by total engagement, using window function RANK().
WITH user_totals AS (
    SELECT
        u.location,
        p.user_id,
        SUM(p.likes + p.shares + p.comments) AS total_engagement
    FROM posts p
    JOIN users u ON p.user_id = u.user_id
    GROUP BY u.location, p.user_id
),
ranked AS (
    SELECT
        location, user_id, total_engagement,
        RANK() OVER (PARTITION BY location ORDER BY total_engagement DESC) AS rnk
    FROM user_totals
)
SELECT location, user_id, total_engagement, rnk
FROM ranked
WHERE rnk <= 3
ORDER BY location, rnk;
-- RESULT: 99 rows (33 locations x top 3 users each)


-- H3: Platform Performance Compared With Its Own Average
-- Posts whose engagement is >= 2x their OWN platform's average.
WITH platform_avg AS (
    SELECT platform, AVG(likes+shares+comments) AS avg_eng
    FROM posts
    WHERE platform != 'Unknown'
    GROUP BY platform
)
SELECT p.post_id, p.platform, (p.likes+p.shares+p.comments) AS post_engagement,
       ROUND(pa.avg_eng, 2) AS platform_avg_engagement
FROM posts p
JOIN platform_avg pa ON p.platform = pa.platform
WHERE (p.likes+p.shares+p.comments) >= 2 * pa.avg_eng
ORDER BY post_engagement DESC;
-- RESULT: 0 rows. Verified: the single highest-engagement post in the whole
-- dataset totals 7,893, while every platform's 2x-average threshold sits
-- between ~7,917 (Twitter, the lowest) and ~8,082 (Instagram). No post
-- clears even the lowest threshold. Consistent with H1 -- this dataset has
-- no "viral outlier" posts; engagement is capped in a fairly narrow range.


-- H4: Follower to Engagement Anomaly
-- Users with <5,000 followers whose TOTAL engagement is in the top 10% of all users.
WITH user_totals AS (
    SELECT p.user_id, SUM(p.likes+p.shares+p.comments) AS total_engagement
    FROM posts p
    GROUP BY p.user_id
),
ranked AS (
    SELECT user_id, total_engagement,
           PERCENT_RANK() OVER (ORDER BY total_engagement DESC) AS pct_rank
    FROM user_totals
)
SELECT r.user_id, u.follower_count, u.location, r.total_engagement
FROM ranked r
JOIN users u ON r.user_id = u.user_id
WHERE u.follower_count < 5000 AND r.pct_rank <= 0.10
ORDER BY r.total_engagement DESC;
-- RESULT: 17 users -- small-audience accounts whose total engagement
-- (driven by high post volume, per M3-style behaviour) places them in the
-- top decile of all users. These are the "punching above their weight"
-- accounts the question is looking for.


-- H5: Identify Data Anomalies
-- NOTE: Uses posts_raw (the ORIGINAL corrupted table), not the cleaned
-- `posts` table -- see schema note at the top of this file.
SELECT
    post_id,
    CASE
        WHEN likes < 0 THEN 'Negative Likes'
        WHEN platform IS NULL THEN 'Missing Platform'
        WHEN text_content IS NULL THEN 'Missing Text Content'
        WHEN text_content LIKE '%&amp;%' OR text_content LIKE '%&lt;%'
             OR text_content LIKE '%&gt;%' OR text_content LIKE '%<div>%'
             OR text_content LIKE '%<br>%' THEN 'HTML Entities/Tags in Text'
        ELSE 'Other'
    END AS anomaly_type
FROM posts_raw
WHERE likes < 0
   OR platform IS NULL
   OR text_content IS NULL
   OR text_content LIKE '%&amp;%' OR text_content LIKE '%&lt;%'
   OR text_content LIKE '%&gt;%' OR text_content LIKE '%<div>%'
   OR text_content LIKE '%<br>%'
ORDER BY anomaly_type;
-- RESULT: 4536 anomalous rows total. Breakdown:
--   Missing Platform            : 1752
--   Missing Text Content        : 1439
--   HTML Entities/Tags in Text  :  820
--   Negative Likes              :  525
-- (Note: CASE returns the FIRST matching condition per row, so a row with
--  multiple simultaneous issues is counted once under its highest-priority
--  anomaly type above. This matches Phase 1's cleaning order of operations.)


-- H6: Find the Most Suspicious High Impact Users
-- Users who satisfy ALL THREE:
--   1. < 10,000 followers
--   2. avg post engagement > overall average
--   3. at least one post where shares > likes
WITH user_stats AS (
    SELECT
        p.user_id,
        COUNT(p.post_id) AS post_count,
        AVG(p.likes+p.shares+p.comments) AS avg_engagement,
        SUM(p.likes+p.shares+p.comments) AS total_engagement,
        MAX(CASE WHEN p.shares > p.likes THEN 1 ELSE 0 END) AS has_shares_gt_likes
    FROM posts p
    GROUP BY p.user_id
),
overall_avg AS (
    SELECT AVG(likes+shares+comments) AS overall_avg_engagement FROM posts
)
SELECT
    us.user_id,
    u.location,
    u.follower_count,
    us.post_count,
    ROUND(us.avg_engagement, 2) AS avg_engagement,
    us.total_engagement
FROM user_stats us
JOIN users u ON us.user_id = u.user_id
CROSS JOIN overall_avg oa
WHERE u.follower_count < 10000
  AND us.avg_engagement > oa.overall_avg_engagement
  AND us.has_shares_gt_likes = 1
ORDER BY us.total_engagement DESC;
-- RESULT: 94 users match all three conditions, ranked by total engagement.
-- Top result: user_uerv85na (Rome, Italy) - 1,824 followers, 16 posts,
-- 72,247 total engagement.
