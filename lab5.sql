-- Task1 
CREATE FUNCTION business_metric_function(target_created_at DATETIME)
RETURNS INT
BEGIN
    RETURN TIMESTAMPDIFF(DAY, target_created_at, NOW());
END


-- Task2
CREATE FUNCTION business_category_function(
    target_created_at DATETIME
)
RETURNS VARCHAR(20)
BEGIN
    DECLARE v_days INT;

    SET v_days = business_metric_function(target_created_at);

    IF v_days < 7 THEN
        RETURN 'fresh';
    ELSEIF v_days <= 30 THEN
        RETURN 'active';
    ELSE
        RETURN 'archive';
    END IF;
END


-- Task3
CREATE PROCEDURE report_procedure()
BEGIN
    SELECT
        p.post_id,
        g.name AS group_name,
        u.first_name,
        u.last_name,
        p.created_at,
        business_metric_function(p.created_at)   AS post_age_days,
        business_category_function(p.created_at) AS post_category,
        (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.post_id) AS comments_count
    FROM posts p
    JOIN user_groups g ON g.group_id = p.group_id
    JOIN users       u ON u.user_id  = p.user_id;
END


-- Task4
CREATE PROCEDURE action_procedure(
    IN p_email      VARCHAR(255),
    IN p_group_name VARCHAR(255),
    IN p_content    TEXT,
    IN p_created_at DATETIME
)
BEGIN
    DECLARE v_user_id  INT;
    DECLARE v_group_id INT;

    SELECT user_id INTO v_user_id
    FROM users
    WHERE email COLLATE utf8mb4_0900_ai_ci = p_email COLLATE utf8mb4_0900_ai_ci
    LIMIT 1;

    SELECT group_id INTO v_group_id
    FROM user_groups
    WHERE name COLLATE utf8mb4_0900_ai_ci = p_group_name COLLATE utf8mb4_0900_ai_ci
    LIMIT 1;

    IF v_user_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Пользователь с таким email не найден';
    END IF;
    IF v_group_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Группа с таким названием не найдена';
    END IF;

    INSERT INTO posts (group_id, user_id, content, created_at)
    VALUES (v_group_id, v_user_id, p_content, p_created_at);
END


-- Task5
CREATE TRIGGER autofill_trigger
BEFORE INSERT ON posts
FOR EACH ROW
BEGIN
    IF NEW.created_at IS NULL THEN
        SET NEW.created_at = NOW();
    END IF;
END


-- Task6
CREATE TRIGGER validation_trigger
BEFORE INSERT ON posts
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM group_members
                   WHERE group_id = NEW.group_id AND user_id = NEW.user_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Пользователь не состоит в выбранной группе';
    END IF;
END


-- Task7
CREATE TRIGGER audit_trigger
AFTER DELETE ON posts
FOR EACH ROW
BEGIN
    INSERT INTO post_audit_log (post_id, operation_note)
    VALUES (OLD.post_id, 'DELETE');
END


-- Task8
CREATE PROCEDURE workflow_procedure(
    IN p_post_id      INT,
    IN p_author_email VARCHAR(255)
)
BEGIN
    DECLARE v_found     INT DEFAULT 0;
    DECLARE v_post_user INT;
    DECLARE v_author_id INT;
    DECLARE v_comments  INT DEFAULT 0;

    SELECT COUNT(*), MAX(user_id) INTO v_found, v_post_user
    FROM posts
    WHERE post_id = p_post_id;

    IF v_found = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Пост не найден';
    END IF;

    SELECT user_id INTO v_author_id
    FROM users
    WHERE email COLLATE utf8mb4_0900_ai_ci = p_author_email COLLATE utf8mb4_0900_ai_ci
    LIMIT 1;

    IF v_author_id IS NULL OR v_author_id <> v_post_user THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Пользователь не является автором поста';
    END IF;

    SELECT COUNT(*) INTO v_comments
    FROM comments
    WHERE post_id = p_post_id;

    IF v_comments > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'У поста есть комментарии, удаление невозможно';
    END IF;

    DELETE FROM posts WHERE post_id = p_post_id;
END