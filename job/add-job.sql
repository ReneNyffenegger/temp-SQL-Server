-- Msg 2812, Level 16, State 62, Line 28
-- Could not find stored procedure 'sp_add_job'.

-- exec msdb..sp_add_job @job_name = N'tq84_job_example_job';
   exec msdb..sp_add_job @job_name = N'exec tq84_job_example_job';

--
-- After a job was added, the job is shown in the Management Studio in the Object Explorer under
--    SQL Server Agent -> Jobs
--
--  This is because the SQL server is stopped which can be verified with
--      exec master.sys.xp_servicecontrol N'querystate', N'SQLserverAgent'
--
--  The SQL Server Agent might be started with T-SQL with
--      exec master.sys.xp_servicecontrol N'start', N'SQLserverAgent'
--            --> StartService() returned error 5, 'Access is denied.'
--
