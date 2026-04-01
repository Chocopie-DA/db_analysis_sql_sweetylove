--Замена запятих на крапки (при потребі)
UPDATE data_agency_clean
SET revenue_paid = CAST(REPLACE(revenue_paid, ',', '.') AS REAL),
		 revenue_free = CAST(REPLACE(revenue_paid, ',', '.') AS REAL);
		 
		
--Оновлення довідників
--apps
INSERT INTO apps (app_id, app_name)
SELECT DISTINCT app_id, app_name
FROM data_agency_clean
WHERE app_id NOT IN (SELECT app_id FROM apps);
--users
INSERT INTO users (user_id, user_name)
SELECT DISTINCT user_id, user_name
FROM data_agency_clean
WHERE user_id NOT IN (SELECT user_id FROM users);
--profiles
INSERT INTO profiles (profile_id, profile_name)
SELECT DISTINCT profile_id, profile_name
FROM data_agency_clean
WHERE profile_id NOT IN (SELECT profile_id FROM profiles);
--operators
INSERT INTO operators (operator_name)
SELECT DISTINCT operator_name
FROM data_agency_clean
WHERE operator_name NOT IN (SELECT operator_name FROM operators);


--перенос данных с data_agency_clean.csv в основную таблицу 
INSERT INTO purchases (
time_utc,
operator_key,
profile_key,
user_key,
app_key,
purchase_for,
purchase_place,
credit_gross,
revenue_free,
revenue_paid)

SELECT time_utc,
				  o.operator_key,
				  p.profile_key,
				  u.user_key,
				  a.app_key,
				  purchase_for,
				  purchase_place,
				  credit_gross,
				  revenue_free,
				  revenue_paid
				  
FROM data_agency_clean dac
JOIN apps a ON dac.app_name = a.app_name
JOIN operators o ON dac.operator_name = o.operator_name
JOIN profiles p ON dac.profile_id = p.profile_id
JOIN users u ON dac.user_id= u.user_id
ORDER BY time_utc;


DROP TABLE data_agency_clean