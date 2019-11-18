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
use Traces

/*
	GO
	SELECT  *
	FROM    sys.objects
	WHERE   type = 'U'; 

SELECT type_desc,COUNT(*)
FROM sys.all_objects
WHERE type IN (
    'P', -- stored procedures
    'FN', -- scalar functions 
    'IF', -- inline table-valued functions
    'TF', -- table-valued functions
	'U',
	'V'
)
AND is_ms_shipped = 0
GROUP BY type_desc
ORDER BY 2 desc



SELECT name, type
FROM sys.all_objects
WHERE type IN (
    'P', -- stored procedures
    'FN', -- scalar functions 
    'IF', -- inline table-valued functions
    'TF', -- table-valued functions
	'U',
	'V'
)
AND is_ms_shipped = 0
ORDER BY type, name
-- Objects created in this script
- 27 Procedures
- 40 Tables
- 2 Views
- 5 Jobs



Procedures:
stpCheckList_Alert
stpCheckList_AutoGrowth
stpCheckList_Backup_Executed
stpCheckList_Changed_Jobs
stpCheckList_Counters
stpCheckList_Database_Growth
stpCheckList_Database_Without_Backup
stpCheckList_Disk_Space
stpCheckList_File_Utilization
stpCheckList_Index_Fragmentation
stpCheckList_Jobs_Failed
stpCheckList_Jobs_Running
stpCheckList_MDF_LDF_Files
stpCheckList_Open_Connection
stpCheckList_Queries_Running
stpChecklist_Slow_Jobs
stpCheckList_SQLServer_ErrorLog
stpCheckList_Table_Growth
stpCheckList_Traces_Queries
stpCheckList_Waits_Stats
stpLoad_CheckList_Information
stpLoad_File_Utilization
stpLoad_SQL_Counter
stpLoad_Table_Size
stpLoad_Waits_Stats_History
stpSend_Mail_CheckList_DBA
stpWaits_Stats_History

Tables:
Checklist_Alert
Checklist_Alert_Sem_Clear
CheckList_Backup_Executed
CheckList_Changed_Jobs
CheckList_Conexao_Aberta
CheckList_Counters
CheckList_Counters_Email
CheckList_Data_Files
CheckList_Database_Auto_Growth
CheckList_Database_Growth
CheckList_Database_Growth_Email
CheckList_Database_Without_Backup
CheckList_Disk_Space
CheckList_File_Reads
CheckList_File_Writes
CheckList_Index_Fragmentation_History
CheckList_Jobs_Failed
CheckList_Jobs_Running
CheckList_Log_Files
CheckList_Opened_Connections_Email
CheckList_Parameter
CheckList_Queries_Running
CheckList_Slow_Jobs
CheckList_SQLServer_ErrorLog
CheckList_SQLServer_LoginFailed
CheckList_SQLServer_LoginFailed_Email
CheckList_Table_Growth
CheckList_Table_Growth_Email
CheckList_Traces_Queries
CheckList_Traces_Queries_LastDays
CheckList_Waits_Stats

Tables:
File_Utilization_History
Index_Fragmentation_History
Log_Counter
SQL_Counter
Table_Size_History
User_Database
User_Server
User_Table
Waits_Stats_History

Views:
vwIndex_Fragmentation_History
vwTable_Size

Jobs:
DBA - CheckList SQL Server Instance
DBA - Load SQL Server Files Performance
DBA - Load SQL Server Counters
DBA - Load Table Size
DBA - Wait Stats Load

*/

GO
IF ( OBJECT_ID('[dbo].[CheckList_Parameter]') IS NOT NULL )
	DROP TABLE [dbo].CheckList_Parameter;

CREATE TABLE CheckList_Parameter(
	Id_CheckList TINYINT IDENTITY,
	Nm_Procedure VARCHAR(100),
	Fl_Enabled BIT)

INSERT INTO CheckList_Parameter(Nm_Procedure,Fl_Enabled)
VALUES('stpCheckList_Disk_Space',1),
	('stpCheckList_MDF_LDF_Files',1),
	('stpCheckList_Database_Growth',1),
	('stpCheckList_Table_Growth',1),
	('stpCheckList_File_Utilization',1),
	('stpCheckList_Database_Without_Backup',1),
	('stpCheckList_Backup_Executed',1),
	('stpCheckList_Queries_Running',1),
	('stpCheckList_Changed_Jobs',1),
	('stpCheckList_Jobs_Failed',1),
	('stpChecklist_Slow_Jobs',1),
	('stpCheckList_Jobs_Running',1),
	('stpCheckList_Open_Connection',1),
	('stpCheckList_Profile_Queries',1),
	('stpCheckList_Counters',1),
	('stpCheckList_Index_Fragmentation',1),
	('stpCheckList_Waits_Stats',1),
	('stpCheckList_SQLServer_ErrorLog',1),
	('stpCheckList_Alert',1),
	('stpCheckList_AutoGrowth',1)

GO

