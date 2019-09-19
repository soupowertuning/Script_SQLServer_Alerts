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

--Essa rotina é opcional. Caso não queira ligar um profile no servidor, não execute esses script. Você também pode usar um Extended EVENT se preferir.
--This script is optional. If you don't want to create a profile on your SQL Server, don't run this script. You can also use a Extended Event if you want.


----------- Steps to execute this script and create a Profile to monitor 3 seconds query

-- 1) Fazer um Replace(CTRL + H) no caminho "C:\Temp\teste" e alterar para um Caminho Real no servidor. Você precisa dar acesso ao usuário do SQL nessa pasta para criar e excluir arquivo, caso contrário o job de trace vai falhar.

-- 1) You need to do a replace the path "C:\Temp\teste" on this script to a path that exists on the server. You need to give access to the SQL User on this path to create and drop the trace file. Without this, the job will fail.


-- 2) Change for your Database Name and execute 

USE Traces -- Database Name

if OBJECT_ID('Queries_Profile') is not null
	drop table Queries_Profile
	
CREATE TABLE [dbo].[Queries_Profile](
	[TextData] varchar(max) NULL,
	[NTUserName] [varchar](128) NULL,
	[HostName] [varchar](128) NULL,
	[ApplicationName] [varchar](128) NULL,
	[LoginName] [varchar](128) NULL,
	[SPID] [int] NULL,
	[Duration] [numeric](15, 2) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[ServerName] [varchar](128) NULL,
	[Reads] bigint NULL,
	[Writes] bigint NULL,
	[CPU] bigint NULL,
	[DataBaseName] [varchar](128) NULL,
	[RowCounts] bigint NULL,
--	[SessionLoginName] [varchar](128) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]        

GO
	--enable the Slow Queries alert
	UPDATE Alert_Parameter 
	SET Fl_Enable = 1
    WHERE Nm_Alert = 'Slow Queries' 

GO

if OBJECT_ID('stpTrace_Creation') is not null
	drop procedure stpTrace_Creation
GO

