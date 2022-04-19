--Write a query that separates the `location` field into separate fields for latitude and longitude. You can compare your results
--against the actual `lat` and `lon` fields in the table.

SELECT location,
      --POSITION(',' IN location) AS comma_position,
     --LEFT(location, POSITION(',' IN location)) AS lat,
     TRIM(both '(,' FROM LEFT(location, POSITION(',' IN location))) AS latitude,
     --SUBSTR(location, POSITION(',' IN location)+ 1, (LENGTH(location) - (POSITION(',' IN location)))) AS long,
     TRIM(trailing ')' FROM SUBSTR(location, POSITION(',' IN location)+ 1, (LENGTH(location) - (POSITION(',' IN location))))) AS longitude
FROM tutorial.sf_crime_incidents_2014_01


--answer

SELECT location,
       TRIM(leading '(' FROM LEFT(location, POSITION(',' IN location) - 1)) AS lattitude,
       TRIM(trailing ')' FROM RIGHT(location, LENGTH(location) - POSITION(',' IN location) ) ) AS longitude
  FROM tutorial.sf_crime_incidents_2014_01

  --Concatenate the lat and lon fields to form a field that is equivalent to the location field. (Note that the answer will have a different
--decimal precision.)

SELECT location,
        lat,
        lon,
        CONCAT(lat, ', ' ,  lon) AS loc_field
FROM tutorial.sf_crime_incidents_2014_01

--Write a query that creates a date column formatted YYYY-MM-DD.

SELECT date,
      LEFT(date, 10) AS new_date,
      LEFT(LEFT(date, 10), 2) AS day,
      SUBSTR(LEFT(date, 10), 4, 2) AS month,
      RIGHT(LEFT(date, 10), 4) AS year,
      CONCAT(RIGHT(LEFT(date, 10), 4) ||'-' || SUBSTR(LEFT(date, 10), 4, 2) || '-' || LEFT(LEFT(date, 10), 2)) AS format_date
FROM tutorial.sf_crime_incidents_2014_01

--answer:
SELECT incidnt_num,
           date,
           SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2) AS cleaned_date
      FROM tutorial.sf_crime_incidents_2014_01

--Write a query that returns the `category` field, but with the first letter capitalized and the rest of the letters in lower-case.

SELECT category,
      LEFT(category, 1)  ||   LOWER(RIGHT(category, LENGTH(category)-1)) AS format_category
  FROM tutorial.sf_crime_incidents_2014_01

  --alternative:
  SELECT incidnt_num,
       category,
       UPPER(LEFT(category, 1)) || LOWER(RIGHT(category, LENGTH(category) - 1)) AS category_cleaned
  FROM tutorial.sf_crime_incidents_2014_01


  --Write a query that creates an accurate timestamp using the date and time columns in tutorial.sf_crime_incidents_2014_01. Include a field that is exactly 1 week later as well.

  SELECT date,
          time,
          (LEFT(date, 10) || ' ' || time ) ::TIMESTAMP AS format_time,
          (LEFT(date, 10) || ' ' || time ) ::TIMESTAMP  + INTERVAL '1 week' AS week_time
  FROM tutorial.sf_crime_incidents_2014_01 LIMIT 100;

--alternative solution:
  SELECT incidnt_num,
         (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) ||
          '-' || SUBSTR(date, 4, 2) || ' ' || time || ':00')::timestamp AS timestamp,
         (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) ||
          '-' || SUBSTR(date, 4, 2) || ' ' || time || ':00')::timestamp
          + INTERVAL '1 week' AS timestamp_plus_interval
    FROM tutorial.sf_crime_incidents_2014_01

--Write a query that counts the number of incidents reported by week. Cast the week as a date to get rid of the hours/minutes/seconds.
SELECT COUNT(*),
      DATE_TRUNC('week', CAST(cleaned_date AS date))
FROM tutorial.sf_crime_incidents_cleandate
GROUP BY 2;

--Mode Solution
SELECT DATE_TRUNC('week', cleaned_date)::date AS week_beginning,
     COUNT(*) AS incidents
FROM tutorial.sf_crime_incidents_cleandate
GROUP BY 1
ORDER BY 1

--Write a query that shows exactly how long ago each indicent was reported. Assume that the dataset is in Pacific Standard Time (UTC - 8).

SELECT sf.date :: TIMESTAMP,
      NOW() AS present_time,
      DATE_TRUNC('day', NOW()) - DATE_TRUNC('day', (sf.date :: date)) AS age_of_report
FROM tutorial.sf_crime_incidents_2014_01 sf;

SELECT sf.time,
      sf.date,
      (LEFT(sf.date, 10) || ' ' || sf.time ) ::TIMESTAMP AS time_of_report,
      NOW() AS present_time,
      NOW() - ((LEFT(sf.date, 10) || ' ' || sf.time ) ::TIMESTAMP) AS age_of_report
FROM tutorial.sf_crime_incidents_2014_01 sf;

--Mode Solution
SELECT incidnt_num,
       cleaned_date,
       NOW() AT TIME ZONE 'PST' AS now,
       NOW() AT TIME ZONE 'PST' - cleaned_date AS time_ago
  FROM tutorial.sf_crime_incidents_cleandate
