--RETENTION (BIGQUERY)

--когорта усіх paid users
WITH cohort_users AS (
  SELECT DISTINCT user_key
  FROM `df_sweetylove.number_day_cumul_revenue` 
  WHERE number_day = 0
),

--LT для кожного usera
user_max_day AS (
  SELECT user_key,
         MAX(number_day) AS max_day
  FROM `df_sweetylove.number_day_cumul_revenue`
  GROUP BY user_key
)

--strict retention
SELECT
      "strict" AS type,
      COUNT(DISTINCT cu.user_key) AS day_0,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day = 1, n.user_key, NULL)), COUNT(DISTINCT cu.user_key)) AS day_1,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  = 2, n.user_key, NULL)), COUNT(DISTINCT cu.user_key)) AS day_2,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  = 3, n.user_key, NULL)), COUNT(DISTINCT cu.user_key)) AS day_3,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  = 4, n.user_key, NULL)), COUNT(DISTINCT cu.user_key)) AS day_4,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  = 5, n.user_key, NULL)), COUNT(DISTINCT cu.user_key)) AS day_5,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  = 6, n.user_key, NULL)), COUNT(DISTINCT cu.user_key)) AS day_6,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  = 7, n.user_key, NULL)), COUNT(DISTINCT cu.user_key)) AS day_7,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  = 14, n.user_key, NULL)), COUNT(DISTINCT cu.user_key)) AS day_14,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  = 30, n.user_key, NULL)), COUNT(DISTINCT cu.user_key)) AS day_30,
      SAFE_DIVIDE(COUNT(DISTINCT IF(n.number_day  = 60, n.user_key, NULL)), COUNT(DISTINCT cu.user_key)) AS day_60
FROM cohort_users AS cu
LEFT JOIN `df_sweetylove.number_day_cumul_revenue` AS n
  ON n.user_key = cu.user_key


UNION ALL

--rolling retention
SELECT
      "rolling" AS type,
      COUNT(DISTINCT cu.user_key) AS day_0,
      SAFE_DIVIDE(COUNT(DISTINCT IF(umd.max_day >= 1, cu.user_key, NULL)), COUNT(DISTINCT cu.user_key)) AS day_1,
      SAFE_DIVIDE(COUNT(DISTINCT IF(umd.max_day >= 2, cu.user_key, NULL)), COUNT(DISTINCT cu.user_key)) AS day_2,
      SAFE_DIVIDE(COUNT(DISTINCT IF(umd.max_day >= 3, cu.user_key, NULL)), COUNT(DISTINCT cu.user_key)) AS day_3,
      SAFE_DIVIDE(COUNT(DISTINCT IF(umd.max_day  >= 4, cu.user_key, NULL)), COUNT(DISTINCT cu.user_key)) AS day_4,
      SAFE_DIVIDE(COUNT(DISTINCT IF(umd.max_day  >= 5, cu.user_key, NULL)), COUNT(DISTINCT cu.user_key)) AS day_5,
      SAFE_DIVIDE(COUNT(DISTINCT IF(umd.max_day  >= 6, cu.user_key, NULL)), COUNT(DISTINCT cu.user_key)) AS day_6,
      SAFE_DIVIDE(COUNT(DISTINCT IF(umd.max_day  >= 7, cu.user_key, NULL)), COUNT(DISTINCT cu.user_key)) AS day_7,
      SAFE_DIVIDE(COUNT(DISTINCT IF(umd.max_day  >= 14, cu.user_key, NULL)), COUNT(DISTINCT cu.user_key)) AS day_14,
      SAFE_DIVIDE(COUNT(DISTINCT IF(umd.max_day  >= 30, cu.user_key, NULL)), COUNT(DISTINCT cu.user_key)) AS day_30,
      SAFE_DIVIDE(COUNT(DISTINCT IF(umd.max_day  >= 60, cu.user_key, NULL)), COUNT(DISTINCT cu.user_key)) AS day_60
FROM user_max_day AS umd
LEFT JOIN cohort_users AS cu
  ON umd.user_key = cu.user_key
