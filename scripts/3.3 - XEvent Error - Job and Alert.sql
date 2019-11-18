  
/***********************************************************************************************************************************
(C) 2016, Fabricio França Lima 

Blog: https://www.fabriciolima.net/blog/

Feedback: suporte@fabriciolima.net

Instagram: @fabriciofrancalima

Twitter: @fabriciodba

Facebook: https://www.facebook.com/fabricio.francalima

Linkedin: https://www.linkedin.com/in/fabriciolimasolucoesembd/

Consultoria: comercial@fabriciolima.net

***********************************************************************************************************************************/

/*
Instructions:
1 - You need to change the path to a real one of your server
	Replace: "C:\Temp\Video Alertas"
*/



USE [Traces]
GO

--Enable the Database Error Alert
	update Alert_Parameter
	set Fl_Enable = 1
	WHERE Nm_Alert = 'Database Errors' 


IF ( OBJECT_ID('Log_DB_Error') IS NOT NULL ) 
		DROP TABLE Log_DB_Error

CREATE TABLE [dbo].[Log_DB_Error](
	[err_timestamp] [DATETIME] NULL,
	[err_severity] [TINYINT] NULL,
	[err_number] [INT] NULL,
	[username] [VARCHAR](100) NULL,
	[database_id] [VARCHAR](100) NULL,
	[err_message] [VARCHAR](512) NULL,
	[sql_text] [VARCHAR](MAX) NULL,
	[client_hostname] [varchar](50) NULL,
	[Dt_Error] [DATETIME] NOT NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]


create nonclustered index Sk01_Log_DB_Error on Log_DB_Error(err_timestamp,err_message)

GO
IF ( OBJECT_ID('[dbo].stpXEvent_DB_Error') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpXEvent_DB_Error
GO
CREATE procedure [dbo].stpXEvent_DB_Error
AS
BEGIN
	IF EXISTS( select * from sys.dm_xe_sessions where name = 'what_queries_are_failing' )
	BEGIN
		-- Stop your Extended Events session
		ALTER EVENT SESSION what_queries_are_failing ON SERVER
		STATE = STOP;

		IF(OBJECT_ID('tempdb..#events_cte') IS NOT NULL)
			DROP TABLE #events_cte

		select
			DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), CURRENT_TIMESTAMP),xevents.event_data.value('(event/@timestamp)[1]', 'datetime')) AS [err_timestamp],
			xevents.event_data.value('(event/data[@name="severity"]/value)[1]', 'tinyint') AS [err_severity],
			xevents.event_data.value('(event/data[@name="error_number"]/value)[1]', 'int') AS [err_number],
			xevents.event_data.value('(event/action[@name="username"]/value)[1]', 'varchar(100)') AS username,
			xevents.event_data.value('(event/action[@name="database_id"]/value)[1]', 'varchar(100)') AS database_id,
			xevents.event_data.value('(event/data[@name="message"]/value)[1]', 'varchar(512)') AS [err_message],
			xevents.event_data.value('(event/action[@name="sql_text"]/value)[1]', 'varchar(max)') AS [sql_text],
			xevents.event_data.value('(event/action[@name="client_hostname"]/value)[1]', 'varchar(max)') AS [client_hostname],
			--xevents.event_data
			GETDATE() as [Dt_Error]
		into #events_cte
		from sys.fn_xe_file_target_read_file
			('C:\Temp\Video Alertas\what_queries_are_failing*.xel',
			'C:\Temp\Video Alertas\what_queries_are_failing*.xem',
			null, null)
		cross apply (select CAST(event_data as XML) as event_data) as xevents

		insert into Log_DB_Error([err_timestamp], [err_severity], [err_number], [username], [database_id], [err_message], [sql_text], [client_hostname],[Dt_Error])
		SELECT A.[err_timestamp], A.[err_severity], A.[err_number], A.[username], A.[database_id], A.[err_message], A.[sql_text], A.[client_hostname],A.[Dt_Error]
		from #events_cte A	
		left join Log_DB_Error B on A.err_message = B.err_message and A.err_timestamp = B.err_timestamp
		where A.sql_text not like '%sp_whoisactive%'			
			and B.err_message is null
		order by A.err_timestamp
	END

	IF EXISTS( select * from sys.server_event_sessions where name = 'what_queries_are_failing' )
	BEGIN
		-- Clean up your session from the server
		DROP EVENT SESSION what_queries_are_failing ON SERVER;
	END

	CREATE EVENT SESSION
	what_queries_are_failing
	ON SERVER
	ADD EVENT sqlserver.error_reported
	(
	ACTION (sqlserver.client_hostname,sqlserver.sql_text, sqlserver.tsql_stack, sqlserver.database_id, sqlserver.username)
	WHERE ([severity]> 12)
	)
	ADD TARGET package0.asynchronous_file_target
	(set filename = 'C:\Temp\Video Alertas\what_queries_are_failing.xel' ,
	metadatafile = 'C:\Temp\Video Alertas\what_queries_are_failing.xem',
	max_file_size = 500,
	max_rollover_files = 5)
	WITH (MAX_DISPATCH_LATENCY = 5SECONDS)

	-- Start the session
	ALTER EVENT SESSION what_queries_are_failing
	ON SERVER STATE = START
END
GO

USE [msdb]

GO

IF EXISTS ( SELECT job_id 
            FROM msdb.dbo.sysjobs_view 
            WHERE name = N'DBA - Load XEvent Database Error')
	EXEC msdb.dbo.sp_delete_job @job_name = N'DBA - Load XEvent Database Error', @delete_unused_schedule = 1

GO

/****** Object:  Job [DBA - XEvent erros Banco de dados]    Script Date: 22/02/2018 19:09:34 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 22/02/2018 19:09:34 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Load XEvent Database Error', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA_Operator',
		@job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DBA - XEvent error]    Script Date: 22/02/2018 19:09:34 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DBA - XEvent error', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec stpXEvent_DB_Error', 
		@database_name=N'Traces', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 5 Minutes', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=60, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150812, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'3fa56740-03a8-4232-8c5b-1cf2b0286f22'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


	IF EXISTS( select * from sys.server_event_sessions where name = 'what_queries_are_failing' )
	BEGIN
		-- Clean up your session from the server
		DROP EVENT SESSION what_queries_are_failing ON SERVER;
	END
	GO
CREATE EVENT SESSION
what_queries_are_failing
ON SERVER
ADD EVENT sqlserver.error_reported
(
ACTION (sqlserver.client_hostname,sqlserver.sql_text, sqlserver.tsql_stack, sqlserver.database_id, sqlserver.username)
WHERE ([severity]> 12)
)
ADD TARGET package0.asynchronous_file_target
(set filename = 'C:\Temp\Video Alertas\what_queries_are_failing.xel' ,
metadatafile = 'C:\Temp\Video Alertas\what_queries_are_failing.xem',
max_file_size = 500,
max_rollover_files = 5)
WITH (MAX_DISPATCH_LATENCY = 5SECONDS)


-- Start the session
ALTER EVENT SESSION what_queries_are_failing
ON SERVER STATE = START



GO
USE [Traces]
