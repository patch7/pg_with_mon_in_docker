-- ALTER SYSTEM SET shared_preload_libraries = 'timescaledb, pg_stat_statements';
-- Настройки производительности (применяются после перезагрузки сервера)
ALTER SYSTEM SET max_connections = 32;
ALTER SYSTEM SET shared_buffers = '1GB';
ALTER SYSTEM SET effective_cache_size = '3GB'
-- поможет уменьшить использование диска в HashAggregate и Sort, но при этом жрет много памяти на запросе с большой
-- агрегацией (и то при агрегации на 100 дней немного ходим на диск)
ALTER SYSTEM SET work_mem = '64MB';
ALTER SYSTEM SET maintenance_work_mem = '128MB';
ALTER SYSTEM SET autovacuum_vacuum_scale_factor = 0.1;
ALTER SYSTEM SET autovacuum_analyze_scale_factor = 0.05;
-- Абсолютные пороги, чтобы автовакуум запускался раньше, когда накопится немного мёртвых строк.
-- Это предотвратит накопление миллионов мёртвых строк и резкие всплески
ALTER TABLE "Trade_BTCUSDT" SET (autovacuum_vacuum_threshold = 1000);
ALTER TABLE "Trade_BTCUSDT" SET (autovacuum_analyze_threshold = 500);
ALTER TABLE "Trade_ETHUSDT" SET (autovacuum_vacuum_threshold = 1000);
ALTER TABLE "Trade_ETHUSDT" SET (autovacuum_analyze_threshold = 500);

-- Применить динамические параметры без перезапуска (не все параметры поддерживают)
SELECT pg_reload_conf();