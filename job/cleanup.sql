exec msdb..sp_delete_jobserver @jobname = N'tq84_job_example_job'






exec msdb..sp_delete_jobstep 
   @step_id  =  1,
   @job_name = 'tq84_job_example_job';

exec msdb..sp_delete_job @job_name = N'tq84_job_example_job';
