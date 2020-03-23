Use Traces
go

CREATE TABLE [dbo].[Log_Identity_MaxSize](
	[Dt_Log] [datetime] NULL,
	[Ds_Database] [sysname] NULL,
	[Ds_Tabela] [sysname] NULL,
	[Ds_Coluna] [sysname] NULL,
	[Ds_Tipo_Dado] [sysname] NULL,
	[Vl_Maximo] [bigint] NULL,
	[Vl_Inicial] [bigint] NULL,
	[Vl_Incremento] [bigint] NULL,
	[Vl_Ultimo_Valor] [bigint] NULL,
	[Qt_Linhas] [bigint] NULL,
	[Pr_Atingimento] [decimal](18, 2) NULL
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Alert_Identity_Valor_Maximo_Tipo_Dado](
	[Ds_Tipo_Dado] [varchar](50) NULL,
	[Vl_Maximo] [bigint] NULL
) ON [PRIMARY]

GO

INSERT INTO [Alert_Identity_Valor_Maximo_Tipo_Dado] 
VALUES 
   ('tinyint' , 255),
   ('smallint' , 32767),
   ('int' , 2147483647),
   ('bigint' , 9223372036854775807)
 

INSERT INTO Traces.[dbo].[Alert_Parameter]
           ([Nm_Alert]
           ,[Nm_Procedure]
           ,[Frequency_Minutes]
           ,[Hour_Start_Execution]
           ,[Hour_End_Execution]
           ,[Fl_Language]
           ,[Fl_Clear]
           ,[Fl_Enable]
           ,[Vl_Parameter]
           ,[Ds_Metric]
           ,[Vl_Parameter_2]
           ,[Ds_Metric_2]
           ,[Ds_Profile_Email]
           ,[Ds_Email]
           ,[Ds_Message_Alert_ENG]
           ,[Ds_Message_Clear_ENG]
           ,[Ds_Message_Alert_PTB]
           ,[Ds_Message_Clear_PTB]
           ,[Ds_Email_Information_1_ENG]
           ,[Ds_Email_Information_2_ENG]
           ,[Ds_Email_Information_1_PTB]
           ,[Ds_Email_Information_2_PTB])
   select 'Identity MaxSize', 'stpAlert_Identity_MaxSize', null,null,null, 1,0,1,NULL,NULL,NULL,NULL, 'Profile','email@dominio.com',
   'ALERT: There is an IDENTITY above 60% of the maximum size','','ALERTA: Existe um ou mais IDENTITY acima de 60% do tamanho máximo','','Identity Maxsize Information',null,'Informações sobre o tamanho maximo do Identity', null




CREATE procedure [dbo].[stpLoad_Log_Identity_MaxSize]
AS

EXEC master.dbo.sp_MSforeachdb '
IF (''?'' NOT IN (''msdb'', ''master'', ''model'', ''tempdb''))
BEGIN
 
    INSERT INTO Traces..Log_Identity_MaxSize
    SELECT DISTINCT
		getdate() Dt_Log,
        ''?'' AS Ds_Database,
        B.name AS Ds_Tabela,
        A.name AS Ds_Coluna,
        C.name AS Ds_Tipo_Dado,
        D.Vl_Maximo,
        CONVERT(VARCHAR(20), A.seed_value) AS Vl_Inicial,
        CONVERT(VARCHAR(20), A.increment_value) AS Vl_Incremento, 
        CONVERT(VARCHAR(20), A.last_value) AS Vl_Ultimo_Valor,
        E.row_count AS Qt_Linhas,
        (CONVERT(FLOAT, CONVERT(VARCHAR(20), A.last_value)) * 100 / D.Vl_Maximo) AS Pr_Atingimento
    FROM 
        [?].sys.identity_columns                A   WITH(NOLOCK)
        JOIN [?].sys.tables                     B   WITH(NOLOCK)    ON  A.[object_id] = B.[object_id]
        JOIN [?].sys.types                      C   WITH(NOLOCK)    ON  A.system_type_id = C.system_type_id
        JOIN Traces..Alert_Identity_Valor_Maximo_Tipo_Dado            D   WITH(NOLOCK)    ON  C.name COLLATE SQL_Latin1_General_CP1_CI_AI = D.Ds_Tipo_Dado
        JOIN [?].sys.dm_db_partition_stats      E   WITH(NOLOCK)    ON  E.[object_id] = A.[object_id]
        JOIN [?].sys.indexes                    F   WITH(NOLOCK)    ON  E.index_id = F.index_id
    WHERE 
        E.row_count > 0
 
 
END'


Delete from Traces..Log_Identity_MaxSize where dt_log < getdate()-5

END



CREATE PROCEDURE [dbo].[stpAlert_Identity_MaxSize]
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
	WHERE Nm_Alert = 'Identity MaxSize'

	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
	declare @Last_Status datetime

	select @Last_Status = max(Dt_Log) from Traces..Log_Identity_MaxSize

	select *
	into #Log_Identity_MaxSize_Problem
	from Traces..Log_Identity_MaxSize
	where Pr_Atingimento > 60 and Dt_Log = @Last_Status

	--	Do we have Memory problem?	
	IF EXISTS (	SELECT null	FROM   #Log_Identity_MaxSize_Problem )		
	BEGIN	
		IF ISNULL(@Fl_Type, 0) = 0	-- Control Alert/Clear
		BEGIN
			IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
				DROP TABLE ##Email_HTML
						
			SELECT *
			INTO ##Email_HTML
			FROM    #Log_Identity_MaxSize_Problem				
			
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
			FROM   #Log_Identity_MaxSize_Problem		

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


USE [msdb]
GO

/****** Object:  Job [DBA - Identity MaxSize Load and Alert]    Script Date: 19/03/2020 18:25:05 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 19/03/2020 18:25:05 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Identity MaxSize Load and Alert', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA_Team_Operator', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Identity MaxSize]    Script Date: 19/03/2020 18:25:05 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Identity MaxSize', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec [stpLoad_Log_Identity_MaxSize]

exec [stpAlert_Identity_MaxSize]

', 
		@database_name=N'Traces', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Diario', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200319, 
		@active_end_date=99991231, 
		@active_start_time=70000, 
		@active_end_time=235959, 
		@schedule_uid=N'e7d6d3bb-4508-4a01-aa69-f89704eafb59'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO





