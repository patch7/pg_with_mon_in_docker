-- Создаём функции int_now для корректной работы политик удаления
CREATE OR REPLACE FUNCTION int_now_trade() RETURNS BIGINT LANGUAGE SQL STABLE AS $$ SELECT CAST(EXTRACT(EPOCH FROM NOW()) AS BIGINT); $$;

-- Регистрируем функции для каждой гипертаблицы
SELECT set_integer_now_func('"Trade_BTCUSDT"', 'int_now_trade');
SELECT set_integer_now_func('"Trade_ETHUSDT"', 'int_now_trade');

-- Включаем сжатие через 7 дней после закрытия чанка
SELECT add_compression_policy('"Trade_BTCUSDT"', compress_after => 7 * 86400, schedule_interval => 3600);
SELECT add_compression_policy('"Trade_ETHUSDT"', compress_after => 7 * 86400, schedule_interval => 3600);

-- Для политик сжатия на материализованные представления не добавлены намеренно (даных не много при агрегации). Можно добавить в будущем.

-- Автоматическое удаление данных старше 18 недель
SELECT add_retention_policy('"Trade_BTCUSDT"', drop_after => 126 * 86400);
SELECT add_retention_policy('"Trade_ETHUSDT"', drop_after => 126 * 86400);