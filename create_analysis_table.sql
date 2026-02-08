DROP TABLE IF EXISTS analysis_table;

CREATE TABLE analysis_table AS 
WITH status AS
	(SELECT  user_key, 
	CASE 
			WHEN SUM(revenue_free) > 0 AND SUM(revenue_paid) > 0 THEN "free+paid"
			WHEN SUM(revenue_free) > 0 THEN "free"
			WHEN SUM(revenue_paid) > 0 THEN "paid"
	END AS user_status
	FROM purchases
	GROUP BY user_key)
			

SELECT *,
				CASE strftime('%w', time_utc)
					  WHEN '0' THEN 'Sunday'
					  WHEN '1' THEN 'Monday'
					  WHEN '2' THEN 'Tuesday'
					  WHEN '3' THEN 'Wednesday'
					  WHEN '4' THEN 'Thursday'
					  WHEN '5' THEN 'Friday'
					  WHEN '6' THEN 'Saturday'
				END AS day_of_week,
				revenue_free + revenue_paid AS total_revenue,
				s.user_status
FROM purchases p
LEFT JOIN status s ON p.user_key = s.user_key
ORDER BY id