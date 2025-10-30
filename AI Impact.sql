CREATE DATABASE Future_AI_Job;
USE Future_AI_Job;
-- Drop DATABASE Future_AI_Job;

CREATE TABLE InvestmentAnalystJobs (
    Job_Title VARCHAR(100),
    Industry VARCHAR(100),
    Job_Status VARCHAR(50),
    AI_Impact_Level VARCHAR(50),
    Median_Salary_USD DECIMAL(10,2),
    Required_Education VARCHAR(100),
    Experience_Required_Years INT,
    Job_Openings_2024 INT,
    Projected_Openings_2030 INT,
    Remote_Work_Ratio DECIMAL(5,2),
    Automation_Risk DECIMAL(5,2),
    Location VARCHAR(100),
    Gender_Diversity DECIMAL(5,2)
);

ALTER TABLE InvestmentAnalystJobs
RENAME TO AI_Job_Impact;

LOAD DATA LOCAL INFILE '/Users/akashsingh/Desktop/AI Impact on Job Market (2024–2030).csv'
INTO TABLE `AI_Job_Impact`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = TRUE;

-- Q1: What are the distinct industries in the dataset?
SELECT DISTINCT industry
FROM AI_Job_Impact
ORDER BY industry;

-- Q2: Average median salary by AI impact level?
SELECT 'AI Impact Level',
ROUND(AVG('Median Salary (USD)'), 2) AS avg_median_salary_usd,
COUNT(*) AS job_count
FROM AI_Job_Impact
GROUP BY 'AI Impact Level'
ORDER BY avg_median_salary_usd DESC;

-- Q3: List top 10 jobs by median salary (descending) with industry and location.
SELECT 'Job Title', Industry, Location, 'Median Salary (USD)'
FROM AI_Job_Impact
ORDER BY 'Median Salary (USD)' DESC
LIMIT 10;

-- Q4: Count of jobs by status (Increasing vs Decreasing) overall and by industry? 
SELECT Industry, 'Job Status', COUNT(*) AS Num_jobs
FROM AI_Job_Impact
GROUP BY Industry, 'Job Status'
ORDER BY Industry, Num_jobs DESC;

-- Q5: Jobs with largest projected growth (2024 → 2030)? Pending
SELECT 'Job Title', Industry, Location
FROM AI_Job_Impact
WHERE pct_change_2024_2030 IS NOT NULL
ORDER BY pct_change_2024_2030 DESC
LIMIT 10;

-- Q6: Locations with highest average median salary?
SELECT Location,
ROUND(AVG('Median Salary (USD)'), 2) AS Avg_median_salary_usd,
COUNT(*) AS job_count
FROM AI_Job_Impact
GROUP BY Location
HAVING COUNT(*) >= 3
ORDER BY Avg_median_salary_usd DESC
LIMIT 10;

-- Q7: Distribution of required education levels? 
SELECT 'Required Education', COUNT(*) AS Num_jobs
FROM AI_Job_Impact
GROUP BY 'Required Education'
ORDER BY Num_jobs DESC;

-- Q8: Industries with the largest share of High AI impact jobs?
SELECT
  Industry,
  COUNT(*) AS total_jobs,
  SUM(CASE WHEN 'AI Impact Level' = 'High' THEN 1 ELSE 0 END) AS High_impact_jobs,
  ROUND(100.0 * SUM(CASE WHEN 'AI Impact Level' = 'High' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_high_impact
FROM AI_Job_Impact
GROUP BY Industry
HAVING COUNT(*) >= 5
ORDER BY pct_high_impact DESC;

-- Q9: Does higher gender diversity associate with higher median salary? (bucket approach)?
-- Create buckets for gender_diversity_pct (e.g., 0-20, 20-40, ...).
-- For each bucket compute average median salary and number of jobs.

SELECT
  CASE
    WHEN 'Gender Diversity (%)' < 20 THEN '0-20'
    WHEN 'Gender Diversity (%)' < 40 THEN '20-40'
    WHEN 'Gender Diversity (%)' < 60 THEN '40-60'
    WHEN 'Gender Diversity (%)' < 80 THEN '60-80'
    ELSE '80-100'
  END AS Gender_diversity_bucket,
  COUNT(*) AS Jobs_in_bucket,
  ROUND(AVG('Median Salary (USD)'), 2) AS avg_median_salary_usd
FROM AI_Job_Impact
WHERE 'Gender Diversity (%)' IS NOT NULL
GROUP BY Gender_diversity_bucket
ORDER BY Gender_diversity_bucket;

-- Q10: Industry summary table (total jobs, avg salary, % increasing, avg gender diversity)?
SELECT
  Industry,
  COUNT(*) AS total_jobs,
  ROUND(AVG('Median Salary (USD)'), 2) AS avg_median_salary_usd,
  ROUND(100.0 * SUM(CASE WHEN 'Job Status' = 'Increasing' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_increasing,
  ROUND(AVG('Gender Diversity (%)'), 2) AS avg_gender_diversity_pct
FROM AI_Job_Impact
GROUP BY Industry
ORDER BY total_jobs DESC;

-- Q11: Top jobs by absolute change in employed numbers (if employed_2024 and pct change can be used):
-- If you want the projected absolute increase between 2024 and 2030
-- compute projected_employed_2030 = employed_2024 * (1 + pct_change_2024_2030/100)
-- Compute absolute_change = projected_employed_2030 - employed_2024.
SELECT
  ('Job Openings (2024)' * (1 + 'Projected Openings (2030)' / 100.0)) AS projected_employed_2030,
  ('Job Openings (2024)' * ('Projected Openings (2030)' / 100.0)) AS absolute_change
FROM AI_Job_Impact
WHERE 'Job Openings (2024)' IS NOT NULL AND 'Projected Openings (2030)' IS NOT NULL
ORDER BY absolute_change DESC
LIMIT 10;
