--Write a query that selects all Warrant Arrests from the tutorial.sf_crime_incidents_2014_01 dataset, then wrap it in an outer query that only displays unresolved incidents.

SELECT sub.*
FROM ( SELECT *
        FROM tutorial.sf_crime_incidents_2014_01
        WHERE descript = 'WARRANT ARREST') sub
WHERE resolution = 'NONE'

--Mode solution
SELECT sub.*
      FROM (
            SELECT *
              FROM tutorial.sf_crime_incidents_2014_01
             WHERE descript = 'WARRANT ARREST'
           ) sub
     WHERE sub.resolution = 'NONE'

 --Write a query that displays the average number of monthly incidents for each category. Hint: use tutorial.sf_crime_incidents_cleandate to make
 --your life a little easier.
 SELECT sub.category,
       AVG(sub.num_incidents)
   FROM (SELECT DATE_PART('month', cleaned_date),
                 category,
                 COUNT(incidnt_num) AS num_incidents
         FROM tutorial.sf_crime_incidents_cleandate
         GROUP BY 1,2) sub
 GROUP BY 1
 ORDER BY 1

 --Mode Solution:
 SELECT sub.category,
       AVG(sub.incidents) AS avg_incidents_per_month
  FROM (
        SELECT EXTRACT('month' FROM cleaned_date) AS month,
               category,
               COUNT(1) AS incidents
          FROM tutorial.sf_crime_incidents_cleandate
         GROUP BY 1,2
       ) sub
 GROUP BY 1


 --Write a query that displays all rows from the three categories with the fewest incidents reported.
SELECT *
FROM tutorial.sf_crime_incidents_2014_01
JOIN
    (SELECT category,
          COUNT(incidnt_num) AS num_of_incidents
    FROM tutorial.sf_crime_incidents_2014_01
    GROUP BY 1
    ORDER BY 2
    LIMIT 3) sub
ON tutorial.sf_crime_incidents_2014_01.category = sub.category

--Write a query that counts the number of companies founded and acquired by quarter starting in Q1 2012. Create the aggregations in two separate queries, then join them.

SELECT COALESCE(acquired_quarter, founded_quarter) AS quarter,
      num_comp_acquired,
      num_comp_founded
FROM (SELECT acquired_quarter,
              COUNT(DISTINCT company_permalink) AS num_comp_acquired
      FROM tutorial.crunchbase_acquisitions
      GROUP BY 1
      HAVING acquired_quarter >= '2012-Q1') acquisitions
FULL JOIN (SELECT founded_quarter,
                  COUNT(permalink) AS num_comp_founded
          FROM tutorial.crunchbase_companies
          GROUP BY 1
          HAVING founded_quarter >= '2012-Q1') founded
ON acquisitions.acquired_quarter = founded.founded_quarter
ORDER BY 1
