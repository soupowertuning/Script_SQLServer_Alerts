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

USE [Traces]
GO
--Enable the AlwaysON Alert
UPDATE [dbo].Alert_Parameter 
SET Fl_Enable = 1
WHERE Nm_Alert = 'AlwaysON AG Status'


IF ( OBJECT_ID('[dbo].Log_AlwaysOn_AG') IS NOT NULL )
	DROP TABLE [dbo].Log_AlwaysOn_AG;

CREATE TABLE [dbo].[Log_AlwaysOn_AG](
	[Dt_Log] [datetime] NULL,
	[replica_server_name] [varchar](256) NULL,
	[database_name] [sysname] NULL,
	[ag_name] [sysname] NULL,
	[is_local] [bit] NULL,
	[is_primary_replica] [bit] NULL,
	[synchronization_state_desc] [varchar](60) NULL,
	[is_commit_participant] [bit] NULL,
	[synchronization_health_desc] [varchar](60) NULL,
	[recovery_lsn] [numeric](25, 0) NULL,
	[truncation_lsn] [numeric](25, 0) NULL,
	[last_sent_lsn] [numeric](25, 0) NULL,
	[last_sent_time] [datetime] NULL,
	[last_received_lsn] [numeric](25, 0) NULL,
	[last_received_time] [datetime] NULL,
	[last_hardened_lsn] [numeric](25, 0) NULL,
	[last_hardened_time] [datetime] NULL,
	[last_redone_lsn] [numeric](25, 0) NULL,
	[last_redone_time] [datetime] NULL,
	[log_send_queue_size] [bigint] NULL,
	[log_send_rate] [bigint] NULL,
	[redo_queue_size] [bigint] NULL,
	[redo_rate] [bigint] NULL,
	[filestream_send_rate] [bigint] NULL,
	[end_of_log_lsn] [numeric](25, 0) NULL,
	[last_commit_lsn] [numeric](25, 0) NULL,
	[last_commit_time] [datetime] NULL
) ON [PRIMARY]


