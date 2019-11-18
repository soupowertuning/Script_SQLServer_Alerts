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

--Enable
update [dbo].Alert_Parameter 
set Fl_Enable = 1
WHERE Nm_Alert = 'Index Fragmentation'

GO
if object_id('stpLoad_Index_Fragmentation') is not null
	drop procedure stpLoad_Index_Fragmentation
GO

CREATE procedure [dbo].[stpLoad_Index_Fragmentation]
AS
BEGIN
	SET NOCOUNT ON

	SET LOCK_TIMEOUT 300000 	 
	
	IF object_id('tempdb..##Index_Fragmentation_History_TEMP') IS NOT NULL DROP TABLE ##Index_Fragmentation_History_TEMP
	
	CREATE TABLE ##Index_Fragmentation_History_TEMP(
	--	[Id_Index_Fragmentation_History] [int] IDENTITY(1,1) NOT NULL,
		[Dt_Log] [datetime] NULL,
		[Nm_Server] VARCHAR(50) NULL,
		[Nm_Database] VARCHAR(100) NULL,
		[Nm_Table] VARCHAR(1000) NULL,
		[Nm_Index] [varchar](1000) NULL,
		[Nm_Schema] varchar(100),
		[avg_fragmentation_in_percent] [numeric](5, 2) NULL,
		[page_count] [int] NULL,
		[fill_factor] [tinyint] NULL,
		[Fl_Compression] [tinyint] NULL,
		[ObjectID] int,
		[indexid] int
	) ON [PRIMARY]

	IF object_id('tempdb..##Index_Fragmentation_History') IS NOT NULL DROP TABLE ##Index_Fragmentation_History
	
	CREATE TABLE ##Index_Fragmentation_History(
	--	[Id_Index_Fragmentation_History] [int] IDENTITY(1,1) NOT NULL,
		[Dt_Log] [datetime] NULL,
		[Nm_Server] VARCHAR(50) NULL,
		[Nm_Database] VARCHAR(100) NULL,
		[Nm_Table] VARCHAR(1000) NULL,
		[Nm_Index] [varchar](1000) NULL,
		Nm_Schema varchar(100),
		[Avg_Fragmentation_In_Percent] [numeric](5, 2) NULL,
		[Page_Count] [int] NULL,
		[Fill_Factor] [tinyint] NULL,
		[Fl_Compression] [tinyint] NULL	
	) ON [PRIMARY]

	
	EXEC sp_MSforeachdb '
	IF ''?'' IN (''tempdb'',''ReportServerTempDB'',''model'',''master'',''msdb'') 
		RETURN
	ELSE IF EXISTS (SELECT * FROM [dbo].[Ignore_Databases] WHERE Nm_Database = ''?'')
		RETURN

	Use [?]

	declare @Id_Database int 
	set @Id_Database = db_id()
	
	DECLARE @Table_ID INT

	IF (OBJECT_ID(''tempdb..#User_Tables'') IS NOT NULL)
		DROP TABLE #User_Tables

	SELECT  OBJECT_NAME(s.object_id) name,s.object_id
	INTO #User_Tables
	FROM    sys.dm_db_partition_stats s
	JOIN    sys.tables t
			ON s.object_id = t.object_id
	GROUP BY s.object_id
	having SUM(s.used_page_count) > 1000

	create clustered index SK01_#User_Tables  on #User_Tables(object_id)

	WHILE EXISTS ( SELECT TOP 1 object_id FROM #User_Tables )
	BEGIN
		-- Se passar de 6 da manha deve terminar a execução automaticamente
		IF( (SELECT DATEPART(HOUR, GETDATE())) >= 6 )
		BEGIN
			BREAK
		END

		SELECT TOP 1 @Table_ID = object_id
		FROM #User_Tables
		
		insert into ##Index_Fragmentation_History_TEMP
		select	getdate(), @@servername Nm_Server,  DB_NAME(db_id()) Nm_Database, '''' Nm_Table,  B.Name Nm_Index,
				'''' Nm_Schema, avg_fragmentation_in_percent, page_count,fill_factor, '''' data_compression	,A.object_id,A.index_id
		from sys.dm_db_index_physical_stats(@Id_Database, @Table_ID, null,null,null) A
		join sys.indexes B on A.object_id = B.object_id and A.index_id = B.index_id
		where page_count > 1000

		delete #User_Tables
		where object_id = @Table_ID
	END
	
	insert into ##Index_Fragmentation_History
	select	A.Dt_Log, A.Nm_Server,  A.Nm_Database, D.name , A.Nm_Index ,	F.name , A.avg_fragmentation_in_percent, A.page_count,A.fill_factor,data_compression
	from ##Index_Fragmentation_History_TEMP A
	JOIN sys.partitions C ON C.object_id = A.ObjectID AND C.index_id = A.indexid
	JOIN sys.sysobjects D ON A.ObjectID = D.id
	join sys.objects E on D.id = E.object_id
	join  sys.schemas F on E.schema_id = F.schema_id	
	 
	truncate table ##Index_Fragmentation_History_TEMP
	'
       
    INSERT INTO dbo.User_Server(Nm_Server)
	SELECT DISTINCT A.Nm_Server 
	FROM ##Index_Fragmentation_History A
		LEFT JOIN dbo.User_Server B ON A.Nm_Server = B.Nm_Server
	WHERE B.Nm_Server IS null
		
	INSERT INTO dbo.User_Database(Nm_Database)
	SELECT DISTINCT A.Nm_Database 
	FROM ##Index_Fragmentation_History A
		LEFT JOIN dbo.User_Database B ON A.Nm_Database = B.Nm_Database
	WHERE B.Nm_Database IS null
	
	INSERT INTO Traces.dbo.User_Table(Nm_Table)
	SELECT DISTINCT A.Nm_Table 
	FROM ##Index_Fragmentation_History A
		LEFT JOIN Traces.dbo.User_Table B ON A.Nm_Table = B.Nm_Table
	WHERE B.Nm_Table IS null	
	
    INSERT INTO dbo.Index_Fragmentation_History(Dt_Log,Id_Server,Id_Database,Id_Table,Nm_Index,Nm_Schema,Avg_Fragmentation_In_Percent,
			Page_Count,Fill_Factor,Fl_Compression)	
    SELECT A.Dt_Log,E.Id_Server, D.Id_Database,C.Id_Table,A.Nm_Index,A.Nm_Schema,A.Avg_Fragmentation_In_Percent,A.Page_Count,A.Fill_Factor,A.Fl_Compression 
    FROM ##Index_Fragmentation_History A 
    JOIN dbo.User_Table C ON A.Nm_Table = C.Nm_Table
	JOIN dbo.User_Database D ON A.Nm_Database = D.Nm_Database
	JOIN dbo.User_Server E ON A.Nm_Server = E.Nm_Server 
    LEFT JOIN Index_Fragmentation_History B ON E.Id_Server = B.Id_Server AND D.Id_Database = B.Id_Database  
    												AND C.Id_Table = B.Id_Table AND A.Nm_Index = B.Nm_Index 
    												AND CONVERT(VARCHAR, A.Dt_Log ,112) = CONVERT(VARCHAR, B.Dt_Log ,112)
	WHERE A.Nm_Index IS NOT NULL AND B.Id_Server IS NULL
    ORDER BY 2,3,4,5        			
end

GO


GO
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Load Index Fragmentation')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Load Index Fragmentation', @delete_unused_schedule=1
GO

GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 04/23/2014 20:20:47 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Load Index Fragmentation', 
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
/****** Object:  Step [DBA - Carga Fragmentacao Indices]    Script Date: 04/23/2014 20:20:47 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DBA - Load Index Fragmentation', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec stpLoad_Index_Fragmentation', 
		@database_name=N'Traces', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DBA - Index Fragmentation Load', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20140423, 
		@active_end_date=99991231, 
		@active_start_time=3000, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO
