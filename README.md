🎬 Streaming Content Analytics — MySQL + Power BI

An end-to-end data analysis project: raw data cleaned and analyzed in MySQL, modeled into a star/snowflake schema, and visualized in an interactive Power BI dashboard.

Pipeline: Raw CSV → MySQL (cleaning, EDA, window functions, CTEs) → Power Query (dimensional modeling) → DAX measures → Power BI dashboard

📊 Dataset Overview
Metric	Value
Total titles	90
TV Shows	68
Movies	22
Distinct genres	13
Distinct countries	10
Distinct languages	8
Date range added	2014 – 2022
Netflix Originals	81% of catalog

🛠️ Tools & Concepts Used
MySQL / MySQL Workbench — schema setup, cleaning, aggregation, window functions, CTEs
Power Query — dimensional modeling (fact/dimension split), data type correction, custom columns
Power BI — DAX measures, relationship modeling, interactive dashboard, slicers

🧹 Data Cleaning (MySQL)
Step	Action	Reason
show_id → INT PRIMARY KEY	Enforce unique identifier	Data integrity
Blank duration_mins → NULL, column cast to INT	TV Shows have no runtime	Keeps column numeric/queryable instead of storing text placeholders
Blank seasons → NULL, column cast to INT	Movies have no season count	Same reasoning
Blank director → NULL	Applies mainly to TV Shows	Avoids empty-string artifacts
Blank cast_lead → NULL	A few titles had no lead cast recorded	Avoids empty-string artifacts
Duplicate title check	GROUP BY title HAVING COUNT(*) > 1	Confirmed 0 duplicates
Ranking bug fix	Added DESC to DENSE_RANK() calls	Original queries ranked ascending, incorrectly surfacing lowest-rated titles as "top"

🧱 Data Model (Star/Snowflake Schema)

Built in Power Query using Reference + Remove Duplicates + Index to split the flat table into a fact table and supporting dimensions:

fact table:        netflix (measures: imdb_score, budget_usd_millions,
                    awards_won, popularity_score, duration_mins, date, etc.)

dimension tables:  dim_title    (title, director, cast_lead, netflix_original, show_id)
                   dim_genre    (genre, genre_id)
                   dim_country  (country, country_id)
                   dim_lang     (language, lang_id)
                   dim_dim_type (type, type_id)  -- Movie / TV Show

Deliberately excluded as dimensions: director and cast_lead were kept as attributes inside dim_title rather than split into their own tables — most values appear on only one title, so there's minimal repetition to normalize away, and modeling cast properly would require a many-to-many bridge table, which was out of scope for this project's grain.

Known issue caught & fixed: an early version of the netflix ↔ dim_title relationship allowed a fan-out that inflated the "titles by year" line chart (showing 30–60 titles/year against a 90-title total). Diagnosed via a COUNTROWS(netflix) sanity-check card and resolved by correcting the relationship cardinality/direction.

📐 Key DAX Measures
dax
No of Movies =
CALCULATE(DISTINCTCOUNT(dim_title[show_id]), dim_dim_type[type] = "Movie")

No of TV Shows =
CALCULATE(DISTINCTCOUNT(dim_title[show_id]), dim_dim_type[type] = "TV Show")

% Netflix Originals =
DIVIDE(
    CALCULATE(COUNTROWS(netflix), dim_title[netflix_original] = "Yes"),
    COUNTROWS(netflix),
    0
)

Avg IMDb Score = ROUND(AVERAGE(netflix[imdb_score]), 2)

IMDb Category =
SWITCH(
    TRUE(),
    netflix[imdb_score] >= 8.5, "Excellent",
    netflix[imdb_score] >= 7.5, "Very Good",
    netflix[imdb_score] >= 6.5, "Good",
    netflix[imdb_score] >= 5.5, "Average",
    "Below Average"
)
📈 Dashboard

Layout: left-side filter panel (Type, Genre, Netflix Original, Language) + KPI row + 4 supporting visuals.

Visual	Type	Why this chart
Titles by Country	Horizontal bar, sorted descending	Independent category comparison — bar/column is the correct chart for this, not funnel or pie (too many categories)
Titles by Year	Line chart	Genuinely sequential/time-based data
Content Quality Distribution	Pie chart	Only 4 categories — appropriate range for a pie; given distinct (non-monochrome) colors so slices are distinguishable
Budget vs. Rating	Scatter (bubble size = popularity)	Reveals relationship between two continuous variables

KPI cards: Total Titles, Average Score, Movies, TV Shows, % Netflix Originals

💡 Key Insights
Catalog is TV-Show heavy: 68 TV Shows vs. 22 Movies (~76%/24% split).
US dominance: United States accounts for 56 of 90 titles (~62%), followed by India and the UK.
Growth peaked in 2019–2020: content additions rose sharply, peaked around 2019–2020, then declined — visible clearly once the model's fan-out bug was fixed.
81% of the catalog is Netflix Original content, vs. 19% licensed.
Budget doesn't guarantee rating: the scatter plot shows most titles cluster at low budgets with mid-to-high ratings; a few high-budget outliers (>$100M) don't consistently score higher — spending more doesn't reliably buy a better score in this dataset.
Genre averages are directional, not definitive: genres like Anime and Animation top the average-score charts but have very few titles each, so they were deliberately left out of headline KPI cards to avoid overstating a small-sample result — a judgment call favoring statistical honesty over a flashier stat.
🔍 Chart-Type Decisions (and rejected alternatives)
Funnel chart was considered and rejected for both "titles by country" and "budget by genre" — funnel charts imply a sequential, narrowing process (like a sales pipeline), which doesn't exist in either of these independent-category comparisons. Bar/column charts were used instead.
Pie chart limited to categories with ≤5 values (IMDb Category) — genre/country were deliberately kept as bar charts since a pie chart with 10–13 slices becomes unreadable.

📁 Files
netflix.sql — full MySQL script (setup → cleaning → EDA → window functions → CTEs)
netflix_shows_extended.csv — source dataset
netflix_dashboard.pbix — Power BI dashboard file
README.md — this file

Below are some screenshots of the dashboard and data model

<img width="1027" height="716" alt="Screenshot 2026-07-27 092251" src="https://github.com/user-attachments/assets/5c0a21d8-311c-4bb0-8792-3a1936a32b8f" />
<img width="1309" height="721" alt="Screenshot 2026-07-27 092208" src="https://github.com/user-attachments/assets/a600f0ed-cd01-4fc8-a989-8bc03fde6331" />
<img width="1306" height="722" alt="Screenshot 2026-07-27 092233" src="https://github.com/user-attachments/assets/bd82d77d-829e-456c-b69a-0116c3dce9c4" />
