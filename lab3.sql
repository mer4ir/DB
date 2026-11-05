-- Task1
INSERT INTO comments (post_id, user_id, content, created_at)
SELECT 
    p.post_id,
    u.user_id,
    'Очень интересная тема для обсуждения!',
    '2024-08-01 12:00:00'
FROM posts p
JOIN user_groups g ON p.group_id = g.group_id
JOIN users u ON u.email = 'ivan.ivanov@example.com'
WHERE g.name = 'Группа любителей кино'
  AND p.created_at = '2023-01-01 12:00:00';

-- Task2
SELECT member_id, role_id
FROM group_members gm
JOIN users u ON gm.user_id = u.user_id
JOIN user_groups g ON gm.group_id = g.group_id
WHERE u.email = 'ivan.ivanov@example.com'
  AND g.name = 'Группа любителей кино';

-- Task3
SELECT 
    g.name AS group_name,
    u.first_name,
    u.last_name,
    p.created_at,
    p.content
FROM posts p
JOIN user_groups g ON p.group_id = g.group_id
JOIN users u ON p.user_id = u.user_id
WHERE g.name = 'Группа любителей кино'
  AND p.created_at >= '2023-01-01 00:00:00'
ORDER BY p.created_at DESC;

-- Task4
SELECT g.name
FROM user_groups g
WHERE NOT EXISTS (
    SELECT 1 
    FROM posts p 
    WHERE p.group_id = g.group_id
      AND p.created_at >= '2024-01-01 00:00:00'
      AND p.created_at <  '2025-01-01 00:00:00'
);

-- Task5
SELECT 
    g.name AS group_name,
    COUNT(DISTINCT p.post_id) AS posts_count,
    COUNT(c.comment_id) / NULLIF(COUNT(DISTINCT p.post_id), 0) AS avg_comments_per_post
FROM user_groups g
LEFT JOIN posts p ON p.group_id = g.group_id
LEFT JOIN comments c ON c.post_id = p.post_id
GROUP BY g.group_id, g.name
ORDER BY g.group_id;

-- Task6
SELECT 
    g.name AS group_name,
    COUNT(gm.member_id) AS members_count
FROM user_groups g
JOIN group_members gm ON gm.group_id = g.group_id
GROUP BY g.group_id, g.name
HAVING COUNT(gm.member_id) >= 3;

-- Task7
SELECT DISTINCT u.email
FROM comments c
JOIN posts p ON c.post_id = p.post_id
JOIN user_groups g ON p.group_id = g.group_id
JOIN users u ON c.user_id = u.user_id
WHERE g.name = 'Группа любителей кино';

-- Task8
SELECT 
    g.name AS group_name,
    COUNT(gm.member_id) AS members_count
FROM user_groups g
JOIN group_members gm ON gm.group_id = g.group_id
GROUP BY g.group_id, g.name
HAVING COUNT(gm.member_id) = (
    SELECT MAX(cnt)
    FROM (
        SELECT COUNT(*) AS cnt
        FROM group_members
        GROUP BY group_id
    ) AS group_counts
);

-- Task9
SELECT 
    group_name,
    email,
    posts_count,
    RANK() OVER (PARTITION BY group_id ORDER BY posts_count DESC) AS user_rank
FROM (
    SELECT 
        g.group_id,
        g.name AS group_name,
        u.user_id,
        u.email,
        COUNT(p.post_id) AS posts_count
    FROM posts p
    JOIN user_groups g ON p.group_id = g.group_id
    JOIN users u ON p.user_id = u.user_id
    GROUP BY g.group_id, g.name, u.user_id, u.email
) AS counted
ORDER BY group_name, user_rank;

-- Task10
SELECT 
    g.name AS group_name,
    p.post_id,
    p.created_at,
    COUNT(*) OVER (
        PARTITION BY p.group_id 
        ORDER BY p.created_at, p.post_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_posts_count
FROM posts p
JOIN user_groups g ON p.group_id = g.group_id
ORDER BY g.name, p.created_at, p.post_id;