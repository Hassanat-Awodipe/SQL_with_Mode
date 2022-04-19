--get all the companies that were acquired after three years of being founded_at_clean

/*Write a query that counts the number of companies acquired within 3 years, 5 years, and 10 years of being founded (in 3 separate columns).
 Include a column for total companies acquired as well. Group by category and limit to only rows with a founding date.*/
SELECT ccd.permalink,
       com.category_code,
       ccd.founded_at_clean,
       cad.acquired_at_cleaned
  FROM tutorial.crunchbase_companies_clean_date  AS ccd
  JOIN tutorial.crunchbase_acquisitions_clean_date  AS cad
  ON cad.company_permalink = ccd.permalink
  JOIN tutorial.crunchbase_companies com
  ON com.permalink = ccd.permalink
  WHERE ccd.founded_at_clean IS NOT NULL
    AND ccd.founded_at_clean::timestamp - cad.acquired_at_cleaned ::timestamp >= INTERVAL '3 years'

--this does the same as above
    SELECT ccd.name
           com.category_code,
           ccd.founded_at_clean::timestamp,
           cad.acquired_at_cleaned ::timestamp
      FROM tutorial.crunchbase_companies_clean_date  AS ccd
      JOIN tutorial.crunchbase_acquisitions_clean_date  AS cad
      ON cad.company_permalink = ccd.permalink
      JOIN tutorial.crunchbase_companies com
      ON com.permalink = ccd.permalink
      WHERE ccd.founded_at_clean IS NOT NULL
      GROUP BY 2,3,4
      HAVING ccd.founded_at_clean::timestamp - cad.acquired_at_cleaned ::timestamp >= INTERVAL '3 years'

--right answer
      SELECT companies.category_code,
       COUNT(CASE WHEN acquisitions.acquired_at_cleaned <= companies.founded_at_clean::timestamp + INTERVAL '3 years'
                       THEN 1 ELSE NULL END) AS acquired_3_yrs,
       COUNT(CASE WHEN acquisitions.acquired_at_cleaned <= companies.founded_at_clean::timestamp + INTERVAL '5 years'
                       THEN 1 ELSE NULL END) AS acquired_5_yrs,
       COUNT(CASE WHEN acquisitions.acquired_at_cleaned <= companies.founded_at_clean::timestamp + INTERVAL '10 years'
                       THEN 1 ELSE NULL END) AS acquired_10_yrs,
       COUNT(1) AS total
  FROM tutorial.crunchbase_companies_clean_date companies
  JOIN tutorial.crunchbase_acquisitions_clean_date acquisitions
    ON acquisitions.company_permalink = companies.permalink
 WHERE founded_at_clean IS NOT NULL
 GROUP BY 1
 ORDER BY 5 DESC
