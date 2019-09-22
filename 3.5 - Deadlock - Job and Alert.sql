/***********************************************************************************************************************************
(C) 2016, Fabricio França Lima 

Blog: https://www.fabriciolima.net/blog/

Feedback: suporte@fabriciolima.net

Instagram: @fabriciofrancalima

Twitter: @fabriciodba

Facebook: https://www.facebook.com/fabricio.francalima

Linkedin: https://www.linkedin.com/in/fabriciolimasolucoesembd/

Consultoria: comercial@fabriciolima.net


Instructions:
1 - You need to change the path to a real one of your server
	Replace: "C:\Temp\Video Alertas"
	
--Open the procedure stpAlert_Every_Day e uncomment the stored procedure call "exec stpAlert_DeadLocks"
	EXEC dbo.stpAlert_DeadLocks
	
********************************************************************************************************************************/

/*
	

--IF YOU HAVE AZURE SQL DATABASE - MANAGED INSTANCE

CREATE TABLE [dbo].[Log_DeadLock](
	[eventDate] [datetime] NULL,
	[deadlock] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

--Put this code on a job
INSERT into Log_DeadLock
SELECT CAST(timestamp_utc AS DATETIME) timestamp_utc,CAST(event_data AS XML) AS [target_data_XML]
FROM master.sys.fn_xe_telemetry_blob_target_read_file('dl', null, null, null) A
	LEFT JOIN Traces.dbo.Log_DeadLock AS B ON CAST(A.timestamp_utc AS DATETIME) = B.eventDate
WHERE CAST(A.timestamp_utc AS DATE) = CAST(GETDATE()-1 AS DATE)
AND B.eventDate IS null

*/

USE Traces

UPDATE dbo.Alert_Parameter
SET Fl_Enable = 1
WHERE Nm_Alert = 'DeadLock'

USE [Traces]
GO


