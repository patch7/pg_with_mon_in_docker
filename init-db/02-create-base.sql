-- Таблица для хранения учётных записей бирж
CREATE TABLE IF NOT EXISTS "Auth" (
    "Exchange" TEXT NOT NULL UNIQUE,
    "Account" TEXT NOT NULL,
    "APIKey" TEXT NOT NULL,
    "SecretKey" TEXT NOT NULL,
    "UserName" TEXT NOT NULL,
    "FullName" TEXT NOT NULL
);

-- Справочник символов (инструментов)
CREATE TABLE IF NOT EXISTS "Symbol" (
    "Symbol" TEXT NOT NULL UNIQUE,
    "PriceStep" NUMERIC NOT NULL,
    "LotStep" NUMERIC NOT NULL,
    "PricePrecision" INTEGER NOT NULL,
    "LotPrecision" INTEGER NOT NULL
);

-- Таблица для хранения мета данных коллектора и филлера
CREATE TABLE IF NOT EXISTS "Metadata" ("Key" TEXT PRIMARY KEY, "Value" TEXT);

-- Создаём функции int_now для корректной работы гипертаблицы (обязательно перед настройкой гипертаблиц)
CREATE OR REPLACE FUNCTION int_now_trade() RETURNS BIGINT LANGUAGE SQL STABLE AS $$ SELECT CAST(EXTRACT(EPOCH FROM NOW()) AS BIGINT); $$;