GO 
IF ( OBJECT_ID('[dbo].[stpLoad_Log_AlwaysOn_AG]') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpLoad_Log_AlwaysOn_AG
GO

CREATE procedure [dbo].[stpLoad_Log_AlwaysOn_AG]
AS

declare @Actual_Date datetime
set @Actual_Date = getdate()

insert into [Log_AlwaysOn_AG]
SELECT 
	@Actual_Date,
	ar.replica_server_name, 
	adc.database_name, 
	ag.name AS ag_name, 
	drs.is_local, 
	drs.is_primary_replica, 
	drs.synchronization_state_desc, 
drs.is_commit_participant, 
	drs.synchronization_health_desc, 
	drs.recovery_lsn, 
	drs.truncation_lsn, 
	drs.last_sent_lsn, 
	drs.last_sent_time, 
	drs.last_received_lsn, 
	drs.last_received_time, 
	drs.last_hardened_lsn, 
	drs.last_hardened_time, 
	drs.last_redone_lsn, 
	drs.last_redone_time, 
	drs.log_send_queue_size, 
	drs.log_send_rate, 
	drs.redo_queue_size, 
	drs.redo_rate, 
	drs.filestream_send_rate, 
	drs.end_of_log_lsn, 
	drs.last_commit_lsn, 
	drs.last_commit_time
FROM sys.dm_hadr_database_replica_states AS drs
INNER JOIN sys.availability_databases_cluster AS adc 
	ON drs.group_id = adc.group_id AND 
	drs.group_database_id = adc.group_database_id
INNER JOIN sys.availability_groups AS ag
	ON ag.group_id = drs.group_id
INNER JOIN sys.availability_replicas AS ar 
	ON drs.group_id = ar.group_id AND 
	drs.replica_id = ar.replica_id

GO
IF ( OBJECT_ID('[dbo].[stpAlert_AlwaysON_AG_Status]') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_AlwaysON_AG_Status
GO

CREATE PROCEDURE [dbo].[stpAlert_AlwaysON_AG_Status]
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Id_Alert_Parameter SMALLINT, @Fl_Enable BIT, @Fl_Type TINYINT, @Vl_Parameter SMALLINT,@Ds_Email VARCHAR(500),@Ds_Profile_Email VARCHAR(200),@Dt_Now DATETIME,@Vl_Parameter_2 INT,
		@Ds_Email_Information_1_ENG VARCHAR(200), @Ds_Email_Information_2_ENG VARCHAR(200), @Ds_Email_Information_1_PTB VARCHAR(200), @Ds_Email_Information_2_PTB VARCHAR(200),
		@Ds_Message_Alert_ENG varchar(1000),@Ds_Message_Clear_ENG varchar(1000),@Ds_Message_Alert_PTB varchar(1000),@Ds_Message_Clear_PTB varchar(1000), @Ds_Subject VARCHAR(500)
	
	DECLARE @Company_Link  VARCHAR(4000),@Line_Space VARCHAR(4000),@Header_Default VARCHAR(4000),@Header VARCHAR(4000),@Fl_Language BIT,@Final_HTML VARCHAR(MAX),@HTML VARCHAR(MAX)		

								
	IF @Fl_Enable = 0
		RETURN
	
	-- Alert information
	SELECT @Id_Alert_Parameter = Id_Alert_Parameter, 
		@Fl_Enable = Fl_Enable, 
		@Vl_Parameter = Vl_Parameter,		-- Minutes,
		@Ds_Email = Ds_Email,
		@Fl_Language = Fl_Language,
		@Ds_Profile_Email = Ds_Profile_Email,
		@Vl_Parameter_2 = Vl_Parameter_2,		--minute
		@Dt_Now = GETDATE(),
		@Ds_Message_Alert_ENG = Ds_Message_Alert_ENG,
		@Ds_Message_Clear_ENG = Ds_Message_Clear_ENG,
		@Ds_Message_Alert_PTB = Ds_Message_Alert_PTB,
		@Ds_Message_Clear_PTB = Ds_Message_Clear_PTB,
		@Ds_Email_Information_1_ENG = Ds_Email_Information_1_ENG,
		@Ds_Email_Information_2_ENG = Ds_Email_Information_2_ENG,
		@Ds_Email_Information_1_PTB = Ds_Email_Information_1_PTB,
		@Ds_Email_Information_2_PTB = Ds_Email_Information_2_PTB
	FROM [Traces].[dbo].Alert_Parameter 
	WHERE Nm_Alert = 'AlwaysON AG Status'

	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
	declare @Last_Status datetime

	select @Last_Status = max(Dt_Log) from Log_AlwaysOn_AG

	select Dt_Log, replica_server_name, database_name, ag_name, synchronization_state_desc,synchronization_health_desc
	into #AlWaysON_AG_Problem
	from Log_AlwaysOn_AG
	where is_primary_replica = 1
		and (synchronization_state_desc <> 'SYNCHRONIZED' or synchronization_health_desc <> 'HEALTHY')
		and Dt_Log = @Last_Status

	--	Do we have Memory problem?	
	IF EXISTS (	SELECT null	FROM   #AlWaysON_AG_Problem )		
	BEGIN	
		IF ISNULL(@Fl_Type, 0) = 0	-- Control Alert/Clear
		BEGIN
			IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
				DROP TABLE ##Email_HTML
						
			SELECT *
			INTO ##Email_HTML
			FROM    #AlWaysON_AG_Problem				
			
			IF ( OBJECT_ID('tempdb..##Email_HTML_2') IS NOT NULL )
				DROP TABLE ##Email_HTML_2	
				 	
			SELECT TOP 50 *
			INTO ##Email_HTML_2
			FROM ##WhoIsActive_Result
			ORDER BY [dd hh:mm:ss.mss] DESC 
				 
		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter			

		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				SET @Ds_Subject =  @Ds_Message_Alert_PTB+@@SERVERNAME 
		END
        ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
			SET @Ds_Subject =  @Ds_Message_Alert_ENG+@@SERVERNAME 
		END		   		

		declare @Ds_Alinhamento VARCHAR(10),@Ds_OrderBy VARCHAR(MAX) 
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML',	
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = 'database_name',
			@Ds_Saida = @HTML OUT			
						
		-- First Result
		SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space 		
				
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML_2', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[dd hh:mm:ss.mss] desc',
			@Ds_Saida = @HTML OUT				-- varchar(max)			

		IF @Fl_Language = 1
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_PTB)
		ELSE 
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_ENG)				

		-- Second Result
		SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space + @Company_Link			

		EXEC [msdb].[dbo].[sp_send_dbmail]
				@profile_name = @Ds_Profile_Email,
				@recipients =	@Ds_Email,
				@subject =		@Ds_Subject,
				@body =			@Final_HTML,
				@body_format =	'HTML',
				@importance =	'High'									
		
		-- Fl_Type = 1 : ALERT	
		INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
		SELECT @Id_Alert_Parameter, @Ds_Subject, 1			
		
	END		-- END - ALERT
	END
	ELSE 
	BEGIN	-- BEGIN - CLEAR				
		IF @Fl_Type = 1
		BEGIN			
			
			IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR') IS NOT NULL )
					DROP TABLE ##Email_HTML_CLEAR
			
			SELECT *
			INTO ##Email_HTML_CLEAR
			FROM   #AlWaysON_AG_Problem		

			IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR_2') IS NOT NULL )
				DROP TABLE ##Email_HTML_CLEAR_2	
				 	
			SELECT TOP 50 *
			INTO ##Email_HTML_CLEAR_2
			FROM ##WhoIsActive_Result
			ORDER BY [dd hh:mm:ss.mss] DESC 
				 
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter
			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  @Ds_Message_Clear_PTB+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject = @Ds_Message_Clear_ENG+@@SERVERNAME 
		   END		   		

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_CLEAR', -- varchar(max)
				@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = 'database_name',
				@Ds_Saida = @HTML OUT				-- varchar(max)

			-- First Result
			SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space 		
				
			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_CLEAR_2', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[dd hh:mm:ss.mss] desc',
				@Ds_Saida = @HTML OUT				-- varchar(max)			

			IF @Fl_Language = 1
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_PTB)
			ELSE 
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_ENG)				

			-- Second Result
			SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space + @Company_Link			

			EXEC [msdb].[dbo].[sp_send_dbmail]
					@profile_name = @Ds_Profile_Email,
					@recipients =	@Ds_Email,
					@subject =		@Ds_Subject,
					@body =			@Final_HTML,
					@body_format =	'HTML',
					@importance =	'High'			
			
			-- Fl_Type = 0 : CLEAR
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 0		
		END		
	END		-- END - CLEAR	

END

GO
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - AlwaysOn AG Load and Alert')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - AlwaysOn AG Load and Alert', @delete_unused_schedule=1
GO
GO

USE [msdb]
GO

/****** Object:  Job [DBA - AlwaysOn AG Load and Alert]    Script Date: 07/09/2019 15:29:33 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 07/09/2019 15:29:33 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - AlwaysOn AG Load and Alert', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [AlwaysON]    Script Date: 07/09/2019 15:29:33 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'AlwaysON', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
exec stpLoad_Log_AlwaysOn_AG

exec stpAlert_AlwaysON_AG_Status

', 
		@database_name=N'Traces', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Alwayson', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190907, 
		@active_end_date=99991231, 
		@active_start_time=47, 
		@active_end_time=235959, 
		@schedule_uid=N'1f4d4059-80c0-4d6f-9090-cd8c69e68045'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