IF ( OBJECT_ID('[dbo].stpXEvent_DeadLock') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpXEvent_DeadLock
GO

USE [Traces]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[stpXEvent_DeadLock]
AS
BEGIN
	-- Stop your Extended Events session
	ALTER EVENT SESSION capture_deadlocks ON SERVER
	STATE = STOP;

	declare @filenamePattern sysname;
 
	SELECT @filenamePattern = REPLACE( CAST(field.value AS sysname), '.xel', '*xel' )
	FROM sys.server_event_sessions AS [session]
	JOIN sys.server_event_session_targets AS [target]
	  ON [session].event_session_id = [target].event_session_id
	JOIN sys.server_event_session_fields AS field 
	  ON field.event_session_id = [target].event_session_id
	  AND field.object_id = [target].target_id	
	WHERE
		field.name = 'filename'
		and [session].name= N'capture_deadlocks'

	insert into Log_DeadLock(eventName,eventDate,deadlock,Nm_Object,Nm_Database)
	SELECT deadlockData.eventName,dateadd(hh,-3,deadlockData.eventDate),deadlockData.deadlock,isnull(isnull(isnull(deadlockData.objectname1,deadlockData.objectname2),deadlockData.objectname3),'') objectname,isnull(C.name,'')
	FROM sys.fn_xe_file_target_read_file ( @filenamePattern, null, null, null) 
		as event_file_value
	CROSS APPLY ( SELECT CAST(event_file_value.[event_data] as xml) ) 
		as event_file_value_xml ([xml])
	CROSS APPLY (
		SELECT 
			event_file_value_xml.[xml].value('(event/@name)[1]', 'varchar(100)') as eventName,
			event_file_value_xml.[xml].value('(event/@timestamp)[1]', 'datetime') as eventDate,
			event_file_value_xml.[xml].value('(event/data/value/deadlock/resource-list/pagelock/@dbid)[1]', 'int') as dbid1,
			event_file_value_xml.[xml].value('(event/data/value/deadlock/resource-list/ridlock/@dbid)[1]', 'int') as dbid2,			
			event_file_value_xml.[xml].value('(event/data/value/deadlock/resource-list/keylock/@dbid)[1]', 'int') as dbid3,			
			event_file_value_xml.[xml].value('(event/data/value/deadlock/resource-list/pagelock/@objectname)[1]', 'varchar(500)') as objectname1,
			event_file_value_xml.[xml].value('(event/data/value/deadlock/resource-list/ridlock/@objectname)[1]', 'varchar(500)') as objectname2,	
			event_file_value_xml.[xml].value('(event/data/value/deadlock/resource-list/keylock/@objectname)[1]', 'varchar(500)') as objectname3,				
			event_file_value_xml.[xml].query('//event/data/value/deadlock') as deadlock	
			--event_file_value_xml.[xml].query('//event/data/value/deadlock') as deadlock		

	  ) as deadlockData
	  LEFT JOIN Log_DeadLock X on dateadd(hh,-3,deadlockData.eventDate) = X.eventDate
	  left join sys.databases C on isnull(isnull(deadlockData.dbid1,deadlockData.dbid2),deadlockData.dbid3) = C.database_id
	WHERE deadlockData.eventName = 'xml_deadlock_report'
		and X.eventDate is null
	ORDER BY deadlockData.eventDate


	-- Clean up your session from the server
	DROP EVENT SESSION [capture_deadlocks] ON SERVER;


	CREATE EVENT SESSION [capture_deadlocks] ON SERVER 
	ADD EVENT sqlserver.xml_deadlock_report( ACTION(sqlserver.database_name) ) 
	ADD TARGET package0.asynchronous_file_target(
	  SET filename = 'C:\Temp\Video Alertas\capture_deadlocks.xel',
		  max_file_size = 500,
		  max_rollover_files = 5)
	WITH (
		STARTUP_STATE=ON,
		EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
		MAX_DISPATCH_LATENCY=15 SECONDS,
		TRACK_CAUSALITY=OFF
		)
 

	 -- Start the session
	ALTER EVENT SESSION capture_deadlocks
	ON SERVER STATE = START
END

GO

-- INICIA O EVENTO
CREATE EVENT SESSION [capture_deadlocks] ON SERVER 
ADD EVENT sqlserver.xml_deadlock_report( ACTION(sqlserver.database_name) ) 
ADD TARGET package0.asynchronous_file_target(
	SET filename = 'C:\Temp\Video Alertas\capture_deadlocks.xel',
		max_file_size = 500,
		max_rollover_files = 5)
WITH (
	STARTUP_STATE=ON,
	EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
	MAX_DISPATCH_LATENCY=15 SECONDS,
	TRACK_CAUSALITY=OFF
	)
 

	-- Start the session
ALTER EVENT SESSION capture_deadlocks
ON SERVER STATE = START

GO


IF ( OBJECT_ID('[dbo].stpAlert_DeadLocks') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_DeadLocks
GO
USE [Traces]
GO
/****** Object:  StoredProcedure [dbo].[stpAlert_DeadLocks]    Script Date: 08/08/2019 07:55:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stpAlert_DeadLocks]
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
	WHERE Nm_Alert = 'DeadLock'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
	select CONVERT(VARCHAR(20), eventDate, 120) [Date],
		isnull(Nm_Object,'') [Object],
		isnull(Nm_Database,'') [Database],
		deadlock.value('(deadlock/process-list/process/inputbuf)[1]','varchar(max)') AS Query		
	into #Deadlocks
	from Log_DeadLock
	where eventDate >= dateadd(hh,@Vl_Parameter*-1,getdate())

	declare @Deadlock_Number int
	select @Deadlock_Number = count(*) from #Deadlocks
	
	IF @Deadlock_Number > @Vl_Parameter_2
	BEGIN
		
		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
			DROP TABLE ##Email_HTML

		SELECT	*
		into ##Email_HTML
		FROM #Deadlocks
						 
		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter			
						
		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB),'###1',@Vl_Parameter)
				SET @Ds_Subject =  replace(REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter),'###2',@Deadlock_Number)  +@@SERVERNAME 
		END
        ELSE 
		BEGIN
			SET @Header = REPLACE(REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG),'###1',@Vl_Parameter)
			SET @Ds_Subject =  replace(REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter),'###2',@Deadlock_Number)+@@SERVERNAME 
		END		 
		

		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)			
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Date] DESC',
			@Ds_Saida = @HTML OUT				-- varchar(max)
				
		-- First Result
		SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space + @Company_Link	
		
			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'							
		
		-- Fl_Type = 1 : ALERT	
		INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
		SELECT @Id_Alert_Parameter, @Ds_Subject, 1											
		
	END	
END



GO


USE [msdb]
GO

-- Se o job já existe, exclui para criar novamente.
IF EXISTS (SELECT job_id 
            FROM msdb.dbo.sysjobs_view 
            WHERE name = N'DBA - Load XEvent Deadlock')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Load XEvent Deadlock'  , @delete_unused_schedule=1

GO
/****** Object:  Job [DBA - XEvent Deadlock]    Script Date: 25/09/2017 23:40:03 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 25/09/2017 23:40:03 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Load XEvent Deadlock', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA_Operator', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [PROC]    Script Date: 25/09/2017 23:40:03 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Executa Procedure', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec [stpXEvent_DeadLock]', 
		@database_name=N'Traces', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DIÁRIO - A CADA 5 MINUTOS', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160713, 
		@active_end_date=99991231, 
		@active_start_time=70000, 
		@active_end_time=220059, 
		@schedule_uid=N'db1f3048-7ca2-48d4-b832-bf918af054b9'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


/*
-- TO TESTE

SELECT * FROM Traces.[dbo].[Log_DeadLock]

use traces
go
create table teste1 (id int)

insert into teste1 values (1)

create table teste2 (id int)

insert into teste2 values (2)


-- CONEXAO 1
BEGIN TRAN
	UPDATE teste1
	SET id = id

	UPDATE teste2
	SET id = id

COMMIT

-- CONEXAO 2
BEGIN TRAN
	UPDATE teste2
	SET id = id

	UPDATE teste1
	SET id = id

COMMIT


EXEC msdb.dbo.sp_start_job N'DBA - XEvent Deadlock'


SELECT * FROM Traces.[dbo].[Log_DeadLock]

DROP TABLE teste1
DROP TABLE teste2
*/
