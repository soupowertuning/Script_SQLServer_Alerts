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


--Habilita o alerta de Mirror
update [Alert_Parameter]
 set Fl_Enable = 1
 where Nm_Alert = 'Database Mirroring'


IF ( OBJECT_ID('[dbo].[Log_DB_Mirror]') IS NOT NULL )
		DROP TABLE [dbo].Log_DB_Mirror;

CREATE TABLE [dbo].[Log_DB_Mirror](
	[Id_Log_DB_Mirror] [int] IDENTITY(1,1) NOT NULL,
	Dt_Log datetime,
	[Database_Name] varchar(200) NOT NULL,
	[Mirroring_Role] [tinyint] NULL, -- 1 = Principal 2 = Espelhamento
	[Mirroring_State] [tinyint] NULL, --0 = Suspended  1 = Desconectado do outro parceiro 2 = Sincronização 3 = Failover pendente 4 = Sincronizado 5 = Os parceiros não estão sincronizados. Failover impossível no momento. 6 = Os parceiros estão sincronizados. Failover é potencialmente possível.
	Mirroring_Safety_Level tinyint, --0 = Estado desconhecido  1 = Desativado [assíncrono] 2 = Completo [síncrono]
	Mirroring_Partner_Instance varchar(100),	
	[Witness_Status] [tinyint] NULL,	--0 = Desconhecido 1 = conectado 2 = Desconectado	
 CONSTRAINT [PK_Log_DBMirror] PRIMARY KEY CLUSTERED 
(
	Id_Log_DB_Mirror ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
create nonclustered index SK01_Log_DB_Mirror on Log_DB_Mirror([Database_Name],[Id_Log_DB_Mirror]) with (DATA_COMPRESSION=PAGE,FILLFACTOR=90)
GO

IF ( OBJECT_ID('[dbo].[stpLoad_Mirror_Information]') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpLoad_Mirror_Information
GO
CREATE procedure stpLoad_Mirror_Information
AS
	insert into [Log_DB_Mirror]([Database_Name],Dt_Log, [Mirroring_Role], [Mirroring_State], [Mirroring_Safety_Level],  [Mirroring_Partner_Instance],[Witness_Status])
	SELECT					d.name,getdate(),m.mirroring_role,m.mirroring_state,m.mirroring_safety_level ,m.mirroring_partner_instance,m.mirroring_witness_state
    FROM    sys.databases d
              JOIN sys.database_mirroring m ON m.database_id = d.database_id
    WHERE   mirroring_role_desc IS NOT NULL
GO

IF ( OBJECT_ID('[dbo].[stpAlert_Status_DB_Mirror]') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_Status_DB_Mirror
GO
CREATE PROCEDURE [dbo].[stpAlert_Status_DB_Mirror] 
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Id_Alert_Parameter SMALLINT, @Fl_Enable BIT, @Fl_Type TINYINT, @Vl_Parameter SMALLINT,@Ds_Email VARCHAR(500),@Ds_Profile_Email VARCHAR(200),@Dt_Now DATETIME,@Vl_Parameter_2 INT,
		@Ds_Email_Information_1_ENG VARCHAR(200), @Ds_Email_Information_2_ENG VARCHAR(200), @Ds_Email_Information_1_PTB VARCHAR(200), @Ds_Email_Information_2_PTB VARCHAR(200),
		@Ds_Message_Alert_ENG varchar(1000),@Ds_Message_Clear_ENG varchar(1000),@Ds_Message_Alert_PTB varchar(1000),@Ds_Message_Clear_PTB varchar(1000), @Ds_Subject VARCHAR(500)
	
	DECLARE @Company_Link  VARCHAR(4000),@Line_Space VARCHAR(4000),@Header_Default VARCHAR(4000),@Header VARCHAR(4000),@Fl_Language BIT,@Final_HTML VARCHAR(MAX),@HTML VARCHAR(MAX)		
	
	declare @Ds_Alinhamento VARCHAR(10),@Ds_OrderBy VARCHAR(MAX) 	

	
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
	FROM [dbo].Alert_Parameter 
	WHERE Nm_Alert = 'Database Mirroring'


	IF @Fl_Enable = 0
		RETURN
		
	---- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	--SELECT @Fl_Type = [Fl_Type]
	--FROM [dbo].[Alert]
	--WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
	declare @Last_Row as table(Database_Name varchar(100),Id_Log_DB_Mirror int)
	
	insert into @Last_Row
	select A.Database_Name, max(A.[Id_Log_DB_Mirror]) [Id_Log_DB_Mirror]
	from [Log_DB_Mirror] A (nolock) 					
	group by A.Database_Name	
	
	declare @SecondToLast_Row as table(Database_Name varchar(100),Id_Log_DB_Mirror int)
	
	insert into @SecondToLast_Row
	select A.Database_Name, max(A.Id_Log_DB_Mirror) Id_Log_DB_Mirror
	from [Log_DB_Mirror] A (nolock) 	
		left join @Last_Row B on A.Id_Log_DB_Mirror = B.Id_Log_DB_Mirror
	where B.Id_Log_DB_Mirror is null		
	group by A.Database_Name	
			
	--	Do we have mirror problems?
	if exists (
		select null
		from (	select E.* 
				from [Log_DB_Mirror] E
				join @SecondToLast_Row F on E.Id_Log_DB_Mirror = F.Id_Log_DB_Mirror
				) A
			join (	select C.* 
					from [Log_DB_Mirror] C
						join @Last_Row D on C.Id_Log_DB_Mirror = D.Id_Log_DB_Mirror		) 
				B on A.Database_Name = B.Database_Name 			
		where	B.Dt_Log >= DATEADD(day,-1,getdate()) and
				(
					A.[Mirroring_Role] <> B.[Mirroring_Role] 
					or A.[Mirroring_State] <> B.[Mirroring_State] 
					or A.[Witness_Status] <> B.[Witness_Status] 
					or A.[Mirroring_Safety_Level] <> B.[Mirroring_Safety_Level]
				)

	)
	BEGIN	-- BEGIN - ALERT

		--IF ISNULL(@Fl_Type, 0) = 0	-- Control Alert/Clear
		--BEGIN
			IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
				DROP TABLE ##Email_HTML
							
				select B.Database_Name [Database Name],
							case B.[Mirroring_Role] when 1 then 'Principal' when 2 then 'Mirror' end [Mirroring Role],
						case B.[Mirroring_State] 
						when 0 then 'Suspended'
						when 1 then 'Disconnected'
						when 2 then 'Synchronizing'
						when 3 then 'Pending Failover'
						when 4 then 'Synchronized' end [Mirroring State],						
					case B.[Witness_Status] when 0 then 'UnKnown' when 1 then 'Connected' when 2 then 'Disconnecteed' end [Witness Status],
					convert(varchar,B.Dt_Log,20) [Log Time]
				into ##Email_HTML
				from (select C.* 
					from [Log_DB_Mirror] C
						join @Last_Row D on C.Id_Log_DB_Mirror = D.Id_Log_DB_Mirror)	B
				where B.Dt_Log >= DATEADD(day,-1,getdate()) 	
		      		
						 
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
				SET @Ds_Subject = @Ds_Message_Alert_ENG+@@SERVERNAME 
		   END		   		

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[Database Name]',
				@Ds_Saida = @HTML OUT				-- varchar(max)

			-- First Result
			SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space 	 + @Company_Link	
		
			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'								
		
			-- Fl_Type = 1 : ALERT	
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 1			
	END
END

GO
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Database Mirroring Load and Alert')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Database Mirroring Load and Alert', @delete_unused_schedule=1
GO
GO
USE [msdb]
GO

/****** Object:  Job [DBA - Database Mirroring Load and Alert]    Script Date: 9/2/2019 10:42:22 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 9/2/2019 10:42:22 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Database Mirroring Load and Alert', 
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
/****** Object:  Step [Call Procedures]    Script Date: 9/2/2019 10:42:22 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Call Procedures', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec stpLoad_Mirror_Information
exec stpAlert_Status_DB_Mirror', 
		@database_name=N'Traces', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Mirror Alert', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=2, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190902, 
		@active_end_date=99991231, 
		@active_start_time=47, 
		@active_end_time=235959, 
		@schedule_uid=N'40346f92-025d-43d0-8e43-e90e34264599'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