CREATE  Procedure [dbo].[stpTrace_Creation]
AS
BEGIN
	DECLARE @Vl_Parameter SMALLINT

	-- Alert information
	SELECT @Vl_Parameter = Vl_Parameter		-- Minutes,

	FROM [Traces].[dbo].Alert_Parameter 
	WHERE Nm_Alert = 'Trace Creation'
	
	-- In case we have a problem with the @Vl_Parameter.
	IF(@Vl_Parameter IS NULL OR @Vl_Parameter < 0)
	BEGIN
		SELECT @Vl_Parameter = 3	-- Segundos
	END	

	-- Create a Queue.
	declare @rc int
	declare @TraceID int
	declare @maxfilesize bigint
	set @maxfilesize = 50

	/*******************************************************************************************************************************
	-- ATENTION!!! YOU NEED TO CHANGE THIS PATH
	*******************************************************************************************************************************/
	exec @rc = sp_trace_create @TraceID output, 0, N'C:\Temp\teste\Duration', @maxfilesize, NULL 

	if (@rc != 0) goto error

	-- Client side File and Table cannot be scripted.

	-- Set the events.
	declare @on bit
	set @on = 1

	-- 10 RPC:Completed Ocorre quando uma RPC (chamada de procedimento remoto) é concluída. 
	exec sp_trace_setevent @TraceID, 10, 1, @on		-- TextData: Valor de texto dependente da classe de evento capturada no rastreamento.
	exec sp_trace_setevent @TraceID, 10, 6, @on		-- NTUserName: Nome de usuário do Microsoft Windows. 
	exec sp_trace_setevent @TraceID, 10, 8, @on		-- HostName: Nome do computador cliente que originou a solicitação. 
	exec sp_trace_setevent @TraceID, 10, 10, @on	-- ApplicationName: Nome do aplicativo cliente que criou a conexão com uma instância do SQL Server.
													-- Essa coluna é populada com os valores passados pelo aplicativo e não com o nome exibido do programa.
	exec sp_trace_setevent @TraceID, 10, 11, @on	-- LoginName: Nome de logon do cliente no SQL Server.
	exec sp_trace_setevent @TraceID, 10, 12, @on	-- SPID: ID de processo de servidor atribuída pelo SQL Server ao processo associado ao cliente.
	exec sp_trace_setevent @TraceID, 10, 13, @on	-- Duration: Tempo decorrido (em milhões de segundos) utilizado pelo evento. 
													-- Esta coluna de dados não é populada pelo evento Hash Warning.
	exec sp_trace_setevent @TraceID, 10, 14, @on	-- StartTime: Horário de início do evento, quando disponível.
	exec sp_trace_setevent @TraceID, 10, 15, @on	-- EndTime: Horário em que o evento foi encerrado. Esta coluna não é populada para classes de evento
													-- iniciais, como SQL:BatchStarting ou SP:Starting. Também não é populada pelo evento Hash Warning.
	exec sp_trace_setevent @TraceID, 10, 16, @on	-- Reads: Número de leituras lógicas do disco executadas pelo servidor em nome do evento. 
													-- Esta coluna não é populada pelo evento Lock:Released.
	exec sp_trace_setevent @TraceID, 10, 17, @on	-- Writes: Número de gravações no disco físico executadas pelo servidor em nome do evento.
	exec sp_trace_setevent @TraceID, 10, 18, @on	-- CPU: Tempo da CPU (em milissegundos) usado pelo evento.
	exec sp_trace_setevent @TraceID, 10, 19, @on	-- CPU: Tempo da CPU (em milissegundos) usado pelo evento.
	exec sp_trace_setevent @TraceID, 10, 26, @on	-- ServerName: Nome da instância do SQL Server, servername ou servername\instancename, 
													-- que está sendo rastreada
	exec sp_trace_setevent @TraceID, 10, 35, @on	-- DatabaseName: Nome do banco de dados especificado na instrução USE banco de dados.
	exec sp_trace_setevent @TraceID, 10, 40, @on	-- DBUserName: Nome de usuário do banco de dados do SQL Server do cliente.
	exec sp_trace_setevent @TraceID, 10, 48, @on	-- RowCounts: Número de linhas no lote.
	--exec sp_trace_setevent @TraceID, 10, 64, @on	-- SessionLoginName: O nome de logon do usuário que originou a sessão. Por exemplo, se você 
	--												-- se conectar ao SQL Server usando Login1 e executar uma instrução como Login2, SessionLoginName
	--												-- irá exibir Login1, enquanto que LoginName exibirá Login2. Esta coluna de dados exibe logons
	--												-- tanto do SQL Server, quanto do Windows.

	exec sp_trace_setevent @TraceID, 12, 1,  @on	-- TextData: Valor de texto dependente da classe de evento capturada no rastreamento.
	exec sp_trace_setevent @TraceID, 12, 6,  @on	-- NTUserName: Nome de usuário do Microsoft Windows. 
	exec sp_trace_setevent @TraceID, 12, 8,  @on	-- HostName: Nome do computador cliente que originou a solicitação. 
	exec sp_trace_setevent @TraceID, 12, 10, @on	-- ApplicationName: Nome do aplicativo cliente que criou a conexão com uma instância do SQL Server. 
													-- Essa coluna é populada com os valores passados pelo aplicativo e não com o nome exibido do programa.
	exec sp_trace_setevent @TraceID, 12, 11, @on	-- LoginName: Nome de logon do cliente no SQL Server.
	exec sp_trace_setevent @TraceID, 12, 12, @on	-- SPID: ID de processo de servidor atribuída pelo SQL Server ao processo associado ao cliente.
	exec sp_trace_setevent @TraceID, 12, 13, @on	-- Duration: Tempo decorrido (em milhões de segundos) utilizado pelo evento. Esta coluna de dados não
													-- é populada pelo evento Hash Warning.
	exec sp_trace_setevent @TraceID, 12, 14, @on	-- StartTime: Horário de início do evento, quando disponível.
	exec sp_trace_setevent @TraceID, 12, 15, @on	-- EndTime: Horário em que o evento foi encerrado. Esta coluna não é populada para classes de evento
													-- iniciais, como SQL:BatchStarting ou SP:Starting. Também não é populada pelo evento Hash Warning.
	exec sp_trace_setevent @TraceID, 12, 16, @on	-- Reads: Número de leituras lógicas do disco executadas pelo servidor em nome do evento. 
													-- Esta coluna não é populada pelo evento Lock:Released.
	exec sp_trace_setevent @TraceID, 12, 17, @on	-- Writes: Número de gravações no disco físico executadas pelo servidor em nome do evento.
	exec sp_trace_setevent @TraceID, 12, 18, @on	-- CPU: Tempo da CPU (em milissegundos) usado pelo evento.
	exec sp_trace_setevent @TraceID, 12, 26, @on	-- ServerName: Nome da instância do SQL Server, servername ou servername\instancename, 
													-- que está sendo rastreada
	exec sp_trace_setevent @TraceID, 12, 35, @on	-- DatabaseName: Nome do banco de dados especificado na instrução USE banco de dados.
	exec sp_trace_setevent @TraceID, 12, 40, @on	-- DBUserName: Nome de usuário do banco de dados do SQL Server do cliente.
	exec sp_trace_setevent @TraceID, 12, 48, @on	-- RowCounts: Número de linhas no lote.
	--exec sp_trace_setevent @TraceID, 12, 64, @on	-- SessionLoginName: O nome de logon do usuário que originou a sessão. Por exemplo, se você se
	--												-- conectar ao SQL Server usando Login1 e executar uma instrução como Login2, SessionLoginName
	--												-- irá exibir Login1, enquanto que LoginName exibirá Login2. Esta coluna de dados exibe logons
	--												-- tanto do SQL Server, quanto do Windows.

	-- Set the Filters.
	declare @intfilter int
	declare @bigintfilter bigint

	exec sp_trace_setfilter @TraceID, 10, 0, 7, N'SQL Server Profiler - 4d8f4bca-f08c-4755-b90c-6ec17a6f1275'
	exec sp_trace_setfilter @TraceID, 10, 0, 7, N'DatabaseMail90%'

	set @bigintfilter = 1000000 * @Vl_Parameter		--  @Vl_Parameter (In Seconds)

	exec sp_trace_setfilter @TraceID, 13, 0, 4, @bigintfilter

	set @bigintfilter = null
	exec sp_trace_setfilter @TraceID, 13, 0, 1, @bigintfilter

	exec sp_trace_setfilter @TraceID, 1, 0, 7, N'NO STATS%'

	exec sp_trace_setfilter @TraceID, 1, 0, 7, N'NULL%'

	-- Set the trace status to start.
	exec sp_trace_setstatus @TraceID, 1

	-- Display trace id for future references.
	select TraceID = @TraceID

	goto finish

	error: 
		select ErrorCode = @rc

	finish: 
