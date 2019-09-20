exec msdb..sp_add_jobstep  
    @job_name       = N'tq84_job_example_job',  
    @step_name      = N'tq84_job_example_step',
    @subsystem      = N'TSQL',  
    @command        = N'exec tq84_job_example_proc',   
    @retry_attempts = 0,  
    @retry_interval = 0;  
