 create database project;
 use project;
 
 show tables;
 rename table netflix_shows_extended to netflix;
 select * from netflix;
 select * from netflix limit 10;
 
 desc netflix;
 alter table netflix
 modify column show_id int primary key;
 select count(*) as total_rows from netflix;
 
 select distinct genre from netflix;
 select count(distinct genre) from netflix;
 select distinct country from netflix;
 select count(distinct cast_lead) from netflix;
 select distinct cast_lead from netflix;
UPDATE netflix
SET duration_mins = NULL
WHERE duration_mins = '';
UPDATE netflix
SET seasons = NULL
WHERE seasons = '';
ALTER TABLE netflix
MODIFY COLUMN duration_mins INT;
ALTER TABLE netflix
MODIFY COLUMN seasons INT;
update netflix
set director=NULL
where director='';
select title, count(*) from netflix group by title
having count(*)>1;
select * from netflix;
update netflix
set cast_lead=NULL
where cast_lead='';


select count(show_id) as total_shows, type
from netflix group by type;
select country, count(*) as total from netflix
group by country order by total desc;
select genre, round(avg(imdb_score),2) as avg_score from netflix 
group by genre order by avg_score desc;
select year(date_added) as yr, count(*) as total
from netflix group by yr order by yr;
SELECT ROUND(AVG(duration_mins), 1) AS avg_movie_duration
FROM netflix
WHERE type = 'Movie';
SELECT title, duration_mins
FROM netflix
WHERE type = 'Movie'
ORDER BY duration_mins DESC
LIMIT 5;
SELECT title, seasons
FROM netflix
WHERE type = 'TV Show'
ORDER BY seasons DESc;

select title, genre, imdb_score,
dense_rank() over (partition by genre order by imdb_score desc) as rnk
from netflix;
select title, genre, imdb_score,
dense_rank() over (order by imdb_score desc) as rnk
from netflix;
select title, genre, imdb_score,
round(avg(imdb_score) over (partition by genre), 2) as avg
from netflix;

with genre_avg as(
	select genre, round(avg(imdb_score),1) as avg_score from netflix group by genre
    )
select * from genre_avg order by avg_score desc;
