-- Task1
SELECT post_id, group_id, user_id, created_at
FROM posts
WHERE group_id = 1
  AND created_at >= '2023-01-01';


-- Task2
CREATE INDEX idx_posts_group_created ON posts (group_id, created_at);

-- Task3
SELECT p.post_id, p.created_at, c.comment_id, c.user_id
FROM posts p
JOIN comments c ON c.post_id = p.post_id
WHERE p.created_at > '2023-01-01';


-- Task4
CREATE INDEX idx_comments_post_id ON comments (post_id);


-- Task5
SELECT
    group_id,
    name,
    CAST(metadata->>'$.location' AS CHAR(50)) COLLATE utf8mb4_bin AS location_info
FROM user_groups
WHERE CAST(metadata->>'$.location' AS CHAR(50)) COLLATE utf8mb4_bin = 'Москва';


-- Task6
CREATE INDEX idx_groups_location
    ON user_groups ((CAST(metadata->>'$.location' AS CHAR(50)) COLLATE utf8mb4_bin));


-- Task7
CREATE PROCEDURE atomic_post_procedure(
    IN p_group_id INT,
    IN p_user_id INT,
    IN p_force_error BOOLEAN
)
BEGIN
    DECLARE v_post_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    INSERT INTO posts (group_id, user_id, content, created_at)
    VALUES (p_group_id, p_user_id, 'Автоматически созданная публикация', NOW());

    SET v_post_id = LAST_INSERT_ID();

    INSERT INTO post_operation_log (post_id, operation_note)
    VALUES (v_post_id, IF(p_force_error, NULL, 'created'));

    COMMIT;
END


-- Task8
CREATE PROCEDURE savepoint_post_procedure(
    IN p_group_id INT,
    IN p_user_id INT,
    IN p_force_second_error BOOLEAN
)
BEGIN
    DECLARE v_post_id INT;

    START TRANSACTION;

    INSERT INTO posts (group_id, user_id, content, created_at)
    VALUES (p_group_id, p_user_id, 'Первый пост', NOW());
    SET v_post_id = LAST_INSERT_ID();

    INSERT INTO post_operation_log (post_id, operation_note)
    VALUES (v_post_id, 'created');

    SAVEPOINT sp_second;

    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
            ROLLBACK TO SAVEPOINT sp_second;

        INSERT INTO posts (group_id, user_id, content, created_at)
        VALUES (p_group_id, p_user_id, 'Второй пост', NOW());
        SET v_post_id = LAST_INSERT_ID();

        INSERT INTO post_operation_log (post_id, operation_note)
        VALUES (v_post_id, IF(p_force_second_error, NULL, 'created'));
    END;

    COMMIT;
END


-- Task8
-- READ UNCOMMITTED vs READ COMMITTED (грязное чтение). Две сессии, post_id = 1.
--
-- READ UNCOMMITTED: грязное чтение возможно
-- Сессия 1:
--   SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
--   START TRANSACTION;
--   SELECT post_id, content FROM posts WHERE post_id = 1;
-- Сессия 2:
--   START TRANSACTION;
--   UPDATE posts SET content = CONCAT(content, ' [edited]') WHERE post_id = 1;   -- без COMMIT
-- Сессия 1:
--   SELECT post_id, content FROM posts WHERE post_id = 1;   -- виден текст с [edited]
-- Сессия 2:
--   ROLLBACK;
-- Сессия 1:
--   COMMIT;
--
-- READ COMMITTED: грязного чтения нет
-- Сессия 1:
--   SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
--   START TRANSACTION;
--   SELECT post_id, content FROM posts WHERE post_id = 1;
-- Сессия 2:
--   START TRANSACTION;
--   UPDATE posts SET content = CONCAT(content, ' [edited]') WHERE post_id = 1;   -- без COMMIT
-- Сессия 1:
--   SELECT post_id, content FROM posts WHERE post_id = 1;   -- исходный текст
--   COMMIT;
-- Сессия 2:
--   ROLLBACK;


-- Task9
-- READ COMMITTED vs REPEATABLE READ (неповторяющееся чтение). Две сессии, post_id = 1.
--
-- READ COMMITTED: повторное чтение меняется
-- Сессия 1:
--   SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
--   START TRANSACTION;
--   SELECT post_id, content FROM posts WHERE post_id = 1;   -- исходный текст
-- Сессия 2:
--   UPDATE posts SET content = CONCAT(content, ' [edited]') WHERE post_id = 1;   -- автокоммит
-- Сессия 1:
--   SELECT post_id, content FROM posts WHERE post_id = 1;   -- текст с [edited]
--   COMMIT;
-- (вернуть: UPDATE posts SET content = REPLACE(content, ' [edited]', '') WHERE post_id = 1;)
--
-- REPEATABLE READ: повторное чтение стабильно
-- Сессия 1:
--   SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
--   START TRANSACTION;
--   SELECT post_id, content FROM posts WHERE post_id = 1;   -- исходный текст
-- Сессия 2:
--   UPDATE posts SET content = CONCAT(content, ' [edited]') WHERE post_id = 1;   -- автокоммит
-- Сессия 1:
--   SELECT post_id, content FROM posts WHERE post_id = 1;   -- по-прежнему исходный текст
--   COMMIT;
-- (вернуть: UPDATE posts SET content = REPLACE(content, ' [edited]', '') WHERE post_id = 1;)