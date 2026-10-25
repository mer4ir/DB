-- Task1
CREATE VIEW basic_details_view AS
SELECT 
    p.post_id,
    p.created_at,
    g.name AS group_name,
    u.first_name AS author_first_name,
    u.last_name AS author_last_name,
    p.content
FROM posts p
JOIN user_groups g ON p.group_id = g.group_id
JOIN users u ON p.user_id = u.user_id;

-- Task2
CREATE VIEW filtered_entities_view AS
SELECT 
    group_id,
    name,
    description,
    created_at
FROM user_groups
WHERE name LIKE 'Группа%'
WITH CHECK OPTION;

-- Task3
CREATE VIEW aggregated_stats_view AS
SELECT 
    g.group_id,
    g.name,
    COUNT(p.post_id) AS posts_count
FROM user_groups g
LEFT JOIN posts p ON p.group_id = g.group_id
GROUP BY g.group_id, g.name;

-- Task4
CREATE VIEW advanced_aggregated_view AS
SELECT
    g.group_id,
    g.name,
    (SELECT COUNT(*) FROM group_members gm WHERE gm.group_id = g.group_id) AS members_count,
    (SELECT COUNT(*) FROM posts p WHERE p.group_id = g.group_id) AS posts_count,
    (SELECT COUNT(DISTINCT p.user_id) FROM posts p WHERE p.group_id = g.group_id) AS authors_count
FROM user_groups g;

-- Task5
CREATE VIEW ranked_entities_view AS
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(p.post_id) AS posts_count,
    ROW_NUMBER() OVER (
        ORDER BY COUNT(p.post_id) DESC, u.last_name, u.first_name
    ) AS user_rank
FROM users u
LEFT JOIN posts p ON p.user_id = u.user_id
GROUP BY u.user_id, u.first_name, u.last_name;

-- Task6
CREATE OR REPLACE VIEW running_totals_view AS
SELECT
    p.user_id,
    p.post_id,
    p.created_at,
    COUNT(*) OVER (
        PARTITION BY p.user_id
        ORDER BY p.created_at, p.post_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_posts_count
FROM posts p;

-- Task7
CREATE VIEW final_analytics_view AS
WITH author_posts AS (
    SELECT 
        g.group_id,
        g.name AS group_name,
        u.user_id,
        u.first_name AS author_first_name,
        u.last_name AS author_last_name,
        COUNT(p.post_id) AS posts_count
    FROM posts p
    JOIN user_groups g ON p.group_id = g.group_id
    JOIN users u ON p.user_id = u.user_id
    GROUP BY g.group_id, g.name, u.user_id, u.first_name, u.last_name
),
ranked AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY group_id 
            ORDER BY posts_count DESC, author_last_name, author_first_name
        ) AS position_in_group
    FROM author_posts
)
SELECT 
    group_id, group_name, user_id, 
    author_first_name, author_last_name, 
    posts_count, position_in_group
FROM ranked
WHERE position_in_group <= 2;