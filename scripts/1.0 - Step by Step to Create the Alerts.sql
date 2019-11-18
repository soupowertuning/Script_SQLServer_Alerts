
/***********************************************************************************************************************************
(C) 2016, Fabricio França Lima 

Blog: https://www.fabriciolima.net/blog/

Feedback: suporte@fabriciolima.net

Instagram: @fabriciofrancalima

Twitter: @fabriciodba

Facebook: https://www.facebook.com/fabricio.francalima

Linkedin: https://www.linkedin.com/in/fabriciolimasolucoesembd/

Consultoria: comercial@fabriciolima.net


select 4082+161+381+264+103+380+219+210+382+137+7429+444 (Quantidade de linhas dos scripts)

Post do blog com informações sobre os alertas:
http://www.fabriciolima.net/blog/2019/09/22/passo-a-passo-de-como-criar-40-alertas-para-monitorar-seu-sql-server/

Vídeos explicando o passo a passo para a criação dos alertas:
https://cursos.fabriciolima.net/course?courseid=criando-40-alertas-para-monitorar-o-sql-server

***********************************************************************************************************************************/


------------------------------------------------------------------
-- 0) Pré-Requisitos para utilizar esses Scripts
-- 0) Prerequisite to use this scripts
------------------------------------------------------------------

-- Criar a procedure sp_whoisactive (Obrigado Adam Machanic)
-- Create the sp_whoisactive stored procedure (thanks to Adam Machanic)

--Link to Download:
http://whoisactive.com/downloads/

--Crie a procedure exatamente com esse nome: sp_whoisactive (se não fizer isso, podemos ter erros em bancos case sensitive)
--Create the stored procedure name exactly as: sp_whoisactive (lower case, otherwise you can find errors related to case sensitive databases

--Test the stored procedure Whoisactive
exec sp_whoisactive 

--Antes de continuar, garanta que o envio de e-mail na sua instância SQL Server está funcionando.
--Before you continue, make sure that your SQL Server Instance is able to send emails

--------------------------------------------------------------------------------------------------------------------------------
-- 1) Criar um operator para utilizar nos jobs e uma database para armazenar os dados
-- 1) Create an operator to use on Jobs and a new Database to store the data
--------------------------------------------------------------------------------------------------------------------------------
	USE [msdb]
	
	if not exists (
	select NULL
	from msdb.dbo.sysoperators
	where name = 'DBA_Operator' )
	begin 
		EXEC [msdb].[dbo].[sp_add_operator]
				@name = N'DBA_Operator',
				@enabled = 1,
				@pager_days = 0,
				@email_address = N'EMail1@provedor.com'	-- To put more Emails: 'EMail1@provedor.com;EMail2@provedor.com'	

	end



--Criar uma database para armazenar as informações. Eu utilizo uma database chamada Traces. Caso queira utilizar outra, terá que alterar todo o script para a base com o seu nome.
--We need a Database to store our scripts. I use a database named [Traces] to all of my scripts, if you wish to use another name, you need to replace you database name by [Traces] within the whole script.
GO
	CREATE DATABASE [Traces] 
		ON  PRIMARY ( 
			NAME = N'Traces', FILENAME = N'C:\...\Traces.mdf' , -- Alter to a real path
			SIZE = 102400KB , FILEGROWTH = 102400KB 
		)
		LOG ON ( 
			NAME = N'Traces_log', FILENAME = N'C:\...\Traces_log.ldf',  -- Alter to a real path
			SIZE = 30720KB , FILEGROWTH = 30720KB 
		)
	GO

	ALTER DATABASE [Traces] SET RECOVERY SIMPLE

-------------------------------------------------------------------------------------------------

	USE Traces
	
	-- Tabela para ignorar algumas bases não importantes de algumas rotinas no ambiente, como por exemplo o Checkdb.
	--Table used to ignore some databases from jobs like CheckDB
	
	IF ( OBJECT_ID('[dbo].[Ignore_Databases]') IS NOT NULL )
		DROP TABLE [dbo].Ignore_Databases
		
	CREATE TABLE [dbo].[Ignore_Databases] (
		[Nm_Database] VARCHAR(500)
	)

	-- If you want to ignore some databases, just insert it here.
	-- Se você quiser ignotar alguma database, insira ela aqui.
	INSERT INTO [Ignore_Databases]
	VALUES('Nm_Database1'),('Nm_Database2'),('Nm_Database3') 
	
	
--------------------------------------------------------------------------------------------------------------------------------
--2) Executar alguns scripts de outros arquivos
--2) Execute some scripts from other files
--------------------------------------------------------------------------------------------------------------------------------


-- RUN Script: "2.0 - Create Alert Table.sql"


-- Execute a procedure para criar a tabela com todos as configurações de alertas. Se preciso, esse é o lugar onde vai acertas os valores dos alertas.
-- Execute the procedure to create the Table with all Alert Configurations. If needed, this is the place to change some Alert Configurations. 

-- Mude o parâmetro "Email1@provedor.com;Email2@provedor.com" para os e-mails que vão receber os alertas.
-- Change the parameter "Email@provedor.com" for the Emails that should receive the alerts. 

-- Também mude o parâmetro @Profile para o Database Mail Profile configurado no seu SQL Server.
-- Also change the parameter @Profile for your Database Mail Profile.
USE Traces

exec stpConfiguration_Table 'Email1@provedor.com;Email2@provedor.com', @Profile, @Fl_Language --(1 - Portuguese | 0 -- English)



--Check the Parameters
select * from [dbo].Alert_Parameter