IF (OBJECT_ID('[dbo].[CheckList_Disk_Space]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Disk_Space]

CREATE TABLE [dbo].[CheckList_Disk_Space] (
	[DriveName]			VARCHAR(256) NULL,
	[TotalSize_GB]		BIGINT NULL,
	[FreeSpace_GB]		BIGINT NULL,
	[SpaceUsed_GB]		BIGINT NULL,
	[SpaceUsed_Percent] DECIMAL(9, 3) NULL
)

IF (OBJECT_ID('[dbo].[CheckList_Data_Files]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Data_Files]

CREATE TABLE [dbo].[CheckList_Data_Files] (
	[Server]			VARCHAR(500),
	[Logical_Name]		VARCHAR(500),
	[Nm_Database]		VARCHAR(500),
	[FileName]			VARCHAR(500),
	[Total_Reserved]	NUMERIC(15,2),
	[Total_Used]	NUMERIC(15,2),
	[Free_Space (MB)] NUMERIC(15,2), 
	[Free_Space (%)]	NUMERIC(15,2), 
	[MaxSize]			INT,
	[Growth]			VARCHAR(25),
	[NextSize]			NUMERIC(15,2),
	[Fl_Status]		CHAR(1)
)

IF (OBJECT_ID('[dbo].[CheckList_Log_Files]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Log_Files]

CREATE TABLE [dbo].[CheckList_Log_Files] (
	[Server]			VARCHAR(500),
	[Nm_Database]		VARCHAR(500),
	[Logical_Name]		VARCHAR(500),
	[FileName]			VARCHAR(500),
	[Total_Reserved]	NUMERIC(15,2),
	[Total_Used]	NUMERIC(15,2),
	[Free_Space (MB)] NUMERIC(15,2), 
	[Free_Space (%)]	NUMERIC(15,2), 
	[MaxSize]			INT,
	[Growth]			VARCHAR(25),
	[NextSize]			NUMERIC(15,2),
	[Fl_Status]		CHAR(1)
)

IF (OBJECT_ID('[dbo].[CheckList_Database_Growth]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Database_Growth]
	
CREATE TABLE [dbo].[CheckList_Database_Growth] (
	[Nm_Server]	VARCHAR(50) NULL,
	[Nm_Database]	VARCHAR(100) NULL,
	[Actual_Size] NUMERIC(38, 2) NULL,
	[Growth_1_day]	NUMERIC(38, 2) NULL,
	[Growth_15_days]	NUMERIC(38, 2) NULL,
	[Growth_30_days]	NUMERIC(38, 2) NULL,
	[Growth_60_days]	NUMERIC(38, 2) NULL
)

IF (OBJECT_ID('[dbo].[CheckList_Database_Growth_Email]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Database_Growth_Email]
	
CREATE TABLE [dbo].[CheckList_Database_Growth_Email] (
	[Nm_Server]	VARCHAR(50) NULL,
	[Nm_Database]	VARCHAR(100) NULL,
	[Actual_Size] NUMERIC(38, 2) NULL,
	[Growth_1_day]	NUMERIC(38, 2) NULL,
	[Growth_15_days]	NUMERIC(38, 2) NULL,
	[Growth_30_days]	NUMERIC(38, 2) NULL,
	[Growth_60_days]	NUMERIC(38, 2) NULL
)

IF (OBJECT_ID('[dbo].[CheckList_Table_Growth]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Table_Growth]
	
CREATE TABLE [dbo].[CheckList_Table_Growth] (
	[Nm_Server]	VARCHAR(50) NULL,
	[Nm_Database]	VARCHAR(100) NULL,
	[Nm_Table]		VARCHAR(100) NULL,
	[Actual_Size] NUMERIC(38, 2) NULL,
	[Growth_1_day]	NUMERIC(38, 2) NULL,
	[Growth_15_days]	NUMERIC(38, 2) NULL,
	[Growth_30_days]	NUMERIC(38, 2) NULL,
	[Growth_60_days]	NUMERIC(38, 2) NULL
)

IF (OBJECT_ID('[dbo].[CheckList_Table_Growth_Email]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Table_Growth_Email]
	
CREATE TABLE [dbo].[CheckList_Table_Growth_Email] (
	[Nm_Server]	VARCHAR(50) NULL,
	[Nm_Database]	VARCHAR(100) NULL,
	[Nm_Table]		VARCHAR(100) NULL,
	[Actual_Size] NUMERIC(38, 2) NULL,
	[Growth_1_day]	NUMERIC(38, 2) NULL,
	[Growth_15_days]	NUMERIC(38, 2) NULL,
	[Growth_30_days]	NUMERIC(38, 2) NULL,
	[Growth_60_days]	NUMERIC(38, 2) NULL
)

IF (OBJECT_ID('[dbo].[CheckList_File_Writes]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_File_Writes]

CREATE TABLE [dbo].[CheckList_File_Writes](
	[Nm_Database] [nvarchar](200) NOT NULL,
	[file_id] [smallint] NULL,	
	[io_stall_write_ms] [bigint] NULL,
	[num_of_writes] [bigint] NULL,
	[avg_write_stall_ms] [numeric](15, 1) NULL
) ON [PRIMARY]

IF (OBJECT_ID('[dbo].[CheckList_File_Reads]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_File_Reads]

CREATE TABLE [dbo].[CheckList_File_Reads](
	[Nm_Database] [nvarchar](200) NOT NULL,
	[file_id] [smallint] NULL,
	[io_stall_read_ms] [bigint] NULL,
	[num_of_reads] [bigint] NULL,
	[avg_read_stall_ms] [numeric](15, 1) NULL
) ON [PRIMARY]

IF (OBJECT_ID('[dbo].[CheckList_Database_Without_Backup]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Database_Without_Backup]
	
CREATE TABLE [dbo].[CheckList_Database_Without_Backup] (
	[Nm_Database] VARCHAR(100) NOT NULL	
)

IF (OBJECT_ID('[dbo].[CheckList_Backup_Executed]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Backup_Executed]
	
CREATE TABLE [dbo].[CheckList_Backup_Executed] (
	[Database_Name]			VARCHAR(128) NULL,
	[Name]					VARCHAR(128) NULL,
	[Backup_Start_Date]		DATETIME NULL,
	[Tempo_Min]				INT NULL,
	[Position]				INT NULL,
	[Server_Name]			VARCHAR(128) NULL,
	[Recovery_Model]		VARCHAR(60) NULL,
	[Logical_Device_Name]	VARCHAR(128) NULL,
	[Device_Type]			TINYINT NULL,
	[Type]					CHAR(1) NULL,
	[Tamanho_MB]			NUMERIC(15, 2) NULL
)

IF ( OBJECT_ID('[dbo].[CheckList_Queries_Running]') IS NOT NULL )
	DROP TABLE [dbo].[CheckList_Queries_Running]
				
CREATE TABLE [dbo].[CheckList_Queries_Running] (		
	[dd hh:mm:ss.mss]		VARCHAR(20),
	[database_name]			NVARCHAR(128),		
	[login_name]			NVARCHAR(128),
	[host_name]				NVARCHAR(128),
	[start_time]			DATETIME,
	[status]				VARCHAR(30),
	[session_id]			INT,
	[blocking_session_id]	INT,
	[wait_info]				VARCHAR(MAX),
	[open_tran_count]		INT,
	[CPU]					VARCHAR(MAX),
	[reads]					VARCHAR(MAX),
	[CPU_delta]					VARCHAR(MAX),
	[reads_delta]					VARCHAR(MAX),
	[writes]				VARCHAR(MAX),
	[sql_command]			VARCHAR(MAX)
)

IF (OBJECT_ID('[dbo].[CheckList_Jobs_Failed]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Jobs_Failed]
	
CREATE TABLE [dbo].[CheckList_Jobs_Failed] (
	[Server]		VARCHAR(500),
	[Job_Name]		VARCHAR(500),
	[Status]		VARCHAR(25),
	[Dt_Execution]	VARCHAR(20),
	[Run_Duration]	VARCHAR(8),
	[SQL_Message]	VARCHAR(4490)
)

IF (OBJECT_ID('[dbo].[CheckList_Changed_Jobs]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Changed_Jobs]

CREATE TABLE [dbo].[CheckList_Changed_Jobs] (
	[Nm_Job]			VARCHAR(1000),
	[Fl_Enabled]		TINYINT,
	[Dt_Creation]		DATETIME,
	[Dt_Alteration]	DATETIME,
	[Nr_Version]		INT
)

IF (OBJECT_ID('[dbo].[CheckList_Slow_Jobs]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Slow_Jobs]

CREATE TABLE [dbo].[CheckList_Slow_Jobs] (
	[Job_Name]		VARCHAR(255) NULL,
	[Status]		VARCHAR(19) NULL,
	[Dt_Execution]	VARCHAR(30) NULL,
	[Run_Duration]	VARCHAR(8) NULL,
	[SQL_Message]	VARCHAR(3990) NULL
) 

IF (OBJECT_ID('[dbo].[CheckList_Jobs_Running]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Jobs_Running]
	
CREATE TABLE [dbo].[CheckList_Jobs_Running](
	[Nm_JOB] [varchar](256) NULL,
	[Dt_Start] [varchar](16) NULL,
	[Duration] [varchar](60) NULL,
	[Nm_Step] [varchar](256) NULL
) ON [PRIMARY]
	
IF (OBJECT_ID('[dbo].[CheckList_Profile_Queries]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Profile_Queries]
	
CREATE TABLE [dbo].[CheckList_Profile_Queries] (
	[PrefixoQuery]	VARCHAR(400),
	[QTD]			INT,
	[Total]			NUMERIC(15,2),
	[AVG]			NUMERIC(15,2),
	[MIN]			NUMERIC(15,2),
	[MAX]			NUMERIC(15,2),
	[Writes]		BIGINT,
	[CPU]			BIGINT,
	[Reads]			BIGINT,
	[Ordem]			TINYINT
)

IF (OBJECT_ID('[dbo].[CheckList_Profile_Queries_LastDays]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Profile_Queries_LastDays]
	
CREATE TABLE [dbo].[CheckList_Profile_Queries_LastDays] (
	[Date]	VARCHAR(50),
	[QTD]	INT
)

IF (OBJECT_ID('[dbo].[CheckList_Conexao_Aberta]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Conexao_Aberta]

CREATE TABLE [dbo].[CheckList_Conexao_Aberta](
	[login_name] [nvarchar](256) NULL,
	[session_count] [int] NULL
) ON [PRIMARY]

IF (OBJECT_ID('[dbo].[CheckList_Opened_Connections_Email]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Opened_Connections_Email]

CREATE TABLE [dbo].[CheckList_Opened_Connections_Email](
	[Nr_Order] INT NULL,
	[login_name] [nvarchar](256) NULL,
	[session_count] [int] NULL
) ON [PRIMARY]

IF (OBJECT_ID('[dbo].[CheckList_Counters]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Counters]
	
CREATE TABLE [dbo].[CheckList_Counters] (
	[Hour]			TINYINT,
	[Nm_Counter]	VARCHAR(60),
	[AVG]			BIGINT
)

IF (OBJECT_ID('[dbo].[CheckList_Counters_Email]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Counters_Email]

CREATE TABLE [dbo].[CheckList_Counters_Email](
	[Hour] [varchar](30) NOT NULL,
	[BatchRequests] [varchar](30) NOT NULL,
	[CPU] [varchar](30) NOT NULL,
	[Page_Life_Expectancy] [varchar](30) NOT NULL,
	[SQL_Compilations] [varchar](30) NOT NULL,
	[User_Connection] [varchar](30) NOT NULL,
	[Qtd_Queries_Lentas] [varchar](30) NOT NULL,
	[Reads_Queries_Lentas] [varchar](30) NOT NULL,
	[Page Splits/sec] [varchar](30) NOT NULL
)

IF (OBJECT_ID('[dbo].CheckList_Index_Fragmentation_History') IS NOT NULL)
	DROP TABLE [dbo].CheckList_Index_Fragmentation_History
	
CREATE TABLE [dbo].CheckList_Index_Fragmentation_History (
	[Dt_Log]					DATETIME NULL,
	[Nm_Server]					VARCHAR(100) NULL,
	[Nm_Database]					VARCHAR(1000) NULL,
	[Nm_Table]						VARCHAR(1000) NULL,
	[Nm_Index]						VARCHAR(1000) NULL,
	[Avg_Fragmentation_In_Percent]	NUMERIC(5, 2) NULL,
	[Page_Count]					INT NULL,
	[Fill_Factor]					TINYINT NULL,
	[Fl_Compression]					TINYINT NULL
)

IF (OBJECT_ID('[dbo].[CheckList_Waits_Stats]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Waits_Stats]
	
CREATE TABLE [dbo].[CheckList_Waits_Stats] (
	[WaitType]			VARCHAR(100),
	[Min_Log]			DATETIME,
	[Max_Log]			DATETIME,
	[DIf_Wait_S]		DECIMAL(14, 2),
	[DIf_Resource_S]	DECIMAL(14, 2),
	[DIf_Signal_S]		DECIMAL(14, 2),
	[DIf_WaitCount]		BIGINT,
	[DIf_Percentage]	DECIMAL(4, 2),
	[Last_Percentage]	DECIMAL(4, 2)
)

IF (OBJECT_ID('[dbo].[CheckList_SQLServer_LoginFailed]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_SQLServer_LoginFailed]
	
CREATE TABLE [dbo].[CheckList_SQLServer_LoginFailed] (	
	[Text]		VARCHAR(MAX),
	[Qt_Error]	INT
)

IF (OBJECT_ID('[dbo].[CheckList_SQLServer_LoginFailed_Email]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_SQLServer_LoginFailed_Email]
	
CREATE TABLE [dbo].[CheckList_SQLServer_LoginFailed_Email] (
	[Nr_Order]	INT,
	[Text]		VARCHAR(MAX),
	[Qt_Error]	INT
)

IF (OBJECT_ID('[dbo].[CheckList_SQLServer_ErrorLog]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_SQLServer_ErrorLog]
	
CREATE TABLE [dbo].[CheckList_SQLServer_ErrorLog] (
	[Dt_Log]		DATETIME,
	[ProcessInfo]	VARCHAR(100),
	[Text]			VARCHAR(MAX)
)

IF (OBJECT_ID('[dbo].[CheckList_Database_Auto_Growth]') IS NOT NULL)
	DROP TABLE [dbo].[CheckList_Database_Auto_Growth]

CREATE TABLE [dbo].[CheckList_Database_Auto_Growth](
	[Nm_Database]			VARCHAR(50),
	[Filename]				VARCHAR(60),
	[Duration]				INT,
	[StartTime]				DATETIME,
	[EndTime]				DATETIME,
	[Growth_Size]			DECIMAL (9,2),
	[ApplicationName]		VARCHAR(300),
	[HostName]				VARCHAR(100),
	[LoginName]				VARCHAR(100)
)

GO

use Traces


if object_id('vwIndex_Fragmentation_History') is not null
	drop View vwIndex_Fragmentation_History

GO
create view vwIndex_Fragmentation_History
AS
select A.Dt_Log, B.Nm_Server, C.Nm_Database,D.Nm_Table ,A.Nm_Index, A.Nm_Schema, 
	A.Avg_Fragmentation_In_Percent, A.Page_Count, A.Fill_Factor, A.Fl_Compression
from Index_Fragmentation_History A
	join User_Server B on A.Id_Server = B.Id_Server
	join User_Database C on A.Id_Database = C.Id_Database
	join User_Table D on A.Id_Table = D.Id_Table
GO



IF (OBJECT_ID('[dbo].[stpCheckList_Disk_Space]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Disk_Space]
GO

GO

CREATE PROCEDURE [dbo].[stpCheckList_Disk_Space]
AS
BEGIN
	SET NOCOUNT ON 

	TRUNCATE TABLE [dbo].[CheckList_Disk_Space]

	IF NOT EXISTS (SELECT Fl_Enabled FROM CheckList_Parameter WHERE Nm_Procedure = 'stpCheckList_Disk_Space' AND Fl_Enabled = 1)
	BEGIN
		RETURN
	END
	

	DECLARE @Ole_Automation sql_variant
	SELECT @Ole_Automation = value_in_use
	FROM sys.configurations
	WHERE name = 'Ole Automation Procedures' 
	
	IF ( OBJECT_ID('tempdb..#diskspace') IS NOT NULL )
		DROP TABLE #diskspace

	CREATE TABLE [#diskspace] (
		[Drive]				VARCHAR (10),
		[Size (MB)]		INT,
		[Used (MB)]		INT,
		[Free (MB)]		INT,
		[Free (%)]			INT,
		[Used (%)]			INT,
		[Used SQL (MB)]	INT, 
		[Date]				SMALLDATETIME
	)

	IF ( OBJECT_ID('tempdb..#Database_Driver_Letters') IS NOT NULL )
		DROP TABLE #Database_Driver_Letters

	CREATE TABLE [dbo].#Database_Driver_Letters(
		[Disk] [VARCHAR](256) NULL,
		[Total Size in GB] [DECIMAL](15, 2) NULL,
		[Used Size in GB] [DECIMAL](15, 2) NULL,
		[Available Size in GB] [DECIMAL](15, 2) NULL,
		[Space Free %] [DECIMAL](15, 2) NULL ,
		[Space Used %] [DECIMAL](15, 2) NULL ) 

	IF @Ole_Automation = 1	
	BEGIN    

		IF ( OBJECT_ID('tempdb..#dbspace') IS NOT NULL )
			DROP TABLE #dbspace
		
		CREATE TABLE #dbspace (
			[name]		SYSNAME,
			[Path]	VARCHAR(200),
			[Size]	VARCHAR(10),
			[drive]		VARCHAR(30)
		)
		
		IF ( OBJECT_ID('tempdb..#space') IS NOT NULL ) 
			DROP TABLE #space 

		CREATE TABLE #space (
			[drive]		CHAR(1),
			[mbfree]	INT
		)
		EXEC sp_MSforeachdb 'Use [?] INSERT INTO #dbspace SELECT CONVERT(VARCHAR(25), DB_Name()) ''Database'', CONVERT(VARCHAR(60), FileName), CONVERT(VARCHAR(8), Size / 128) ''Size in MB'', CONVERT(VARCHAR(30), Name) FROM sysfiles'

		DECLARE @hr INT, @fso INT, @mbtotal INT, @TotalSpace INT, @MBFree INT, @Percentage INT,
				@SQLDriveSize INT, @size float, @drive VARCHAR(1), @fso_Method VARCHAR(255)

		SELECT	@mbtotal = 0, 
				@mbtotal = 0
			
		EXEC @hr = [master].[dbo].[sp_OACreate] 'Scripting.FilesystemObject', @fso OUTPUT
		
		INSERT INTO #space 
		EXEC [master].[dbo].[xp_fixeddrives]	

		DECLARE CheckDrives CURSOR FOR SELECT drive,mbfree FROM #space
		OPEN CheckDrives
		FETCH NEXT FROM CheckDrives INTO @drive, @MBFree
		WHILE(@@FETCH_STATUS = 0)
		BEGIN
			SET @fso_Method = 'Drives("' + @drive + ':").TotalSize'
		
			SELECT @SQLDriveSize = SUM(CONVERT(INT, [Size])) 
			FROM #dbspace 
			WHERE SUBSTRING([Path], 1, 1) = @drive
		
			EXEC @hr = [sp_OAMethod] @fso, @fso_Method, @size OUTPUT
		
			SET @mbtotal =  @size / (1024 * 1024)
		
			INSERT INTO #diskspace 
			VALUES(	@drive + ':', @mbtotal, @mbtotal - @MBFree, @MBFree, (100 * ROUND(@MBFree, 2) / ROUND(@mbtotal, 2)), 
					(100 - 100 * ROUND(@MBFree, 2) / ROUND(@mbtotal, 2)), @SQLDriveSize, GETDATE())

			FETCH NEXT FROM CheckDrives INTO @drive,@MBFree
		END
		CLOSE CheckDrives
		DEALLOCATE CheckDrives
	END
	ELSE
		BEGIN
			INSERT INTO #Database_Driver_Letters
			SELECT DISTINCT 
					volume_mount_point , 
				--	file_system_type [File System Type], 
				--	logical_volume_name as [Logical Drive Name], 
					CONVERT(DECIMAL(18,2),total_bytes/1073741824.0) AS [Total Size in GB], ---1GB = 1073741824 bytes
					(CONVERT(DECIMAL(18,2),total_bytes/1073741824.0) - CONVERT(DECIMAL(18,2),available_bytes/1073741824.0) ) AS [Used Size in GB],
					CONVERT(DECIMAL(18,2),available_bytes/1073741824.0) AS [Available Size in GB], 
					CAST(CAST(available_bytes AS FLOAT)/ CAST(total_bytes AS FLOAT) AS DECIMAL(18,2)) * 100 AS [Space Free %] ,
					100-(CAST(CAST(available_bytes AS FLOAT)/ CAST(total_bytes AS FLOAT) AS DECIMAL(18,2)) * 100) AS [Space Used %] 		
			FROM sys.master_files 
			CROSS APPLY sys.dm_os_volume_stats(database_id, file_id)

		END
	
	
	
	INSERT INTO [dbo].[CheckList_Disk_Space]( [DriveName], [TotalSize_GB], [FreeSpace_GB], [SpaceUsed_GB], [SpaceUsed_Percent] )
	SELECT [Drive], [Size (MB)]/1024.00, [Free (MB)]/1024.00, [Used (MB)]/1024.00, [Used (%)] 
	FROM #diskspace
	UNION ALL
	SELECT Disk,[Total Size in GB],[Available Size in GB],[Used Size in GB],[Space Used %]
	FROM #Database_Driver_Letters


	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Disk_Space]( [DriveName], [TotalSize_GB], [FreeSpace_GB], [SpaceUsed_GB], [SpaceUsed_Percent] )
		SELECT 'Without information.', NULL, NULL, NULL, NULL
	END
END



GO
IF (OBJECT_ID('[dbo].[stpCheckList_MDF_LDF_Files]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_MDF_LDF_Files]
GO

CREATE PROCEDURE [dbo].[stpCheckList_MDF_LDF_Files]
AS
BEGIN
	SET NOCOUNT ON

	TRUNCATE TABLE [dbo].[CheckList_Data_Files]
	TRUNCATE TABLE [dbo].[CheckList_Log_Files]

	IF NOT EXISTS (SELECT Fl_Enabled FROM CheckList_Parameter WHERE Nm_Procedure = 'stpCheckList_MDF_LDF_Files' AND Fl_Enabled = 1)
	BEGIN
		RETURN
	END

	IF (OBJECT_ID('tempdb..##Alert_MDFs_Sizes') IS NOT NULL)
		DROP TABLE ##Alert_MDFs_Sizes

	CREATE TABLE ##Alert_MDFs_Sizes (
		[Server]			VARCHAR(500),
		[Nm_Database]		VARCHAR(500),
		[Logical_Name]		VARCHAR(500),
		[Size]				NUMERIC(15,2),
		[Total_Used]	NUMERIC(15,2),
		[Free_Space (MB)] NUMERIC(15,2),
		[Percent_Free] NUMERIC(15,2)
	)

	EXEC sp_MSforeachdb '
		Use [?]

			;WITH cte_datafiles AS 
			(
			  SELECT name, size = size/128.0 FROM sys.database_files
			),
			cte_datainfo AS
			(
			  SELECT	name, CAST(size as numeric(15,2)) as size, 
						CAST( (CONVERT(INT,FILEPROPERTY(name,''SpaceUsed''))/128.0) as numeric(15,2)) as used, 
						free = CAST( (size - (CONVERT(INT,FILEPROPERTY(name,''SpaceUsed''))/128.0)) as numeric(15,2))
			  FROM cte_datafiles
			)

			INSERT INTO ##Alert_MDFs_Sizes
			SELECT	@@SERVERNAME, DB_NAME(), name as [Logical_Name], size, used, free,
					percent_free = case when size <> 0 then cast((free * 100.0 / size) as numeric(15,2)) else 0 end
			FROM cte_datainfo	
	'	

	
	INSERT INTO [dbo].[CheckList_Data_Files] (	[Server], [Nm_Database], [Logical_Name], [FileName], [Total_Reserved], [Total_Used], 
													[Free_Space (MB)], [Free_Space (%)], [MaxSize], [Growth] )
	SELECT	@@SERVERNAME AS [Server],
			DB_NAME(A.database_id) AS [Nm_Database],
			[name] AS [Logical_Name],
			A.[physical_name] AS [Filename],
			B.[Size] AS [Total_Reserved],
			B.[Total_Used],
			B.[Free_Space (MB)] AS [Free_Space (MB)],
			B.[Percent_Free] AS [Free_Space (%)],
			CASE WHEN A.[Max_Size] = -1 THEN -1 ELSE (A.[Max_Size] / 1024) * 8 END AS [MaxSize(MB)], 
			CASE WHEN [is_percent_growth] = 1 
				THEN CAST(A.[Growth] AS VARCHAR) + ' %'
				ELSE CAST(CAST((A.[Growth] * 8 ) / 1024.00 AS NUMERIC(15, 2)) AS VARCHAR) + ' MB'
			END AS [Growth]
	FROM [sys].[master_files] A WITH(NOLOCK)	
		JOIN ##Alert_MDFs_Sizes B ON DB_NAME(A.[database_id]) = B.[Nm_Database] and A.[name] = B.[Logical_Name]
	WHERE	A.[type_desc] <> 'FULLTEXT'
			and A.type = 0	

	IF ( @@ROWCOUNT = 0 )
	BEGIN
		INSERT INTO [dbo].[CheckList_Data_Files] (	[Server], [Nm_Database], [Logical_Name], [FileName], [Total_Reserved], [Total_Used], 
														[Free_Space (MB)], [Free_Space (%)], [MaxSize], [Growth], [NextSize], [Fl_Status] )
		SELECT	NULL, 'Without information', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
	END

	INSERT INTO [dbo].[CheckList_Log_Files] (	[Server], [Nm_Database], [Logical_Name], [FileName], [Total_Reserved], [Total_Used], 
													[Free_Space (MB)], [Free_Space (%)], [MaxSize], [Growth] )
	SELECT	@@SERVERNAME AS [Server],
			DB_NAME(A.database_id) AS [Nm_Database],
			[name] AS [Logical_Name],
			A.[physical_name] AS [Filename],
			B.[Size] AS [Total_Reserved],
			B.[Total_Used],
			B.[Free_Space (MB)] AS [Free_Space (MB)],
			B.[Percent_Free] AS [Free_Space (%)],
			CASE WHEN A.[Max_Size] = -1 THEN -1 ELSE (A.[Max_Size] / 1024) * 8 END AS [MaxSize(MB)], 
			CASE WHEN [is_percent_growth] = 1 
				THEN CAST(A.[Growth] AS VARCHAR) + ' %'
				ELSE CAST(CAST((A.[Growth] * 8 ) / 1024.00 AS NUMERIC(15, 2)) AS VARCHAR) + ' MB'
			END AS [Growth]
	FROM [sys].[master_files] A WITH(NOLOCK)	
		JOIN ##Alert_MDFs_Sizes B ON DB_NAME(A.[database_id]) = B.[Nm_Database] and A.[name] = B.[Logical_Name]
	WHERE	A.[type_desc] <> 'FULLTEXT'
			and A.type = 1	
	
	IF ( @@ROWCOUNT = 0 )
	BEGIN
		INSERT INTO [dbo].[CheckList_Log_Files] (	[Server], [Nm_Database], [Logical_Name], [FileName], [Total_Reserved], [Total_Used], 
														[Free_Space (MB)], [Free_Space (%)], [MaxSize], [Growth], [NextSize], [Fl_Status] )
		SELECT	NULL, 'Without information', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
	END
END

GO

if object_id('vwTable_Size') is not null
	drop view vwTable_Size
GO

CREATE VIEW [dbo].[vwTable_Size]
AS

select	A.Dt_Log, B.Nm_Server, C.Nm_Database,D.Nm_Table ,A.Nm_Drive, 
		A.Nr_Total_Size, A.Nr_Data_Size, A.Nr_Index_Size, A.Qt_Rows
from Table_Size_History A
	join User_Server B on A.Id_Server = B.Id_Server
	join User_Database C on A.Id_Database = C.Id_Database
	join User_Table D on A.Id_Table = D.Id_Table

GO
if object_id('stpLoad_Table_Size') is not null
	drop procedure stpLoad_Table_Size
GO
CREATE proc [dbo].[stpLoad_Table_Size]
AS
BEGIN
	declare @Databases table(Id_Database int identity(1,1), Nm_Database varchar(256))

	declare @Total int, @i int, @Database varchar(256), @cmd varchar(8000);
	
	insert into @Databases(Nm_Database)
	select name
	from sys.databases
	where	name not in ('master','model','tempdb') 
			and state_desc = 'online'
						
	select @Total = max(Id_Database)
	from @Databases

	set @i = 1

	if object_id('tempdb..##Table_Size') is not null 
		drop table ##Table_Size
				
	CREATE TABLE ##Table_Size(
		[Nm_Server] VARCHAR(256),
		[Nm_Database] varchar(256),
		[Nm_Schema] [varchar](8000) NULL,
		[Nm_Table] [varchar](8000) NULL,
		[Nm_Index] [varchar](8000) NULL,
		[Nm_Drive] CHAR(1),
		[Used_in_kb] [bigint] NULL,
		[Reserved_in_kb] [bigint] NULL,
		[Tbl_Rows] [bigint] NULL,
		[Type_Desc] [varchar](50) NULL
	) ON [PRIMARY]

	while (@i <= @Total)
	begin
		IF EXISTS (SELECT NULL from @Databases  where Id_Database = @i) 
		BEGIN
			select @Database = Nm_Database
			from @Databases
			where Id_Database = @i
						
			set @cmd = '
				insert into ##Table_Size
				select	@@SERVERNAME,					
						''' + @Database + ''' Nm_Database, t.schema_name, t.table_Name, t.Index_name,
						(
							SELECT SUBSTRING(filename,1,1) 
							FROM ' + QUOTENAME(@Database) + '.sys.sysfiles 
							WHERE fileid = 1
						),
						sum(t.used) as used_in_kb,
						sum(t.reserved) as Reserved_in_kb,
						--case grouping (t.Index_name) when 0 then sum(t.ind_rows) else sum(t.tbl_rows) end as rows,
						max(t.tbl_rows) as rows,
						type_Desc
				from	(
							select	s.name as schema_name, 
									o.name as table_Name,
									coalesce(i.name,''heap'') as Index_name,
									p.used_page_Count*8 as used,
									p.reserved_page_count*8 as reserved, 
									p.row_count as ind_rows,
									(case when i.index_id in (0,1) then p.row_count else 0 end) as tbl_rows, 
									i.type_Desc as type_Desc
							from
								' + QUOTENAME(@Database) + '.sys.dm_db_partition_stats p
								join ' + QUOTENAME(@Database) + '.sys.objects o on o.object_id = p.object_id
								join ' + QUOTENAME(@Database) + '.sys.schemas s on s.schema_id = o.schema_id
								left join ' + QUOTENAME(@Database) + '.sys.indexes i on i.object_id = p.object_id and i.index_id = p.index_id
							where o.type_desc = ''user_Table'' and o.is_Ms_shipped = 0
						) as t
				group by t.schema_name, t.table_Name,t.Index_name,type_Desc
				--with rollup -- no sql server 2005, essa linha deve ser habilitada **********************************************
				--order by grouping(t.schema_name),t.schema_name,grouping(t.table_Name),t.table_Name,	grouping(t.Index_name),t.Index_name
				'

			EXEC(@cmd);
	
		END
		
		set @i = @i + 1
	end 

	INSERT INTO dbo.User_Server(Nm_Server)
	SELECT DISTINCT A.Nm_Server 
	FROM ##Table_Size A
		LEFT JOIN dbo.User_Server B ON A.Nm_Server = B.Nm_Server
	WHERE B.Nm_Server IS null
		
	INSERT INTO dbo.User_Database(Nm_Database)
	SELECT DISTINCT A.Nm_Database 
	FROM ##Table_Size A
		LEFT JOIN dbo.User_Database B ON A.Nm_Database = B.Nm_Database
	WHERE B.Nm_Database IS null
	
	INSERT INTO dbo.User_Table(Nm_Table)
	SELECT DISTINCT A.Nm_Table 
	FROM ##Table_Size A
		LEFT JOIN dbo.User_Table B ON A.Nm_Table = B.Nm_Table
	WHERE B.Nm_Table IS null	

	insert into dbo.Table_Size_History(Id_Server, Id_Database, Id_Table, Nm_Drive, 
				Nr_Total_Size, Nr_Data_Size, Nr_Index_Size, Qt_Rows, Dt_Log)
	select	B.Id_Server, D.Id_Database, C.Id_Table ,UPPER(A.Nm_Drive),
			sum(Reserved_in_kb)/1024.00 [Reservado (KB)], 
			sum(case when Type_Desc in ('CLUSTERED', 'HEAP') then Reserved_in_kb else 0 end)/1024.00 [Dados (KB)], 
			sum(case when Type_Desc in ('NONCLUSTERED') then Reserved_in_kb else 0 end)/1024.00 [Indices (KB)],
			max(Tbl_Rows) Qtd_Linhas,
			CONVERT(VARCHAR, GETDATE(), 112)						 
	from ##Table_Size A
		JOIN dbo.User_Server B ON A.Nm_Server = B.Nm_Server 
		JOIN dbo.User_Table C ON A.Nm_Table = C.Nm_Table
		JOIN dbo.User_Database D ON A.Nm_Database = D.Nm_Database
		LEFT JOIN dbo.Table_Size_History E ON	B.Id_Server = E.Id_Server 
															AND D.Id_Database = E.Id_Database AND C.Id_Table = E.Id_Table 
															AND E.Dt_Log = CONVERT(VARCHAR, GETDATE() ,112)    
	where Nm_Index is not null	and Type_Desc is not NULL AND E.Id_Size_History IS NULL 
	group by B.Id_Server, D.Id_Database, C.Id_Table, UPPER(A.Nm_Drive), E.Dt_Log
END
GO



GO
IF (OBJECT_ID('[dbo].[stpCheckList_Database_Growth]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Database_Growth]
GO

CREATE PROCEDURE [dbo].[stpCheckList_Database_Growth]
AS
BEGIN
	SET NOCOUNT ON

	TRUNCATE TABLE [dbo].[CheckList_Database_Growth]
	TRUNCATE TABLE [dbo].[CheckList_Database_Growth_Email]

	IF NOT EXISTS (SELECT Fl_Enabled FROM CheckList_Parameter WHERE Nm_Procedure = 'stpCheckList_Database_Growth' AND Fl_Enabled = 1)
	BEGIN
		RETURN
	END


	DECLARE @Dt_Hoje DATE, @Dt_1Dia DATE, @Dt_15Dias DATE, @Dt_30Dias DATE, @Dt_60Dias DATE
	
	SELECT	@Dt_Hoje = CAST(GETDATE() AS DATE)
	
	SELECT	@Dt_1Dia =	 MIN((CASE WHEN DATEDIFF(DAY,A.[Dt_Log], @Dt_Hoje) <= 1  THEN A.[Dt_Log] END)),
			@Dt_15Dias = MIN((CASE WHEN DATEDIFF(DAY,A.[Dt_Log], @Dt_Hoje) <= 15 THEN A.[Dt_Log] END)),
			@Dt_30Dias = MIN((CASE WHEN DATEDIFF(DAY,A.[Dt_Log], @Dt_Hoje) <= 30 THEN A.[Dt_Log] END)),
			@Dt_60Dias = MIN((CASE WHEN DATEDIFF(DAY,A.[Dt_Log], @Dt_Hoje) <= 60 THEN A.[Dt_Log] END))
	FROM [dbo].[Table_Size_History] A
		JOIN [dbo].User_Server B ON A.[Id_Server] = B.[Id_Server] 
		JOIN [dbo].User_Table C ON A.[Id_Table] = C.[Id_Table]
		JOIN [dbo].User_Database D ON A.[Id_Database] = D.[Id_Database]
	WHERE 	DATEDIFF(DAY,A.[Dt_Log], CAST(GETDATE() AS DATE)) <= 60
		AND B.Nm_Server = @@SERVERNAME
	
	/*

	SELECT @Dt_Hoje Dt_Hoje, @Dt_1Dia Dt_1Dia, @Dt_15Dias Dt_15Dias, @Dt_30Dias Dt_30Dias, @Dt_60Dias Dt_60Dias
	
	SELECT	CONVERT(VARCHAR, GETDATE() ,112) Hoje, CONVERT(VARCHAR, GETDATE()-1 ,112) [1Dia], CONVERT(VARCHAR, GETDATE()-15 ,112) [15Dias],
			CONVERT(VARCHAR, GETDATE()-30 ,112) [30Dias], CONVERT(VARCHAR, GETDATE()-60 ,112) [60Dias]
	*/

	IF (OBJECT_ID('tempdb..#CheckList_Database_Growth') IS NOT NULL)
		DROP TABLE #CheckList_Database_Growth
	
	CREATE TABLE #CheckList_Database_Growth (
		[Nm_Server]	VARCHAR(50) NOT NULL,
		[Nm_Database]	VARCHAR(100) NULL,
		[Actual_Size] NUMERIC(38, 2) NULL,
		[Growth_1_day]	NUMERIC(38, 2) NULL,
		[Growth_15_days]	NUMERIC(38, 2) NULL,
		[Growth_30_days]	NUMERIC(38, 2) NULL,
		[Growth_60_days]	NUMERIC(38, 2) NULL
	)
		
	INSERT INTO #CheckList_Database_Growth
	SELECT	B.[Nm_Server], [Nm_Database], 
			SUM(CASE WHEN [Dt_Log] = @Dt_Hoje   THEN A.[Nr_Total_Size] ELSE 0 END) AS [Actual_Size],
			SUM(CASE WHEN [Dt_Log] = @Dt_1Dia   THEN A.[Nr_Total_Size] ELSE 0 END) AS [Growth_1_day],
			SUM(CASE WHEN [Dt_Log] = @Dt_15Dias THEN A.[Nr_Total_Size] ELSE 0 END) AS [Growth_15_days],
			SUM(CASE WHEN [Dt_Log] = @Dt_30Dias THEN A.[Nr_Total_Size] ELSE 0 END) AS [Growth_30_days],
			SUM(CASE WHEN [Dt_Log] = @Dt_60Dias THEN A.[Nr_Total_Size] ELSE 0 END) AS [Growth_60_days]          
	FROM [dbo].[Table_Size_History] A
		JOIN [dbo].User_Server B ON A.[Id_Server] = B.[Id_Server] 
		JOIN [dbo].User_Table C ON A.[Id_Table] = C.[Id_Table]
		JOIN [dbo].User_Database D ON A.[Id_Database] = D.[Id_Database]
	WHERE	A.[Dt_Log] IN ( @Dt_Hoje, @Dt_1Dia, @Dt_15Dias, @Dt_30Dias, @Dt_60Dias ) -- Hoje, 1 dia, 15 dias, 30 dias, 60 dias
		AND B.Nm_Server = @@SERVERNAME
	GROUP BY B.[Nm_Server], [Nm_Database]
			
					
	INSERT INTO [dbo].[CheckList_Database_Growth] ( [Nm_Server], [Nm_Database], [Actual_Size], [Growth_1_day], [Growth_15_days], [Growth_30_days], [Growth_60_days] )
	SELECT	[Nm_Server], [Nm_Database], [Actual_Size], 
			[Actual_Size] - [Growth_1_day] AS [Growth_1_day],
			[Actual_Size] - [Growth_15_days] AS [Growth_15_days],
			[Actual_Size] - [Growth_30_days] AS [Growth_30_days],
			[Actual_Size] - [Growth_60_days] AS [Growth_60_days]
	FROM #CheckList_Database_Growth

	IF (@@ROWCOUNT <> 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Database_Growth_Email] ( [Nm_Server], [Nm_Database], [Actual_Size], [Growth_1_day], [Growth_15_days], [Growth_30_days], [Growth_60_days] )
		SELECT	TOP 10
				[Nm_Server], [Nm_Database], [Actual_Size], [Growth_1_day], [Growth_15_days], [Growth_30_days], [Growth_60_days]
		FROM [dbo].[CheckList_Database_Growth]
		ORDER BY ABS([Growth_1_day]) DESC, ABS([Growth_15_days]) DESC, ABS([Growth_30_days]) DESC, ABS([Growth_60_days]) DESC, [Actual_Size] DESC
	
		INSERT INTO [dbo].[CheckList_Database_Growth_Email] ( [Nm_Server], [Nm_Database], [Actual_Size], [Growth_1_day], [Growth_15_days], [Growth_30_days], [Growth_60_days] )
		SELECT NULL, 'TOTAL ALL', SUM([Actual_Size]), SUM([Growth_1_day]), SUM([Growth_15_days]), SUM([Growth_30_days]), SUM([Growth_60_days])
		FROM [dbo].[CheckList_Database_Growth]
	END
	ELSE
	BEGIN
		INSERT INTO [dbo].[CheckList_Database_Growth_Email] ( [Nm_Server], [Nm_Database], [Actual_Size], [Growth_1_day], [Growth_15_days], [Growth_30_days], [Growth_60_days] )
		SELECT NULL, 'Without Information', NULL, NULL, NULL, NULL, NULL
	END
END

GO
IF (OBJECT_ID('[dbo].[stpCheckList_Table_Growth]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Table_Growth]	
GO

CREATE PROCEDURE [dbo].[stpCheckList_Table_Growth]
AS
BEGIN
	SET NOCOUNT ON
				
	TRUNCATE TABLE [dbo].[CheckList_Table_Growth]
	TRUNCATE TABLE [dbo].[CheckList_Table_Growth_Email]

	IF NOT EXISTS (SELECT Fl_Enabled FROM CheckList_Parameter WHERE Nm_Procedure = 'stpCheckList_Table_Growth' AND Fl_Enabled = 1)
	BEGIN
		RETURN
	END

	DECLARE @Dt_Hoje DATE, @Dt_1Dia DATE, @Dt_15Dias DATE, @Dt_30Dias DATE, @Dt_60Dias DATE
	
	SELECT	@Dt_Hoje = CAST(GETDATE() AS DATE)
	
	SELECT	@Dt_1Dia   = MIN((CASE WHEN DATEDIFF(DAY,A.[Dt_Log], @Dt_Hoje) <= 1  THEN A.[Dt_Log] END)),
			@Dt_15Dias = MIN((CASE WHEN DATEDIFF(DAY,A.[Dt_Log], @Dt_Hoje) <= 15 THEN A.[Dt_Log] END)),
			@Dt_30Dias = MIN((CASE WHEN DATEDIFF(DAY,A.[Dt_Log], @Dt_Hoje) <= 30 THEN A.[Dt_Log] END)),
			@Dt_60Dias = MIN((CASE WHEN DATEDIFF(DAY,A.[Dt_Log], @Dt_Hoje) <= 60 THEN A.[Dt_Log] END))
	FROM [dbo].[Table_Size_History] A
		JOIN [dbo].User_Server B ON A.[Id_Server] = B.[Id_Server] 
		JOIN [dbo].User_Table C ON A.[Id_Table] = C.[Id_Table]
		JOIN [dbo].User_Database D ON A.[Id_Database] = D.[Id_Database]
	WHERE 	DATEDIFF(DAY,A.[Dt_Log], CAST(GETDATE() AS DATE)) <= 60
		AND B.Nm_Server = @@SERVERNAME
	
	/*

	SELECT @Dt_Hoje Dt_Hoje, @Dt_1Dia Dt_1Dia, @Dt_15Dias Dt_15Dias, @Dt_30Dias Dt_30Dias, @Dt_60Dias Dt_60Dias
	
	SELECT	CONVERT(VARCHAR, GETDATE() ,112) Hoje, CONVERT(VARCHAR, GETDATE()-1 ,112) [1Dia], CONVERT(VARCHAR, GETDATE()-15 ,112) [15Dias],
			CONVERT(VARCHAR, GETDATE()-30 ,112) [30Dias], CONVERT(VARCHAR, GETDATE()-60 ,112) [60Dias]
	*/

	IF (OBJECT_ID('tempdb..#CheckList_Table_Growth') IS NOT NULL)
		DROP TABLE #CheckList_Table_Growth
	
	CREATE TABLE #CheckList_Table_Growth (
		[Nm_Server]	VARCHAR(50) NOT NULL,
		[Nm_Database]	VARCHAR(100) NULL,
		[Nm_Table]		VARCHAR(100) NULL,
		[Actual_Size] NUMERIC(38, 2) NULL,
		[Growth_1_day]	NUMERIC(38, 2) NULL,
		[Growth_15_days]	NUMERIC(38, 2) NULL,
		[Growth_30_days]	NUMERIC(38, 2) NULL,
		[Growth_60_days]	NUMERIC(38, 2) NULL		
	)
		
	INSERT INTO #CheckList_Table_Growth
	SELECT	B.[Nm_Server], [Nm_Database], [Nm_Table], 
			SUM(CASE WHEN [Dt_Log] = @Dt_Hoje   THEN A.[Nr_Total_Size] ELSE 0 END) AS [Actual_Size],
			SUM(CASE WHEN [Dt_Log] = @Dt_1Dia   THEN A.[Nr_Total_Size] ELSE 0 END) AS [Growth_1_day],
			SUM(CASE WHEN [Dt_Log] = @Dt_15Dias THEN A.[Nr_Total_Size] ELSE 0 END) AS [Growth_15_days],
			SUM(CASE WHEN [Dt_Log] = @Dt_30Dias THEN A.[Nr_Total_Size] ELSE 0 END) AS [Growth_30_days],
			SUM(CASE WHEN [Dt_Log] = @Dt_60Dias THEN A.[Nr_Total_Size] ELSE 0 END) AS [Growth_60_days]           
	FROM [dbo].[Table_Size_History] A
		JOIN [dbo].User_Server B ON A.[Id_Server] = B.[Id_Server] 
		JOIN [dbo].User_Table C ON A.[Id_Table] = C.[Id_Table]
		JOIN [dbo].User_Database D ON A.[Id_Database] = D.[Id_Database]
	WHERE 	A.[Dt_Log] IN( @Dt_Hoje, @Dt_1Dia, @Dt_15Dias, @Dt_30Dias, @Dt_60Dias) -- Hoje, 1 dia, 15 dias, 30 dias, 60 dias
		AND B.Nm_Server = @@SERVERNAME
	GROUP BY B.[Nm_Server], [Nm_Database], [Nm_Table]

			
	INSERT INTO [dbo].[CheckList_Table_Growth] ( [Nm_Server], [Nm_Database], [Nm_Table], [Actual_Size], [Growth_1_day], [Growth_15_days], [Growth_30_days], [Growth_60_days] )
	SELECT	[Nm_Server], [Nm_Database], [Nm_Table], [Actual_Size], 
			[Actual_Size] - [Growth_1_day] AS [Growth_1_day],
			[Actual_Size] - [Growth_15_days] AS [Growth_15_days],
			[Actual_Size] - [Growth_30_days] AS [Growth_30_days],
			[Actual_Size] - [Growth_60_days] AS [Growth_60_days]
	FROM #CheckList_Table_Growth
	
	IF (@@ROWCOUNT <> 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Table_Growth_Email] ( [Nm_Server], [Nm_Database], [Nm_Table], [Actual_Size], [Growth_1_day], [Growth_15_days], [Growth_30_days], [Growth_60_days] )
		SELECT	TOP 10
				[Nm_Server], [Nm_Database], [Nm_Table], [Actual_Size], [Growth_1_day], [Growth_15_days], [Growth_30_days], [Growth_60_days]
		FROM [dbo].[CheckList_Table_Growth]
		ORDER BY ABS([Growth_1_day]) DESC, ABS([Growth_15_days]) DESC, ABS([Growth_30_days]) DESC, ABS([Growth_60_days]) DESC, [Actual_Size] DESC
	
		INSERT INTO [dbo].[CheckList_Table_Growth_Email] ( [Nm_Server], [Nm_Database], [Nm_Table], [Actual_Size], [Growth_1_day], [Growth_15_days], [Growth_30_days], [Growth_60_days] )
		SELECT NULL, 'TOTAL ALL', NULL, SUM([Actual_Size]), SUM([Growth_1_day]), SUM([Growth_15_days]), SUM([Growth_30_days]), SUM([Growth_60_days])
		FROM [dbo].[CheckList_Table_Growth]
	END
	ELSE
	BEGIN
		INSERT INTO [dbo].[CheckList_Table_Growth_Email] ( [Nm_Server], [Nm_Database], [Nm_Table], [Actual_Size], [Growth_1_day], [Growth_15_days], [Growth_30_days], [Growth_60_days] )
		SELECT NULL, 'Without Information', NULL, NULL, NULL, NULL, NULL, NULL
	END
END
GO


IF (OBJECT_ID('[dbo].[stpLoad_File_Utilization]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpLoad_File_Utilization]
GO

CREATE PROCEDURE [dbo].[stpLoad_File_Utilization]
AS
BEGIN
	INSERT INTO dbo.File_Utilization_History
	SELECT DB_NAME(database_id) AS [Database Name]
			, file_id 
			, io_stall_read_ms
			, num_of_reads
			, CAST(io_stall_read_ms/(1.0 + num_of_reads) AS NUMERIC(10,1)) AS [avg_read_stall_ms]
			, io_stall_write_ms
			, num_of_writes
			, CAST(io_stall_write_ms/(1.0+num_of_writes) AS NUMERIC(10,1)) AS [avg_write_stall_ms]
			, io_stall_read_ms + io_stall_write_ms AS [io_stalls]
			, num_of_reads + num_of_writes AS [total_io]
			, CAST((io_stall_read_ms + io_stall_write_ms)/(1.0 + num_of_reads + num_of_writes) AS NUMERIC(10,1)) AS [avg_io_stall_ms]
			, GETDATE() as [Dt_Registro]
	FROM sys.dm_io_virtual_file_stats(null,null)
END
GO

GO

IF (OBJECT_ID('[dbo].[stpCheckList_File_Utilization]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_File_Utilization]	
GO	

CREATE PROCEDURE [dbo].[stpCheckList_File_Utilization]
AS
BEGIN

	TRUNCATE TABLE [dbo].[CheckList_File_Writes]
	TRUNCATE TABLE [dbo].[CheckList_File_Reads]

	IF NOT EXISTS (SELECT Fl_Enabled FROM CheckList_Parameter WHERE Nm_Procedure = 'stpCheckList_File_Utilization' AND Fl_Enabled = 1)
	BEGIN
		RETURN
	END


	DECLARE @Dt_Log DATETIME = CAST(GETDATE()-1 AS DATE)

	-- WRITES
	if (OBJECT_ID('tempdb..#file_writes') is not null)
		drop table #file_writes

	select  TOP 10
			A.Nm_Database, A.file_id
			, B.io_stall_write_ms - A.io_stall_write_ms AS io_stall_write_ms		
			, B.num_of_writes - A.num_of_writes AS num_of_writes
			, CASE WHEN (1.0 + B.num_of_writes - A.num_of_writes) <> 0 THEN
					CAST(((B.io_stall_write_ms - A.io_stall_write_ms)/(1.0+ B.num_of_writes - A.num_of_writes)) AS NUMERIC(15,1)) 
				ELSE
					0
			  END AS [avg_write_stall_ms]
	into #file_writes		  
	from [dbo].File_Utilization_History A
	JOIN [dbo].File_Utilization_History B on	A.Nm_Database = B.Nm_Database and A.file_id = B.file_id
													and B.Dt_Log >= @Dt_Log and B.Dt_Log < @Dt_Log + 1
													and DATEPART(HH,B.Dt_Log) = 18 and DATEPART(MINUTE,B.Dt_Log) BETWEEN 0 AND 5	-- 18 Hours
	where	A.Dt_Log >= @Dt_Log and A.Dt_Log < @Dt_Log + 1
			and DATEPART(HH,A.Dt_Log) = 9 and DATEPART(MINUTE,A.Dt_Log) BETWEEN 0 AND 5											-- 9 HORAS	
	order by num_of_writes  DESC 
	
	-- READS
	if (OBJECT_ID('tempdb..#file_reads') is not null)
		drop table #file_reads

	select  TOP 10
			A.Nm_Database, A.file_id
			, B.io_stall_read_ms - A.io_stall_read_ms AS io_stall_read_ms
			, B.num_of_reads - A.num_of_reads AS num_of_reads		
			, CASE WHEN (1.0 + B.num_of_reads - A.num_of_reads) <> 0 THEN
					CAST(((B.io_stall_read_ms - A.io_stall_read_ms)/(1.0 + B.num_of_reads - A.num_of_reads)) AS NUMERIC(15,1))
				ELSE 
					0
			  END AS [avg_read_stall_ms]
	into #file_reads		  
	from [dbo].File_Utilization_History A
	JOIN [dbo].File_Utilization_History B on	A.Nm_Database = B.Nm_Database and A.file_id = B.file_id
													and B.Dt_Log >= @Dt_Log and B.Dt_Log < @Dt_Log + 1
													and DATEPART(HH,B.Dt_Log) = 18 and DATEPART(MINUTE,B.Dt_Log) BETWEEN 0 AND 5	-- 18 HORAS
	where	A.Dt_Log >= @Dt_Log and A.Dt_Log < @Dt_Log + 1
			and DATEPART(HH,A.Dt_Log) = 9 and DATEPART(MINUTE,A.Dt_Log) BETWEEN 0 AND 5											-- 9 HORAS	
	order by num_of_reads  DESC 

	-- WRITES

	
	INSERT INTO [dbo].[CheckList_File_Writes]
	SELECT *
	FROM #file_writes

	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_File_Writes]
		SELECT 'Without Information - Writes', 0, 0, 0, 0
	END
	
	-- READS

	
	INSERT INTO [dbo].[CheckList_File_Reads]
	SELECT *
	FROM #file_reads
	
	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_File_Reads]
		SELECT 'Without Information - Reads', 0, 0, 0, 0
	END
END


GO
IF (OBJECT_ID('[dbo].[stpCheckList_Database_Without_Backup]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Database_Without_Backup]	
GO	
	
CREATE PROCEDURE [dbo].[stpCheckList_Database_Without_Backup]
AS
BEGIN

	TRUNCATE TABLE [dbo].[CheckList_Database_Without_Backup]

	IF NOT EXISTS (SELECT Fl_Enabled FROM CheckList_Parameter WHERE Nm_Procedure = 'stpCheckList_Database_Without_Backup' AND Fl_Enabled = 1)
	BEGIN
		RETURN
	END
	

	DECLARE @Dt_Log DATETIME
	SELECT @Dt_Log = GETDATE()
	
	IF ( OBJECT_ID('tempdb..#CheckList_Database_Without_Backup') IS NOT NULL)
	DROP TABLE #CheckList_Database_Without_Backup

	SELECT A.name AS Nm_Database
	INTO #CheckList_Database_Without_Backup
	FROM [sys].[databases] A
	LEFT JOIN [msdb].[dbo].[backupset] B ON 
			B.[database_name] = A.name AND [type] IN ('D','I')
			and [backup_start_date] >= DATEADD(hh, -16, @Dt_Log)
	LEFT JOIN [dbo].[Ignore_Databases] C ON A.[name] = C.[Nm_Database]
	WHERE	B.[database_name] IS NULL
			and C.[Nm_Database] IS NULL
			AND A.[name] NOT IN ('tempdb','ReportServerTempDB') 
			AND state_desc <> 'OFFLINE'
		
	INSERT INTO [dbo].[CheckList_Database_Without_Backup] (Nm_Database)
	select Nm_Database 
	from #CheckList_Database_Without_Backup
			  
	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Database_Without_Backup] ( Nm_Database )
		SELECT 'No problem with Backups on the last 16 Hours'
	END
END

GO
IF (OBJECT_ID('[dbo].[stpCheckList_Backup_Executed]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Backup_Executed]	
GO	
	
CREATE PROCEDURE [dbo].[stpCheckList_Backup_Executed]
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Dt_Log DATETIME
	SELECT @Dt_Log = GETDATE()

	TRUNCATE TABLE [dbo].[CheckList_Backup_Executed]

	IF NOT EXISTS (SELECT Fl_Enabled FROM CheckList_Parameter WHERE Nm_Procedure = 'stpCheckList_Backup_Executed' AND Fl_Enabled = 1)
	BEGIN
		RETURN
	END

	
	INSERT INTO [dbo].[CheckList_Backup_Executed] (	[Database_Name], [Name], [Backup_Start_Date], [Tempo_Min], [Position], [Server_Name],
														[Recovery_Model], [Logical_Device_Name], [Device_Type], [Type], [Tamanho_MB] )
	SELECT	[database_name], [name], [backup_start_date], DATEdiff(mi, [backup_start_date], [backup_finish_date]) AS [Tempo_Min], 
			[position], [server_name], [recovery_model], isnull([logical_device_name], ' ') AS [logical_device_name],
			[device_type], [type], CAST([backup_size]/1024/1024 AS NUMERIC(15,2)) AS [Tamanho (MB)]
	FROM [msdb].[dbo].[backupset] B
		JOIN [msdb].[dbo].[backupmediafamily] BF ON B.[media_set_id] = BF.[media_set_id]
	WHERE [backup_start_date] >= DATEADD(hh, -24 ,@Dt_Log) AND [type] in ('D','I')
		  
	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Backup_Executed] (	[Database_Name], [Name], [Backup_Start_Date], [Tempo_Min], [Position], [Server_Name],
															[Recovery_Model], [Logical_Device_Name], [Device_Type], [Type], [Tamanho_MB] )
		SELECT 'Withou Backup FULL or Differential in the last 24 hours.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
	END
END
GO

IF (OBJECT_ID('[dbo].[stpCheckList_Queries_Running]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Queries_Running]
GO


CREATE PROCEDURE [dbo].[stpCheckList_Queries_Running]
AS
BEGIN
	SET NOCOUNT ON 

	TRUNCATE TABLE [dbo].[CheckList_Queries_Running]

	IF NOT EXISTS (SELECT Fl_Enabled FROM CheckList_Parameter WHERE Nm_Procedure = 'stpCheckList_Queries_Running' AND Fl_Enabled = 1)
	BEGIN
		RETURN
	END
	

	IF ( OBJECT_ID('tempdb..#Whoisactive_Result') IS NOT NULL )
		DROP TABLE #Whoisactive_Result
				
	CREATE TABLE #Whoisactive_Result (		
		[dd hh:mm:ss.mss]		VARCHAR(20),
		[database_name]			NVARCHAR(128),		
		[login_name]			NVARCHAR(128),
		[host_name]				NVARCHAR(128),
		[start_time]			DATETIME,
		[status]				VARCHAR(30),
		[session_id]			INT,
		[blocking_session_id]	INT,
		[wait_info]				VARCHAR(MAX),
		[open_tran_count]		INT,
		[CPU]					VARCHAR(MAX),
		[reads]					VARCHAR(MAX),
		[CPU_delta]					VARCHAR(MAX),
		[reads_delta]					VARCHAR(MAX),
		[writes]				VARCHAR(MAX),
		[sql_command]			XML
	)
	
	EXEC [dbo].[sp_whoisactive]
			@get_outer_command =	1,
			@delta_interval = 1,
			@output_column_list =	'[dd hh:mm:ss.mss][database_name][login_name][host_name][start_time][status][session_id][blocking_session_id][wait_info][open_tran_count][CPU][reads][CPU_delta][reads_delta][writes][sql_command]',
			@destination_table =	'#Whoisactive_Result'

	ALTER TABLE #Whoisactive_Result
	ALTER COLUMN [sql_command] NVARCHAR(MAX)
	
	UPDATE #Whoisactive_Result
	SET [sql_command] = REPLACE( REPLACE( REPLACE( REPLACE( CAST([sql_command] AS NVARCHAR(1000)), '<?query --', ''), '--?>', ''), '&gt;', '>'), '&lt;', '')

	DELETE #Whoisactive_Result	
	where DATEDIFF(MINUTE, start_time, GETDATE()) < 120
	OR ISNULL(wait_info,'') LIKE '%XE_LIVE_TARGET_TVF%' -- IGNORE this wait type (Managed Instance)


	INSERT INTO [dbo].[CheckList_Queries_Running]
	SELECT * FROM #Whoisactive_Result

	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Queries_Running]( [dd hh:mm:ss.mss], database_name, login_name, host_name, start_time, status, session_id, blocking_session_id, wait_info, open_tran_count, CPU, reads, CPU_delta, reads_delta, writes, sql_command )
		SELECT NULL, 'Without Queries running for more than 2 hours', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
	END
END

GO
IF (OBJECT_ID('[dbo].[stpCheckList_Changed_Jobs]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Changed_Jobs]
GO

CREATE PROCEDURE [dbo].[stpCheckList_Changed_Jobs]
AS
BEGIN

	SET NOCOUNT ON

	TRUNCATE TABLE [dbo].[CheckList_Changed_Jobs]

	IF NOT EXISTS (SELECT Fl_Enabled FROM CheckList_Parameter WHERE Nm_Procedure = 'stpCheckList_Changed_Jobs' AND Fl_Enabled = 1)
	BEGIN
		RETURN
	END

	DECLARE @hoje VARCHAR(8), @ontem VARCHAR(8)	
	SELECT	@ontem  = CONVERT(VARCHAR(8),(DATEADD (DAY, -1, GETDATE())), 112),
			@hoje = CONVERT(VARCHAR(8), GETDATE()+1, 112)

	TRUNCATE TABLE [dbo].[CheckList_Changed_Jobs]

	INSERT INTO [dbo].[CheckList_Changed_Jobs] ( [Nm_Job], [Fl_Enabled], [Dt_Creation], [Dt_Alteration], [Nr_Version] )
	SELECT	[name] AS [Nm_Job], CONVERT(SMALLINT, [enabled]) AS [Fl_Enabled], CONVERT(SMALLDATETIME, [date_created]) AS [Dt_Creation], 
			CONVERT(SMALLDATETIME, [date_modified]) AS [Dt_Alteration], [version_number] AS [Nr_Version]
	FROM [msdb].[dbo].[sysjobs]  sj     
	WHERE	( [date_created] >= @ontem AND [date_created] < @hoje) OR ([date_modified] >= @ontem AND [date_modified] < @hoje)	
	 
	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Changed_Jobs] ( [Nm_Job], [Fl_Enabled], [Dt_Creation], [Dt_Alteration], [Nr_Version] )
		SELECT 'Without information about changed hobs', NULL, NULL, NULL, NULL
	END
END

GO
IF (OBJECT_ID('[dbo].[stpCheckList_Jobs_Failed]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Jobs_Failed]
GO

CREATE PROCEDURE [dbo].[stpCheckList_Jobs_Failed]
AS
BEGIN
	SET NOCOUNT ON

	TRUNCATE TABLE [dbo].[CheckList_Jobs_Failed]

	IF NOT EXISTS (SELECT Fl_Enabled FROM CheckList_Parameter WHERE Nm_Procedure = 'stpCheckList_Jobs_Failed' AND Fl_Enabled = 1)
	BEGIN
		RETURN
	END
		
	IF (OBJECT_ID('tempdb..#Result_History_Jobs') IS NOT NULL)
		DROP TABLE #Result_History_Jobs

	CREATE TABLE #Result_History_Jobs (
		[Cod] INT IDENTITY(1,1),
		[Instance_Id] INT,
		[Job_Id] VARCHAR(255),
		[Job_Name] VARCHAR(255),
		[Step_Id] INT,
		[Step_Name] VARCHAR(255),
		[SQl_Message_Id] INT,
		[Sql_Severity] INT,
		[SQl_Message] VARCHAR(4490),
		[Run_Status] INT,
		[Run_Date] VARCHAR(20),
		[Run_Time] VARCHAR(20),
		[Run_Duration] INT,
		[Operator_Emailed] VARCHAR(100),
		[Operator_NetSent] VARCHAR(100),
		[Operator_Paged] VARCHAR(100),
		[Retries_Attempted] INT,
		[Nm_Server] VARCHAR(100)  
	)

	DECLARE @hoje VARCHAR(8), @ontem VARCHAR(8)	
	SELECT	@ontem = CONVERT(VARCHAR(8),(DATEADD (DAY, -1, GETDATE())), 112), 
			@hoje = CONVERT(VARCHAR(8), GETDATE() + 1, 112)

	INSERT INTO #Result_History_Jobs
	EXEC [msdb].[dbo].[sp_help_jobhistory] @mode = 'FULL', @start_run_date = @ontem

	INSERT INTO [dbo].[CheckList_Jobs_Failed] ( [Server], [Job_Name], [Status], [Dt_Execution], [Run_Duration], [SQL_Message] )
	SELECT	Nm_Server AS [Server], [Job_Name], 
			CASE	WHEN [Run_Status] = 0 THEN 'Failed'
					WHEN [Run_Status] = 1 THEN 'Succeeded'
					WHEN [Run_Status] = 2 THEN 'Retry (step only)'
					WHEN [Run_Status] = 3 THEN 'Cancelled'
					WHEN [Run_Status] = 4 THEN 'In-progress message'
					WHEN [Run_Status] = 5 THEN 'Unknown' 
			END [Status],
			CAST(	[Run_Date] + ' ' +
					RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-5), 2), 2) + ':' +
					RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-3), 2), 2) + ':' +
					RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-1), 2), 2) AS VARCHAR) AS [Dt_Execution],
			RIGHT('00' + SUBSTRING(CAST([Run_Duration] AS VARCHAR),(LEN([Run_Duration])-5),2), 2) + ':' +
			RIGHT('00' + SUBSTRING(CAST([Run_Duration] AS VARCHAR),(LEN([Run_Duration])-3),2), 2) + ':' +
			RIGHT('00' + SUBSTRING(CAST([Run_Duration] AS VARCHAR),(LEN([Run_Duration])-1),2), 2) AS [Run_Duration],
			CAST([SQl_Message] AS VARCHAR(3990)) AS [SQl_Message]
	FROM #Result_History_Jobs 
	WHERE 
		  CAST([Run_Date] + ' ' + RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-5), 2), 2) + ':' +
			  RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-3), 2), 2) + ':' +
			  RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-1), 2), 2) AS DATETIME) >= @ontem + ' 08:00' 
		  AND  /*dia anterior no horário*/
			CAST([Run_Date] + ' ' + RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-5), 2), 2) + ':' +
			  RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-3), 2), 2) + ':' +
			  RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-1), 2), 2) AS DATETIME) < @hoje
		  --AND [Step_Id] = 0 tratamento para o Retry do Job
		  AND [Run_Status] <> 1
	 
	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Jobs_Failed] ( [Server], [Job_Name], [Status], [Dt_Execution], [Run_Duration], [SQL_Message] )
		SELECT NULL, 'Without Information about failed Jobs', NULL, NULL, NULL, NULL		
	END
END

GO
IF (OBJECT_ID('[dbo].[stpChecklist_Slow_Jobs]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpChecklist_Slow_Jobs]	
GO	

CREATE PROCEDURE [dbo].[stpChecklist_Slow_Jobs]
AS
BEGIN
	SET NOCOUNT ON

	TRUNCATE TABLE [dbo].[CheckList_Slow_Jobs]

	IF NOT EXISTS (SELECT Fl_Enabled FROM CheckList_Parameter WHERE Nm_Procedure = 'stpChecklist_Slow_Jobs' AND Fl_Enabled = 1)
	BEGIN
		RETURN
	END
	
	IF (OBJECT_ID('tempdb..#Result_History_Jobs') IS NOT NULL)
		DROP TABLE #Result_History_Jobs
		
	CREATE TABLE #Result_History_Jobs (
		[Cod]				INT	IDENTITY(1,1),
		[Instance_Id]		INT,
		[Job_Id]			VARCHAR(255),
		[Job_Name]			VARCHAR(255),
		[Step_Id]			INT,
		[Step_Name]			VARCHAR(255),
		[Sql_Message_Id]	INT,
		[Sql_Severity]		INT,
		[SQl_Message]		VARCHAR(4490),
		[Run_Status]		INT,
		[Run_Date]			VARCHAR(20),
		[Run_Time]			VARCHAR(20),
		[Run_Duration]		INT,
		[Operator_Emailed]	VARCHAR(100),
		[Operator_NetSent]	VARCHAR(100),
		[Operator_Paged]	VARCHAR(100),
		[Retries_Attempted] INT,
		[Nm_Server]			VARCHAR(100)  
	)
	
	DECLARE @ontem VARCHAR(8)
	SET @ontem  =  CONVERT(VARCHAR(8), (DATEADD(DAY, -1, GETDATE())), 112)

	INSERT INTO #Result_History_Jobs
	EXEC [msdb].[dbo].[sp_help_jobhistory] @mode = 'FULL', @start_run_date = @ontem


	INSERT INTO [dbo].[CheckList_Slow_Jobs] ( [Job_Name], [Status], [Dt_Execution], [Run_Duration], [SQL_Message] )
	SELECT	[Job_Name], 
			CASE	WHEN [Run_Status] = 0 THEN 'Failed'
					WHEN [Run_Status] = 1 THEN 'Succeeded'
					WHEN [Run_Status] = 2 THEN 'Retry (step only)'
					WHEN [Run_Status] = 3 THEN 'Canceled'
					WHEN [Run_Status] = 4 THEN 'In-progress message'
					WHEN [Run_Status] = 5 THEN 'Unknown' 
			END [Status],
			CAST([Run_Date] + ' ' +
				RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-5), 2), 2) + ':' +
				RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-3), 2), 2) + ':' +
				RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-1), 2), 2) AS VARCHAR) AS [Dt_Execution],
			RIGHT('00' + SUBSTRING(CAST(Run_Duration AS VARCHAR),(LEN(Run_Duration)-5), 2), 2)+ ':' +
				RIGHT('00' + SUBSTRING(CAST(Run_Duration AS VARCHAR),(LEN(Run_Duration)-3), 2) ,2) + ':' +
				RIGHT('00' + SUBSTRING(CAST(Run_Duration AS VARCHAR),(LEN(Run_Duration)-1), 2) ,2) AS [Run_Duration],
			CAST([SQl_Message] AS VARCHAR(3990)) AS [SQL_Message]	
	FROM #Result_History_Jobs
	WHERE 
		  CAST([Run_Date] + ' ' + RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-5), 2), 2) + ':' +
		  RIGHT('00' + SUBSTRING([Run_Time], (LEN([Run_Time])-3), 2), 2) + ':' +
		  RIGHT('00' + SUBSTRING([Run_Time], (LEN([Run_Time])-1), 2), 2) AS DATETIME) >= GETDATE() -1 and
		  CAST([Run_Date] + ' ' + RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-5), 2), 2)+ ':' +
		  RIGHT('00' + SUBSTRING([Run_Time], (LEN([Run_Time])-3), 2), 2) + ':' +
		  RIGHT('00' + SUBSTRING([Run_Time], (LEN([Run_Time])-1), 2), 2) AS DATETIME) < GETDATE() 
		  AND [Step_Id] = 0
		  AND [Run_Status] = 1
		  AND [Run_Duration] >= 100  -- JOBS que demoraram mais de 1 minuto

	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Slow_Jobs] ( [Job_Name], [Status], [Dt_Execution], [Run_Duration], [SQL_Message] )
		SELECT 'Without Information about Slow Jobs', NULL, NULL, NULL, NULL
	END
END

GO
IF (OBJECT_ID('[dbo].[stpCheckList_Jobs_Running]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Jobs_Running]	
GO	


CREATE PROCEDURE [dbo].[stpCheckList_Jobs_Running]
AS
BEGIN
	SET NOCOUNT ON

	TRUNCATE TABLE [dbo].[CheckList_Jobs_Running]

	IF NOT EXISTS (SELECT Fl_Enabled FROM CheckList_Parameter WHERE Nm_Procedure = 'stpCheckList_Jobs_Running' AND Fl_Enabled = 1)
	BEGIN
		RETURN
	END

	INSERT INTO [dbo].[CheckList_Jobs_Running] (Nm_JOB, Dt_Start, Duration, Nm_Step)
	SELECT
		j.name AS Nm_JOB,
		CONVERT(VARCHAR(16), start_execution_date,120) AS Dt_Start,
		RTRIM(CONVERT(CHAR(17), DATEDIFF(SECOND, CONVERT(DATETIME, start_execution_date), GETDATE()) / 86400)) + ' Dia(s) ' +
		RIGHT('00' + RTRIM(CONVERT(CHAR(7), DATEDIFF(SECOND, CONVERT(DATETIME, start_execution_date), GETDATE()) % 86400 / 3600)), 2) + ' Hora(s) ' +
		RIGHT('00' + RTRIM(CONVERT(CHAR(7), DATEDIFF(SECOND, CONVERT(DATETIME, start_execution_date), GETDATE()) % 86400 % 3600 / 60)), 2) + ' Minuto(s) ' AS Duration,
		js.step_name AS Nm_Step
	FROM msdb.dbo.sysjobactivity ja 
	LEFT JOIN msdb.dbo.sysjobhistory jh 
		ON ja.job_history_id = jh.instance_id
	JOIN msdb.dbo.sysjobs j 
	ON ja.job_id = j.job_id
	JOIN msdb.dbo.sysjobsteps js
		ON ja.job_id = js.job_id
		AND ISNULL(ja.last_executed_step_id,0)+1 = js.step_id
	WHERE	ja.session_id = (SELECT TOP 1 session_id FROM msdb.dbo.syssessions ORDER BY agent_start_date DESC)
			AND start_execution_date is not null
			AND stop_execution_date is null
			AND DATEDIFF(minute,start_execution_date, GETDATE()) >= 10		-- No minimo 10 minutos em execução

	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Jobs_Running] (Nm_JOB, Dt_Start, Duration, Nm_Step)
		SELECT 'Without Information about a Job executing for more than 10 minutes', NULL, NULL, NULL
	END	
END

GO	
IF (OBJECT_ID('[dbo].[stpCheckList_Open_Connection]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Open_Connection]	
GO	


CREATE PROCEDURE [dbo].[stpCheckList_Open_Connection]
AS
BEGIN
	SET NOCOUNT ON

	TRUNCATE TABLE [dbo].[CheckList_Conexao_Aberta]
	TRUNCATE TABLE [dbo].[CheckList_Opened_Connections_Email]

	IF NOT EXISTS (SELECT Fl_Enabled FROM CheckList_Parameter WHERE Nm_Procedure = 'stpCheckList_Open_Connection' AND Fl_Enabled = 1)
	BEGIN
		RETURN
	END


	INSERT INTO [dbo].[CheckList_Conexao_Aberta] ([login_name], [session_count])
	SELECT login_name, COUNT(login_name) AS [session_count] 
	FROM sys.dm_exec_sessions 
	WHERE session_id > 50
	GROUP BY login_name
	ORDER BY COUNT(login_name) DESC, login_name
	
	IF (@@ROWCOUNT <> 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Opened_Connections_Email] ([Nr_Order], [login_name], [session_count])
		SELECT TOP 10 1, [login_name], [session_count]
		FROM [dbo].[CheckList_Conexao_Aberta]
		ORDER BY [session_count] DESC, [login_name]

		INSERT INTO [dbo].[CheckList_Opened_Connections_Email] ([Nr_Order], [login_name], [session_count])
		SELECT 2, 'TOTAL', SUM([session_count])
		FROM [dbo].[CheckList_Conexao_Aberta]		
	END
	ELSE
	BEGIN
		INSERT INTO [dbo].[CheckList_Opened_Connections_Email] ([Nr_Order], [login_name], [session_count])
		SELECT NULL, 'Without Information about User Open Connections', NULL
	END
END

GO
IF (OBJECT_ID('[dbo].[stpCheckList_Profile_Queries]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Profile_Queries]	
GO

CREATE PROCEDURE [dbo].[stpCheckList_Profile_Queries]
AS
BEGIN
	SET NOCOUNT ON

	TRUNCATE TABLE [dbo].[CheckList_Profile_Queries]

	IF NOT EXISTS (SELECT Fl_Enabled FROM CheckList_Parameter WHERE Nm_Procedure = 'stpCheckList_Profile_Queries' AND Fl_Enabled = 1)
	BEGIN
		RETURN
	END

	
	DECLARE @Dt_Log DATETIME
	SET @Dt_Log = CAST(GETDATE() AS DATE)
	
	IF (OBJECT_ID('tempdb..#Slow_Queries') IS NOT NULL) 
		DROP TABLE #Slow_Queries

	SELECT	[TextData], [NTUserName], [HostName], [ApplicationName], [LoginName], [SPID], [Duration], [StartTime], 
			[EndTime], [ServerName], cast([Reads] AS BIGINT) AS [Reads], [Writes], [CPU], [DataBaseName], [RowCounts]
	INTO #Slow_Queries
	FROM [dbo].[Queries_Profile] (nolock)
	WHERE	[StartTime] >= DATEADD(DAY, -10, @Dt_Log)
			AND [StartTime] < @Dt_Log
			AND DATEPART(HOUR, [StartTime]) BETWEEN 7 AND 22	
	
	IF (OBJECT_ID('tempdb..#TOP10_Dia_Anterior') IS NOT NULL) 
		DROP TABLE #TOP10_Dia_Anterior

	SELECT	TOP 10 LTRIM(CAST([TextData] AS CHAR(150))) AS [PrefixoQuery], COUNT(*) AS [QTD], SUM([Duration]) AS [Total], 
			AVG([Duration]) AS [AVG], MIN([Duration]) AS [MIN], MAX([Duration]) AS [MAX],  
			SUM([Writes]) AS [Writes], SUM([CPU]) AS [CPU], SUM([Reads]) AS [Reads]
	INTO #TOP10_Dia_Anterior
	FROM #Slow_Queries
	WHERE	[StartTime] >= DATEADD(DAY, -1, @Dt_Log)
			AND [StartTime] < @Dt_Log
	GROUP BY LTRIM(CAST([TextData] AS CHAR(150)))
	ORDER BY COUNT(*) DESC
		
		
	INSERT INTO [dbo].[CheckList_Profile_Queries] ( [PrefixoQuery], [QTD], [Total], [AVG], [MIN], [MAX], [Writes], [CPU], [Reads], [Ordem] )
	SELECT [PrefixoQuery], [QTD], [Total], [AVG], [MIN], [MAX], [Writes], [CPU], [Reads], 1 AS [Ordem]
	FROM #TOP10_Dia_Anterior	
		
	IF (@@ROWCOUNT <> 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Profile_Queries] ( [PrefixoQuery], [QTD], [Total], [AVG], [MIN], [MAX], [Writes], [CPU], [Reads], [Ordem] )
		SELECT	'OUTRAS' AS [PrefixoQuery], COUNT(*) AS [QTD], SUM([Duration]) AS [Total], 
				AVG([Duration]) AS [AVG], MIN([Duration]) AS [MIN], MAX([Duration]) AS [MAX],  
				SUM([Writes]) AS [Writes], SUM([CPU]) AS [CPU], SUM([Reads]) AS [Reads], 2 AS [Ordem]
		FROM #Slow_Queries A
		WHERE	LTRIM(CAST([TextData] AS CHAR(150))) NOT IN (SELECT [PrefixoQuery] FROM #TOP10_Dia_Anterior)
				AND	[StartTime] >= DATEADD(DAY, -1, @Dt_Log)
				AND [StartTime] < @Dt_Log

		INSERT INTO [dbo].[CheckList_Profile_Queries] ( [PrefixoQuery], [QTD], [Total], [AVG], [MIN], [MAX], [Writes], [CPU], [Reads], [Ordem] )
		SELECT	'TOTAL' AS [PrefixoQuery], SUM([QTD]), SUM([Total]), AVG([AVG]), MIN([MIN]) AS [MIN], 
				MAX([MAX]) AS [MAX], SUM([Writes]) AS [Writes], SUM([CPU]) AS [CPU], SUM([Reads]) AS [Reads], 3 AS [Ordem]
		FROM [dbo].[CheckList_Profile_Queries]
	END
	ELSE
	BEGIN
		INSERT INTO [dbo].[CheckList_Profile_Queries] ( [PrefixoQuery], [QTD], [Total], [AVG], [MIN], [MAX], [Writes], [CPU], [Reads], [Ordem] )	
		SELECT 'Without Information About Slow Queries', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1		
	END

	IF (OBJECT_ID('tempdb..#Slow_All') IS NOT NULL) 
		DROP TABLE #Slow_All

	SELECT	TOP 10 CONVERT(VARCHAR(10), [StartTime], 120) AS [Date], COUNT(*) AS [QTD]
	INTO #Slow_All
	FROM #Slow_Queries
	GROUP BY CONVERT(VARCHAR(10), [StartTime], 120)
	
	TRUNCATE TABLE [dbo].[CheckList_Profile_Queries_LastDays]
		
	INSERT INTO [dbo].[CheckList_Profile_Queries_LastDays] ( [Date], [QTD] )
	SELECT [Date], [QTD]
	FROM #Slow_All
		
	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Profile_Queries_LastDays] ( [Date], [QTD] )	
		SELECT 'Without Information About Slow Queries', NULL		
	END
END
GO

if OBJECT_ID('stpLoad_SQL_Counter') is not null
	drop procedure stpLoad_SQL_Counter

GO
CREATE PROCEDURE stpLoad_SQL_Counter
AS
begin
	
 DECLARE @BatchRequests INT,@User_Connection INT, @CPU INT, @PLE int,@SQLCompilations int,@PS bigint  
  
 DECLARE @RequestsPerSecondSample1 BIGINT,  @RequestsPerSecondSample2 BIGINT  
 DECLARE @SQLCompilationsSample1  BIGINT,  @SQLCompilationsSample2  BIGINT  
  
 SELECT @RequestsPerSecondSample1  = (case when counter_name = 'Batch Requests/sec' then cntr_value end)  
 FROM sys.dm_os_performance_counters   
 WHERE counter_name in ('Batch Requests/sec','SQL Compilations/sec')  
   
 SELECT @RequestsPerSecondSample1 = cntr_value FROM sys.dm_os_performance_counters WHERE counter_name = 'Batch Requests/sec'  
 SELECT @SQLCompilationsSample1 = cntr_value FROM sys.dm_os_performance_counters WHERE counter_name = 'SQL Compilations/sec'  
   
 WAITFOR DELAY '00:00:05'  
  
 SELECT @RequestsPerSecondSample2 = cntr_value FROM sys.dm_os_performance_counters WHERE counter_name = 'Batch Requests/sec'  
 SELECT @SQLCompilationsSample2 = cntr_value FROM sys.dm_os_performance_counters WHERE counter_name = 'SQL Compilations/sec'  
  
 SELECT @BatchRequests = (@RequestsPerSecondSample2 - @RequestsPerSecondSample1)/5  
 SELECT @SQLCompilations = (@SQLCompilationsSample2 - @SQLCompilationsSample1)/5  
  
 select @User_Connection = cntr_Value  
 from sys.dm_os_performance_counters  
 where counter_name = 'User Connections'  
          
     SELECT  TOP(1) @CPU  = (SQLProcessUtilization + (100 - SystemIdle - SQLProcessUtilization ) )  
     FROM (   
        SELECT record.value('(./Record/@id)[1]', 'int') AS record_id,   
        record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int')   
        AS [SystemIdle],   
        record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]',   
        'int')   
        AS [SQLProcessUtilization], [timestamp]   
        FROM (   
        SELECT [timestamp], CONVERT(xml, record) AS [record]   
        FROM sys.dm_os_ring_buffers   
        WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'   
        AND record LIKE '%<SystemHealth>%') AS x   
        ) AS y   
          
          
	 SELECT @PLE = cntr_value   
	 FROM sys.dm_os_performance_counters  
	 WHERE  counter_name = 'Page life expectancy'  
	  and object_name like '%Buffer Manager%'  
	  
	 SELECT @PS = cntr_value  
	 FROM sys.dm_os_performance_counters  
	 WHERE object_name like '%Access Methods%'   
	 and counter_name = 'Page Splits/sec';  
	  
	 insert INTO Log_Counter(Dt_Log,Id_Counter,Value)  
	 Select GETDATE(), 1,@BatchRequests  
	 insert INTO Log_Counter(Dt_Log,Id_Counter,Value)  
	 Select GETDATE(), 2,@User_Connection  
	 insert INTO Log_Counter(Dt_Log,Id_Counter,Value)  
	 Select GETDATE(), 3,@CPU  
	 insert INTO Log_Counter(Dt_Log,Id_Counter,Value)  
	 Select GETDATE(), 4,@PLE  
	 insert INTO Log_Counter(Dt_Log,Id_Counter,Value)  
	 Select GETDATE(), 5,@SQLCompilations  
	 insert INTO Log_Counter(Dt_Log,Id_Counter,Value)  
	 Select GETDATE(), 6,@PS  

END



---------------------------------------------------------


GO
IF (OBJECT_ID('[dbo].[stpCheckList_Counters]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Counters]
GO

CREATE PROCEDURE [dbo].[stpCheckList_Counters]
AS
BEGIN
	SET NOCOUNT ON

	TRUNCATE TABLE [dbo].[CheckList_Counters]
	TRUNCATE TABLE [dbo].[CheckList_Counters_Email]

		IF NOT EXISTS (SELECT Fl_Enabled FROM CheckList_Parameter WHERE Nm_Procedure = 'stpCheckList_Counters' AND Fl_Enabled = 1)
	BEGIN
		RETURN
	END


	DECLARE @Dt_Log DATETIME
	SET @Dt_Log = CAST(GETDATE()-1 AS DATE)

		
	INSERT INTO [dbo].[CheckList_Counters]( [Hour], [Nm_Counter], [AVG] )
	SELECT DATEPART(hh, [Dt_Log]) AS [Hour], [Nm_Counter], AVG(CAST([Value] as bigint)) AS [AVG]
	FROM [dbo].[Log_Counter] A
		JOIN [dbo].[SQL_Counter] B ON A.[Id_Counter] = B.[Id_Counter]
	WHERE [Dt_Log] >= DATEADD(hh, 7, @Dt_Log) AND [Dt_Log] < DATEADD(hh, 23, @Dt_Log)   
	GROUP BY DATEPART(hh, [Dt_Log]), [Nm_Counter]

	INSERT INTO [dbo].[CheckList_Counters]( [Hour], [Nm_Counter], [AVG] )	
	SELECT DATEPART(HH, [StartTime]), 'Qtd Slow Queries', COUNT(*)
	FROM [dbo].[Queries_Profile]
	WHERE	[StartTime] >= @Dt_Log AND [StartTime] < @Dt_Log + 1
			AND DATEPART(HH, [StartTime]) >= 7 AND DATEPART(HH, [StartTime]) < 23
	GROUP BY DATEPART(HH, [StartTime])
	
	INSERT INTO [dbo].[CheckList_Counters]( [Hour], [Nm_Counter], [AVG] )	
	SELECT DATEPART(HH, [StartTime]), 'Reads Slow Queries', SUM(CAST(Reads AS BIGINT))
	FROM [dbo].[Queries_Profile]
	WHERE	[StartTime] >= @Dt_Log AND [StartTime] < @Dt_Log + 1
			AND DATEPART(HH, [StartTime]) >= 7 AND DATEPART(HH, [StartTime]) < 23
	GROUP BY DATEPART(HH, [StartTime])

	
	IF NOT EXISTS (SELECT TOP 1 NULL FROM [dbo].[CheckList_Counters])
	BEGIN
		INSERT INTO [dbo].[CheckList_Counters]( [Hour], [Nm_Counter], [AVG] )
		SELECT NULL, 'Without Information about Counters', NULL
	END
		
	INSERT INTO [dbo].[CheckList_Counters_Email]
	SELECT	ISNULL(CAST(U.[Hour]					AS VARCHAR), '-')	AS [Hour], 
			ISNULL(CAST(U.[BatchRequests]			AS VARCHAR), '-')	AS [BatchRequests],
			ISNULL(CAST(U.[CPU]						AS VARCHAR), '-')	AS [CPU],
			ISNULL(CAST(U.[Page Life Expectancy]	AS VARCHAR), '-')	AS [Page_Life_Expectancy],
			ISNULL(CAST(U.[SQL_Compilations]		AS VARCHAR), '-')	AS [SQL_Compilations], 
			ISNULL(CAST(U.[User_Connection]			AS VARCHAR), '-')	AS [User_Connection],
			ISNULL(CAST(U.[Reads Slow Queries]		AS VARCHAR), '-')	AS [Qtd Slow Queries], 
			ISNULL(CAST(U.[Reads Slow Queries]	AS VARCHAR), '-')	AS [Reads Slow Queries],
			ISNULL(CAST(U.[Page Splits/sec]			AS VARCHAR), '-')	AS [Page Splits/sec]
	FROM [dbo].[CheckList_Counters] AS C
	PIVOT	(
				SUM([AVG]) 
				FOR [Nm_Counter] IN (	[BatchRequests], [CPU], [Page Life Expectancy],[SQL_Compilations], 
										[User_Connection], [Qtd Slow Queries], [Reads Slow Queries],[Page Splits/sec])
			) AS U
END


GO
IF (OBJECT_ID('[dbo].[stpCheckList_Index_Fragmentation]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Index_Fragmentation]
GO
CREATE PROCEDURE [dbo].[stpCheckList_Index_Fragmentation]
AS
BEGIN
	SET NOCOUNT ON

	TRUNCATE TABLE [dbo].CheckList_Index_Fragmentation_History

	IF NOT EXISTS (SELECT Fl_Enabled FROM CheckList_Parameter WHERE Nm_Procedure = 'stpCheckList_Index_Fragmentation' AND Fl_Enabled = 1)
	BEGIN
		RETURN
	END
	
	DECLARE @Max_Dt_Log DATETIME

	SELECT @Max_Dt_Log = MAX(Dt_Log) FROM [dbo].vwIndex_Fragmentation_History
		
	INSERT INTO [dbo].CheckList_Index_Fragmentation_History (	[Dt_Log], [Nm_Server], [Nm_Database], [Nm_Table], [Nm_Index], 
															[Avg_Fragmentation_In_Percent], [Page_Count], [Fill_Factor], [Fl_Compression] )
	SELECT	[Dt_Log], [Nm_Server], [Nm_Database], [Nm_Table], [Nm_Index], 
			[Avg_Fragmentation_In_Percent], [Page_Count], [Fill_Factor], [Fl_Compression]
	FROM [dbo].vwIndex_Fragmentation_History
	WHERE	CAST([Dt_Log] AS DATE) = CAST(@Max_Dt_Log AS DATE)
			AND [Avg_Fragmentation_In_Percent] > 10
			AND [Page_Count] > 1000
	
	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].CheckList_Index_Fragmentation_History (	[Dt_Log], [Nm_Server], [Nm_Database], [Nm_Table], [Nm_Index], 
																[Avg_Fragmentation_In_Percent], [Page_Count], [Fill_Factor], [Fl_Compression] )
		SELECT NULL, NULL, 'Without Information about Index with more than 10% of Fragmentarion', NULL, NULL, NULL, NULL, NULL, NULL
	END
END


GO



if object_id('stpLoad_Waits_Stats_History') is not null
	drop procedure stpLoad_Waits_Stats_History
GO
CREATE procedure [dbo].stpLoad_Waits_Stats_History
AS
declare @Waits_Before table (WaitType varchar(60), WaitCount bigint, Id_Store int)
declare @Id_Store int

select @Id_Store = Id_Store
from Waits_Stats_History A
	join (select max(Id_Waits_Stats_History)  Id_Waits_Stats_History
	from Waits_Stats_History) B on A.Id_Waits_Stats_History = B.Id_Waits_Stats_History

insert into @Waits_Before
select A.WaitType,A.WaitCount,A.Id_Store
from Waits_Stats_History A
	join (select [WaitType], max(Id_Waits_Stats_History) Id_Waits_Stats_History
		from Waits_Stats_History
		group by [WaitType] ) B on A.Id_Waits_Stats_History = B.Id_Waits_Stats_History
		
;WITH Waits AS
    (SELECT
        wait_type,
        wait_time_ms / 1000.0 AS WaitS,
        (wait_time_ms - signal_wait_time_ms) / 1000.0 AS ResourceS,
        signal_wait_time_ms / 1000.0 AS SignalS,
        waiting_tasks_count AS WaitCount,
        100.0 * wait_time_ms / SUM (wait_time_ms) OVER() AS Percentage,
        ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS RowNum
    FROM sys.dm_os_wait_stats
    WHERE [wait_type] NOT IN (
        N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR',
        N'BROKER_TASK_STOP', N'BROKER_TO_FLUSH',
        N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
        N'CHKPT', N'CLR_AUTO_EVENT',
        N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE',
 
        -- Maybe uncomment these four if you have mirroring issues
        N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE',
        N'DBMIRROR_WORKER_QUEUE', N'DBMIRRORING_CMD',
 
        N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC', N'FSAGENT',
        N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
 
        -- Maybe uncomment these six if you have AG issues
        N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
        N'HADR_LOGCAPTURE_WAIT', N'HADR_NOTIFICATION_DEQUEUE',
        N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
 
        N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP',
        N'LOGMGR_QUEUE', N'MEMORY_ALLOCATION_EXT',
        N'ONDEMAND_TASK_QUEUE',
        N'PREEMPTIVE_XE_GETTARGETSTATE',
        N'PWAIT_ALL_COMPONENTS_INITIALIZED',
        N'PWAIT_DIRECTLOGCONSUMER_GETNEXT',
        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', N'QDS_ASYNC_QUEUE',
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
        N'QDS_SHUTDOWN_QUEUE', N'REDO_THREAD_PENDING_WORK',
        N'REQUEST_FOR_DEADLOCK_SEARCH', N'RESOURCE_QUEUE',
        N'SERVER_IDLE_CHECK', N'SLEEP_BPOOL_FLUSH',
        N'SLEEP_DBSTARTUP', N'SLEEP_DCOMSTARTUP',
        N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY',
        N'SLEEP_MASTERUPGRADED', N'SLEEP_MSDBSTARTUP',
        N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT',
        N'SP_SERVER_DIAGNOSTICS_SLEEP', N'SQLTRACE_BUFFER_FLUSH',
        N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
        N'SQLTRACE_WAIT_ENTRIES', N'WAIT_FOR_RESULTS',
        N'WAITFOR', N'WAITFOR_TASKSHUTDOWN',
        N'WAIT_XTP_RECOVERY',
        N'WAIT_XTP_HOST_WAIT', N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
        N'WAIT_XTP_CKPT_CLOSE', N'XE_DISPATCHER_JOIN',
        N'XE_DISPATCHER_WAIT', N'XE_TIMER_EVENT','SOS_WORK_DISPATCHER','XE_LIVE_TARGET_TVF','HADR_FABRIC_CALLBACK')
		AND [waiting_tasks_count] > 0
)
INSERT INTO Waits_Stats_History(WaitType,Wait_S,Resource_S,Signal_S,WaitCount,Percentage,Id_Store)
SELECT
    MAX ([W1].[wait_type]) AS [WaitType],
    CAST (MAX ([W1].[WaitS]) AS DECIMAL (16,2)) AS [Wait_S],
    CAST (MAX ([W1].[ResourceS]) AS DECIMAL (16,2)) AS [Resource_S],
    CAST (MAX ([W1].[SignalS]) AS DECIMAL (16,2)) AS [Signal_S],
    MAX ([W1].[WaitCount]) AS [WaitCount],
    CAST (MAX ([W1].[Percentage]) AS DECIMAL (5,2)) AS [Percentage],
	 isnull(@Id_Store,0) + 1
FROM [Waits] AS [W1]
INNER JOIN [Waits] AS [W2]  ON [W2].[RowNum] <= [W1].[RowNum]
GROUP BY [W1].[RowNum]
HAVING     CAST (MAX ([W1].[Percentage]) AS DECIMAL (5,2)) > 1

--HAVING SUM (W2.Percentage) - W1.Percentage < 95 -- percentage threshold


--INSERT INTO Waits_Stats_History(WaitType,Wait_S,Resource_S,Signal_S,WaitCount,Percentage,Id_Store)
--SELECT  
--    W1.wait_type AS WaitType, 
--    CAST (W1.WaitS AS DECIMAL(14, 2)) AS Wait_S,
--    CAST (W1.ResourceS AS DECIMAL(14, 2)) AS Resource_S,
--    CAST (W1.SignalS AS DECIMAL(14, 2)) AS Signal_S,
--    W1.WaitCount AS WaitCount,
--    CAST (W1.Percentage AS DECIMAL(4, 2)) AS Percentage, isnull(@Id_Store,0) + 1

--FROM Waits AS W1
--    INNER JOIN Waits AS W2 ON W2.RowNum <= W1.RowNum
--GROUP BY W1.RowNum, W1.wait_type, W1.WaitS, W1.ResourceS, W1.SignalS, W1.WaitCount, W1.Percentage
--HAVING SUM (W2.Percentage) - W1.Percentage < 95 -- percentage threshold
--OPTION (RECOMPILE); 

if exists (select null
		   from Waits_Stats_History A
			join (select [WaitType], max(Id_Waits_Stats_History) Id_Waits_Stats_History
				from Waits_Stats_History
				group by [WaitType] ) B on A.Id_Waits_Stats_History = B.Id_Waits_Stats_History
			join @Waits_Before C on A.WaitType = C.WaitType and A.WaitCount < C.WaitCount and isnull(A.Id_Store,0)  = isnull(C.Id_Store,0) +1 )
begin
	INSERT INTO Waits_Stats_History(WaitType)
	values('RESET WAITS STATS')
END
GO


if object_id('stpWaits_Stats_History') is not null
	drop procedure stpWaits_Stats_History
GO
CREATE procedure [dbo].[stpWaits_Stats_History] @Dt_Start datetime, @Dt_Final datetime
AS
BEGIN
--declare @Dt_Start datetime, @Dt_Final datetime
--select @Dt_Start = '20110505 12:00',@Dt_Final = '20110505 13:00'
 
declare @Wait_Stats table(WaitType varchar(60),Min_Id int,Max_Id int,MIN_Data datetime)
 
insert into @Wait_Stats(WaitType,Min_Id,Max_Id,MIN_Data)
select WaitType, min(Id_Waits_Stats_History) Min_Id , max(Id_Waits_Stats_History) Max_Id ,min(Dt_Log) MIN_Data
from Waits_Stats_History (nolock)
where Dt_Log >= @Dt_Start
and Dt_Log < @Dt_Final
group by WaitType
 
if exists (select null from @Wait_Stats where WaitType = 'RESET WAITS STATS')
begin

select 
'The Wait Stat Informations were cleared' WaitType, getdate() Min_Log,  getdate() Max_Log, 
	0 DIf_Wait_S,
	0 DIf_Resource_S,        0 DIf_Signal_S,0 DIf_WaitCount,
	0 DIf_Percentage, 0 Last_Percentage
/*
select 'Houve uma limpeza das Waits Stats após a coleta do dia: ' + cast(MIN_Data as varchar) +
' | Favor alterar o período para que não inclua essa limpeza.'
from @Wait_Stats where WaitType = 'RESET WAITS STATS'
 */
return
End

select A.WaitType, B.Dt_Log Min_Log, C.Dt_Log Max_Log, C.Wait_S - B.Wait_S DIf_Wait_S,
C.Resource_S - B.Resource_S DIf_Resource_S,        C.Signal_S - B.Signal_S DIf_Signal_S,C.WaitCount - B.WaitCount DIf_WaitCount,
C.Percentage - B.Percentage DIf_Percentage, B.Percentage Last_Percentage
from @Wait_Stats A
join Waits_Stats_History B on A.Min_Id = B.Id_Waits_Stats_History -- Primeiro
join Waits_Stats_History C on A.Max_Id = C.Id_Waits_Stats_History -- Último
 
 END

GO


GO
IF (OBJECT_ID('[dbo].[stpCheckList_Waits_Stats]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Waits_Stats]
GO

CREATE PROCEDURE [dbo].[stpCheckList_Waits_Stats]
AS
BEGIN
	SET NOCOUNT ON

	TRUNCATE TABLE [dbo].[CheckList_Waits_Stats]

	IF NOT EXISTS (SELECT Fl_Enabled FROM CheckList_Parameter WHERE Nm_Procedure = 'stpCheckList_Waits_Stats' AND Fl_Enabled = 1)
	BEGIN
		RETURN
	END

	DECLARE @Dt_Log DATETIME, @Dt_Start DATETIME, @Dt_End DATETIME
	SET @Dt_Log = CAST(GETDATE()-1 AS DATE)
	
	SELECT @Dt_Start = DATEADD(hh, 7, @Dt_Log), @Dt_End = DATEADD(hh, 23, @Dt_Log)   


	INSERT INTO [dbo].[CheckList_Waits_Stats](	[WaitType], [Min_Log], [Max_Log], [DIf_Wait_S], [DIf_Resource_S], [DIf_Signal_S], 
												[DIf_WaitCount], [DIf_Percentage], [Last_Percentage] )
	EXEC [dbo].[stpWaits_Stats_History] @Dt_Start, @Dt_End
	
	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_Waits_Stats](	[WaitType], [Min_Log], [Max_Log], [DIf_Wait_S], [DIf_Resource_S], [DIf_Signal_S], 
													[DIf_WaitCount], [DIf_Percentage], [Last_Percentage] )
		SELECT 'Without Information about Waits Stats.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
	END
END



GO
IF (OBJECT_ID('[dbo].[stpCheckList_SQLServer_ErrorLog]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_SQLServer_ErrorLog]
GO

CREATE PROCEDURE [dbo].[stpCheckList_SQLServer_ErrorLog]
AS
BEGIN
	SET NOCOUNT ON

	IF NOT EXISTS (SELECT Fl_Enabled FROM CheckList_Parameter WHERE Nm_Procedure = 'stpCheckList_SQLServer_ErrorLog' AND Fl_Enabled = 1)
	BEGIN
		RETURN
	END

	SET DATEFORMAT MDY

	IF (OBJECT_ID('tempdb..#TempLog') IS NOT NULL)
		DROP TABLE #TempLog
	
	CREATE TABLE #TempLog (
		[LogDate]		DATETIME,
		[ProcessInfo]	NVARCHAR(50),
		[Text]			NVARCHAR(MAX)
	)

	IF (OBJECT_ID('tempdb..#logF') IS NOT NULL)
		DROP TABLE #logF
	
	CREATE TABLE #logF (
		[ArchiveNumber] INT,
		[LogDate]		DATETIME,
		[LogSize]		INT 
	)

	INSERT INTO #logF  
	EXEC sp_enumerrorlogs
	
	DELETE FROM #logF
	WHERE LogDate < GETDATE()-2

	DECLARE @TSQL NVARCHAR(2000), @lC INT

	SELECT @lC = MIN(ArchiveNumber) FROM #logF

	WHILE @lC IS NOT NULL
	BEGIN
		  INSERT INTO #TempLog
		  EXEC sp_readerrorlog @lC
		  SELECT @lC = MIN(ArchiveNumber) FROM #logF
		  WHERE ArchiveNumber > @lC
	END
	
	TRUNCATE TABLE [dbo].[CheckList_SQLServer_ErrorLog]
	TRUNCATE TABLE [dbo].[CheckList_SQLServer_LoginFailed]
	TRUNCATE TABLE [dbo].[CheckList_SQLServer_LoginFailed_Email]

	-- Login Failed
	INSERT INTO [dbo].[CheckList_SQLServer_LoginFailed]( [Text], [Qt_Error] )
	SELECT RTRIM([Text]), COUNT(*)
	FROM #TempLog
	WHERE [LogDate] >= GETDATE()-1
		AND [Text] LIKE '%Login failed for user%'
	GROUP BY [Text]
	
	IF (@@ROWCOUNT <> 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_SQLServer_LoginFailed_Email]( [Nr_Order], [Text], [Qt_Error] )
		SELECT TOP 10 1, [Text], [Qt_Error]
		FROM [dbo].[CheckList_SQLServer_LoginFailed]
		ORDER BY [Qt_Error] DESC

		INSERT INTO [dbo].[CheckList_SQLServer_LoginFailed_Email]( [Nr_Order], [Text], [Qt_Error] )
		SELECT 2, 'TOTAL', SUM([Qt_Error])
		FROM [dbo].[CheckList_SQLServer_LoginFailed]
	END
	ELSE
	BEGIN
		INSERT INTO [dbo].[CheckList_SQLServer_LoginFailed_Email]( [Text], [Qt_Error] )
		SELECT 'Without Information about Login Failed', NULL
	END
	
	-- Error Log
	INSERT INTO [dbo].[CheckList_SQLServer_ErrorLog]( [Dt_Log], [ProcessInfo], [Text] )
	SELECT [LogDate], [ProcessInfo], [Text]
	FROM #TempLog
	WHERE [LogDate] >= GETDATE()-1
		AND [ProcessInfo] <> 'Backup'
		AND [Text] NOT LIKE '%CHECKDB%'
		AND [Text] NOT LIKE '%Trace%'
		AND [Text] NOT LIKE '%IDR%'
		AND [Text] NOT LIKE 'AppDomain%'
		AND [Text] NOT LIKE 'Unsafe assembly%'
		AND [Text] NOT LIKE '%Login failed for user%'
		AND [Text] NOT LIKE '%Error:%Severity:%State:%'
		AND [Text] NOT LIKE '%Erro:%Gravidade:%Estado:%'
		AND [Text] NOT LIKE '%No user action is required.%'
		AND [Text] NOT LIKE '%Backup%'
		
	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[CheckList_SQLServer_ErrorLog]( [Dt_Log], [ProcessInfo], [Text] )
		SELECT NULL, NULL, 'Without Information about the Error Log'
	END
END

GO


GO
IF (OBJECT_ID('[dbo].[Checklist_Alert]') IS NOT NULL)
	DROP TABLE [dbo].[Checklist_Alert]

CREATE TABLE [dbo].[Checklist_Alert] (
	[Nm_Alert] VARCHAR(200) NULL,
	[Ds_Message] VARCHAR(200) NULL,
	[Dt_Alert] DATETIME,
	[Run_Duration] VARCHAR(18)
)

IF (OBJECT_ID('[dbo].[Checklist_Alert_Sem_Clear]') IS NOT NULL)
	DROP TABLE [dbo].[Checklist_Alert_Sem_Clear]

CREATE TABLE [dbo].[Checklist_Alert_Sem_Clear] (
	[Nm_Alert] VARCHAR(200) NULL,
	[Ds_Message] VARCHAR(200) NULL,
	[Dt_Alert] DATETIME,
	[Run_Duration] VARCHAR(18)
)

GO

IF (OBJECT_ID('[dbo].[stpCheckList_Alert]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_Alert]	
GO

CREATE PROCEDURE [dbo].[stpCheckList_Alert]
AS
BEGIN
	SET NOCOUNT ON

	TRUNCATE TABLE [dbo].[Checklist_Alert_Sem_Clear]

	IF NOT EXISTS (SELECT Fl_Enabled FROM CheckList_Parameter WHERE Nm_Procedure = 'stpCheckList_Alert' AND Fl_Enabled = 1)
	BEGIN
		RETURN
	END
	
	IF(OBJECT_ID('tempdb..#Checklist_Alert') IS NOT NULL)
		DROP TABLE #Checklist_Alert

	CREATE TABLE #Checklist_Alert (
		Id_Alert INT,
		Id_Alert_Parameter INT,
		Nm_Alert VARCHAR(200),
		Ds_Message VARCHAR(2000),
		Dt_Alert DATETIME,
		Fl_Type BIT,
		Run_Duration VARCHAR(18)
	)

	DECLARE @Dt_Log DATETIME = DATEADD(HOUR, -24, GETDATE())

	INSERT INTO #Checklist_Alert
	SELECT [Id_Alert], A.[Id_Alert_Parameter], [Nm_Alert], [Ds_Message], [Dt_Alert], [Fl_Type], NULL	
	FROM [dbo].[Alert] A WITH(NOLOCK)
	JOIN [dbo].[Alert_Parameter] B WITH(NOLOCK) ON A.Id_Alert_Parameter = B.Id_Alert_Parameter
	WHERE [Dt_Alert] > @Dt_Log

	IF(OBJECT_ID('tempdb..#Checklist_Alert_Clear') IS NOT NULL)
		DROP TABLE #Checklist_Alert_Clear

	select A.Id_Alert, A.Dt_Alert AS Dt_Clear, MAX(B.Dt_Alert) AS Dt_Alert
	into #Checklist_Alert_Clear
	from #Checklist_Alert A
	JOIN [dbo].[Alert_Parameter] C WITH(NOLOCK) ON A.Id_Alert_Parameter = C.Id_Alert_Parameter
	JOIN [dbo].[Alert] B ON A.Id_Alert_Parameter = C.Id_Alert_Parameter and B.Fl_Type = 1 and B.Dt_Alert < A.Dt_Alert	
	where A.Fl_Type = 0
	group by A.Id_Alert, A.Dt_Alert

	UPDATE A
	SET	A.Run_Duration =
			RIGHT('00' + CAST((DATEDIFF(SECOND,B.Dt_Alert, B.Dt_Clear) / 86400) AS VARCHAR), 2) + ' Dia(s) ' +	-- Dia
			RIGHT('00' + CAST((DATEDIFF(SECOND,B.Dt_Alert, B.Dt_Clear) / 3600 % 24) AS VARCHAR), 2) + ':' +	-- Hour
			RIGHT('00' + CAST((DATEDIFF(SECOND,B.Dt_Alert, B.Dt_Clear) / 60 % 60) AS VARCHAR), 2) + ':' +		-- Minutos
			RIGHT('00' + CAST((DATEDIFF(SECOND,B.Dt_Alert, B.Dt_Clear) % 60) AS VARCHAR), 2)					-- Segundos	
	from #Checklist_Alert A
	join #Checklist_Alert_Clear B on A.Id_Alert = B.Id_Alert
	
	-- Limpa os dados antigos da tabela do CheckList	
	TRUNCATE TABLE [dbo].[Checklist_Alert]
	
	INSERT INTO [dbo].[Checklist_Alert]
	SELECT Nm_Alert, Ds_Message, Dt_Alert, Run_Duration 
	FROM #Checklist_Alert

	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[Checklist_Alert] ( [Nm_Alert], [Ds_Message], [Dt_Alert], [Run_Duration] )
		SELECT 'Without Information About Alert Last Day', NULL, NULL, NULL
	END
	
	INSERT INTO [dbo].[Checklist_Alert_Sem_Clear]
	SELECT	[Nm_Alert], [Ds_Message], [Dt_Alert],
			RIGHT('00' + CAST((DATEDIFF(SECOND,Dt_Alert, GETDATE()) / 86400) AS VARCHAR), 2) + ' Dia(s) ' +	-- Dia
			RIGHT('00' + CAST((DATEDIFF(SECOND,Dt_Alert, GETDATE()) / 3600 % 24) AS VARCHAR), 2) + ':' +		-- Hour
			RIGHT('00' + CAST((DATEDIFF(SECOND,Dt_Alert, GETDATE()) / 60 % 60) AS VARCHAR), 2) + ':' +			-- Minutos
			RIGHT('00' + CAST((DATEDIFF(SECOND,Dt_Alert, GETDATE()) % 60) AS VARCHAR), 2) AS [Run_Duration]	-- Segundos	
	FROM [dbo].[Alert] A WITH(NOLOCK)
	JOIN [dbo].[Alert_Parameter] B WITH(NOLOCK) ON A.Id_Alert_Parameter = B.Id_Alert_Parameter
	WHERE	[Id_Alert] = ( SELECT MAX([Id_Alert]) FROM [dbo].[Alert] B WITH(NOLOCK) WHERE A.Id_Alert_Parameter = B.Id_Alert_Parameter )
			AND B.[Fl_Clear] = 1	--  CLEAR
			AND A.[Fl_Type] = 1		-- ALERTA
	 
	IF (@@ROWCOUNT = 0)
	BEGIN
		INSERT INTO [dbo].[Checklist_Alert_Sem_Clear] ( [Nm_Alert], [Ds_Message], [Dt_Alert], [Run_Duration] )
		SELECT 'Without Information about Alert Without CLEAR', NULL, NULL, NULL
	END
END
GO


IF (OBJECT_ID('[dbo].[stpCheckList_AutoGrowth]') IS NOT NULL)
	DROP PROCEDURE [dbo].[stpCheckList_AutoGrowth]	
GO

CREATE PROCEDURE [dbo].[stpCheckList_AutoGrowth]
AS
BEGIN
	SET NOCOUNT ON
	
	TRUNCATE TABLE [dbo].[CheckList_Database_Auto_Growth]

	IF NOT EXISTS (SELECT Fl_Enabled FROM CheckList_Parameter WHERE Nm_Procedure = 'stpCheckList_AutoGrowth' AND Fl_Enabled = 1)
	BEGIN
		RETURN
	END

	DECLARE @Ds_Arquivo_Trace VARCHAR(500) = (SELECT [path] FROM sys.traces WHERE is_default = 1);
	DECLARE @Index INT = PATINDEX('%\%', REVERSE(@Ds_Arquivo_Trace));
	DECLARE @Nm_Arquivo_Trace VARCHAR(500) = LEFT(@Ds_Arquivo_Trace, LEN(@Ds_Arquivo_Trace) - @Index) + '\log.trc';
	
	DECLARE @Dt_Log DATETIME = DATEADD(HOUR, -24, GETDATE())
	
	if @Nm_Arquivo_Trace is not null
	INSERT INTO [dbo].[CheckList_Database_Auto_Growth] ([Nm_Database],[Filename],[Duration],[StartTime],[EndTime],[Growth_Size],[ApplicationName],[HostName],[LoginName])
	SELECT A.DatabaseName,
		   A.[Filename],
		   (A.Duration / 1000000) AS Duration,
		   A.StartTime,
		   A.EndTime,
		   (A.IntegerData * 8.0 / 1024) AS GrowthSize,
		   A.ApplicationName,
		   A.HostName,
		   A.LoginName
	FROM::fn_trace_gettable(@Nm_Arquivo_Trace, DEFAULT) A
	WHERE A.EventClass >= 92
		  AND A.EventClass <= 95
		   AND StartTime > @Dt_Log
		  AND A.ServerName = @@servername
		  AND (A.Duration / 1000000) >= 1	
	ORDER BY A.StartTime DESC;

	IF ( @@ROWCOUNT = 0 )
	BEGIN
		INSERT INTO [dbo].[CheckList_Database_Auto_Growth] ([Nm_Database],[Filename],[Duration],[StartTime],[EndTime],[Growth_Size],[ApplicationName],[HostName],[LoginName])
		SELECT	'Without Information about Auto Growth', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
	END
END
GO


/*******************************************************************************************************************************
--	Database CheckList
*******************************************************************************************************************************/

IF OBJECT_ID('[dbo].[stpSend_Mail_CheckList_DBA]') is not null
	DROP PROCEDURE [dbo].stpSend_Mail_CheckList_DBA

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	
CREATE PROCEDURE [dbo].stpSend_Mail_CheckList_DBA
AS
BEGIN


SET NOCOUNT ON

	DECLARE @Id_Alert_Parameter SMALLINT, @Fl_Enable BIT, @Fl_Type TINYINT, @Vl_Parameter SMALLINT,@Ds_Email VARCHAR(500),@Ds_Profile_Email VARCHAR(200),@Dt_Now DATETIME,@Vl_Parameter_2 INT,
		@Ds_Email_Information_1_ENG VARCHAR(200), @Ds_Email_Information_2_ENG VARCHAR(200), @Ds_Email_Information_1_PTB VARCHAR(200), @Ds_Email_Information_2_PTB VARCHAR(200),
		@Ds_Message_Alert_ENG varchar(1000),@Ds_Message_Clear_ENG varchar(1000),@Ds_Message_Alert_PTB varchar(1000),@Ds_Message_Clear_PTB varchar(1000), @Ds_Subject VARCHAR(500)
	
	DECLARE @Company_Link  VARCHAR(4000),@Line_Space VARCHAR(4000),@Header_Default VARCHAR(4000),@Header VARCHAR(4000),@Fl_Language BIT,@Final_HTML VARCHAR(MAX),@HTML VARCHAR(MAX)		

	SET @Final_HTML = ''					
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
	FROM [dbo].Alert_Parameter 
	WHERE Nm_Alert = 'Database CheckList '
												 
	-- Get HTML Informations
	SELECT @Company_Link = Company_Link,
		@Line_Space = Line_Space,
		@Header_Default = Header
	FROM HTML_Parameter		

	/***********************************************************************************************************************************
	--	SQL Server Availability Time
	***********************************************************************************************************************************/
		
	IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
		DROP TABLE ##Email_HTML
						
	SELECT	/*CASE 
							WHEN	(RTRIM(CONVERT(CHAR(17), DATEDIFF(SECOND, CONVERT(DATETIME, [Create_Date]), GETDATE()) / 86400)) = 0) OR
									(RTRIM(CONVERT(CHAR(17), DATEDIFF(SECOND, CONVERT(DATETIME, [Create_Date]), GETDATE()) / 86400)) > 365)
								THEN ' bgcolor=yellow>' 
								ELSE '' 
						END + */
						RTRIM(CONVERT(CHAR(17), DATEDIFF(SECOND, CONVERT(DATETIME, [Create_Date]), GETDATE()) / 86400)) + ' Dia(s) ' +
						RIGHT('00' + RTRIM(CONVERT(CHAR(7), DATEDIFF(SECOND, CONVERT(DATETIME, [Create_Date]), GETDATE()) % 86400 / 3600)), 2) + ' Hour(s) ' +
						RIGHT('00' + RTRIM(CONVERT(CHAR(7), DATEDIFF(SECOND, CONVERT(DATETIME, [Create_Date]), GETDATE()) % 86400 % 3600 / 60)), 2) + ' Minuto(s) '	AS [Availability Time]
	INTO ##Email_HTML	
	FROM [sys].[databases]
	WHERE [Database_Id] = 2

	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Tempo de Disponibilidade do SQL Server')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','SQL Server Availability Time')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML', -- varchar(max)
		@Ds_Alinhamento  = 'center',			
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	IF EXISTS(SELECT null FROM ##Email_HTML)
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		
	
	/***********************************************************************************************************************************
	--	Disk Space
	***********************************************************************************************************************************/
			
	IF ( OBJECT_ID('tempdb..##Email_HTML2') IS NOT NULL )
		DROP TABLE ##Email_HTML2						

	SELECT	DriveName [Drive Name], 
			ISNULL(CAST([TotalSize_GB]		AS VARCHAR), '-')	AS [Total Size (GB)], 
			ISNULL(CAST([SpaceUsed_GB]		AS VARCHAR), '-')	AS [Space Used (GB)],
			ISNULL(CAST([FreeSpace_GB]		AS VARCHAR), '-')	AS [Free Space (GB)], 
			ISNULL(CAST([SpaceUsed_Percent] AS VARCHAR), '-')	AS [Space Used (%)] 
	INTO ##Email_HTML2
	FROM [dbo].[CheckList_Disk_Space]

	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Espaço em Disco')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Disk Space')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML2', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Drive Name]',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	IF EXISTS(SELECT null FROM ##Email_HTML2)
		SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		
	        
			
              
	/***********************************************************************************************************************************
	--	Data Files
	***********************************************************************************************************************************/
					
	IF ( OBJECT_ID('tempdb..##Email_HTML3') IS NOT NULL )
		DROP TABLE ##Email_HTML3						

		SELECT	TOP 5
			[Nm_Database] [Database], 
			ISNULL([Logical_Name], '-')							AS [Logical Name], 
			[Total_Reserved]		AS [Total Reserved (MB)], 
			[Total_Used]			AS [Total Used (MB)],
			[Free_Space (MB)]	AS [Free Space (MB)], 
			[Free_Space (%)]	AS [Free Space (%)],
			[MaxSize]		AS [Max Size], 
			[Growth]	AS [Growth]
		INTO ##Email_HTML3
		FROM  [dbo].[CheckList_Data_Files]
		ORDER BY [Total_Reserved] DESC,[Total_Used] DESC
		
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 5 - Informações dos Arquivos de Dados (MDF e NDF)')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 5 - Data File Informations (MDF and NDF)')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML3', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Total Reserved (MB)] DESC,[Total Used (MB)] DESC',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	IF EXISTS(SELECT null FROM ##Email_HTML3)
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		


	/***********************************************************************************************************************************
	--	 Log Files
	***********************************************************************************************************************************/

	IF ( OBJECT_ID('tempdb..##Email_HTML4') IS NOT NULL )
	DROP TABLE ##Email_HTML4						

	SELECT	TOP 5
			[Nm_Database] [Database], 
			ISNULL([Logical_Name], '-')							AS [Logical Name], 
			[Total_Reserved]	AS [Total Reserved (MB)], 
			[Total_Used]		AS [Total Used (MB)],
			[Free_Space (MB)]	AS [Free Space (MB)], 
			[Free_Space (%)]	AS [Free Space (%)],
			[MaxSize]			AS [Max Size], 
			[Growth]			AS [Growth]
	INTO ##Email_HTML4
	FROM  [dbo].[CheckList_Log_Files]
	ORDER BY [Total_Reserved] DESC,[Total_Used] DESC


	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 5 - Informações dos Arquivos de Log (LDF)')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 5 - Log File Informations (LDF)')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML4', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Total Reserved (MB)] DESC,[Total Used (MB)] DESC',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	IF EXISTS(SELECT null FROM ##Email_HTML4)
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		
	
	/***********************************************************************************************************************************
	--	Database Growth 
	***********************************************************************************************************************************/
	IF ( OBJECT_ID('tempdb..##Email_HTML5') IS NOT NULL )
		DROP TABLE ##Email_HTML5	
		
		SELECT 
			[Nm_Server] [Server],
			[Nm_Database] [Database],
			[Actual_Size] [Actual Size (MB)],
			[Growth_1_day] [Growth 1 Day (MB)],
			[Growth_15_days] [Growth 15 Days (MB)],
			[Growth_30_days] [Growth 30 Days (MB)],
			[Growth_60_days] [Growth 60 Days (MB)]
		INTO ##Email_HTML5
		FROM (
			SELECT	TOP 10
					[Nm_Server], 
					[Nm_Database], 
					ISNULL([Actual_Size], 0) AS [Actual_Size],
					ISNULL([Growth_1_day] , 0) AS [Growth_1_day],
					ISNULL([Growth_15_days] , 0) AS [Growth_15_days], 
					ISNULL([Growth_30_days], 0) AS [Growth_30_days],
					ISNULL([Growth_60_days], 0) AS [Growth_60_days]
			FROM [dbo].[CheckList_Database_Growth_Email]
			WHERE [Nm_Server] IS NOT NULL		
				
			UNION
				
			SELECT	[Nm_Server], 
					[Nm_Database], 
					ISNULL([Actual_Size], 0) AS [Actual_Size],
					ISNULL([Growth_1_day] , 0) AS [Growth_1_day],
					ISNULL([Growth_15_days] , 0) AS [Growth_15_days], 
					ISNULL([Growth_30_days], 0) AS [Growth_30_days],
					ISNULL([Growth_60_days], 0) AS [Growth_60_days]
			FROM [dbo].[CheckList_Database_Growth_Email]
			WHERE [Nm_Server] IS NULL		) A	


		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Crescimento das Bases')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Database Growth')		
		END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML5', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Server] DESC,[Growth 1 Day (MB)] DESC,[Actual Size (MB)] DESC',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	IF EXISTS(SELECT null FROM ##Email_HTML5)
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		
		                       

	/***********************************************************************************************************************************
	--	Table Growth
	***********************************************************************************************************************************/

	IF ( OBJECT_ID('tempdb..##Email_HTML6') IS NOT NULL )
		DROP TABLE ##Email_HTML6
		
		SELECT 
			[Nm_Server] [Server],
			[Nm_Database] [Database],
			[Nm_Table] [Table],
			[Actual_Size] [Actual Size (MB)],
			[Growth_1_day] [Growth 1 Day (MB)],
			[Growth_15_days] [Growth 15 Days (MB)],
			[Growth_30_days] [Growth 30 Days (MB)],
			[Growth_60_days] [Growth 60 Days (MB)]
		INTO ##Email_HTML6
		FROM (
						SELECT	TOP 10
								[Nm_Server], 
								[Nm_Database], 
								ISNULL([Nm_Table], '-')					   AS [Nm_Table], 
								ISNULL([Actual_Size], 0) AS [Actual_Size],
								ISNULL([Growth_1_day] , 0) AS [Growth_1_day],
								ISNULL([Growth_15_days] , 0) AS [Growth_15_days], 
								ISNULL([Growth_30_days], 0) AS [Growth_30_days],
								ISNULL([Growth_60_days], 0) AS [Growth_60_days]
						FROM [dbo].[CheckList_Table_Growth_Email]
						WHERE [Nm_Server] IS NOT NULL		
							
						UNION ALL
				
						SELECT	[Nm_Server], 
								[Nm_Database], 
								ISNULL([Nm_Table], '-')					   AS [Nm_Table], 
								ISNULL([Actual_Size], 0) AS [Actual_Size],
								ISNULL([Growth_1_day] , 0) AS [Growth_1_day],
								ISNULL([Growth_15_days] , 0) AS [Growth_15_days], 
								ISNULL([Growth_30_days], 0) AS [Growth_30_days],
								ISNULL([Growth_60_days], 0) AS [Growth_60_days]
						FROM [dbo].[CheckList_Table_Growth_Email]
						WHERE [Nm_Server] IS NULL			) A	


		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Crescimento das Tabelas')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Table Growth')		
		END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML6', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Server] DESC,[Growth 1 Day (MB)] DESC,[Actual Size (MB)] DESC',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	IF EXISTS(SELECT null FROM ##Email_HTML6)
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		
		                       

	/***********************************************************************************************************************************
	--	Database Files  - Writes 
	***********************************************************************************************************************************/
		IF ( OBJECT_ID('tempdb..##Email_HTML7') IS NOT NULL )
		DROP TABLE ##Email_HTML7
		
		select	Nm_Database [Database],
				ISNULL(CAST(file_id AS VARCHAR), '-') AS [File ID],
				ISNULL(CAST(io_stall_write_ms AS VARCHAR), '-') AS [IO Stall Write (ms)],
				ISNULL(CAST(num_of_writes AS VARCHAR), '-') AS [Num of Writes],
				ISNULL(CAST([avg_write_stall_ms] AS VARCHAR), '-') AS [AVG Write Stall (ms)] 
		INTO ##Email_HTML7
		from [dbo].[CheckList_File_Writes]		

		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Utilização Arquivos Databases - Writes (09:00 - 18:00) ')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Database Files - Writes (09:00 - 18:00) ')		
		END		  	
	
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML7', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = 'CAST([AVG Write Stall (ms)] AS NUMERIC(15,1)) DESC',
			@Ds_Saida = @HTML OUT		 -- varchar(max)

		-- Add Mail result
		IF EXISTS(SELECT null FROM ##Email_HTML7)
		SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		
		 

	/***********************************************************************************************************************************
	--	Database Files - Reads 
	***********************************************************************************************************************************/

		IF ( OBJECT_ID('tempdb..##Email_HTML8') IS NOT NULL )
		DROP TABLE ##Email_HTML8
		
		SELECT	Nm_Database [Database],
						ISNULL(CAST(file_id AS VARCHAR), '-') AS [File ID],
						ISNULL(CAST(io_stall_read_ms AS VARCHAR), '-') AS [IO Stall Read (ms)],
						ISNULL(CAST(num_of_reads AS VARCHAR), '-') AS [Num od Reads],
						ISNULL(CAST([avg_read_stall_ms] AS VARCHAR), '-') AS [AVG Read Stall (ms)]
		INTO ##Email_HTML8
		from [dbo].[CheckList_File_Reads]

		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Utilização Arquivos Databases - Reads (09:00 - 18:00) ')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Database Files - Reads (09:00 - 18:00) ')		
		END		  	
	
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML8', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = 'CAST([AVG Read Stall (ms)] AS NUMERIC(15,1)) DESC',
			@Ds_Saida = @HTML OUT		 -- varchar(max)

		-- Add Mail result
		IF EXISTS(SELECT null FROM ##Email_HTML8)
		SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		
		 		 		
			
		/***********************************************************************************************************************************
		--	Database File Growth
		***********************************************************************************************************************************/

		IF ( OBJECT_ID('tempdb..##Email_HTML9') IS NOT NULL )
			DROP TABLE ##Email_HTML9
		
		SELECT	TOP 10
					Nm_Database [Database],
					ISNULL(CAST([Filename] AS VARCHAR), '-') AS [File Name],
					ISNULL(CAST([Duration] AS VARCHAR), '-') AS [Duration],
					ISNULL(CAST([StartTime] AS VARCHAR), '-') AS [Start Time],
					ISNULL(CAST([EndTime] AS VARCHAR), '-') AS [End Time],
					ISNULL(CAST([Growth_Size] AS VARCHAR), '-') AS [Growth Size (MB)],
					ISNULL(CAST([ApplicationName] AS VARCHAR), '-') AS [Application Name],
					ISNULL(CAST([HostName] AS VARCHAR), '-') AS [Host Name],
					ISNULL(CAST([LoginName] AS VARCHAR), '-') AS [Login Name]
		INTO ##Email_HTML9
		from [dbo].[CheckList_Database_Auto_Growth]
		ORDER BY [StartTime] DESC, [Duration] DESC


		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Crescimento Arquivos Databases')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Database File Growth')		
		END		  	
	
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML9', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Start Time] DESC, [Duration] DESC',
			@Ds_Saida = @HTML OUT		 -- varchar(max)

		
		IF EXISTS(SELECT null FROM ##Email_HTML9)
			SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		-- Add Mail result

						

	/***********************************************************************************************************************************
	--	Databases Withou Backup 
	***********************************************************************************************************************************/	
		IF ( OBJECT_ID('tempdb..##Email_HTML10') IS NOT NULL )
			DROP TABLE ##Email_HTML10
		
		SELECT	TOP 10 
				[Nm_Database] AS [Database]
		INTO ##Email_HTML10
		FROM [dbo].[CheckList_Database_Without_Backup]	
		ORDER BY [Nm_Database]		


		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Databases Sem Backup nas últimas 16 Horas')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Databases Without Backup in the Last 16 Hours')		
		END		  	
	
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML10', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Database]',
			@Ds_Saida = @HTML OUT		 -- varchar(max)
					
		IF EXISTS(SELECT null FROM ##Email_HTML10)
			SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		-- Add Mail result

			
	/***********************************************************************************************************************************
	--	Backups Executed
	***********************************************************************************************************************************/
	
		IF ( OBJECT_ID('tempdb..##Email_HTML11') IS NOT NULL )
			DROP TABLE ##Email_HTML11

		SELECT	TOP 10
				ISNULL([Database_Name],'-') AS [Database], 
				ISNULL(CONVERT(VARCHAR, [Backup_Start_Date], 120), '-') AS [Backup Start Date], 
				ISNULL(CAST([Tempo_Min] AS VARCHAR), '-')				AS [Duration (min)],
				ISNULL(CAST([Recovery_Model] AS VARCHAR), '-')			AS [Recovery Model],
				ISNULL(
					CASE [Type]
						WHEN 'D' THEN 'FULL'
						WHEN 'I' THEN 'Diferencial'
						WHEN 'L' THEN 'Log'
					END, '-')											AS [Type],
				ISNULL([Tamanho_MB], 0)				AS [Size (MB)]
		INTO ##Email_HTML11
		FROM [dbo].[CheckList_Backup_Executed]
		order by [Tamanho_MB] desc
		
		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Backup FULL e Diferencial das Bases')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Backup FULL and Differential')		
		END		  	
	
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML11', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Size (MB)] DESC',
			@Ds_Saida = @HTML OUT		 -- varchar(max)
					
		IF EXISTS(SELECT null FROM ##Email_HTML11)
			SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		-- Add Mail result             


	/***********************************************************************************************************************************
	--	Queries Running
	***********************************************************************************************************************************/ 	
		IF ( OBJECT_ID('tempdb..##Email_HTML12') IS NOT NULL )
			DROP TABLE ##Email_HTML12

		SELECT	TOP 5
				ISNULL([dd hh:mm:ss.mss], '-')									AS [dd hh:mm:ss.mss], 
				[database_name] [Database], 
				ISNULL([login_name], '-')										AS [Login Name], 
				ISNULL([host_name], '-')										AS [Host Name], 
				ISNULL(CONVERT(VARCHAR(20), [start_time], 120), '-')			AS [Start Time], 
				ISNULL([status], '-')											AS [Status], 
				ISNULL(CAST([session_id] AS VARCHAR), '-')						AS [Session ID], 
				ISNULL(CAST([blocking_session_id] AS VARCHAR), '-')				AS [Blocking Session ID], 
				ISNULL([wait_info], '-')										AS [Wait Info], 
				ISNULL(CAST([open_tran_count] AS VARCHAR), '-')					AS [Open Tran Count], 
				ISNULL(CAST([CPU] AS VARCHAR), '-')								AS [CPU], 
				ISNULL(CAST([reads] AS VARCHAR), '-')							AS [Reads], 
				ISNULL(CAST([writes] AS VARCHAR), '-')							AS [Writes], 
				ISNULL(SUBSTRING(CAST([sql_command] AS VARCHAR), 1, 150), '-')	AS [Query]		
		INTO ##Email_HTML12				
		FROM [dbo].[CheckList_Queries_Running]		
		
		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 5 - Queries em Execução a mais de 2 horas')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 5 - Queries running for more than 2 Hours')		
		END		  	
	
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML12', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Start Time]',
			@Ds_Saida = @HTML OUT		 -- varchar(max)					
	
		IF EXISTS(SELECT null FROM ##Email_HTML12)
		SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		-- Add Mail result         
		

	/***********************************************************************************************************************************
	--	Jobs Running
	***********************************************************************************************************************************/ 
		IF ( OBJECT_ID('tempdb..##Email_HTML13') IS NOT NULL )
			DROP TABLE ##Email_HTML13

		SELECT	TOP 10
				[Nm_JOB] [Job Name], 
				ISNULL(CONVERT(VARCHAR(16), [Dt_Start],120), '-')	AS [Start Date], 
				ISNULL(Duration, '-')								AS [Duration], 
				ISNULL([Nm_Step], '-')								AS [Step Name]
		INTO ##Email_HTML13
		FROM [dbo].[CheckList_Jobs_Running]	
						
		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Jobs em Execução')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Jobs Running')		
		END		  	
	
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML13', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Start Date]',
			@Ds_Saida = @HTML OUT		 -- varchar(max)					
	
		IF EXISTS(SELECT null FROM ##Email_HTML13)
		SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		-- Add Mail result       


	
	/***********************************************************************************************************************************
	--	Jobs Changed
	***********************************************************************************************************************************/ 

		IF ( OBJECT_ID('tempdb..##Email_HTML14') IS NOT NULL )
			DROP TABLE ##Email_HTML14

		SELECT	TOP 10
					[Nm_Job] [Job Name], 
					ISNULL(
						CASE [Fl_Enabled] 
							WHEN 1 THEN 'YES' 
							WHEN 0 THEN 'NO' 
						END, '-')											AS [Enabled], 
					ISNULL(CONVERT(VARCHAR, [Dt_Creation], 120), '-')		AS [Creation Date],
					ISNULL(CONVERT(VARCHAR, [Dt_Alteration], 120), '-')	AS [Change Date],
					ISNULL(CAST([Nr_Version] AS VARCHAR), '-')				AS [Version]
		INTO ##Email_HTML14
		FROM [dbo].[CheckList_Changed_Jobs]		

		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Jobs Alterados')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Jobs Changed')		
		END		  	
	
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML14', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Change Date] DESC',
			@Ds_Saida = @HTML OUT		 -- varchar(max)					
	
		IF EXISTS(SELECT null FROM ##Email_HTML14)
		SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		-- Add Mail result       


	/***********************************************************************************************************************************
	--	Failed Jobs 
	***********************************************************************************************************************************/
		IF ( OBJECT_ID('tempdb..##Email_HTML15') IS NOT NULL )
			DROP TABLE ##Email_HTML15

		SELECT	TOP 10
				[Job_Name] [Job Name], 
				ISNULL([Status], '-')								AS [Status], 
				ISNULL(CONVERT(VARCHAR, [Dt_Execution], 120), '-')	AS [Execution Date], 
				ISNULL([Run_Duration], '-')							AS [Duration], 
				ISNULL(REPLACE(REPLACE( REPLACE( REPLACE(SQL_Message, '<tr>', ' '), '<td>', ' '), '</td>', ' '), '</tr>', ' '),'-') AS [SQL Message]
		INTO ##Email_HTML15
		FROM [dbo].[CheckList_Jobs_Failed]	

		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Jobs que Falharam')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Jobs Failed')		
		END		  	
	
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML15', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Execution Date] DESC',
			@Ds_Saida = @HTML OUT		 -- varchar(max)					
	
		IF EXISTS(SELECT null FROM ##Email_HTML15)
		SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		-- Add Mail result       


	/***********************************************************************************************************************************
	--	Slow Jobs  
	***********************************************************************************************************************************/ 
		IF ( OBJECT_ID('tempdb..##Email_HTML16') IS NOT NULL )
			DROP TABLE ##Email_HTML16
		
		SELECT	TOP 10
				[Job_Name] [Job Name], 
				ISNULL([Status], '-')								AS [Status], 
				ISNULL(CONVERT(VARCHAR, [Dt_Execution], 120), '-')	AS [Execution Date], 
				ISNULL([Run_Duration], '-')							AS [Duration], 
				ISNULL([SQL_Message], '-')							AS [SQL Message]
		INTO ##Email_HTML16
		FROM [dbo].[CheckList_Slow_Jobs]			

		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Jobs Demorados')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Slow Jobs')		
		END		  	
	
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML16', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Duration] DESC',
			@Ds_Saida = @HTML OUT		 -- varchar(max)					
	
			IF EXISTS(SELECT null FROM ##Email_HTML16)
		SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		-- Add Mail result       


	/***********************************************************************************************************************************
	--	Slow Queries
	***********************************************************************************************************************************/
		IF ( OBJECT_ID('tempdb..##Email_HTML17') IS NOT NULL )
			DROP TABLE ##Email_HTML17
		
		SELECT	[dbo].fncAlert_Change_Invalid_Character ([PrefixoQuery])	AS [Prefixo Query],
						ISNULL(CAST([QTD]	 AS VARCHAR), '-')						AS [Quantity],
						ISNULL(CAST([Total]  AS VARCHAR), '-')						AS [Total (s)],
						ISNULL(CAST([AVG]  AS VARCHAR), '-')						AS [AVG (s)],
						ISNULL(CAST([MIN]  AS VARCHAR), '-')					AS [MIN (s)],
						ISNULL(CAST([MAX]  AS VARCHAR), '-')						AS [MAX (s)],
						ISNULL(CAST([Writes] AS VARCHAR), '-')						AS [Writes],
						ISNULL(CAST([CPU]	 AS VARCHAR), '-')						AS [CPU (m)],
						ISNULL(CAST([Reads]	 AS VARCHAR), '-')						AS [Reads],
						[Ordem]
		INTO  ##Email_HTML17
		FROM [dbo].[CheckList_Profile_Queries]			


		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Queries Demoradas Dia Anterior (07:00 - 23:00)')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Slow Queries Last Day (07:00 am - 11:00 pm)')		
		END		  	
	
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML17', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Ordem]',
			@Ds_Saida = @HTML OUT		 -- varchar(max)					
	
			IF EXISTS(SELECT null FROM ##Email_HTML17)
		SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		-- Add Mail result       

    

	/***********************************************************************************************************************************
	--	Slow Queries - Last 10 Days
	***********************************************************************************************************************************/ 
		IF ( OBJECT_ID('tempdb..##Email_HTML18') IS NOT NULL )
			DROP TABLE ##Email_HTML18
		
			SELECT	[Date], 
					ISNULL(CAST([QTD] AS VARCHAR), '-')	AS [QTD]
			INTO ##Email_HTML18
			FROM [dbo].[CheckList_Profile_Queries_LastDays]


		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Queries Demoradas - Últimos 10 Dias (07:00 - 23:00)')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Slow Queries - Last 10 Day (07:00 am - 11:00 pm)')		
		END		  	
	
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML18', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Date] DESC',
			@Ds_Saida = @HTML OUT		 -- varchar(max)					
	
		IF EXISTS(SELECT null FROM ##Email_HTML18)
		SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		-- Add Mail result       

		
	/***********************************************************************************************************************************
	--	Counters
	***********************************************************************************************************************************/
		IF ( OBJECT_ID('tempdb..##Email_HTML19') IS NOT NULL )
			DROP TABLE ##Email_HTML19

		SELECT	[Hour],
						[BatchRequests] [Batch Requests],
						[CPU],
						[Page_Life_Expectancy] [PLE],
						[SQL_Compilations] [SQL Compilations],
						[User_Connection] [User Connection],
						[Qtd_Queries_Lentas] [Num Slow Queries],
						[Reads_Queries_Lentas] [Reads Slow Queries],
						[Page Splits/sec]
		INTO ##Email_HTML19
		FROM [dbo].[CheckList_Counters_Email] AS C		
				

		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Média Contadores Dia Anterior (07:00 - 23:00)')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Average Counters Last Day (07:00 am - 11:00 pm)')		
		END		  	
	
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML19', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = 'LEN([Hour]), [Hour]',
			@Ds_Saida = @HTML OUT		 -- varchar(max)					

			IF EXISTS(SELECT null FROM ##Email_HTML19)
		SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		-- Add Mail result       


			

	/***********************************************************************************************************************************
	--	Open Connections
	***********************************************************************************************************************************/ 

		IF ( OBJECT_ID('tempdb..##Email_HTML20') IS NOT NULL )
			DROP TABLE ##Email_HTML20

		SELECT	Nr_Order [Order],
						ISNULL([login_name], '-')			AS [Login Name], 
						CAST([session_count] AS VARCHAR)	AS [Session Count]
		INTO ##Email_HTML20
		FROM [dbo].[CheckList_Opened_Connections_Email]							

		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Conexões Abertas por Usuários')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Opened Connections by User')		
		END		  	
	
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML20', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Order], CAST([Session Count] AS INT) DESC',
			@Ds_Saida = @HTML OUT		 -- varchar(max)					

		IF EXISTS(SELECT null FROM ##Email_HTML20)
		SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		-- Add Mail result       



	/***********************************************************************************************************************************
	--	Index Fragmentation
	***********************************************************************************************************************************/

		IF ( OBJECT_ID('tempdb..##Email_HTML21') IS NOT NULL )
			DROP TABLE ##Email_HTML21

		SELECT	TOP 10
				ISNULL(CONVERT(VARCHAR, [Dt_Log], 120), '-')				AS [Date], 
				[Nm_Database] [Database], 
				ISNULL([Nm_Table], '-')										AS [Table], 
				ISNULL([Nm_Index], '-')										AS [Index],
				ISNULL([Avg_Fragmentation_In_Percent]	, 0)	AS [Fragmentation (%)],
				ISNULL(CAST([Page_Count]					AS VARCHAR), '-')	AS [Page Count], 
				ISNULL(CAST([Fill_Factor]					AS VARCHAR), '-')	AS [Fill Factor],
				ISNULL(	
					CASE [Fl_Compression]
						WHEN 0 THEN 'NO Compression'
						WHEN 1 THEN 'ROW Compression' 
						WHEN 2 THEN 'PAGE Compression'
					END, '-') AS [Compression]
		INTO ##Email_HTML21
		FROM [dbo].CheckList_Index_Fragmentation_History
	

		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Fragmentação dos Índices')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Fragmented Index')		
		END		  	
	
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML21', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Fragmentation (%)] DESC',
			@Ds_Saida = @HTML OUT		 -- varchar(max)					

		IF EXISTS(SELECT null FROM ##Email_HTML21)
		SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		-- Add Mail result       


	
	/***********************************************************************************************************************************
	--	Waits Stats 
	***********************************************************************************************************************************/
		IF ( OBJECT_ID('tempdb..##Email_HTML22') IS NOT NULL )
			DROP TABLE ##Email_HTML22

		SELECT	TOP 10
						[WaitType] [Wait Type], 
						ISNULL(CONVERT(VARCHAR, [Max_Log], 120),     '-') AS [Last Log Date],
						ISNULL([DIf_Wait_S]	, 0) AS [Dif Wait (s)], 
						ISNULL([DIf_Resource_S], 0) AS [Dif Resource (s)],
						ISNULL([DIf_Signal_S], 0) AS [Dif Signal (s)], 
						ISNULL([DIf_WaitCount], 0) AS [Dif Wait Count],
						ISNULL([Last_Percentage], 0) AS [Percentage]
		INTO ##Email_HTML22
		FROM [dbo].[CheckList_Waits_Stats]		
	
			
		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Waits Stats Dia Anterior (07:00 - 23:00)')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Waits Stats Last Day (07:00 am - 11:00 pm)')		
		END		  	
	
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML22', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Dif Wait (s)] DESC',
			@Ds_Saida = @HTML OUT		 -- varchar(max)					

		IF EXISTS(SELECT null FROM ##Email_HTML22)
		SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		-- Add Mail result       


    
   	/***********************************************************************************************************************************
	--	Alerts Without CLEAR 
	***********************************************************************************************************************************/
		IF ( OBJECT_ID('tempdb..##Email_HTML23') IS NOT NULL )
			DROP TABLE ##Email_HTML23					

		SELECT	[Nm_Alert] [Alert],
						ISNULL([Ds_Message], '-') AS [Message],
						ISNULL(CONVERT(VARCHAR, [Dt_Alert], 120), '-') AS [Date],
						ISNULL([Run_Duration], '-') AS [Open Time]
		INTO ##Email_HTML23
		FROM [dbo].[Checklist_Alert_Sem_Clear]				
			
		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Alertas Sem CLEAR ')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Alerts Without CLEAR ')		
		END		  	
	
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML23', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Date] DESC',
			@Ds_Saida = @HTML OUT		 -- varchar(max)					

		IF EXISTS(SELECT null FROM ##Email_HTML23)
		SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		-- Add Mail result     



		/***********************************************************************************************************************************
		--	Alerts - Last Day
		***********************************************************************************************************************************/
		IF ( OBJECT_ID('tempdb..##Email_HTML24') IS NOT NULL )
				DROP TABLE ##Email_HTML24					
		
		SELECT	TOP 50
						[Nm_Alert] [Alert],
						ISNULL([Ds_Message], '-') AS [Message],
						ISNULL(CONVERT(VARCHAR, [Dt_Alert], 120), '-') AS [Date],
						ISNULL([Run_Duration], '-') AS [Open Time]
		INTO ##Email_HTML24
		FROM [dbo].[Checklist_Alert]						
			
		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 50 - Alertas Últimas 24 horas')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 50 - Alerts Last 24 Hours')		
		END		  	
	
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML24', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Date] DESC',
			@Ds_Saida = @HTML OUT		 -- varchar(max)					

		IF EXISTS(SELECT null FROM ##Email_HTML24)
		SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		-- Add Mail result     
		      	

	/***********************************************************************************************************************************
	--	Login Failed 
	***********************************************************************************************************************************/

		IF ( OBJECT_ID('tempdb..##Email_HTML25') IS NOT NULL )
				DROP TABLE ##Email_HTML25			
				
		SELECT	TOP 10
				[Nr_Order] [Order],
				[Text],
				ISNULL(CAST([Qt_Error] AS VARCHAR), '-') AS [Number of Error]
		INTO ##Email_HTML25
		FROM [dbo].[CheckList_SQLServer_LoginFailed_Email]
		ORDER BY CAST(REPLACE([Qt_Error], '-', 0) AS INT) DESC		  					
			
		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Login Failed - SQL Server')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 10 - Login Failed - SQL Server')		
		END		  	
	
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML25', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Order], CAST([Number of Error] AS INT) DESC',
			@Ds_Saida = @HTML OUT		 -- varchar(max)					

		IF EXISTS(SELECT null FROM ##Email_HTML25)
		SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		-- Add Mail result     


	/***********************************************************************************************************************************
	--	Error Log SQL 
	***********************************************************************************************************************************/

		IF ( OBJECT_ID('tempdb..##Email_HTML26') IS NOT NULL )
				DROP TABLE ##Email_HTML26
							
		SELECT	TOP 100
						ISNULL(CONVERT(VARCHAR, [Dt_Log], 120), '-') AS [Date], 
						ISNULL([ProcessInfo], '-')					 AS [Process Info], 
						[Text] 
		INTO ##Email_HTML26
		FROM [dbo].[CheckList_SQLServer_ErrorLog]	  					
			
		IF @Fl_Language = 1 --Portuguese
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 100 - Error Log do SQL Server')				
		END
		ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT','TOP 100 - Error Log do SQL Server')		
		END		  	
	
		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML26', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Date] DESC',
			@Ds_Saida = @HTML OUT		 -- varchar(max)					

		IF EXISTS(SELECT null FROM ##Email_HTML26)
		SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space  	
			
	/***********************************************************************************************************************************
	--	Send CheckList Email
	***********************************************************************************************************************************/
	
				SET @Final_HTML = @Final_HTML + @Company_Link		

				IF @Fl_Language = 1 --Portuguese
				BEGIN
					 SET @Ds_Subject = @Ds_Message_Alert_PTB+@@SERVERNAME 
				END
			   ELSE 
			   BEGIN
				
					SET @Ds_Subject =  @Ds_Message_Alert_ENG+@@SERVERNAME 
			   END		   		
	
				EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'	
										

END
GO


IF ( OBJECT_ID('[dbo].[stpLoad_CheckList_Information]') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpLoad_CheckList_Information
GO

	CREATE PROCEDURE stpLoad_CheckList_Information
	AS
	BEGIN	
		DECLARE @Query NVARCHAR(1000),@Proc VARCHAR(100)
		DECLARE @Procedures TABLE(Nm_Procedure VARCHAR(100))

		SET @Query = ''
		
		INSERT INTO @Procedures
		SELECT Nm_Procedure
		FROM CheckList_Parameter

		WHILE EXISTS(SELECT TOP 1 NULL FROM @Procedures)
		BEGIN
			SELECT TOP 1 @Proc = Nm_Procedure
			FROM @Procedures

			SET @Query = @Query  + ' EXEC ' + @Proc

			DELETE FROM @Procedures
			WHERE Nm_Procedure = @Proc 

		end

		--SELECT @Query

		EXECUTE sp_executesql @Query
	END     
GO


USE [msdb]

GO
GO
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - CheckList SQL Server Instance')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - CheckList SQL Server Instance', @delete_unused_schedule=1
GO
GO


BEGIN TRANSACTION
	DECLARE @ReturnCode INT
	SELECT @ReturnCode = 0
	
	------------------------------------------------------------------------------------------------------------------------------------	
	-- Seleciona a Categoria do JOB
	------------------------------------------------------------------------------------------------------------------------------------
	IF NOT EXISTS ( SELECT [name] FROM [msdb].[dbo].[syscategories] WHERE [name] = N'Database Maintenance' AND [category_class] = 1 )
	BEGIN
		EXEC @ReturnCode = [msdb].[dbo].[sp_add_category] @class = N'JOB', @type = N'LOCAL', @name = N'Database Maintenance'
		
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	END

	DECLARE @jobId BINARY(16)
	EXEC @ReturnCode = [msdb].[dbo].[sp_add_job]
			@job_name = N'DBA - CheckList SQL Server Instance', 
			@enabled = 1, 
			@notify_level_eventlog = 0, 
			@notify_level_email = 2, 
			@notify_level_netsend = 0, 
			@notify_level_page = 0, 
			@delete_level = 0, 
			@category_name = N'Database Maintenance', 
			@owner_login_name = N'sa',
			@notify_email_operator_name=N'DBA_Operator',
			@job_id = @jobId OUTPUT
											
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	------------------------------------------------------------------------------------------------------------------------------------	
	-- Cria o Step 1 do JOB - Carga Tabelas CheckList
	------------------------------------------------------------------------------------------------------------------------------------
	EXEC @ReturnCode = [msdb].[dbo].[sp_add_jobstep]
			@job_id = @jobId,
			@step_name = N'DBA - Load Table CheckList',
			@step_id = 1,
			@cmdexec_success_code = 0,
			@on_success_action = 3,
			@on_success_step_id = 0,
			@on_fail_action = 2,
			@on_fail_step_id = 0,
			@retry_attempts = 0, 
			@retry_interval = 0, 
			@os_run_priority = 0, 
			@subsystem = N'TSQL',
			@command = N'			
				exec stpLoad_CheckList_Information',
			@database_name = N'Traces',
			@flags = 0
							
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = [msdb].[dbo].[sp_add_jobstep]
			@job_id = @jobId, 
			@step_name = N'DBA - Send CheckList Mail', 
			@step_id = 2, 
			@cmdexec_success_code = 0,
			@on_success_action = 1,
			@on_success_step_id = 0, 
			@on_fail_action = 2,
			@on_fail_step_id = 0, 
			@retry_attempts = 0, 
			@retry_interval = 0, 
			@os_run_priority = 0, 
			@subsystem = N'TSQL', 
			@command = N'EXEC[dbo].[stpSend_Mail_CheckList_DBA]', 
			@database_name = N'Traces', 
			@flags = 0

	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = [msdb].[dbo].[sp_update_job] @job_id = @jobId, @start_step_id = 1
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	------------------------------------------------------------------------------------------------------------------------------------	
	-- Cria o Schedule do JOB
	------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @Dt_Atual VARCHAR(8) = CONVERT(VARCHAR(8), GETDATE(), 112)
		
	EXEC @ReturnCode = [msdb].[dbo].[sp_add_jobschedule]
			@job_id = @jobId, 
			@name = N'Daily - 06:00', 
			@enabled = 1, 
			@freq_type = 4, 
			@freq_interval = 1 , 
			@freq_subday_type = 1, 
			@freq_subday_interval = 0, 
			@freq_relative_interval = 0, 
			@freq_recurrence_factor = 0, 
			@active_start_date = @Dt_Atual,
			@active_end_date = 99991231, 
			@active_start_time = 65500, 
			@active_end_time = 235959, 
			@schedule_uid = N'5db1dad0-4ec4-4cb2-8bb4-6841a8a90cfc'
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = [msdb].[dbo].[sp_add_jobserver] @job_id = @jobId, @server_name = N'(local)'
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

COMMIT TRANSACTION

GOTO EndSave

QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
    
EndSave:

GO


--------------------------------------------------------------------------------------------------------------------------------
-- JOB: DBA - Load SQL Server Counters
--------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT job_id 
            FROM msdb.dbo.sysjobs_view 
            WHERE name = N'DBA - Load SQL Server Counters')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Load SQL Server Counters'  , @delete_unused_schedule=1

USE [msdb]

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
	EXEC @ReturnCode =  msdb.dbo.sp_add_job 
			@job_name = N'DBA - Load SQL Server Counters', 
			@enabled = 1, 
			@notify_level_eventlog = 0, 
			@notify_level_email = 0, 
			@notify_level_netsend = 0, 
			@notify_level_page = 0, 
			@delete_level = 0, 
			@description = N'No description available.', 
			@category_name = N'Database Maintenance', 
			@owner_login_name = N'sa', 
			@job_id = @jobId OUTPUT
		
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
			@job_id = @jobId, 
			@step_name = N'DBA - Load SQL Server Counters', 
			@step_id = 1, 
			@cmdexec_success_code = 0, 
			@on_success_action = 1, 
			@on_success_step_id = 0, 
			@on_fail_action = 2, 
			@on_fail_step_id = 0, 
			@retry_attempts = 0, 
			@retry_interval = 0, 
			@os_run_priority = 0,
			@subsystem = N'TSQL', 
			@command = N'exec stpLoad_SQL_Counter', 
			@database_name = N'Traces', 
			@flags=0
		
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	declare @Dt_Atual varchar(8) = convert(varchar(8), getdate(), 112)
	
	EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule 
			@job_id = @jobId, 
			@name = N'Contadores SQL', 
			@enabled = 1, 
			@freq_type = 4, 
			@freq_interval = 1, 
			@freq_subday_type = 4, 
			@freq_subday_interval = 1, 
			@freq_relative_interval = 0, 
			@freq_recurrence_factor = 0, 
			@active_start_date = @Dt_Atual,
			@active_end_date = 99991231, 
			@active_start_time = 32, 
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


--------------------------------------------------------------------------------------------------------------------------------
-- JOB: DBA - Load Table Size
--------------------------------------------------------------------------------------------------------------------------------
-- Se o job já existe, exclui para criar novamente.
IF EXISTS (	SELECT job_id 
            FROM msdb.dbo.sysjobs_view 
            WHERE name = N'DBA - Load Table Size')
	EXEC msdb.dbo.sp_delete_job @job_name = N'DBA - Load Table Size', @delete_unused_schedule = 1

USE [msdb]

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
	EXEC @ReturnCode =  msdb.dbo.sp_add_job 
			@job_name = N'DBA - Load Table Size', 
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
			@step_name = N'DBA - Load Table Size', 
			@step_id = 1, 
			@cmdexec_success_code = 0, 
			@on_success_action = 1, 
			@on_success_step_id = 0, 
			@on_fail_action = 2, 
			@on_fail_step_id = 0, 
			@retry_attempts = 0, 
			@retry_interval = 0, 
			@os_run_priority = 0, 
			@subsystem = N'TSQL', 
			@command = N'exec stpLoad_Table_Size', 
			@database_name = N'Traces', 
			@flags = 0
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	declare @Dt_Atual varchar(8) = convert(varchar(8), getdate(), 112)
	
	EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule 
			@job_id = @jobId, 
			@name = N'DBA - Load Table Size', 
			@enabled = 1, 
			@freq_type = 4, 
			@freq_interval = 1, 
			@freq_subday_type = 1, 
			@freq_subday_interval = 0, 
			@freq_relative_interval = 0, 
			@freq_recurrence_factor = 0, 
			@active_start_date = @Dt_Atual, 
			@active_end_date = 99991231, 
			@active_start_time = 1000, 
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

--------------------------------------------------------------------------------------------------------------------------------
-- JOB: DBA - Load SQL Server Files Performance
--------------------------------------------------------------------------------------------------------------------------------

USE [msdb]
GO

IF EXISTS (SELECT job_id 
            FROM msdb.dbo.sysjobs_view 
            WHERE name = N'DBA - Load SQL Server Files Performance')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Load SQL Server Files Performance'  , @delete_unused_schedule=1

GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 02/15/2017 10:47:42 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Load SQL Server Files Performance', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Nenhuma descrição disponível.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA_Operator',
		@job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Carga Utilização Arquivo]    Script Date: 02/15/2017 10:47:48 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DBA - Load SQL Server Files Performance', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [dbo].[stpLoad_File_Utilization]', 
		@database_name=N'Traces', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily- every 30 minutes', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=126, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20161110, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'cd176e16-94e3-4911-9fb8-937d0c07a6e0'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

--------------------------------------------------------------------------------------------------------------------------------
-- JOB: DBA - Wait Stats Load.
--------------------------------------------------------------------------------------------------------------------------------
USE [msdb]
GO

-- Se o job já existe, exclui para criar novamente.
IF EXISTS (SELECT job_id 
            FROM msdb.dbo.sysjobs_view 
            WHERE name = N'DBA - Load Wait Stats')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Load Wait Stats'  , @delete_unused_schedule=1

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
	EXEC @ReturnCode =  msdb.dbo.sp_add_job 
			@job_name = N'DBA - Load Wait Stats', 
			@enabled = 1, 
			@notify_level_eventlog = 0, 
			@notify_level_email = 0, 
			@notify_level_netsend = 0, 
			@notify_level_page = 0, 
			@delete_level = 0, 
			@description = N'No description available.', 
			@category_name = N'Database Maintenance', 
			@owner_login_name = N'sa', 
			@job_id = @jobId OUTPUT
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
			@job_id = @jobId, 
			@step_name = N'DBA - Load Wait Stats', 
			@step_id = 1, 
			@cmdexec_success_code = 0, 
			@on_success_action = 1, 
			@on_success_step_id = 0, 
			@on_fail_action = 2, 
			@on_fail_step_id = 0, 
			@retry_attempts = 0, 
			@retry_interval = 0, 
			@os_run_priority = 0, 
			@subsystem = N'TSQL', 
			@command = N'exec stpLoad_Waits_Stats_History', 
			@database_name = N'Traces', 
			@flags = 0
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	declare @Dt_Atual varchar(8) = convert(varchar(8), getdate(), 112)

	EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule 
			@job_id = @jobId, 
			@name = N'Histórico Wait', 
			@enabled = 1, 
			@freq_type = 4, 
			@freq_interval = 1, 
			@freq_subday_type = 4, 
			@freq_subday_interval = 30, 
			@freq_relative_interval = 0, 
			@freq_recurrence_factor = 0, 
			@active_start_date = @Dt_Atual, 
			@active_end_date = 99991231, 
			@active_start_time = 707, 
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
