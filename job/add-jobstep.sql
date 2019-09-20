exec msdb..sp_add_jobstep  
    @job_name          = N'tq84_job_example_job',  
    @step_name         = N'tq84_job_example_step',
    @step_id           =   1,  -- Used to order steps.
    @subsystem         = N'TSQL',
    @database_name     =  'job_test',                   -- <<<  Change here !!!
    @command           = N'exec tq84_job_example_proc',
    @on_success_action =   3, -- Go to next step
    @retry_attempts    =   0,  
    @retry_interval    =   0;  
;
