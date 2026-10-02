-- Task1
CREATE TABLE student (
    student_id VARCHAR(20) PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    birth_date DATE NOT NULL
);

CREATE TABLE teacher (
    teacher_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL
);

CREATE TABLE subject (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    semester INT NOT NULL,
    teacher_id INT NOT NULL,
    FOREIGN KEY (teacher_id) REFERENCES teacher(teacher_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE grade (
    student_id VARCHAR(20) NOT NULL,
    subject_id INT NOT NULL,
    grade_value INT NOT NULL CHECK (grade_value BETWEEN 2 AND 5),
    PRIMARY KEY (student_id, subject_id),
    FOREIGN KEY (student_id) REFERENCES student(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subject(subject_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);


-- Task2
INSERT INTO teacher (teacher_id, full_name) VALUES 
(1, 'Иванов Иван Иванович'),
(2, 'Петрова Анна Сергеевна');

INSERT INTO student (student_id, full_name, birth_date) VALUES 
('210101', 'Иванченко Алексей Сергеевич', '2004-03-15'),
('210102', 'Иванова Мария Игоревна', '2005-07-22'),
('210103', 'Сидоров Пётр Алексеевич', '2004-11-05');

INSERT INTO subject (subject_id, title, semester, teacher_id) VALUES 
(1, 'Базы данных', 1, 1),
(2, 'Математика', 1, 2);

INSERT INTO grade (student_id, subject_id, grade_value) VALUES 
('210101', 1, 5),
('210101', 2, 4),
('210102', 1, 5),
('210102', 2, 5),
('210103', 1, 3);

UPDATE grade 
SET grade_value = 4 
WHERE student_id = '210103' AND subject_id = 1;

DELETE FROM grade 
WHERE student_id = '210103' AND subject_id = 1;


-- Task3
SELECT * 
FROM subject;


-- Task4
SELECT COUNT(*) AS total_students 
FROM student;


-- Task5
SELECT * 
FROM student 
WHERE full_name LIKE 'Ива%' 
ORDER BY 
    SUBSTRING_INDEX(full_name, ' ', 1),
    SUBSTRING_INDEX(SUBSTRING_INDEX(full_name, ' ', 2), ' ', -1);


-- Task6
SELECT 
    subject.subject_id,
    title AS subject_title,
    COUNT(grade.student_id) AS students_count
FROM subject
LEFT JOIN grade ON subject.subject_id = grade.subject_id
GROUP BY subject.subject_id, title;

-- Task7
SET @min_excellent = 1;

SELECT 
    subject.subject_id,
    title AS subject_title,
    COUNT(grade.student_id) AS count_excellent_students
FROM subject
JOIN grade ON subject.subject_id = grade.subject_id
WHERE grade_value = 5
GROUP BY subject.subject_id, title
HAVING COUNT(grade.student_id) >= @min_excellent
ORDER BY title ASC;


-- Task8
SELECT 
    student.student_id,
    full_name
FROM student
JOIN grade ON student.student_id = grade.student_id
JOIN subject ON grade.subject_id = subject.subject_id
WHERE semester = 1
GROUP BY student.student_id, full_name
HAVING MIN(grade_value) IN (4, 5);