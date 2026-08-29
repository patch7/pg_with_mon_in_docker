CREATE TABLE IF NOT EXISTS "OHLC_ETHUSDT" (
    "Timestamp" BIGINT NOT NULL PRIMARY KEY,
    "Open" INTEGER NOT NULL,
    "High" INTEGER NOT NULL,
    "Low" INTEGER NOT NULL,
    "Close" INTEGER NOT NULL,
    "Full" BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS "Trade_ETHUSDT" (
    "Timestamp" BIGINT NOT NULL,
    "Price" INTEGER NOT NULL,
    "Quantity" INTEGER NOT NULL,
    "TradeId" BIGINT NOT NULL,
    PRIMARY KEY ("Timestamp", "TradeId")
);

CREATE INDEX IF NOT EXISTS "Trade_ETHUSDT_TradeId" ON "Trade_ETHUSDT" ("TradeId");
CREATE INDEX IF NOT EXISTS "Trade_ETHUSDT_TSPrice" ON "Trade_ETHUSDT" ("Timestamp", "Price");

-- Превращаем в гипертаблицу по полю "Timestamp" (интервал чанка – 4 дня)
SELECT create_hypertable('"Trade_ETHUSDT"', 'Timestamp', chunk_time_interval => 4 * 86400);
-- Регистрируем ранее определенную функцию для гипертаблицы
SELECT set_integer_now_func('"Trade_ETHUSDT"', 'int_now_trade');
-- Включить компрессию для гипертаблиц (обязательно перед добавлением политики)
ALTER TABLE "Trade_ETHUSDT" SET (timescaledb.compress, timescaledb.compress_orderby = '"TradeId"');
-- Включаем сжатие через 4 дней после закрытия чанка
SELECT add_compression_policy('"Trade_ETHUSDT"', compress_after => 4 * 86400, schedule_interval => 3600);
-- Автоматическое удаление данных старше 18 недель
SELECT add_retention_policy('"Trade_ETHUSDT"', drop_after => 126 * 86400);

-- Таблицы OHLC не являются гипертаблицами, не превратили OHLC_{} в гипертаблицу, поэтому политики сжатия/удаления не
-- применяются. Если там много данных, стоит сделать гипертаблицами (по Timestamp) и настроить аналогичные политики.
-- Для политик сжатия на материализованные представления не добавлены намеренно (даных не много при агрегации). Можно добавить в будущем.

CREATE MATERIALIZED VIEW "Trade_ETHUSDT_5m" WITH (timescaledb.continuous, timescaledb.materialized_only = false) AS
SELECT time_bucket(300, "Timestamp") AS "Timestamp", 
       "Price",
       SUM("Quantity")::BIGINT AS "Delta",
       SUM(ABS("Quantity"))::BIGINT AS "Volume"
FROM "Trade_ETHUSDT" GROUP BY 1, 2;
-- Автоматическое удаление данных старше 18 недель
SELECT add_retention_policy('"Trade_ETHUSDT_5m"', drop_after => 127 * 86400);
-- Политика автоматического обновления. Без неё агрегаты никогда не пересчитаются при вставке новых данных
SELECT add_continuous_aggregate_policy('"Trade_ETHUSDT_5m"',
                                       start_offset => 50 * 3600, -- 50 часов, т.к. по REST можно вычитать только последние 48 часов
                                       end_offset => 60,
                                       schedule_interval => INTERVAL '1 minutes');

CREATE MATERIALIZED VIEW "Trade_ETHUSDT_1h" WITH (timescaledb.continuous, timescaledb.materialized_only = false) AS
SELECT time_bucket(3600, "Timestamp") AS "Timestamp",
       "Price",
       SUM("Quantity")::BIGINT AS "Delta",
       SUM(ABS("Quantity"))::BIGINT AS "Volume"
FROM "Trade_ETHUSDT_5m" GROUP BY 1, 2;
-- Автоматическое удаление данных старше 18 недель
SELECT add_retention_policy('"Trade_ETHUSDT_1h"', drop_after => 127 * 86400);
-- Политика автоматического обновления. Без неё агрегаты никогда не пересчитаются при вставке новых данных
SELECT add_continuous_aggregate_policy('"Trade_ETHUSDT_1h"',
                                       start_offset => 50 * 3600, -- 50 часов, т.к. по REST можно вычитать только последние 48 часов
                                       end_offset => 60,
                                       schedule_interval => INTERVAL '5 minutes');

CREATE MATERIALIZED VIEW "Trade_ETHUSDT_6h" WITH (timescaledb.continuous, timescaledb.materialized_only = false) AS
SELECT time_bucket(6 * 3600, "Timestamp") AS "Timestamp",
       "Price",
       SUM("Quantity")::BIGINT AS "Delta",
       SUM(ABS("Quantity"))::BIGINT AS "Volume"
FROM "Trade_ETHUSDT_1h" GROUP BY 1, 2;
-- Автоматическое удаление данных старше 18 недель
SELECT add_retention_policy('"Trade_ETHUSDT_6h"', drop_after => 127 * 86400);
-- Политика автоматического обновления. Без неё агрегаты никогда не пересчитаются при вставке новых данных
SELECT add_continuous_aggregate_policy('"Trade_ETHUSDT_6h"',
                                       start_offset => 50 * 3600, -- 50 часов, т.к. по REST можно вычитать только последние 48 часов
                                       end_offset => 60,
                                       schedule_interval => INTERVAL '15 minutes');

CREATE MATERIALIZED VIEW "Trade_ETHUSDT_1d" WITH (timescaledb.continuous, timescaledb.materialized_only = false) AS
SELECT time_bucket(24 * 3600, "Timestamp") AS "Timestamp",
       "Price",
       SUM("Quantity")::BIGINT AS "Delta",
       SUM(ABS("Quantity"))::BIGINT AS "Volume"
FROM "Trade_ETHUSDT_6h" GROUP BY 1, 2;
-- Автоматическое удаление данных старше 18 недель
SELECT add_retention_policy('"Trade_ETHUSDT_1d"', drop_after => 127 * 86400);
-- Политика автоматического обновления. Без неё агрегаты никогда не пересчитаются при вставке новых данных
SELECT add_continuous_aggregate_policy('"Trade_ETHUSDT_1d"',
                                       start_offset => 50 * 3600, -- 50 часов, т.к. по REST можно вычитать только последние 48 часов
                                       end_offset => 60,
                                       schedule_interval => INTERVAL '30 minutes');