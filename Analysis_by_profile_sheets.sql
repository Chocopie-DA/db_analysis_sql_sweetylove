----------------------------------------------------------------------------------------
--Аналіз по profile (УВАГА!! КОД тільки для BigQuery )
----------------------------------------------------------------------------------------
--рахую ДЕННІ показники профілів: 
--===========================
--мин/макс/ середній, медіанний дохід, стандартне відхидення та середнє DAU 
WITH avg_daily_rvn AS (
SELECT 
				profile_key,
				AVG(sum_daily_rvnue) AS avg_daily_rvnue,
				MIN(sum_daily_rvnue) AS min_daily_rvnue,
				MAX(sum_daily_rvnue) AS max_daily_rvnue,
				APPROX_QUANTILES(sum_daily_rvnue, 2)[OFFSET(1)] AS medn_daily_rvnue,
				STDDEV(sum_daily_rvnue) AS std_daily_rvnue,
				AVG(cnt_day_users) AS avg_dau,
        APPROX_QUANTILES(cnt_day_users, 2)[OFFSET(1)] AS median_dau,
        STDDEV(cnt_day_users) / AVG(cnt_day_users) AS cv_dau
FROM ( SELECT 
								profile_key,
								DATE(time_utc) AS day,
								SUM(total_revenue) AS sum_daily_rvnue,
								COUNT(DISTINCT user_key) as cnt_day_users
				FROM `df_sweetylove.analysis_table`
				GROUP BY profile_key, DATE(time_utc))
WHERE sum_daily_rvnue > 0 -- рахуються лише активні дні. 
GROUP BY profile_key),

--МІСЯЧНІ показники профілів: 
--===========================
--мин/макс/ середній, медіанний дохід, стандартне відхидення та середнє MAU 
avg_monthly_rvn AS (
SELECT 
				profile_key,
				AVG(sum_monthly_rvnue) AS avg_monthly_rvnue,
				MIN(sum_monthly_rvnue) AS min_monthly_rvnue,
				MAX(sum_monthly_rvnue) AS max_monthly_rvnue,
				APPROX_QUANTILES(sum_monthly_rvnue, 2)[OFFSET(1)] AS medn_monthly_rvnue,
				STDDEV(sum_monthly_rvnue) AS std_monthly_rvnue,
				AVG(cnt_mont_users) AS avg_mau,
        APPROX_QUANTILES(cnt_mont_users, 2)[OFFSET(1)] AS median_mau,
        STDDEV(cnt_mont_users) / AVG(cnt_mont_users) AS cv_mau
FROM 
			(SELECT 
							profile_key,
							DATE_TRUNC(DATE(time_utc), MONTH) AS month,
							SUM(total_revenue) AS sum_monthly_rvnue,
							COUNT(DISTINCT user_key) AS cnt_mont_users
			FROM `df_sweetylove.analysis_table`
			GROUP BY profile_key, DATE_TRUNC(DATE(time_utc), MONTH))
			
 WHERE sum_monthly_rvnue > 0 --рахуються лише активні місяці
 GROUP BY profile_key),

 --агрегую загальні показники профілей
by_profile AS (
SELECT 
        profile_key,
        DATE(MIN(time_utc)) AS first_day,
        DATE(MAX(time_utc)) AS last_day,
        COUNT(DISTINCT DATE(time_utc)) AS cnt_active_days,
        COUNT(DISTINCT DATE_TRUNC(time_utc, MONTH)) AS cnt_active_month,
        SUM(total_revenue) AS total_revenue,

        SUM(
            CASE 
					WHEN purchase_for IN ('Chat per minute', 'Chat per message') 
					THEN total_revenue 
					ELSE 0 
				END) AS rvnue_for_chat,

        SUM(
            CASE 
					WHEN purchase_for IN ('View Video', 'View Image', 'Upload Photo') 
					THEN total_revenue 
					ELSE 0 
				END) AS rvnue_for_media,

        COUNT(DISTINCT CASE WHEN user_status = 'free' THEN user_key END) AS cnt_free_users,
        COUNT(DISTINCT CASE WHEN user_status = 'paid' THEN user_key END) AS cnt_paid_users,
        COUNT(DISTINCT CASE WHEN user_status = 'free+paid' THEN user_key END) AS cnt_freepaid_users,
        COUNT(DISTINCT user_key) AS cnt_users
		
FROM `df_sweetylove.analysis_table`
GROUP BY profile_key)

--Джойню усі показники в одну таблицу
SELECT 
			bp.profile_key,  	---ключ профілю
			bp.first_day, --день перщої активності
			bp.last_day, --день останьої активності
			bp.cnt_active_month, --кіл-ть активних місяців
			DATE_DIFF(bp.last_day, bp.first_day, DAY) as total_days, --загальна кіл ть днів з урахуванням "0" днів
			bp.cnt_active_days, --кіл ть активніх днів
			DATE_DIFF(bp.last_day, bp.first_day, DAY) - 
			bp.cnt_active_days AS cnt_zero_days, -- кіл ть днів з 0 доходом
			SAFE_DIVIDE(
				DATE_DIFF(bp.last_day, bp.first_day, DAY) - bp.cnt_active_days,
				DATE_DIFF(bp.last_day, bp.first_day, DAY)
				) AS share_zero_days, --доля 0 днів 
			
			bp.rvnue_for_chat, --загальний дохід за чат по профілю
			bp.rvnue_for_media, --загальний дохід за медіа по профілю
			bp.total_revenue, --загальний дохід профілю
			
			avr.avg_monthly_rvnue, --середньомісячний дохід профіля
			avr.medn_monthly_rvnue, --медіанно місячний дохід профіля
			avr.std_monthly_rvnue, --стандартне відхилення місячного доходу профіля
			avr.std_monthly_rvnue / 
			avr.avg_monthly_rvnue AS cv_monthly, --коефф варіації місячного доходу профіля
			avr.max_monthly_rvnue, --максимальний місячний дохід профіля
			
			adr.avg_daily_rvnue, -- середньоденний дохід профіля
			adr.medn_daily_rvnue, --медіанно денний дохід профіля
			adr.std_daily_rvnue, --стандартне відхилення денного доходу профіля
			adr.std_daily_rvnue / adr.avg_daily_rvnue AS cv_daily,  --коефф варіації денного доходу профіля
			adr.max_daily_rvnue,--максимальний денний дохід профіля
			
			bp.cnt_free_users, --кількість юзерів зі статусом free у профіля
			bp.cnt_paid_users, --кількість юзерів зі статусом paid у профіля
			bp.cnt_freepaid_users, ----кількість юзерів зі статусом freepaid у профіля
			bp.cnt_users, --загальна кількість юзерів у профіля
			adr.avg_dau, --середнє DAU у профіля
      adr.median_dau, --медіанне DAU у профіля
      adr.cv_dau,--коефф варіації DAU у профіля
			avr.avg_mau, --середнє MAU у профіля
      avr.median_mau, --медіанне MAU у профіля
      avr.cv_mau --коефф варіації MAU у профіля
			
FROM avg_daily_rvn adr
JOIN avg_monthly_rvn avr  ON adr.profile_key = avr.profile_key
JOIN by_profile bp  ON bp.profile_key = adr.profile_key;