END

GO

if OBJECT_ID('stpLoad_Queries_Profile') is not null
	drop procedure stpLoad_Queries_Profile
GO

CREATE PROCEDURE stpLoad_Queries_Profile
AS
BEGIN
	Insert Into Queries_Profile(TextData, NTUserName, HostName, ApplicationName, LoginName, SPID, Duration, StartTime, 
	EndTime,  Reads, Writes, CPU, ServerName,DataBaseName, RowCounts/*,SessionLoginName*/)

	Select TextData,NTUserName, HostName, ApplicationName, LoginName, SPID, 
	cast(Duration /1000/1000.00 as numeric(15,2)) Duration, StartTime,
	EndTime, Reads,Writes, CPU, ServerName, DataBaseName, RowCounts/*, SessionLoginName*/
	FROM :: fn_trace_gettable('C:\Temp\teste\Duration.trc', default)
	where Duration is not null	
		and TextData not like '%stpLoad_SQL_Counter%' --you can ignore some query here
		and TextData not like '%stpAlert_Every_Minute%' --you can ignore some query here

	-- if exists an alert, run it.
	IF EXISTS (SELECT * FROM sys.objects WHERE name = 'Alert_Parameter')
		IF EXISTS (SELECT * FROM Alert_Parameter WHERE Nm_Alert = 'Slow Queries' AND Fl_Enable = 1)
			EXEC dbo.stpAlert_Slow_Queries
END

GO
USE [msdb]

GO

IF EXISTS ( SELECT job_id 
            FROM msdb.dbo.sysjobs_view 
            WHERE name = N'DBA - Load Server Side Trace')
	EXEC msdb.dbo.sp_delete_job @job_name = N'DBA - Load Server Side Trace', @delete_unused_schedule = 1

GO

