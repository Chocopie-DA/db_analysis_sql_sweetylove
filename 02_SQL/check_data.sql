--===================
--Перевірка на NULL
--===================
SELECT  *
FROM purchases pur
LEFT JOIN apps a ON pur.app_key = a.app_key
LEFT JOIN operators o ON pur.operator_key = o.operator_key
LEFT JOIN profiles p ON pur.profile_key = p.profile_key
LEFT JOIN users u ON pur.user_key = u.user_key
WHERE 
				pur.time_utc IS NULL OR
				pur.operator_key IS NULL OR
				pur.profile_key IS NULL OR
				pur.user_key IS NULL OR
				pur.app_key IS NULL OR
				pur.credit_gross IS NULL OR
				pur.purchase_for IS NULL OR
				pur.purchase_place IS NULL OR
				a.app_name IS NULL OR
				o.operator_name IS NULL OR
				p.profile_name IS NULL OR
				p.profile_id IS NULL OR
				u.user_id IS NULL OR
				u.user_name IS NULL;

			
--=============================
-- Проверка нарушений PK-FK
--=============================
------------------------------------------------
-- для app_key и operator_key
------------------------------------------------
SELECT *
FROM purchases pur
LEFT JOIN apps a ON pur.app_key = a.app_key
WHERE pur.app_key IS NOT NULL AND a.app_key IS NULL

UNION ALL

SELECT *
FROM purchases pur
LEFT JOIN operators o ON pur.operator_key = o.operator_key
WHERE pur.operator_key IS NOT NULL AND o.operator_key IS NULL;

------------------------------------------------
-- для profile_key и user_key
------------------------------------------------
SELECT *
FROM purchases pur
LEFT JOIN profiles p ON pur.profile_key = p.profile_key
WHERE pur.profile_key IS NOT NULL AND p.profile_key IS NULL

UNION ALL

SELECT *
FROM purchases pur
LEFT JOIN users u ON pur.user_key = u.user_key
WHERE pur.user_key IS NOT NULL AND u.user_key IS NULL;

--================================
-- Проверка "лишних" операторов
--================================
SELECT o.operator_name, o.operator_key
FROM operators o
LEFT JOIN purchases pur ON o.operator_key = pur.operator_key
WHERE pur.operator_key IS NULL;

--===============================
-- Проверка "лишних" профилей
--===============================
SELECT p.profile_name, p.profile_id
FROM profiles p
LEFT JOIN purchases pur ON p.profile_key = pur.profile_key
WHERE pur.profile_key IS NULL;

--====================================
-- Проверка "лишних" пользователей
--====================================
SELECT u.user_name, u.user_id
FROM users u
LEFT JOIN purchases pur ON u.user_key = pur.user_key
WHERE pur.user_key IS NULL;


--==================
-- Проверка дублей
--==================
SELECT *
FROM (SELECT *, 
								COUNT(*) OVER (PARTITION BY id) AS cnt
				FROM purchases) as t
WHERE cnt > 1
ORDER BY id;

--=====================================================
-- Перевірка діапазоніа та аномальних значень
-- credit_gross не має бути нижче 1
-- revenue_free та paid повинен збігати зі статистикою на адмінпанелі
--=====================================================
SELECT  min(time_utc) as min_day,
				   max(time_utc) as max_day,
				   min(operator_key) as min_operator_key,
				   max(operator_key) as max_operator_key,
				   min(profile_key) as min_profile_key,
				   max(profile_key) as max_profile_key,
				   min(user_key) as min_user_key,
				   max(user_key) as max_user_key,
				   min(app_key) as min_app_key,
				   max(app_key) as max_app_key,
				   SUM(CASE 
							   WHEN credit_gross < 1 THEN 1 
							   ELSE 0 
							   END) as invalid_gross_cnt, --кол-во сredit_gross < 1
				   SUM(revenue_free) AS total_revenue_free,
				   SUM(revenue_paid) AS total_revenue_paid,
				   SUM(
							COALESCE(ROUND(credit_gross * 0.0588, 4), 0) !=  -- 1 credit = 0.0588
							COALESCE(ROUND(revenue_free + revenue_paid, 4), 0)
							) as credit_rvenue_check -- кол-во НЕ соответствий credit с revenue
FROM purchases;

--===============================================================
-- Строки которые именют аномальную стоимость credit_gross
--===============================================================
SELECT *
FROM purchases
WHERE COALESCE(ROUND(credit_gross * 0.0588, 4), 0) != 
                 COALESCE(ROUND(revenue_free + revenue_paid, 4), 0)
ORDER BY time_utc 
				 



