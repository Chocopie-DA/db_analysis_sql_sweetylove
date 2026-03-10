-- =====================================================
-- Проект: Sweetylove - створення та налаштування БД. Аналіз данних.
-- Файл: schema.sql
-- Опис: 
--   Структура бази даних.
--   Містить опис таблиць, первинних (PK) та зовнішніх ключів (FK),
--   а також індекси для оптимізації запитів.
--   Використовується для підготовки, перевірки та аналізу даних.
-- СУБД: SQLite
-- Автор: Стрижак Микола
-- Створено: 2026-02-06
-- =====================================================

PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

--==================
-- Dimension tables
--==================
-- Таблица приложений(сайтов)
DROP TABLE IF EXISTS "apps";
CREATE TABLE "apps" (
    "app_key"   INTEGER PRIMARY KEY AUTOINCREMENT,
    "app_name"  TEXT NOT NULL UNIQUE);

-- Таблица операторов
DROP TABLE IF EXISTS "operators";
CREATE TABLE "operators" (
    "operator_key"   INTEGER PRIMARY KEY AUTOINCREMENT,
    "operator_name"  TEXT NOT NULL UNIQUE);

-- Таблица профилей(моделей)
DROP TABLE IF EXISTS "profiles";
CREATE TABLE "profiles" (
    "profile_key"   INTEGER PRIMARY KEY AUTOINCREMENT,
    "profile_id"    TEXT NOT NULL UNIQUE,
    "profile_name"  TEXT NOT NULL);

-- Таблица пользователей
DROP TABLE IF EXISTS "users";
CREATE TABLE "users" (
    "user_key"   INTEGER PRIMARY KEY AUTOINCREMENT,
    "user_id"    TEXT NOT NULL UNIQUE,
    "user_name"  TEXT NOT NULL);

-- ==================
--  Основна таблиця
-- ==================
DROP TABLE IF EXISTS "purchases";
CREATE TABLE "purchases" (
    "id"            INTEGER PRIMARY KEY AUTOINCREMENT,
    "time_utc"      TEXT NOT NULL,
    "operator_key"  INTEGER NOT NULL,
    "profile_key"   INTEGER NOT NULL,
    "user_key"      INTEGER NOT NULL,
    "app_key"       INTEGER NOT NULL,
    "purchase_for"  TEXT NOT NULL,
    "purchase_place" TEXT NOT NULL,
    "credit_gross"  REAL CHECK (credit_gross > 0),
    "revenue_free"  REAL CHECK (revenue_free >= 0),
    "revenue_paid"  REAL CHECK (revenue_paid >= 0),
	
    FOREIGN KEY("app_key") REFERENCES "apps"("app_key"),
    FOREIGN KEY("operator_key") REFERENCES "operators"("operator_key"),
    FOREIGN KEY("profile_key") REFERENCES "profiles"("profile_key"),
    FOREIGN KEY("user_key") REFERENCES "users"("user_key")
);

-- =========================
-- Индекси
-- =========================

DROP INDEX IF EXISTS "idx_purch_app";
CREATE INDEX "idx_purch_app" ON "purchases" ("app_key" ASC);

DROP INDEX IF EXISTS "idx_purch_operator";
CREATE INDEX "idx_purch_operator" ON "purchases" ("operator_key" ASC);

DROP INDEX IF EXISTS "idx_purch_profile";
CREATE INDEX "idx_purch_profile" ON "purchases" ("profile_key" ASC);

DROP INDEX IF EXISTS "idx_purch_time";
CREATE INDEX "idx_purch_time" ON "purchases" ("time_utc" ASC);

DROP INDEX IF EXISTS "idx_purch_user";
CREATE INDEX "idx_purch_user" ON "purchases" ("user_key" ASC);

COMMIT;

