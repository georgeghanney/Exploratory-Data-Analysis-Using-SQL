
-- Select and Describe  all tables in the database to investigate columns
SELECT * FROM Project_uno.aliens_main;
SELECT * FROM Project_uno.aliens_det;
SELECT * FROM Project_uno.aliens_loc;

-- Describe tables
DESC Project_uno.aliens_main;
DESC Project_uno.aliens_det;
DESC Project_uno.aliens_loc;

-- Testing for null values in our tables
SELECT * FROM Project_uno.aliens_main WHERE gender IS NULL;
SELECT * FROM Project_uno.aliens_det WHERE favorite_food IS NULL;
SELECT * FROM Project_uno.aliens_loc WHERE state IS NULL;

-- Creating column 'Name' and Concatenate columns 'first_name' and 'last_name' in aliens_main table
ALTER table aliens_main ADD COLUMN Name Nvarchar(255);
UPDATE aliens_main 
SET 
    Name = CONCAT(first_name, ' ', last_name);

-- Creating the age column 
ALTER TABLE aliens_main ADD COLUMN Age INT(50);
UPDATE aliens_main 
SET 
    age = (2022 - birth_year);

-- Dropping irrelevants columns from table 'aliens_main'
ALTER TABLE aliens_main DROP COLUMN first_name,DROP COLUMN last_name,DROP COLUMN email;

-- Dropping the 'country' column in aliens_loc table
ALTER TABLE aliens_loc DROP COLUMN country;

-- Calculating total number of aliens
SELECT 
    COUNT(*)
FROM
    aliens_main;

-- Calculating average age of aliens
SELECT 
	ROUND(AVG(Age),0) as AVG_AGE
FROM aliens_main;

-- Calculating the oldest aliens by gender and type
SELECT 
    gender, type, MAX(Age) Age
FROM
    aliens_main
GROUP BY 1 , 2
ORDER BY 3 DESC;

-- Return Name,type, occupation and current location of aliens  70 years and above
SELECT 
    m.id, m.Name, m.type, l.occupation, l.current_location
FROM
    aliens_main AS m
        LEFT JOIN
    aliens_loc AS l ON m.id = l.loc_id
WHERE
    m.age >= 70;
    
-- Current location with most aliens 
SELECT 
    cul.current_location AS location,
    COUNT(cul.current_location) AS total_aliens
FROM
    (SELECT 
        m.id, m.Name, m.type, l.occupation, l.current_location
    FROM
        aliens_main AS m
    LEFT JOIN aliens_loc AS l ON m.id = l.loc_id) AS cul
GROUP BY 1
ORDER BY 2 DESC;


-- Calculating the number of aliens by gender
SELECT 
    gender, COUNT(*) AS total_count
FROM
    aliens_main
GROUP BY 1
ORDER BY 2 DESC;

-- The Top 10 occupations with most aliens by gender(male and female only)
SELECT 
    m.gender, l.occupation, COUNT(l.occupation) AS Total_aliens
FROM
    aliens_main AS m
        LEFT JOIN
    aliens_loc AS l ON m.id = l.loc_id
WHERE
    m.gender IN ('Female' , 'Male')
GROUP BY 1 , 2
ORDER BY 3 DESC , 1
LIMIT 10;

-- The Top 10 occupations with most aliens
SELECT 
    occupation, COUNT(occupation) AS Total_aliens
FROM
    aliens_loc
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- Pivoting number of aliens in the top 3 genders by breed type
SELECT 
    type,
    SUM(IF(gender = 'Male', Total, 0)) AS 'Male',
    SUM(IF(gender = 'Female', Total, 0)) AS 'Female',
    SUM(IF(gender = 'Bigender', Total, 0)) AS 'Bigender'
FROM
    (SELECT 
        type, gender, COUNT(*) Total
    FROM
        aliens_main
    WHERE
        gender IN ('Female' , 'Male', 'Bigender')
    GROUP BY 1 , 2) AS t
GROUP BY type
ORDER BY Male DESC , Female , Bigender;

-- The most aggressive alien type
SELECT 
    m.type,COUNT(*) AS total_Aggre
FROM
    aliens_main m
        LEFT JOIN
    aliens_det d ON m.id = d.detail_id
WHERE
    d.aggressive = 'True'
GROUP BY 1  
ORDER BY 2 DESC;

-- The most aggressive alien type by gender
SELECT 
    m.gender,m.type,COUNT(*) AS total_Aggre
FROM
    aliens_main m
        LEFT JOIN
    aliens_det d ON m.id = d.detail_id
WHERE
    d.aggressive = 'True'
GROUP BY 1,2
ORDER BY 3 DESC;

-- The most aggressive alien type by birth_year
SELECT 
   m.birth_year, m.type,COUNT(*) AS total_Aggre
