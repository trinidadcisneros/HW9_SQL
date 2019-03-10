SHOW DATABASES;
USE sakila;
SHOW TABLES;
DESC actor;
SHOW CREATE TABLE actor;

-- * 1a. Display the first and last names of all actors from the table `actor`. DONE
SELECT 
	first_name, 
    last_name
FROM 
	actor;

-- * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT 
	UPPER(first_name), 
    UPPER(last_name), 
    concat(first_name, ' ', last_name) AS actor_name
FROM 
	actor
ORDER BY 
	actor_name ASC LIMIT 10;

-- * 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

DESC actor;
SELECT actor_id, first_name, last_name
FROM actor WHERE first_name = "Joe";
-- ID 9, Joe Swank

-- * 2b. Find all actors whose last name contain the letters `GEN`:\
SELECT *
FROM actor WHERE last_name LIKE '%GEN%';
-- Count = 4

-- * 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT *
FROM actor 
WHERE last_name LIKE '%LI%'
ORDER BY last_name ASC;
-- Count = 10

-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country
FROM country 
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- * 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).

ALTER TABLE actor
ADD COLUMN description BLOB AFTER last_name;

-- * 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor DROP description;

DESC actor;

-- * 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS total 
FROM actor 
GROUP BY last_name 
ORDER BY total DESC;

-- * 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS total
FROM actor
GROUP BY last_name
HAVING total > 2
ORDER BY total DESC;
--  Count = 20

-- * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
SELECT first_name, last_name
FROM actor
WHERE first_name LIKE '%GROUCHO%' AND last_name LIKE '%WILLIAMS%';
-- Count = 1

SET SQL_SAFE_UPDATES = 0; 
UPDATE actor 
SET 
first_name = REPLACE(first_name,'GROUCHO','HARPO') 
WHERE first_name LIKE '%GROUCHO%' AND last_name LIKE '%WILLIAMS%';
SET SQL_SAFE_UPDATES = 1;
 
SELECT first_name, last_name
FROM actor
WHERE first_name LIKE '%GROUCHO%' AND last_name LIKE '%WILLIAMS%';
-- Empty

-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

SET SQL_SAFE_UPDATES = 0; 
UPDATE actor 
SET 
first_name = REPLACE(first_name,'HARPO','GROUCHO') 
WHERE first_name LIKE '%HARPO%' AND last_name LIKE '%WILLIAMS%';
SET SQL_SAFE_UPDATES = 1;

-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;


-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT first_name, last_name, address
FROM staff
INNER JOIN address
ON (staff_id);

-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

SELECT 
	first_name, last_name, amount
FROM 
	staff s1
		INNER JOIN 
	payment p1 ON s1.staff_id = p1.staff_id
WHERE payment_date 
BETWEEN '2005-08-01' AND '2005-08-31';

DESC staff;

-- * 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT 
	title, COUNT(DISTINCT actor_id) AS total
FROM 
	film_actor
INNER JOIN film USING (film_id)
GROUP BY title;

-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

SELECT COUNT(title)
FROM film
WHERE title = 'Hunchback Impossible';
--  Only 1 version exists in the inventory

-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT 
	last_name, first_name, customer_id, SUM(amount) AS total
FROM 
	customer
		INNER JOIN 
	payment USING (customer_id)
GROUP BY customer_id
ORDER BY last_name ASC;

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

-- Solution using a subquery
SELECT title
FROM film
WHERE title LIKE 'K%' OR title LIKE 'Q%' AND language_id IN (
	SELECT language_id
	FROM language
	WHERE name = 'ENGLISH'
	);

-- Solution with inner join
SELECT title, name
FROM film
INNER JOIN language USING (language_id)
WHERE title LIKE 'K%' OR title LIKE 'Q%' ;

-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

-- Solution using subqueries
SELECT last_name, first_name
FROM actor
WHERE actor_id IN 
(
	SELECT actor_id
    FROM film_actor
    WHERE film_id IN
    (
    SELECT film_id
    FROM film
    WHERE title = 'Alone Trip'
    )
);

-- Solution using inner joins
SELECT title, last_name, first_name
FROM film
INNER JOIN film_actor USING (film_id)
INNER JOIN actor USING (actor_id)
WHERE title = "Alone Trip";

-- * 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT first_name, last_name, email, country
FROM country
INNER JOIN city USING (country_id)
INNER JOIN address USING (city_id)
INNER JOIN customer USING (address_id)
WHERE country LIKE '%CANADA%';

-- * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.

SELECT title, name
FROM category
INNER JOIN film_category USING(category_id)
INNER JOIN film_text USING(film_id)
WHERE name LIKE '%Family%';

-- * 7e. Display the most frequently rented movies in descending order.
SELECT title, COUNT(DISTINCT inventory_id) AS freq
FROM film
INNER JOIN inventory USING(film_id)
INNER JOIN rental USING(inventory_id)
GROUP BY title
ORDER BY freq DESC;

-- * 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT staff_id AS store_business, SUM(AMOUNT) as business
FROM store
INNER JOIN inventory USING (store_id)
INNER JOIN staff USING (store_id)
INNER JOIN payment USING (staff_id)
GROUP BY store_business
ORDER BY business DESC;

-- * 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country
FROM store
INNER JOIN address USING(address_id)
INNER JOIN city USING(city_id)
INNER JOIN country USING(country_id);

-- * 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT name, SUM(amount) AS total
FROM category
INNER JOIN film_category USING (category_id)
INNER JOIN inventory USING (film_id)
INNER JOIN rental USING (inventory_id)
INNER JOIN payment USING (rental_id)
GROUP BY name
ORDER BY total DESC;

-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_genres AS
SELECT name, SUM(amount) AS total
FROM category
INNER JOIN film_category USING (category_id)
INNER JOIN inventory USING (film_id)
INNER JOIN rental USING (inventory_id)
INNER JOIN payment USING (rental_id)
GROUP BY name
ORDER BY total DESC;

-- * 8b. How would you display the view that you created in 8a?
SELECT * FROM top_genres;

-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW top_genres;










