---------------------------------------------------------------------------------------------------------------------------------------
--COHORT RETENTION (N Day, N Week)  BY  FIRST DAY CREDITS SPENT (BIGQUERY)
---------------------------------------------------------------------------------------------------------------------------------------
WITH add_group AS (
  SELECT user_key,
      CASE 
       WHEN credits_spent <= 2 THEN "1. <=2"
       WHEN credits_spent <= 10 THEN "2. від 3 до 10"
       WHEN credits_spent <= 25 THEN "3. від 11 до 25"
       WHEN credits_spent <= 50 THEN "4. від 26 до 50"
       WHEN credits_spent <= 100 THEN "5. від 51 до 100"
       WHEN credits_spent > 101 THEN "6. від 101"
      END AS cohort
FROM `df_sweetylove.number_day_cumul_revenue` 
WHERE number_day = 0
)


SELECT
     "N Day" AS type, 
     cohort,
     COUNT(DISTINCT ag.user_key) AS day_0,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day = 1, n.user_key, NULL)), COUNT(DISTINCT ag.user_key)) AS N1,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  = 2, n.user_key, NULL)), COUNT(DISTINCT ag.user_key)) AS N2,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  = 3, n.user_key, NULL)), COUNT(DISTINCT ag.user_key)) AS N3,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  = 4, n.user_key, NULL)), COUNT(DISTINCT ag.user_key)) AS N4,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  = 5, n.user_key, NULL)), COUNT(DISTINCT ag.user_key)) AS N5,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  = 6, n.user_key, NULL)), COUNT(DISTINCT ag.user_key)) AS N6,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  = 7, n.user_key, NULL)), COUNT(DISTINCT ag.user_key)) AS N7,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  = 8, n.user_key, NULL)), COUNT(DISTINCT ag.user_key)) AS N8,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  = 9, n.user_key, NULL)), COUNT(DISTINCT ag.user_key)) AS N9,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  = 10, n.user_key, NULL)), COUNT(DISTINCT ag.user_key)) AS N10
FROM add_group AS ag
JOIN `df_sweetylove.number_day_cumul_revenue` AS n
ON ag.user_key = n.user_key
GROUP BY cohort

UNION ALL

SELECT
     "N Week" AS type, 
     cohort,
     COUNT(DISTINCT ag.user_key) AS day_0,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day BETWEEN 1 AND 7, n.user_key, NULL)), COUNT(DISTINCT ag.user_key)) AS N1,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day BETWEEN 8 AND 14, n.user_key, NULL)), COUNT(DISTINCT ag.user_key)) AS N2,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day BETWEEN 15 AND 21, n.user_key, NULL)), COUNT(DISTINCT ag.user_key)) AS N3,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  BETWEEN 22 AND 28, n.user_key, NULL)), COUNT(DISTINCT ag.user_key)) AS N4,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  BETWEEN 29 AND 35, n.user_key, NULL)), COUNT(DISTINCT ag.user_key)) AS N5,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  BETWEEN 36 AND 42, n.user_key, NULL)), COUNT(DISTINCT ag.user_key)) AS N6,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  BETWEEN 43 AND 49, n.user_key, NULL)), COUNT(DISTINCT ag.user_key)) AS N7,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  BETWEEN 50 AND 56, n.user_key, NULL)), COUNT(DISTINCT ag.user_key)) AS N8,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  BETWEEN 57 AND 63, n.user_key, NULL)), COUNT(DISTINCT ag.user_key)) AS N9,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  BETWEEN 64 AND 70, n.user_key, NULL)), COUNT(DISTINCT ag.user_key)) AS N10


FROM  `df_sweetylove.number_day_cumul_revenue` AS n
LEFT JOIN add_group AS ag
ON ag.user_key = n.user_key
GROUP BY cohort
ORDER BY type, cohort