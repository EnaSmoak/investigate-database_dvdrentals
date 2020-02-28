/* <Query 1 - Who are the top 10 paying customers and what are their detials?>
*/
WITH t1 
AS (
	SELECT *, (first_name|| ' '|| last_name)AS full_name
	FROM customer
)
SELECT full_name, email, address, phone, city, country, sum(amount)
	AS total_amount
FROM t1
JOIN address ON (address.address_id = t1.address_id)
JOIN city ON (city.city_id = address.city_id)
JOIN country ON (country.country_id = city.country_id)
JOIN payment ON (payment.customer_id = t1.customer_id)
GROUP BY full_name, email, phone, city, country, address
ORDER BY address
LIMIT 10;


/* <Query 2> -Can you provide a table with the movie titles and divide them 
	into 4 levels (first_quarter, second_quarter, third_quarter, and final_quarter) 
	based on the quartiles (25%, 50%, 75%) of the rental duration for movies across all categories? Family-friendly movie categories
*/
SELECT f.title, c.name, f.rental_duration, NTILE(4) OVER (ORDER BY f.rental_duration) AS standard_quartile
FROM film_category fcat
JOIN category c
ON c.category_id = fcat.category_id
JOIN film f
ON f.film_id = fcat.film_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
ORDER BY 3;



/* <Query 3> - Number of rented films 
	that were returned late, early and on time
*/
WITH t1 AS (
	SELECT *, DATE_PART('day', return_date - rental_date)
	AS date_difference
	FROM rental
),
t2 AS (
	SELECT rental_duration, date_difference,
		CASE
			WHEN rental_duration > date_difference THEN 'Returned early'
			WHEN rental_duration = date_difference THEN 'Returned on time'
			ELSE 'Returned late'
		END AS return_status
	FROM film f
	JOIN inventory i ON(i.film_id = f.film_id)
	JOIN t1 ON (t1.inventory_id = i.inventory_id)
)
SELECT return_status, count(*) AS total_no_of_films
FROM  t2
GROUP BY 1
ORDER BY 2 DESC;



/* <Query 4> - Create a query that lists each movie, 
	the film category it is classified in, and the number of times it has been rented out.
*/
SELECT f.title AS film_title, c.name AS category_name, COUNT(r.rental_id) AS rental_count
FROM film_category fc
JOIN category c
ON c.category_id = fc.category_id
JOIN film f
ON f.film_id = fc.film_id
JOIN inventory i
ON i.film_id = f.film_id
JOIN rental r 
ON r.inventory_id = i.inventory_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
GROUP BY 1, 2
ORDER BY rental_count DESC;

