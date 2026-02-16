DROP TABLE IF EXISTS analysis_table;

CREATE TABLE analysis_table AS 
--=====================================
--дополнительные временные поля
--====================================
WITH ym_dom_dow_pod AS (
SELECT id,
	   DATE(time_utc, "start of month") AS year_month,
	   STRFTIME("%d", time_utc) AS day_of_month,
	   CASE strftime('%w',  time_utc)
			  WHEN '0' THEN 'Sunday'
			  WHEN '1' THEN 'Monday'
			  WHEN '2' THEN 'Tuesday'
			  WHEN '3' THEN 'Wednesday'
			  WHEN '4' THEN 'Thursday'
			  WHEN '5' THEN 'Friday'
			  WHEN '6' THEN 'Saturday'
		END AS day_of_week,
		CASE 
			  WHEN time(time_utc) <  "06:00'" THEN "night"
			  WHEN time(time_utc) <  "12:00" THEN "morning"
			  WHEN time(time_utc) <  "18:00" THEN "afternoon"
			  ELSE "evening"
		 END AS part_of_day
FROM purchases ),
--====================================
--==статус для пользователей
--====================================
status AS
(SELECT user_key, 
		CASE 
			WHEN SUM(revenue_free) > 0 AND SUM(revenue_paid) > 0 THEN "free+paid"
			WHEN SUM(revenue_free) > 0 THEN "free"
			WHEN SUM(revenue_paid) > 0 THEN "paid"
		END AS user_status
		FROM purchases
		GROUP BY user_key),
--=====================================================
--группировка purchase_for на медиа, чат, остальное
--=====================================================
new_purhcase_for AS 
(SELECT purchase_for,
	    CASE
			WHEN  purchase_for IN ("Chat per message", "Chat per minute") THEN "chat"
			WHEN purchase_for IN ("View Image", "Upload Photo", "View Video", "Upload Video",
								  "View disappearing photo", "View disappearing video") THEN "media"
			ELSE "other"
	    END AS "chat_or_media"
FROM purchases
GROUP BY purchase_for)

SELECT p.id,
	 p.time_utc,
	 t.year_month,
	 t.day_of_month,	
	 t.day_of_week,
	 t.part_of_day,
	 p.operator_key,
	 p.profile_key,
	 p.user_key,
	 p.app_key,
	 p.purchase_for,
	 n.chat_or_media,
	 s.user_status,
	 p.credit_gross,
	 p.revenue_free,
	 p.revenue_paid,
	 revenue_free + revenue_paid AS total_revenue
FROM purchases p
LEFT JOIN ym_dom_dow_pod t on t.id = p.id
LEFT JOIN status s ON p.user_key = s.user_key
LEFT JOIN new_purhcase_for n ON p.purchase_for = n.purchase_for
ORDER BY p.id
