INSERT INTO [Traces].[dbo].Alert_Parameter 
SELECT 'AlwaysON AG Queue Size', 'stpAlert_AlwaysON_AG_Queue_Size',NULL,NULL,NULL, 1,1,1,null,null,null,null,'MSSQLServer', 'EMAIL','ALERT: The AlwaysON Queue Size is big on Server:','CLEAR: The AlwaysON Queue Size is Normal on Server:','ALERTA: A fila do AlwaysOn AG está Grande no Servidor:','CLEAR: A fila do AlwaysOn AG está Normal no Servidor:','AlwaysON AG Dadabase Queue Size','','',''


USE [Traces]
GO
/****** Object:  StoredProcedure [dbo].[stpAlert_AlwaysON_AG_Queue_Size]    Script Date: 3/17/2020 11:48:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 
CREATE PROCEDURE [dbo].[stpAlert_AlwaysON_AG_Queue_Size]
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
@Vl_Parameter = Vl_Parameter,-- Minutes,
@Ds_Email = Ds_Email,
@Fl_Language = Fl_Language,
@Ds_Profile_Email = Ds_Profile_Email,
@Vl_Parameter_2 = Vl_Parameter_2,--minute
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
WHERE Nm_Alert = 'AlwaysON AG Queue Size'
 
-- Look for the last time the alert was executed and 30find if it was a "0: CLEAR" OR "1: ALERT".
SELECT @Fl_Type = [Fl_Type]
FROM [dbo].[Alert]
WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )
 
 
IF ( OBJECT_ID('tempdb..#AlWaysON_AG_Queue_Size') IS NOT NULL )DROP TABLE #AlWaysON_AG_Queue_Size
select  ag.name
, ags.primary_replica
, db_name(drs.database_id) as database_name
, rcs.replica_server_name
, drs.synchronization_health_desc
, drs.synchronization_state_desc
, drs.log_send_queue_size
, drs.log_send_rate
, drs.redo_queue_size
, drs.redo_rate
, drs.last_received_time
, drs.last_redone_time
into #AlWaysON_AG_Queue_Size
from sys.availability_groups ag
inner join sys.dm_hadr_availability_group_states ags on ags.group_id = ag.group_id
inner join sys.dm_hadr_database_replica_states drs on drs.group_id = ag.group_id
inner join sys.dm_hadr_availability_replica_cluster_states rcs on rcs.replica_id = drs.replica_id
WHERE log_send_queue_size >= 5242880 OR redo_queue_size >= 10485760      --5GB de fila pra send 8gb pra redo
order by drs.redo_queue_size desc
 
IF ( OBJECT_ID('tempdb..#AlWaysON_AG_Queue_Size_Clear') IS NOT NULL )DROP TABLE #AlWaysON_AG_Queue_Size_Clear
select  ag.name
, ags.primary_replica
, db_name(drs.database_id) as database_name
, rcs.replica_server_name
, drs.synchronization_health_desc
, drs.synchronization_state_desc
, drs.log_send_queue_size
, drs.log_send_rate
, drs.redo_queue_size
, drs.redo_rate
, drs.last_received_time
, drs.last_redone_time
into #AlWaysON_AG_Queue_Size_Clear
from sys.availability_groups ag
inner join sys.dm_hadr_availability_group_states ags on ags.group_id = ag.group_id
inner join sys.dm_hadr_database_replica_states drs on drs.group_id = ag.group_id
inner join sys.dm_hadr_availability_replica_cluster_states rcs on rcs.replica_id = drs.replica_id
order by drs.redo_queue_size desc
 
--Do we have Memory problem?
IF EXISTS (SELECT count(*) FROM   #AlWaysON_AG_Queue_Size )
BEGIN
IF ISNULL(@Fl_Type, 0) = 0-- Control Alert/Clear
BEGIN
IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
DROP TABLE ##Email_HTML
 
SELECT *
INTO ##Email_HTML
FROM    #AlWaysON_AG_Queue_Size
 

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
 
IF @Fl_Language = 1
SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_PTB)
ELSE 
SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_ENG)
 
EXEC [msdb].[dbo].[sp_send_dbmail]
@profile_name = @Ds_Profile_Email,
@recipients =@Ds_Email,
@subject =@Ds_Subject,
@body =@Final_HTML,
@body_format ='HTML',
@importance ='High'
 
-- Fl_Type = 1 : ALERT
INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
SELECT @Id_Alert_Parameter, @Ds_Subject, 1
 
END-- END - ALERT
END
ELSE 
BEGIN-- BEGIN - CLEAR
IF @Fl_Type = 1
BEGIN
 
IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR') IS NOT NULL )
DROP TABLE ##Email_HTML_CLEAR
 
SELECT *
INTO ##Email_HTML_CLEAR
FROM   #AlWaysON_AG_Queue_Size_Clear
 
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
@Ds_Saida = @HTML OUT-- varchar(max)
 
-- First Result
SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space
 
IF @Fl_Language = 1
SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_PTB)
ELSE 
SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_ENG)
 
EXEC [msdb].[dbo].[sp_send_dbmail]
@profile_name = @Ds_Profile_Email,
@recipients =@Ds_Email,
@subject =@Ds_Subject,
@body =@Final_HTML,
@body_format ='HTML',
@importance ='High'
 
-- Fl_Type = 0 : CLEAR
INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
SELECT @Id_Alert_Parameter, @Ds_Subject, 0
END
END-- END - CLEAR
 
END
