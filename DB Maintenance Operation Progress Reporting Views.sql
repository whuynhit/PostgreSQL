-- Unified view for pg_stat_progress_create_index (CREATE INDEX & REINDEX Operations)
SELECT 
	now() - a.query_start AS query_duration,
	ci.pid,
	ci.datname,
	ai.schemaname,
	ai.relname,
	ai.indexrelname,
	ci.command,
	a.query,
	ci.phase,
	a.wait_event_type,
	a.wait_event,
	a.state,
	ci.lockers_total,
	ci.lockers_done,
	ci.current_locker_pid,
	ci.blocks_total,
	ci.blocks_done,
	ci.tuples_total,
	ci.tuples_done,
	ci.partitions_total,
	ci.partitions_done
FROM pg_stat_progress_create_index ci
INNER JOIN pg_statio_all_indexes ai
ON ci.index_relid = ai.indexrelid
INNER JOIN pg_stat_activity a
ON ci.pid = a.pid;

-- Unified view for pg_stat_progress_vacuum (VACUUM & Autovacuum Operations)
SELECT
	now() - a.query_start AS query_duration,
	v.pid,
	v.datname,
	t.schemaname,
	t.relname,
	v.phase,
	a.query,
	a.wait_event_type,
	a.wait_event,
	a.state,
	v.heap_blks_total,
	v.heap_blks_scanned,
	v.heap_blks_vacuumed,
	v.index_vacuum_count,
	v.max_dead_tuples,
	v.num_dead_tuples
FROM pg_stat_progress_vacuum v
INNER JOIN pg_stat_all_tables t
ON v.relid = t.relid
INNER JOIN pg_stat_activity a
ON v.pid = a.pid;

-- Unified view for pg_stat_progress_cluster (VACUUM FULL Operations)
SELECT
	now() - a.query_start AS query_duration,
	c.pid,
	c.datname,
	t.schemaname,
	t.relname,
	c.command,
	c.phase,
	a.wait_event_type,
	a.wait_event,
	a.state,
	c.heap_tuples_scanned,
	c.heap_tuples_written,
	c.heap_blks_total,
	c.heap_blks_scanned,
	c.index_rebuild_count
FROM pg_stat_progress_cluster c
INNER JOIN pg_stat_all_tables t
ON c.relid = t.relid
INNER JOIN pg_stat_activity a
ON c.pid = a.pid;
