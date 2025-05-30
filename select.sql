USE sakila;

SELECT * FROM actor;
SELECT first_name, last_name FROM actor
	WHERE first_name LIKE 's%' ORDER BY last_name;
    
SELECT title, length FROM film
	WHERE length >= 50 AND length <= 100
    ORDER BY length;
    
SELECT language_id, count(film_id) from film GROUP BY rating;
SELECT rating, count(film_id) from film group by language_id;

SELECT rating, avg(rental_rate) as 'media do valor de locação'
	from film GROUP BY rating ORDER BY 2;
    
SELECT rating as 'classificação', avg(rental_rate) AS 'media do valor de locação'
	from film 
    WHERE length > 50 OR length < 40
    GROUP BY rating
    ORDER BY 2 desc
    LIMIT 2;
    
SELECT
city.city as 'cidade',
country.country as 'pais'
from city
INNER JOIN country on city.country_id = country.country_id;

select * from city c
INNER join country co on c.country_id = co.country_id
WHERE country = 'brazil';