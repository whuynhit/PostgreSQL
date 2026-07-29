-- ANALYZE operation progress reporting
SELECT 
	pid,
	datname,
	relid::regclass,
	phase,
	sample_blks_total,
	sample_blks_scanned,
	ext_stats_total,
	ext_stats_computed,
	child_tables_total,
	child_tables_done,
	current_child_table_relid::regclass
FROM pg_stat_progress_analyze;
