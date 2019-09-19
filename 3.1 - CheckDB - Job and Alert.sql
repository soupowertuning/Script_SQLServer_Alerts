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

USE Traces

GO
IF ( OBJECT_ID('[dbo].[stpCHECKDB_Databases]') IS NOT NULL ) 
	DROP PROCEDURE [dbo].[stpCHECKDB_Databases]
GO

CREATE PROCEDURE [dbo].[stpCHECKDB_Databases]
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @Databases TABLE ( 
		[Id_Database] INT IDENTITY(1, 1), 
		[Nm_Database] VARCHAR(256)
	)

	DECLARE @Total INT, @Loop INT, @Nm_Database VARCHAR(256)
	
	INSERT INTO @Databases( [Nm_Database] )
	SELECT A.[name]
	FROM [master].[sys].[databases] A
	LEFT JOIN [dbo].Ignore_Databases B ON A.[name] = B.[Nm_Database]
	WHERE	A.[name] NOT IN ('tempdb')
			AND A.[state_desc] = 'ONLINE'
			and B.[Nm_Database] IS NULL		


	SELECT @Total = MAX([Id_Database])
	FROM @Databases

	SET @Loop = 1

	WHILE ( @Loop <= @Total )
	BEGIN
		SELECT @Nm_Database = [Nm_Database]
		FROM @Databases
		WHERE [Id_Database] = @Loop

		DBCC CHECKDB(@Nm_Database) WITH NO_INFOMSGS 
		SET @Loop = @Loop + 1
	END
END

GO


USE [msdb]

GO
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Check Corruption Databases')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Check Corruption Databases', @delete_unused_schedule=1
GO

USE [msdb]
GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 27/01/2017 14:49:04 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Check Corruption Databases', 
		@enabled=0, 
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
/****** Object:  Step [DBA - Check Corruption Databases]    Script Date: 27/01/2017 14:49:04 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DBA - Check Corruption Databases', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [dbo].[stpCHECKDB_Databases]', 
		@database_name=N'Traces', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Alerta Corrupção Databases]    Script Date: 27/01/2017 14:49:04 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Alert Database Corruption', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
		EXEC stpRead_Error_log 0
		EXEC [dbo].[stpAlert_CheckDB]', 
		@database_name=N'Traces', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DBA - Check Corruption Databases', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170127, 
		@active_end_date=99991231, 
		@active_start_time=20000, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
