🎬 Netflix SQL Data Analysis Project

An end-to-end exploratory data analysis project built in MySQL, using a Netflix-style content dataset. The project covers database setup, data cleaning, aggregate analysis, and advanced SQL (window functions, CTEs).

📊 Dataset Overview

MetricValueTotal titles90Columns18TV Shows68Movies22Distinct genres13Distinct countries10Distinct cast leads81Date range added2013 – 2022

Columns: show_id, title, type, director, cast_lead, country, language, date_added, release_year, rating, duration_mins, seasons, genre, netflix_original, imdb_score, awards_won, budget_usd_millions, popularity_score

🛠️ Tools & Concepts Used


MySQL / MySQL Workbench
Database & table setup (CREATE DATABASE, RENAME TABLE, ALTER TABLE)
Data cleaning (UPDATE, NULL handling, type correction)
Aggregation (GROUP BY, HAVING, COUNT, AVG, ROUND)
Date functions (YEAR())
Window functions (DENSE_RANK() OVER, AVG() OVER (PARTITION BY ...))
CTEs (WITH ... AS)


🧹 Data Cleaning Log

StepActionReason1RENAME TABLE netflix_shows_extended TO netflixSimplify table name for querying2show_id set to INT PRIMARY KEYEnforce a unique identifier per title3Blank duration_mins → NULL, then column cast to INTTV Shows have no runtime — keep the field numeric and nullable instead of storing as text, so AVG()/MAX() still work4Blank seasons → NULL, then column cast to INTMovies have no season count — same reasoning as above5Blank director → NULLApplies mainly to TV Shows, where a single director isn't always listed6Blank cast_lead → NULLA few titles had no lead cast recorded7Duplicate title check (GROUP BY title HAVING COUNT(*) > 1)Confirmed 0 duplicate titles — dataset is clean on this dimension

Why numeric types matter here: an earlier version of this project stored missing duration_mins/seasons as text labels ('TV-Show', 'movie'). That blocked numeric functions like AVG() from running. Converting them to NULL + INT instead keeps the columns fully queryable while still correctly marking "not applicable."

📈 Key Insights

1. Content Mix

The library is TV-Show heavy: 68 TV Shows vs. 22 Movies (~76% / 24% split).

2. Highest-Rated Genres (avg IMDb score)

RankGenreAvg Score1Anime8.402Animation8.273Crime8.164Drama8.155Documentary8.14

Lowest: Mystery (7.15), Romance (7.28), Adventure (7.45) — these also have the fewest titles, so treat as directional, not definitive.

3. Content by Country

United States dominates with 56 of 90 titles (~62%), followed by India (13) and the United Kingdom (6). The remaining titles are spread thinly across Spain, South Korea, Mexico, Germany, Japan, Colombia, and France — a long tail of single-digit representation.

4. Content Growth Over Time

2013: 3    2017: 8    2020: 23
2014: 1    2018: 13   2021: 7
2015: 4    2019: 22   2022: 5
2016: 4

2019–2020 account for 50% of all titles in the dataset — a sharp acceleration matching Netflix's real-world content investment surge in that period.

5. Top-Rated Title Per Genre (corrected DENSE_RANK ... DESC)

GenreTop TitleScoreCrimeBreaking Bad9.5DramaKota Factory9.1ComedyGullak8.9Sci-Fi & FantasyDark8.8AnimationBoJack Horseman8.7DocumentaryMaking a Murderer8.6ThrillerThe Haunting of Hill House8.6ActionSpecial Ops8.5RomanceLittle Things8.5AnimeKaguya-sama: Love Is War8.4FantasyPan's Labyrinth8.2MysteryThe Outsider7.7AdventureOuter Banks7.6

6. Overall Highest-Rated Title

Breaking Bad (9.5) tops the entire catalog. Crime and Sci-Fi & Fantasy each place 3 titles in the catalog-wide top 10 — these genres don't just score well on average, they also produce the most consistent standout titles.

7. Runtime & Season Patterns


Average movie duration: 118.1 minutes
Longest movie: The Irishman (209 min) — nearly 2x the average; RRR (187 min) is second
Most seasons (tied at 7): Elite, Orange Is the New Black, Grace and Frankie, Chef's Table


🔍 Sample Queries

sql-- Corrected: highest-rated title per genre
SELECT title, genre, imdb_score,
DENSE_RANK() OVER (PARTITION BY genre ORDER BY imdb_score DESC) AS rnk
FROM netflix;

-- Corrected: highest-rated title across the whole catalog
SELECT title, genre, imdb_score,
DENSE_RANK() OVER (ORDER BY imdb_score DESC) AS rnk
FROM netflix;

-- Each title vs. its genre's average score
SELECT title, genre, imdb_score,
ROUND(AVG(imdb_score) OVER (PARTITION BY genre), 2) AS avg
FROM netflix;

-- CTE: genre-level summary table
WITH genre_avg AS (
    SELECT genre, ROUND(AVG(imdb_score),1) AS avg_score
    FROM netflix GROUP BY genre
)
SELECT * FROM genre_avg ORDER BY avg_score DESC;
