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

SET NOCOUNT ON



IF ( OBJECT_ID('[dbo].[stpConfiguration_Table]') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpConfiguration_Table
GO


CREATE procedure stpConfiguration_Table @Ds_Email VARCHAR(MAX),@Ds_Profile_Email VARCHAR(MAX),@Fl_Language bit
AS
BEGIN

	IF ( OBJECT_ID('[dbo].[Alert]') IS NOT NULL )
		DROP TABLE [dbo].[Alert];

	CREATE TABLE [dbo].[Alert] (
		[Id_Alert]				INT IDENTITY PRIMARY KEY,
		[Id_Alert_Parameter]	SMALLINT NOT NULL,
		[Ds_Message] VARCHAR(2000),
		[Fl_Type]				TINYINT,						-- 0: CLEAR / 1: ALERT
		[Dt_Alert]				DATETIME DEFAULT(GETDATE())
	);


	IF ( OBJECT_ID('[dbo].[Alert_Parameter]') IS NOT NULL )
		DROP TABLE [dbo].[Alert_Parameter];

	CREATE TABLE [dbo].[Alert_Parameter] (
		[Id_Alert_Parameter] SMALLINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
		[Nm_Alert] VARCHAR(100) NOT NULL,
		[Nm_Procedure] VARCHAR(100) NOT NULL,
		[Fl_Language] BIT NOT NULL,    --0 - English | 1 - Portuguese
		[Fl_Clear] BIT NOT NULL,
		[Fl_Enable] BIT NOT NULL, 
		[Vl_Parameter] SMALLINT NULL,
		[Ds_Metric] VARCHAR(50) NULL,
		[Vl_Parameter_2] INT,
		[Ds_Metric_2] VARCHAR(50) NULL,
		[Ds_Profile_Email] VARCHAR(200) NULL,
		[Ds_Email] VARCHAR(500) NULL,
		Ds_Message_Alert_ENG varchar(1000),
		Ds_Message_Clear_ENG varchar(1000),
		Ds_Message_Alert_PTB varchar(1000),
		Ds_Message_Clear_PTB varchar(1000),
		Ds_Email_Information_1_ENG VARCHAR(200),
		Ds_Email_Information_2_ENG VARCHAR(200),
		Ds_Email_Information_1_PTB VARCHAR(200),
		Ds_Email_Information_2_PTB VARCHAR(200)
		
	) ON [PRIMARY];

	ALTER TABLE [dbo].[Alert]
	ADD CONSTRAINT FK01_Alert
	FOREIGN KEY ([Id_Alert_Parameter])
	REFERENCES [dbo].[Alert_Parameter] ([Id_Alert_Parameter]);

	
INSERT INTO [dbo].[Alert_Parameter]
		([Nm_Alert], [Nm_Procedure],[Fl_Language], [Fl_Clear],[Fl_Enable], [Vl_Parameter], [Ds_Metric], [Ds_Profile_Email], [Ds_Email],Ds_Message_Alert_ENG,Ds_Message_Clear_ENG,Ds_Message_Alert_PTB,Ds_Message_Clear_PTB,[Ds_Email_Information_1_ENG],[Ds_Email_Information_2_ENG],[Ds_Email_Information_1_PTB],[Ds_Email_Information_2_PTB]) 
VALUES	('Version DB CheckList ',				'2.0',@Fl_Language,									0,1,		NULL,	NULL,			@Ds_Profile_Email,	@Ds_Email,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
		('Version DB Alert ',					'2.0',@Fl_Language,									0,1,		NULL,	NULL,			@Ds_Profile_Email,	@Ds_Email,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
		('Blocked Process',				'stpAlert_Blocked_Process',@Fl_Language,				1,1,		2,		'Minutes',		@Ds_Profile_Email,	@Ds_Email,'ALERT: There are ###1 Blocked Processes for more than ###2 minutes and a total of ###3 Lock(s) on Server: ' ,'CLEAR: There is not a Blocked Process for more than ###1 minutes on Server: ' ,'ALERTA: Existe(m) ###1 Processo(s) Bloqueado(s) a mais de ###2 minuto(s) e um total de ###3 Lock(s) no Servidor:  ','CLEAR: Não existe mais um processo Bloqueado a mais de ###1 minuto(s) no Servidor: ','TOP 50 - Process by Lock Level','TOP 50 - Process Executing on Database','TOP 50 - Processos por Nível de Lock','TOP 50 - Processos executando no Banco de Dados '),
		('Blocked Long Process',		'stpAlert_Blocked_Process',@Fl_Language,			1,1,		20,		'Minutes',		@Ds_Profile_Email,	@Ds_Email,'ALERT: There are ###1 Blocked Processes for more than ###2 minutes and a total of ###3 Lock(s) on Server: ' ,'CLEAR: There is not a Blocked Process for more than ###1 minutes on Server: ' ,'ALERTA: Existe(m) ###1 Processo(s) Bloqueado(s) a mais de ###2 minuto(s) e um total de ###3 Lock(s) no Servidor:  ','CLEAR: Não existe mais um processo Bloqueado a mais de ###1 minuto(s) no Servidor: ','TOP 50 - Process by Lock Level','TOP 50 - Process Executing on Database','TOP 50 - Processos por Nível de Lock','TOP 50 - Processos executando no Banco de Dados '),
		('Log Full',				'stpAlert_Log_Full',@Fl_Language,				1,1,		85,		'Percent',	@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a Log File with more than ###1% used on Server: ','CLEAR: There is not a Log File with more than ###1 % used on Server: ','ALERTA: Existe um Arquivo de Log com mais de ###1% de utilização no Servidor: ','CLEAR: Não existe mais um Arquivo de Log com mais de ###1 % de utilização no Servidor:','Transaction Log Informations','TOP 50 - Process Executing on Database','Informações dos Arquivos de Log','TOP 50 - Processos executando no Banco de Dados'),
		('CPU Utilization',						'stpAlert_CPU_Utilization',@Fl_Language,					1,1,		85,		'Percent',	@Ds_Profile_Email,	@Ds_Email,'ALERT: Cpu utilization is greater than ###1% on Server: ','CLEAR: Cpu utilization is lower than ###1% on Server: ','ALERTA: O Consumo de CPU está acima de ###1% no Servidor: ','CLEAR: O Consumo de CPU está abaixo de ###1% no Servidor: ','CPU Utilization','TOP 50 - Process Executing on Database','Consumo de CPU no Servidor','TOP 50 - Processos executando no Banco de Dados'),
		('Disk Space',					'stpAlert_Disk_Space',@Fl_Language,					1,1,		80,		'Percent',	@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a disk with more than ###1% used on Server: ','CLEAR: There is not a disk with more than ###1% used on Server: ','ALERTA: Existe um disco com mais de ###1% de utilização no Servidor: ','CLEAR: Não existe mais um volume de disco com mais de ###1% de utilização no Servidor: ','Disk Space on Server','TOP 50 - Process Executing on Database','Espaço em Disco no Servidor','TOP 50 - Processos executando no Banco de Dados'),
		('Database Without Backup',				'stpAlert_Database_Without_Backup',@Fl_Language,			0,1,		24,		'Hours',		@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a Database without Backup in the last ###1 Hours on Server: ','','ALERTA: Existem Databases sem Backup nas últimas ###1 Horas no Servidor: ','','Database without Backup in the last ###1 Hours','','Databases sem Backup nas últimas ###1 Horas',''),
		('SQL Server Restarted',			'stpAlert_SQLServer_Restarted',@Fl_Language,			0,1,		20,		'Minutes',		@Ds_Profile_Email,	@Ds_Email,'ALERT: SQL Server restarted in the last ###1 Minutes on Server: ','','ALERTA: SQL Server Reiniciado nos últimos ###1 Minutos no Servidor: ','','SQL Server Restared in the last ###1 minutes','','SQL Server Reiniciado nos últimos ###1 Minutos',''),
		('Trace Creation',			'stpTrace_Creation',@Fl_Language,							0,1,		3,		'Seconds',		@Ds_Profile_Email,	@Ds_Email,'This is not an Alert','','Não é um Alerta. É para a criação do profile de 3 segundos.','',NULL,NULL,NULL,NULL),
		('Slow Queries',				'stpAlert_Slow_Queries',@Fl_Language,				0,0,		500,	'Quantity',	@Ds_Profile_Email,	@Ds_Email,'ALERT: There are ###1 slower queries in the last ###2 minutes on Server: ','','ALERTA: Existem ###1 queries demoradas nos últimos ###2 minutos no Servidor: ','','TOP 50 - Process Executing on Database','TOP 50 - Slow Queries','TOP 50 - Processos executando no Banco de Dados','TOP 50 - Queries Demoradas'),
		('Database Status',					'stpAlert_Database_Status',@Fl_Language,				1,1,		NULL,	NULL,			@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a Database that is not ONLINE on Server: ','CLEAR: All databases are ONLINE on Server: ','ALERTA: Existe uma Database que não está ONLINE no Servidor: ','CLEAR: Não existe mais uma Database que não está ONLINE no Servidor: ','Databases not ONLINE','','Bases que não estão ONLINE ',''),
		('Page Corruption',				'stpAlert_Page_Corruption',@Fl_Language,				0,1,		NULL,	NULL,			@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a corrupted page on a database on Server: ','','ALERTA: Existe uma Página Corrompida no BD no Servidor: ','','Corrupted Pages','','Páginas Corrompidas',''),
		('Database Corruption',		'stpAlert_CheckDB',@Fl_Language,						0,1,		NULL,	NULL,			@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a corrupted database on Server: ','','ALERTA: Existe um Banco de Dados Corrompido no Servidor: ','','Corrupted Database','','Banco de Dados Corrompido',''),
		('Job Failed',						'stpAlert_Job_Failed',@Fl_Language,						0,1,		24,		'Hours',		@Ds_Profile_Email,	@Ds_Email,'ALERT: Jobs failed in the last ###1 Hours on Server: ','','ALERTA: Jobs que Falharam nas últimas ###1 Horas no Servidor: ','','TOP 50 - Failed Jobs',NULL,'TOP 50 - Jobs que Falharam',NULL),
		('Database Created',					'stpAlert_Database_Created',@Fl_Language,				0,1,		24,		'Hours',		@Ds_Profile_Email,	@Ds_Email,'ALERT: Database created in the last ###1 Hours on Server: ','','ALERTA: Database Criada nas últimas ###1 Horas no Servidor: ','','Created Database','Created Database - Data and Log Files','Database Criada','Database Criada - Arquivos de Dados e Log'),
		('Tempdb MDF File Utilization',	'stpAlert_Tempdb_MDF_File_Utilization',@Fl_Language,	1,1,		70,		'Percent',	@Ds_Profile_Email,	@Ds_Email,'ALERT: The Tempdb MDF file is greater than ###1% used on Server: ','CLEAR: The Tempdb MDF file is lower than ###1% used on Server:  ','ALERTA: O Tamanho do Arquivo MDF do Tempdb está acima de ###1% no Servidor: ','CLEAR: O Tamanho do Arquivo MDF do Tempdb está abaixo de ###1% no Servidor: ','Tempdb MDF File Size', 'TOP 50 - Process Executing on Database', 'Tamanho Arquivo MDF Tempdb','TOP 50 - Processos executando no Banco de Dados'),
		('SQL Server Connection',				'stpAlert_SQLServer_Connection',@Fl_Language,				1,1,		5000,	'Quantity',	@Ds_Profile_Email,	@Ds_Email,'ALERT: There are more than ###1 Openned Connections on Server: ','CLEAR: There are not ###1 Openned Connections on Server: ','ALERTA: Existem mais de ###1 Conexões Abertas no SQL Server no Servidor: ','CLEAR: Não existem mais ###1 Conexões Abertas no SQL Server no Servidor: ','TOP 25 - Open Connections on SQL Server','TOP 50 - Process Executing on Database','TOP 25 - Conexões Abertas no SQL Server','TOP 50 - Processos executando no Banco de Dados'),
		('Database Errors',						'stpAlert_Database_Errors',@Fl_Language,						0,0,		1000,	'Quantity',	@Ds_Profile_Email,	@Ds_Email,'ALERT: There are ###1 Errors on the Last Day on Server: ','','ALERTA: Existem ###1 Erros do Banco de Dados Dia Anterior no Servidor: ','','TOP 50 - Database Erros from Yesterday',NULL,'TOP 50 - Erros do Banco de Dados Dia Anterior',NULL),
		('Slow Disk',					'stpAlert_Slow_Disk',@Fl_Language,					0,1,		24,	'Hour',			@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a slow disk message on the Last Day on Server: ','','ALERTA: Existe uma mensagem de lentidão de Disco no Dia Anterior no Servidor: ','','Yesterday Slow Disk Access ',NULL,'Lentidão de Acesso a Disco no Dia Anterior',NULL),
		('Slow Disk Every Hour',		'stpAlert_Slow_Disk',@Fl_Language,					0,0,		1,	'Hour',			@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a slow disk message in the Last Hour on Server: ','','ALERTA: Existe uma mensagem de lentidão de Disco na última Hora no Servidor: ','','Slow Disk Access ',NULL,'Lentidão de Acesso a Disco',NULL),
		('Process Executing',			'stpSend_Mail_Executing_Process',@Fl_Language,		0,1,		NULL,	NULL,			@Ds_Profile_Email,	@Ds_Email,'INFO: SQL Process running Now on Server: ','','INFO: Processos executando no Banco de Dados agora no servidor: ','','TOP 50 - Process Executing on Database',NULL,'Processos em Execução no Banco de Dados',NULL),
		('Database CheckList ',		'stpSend_Mail_CheckList_DBA',@Fl_Language,			0,1,		NULL,	NULL,			@Ds_Profile_Email,	@Ds_Email,'INFO: Database Checklist on Server: ','','INFO: Checklist do Banco de Dados no Servidor: ','',NULL,NULL,NULL,NULL),
		('SQL Server Configuration',			'stpSQLServer_Configuration',@Fl_Language,		0,1,		NULL,	NULL,			@Ds_Profile_Email,	@Ds_Email,'INFO: Database Information on Server: ','','INFO: Informações do Banco de Dados no Servidor: ','',NULL,NULL,NULL,NULL),
		('Long Running Process',				'stpAlert_Long_Runnning_Process',@Fl_Language,				0,1,		2,		'Hours',		@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a Process in execution for more than ###1 Hours on Server: ','','ALERTA: Existe(m) Processo(s) em Execução há mais de ###1 Hora(s) no Servidor: ','','TOP 50 - Process Executing on Database',NULL,'Processos executando no Banco de Dados',NULL),
		('Slow File Growth',			'stpAlert_Slow_File_Growth',@Fl_Language,			0,1,		5,		'Seconds',		@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a slow growth database file on Server: ','','ALERTA: Existe um Crescimento Lento de Arquivo de Base no Servidor: ','','TOP 50 - Database File Growth',NULL,'TOP 50 - Crescimentos de Arquivos Databases',NULL),
		('Alert Without Clear',				'stpAlert_Without_Clear',@Fl_Language,						0,1,		NULL,	NULL,			@Ds_Profile_Email,	@Ds_Email,'ALERT: There is an Openned Alert on Server: ','','ALERTA: Existe(m) Alerta(s) sem Clear no Servidor: ','','Alerts Without CLEAR',NULL,'Alertas sem CLEAR',NULL),
		('Login Failed',					'stpAlert_Login_Failed',@Fl_Language,					0,1,		100,	'Number',			@Ds_Profile_Email,	@Ds_Email,'ALERT: There are failed attempts to login on Server: ','','ALERTA: Existem tentativas de Login com falha no servidor: ','','Logins Failed - SQL Server',NULL,'Falhas de Login - SQL Server',NULL),
		('Database Without Log Backup',			'stpAlert_Database_Without_Log_Backup',@Fl_Language,		1,1,		2,		'Hours',		@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a Database without Log Backup in the last ###1 Hours on Server: ','CLEAR: There is not a Database without Log Backup in the last ###1 Hours on Server: ','ALERTA: Existem Databases sem Backup de Log nas últimas ###1 Horas no Servidor: ','CLEAR: Não Existe Database sem Backup de Log nas últimas ###1 Horas no Servidor: ','Databases Without Log Backup','TOP 50 - Process Executing on Database','Databases sem Backup do Log','TOP 50 - Processos executando no Banco de Dados'),
		('IO Pending',			'stpAlert_IO_Pending',@Fl_Language,		0,1,		5,		'Seconds',		@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a IO Pending for more than ###1 Seconds on Server: ','','ALERTA: Existe uma operação de IO maior que ###1 Segundos pendentes no Servidor: ','','TOP 50 - IO Pending Operation','TOP 50 - Process Executing on Database','TOP 50 - Operações de IO pendentes','TOP 50 - Processos executando no Banco de Dados'),
		('Memory Available',			'stpAlert_Memory_Available',@Fl_Language,		1,1,		2,		'GB',		@Ds_Profile_Email,	@Ds_Email,'ALERT: There are Less than ###1 GB of Memory Available on Server: ','CLEAR: There are More than ###1 GB of Memory Available on Server: ','ALERTA: Existe menos de ###1 GB de Memória Disponivel no Servidor: ','CLEAR: Existe mais de ###1 GB de Memória Disponivel no Servidor: ','Memory Used','TOP 50 - Process Executing on Database','Utilização de Memória','TOP 50 - Processos executando no Banco de Dados'),
		('Job Disabled',			'stpAlert_Job_Disabled',@Fl_Language,		0,1,		NULL,		NULL,		@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a Disabled Job From Yesterday on Server: ','','ALERTA: Existe um Job que foi Desabilitado no Servidor: ','','Jobs Disabled','','Jobs Desabilitados',''),
		('Large LDF File',			'stpAlert_Large_LDF_File',@Fl_Language,		1,1,		50,		'Percent',		@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a LDF File with ###1 % of the MDF File on Server: ','CLEAR: There is not a LDF File with ###1 % of the MDF File on Server:  ','ALERTA: Existe um Arquivo de Log com ###1 % do tamanho do arquivo de Dados no Servidor: ','CLEAR: Não existe um Arquivo de Log com ###1 % do tamanho do arquivo de Dados no Servidor: ','Database File Informations','TOP 50 - Process Executing on Database','Informações dos Arquivos das Bases de Dados','TOP 50 - Processos executando no Banco de Dados'),
		('Rebuild Failed',			'stpAlert_Rebuild_Failed',@Fl_Language,						0,1,		8,		'Hours',		@Ds_Profile_Email,	@Ds_Email,'ALERT: The Rebuild Job failed because Lock Timeout on Server: ','','ALERTA: O Job de Rebuild falhou por causa de Lock no Servidor : ','','Last Lock Registered',NULL,'Último Lock Registrado',NULL),
		('DeadLock',			'stpAlert_DeadLocks',@Fl_Language,						0,0,		24,		'Hours',		@Ds_Profile_Email,	@Ds_Email,'ALERT: We had ###2 DeadLocks in the last ###1 Hours on Server: ','','ALERTA: Aconteceram ###2 DeadLocks as ultimas ###1 Horas no Servidor : ','','DeadLocks Occurrence',NULL,'Ocorrências de DeadLocks',NULL),
		('Database Growth',			'stpAlert_Database_Growth',@Fl_Language,						0,1,		20,		'GB',		@Ds_Profile_Email,	@Ds_Email,'ALERT: We had a large Database Growth in the Last 24 Hours on Server : ','','ALERTA: Tivemos um crescimento grande de base nas últimas 24 horas no Servidor : ','','Database Growth',NULL,'Crescimento da Base',NULL),
		('MaxSize Growth',			'stpAlert_MaxSize_Growth',@Fl_Language,						1,1,		80,		'Percent',	@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a file with more than ###1% of the Maxsize used on Server: ','CLEAR: There is not a file with more than ###1% of the Maxsize used on Server: ','ALERTA: Existe um arquivo com mais de ###1% de utilização do Maxsize no servidor: ','CLEAR: Não existe um arquivo com mais de ###1% de utilização do Maxsize no servidor: ','SQL Server File(s)','TOP 50 - Process Executing on Database','Arquivo(s) do SQL Server','TOP 50 - Processos executando no Banco de Dados'),
		('CPU Utilization MI',  	 'stpAlert_CPU_Utilization_MI',    @Fl_Language,    1,   0,    85,    'Percent', @Ds_Profile_Email,	@Ds_Email,'ALERT: Cpu utilization is greater than ###1% on Server: ','CLEAR: Cpu utilization is lower than ###1% on Server: ',	'ALERTA: O Consumo de CPU está acima de ###1% no Servidor: ',      'CLEAR: O Consumo de CPU está abaixo de ###1% no Servidor: ', 	   'CPU Utilization', 'TOP 50 - Process Executing on Database',  'Consumo de CPU no Servidor',      'TOP 50 - Processos executando no Banco de Dados'),
		('Database Mirroring',  	 'stpAlert_Status_DB_Mirror',    @Fl_Language,    0,   0,    NULL,    NULL, @Ds_Profile_Email,	@Ds_Email,'ALERT: The DB Mirror Status has changed on Server: ','',	'ALERTA: O Status do Database Mirror mudou no Servidor: ',      '', 	   'Database Mirroring Status', '',  'Status do Database Mirroring',      ''),
	    ('Failover Cluster Active Node',  	 'stpAlert_Cluster_Active_Node',    @Fl_Language,    0,   0,    NULL,    NULL, @Ds_Profile_Email,	@Ds_Email,'ALERT: The Failover Cluster Active Node has Changed','',	'ALERTA: O nó ativo do Cluster mudou',      '', 	   'Failover Cluster Nodes Now', '',  'Failover Cluster Nodes agora',      ''),
	    ('Failover Cluster Node Status',  	 'stpAlert_Cluster_Node_Status',    @Fl_Language,    1,   0,    NULL,    NULL, @Ds_Profile_Email,	@Ds_Email,'ALERT: Some Failover Cluster Node are not UP','CLEAR: ALL Failover Cluster Nodes are UP',	'ALERTA: Algum nó do Cluster não está com o status UP',      'CLEAR: Todos os nós do Cluster estão com o status UP', 	   'Failover Cluster Nodes', '',  'Nós do Cluster',      ''),
	    ('AlwaysON AG STATUS',	'stpAlert_AlwaysON_AG_Status',	@Fl_Language,	0,	0,	NULL,		NULL,	@Ds_Profile_Email,	@Ds_Email,'ALERT: The AlwaysON Status are not SYNCHRONIZED and HEALTHY on Server: ','CLEAR: The AlwaysON Status are SYNCHRONIZED and HEALTHY on Server: ',	'ALERTA: O Status do AlwaysON AG está difernete de SYNCHRONIZED e HEALTHY no Servidor: ',	'CLEAR: O Status do AlwaysON AG está como SYNCHRONIZED e HEALTHY no Servidor: ','AlwaysON AG Dadabase Status','TOP 50 - Process Executing on Database',	'Status das bases do AlwaysON AG','TOP 50 - Processos executando no Banco de Dados'),
		('Index Fragmentation','stpAlert_Index_Fragmentation',@Fl_Language,0,0,7,'Days', @Ds_Profile_Email,	@Ds_Email,'ALERT: We have a Index Fragmented for more than ###1 days on Server : ','',	'ALERTA: Temos pelo menos um índice Fragmentado por mais de ###1 dias no Servidor: ',      '', 	   'Indexes Fragmented for a long time', '',  'Indices Fragmentados por muito tempo',      '')

		-- Alert that needs more than one metric			
		UPDATE [dbo].[Alert_Parameter]
		SET
				[Vl_Parameter_2] = 65536, --Index with 500 MB 
				[Ds_Metric_2] = 'Pages'
		WHERE [Nm_Alert] =  'Index Fragmentation';
							
		UPDATE [dbo].[Alert_Parameter]
		SET
				[Vl_Parameter_2] = 1, 
				[Ds_Metric_2] = 'Minute'
		WHERE [Nm_Alert] =  'CPU Utilization MI';
					
		UPDATE [dbo].[Alert_Parameter]
		SET
				[Vl_Parameter_2] = 10, 
				[Ds_Metric_2] = 'GB'
		WHERE [Nm_Alert] IN ('Large LDF File');
		
		UPDATE [dbo].[Alert_Parameter]
		SET
				[Vl_Parameter_2] = 1, --SPID that is generating the lock must be executing for at least 1 minute
				[Ds_Metric_2] = 'minute'
		WHERE [Nm_Alert] IN ('Blocked Process','Blocked Long Process');
		
		UPDATE [dbo].[Alert_Parameter]
		SET
				[Vl_Parameter_2] = 10240, --GB to sent a log alerta
				[Ds_Metric_2] = 'MB'
		WHERE [Nm_Alert] = 'Log Full';

		UPDATE [dbo].[Alert_Parameter]
		SET
				[Vl_Parameter_2] = 10000, 
				[Ds_Metric_2] = 'MB'
		WHERE [Nm_Alert] = 'Tempdb MDF File Utilization';

		UPDATE [dbo].[Alert_Parameter]
		SET
				[Vl_Parameter_2] = 24, 
				[Ds_Metric_2] = 'Hour'
		WHERE [Nm_Alert] = 'Slow File Growth';

		UPDATE [dbo].[Alert_Parameter]
		SET		[Vl_Parameter_2] = 5, 
				[Ds_Metric_2] = 'Minutes'
		WHERE [Nm_Alert] = 'Slow Queries';

		UPDATE [dbo].[Alert_Parameter]
		SET		[Vl_Parameter_2] = 24, 
				[Ds_Metric_2] = 'Hour'
		WHERE [Nm_Alert] = 'Database Errors';

	
		UPDATE [dbo].[Alert_Parameter]
		SET		[Vl_Parameter_2] = 5, 
				[Ds_Metric_2] = 'MB'
		WHERE [Nm_Alert] = 'Slow Disk Every Hour';


		UPDATE [dbo].[Alert_Parameter]
		SET		[Vl_Parameter_2] = 100, 
				[Ds_Metric_2] = 'Quantity'
		WHERE [Nm_Alert] = 'DeadLock';
		
		IF CONVERT(char(20), SERVERPROPERTY('IsClustered')) = 1
			UPDATE [dbo].[Alert_Parameter]
			SET Fl_Enable = 1
			WHERE Nm_Alert IN ('Failover Cluster Active Node','Failover Cluster Node Status')
		
END

--EXEC stpConfiguration_Table 'fabricioflima@gmail.com','MSSQLServer',1
	
--select * from [dbo].Alert_Parameter
GO

if OBJECT_ID('Alert_Cluster_Active_Node') is NOT  NULL
	DROP TABLE Alert_Cluster_Active_Node

	create table Alert_Cluster_Active_Node(
		Nm_Active_server varchar(100))

	insert into Alert_Cluster_Active_Node
	select CONVERT(VARCHAR(100), SERVERPROPERTY('ComputerNamePhysicalNetBIOS'))


if OBJECT_ID('Log_IO_Pending') is  null
	CREATE TABLE [dbo].Log_IO_Pending(
	Id_Log_IO_Pending int identity , 	
	[Nm_Database] [varchar](128) NULL,
	[Physical_Name] [varchar](260) NOT NULL,
	[IO_Pending] [int] NOT NULL,
	[IO_Pending_ms] [bigint] NOT NULL,
	[IO_Type] [varchar](60) NOT NULL,
	[Number_Reads] [bigint] NOT NULL,
	[Number_Writes] [bigint] NOT NULL,
	[Dt_Log] [datetime] NOT NULL
) ON [PRIMARY]


if OBJECT_ID('Alert_Customization') is  null
begin 	
 create table Alert_Customization(
		Id_Alert_Customizations int identity,
		Nm_Alert varchar(100),
		Nm_Procedure varchar(200),
		Ds_Customization varchar(8000))

	ALTER TABLE Alert_Customization
		ADD Dt_Customization DATETIME
		 CONSTRAINT DF_Alert_Customization  DEFAULT (GETDATE())
end

if OBJECT_ID('[Log_DeadLock]') is  not NULL
	DROP TABLE Log_DeadLock
	
CREATE TABLE [dbo].[Log_DeadLock](
	[eventName] [varchar](100) NULL,
	[eventDate] [datetime] NULL,
	[deadlock] [xml] NULL,
	[Nm_Object] [varchar](500) NULL ,
	[Nm_Database] [varchar](500) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

if OBJECT_ID('Queries_Profile') is null

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


	-- Used in Procedure stpAlert_Page_Corruption
	IF ( OBJECT_ID('[dbo].[Suspect_Pages_History]') IS  NULL )
		CREATE TABLE [dbo].[Suspect_Pages_History](
		[database_id] [int] NOT NULL,
		[file_id] [int] NOT NULL,
		[page_id] [bigint] NOT NULL,
		[event_type] [int] NOT NULL,
		[Dt_Corruption] [datetime] NOT NULL
	) ON [PRIMARY]

IF ( OBJECT_ID('[dbo].[Status_Job_SQL_Agent]') IS  NULL )
	
-- Job Status History. Used on Status Job Alerta
	CREATE TABLE Status_Job_SQL_Agent(
		Name VARCHAR(200),
		Dt_Referencia DATE,
		Date_Modified DATETIME,
		Fl_Status BIT)
    
  
if object_id('Table_Size_History') is  null
	CREATE TABLE [dbo].[Table_Size_History] (
		[Id_Size_History] [int] IDENTITY(1,1) NOT NULL,
		[Id_Server] [smallint] NULL,
		[Id_Database] [smallint] NULL,
		[Id_Table] [int] NULL,
		[Nm_Drive] [char](1) NULL,
		[Nr_Total_Size] [numeric](15, 2) NULL,
		[Nr_Data_Size] [numeric](15, 2) NULL,
		[Nr_Index_Size] [numeric](15, 2) NULL,
		[Qt_Rows] [bigint] NULL,
		[Dt_Log] [date] NULL,
		CONSTRAINT [PK_Table_Size_History] PRIMARY KEY CLUSTERED (
			[Id_Size_History] ASC
		) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]


if object_id('User_Database') is  null
	CREATE TABLE [dbo].User_Database (
		[Id_Database] [int] IDENTITY(1,1) NOT NULL,
		[Nm_Database] [varchar](500) NULL,
		CONSTRAINT [PK_User_Database] PRIMARY KEY CLUSTERED (Id_Database)
	) ON [PRIMARY]


if object_id('User_Table') is  null
	CREATE TABLE [dbo].User_Table (
		[Id_Table] [int] IDENTITY(1,1) NOT NULL,
		[Nm_Table] [varchar](1000) NULL,
		CONSTRAINT [PK_User_Table] PRIMARY KEY CLUSTERED (
			[Id_Table] ASC
		) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]	


if object_id('User_Server') is  null

	CREATE TABLE [dbo].User_Server (
		[Id_Server] [int] IDENTITY(1,1) NOT NULL,
		[Nm_Server] [varchar](100) NOT NULL,
		CONSTRAINT [PK_User_Server] PRIMARY KEY CLUSTERED (
			[Id_Server] ASC
		) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]

GO

if object_id('Index_Fragmentation_History') is  null
BEGIN 	
	CREATE TABLE Index_Fragmentation_History(
		[Id_Index_Fragmentation_History] [int] IDENTITY(1,1) NOT NULL,
		[Dt_Log] [date] NULL,
		[Id_Server] [smallint] NULL,
		[Id_Database] [smallint] NULL,
		[Id_Table] [int] NULL,
		[Nm_Index] [varchar](900) NULL,
		Nm_Schema varchar(50),
		[Avg_Fragmentation_In_Percent] [numeric](5, 2) NULL,
		[Page_Count] [int] NULL,
		[Fill_Factor] [tinyint] NULL,
		[Fl_Compression] [tinyint] NULL
	) ON [PRIMARY]


	CREATE NONCLUSTERED INDEX SK01_Index_Fragmentation_History
	ON Index_Fragmentation_History(Dt_Log, Id_Server, Id_Database, Id_Table, Id_Index_Fragmentation_History)
	WITH(FILLFACTOR=95)

	CREATE NONCLUSTERED INDEX SK02_Index_Fragmentation_History 
	ON Index_Fragmentation_History (Id_Table,Nm_Index,Id_Database,Id_Server) 
	WITH(FILLFACTOR=90)
END


IF (OBJECT_ID('[dbo].[File_Utilization_History]') IS  NULL)

	CREATE TABLE [dbo].File_Utilization_History (
		[Nm_Database] [nvarchar](128) NULL,
		[file_id] [smallint] NOT NULL,
		[io_stall_read_ms] [bigint] NOT NULL,
		[num_of_reads] [bigint] NOT NULL,
		[avg_read_stall_ms] [numeric](10, 1) NULL,
		[io_stall_write_ms] [bigint] NOT NULL,
		[num_of_writes] [bigint] NOT NULL,
		[avg_write_stall_ms] [numeric](10, 1) NULL,
		[io_stalls] [bigint] NULL,
		[total_io] [bigint] NULL,
		[avg_io_stall_ms] [numeric](10, 1) NULL,
		[Dt_Log] [datetime] NOT NULL
	) ON [PRIMARY]

GO


if OBJECT_ID('SQL_Counter') is  null
BEGIN

	CREATE TABLE [dbo].SQL_Counter (
		Id_Counter INT identity, 
		Nm_Counter VARCHAR(50) 
	)

	INSERT INTO SQL_Counter (Nm_Counter)
	SELECT 'BatchRequests'
	INSERT INTO SQL_Counter (Nm_Counter)
	SELECT 'User_Connection'
	INSERT INTO SQL_Counter (Nm_Counter)
	SELECT 'CPU'
	INSERT INTO SQL_Counter (Nm_Counter)
	SELECT 'Page Life Expectancy'
	INSERT INTO SQL_Counter (Nm_Counter)
	SELECT 'SQL_Compilations'
	INSERT INTO SQL_Counter (Nm_Counter)
	SELECT 'Page Splits/sec'

END

-- SELECT * FROM SQL_Counter
if OBJECT_ID('Log_Counter') is  null
	CREATE TABLE [dbo].[Log_Counter] (
		[Id_Log_Counter] [int] IDENTITY(1,1) NOT NULL,
		[Dt_Log] [datetime] NULL,
		[Id_Counter] [int] NULL,
		[Value] BIGINT NULL
	) ON [PRIMARY]


if object_id('Index_Fragmentation_History') is not null
	drop table Index_Fragmentation_History

CREATE TABLE Index_Fragmentation_History(
	[Id_Index_Fragmentation_History] [int] IDENTITY(1,1) NOT NULL,
	[Dt_Log] [date] NULL,
	[Id_Server] [smallint] NULL,
	[Id_Database] [smallint] NULL,
	[Id_Table] [int] NULL,
	[Nm_Index] [varchar](1000) NULL,
	Nm_Schema varchar(50),
	[Avg_Fragmentation_In_Percent] [numeric](5, 2) NULL,
	[Page_Count] [int] NULL,
	[Fill_Factor] [tinyint] NULL,
	[Fl_Compression] [tinyint] NULL
) ON [PRIMARY]




if object_id('Waits_Stats_History') is not null
	drop table Waits_Stats_History
GO
CREATE TABLE [dbo].[Waits_Stats_History](
[Id_Waits_Stats_History] [int] IDENTITY(1,1) NOT NULL,
[Dt_Log] [datetime] NULL default(getdate()),
[WaitType] [varchar](60) NOT NULL,
[Wait_S] [decimal](14, 2) NULL,
[Resource_S] [decimal](14, 2) NULL,
[Signal_S] [decimal](14, 2) NULL,
[WaitCount] [bigint]  NULL,
[Percentage] [decimal](4, 2) NULL,
Id_Store int,
CONSTRAINT [PK_Waits_Stats_History] PRIMARY KEY CLUSTERED (		[Id_Waits_Stats_History] ASC	)
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX SK01_Waits_Stats_History ON Waits_Stats_History([WaitType],Id_Waits_Stats_History) 
GO
