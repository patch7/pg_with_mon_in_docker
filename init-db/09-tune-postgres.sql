-- Динамические параметры (применяются без перезапуска)
ALTER SYSTEM SET work_mem = '64MB';
ALTER SYSTEM SET maintenance_work_mem = '128MB';
ALTER SYSTEM SET autovacuum_vacuum_scale_factor = 0.1;
ALTER SYSTEM SET autovacuum_analyze_scale_factor = 0.05;

-- Абсолютные пороги для таблиц (чтобы автовакуум запускался раньше, предотвратит накопление многих мёртвых строк)
ALTER TABLE "Trade_BTCUSDT" SET (autovacuum_analyze_threshold = 500);
ALTER TABLE "Trade_ETHUSDT" SET (autovacuum_analyze_threshold = 500);
ALTER TABLE "Trade_BTCUSDT" SET (autovacuum_vacuum_threshold = 1000);
ALTER TABLE "Trade_ETHUSDT" SET (autovacuum_vacuum_threshold = 1000);

-- Применить динамические параметры без перезапуска
SELECT pg_reload_conf();