FROM
    aliens_main m
        LEFT JOIN
    aliens_det d ON m.id = d.detail_id
WHERE
    d.aggressive = 'True'
GROUP BY 1,2 
ORDER BY 3 DESC;

-- Total aggressive aliens 
SELECT 
    COUNT(*) AS total_Aggre,
    (COUNT(*) /50000)*100 Percentage    
FROM
    aliens_main m
        LEFT JOIN
    aliens_det d ON m.id = d.detail_id
WHERE
    d.aggressive = 'True'
ORDER BY 1 DESC;

-- The  favorite foods of the most agressive aliens
SELECT 
    m.type, d.favorite_food, COUNT(type) Total
FROM
    aliens_main m
        LEFT JOIN
    aliens_det d ON m.id = d.detail_id
WHERE
    d.aggressive = 'True'
        AND m.type IN ('Reptile' , 'Flatwoods')
GROUP BY 2 , 1
ORDER BY 3 DESC;


-- Selecting gender, location and occupaton by age range
WITH AgeData as
(
  SELECT m.gender,
		l.state,
        l.occupation,
         m.Age
  FROM aliens_main m
  INNER JOIN aliens_loc l ON m.id = l.loc_id
),
GroupAge AS
(
  SELECT gender,
		state,
        occupation,
         Age,
         CASE
             WHEN AGE <= 50 THEN 'Under 50'
             WHEN AGE BETWEEN 51 AND 100 THEN '51 - 100'
             WHEN AGE BETWEEN 101 AND 200 THEN '101 - 200'
             WHEN AGE BETWEEN 201 AND 300 THEN '201 - 300'
             WHEN AGE > 300 THEN 'Over 300'
             ELSE 'Invalid Birthdate'
         END AS Age_Groups
  FROM AgeData 
)
SELECT gender,state,occupation,COUNT(*) AS AgeGrpCount,
       Age_Groups
FROM GroupAge 
Group by 1,2,3,5
ORDER BY 5,4 DESC;

-- Feeding frequency by the most aggressive  aliens 
SELECT 
    type,
    SUM(IF(feeding_frequency = 'Yearly',
        feed_freqCount,
        0)) AS 'Yearly',
    SUM(IF(feeding_frequency = 'Weekly',
        feed_freqCount,
        0)) AS 'Weekly',
    SUM(IF(feeding_frequency = 'Seldom',
        feed_freqCount,
        0)) AS 'Seldom',
    SUM(IF(feeding_frequency = 'Once',
        feed_freqCount,
        0)) AS 'Once',
    SUM(IF(feeding_frequency = 'Often',
        feed_freqCount,
        0)) AS 'Often',
    SUM(IF(feeding_frequency = 'Never',
        feed_freqCount,
        0)) AS 'Never',
    SUM(IF(feeding_frequency = 'Monthly',
        feed_freqCount,
        0)) AS 'Monthly',
    SUM(IF(feeding_frequency = 'Daily',
        feed_freqCount,
        0)) AS 'Daily'
FROM
    (SELECT 
        m.type, d.feeding_frequency, COUNT(*) feed_freqCount
    FROM
        aliens_main m
    LEFT JOIN aliens_det d ON m.id = d.detail_id
    WHERE
        feeding_frequency IN ('Yearly' , 'Weekly', 'Seldom', 'Once', 'Often', 'Never', 'Monthly', 'Daily')
            AND d.aggressive = 'True'
    GROUP BY 1 , 2) AS t
GROUP BY 1
ORDER BY Yearly , Weekly , Seldom , Once , Often , Never , Monthly , Daily DESC;

 -- The most common alien breeds or type
SELECT 
    type, COUNT(type) AS Total_breed
FROM
    aliens_main
GROUP BY 1
ORDER BY 2 DESC;

-- Aliens  who are transgender
SELECT 
    COUNT(*)
FROM
    aliens_main
WHERE
    gender NOT IN ('Male' , 'Female');
    
-- State with the most aggressive aliens
SELECT 
    l.state, COUNT(*) total
FROM
    aliens_loc l
        LEFT JOIN
    aliens_det d ON d.detail_id = l.loc_id
WHERE
    d.aggressive = 'True'
GROUP BY 1
ORDER BY 2 DESC;

-- Joining all three tables using CTE
WITH Aliens as (
	SELECT m.id, m.Name, m.gender,m.type,m.birth_year,d.favorite_food,
    d.feeding_frequency,d.aggressive,l.state,l.current_location,l.occupation
    FROM aliens_main as m
    INNER JOIN aliens_det as d
    ON d.detail_id = m.id
    INNER JOIN aliens_loc as l
    ON d.detail_id = l.loc_id
)
Select * FROM Aliens;


