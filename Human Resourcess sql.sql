drop table human_resources;

Create database if not exists hr_dashboard_projects;

use hr_dashboard_projects;

create table hr_work
(
id	int,
first_name varchar (255),
last_name	varchar (255),
birthdate	text (255),
gender	varchar (255),
race	varchar (255),
department	varchar (255),
jobtitle	varchar (255),
location varchar (255),
hire_date	text,
termdate	text,
location_city	varchar (255),
location_state varchar (255)
);

Select * from hr_work;

SET GLOBAL LOCAL_INFILE=ON;
LOAD DATA LOCAL INFILE 'C:/Users/PC/Downloads/Human Resourcess.csv' INTO TABLE hr_work
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT birthdate from hr_work;
UPDATE hr_work

SET birthdate =CASE
WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'),'%Y-%m-%d')
WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'),'%Y-%m-%d')
ELSE NULL
END;

ALTER TABLE hr_work
MODIFY COLUMN birthdate DATE;

DESCRIBE hr_work;

UPDATE hr_work
SET hire_date =CASE
WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'),'%Y-%m-%d')
WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'),'%Y-%m-%d')
ELSE NULL
END;

ALTER TABLE hr_work
MODIFY COLUMN hire_date DATE;

ALTER TABLE hr_work
ADD  COLUMN age INT;
UPDATE hr_work
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

UPDATE hr_work
SET termdate = IF(termdate IS NOT NULL AND termdate != '', date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE true;

SELECT termdate from hr_work;

SET sql_mode = 'ALLOW_INVALID_DATES';

ALTER TABLE hr_work
MODIFY COLUMN termdate DATE;

SELECT termdate from hr_work;

UPDATE hr_work
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT
min(age) AS youngest,
max(age) AS oldest
From hr_work;

SELECT count(*) hr_work where age <18;

SELECT COUNT(*)
FROM hr_work
WHERE TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) < 18;

SELECT birthdate, age from hr_work;

#QUESTIONS
#1. what is the gender breakdown of the employees in the company?
SELECT gender, count(*) AS count
FROM hr_work
WHERE age >= 18 AND termdate= '0000-00-00'
GROUP BY gender;

#2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, count(*) AS count
FROM hr_work
WHERE age >= 18 AND termdate= '0000-00-00'
GROUP BY race
ORDER BY COUNT(*) DESC;

#3. What is the age distribution of employees in company?
SELECT
min(age) AS youngest,
max(age) AS oldest
From hr_work
WHERE age >= 18 AND termdate= '0000-00-00';

SELECT
 CASE
 WHEN age >= 18 AND age <= 24 THEN '18-24'
 WHEN age >= 25 AND age <= 34 THEN '25-34'
 WHEN age >= 35 AND age <= 44 THEN '35-44'
 WHEN age >= 45 AND age <= 54 THEN '44-54'
 WHEN age >= 55 AND age <= 64 THEN '54-64'
ELSE '65+'
END AS age_group,gender,
count(*) AS count
FROM hr_work
WHERE age >= 18 AND termdate= '0000-00-00'
GROUP BY age_group, gender
ORDER BY age_group, gender;

#4. How many employees work at headquarters versus remote locations?
SELECT location, count(*) AS count
FROM hr_work
WHERE age >= 18 AND termdate= '0000-00-00'
GROUP BY location;

#5. What is the average lenth of employment for employees who have been terminated?
SELECT 
round(avg(datediff(termdate, hire_date))/365,0) AS Avg_length_employment
FROM hr_work
WHERE termdate <= curdate() AND termdate <> '0000-00-00' AND age >=18;

#6. How does the gender distribution vary across departments and job titles?
SELECT department, gender, count(*) AS count
FROM hr_work
WHERE age >= 18 AND termdate= '0000-00-00'
GROUP BY department, gender
ORDER BY department;

#7. What is the distribution of job titles across the company?
SELECT jobtitle, count(*) AS count
FROM hr_work
WHERE age >= 18 AND termdate= '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle DESC;  

#8. Which department has the highest turnover rate?
SELECT department,
total_count,
terminated_count,
terminated_count/total_count AS termination_date
FROM (
SELECT department,
count(*)AS total_count,
sum(case when termdate <> '0000-00-00' AND termdate <= curdate()THEN 1 ELSE 0 END) AS terminated_count
FROM hr_work
WHERE age >= 18
GROUP BY department
)AS subquery
ORDER BY termination_date DESC;

#9. What is the distribution of employees across location by city and state?
SELECT location_state, count(*) AS count
FROM hr_work
WHERE age >= 18 AND termdate= '0000-00-00'
GROUP BY location_state
ORDER BY count DESC;

#10. How has the company's employee count changed over time based on hire and term dates?
SELECT
year,
hires,
terminations,
hires-terminations AS net_change,
round((hires-terminations)/hires* 100,2) AS net_change_percent
FROM(
SELECT
YEAR(hire_date)AS year,
count(*) AS hires,
SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminations
FROM hr_work
WHERE age >=18
GROUP BY YEAR (hire_date)
)AS subquery
ORDER BY year ASC;


#11. What is the tenure distribution for each department?
SELECT department, round(avg(datediff(termdate, hire_date)/365),0) AS avg_tenure
FROM hr_work
WHERE termdate <= curdate() AND termdate<> '0000-00-00' AND age >= 18
GROUP BY department;