BEGIN TRANSACTION
	DECLARE @ReturnCode INT
	SELECT @ReturnCode = 0
	IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name = N'Database Maintenance' AND category_class = 1)
	BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB', @type = N'LOCAL', @name = N'Database Maintenance'
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	END

	DECLARE @jobId BINARY(16)
	EXEC	@ReturnCode = msdb.dbo.sp_add_job 
			@job_name = N'DBA - Load Server Side Trace',
			@enabled = 1,
			@notify_level_eventlog = 0,
			@notify_level_email = 2,
			@notify_level_netsend = 0,
			@notify_level_page = 0,
			@delete_level = 0,
			@description = N'No description available.',
			@category_name = N'Database Maintenance',
			@owner_login_name = N'sa',
			@notify_email_operator_name=N'DBA_Operator',
			@job_id = @jobId OUTPUT
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
			@job_id = @jobId, 
			@step_name = N'DBA - Disable Trace',
			@step_id = 1,
			@cmdexec_success_code = 0,
			@on_success_action = 3,
			@on_success_step_id = 0,
			@on_fail_action = 3,
			@on_fail_step_id = 0,
			@retry_attempts = 0,
			@retry_interval = 0,
			@os_run_priority = 0,
			@subsystem = N'TSQL',
			@command = N'
			declare @Traceid int

			select @Traceid = traceid
			from fn_trace_getinfo (null)
			where cast(value as varchar(100)) like ''%Duration%''

			if @Traceid is not null
			begin
				exec sp_trace_setstatus  @Traceid ,  @status = 0
				exec sp_trace_setstatus  @Traceid ,  @status = 2
			end
			',
			@database_name = N'master',
			@flags = 0

	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback


	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
			@job_id = @jobId, 
			@step_name = N'Insert Values on Queries_Profile', 
			@step_id = 2, 
			@cmdexec_success_code = 0, 
			@on_success_action = 3, 
			@on_success_step_id = 0, 
			@on_fail_action = 3, 
			@on_fail_step_id = 0, 
			@retry_attempts = 0, 
			@retry_interval = 0, 
			@os_run_priority = 0, 
			@subsystem = N'TSQL', 
			@command = N'exec stpLoad_Queries_Profile', 
			@database_name = N'Traces', 
			@flags = 0

	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	------------------------------------------------------------------------------------------------------------------------------------
	-- Cria o Step 3 do JOB - Exclui o arquivo de trace antigo
	------------------------------------------------------------------------------------------------------------------------------------
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
			@job_id = @jobId, 
			@step_name = N'Delete Old Trace File', 
			@step_id = 3,
			@cmdexec_success_code = 0,
			@on_success_action = 3,
			@on_success_step_id = 0,
			@on_fail_action = 3,
			@on_fail_step_id = 0,
			@retry_attempts = 0,
			@retry_interval = 0,
			@os_run_priority = 0,
			@subsystem=N'CmdExec',
			@command = N'Del "C:\Temp\teste\Duration.trc" /Q',
			@flags = 0

	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback


	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
			@job_id = @jobId, 
			@step_name = N'Create Trace', 
			@step_id = 4, 
			@cmdexec_success_code = 0, 
			@on_success_action = 1, 
			@on_success_step_id = 0, 
			@on_fail_action = 2, 
			@on_fail_step_id = 0, 
			@retry_attempts = 0, 
			@retry_interval = 0, 
			@os_run_priority = 0, 
			@subsystem = N'TSQL', 
			@command = N'exec dbo.stpTrace_Creation', 
			@database_name = N'Traces', 
			@flags = 0

	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
		
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	declare @Dt_Atual varchar(8) = convert(varchar(8), getdate(), 112)


	------------------------------------------------------------------------------------------------------------------------------------	
	-- Cria o Schedule do JOB
	------------------------------------------------------------------------------------------------------------------------------------
	EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule 
			@job_id = @jobId, 
			@name = N'DBA - Database Trace', 
			@enabled = 1,
			@freq_type = 4,
			@freq_interval = 1,
			@freq_subday_type = 4,
			@freq_subday_interval = 5,
			@freq_relative_interval = 0,
			@freq_recurrence_factor = 0,
			@active_start_date = @Dt_Atual,
			@active_end_date = 99991231,
			@active_start_time = 10037,
			@active_end_time = 235959
		
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'

	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

COMMIT TRANSACTION

GOTO EndSave

QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION

EndSave:

GO

USE Traces

-- Create Trace
EXEC [dbo].[stpTrace_Creation]
