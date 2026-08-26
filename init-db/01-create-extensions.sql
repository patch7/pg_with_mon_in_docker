-- Включаем расширение TimescaleDB (обязательно перед созданием гипертаблиц)
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;
-- Добавляем расширение для ведения статистики запросов
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;