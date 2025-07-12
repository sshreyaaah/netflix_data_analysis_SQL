create database netflix_data_analysis;
use netflix_data_analysis;

-- Ques1. count the no of movies vs tv shows
SELECT type, COUNT(*) AS count 
from dataset
group by 1; -- this means that we want to group acc to to the first col in the select clause.

-- Ques2. find the most common rating for the movies and tv shows.
	-- we cant use max function caz our input is of string format and we cant apply min-max on strings.
select type, rating, count(*)
from dataset
group by 1,2 -- first group by type col then rating col
order by 1,3 desc; -- print them in desc order based on first the type then count col.
	-- this will get us the highest count value for each category and their corresponding categories.
-- to get the most common rating for each category we are filtering out the reults using where clause.
select type,rating
from 
(
-- to select the rating with highest count value for each category we will be using ranking function with partition.
select type, rating, count(*), rank() over (PARTITION BY type ORDER BY COUNT(*)) as ranking
from dataset
group by 1,2
order by 1,3 desc
) as t1 -- storing these queries and its result under t1.
where ranking=1; -- this will filter out and generate only the results where ranking is 1 displaying the most common rating for movies and tv shows.

-- ques3. list all movies released in a specific year (eg. 2021)
select *
from dataset
where release_year=2021;

-- ques4. find the top5 countries with the most content on netflix
/*again we will be using subquery sytem like we did in ques 2. 
first we will store all the strings in an array seperated by (,) then count the occurence of each country
then use where clause to make sure no col contains null value for country and count 
lastly sort them in desc order using count clause and limit it to 5 displaying the top 5 countries. */
SELECT country, COUNT(*) AS total_content
FROM (
    SELECT TRIM(j.country) AS country -- selecting individual countries after splitting
    FROM dataset,
		-- splitting happens in this section of the code
         JSON_TABLE( -- json_table is func that converts json array into rows
            CONCAT('["', REPLACE(country, ',', '","'), '"]'), 
            /* replace makes the string "a,b,c" look like "a","b","c"
            concat wraps the updatesd string in square braces[]*/
            "$[*]" COLUMNS (country VARCHAR(100) PATH "$") 
            /*
            $[*] -> targets every element of the array
            columns.... -> each array becomes rows and map the value at each index denoted by $ to col named country */
         ) AS j
) AS sub
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

-- ques 5. identify the longest movie.
SELECT *
FROM dataset
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;
/*
SUBSTRING_INDEX(duration, ' ', 1) -> extracts the first word from duration col. 
	it takes the substring before the first space.
CAST(...UNSIGNED) -> converts extracted string to number.
order by sorts in desc order
*/

-- ques6. find the content added in the last 5 years
SELECT *
FROM dataset
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;

-- ques7. find all the movies/tv show directed by 'rajiv chilaka'
SELECT *
FROM (
SELECT n.*, TRIM(d.director_name) AS director_name
FROM dataset AS n,
JSON_TABLE(
CONCAT('["', REPLACE(director, ',', '","'), '"]'),
"$[*]" COLUMNS (director_name VARCHAR(255) PATH "$")
) AS d
) AS t
WHERE director_name = 'Rajiv Menon';


-- ques8. list all tv shows with more than 5 seasons
SELECT *
FROM dataset
WHERE type = 'TV Show'
AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;

-- ques9. count the no of content items in each game
SELECT genre, COUNT(*) AS total_content
FROM (
SELECT TRIM(j.genre) AS genre
FROM dataset,
JSON_TABLE(
 CONCAT('["', REPLACE(listed_in, ',', '","'), '"]'),
 "$[*]" COLUMNS (genre VARCHAR(100) PATH "$")
) AS j
) AS genre_table
GROUP BY genre
ORDER BY total_content DESC;

-- ques10. find each year and average no of content released in india on netflix
SELECT 
country,
release_year,
COUNT(show_id) AS total_release,
ROUND(
COUNT(show_id) * 100.0 /
(SELECT COUNT(show_id) FROM dataset WHERE country = 'India'),
2
) AS avg_release
FROM dataset
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

-- ques11. list all movies that are documentries
SELECT * 
FROM dataset
WHERE listed_in LIKE '%Documentaries';

-- ques 12. find all content without a director
select *
from dataset
where director is null;

-- ques13. find how many movies actor 'salman khan' appeared in last 10 years
SELECT * 
FROM dataset
WHERE cast LIKE '%Salman Khan%'
AND release_year > YEAR(CURDATE()) - 10;
  
  -- ques14. find top10 actors who have appeared in the highest no of movies produced in india 
SELECT actor, COUNT(*) AS appearances
FROM (
SELECT TRIM(j.actor) AS actor
FROM dataset,
JSON_TABLE(
CONCAT('["', REPLACE(cast, ',', '","'), '"]'),
"$[*]" COLUMNS (actor VARCHAR(255) PATH "$")
) AS j
WHERE country = 'India'
) AS actor_table
GROUP BY actor
ORDER BY appearances DESC
LIMIT 10;

-- ques15. categorize content based on the presence of 'kill' and 'violence' keywords
SELECT 
category,
COUNT(*) AS content_count
FROM (
SELECT 
CASE 
WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad'
ELSE 'Good'
END AS category
FROM dataset
) AS categorized_content
GROUP BY category;
