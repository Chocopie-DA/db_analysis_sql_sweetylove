--BIGQUERY
--створення таблиці з нумерацією дня та кумулятивного доходу по кожному юзеру

DROP TABLE IF EXISTS `df_sweetylove.number_day_cumul_revenue`;
CREATE TABLE `df_sweetylove.number_day_cumul_revenue` AS 

--групповка users по днях
WITH group_user_by_day AS (
SELECT
      DATE(time_utc) AS date, 
      user_key,
      SUM(total_revenue) AS revenue,
      SUM(credit_gross) AS credits_spent
FROM `df_sweetylove.analysis_table`
WHERE user_status IN ("paid", "free+paid")
GROUP BY DATE(time_utc), user_key
),

--дата першого контакту
first_connect_day AS (
SELECT 
      DATE(MIN(date)) AS first_day,
      user_key
FROM group_user_by_day
GROUP BY user_key
)

SELECT
    gud.date, --дата
    gud.user_key, --id user
    DATE_DIFF(gud.date, fcd.first_day, DAY) AS number_day, -- номер дня (0 = перший день)
    revenue, --дохід за день
    credits_spent, --потрачено кредитів за день
    SUM(revenue) OVER (PARTITION BY gud.user_key ORDER BY gud.date) AS cumul_revenue, -- кумулятивний ревеню
    SUM(credits_spent) OVER (PARTITION BY gud.user_key ORDER BY gud.date) AS cumul_cred_spent 
FROM group_user_by_day AS gud
LEFT JOIN first_connect_day AS fcd
  ON gud.user_key = fcd.user_key
ORDER BY gud.date, gud.user_key