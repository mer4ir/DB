USE sakila;

-- Task1
SELECT 
    payment_id,
    amount,
    payment_date
FROM payment
WHERE amount BETWEEN 10.00 AND 11.99
ORDER BY amount DESC, payment_date ASC;

-- Task2
SELECT DISTINCT first_name
FROM actor
WHERE last_name IN ('CHASE', 'CROWE', 'DAVIS')
ORDER BY first_name ASC;

-- Task3
SELECT 
    f.title,
    f.release_year
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
JOIN actor a ON fa.actor_id = a.actor_id
WHERE a.first_name = 'PENELOPE' AND a.last_name = 'GUINESS';

-- Task4 
SELECT 
    c.first_name,
    c.last_name,
    p.amount
FROM customer c
LEFT JOIN payment p 
    ON c.customer_id = p.customer_id 
   AND p.amount > 10.00;

-- Task5
SELECT 
    c.store_id,
    SUM(p.amount) AS amount_sum
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.store_id;

-- Task6
SELECT 
    a.first_name,
    a.last_name,
    COUNT(fa.film_id) AS films_count
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
HAVING COUNT(fa.film_id) > 25;

-- Task7
SELECT 
    c.first_name,
    c.last_name,
    SUM(p.amount) AS amount_sum
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY amount_sum DESC, c.last_name ASC, c.first_name ASC
LIMIT 10;

-- Task8
SELECT 
    a.first_name,
    a.last_name,
    COUNT(fa.film_id) AS films_count
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
HAVING COUNT(fa.film_id) = (
    SELECT MAX(films_count)
    FROM (
        SELECT COUNT(film_id) AS films_count
        FROM film_actor
        GROUP BY actor_id
    ) AS sub
);

-- Task9
