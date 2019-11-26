select
   pl.query_plan,
   tx.text,
   qs.statement_start_offset,
   qs.statement_end_offset,
   SUBSTRING(tx.text,
		(qs.statement_start_offset / 2) + 1,
		(CASE WHEN qs.statement_end_offset =-1 THEN DATALENGTH(tx.text) ELSE qs.statement_end_offset END - qs.statement_start_offset)
		/ 2 + 1
   )                                                                    as  query_text,
	case when pl.query_plan LIKE '%<MissingIndexes>%' then 1 else 0 end as [missing indices?],
    qs.execution_count,
	qs.total_worker_time/execution_count   AS avg_cpu_time,
	qs.total_worker_time                   AS total_cpu_time,
	qs.total_logical_reads/execution_count AS avg_logical_reads,
	qs.total_logical_reads,
	qs.creation_time                       AS [plan creation time],
	qs.last_execution_time                 as last_execution_time,
	CAST(pl.query_plan AS XML)             AS sqlplan
FROM
   sys.dm_exec_query_stats                                                                         as qs CROSS APPLY
   sys.dm_exec_text_query_plan(qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset) as pl CROSS APPLY
   sys.dm_exec_sql_text(qs.sql_handle)                                                             as tx
WHERE
   pl.query_plan LIKE '%exch_vst_v%'
ORDER BY
   execution_count DESC
OPTION (RECOMPILE);
