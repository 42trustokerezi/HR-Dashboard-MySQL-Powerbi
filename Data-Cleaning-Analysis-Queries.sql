CREATE DATABASE HR_Project;
USE hr_project;
SELECT * FROM hr;

-- DATA CLEANING --
-- 1. Change the name of the id field 
ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NOT NULL; 

-- 2. Check Datatype of hr table  
DESCRIBE hr;

-- 3. Change birthdate from text format to date 
SELECT birthdate FROM hr;
UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

-- set the query below to 0 to bypass update issues. 
-- set it back to 1 after update changes. 
SET sql_safe_updates = 1;

ALTER TABLE hr
MODIFY birthdate DATE;

-- 4. Change hire date from text format to date 
SET sql_safe_updates = 0;

UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN hire_date date;

SELECT hire_date FROM hr;

-- 5. Change termdate from date/time to date only
SELECT termdate FROM hr;

UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';
 
UPDATE hr
SET termdate = NULL
WHERE termdate = '';

 
SELECT termdate FROM hr;

ALTER TABLE hr
MODIFY COLUMN termdate date;

-- 6. Add new column "age"
ALTER TABLE hr
	ADD COLUMN age INT;

SELECT * FROM hr;

-- 7. Calculate age
UPDATE hr
SET age = timestampdiff(YEAR,birthdate, CURDATE()); 

SELECT birthdate, age FROM hr;

SELECT 
	min(age) AS youngest,
    max(age) AS oldest
FROM hr;

-- check how many records have age less than 18
SELECT count(*) FROM hr WHERE age < 18; 

-- ANALYSIS
-- 1. What is the gender of employees in the company?
SELECT gender FROM hr;

SELECT gender, count(*) AS count
FROM hr 
WHERE age >= 18 AND termdate IS NULL
GROUP BY gender;

select * from hr;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race,count(*) AS count
FROM hr
WHERE age >= 18 AND termdate IS NULL
GROUP BY race
ORDER BY count(*) DESC;

-- 3. What is the age distribution of employees in the company?
SELECT
	min(age) AS youngest,
    max(age) AS oldest
FROM hr
WHERE age >= 18 AND termdate IS NULL;

SELECT
CASE 
	WHEN age >= 18 AND age <= 24 THEN '18-24'
    WHEN age >= 25 AND age <= 34 THEN '25-34'
    WHEN age >= 35 AND age <= 44 THEN '35-44'
    WHEN age >= 45 AND age <= 54 THEN '45-54'
    WHEN age >= 55 AND age <= 64 THEN '55-64'
    ELSE '65+'
  END AS age_group,
  count(*) AS count
FROM hr
WHERE age >= 18 AND termdate IS NULL
GROUP BY age_group
ORDER BY age_group;   


SELECT
CASE 
	WHEN age >= 18 AND age <= 24 THEN '18-24'
    WHEN age >= 25 AND age <= 34 THEN '25-34'
    WHEN age >= 35 AND age <= 44 THEN '35-44'
    WHEN age >= 45 AND age <= 54 THEN '45-54'
    WHEN age >= 55 AND age <= 64 THEN '55-64'
    ELSE '65+'
  END AS age_group, gender,
  count(*) AS count
FROM hr
WHERE age >= 18 AND termdate IS NULL
GROUP BY age_group, gender
ORDER BY age_group, gender;   

-- 4. How many employees work at headquarters versus remote locations?
 SELECT location, count(*) AS count
 FROM hr 
 WHERE age >= 18 AND termdate IS NULL
 GROUP BY location;
 
 -- 5. What is the average length of employment for employees who have been terminated?
 SELECT 
	round(avg(datediff(termdate, hire_date))/365,0) AS avg_length_employment
FROM hr
WHERE termdate <= curdate() AND termdate IS NOT NULL AND age >= 18;
 
 -- 6. How does the gender distribution vary across departments and job titles? 
 SELECT department, gender, COUNT(*) AS count
 FROM hr
WHERE age >= 18 AND termdate IS NULL
GROUP BY department, gender
ORDER BY department;

-- 7. What is the distribution of job titles across the company ?
SELECT jobtitle, count(*) AS count
FROM hr
WHERE age >= 18 AND termdate IS NULL
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8. Which department has the highest turnover rate?
SELECT department,
total_count,
terminated_count,
terminated_count/total_count AS termination_rate
	FROM(
		SELECT department,
		count(*) AS total_count,
		SUM(CASE WHEN termdate IS NOT NULL and termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
		FROM hr
		WHERE age >= 18
		GROUP BY department
	) AS subquery
ORDER BY termination_rate DESC;

-- 9. What is the distribution of employees across locations by city and state? 
SELECT location_state, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate IS NULL
GROUP BY location_state
ORDER BY count DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT 
	year,
    hires,
    terminations,
    hires-terminations AS net_change,
    round((hires-terminations)/hires * 100, 2) AS net_change_percent
FROM(
	SELECT
		YEAR(hire_date) AS year,
        count(*) AS hires,
        SUM(CASE WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminations
        FROM hr
        WHERE age >= 18
        GROUP BY YEAR(hire_date)
) AS subquery
ORDER BY year ASC;


-- 11. What is the tenure distribution for each department?
SELECT department, round(avg(datediff(termdate, hire_date)/365), 0) AS avg_tenure
FROM hr
WHERE termdate <= curdate() AND termdate IS NOT NULL AND age >= 18
GROUP BY department;