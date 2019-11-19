sELECT
		ses.session_id,
		db_name(er.database_id) as db_name,
		ses.login_name,
		ses.host_name,
		er.start_time,
		con.client_net_address,
		st.text sql_text
FROM
	   sys.dm_exec_requests    er                                                     OUTER APPLY
	   sys.dm_exec_sql_text(er.sql_handle) st                                         LEFT JOIN
	   sys.dm_exec_sessions    ses                ON ses.session_id = er.session_id   LEFT JOIN
	   sys.dm_exec_connections con ON con.session_id = ses.session_id
WHERE
	   ses.is_user_process  = 0x1 aND
	   ses.session_id      != @@spid
ORDER BY
		ses.session_id