-- RUN Script: "2.1 - Create All Alert Procedures and Jobs.sql"


--Criar os alertas de severidade. Esses alertas não funcionam no Managed Instance do Azure.
--Create the Alerts of Severity. DO NOT run this stored procedure for an Azure Managed Instance Environment. For Azure Managed Instances, please find it at the end of this script.

EXEC stpAlert_Severity


-- Utilize esses scripts para testar os alertas já criados
-- Use this script to test some of the created alerts

EXEC dbo.stpAlert_Every_Day

EXEC dbo.stpTest_Alerts

--------------------------------------------------------------------------------------------------------------------------------
-- 3)	Se tiver interesse, pode criar algumas rotinas adicionais para o seu banco de dados. Você tem que entender o que essas rotinas fazem antes de criar. Tenha cuidado. Se não conhece SQL Server talvez seja melhor pular esse item 3.0 e ir para o item 4 dos scripts.
-- 3)	If you wish, you can create additional jobs and Alerts for your databases. But be carefull, you must be aware about what these routines do before you create it. Also be carefull, If you are not a SQL Server DBA or if you don't have a good doaming of it, maybe you should skip to step 4 of this setup.
--------------------------------------------------------------------------------------------------------------------------------

****** PT BR-> Na dúvida acesse os vídeos explicando cada uma dessas rotinas ******
link:
"*** If you are not confident enough or if it's still not clear, watch below videos about each of these routines.***"
link: English video not available yet

---------------------3.1)  Job to execute a checkdb on databases and an alert if we have some corrupted database. 

--Script: "3.1 - CheckDB - Job and Alert.sql"


---------------------3.2) Profile to monitor what is taking more than 3 seconds to run and an alert if that number is too high in the last five minutes

--Script: "3.2 - Profile Duration - Job and Alert.sql"

-- obs.: Feel free to change for a XEvents here

select * FROM fn_trace_getinfo (null)

------ Test the server side traces
waitfor delay '00:00:05'

--Execute the job
EXEC msdb.dbo.sp_start_job N'DBA - Load Server Side Trace';  

--Confira o resultado
select * from Traces..Queries_Profile


---------------------3.3) XEvent to monitor database errors and a daily alert information about them

--Script: "3.3 - XEvent Error - Job and Alert.sql"

select 1/0

--Run the job
EXEC msdb.dbo.sp_start_job N'DBA - Load XEvent Database Error';  

select * from Traces..Log_DB_Error


---------------------3.4) Store information about index fragmentation daily

--Script: "3.4 - Index Fragmentation History.sql"

--Open the procedure to execute and test (remove the 6 am lock to test)

SELECT * FROM [dbo].[Index_Fragmentation_History]



---------------------3.5) XEvent to monitor database Dealocks and a daily alert information about them

--Script: "3.5 - Deadlock - Job and Alert.sql"

--To Test
create table test1 (id int)

insert into test1 values (1)

create table test2 (id int)

insert into test2 values (2)

-- Connection 1
BEGIN TRAN
	UPDATE test1
	SET id = id

	UPDATE test2
	SET id = id

--commit


-- Connection 2
BEGIN TRAN
	UPDATE test2
	SET id = id

	UPDATE test1
	SET id = id


EXEC msdb.dbo.sp_start_job N'DBA - Load XEvent Deadlock'


SELECT * FROM Traces.[dbo].[Log_DeadLock]

DROP TABLE teste1
DROP TABLE teste2

---------------------3.6) Log to monitor the whoisactive every minute

--Script: "3.6 - Log Whoisactive.sql"

--Test in another connection
WAITFOR DELAY '00:01:00'

--run the job
EXEC msdb.dbo.sp_start_job N'DBA - Load Whoisactive'

SELECT * FROM dbo.Log_Whoisactive


---------------------3.7) If you have a Database Mirroring

--Script: "3.7 - Alert Database Mirroring.sql"

---------------------3.8) If you have a AlwaysON AG

--Script: "3.8 - Alert AlwaysON AG.sql"

---------------------3.9) If you have a Failover Cluster (do not work for SQL 2008 or less)

--Script: "3.9 - Alert Failover Cluster.sql"


--------------------------------------------------------------------------------------------------------------------------------
-- 4) Execute este script para criar o checklist do banco de dados
-- 4) Execute this script to create the database checklist
--------------------------------------------------------------------------------------------------------------------------------

-- RUN Script: "4.0 - Procedures CheckList.sql"

-- Run the checklist job to test
EXEC msdb.dbo.sp_start_job N'DBA - CheckList SQL Server Instance';  



-- Finish!!!


---------------------------------------------------------------------------------------------------------------------------------
-- Scripts Just for Managed Instance 
---------------------------------------------------------------------------------------------------------------------------------
-- If you are creating this scripts on an Azure Managed Instance, you need to disable some alerts and checklist informations.

-- Disable Alerts
update Alert_Parameter
set Fl_Enable = 0
WHERE Nm_Alert IN ('SQL Server Configuration','Database Without Backup','CPU Utilization','Disk Space',
	'Slow File Growth','Database Without Log Backup','Memory Available')

--Disable CheckList Information

UPDATE CheckList_Parameter
SET Fl_Enabled = 0
WHERE Nm_Procedure IN ('stpCheckList_Disk_Space' ,'stpCheckList_AutoGrowth','stpCheckList_Database_Without_Backup','stpCheckList_Backup_Executed','stpCheckList_Traces_Queries')

-- Enable
update Alert_Parameter
set Fl_Enable = 1
WHERE Nm_Alert IN ('CPU Utilization MI')
