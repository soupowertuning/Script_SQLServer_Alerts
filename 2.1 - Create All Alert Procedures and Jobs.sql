
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
  
  
	IF ( OBJECT_ID('[dbo].[HTML_Parameter]') IS NOT NULL )
		DROP TABLE [dbo].HTML_Parameter

	CREATE TABLE HTML_Parameter (
		Company_Link VARCHAR(4000),
		Line_Space VARCHAR(4000),
		Header VARCHAR(4000))

	INSERT INTO HTML_Parameter(Company_Link,Line_Space,Header)
	SELECT '<br />
			<br />'			
			+ 
				'<a href="http://www.fabriciolima.net" target=”_blank”> 
					<img	src="http://www.fabriciolima.net/wp-content/uploads/2019/03/LogoEscura.png"
							height="150" width="400"/>
				</a>',

				'<br />
					<br />',

				'<font color=black bold=true size=5>
						<BR /> HEADERTEXT <BR />
						</font>'	

GO
IF ( OBJECT_ID('dbo.stpSend_Dbmail') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpSend_Dbmail
GO

	CREATE PROCEDURE stpSend_Dbmail @Ds_Profile_Email VARCHAR(200), @Ds_Email VARCHAR(500),@Ds_Subject VARCHAR(500),@Ds_Mail_HTML VARCHAR(MAX),@Ds_BodyFormat VARCHAR(50),@Ds_Importance VARCHAR(50)
			AS					
				EXEC msdb.dbo.sp_send_dbmail
					@profile_name = @Ds_Profile_Email,
					@recipients =	@Ds_Email,
					@subject =		@Ds_Subject,
					@body =			@Ds_Mail_HTML,
					@body_format =	@Ds_BodyFormat,
					@importance =	@Ds_Importance			

GO
GO

IF ( OBJECT_ID('[dbo].[stpExport_Table_HTML_Output]') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpExport_Table_HTML_Output
GO

CREATE PROCEDURE [dbo].[stpExport_Table_HTML_Output]
    @Ds_Tabela [varchar](max),
    @Fl_Aplica_Estilo_Padrao BIT = 1,
	@Ds_Alinhamento VARCHAR(10) = 'left',
	@Ds_OrderBy VARCHAR(MAX) = '',
    @Ds_Saida VARCHAR(MAX) OUTPUT
AS
BEGIN
    /*
		--retirado do código 23/07
		table { padding:0; border-spacing: 0; border-collapse: collapse; }
		
		Autor: Dirceu Resende
		Post: https://www.dirceuresende.com/blog/como-exportar-dados-de-uma-tabela-do-sql-server-para-html/
	*/
			SET NOCOUNT ON
        
			DECLARE
				@query NVARCHAR(MAX),
				@Database sysname,
				@Nome_Tabela sysname

    
    
			IF (LEFT(@Ds_Tabela, 1) = '#')
			BEGIN
				SET @Database = 'tempdb.'
				SET @Nome_Tabela = @Ds_Tabela
			END
			ELSE BEGIN
				SET @Database = LEFT(@Ds_Tabela, CHARINDEX('.', @Ds_Tabela))
				SET @Nome_Tabela = SUBSTRING(@Ds_Tabela, LEN(@Ds_Tabela) - CHARINDEX('.', REVERSE(@Ds_Tabela)) + 2, LEN(@Ds_Tabela))
			END

    
			SET @query = '
			SELECT ORDINAL_POSITION, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE
			FROM ' + @Database + 'INFORMATION_SCHEMA.COLUMNS 
			WHERE TABLE_NAME = ''' + @Nome_Tabela + '''
			ORDER BY ORDINAL_POSITION'
    
    
			IF (OBJECT_ID('tempdb..#Colunas') IS NOT NULL) DROP TABLE #Colunas
			CREATE TABLE #Colunas (
				ORDINAL_POSITION int, 
				COLUMN_NAME sysname, 
				DATA_TYPE nvarchar(128), 
				CHARACTER_MAXIMUM_LENGTH int,
				NUMERIC_PRECISION tinyint, 
				NUMERIC_SCALE int
			)

			INSERT INTO #Colunas
			EXEC(@query)

    
    
			IF (@Fl_Aplica_Estilo_Padrao = 1)
			BEGIN
    
			SET @Ds_Saida = '<html>

		<head>
			<title>Titulo</title>
			<style type="text/css">				

				 table { border: outset 2.25pt; }
                thead { background: #0B0B61; }
                th { color: #fff; padding: 10px;}
                td { padding: 3.0pt 3.0pt 3.0pt 3.0pt; text-align:' + @Ds_Alinhamento + '; }
			</style>
		</head>';
    
			END
       
    
			SET @Ds_Saida = ISNULL(@Ds_Saida, '') + '
		<table border="1" cellpadding="0">
			<thead>
				<tr>'
											

			DECLARE @totalColunas INT 
			SET @totalColunas = (SELECT COUNT(*) FROM #Colunas)

			-- Cabeçalho da tabela
			DECLARE @contadorColuna INT 			
			SET @contadorColuna = 1
						
			declare
				@nomeColuna sysname,
				@tipoColuna sysname
    	
	
			WHILE(@contadorColuna <= @totalColunas)
			BEGIN

				SELECT @nomeColuna = COLUMN_NAME
				FROM #Colunas
				WHERE ORDINAL_POSITION = @contadorColuna


				SET @Ds_Saida = ISNULL(@Ds_Saida, '') + '
					<th>' + @nomeColuna + '</th>'


				SET @contadorColuna = @contadorColuna + 1

			END
			

			SET @Ds_Saida = ISNULL(@Ds_Saida, '') + '
				</tr>
			</thead>
			<tbody>'

    
			-- Conteúdo da tabela

			DECLARE @saida VARCHAR(MAX)

			SET @query = '
		SELECT @saida = (
			SELECT '


			SET @contadorColuna = 1

			WHILE(@contadorColuna <= @totalColunas)
			BEGIN

				SELECT 
					@nomeColuna = COLUMN_NAME,
					@tipoColuna = DATA_TYPE
				FROM 
					#Colunas
				WHERE 
					ORDINAL_POSITION = @contadorColuna



				IF (@tipoColuna IN ('int', 'bigint', 'float', 'numeric', 'decimal', 'bit', 'tinyint', 'smallint', 'integer'))
				BEGIN
        
					SET @query = @query + '
			ISNULL(CAST([' + @nomeColuna + '] AS VARCHAR(MAX)), '''') AS [td]'
    
				END
				ELSE BEGIN
        
					SET @query = @query + '
			ISNULL([' + @nomeColuna + '], '''') AS [td]'
    
				END
    
        
				IF (@contadorColuna < @totalColunas)
					SET @query = @query + ','

        
				SET @contadorColuna = @contadorColuna + 1

			END



			SET @query = @query + '
		FROM ' + @Ds_Tabela + (CASE WHEN ISNULL(@Ds_OrderBy, '') = '' THEN '' ELSE ' 
		ORDER BY ' END) + @Ds_OrderBy + '
		FOR XML RAW(''tr''), Elements
		)'
    
    
			EXEC tempdb.sys.sp_executesql
				@query,
				N'@saida NVARCHAR(MAX) OUTPUT',
				@saida OUTPUT


			-- Identação
			SET @saida = REPLACE(@saida, '<tr>', '
				<tr>')

			SET @saida = REPLACE(@saida, '<td>', '
					<td>')

			SET @saida = REPLACE(@saida, '</tr>', '
				</tr>')


			SET @Ds_Saida = ISNULL(@Ds_Saida, '') + @saida


    
			SET @Ds_Saida = ISNULL(@Ds_Saida, '') + '
			</tbody>
		</table>'
    
            
END

GO


GO
IF ( OBJECT_ID('[dbo].[stpRead_Error_log]') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpRead_Error_log
GO
CREATE PROCEDURE stpRead_Error_log @Actual_Log bit
AS
BEGIN
	SET DATEFORMAT YMD

	IF (OBJECT_ID('tempdb..##Error_Log_Result') IS NOT NULL)
		DROP TABLE ##Error_Log_Result
	
	CREATE TABLE ##Error_Log_Result (
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
		
	IF @Actual_Log = 0 
	BEGIN 
		DELETE FROM #logF
		WHERE ArchiveNumber NOT IN (
			SELECT ArchiveNumber
			FROM #logF
			WHERE (LogDate > DATEADD(hh,-36,GETDATE()) -- many files from 30 hours
					OR ArchiveNumber <= 1) --OR two old files to be faster
		)
	END
		ELSE --@Actual_Log = 1 - most recent 
        	BEGIN 
				DELETE FROM #logF
				WHERE ArchiveNumber <> 0
				
				DECLARE @Vl_Parameter_2 int
				SELECT @Vl_Parameter_2 = Vl_Parameter_2 FROM [Alert_Parameter] 	WHERE [Nm_Alert] = 'Slow Disk Every Hour'
				
				DELETE FROM #logF
				WHERE LogSize >= @Vl_Parameter_2 * 1024*1024-- just look at small logs
			END

	DECLARE @lC INT

	SELECT @lC = MIN(ArchiveNumber) FROM #logF

	WHILE @lC IS NOT NULL
	BEGIN
		  INSERT INTO ##Error_Log_Result
		  EXEC sp_readerrorlog @lC
		  SELECT @lC = MIN(ArchiveNumber) FROM #logF
		  WHERE ArchiveNumber > @lC
	END

END




GO
/****** Object:  StoredProcedure [dbo].[stpWhoIsActive_Result]    Script Date: 20/05/2019 13:23:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF ( OBJECT_ID('[dbo].[stpWhoIsActive_Result]') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpWhoIsActive_Result
	GO
	
	
CREATE PROCEDURE [dbo].[stpWhoIsActive_Result]
AS
BEGIN
		IF ( OBJECT_ID('tempdb..#WhoIsActive_Result') IS NOT NULL )
		DROP TABLE #WhoIsActive_Result
	
	-- Table with the WhoisActive Result that will be used for all Alert Procedures 
	CREATE TABLE #WhoIsActive_Result(		
		[dd hh:mm:ss.mss]		VARCHAR(20),
		[database_name]			VARCHAR(128),		
		[login_name]			VARCHAR(128),
		[host_name]				VARCHAR(128),
		[start_time]			datetime,
		[status]				VARCHAR(30),
		[session_id]			INT,
		[blocking_session_id]	INT,
		[wait_info]				VARCHAR(MAX),
		[open_tran_count]		INT,
		[CPU]					VARCHAR(MAX),
		[CPU_delta]				VARCHAR(MAX),
		[reads]					VARCHAR(MAX),
		[reads_delta]			VARCHAR(MAX),
		[writes]				VARCHAR(MAX),		
		[sql_command]			XML,
		[sql_text]			XML				
	)   
			
	EXEC [dbo].[sp_whoisactive]
			@get_outer_command =	1,
			@delta_interval = 1,
			@output_column_list =	'[dd hh:mm:ss.mss][database_name][login_name][host_name][start_time][status][session_id][blocking_session_id][wait_info][open_tran_count][CPU][CPU_delta][reads][reads_delta][writes][sql_command][sql_text]',
			@destination_table =	'#WhoIsActive_Result'
						
		ALTER TABLE #WhoIsActive_Result
		ALTER COLUMN [sql_command] NVARCHAR(MAX)

		UPDATE #WhoIsActive_Result
		SET [sql_command] = REPLACE( REPLACE( REPLACE( REPLACE( CAST([sql_command] AS NVARCHAR(4000)), '<?query --', ''), '--?>', ''), '&gt;', '>'), '&lt;', '')

		ALTER TABLE #WhoIsActive_Result
		ALTER COLUMN [sql_text] NVARCHAR(MAX)

		UPDATE #WhoIsActive_Result
		SET [sql_text] = REPLACE( REPLACE( REPLACE( REPLACE( CAST([sql_text] AS NVARCHAR(4000)), '<?query --', ''), '--?>', ''), '&gt;', '>'), '&lt;', '')

		IF ( OBJECT_ID('tempdb..##WhoIsActive_Result') IS NOT NULL )
			DROP TABLE ##WhoIsActive_Result
	/*
		CREATE TABLE ##WhoIsActive_Result(		
		[dd hh:mm:ss.mss]		VARCHAR(20),
		[Database]			VARCHAR(128),		
		[Login]			VARCHAR(128),
		[Host Name]				VARCHAR(128),
		[Start Time]			varchar(20),
		[Status]				VARCHAR(30),
		[Session ID]			INT,
		[Blocking Session ID]	INT,
		[Wait Info]				VARCHAR(MAX),
		[Open Tran Count]		INT,
		[CPU]					VARCHAR(MAX),
		[CPU Delta]				VARCHAR(MAX),
		[Reads]					VARCHAR(MAX),
		[Reads Delta]			VARCHAR(MAX),
		[Writes]				VARCHAR(MAX),		
		[Query]				VARCHAR(MAX)
				
	)   
		
	insert into ##WhoIsActive_Result		
	select [dd hh:mm:ss.mss], [database_name], [login_name], [host_name], ISNULL(CONVERT(VARCHAR(20), [start_time], 120), '-') start_time, [status], [session_id], [blocking_session_id], 
	[wait_info], [open_tran_count], [CPU], [CPU_delta], [reads], [reads_delta], [writes], isnull([sql_command],[sql_text]) Query
	from 	#WhoIsActive_Result
	*/


		CREATE TABLE ##WhoIsActive_Result(		
		[dd hh:mm:ss.mss]		CHAR(20),
		[Database]			VARCHAR(128),		
		[Login]			VARCHAR(128),
		[Host Name]				VARCHAR(128),
		[Start Time]			varchar(20),
		[Status]				VARCHAR(30),
		[Session ID]			INT,
		[Blocking Session ID]	INT,
		[Wait Info]				VARCHAR(200),
		[Open Tran Count]		INT,
		[CPU]					VARCHAR(200),
		[CPU Delta]				VARCHAR(200),
		[Reads]					VARCHAR(200),
		[Reads Delta]			VARCHAR(200),
		[Writes]				VARCHAR(200),		
		[Query]			Varchar(300)
				
	)   
		
	insert into ##WhoIsActive_Result		
	select [dd hh:mm:ss.mss], [database_name], [login_name], [host_name], ISNULL(CONVERT(VARCHAR(20), [start_time], 120), '-') start_time, [status], [session_id], [blocking_session_id], 
	substring([wait_info],1,50), [open_tran_count], [CPU], [CPU_delta], [reads], [reads_delta], [writes], substring(isnull([sql_command],[sql_text]),1,100) Query
	from 	#WhoIsActive_Result
				
				
	IF NOT EXISTS ( SELECT TOP 1 * FROM ##WhoIsActive_Result )
	BEGIN
		INSERT INTO ##WhoIsActive_Result
		SELECT NULL, NULL, NULL, NULL, NULL, '-', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL 
	END

		
END

GO

USE [Traces]
GO

IF ( OBJECT_ID('[dbo].stpAlert_Index_Fragmentation') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_Index_Fragmentation
GO
	

CREATE PROCEDURE [dbo].stpAlert_Index_Fragmentation 
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
	WHERE Nm_Alert = 'Index Fragmentation'
	
	IF @Fl_Enable = 0
		RETURN
	
	IF OBJECT_ID('tempdb..#Fragmented_Indexes') IS NOT NULL
		DROP TABLE #Fragmented_Indexes

	select Nm_Database,Nm_Table,Nm_Index,count(*) [Total Days]
	into #Fragmented_Indexes
	from vwIndex_Fragmentation_History
	where Dt_Log >= dateadd(dd,@Vl_Parameter*-1,cast(getdate() as date)) 
	and Page_Count >= @Vl_Parameter_2
	and Avg_Fragmentation_In_Percent > 30 --30% fragmentation
	group by Nm_Database,Nm_Table,Nm_Index

	--select * 
	--from #Fragmented_Indexes
	--where Total = @Total_Days_Log


				
	if exists (
		select null		from #Fragmented_Indexes
		where [Total Days] >= @Vl_Parameter --value default = 7 days
	)
	BEGIN	-- BEGIN - ALERT


			IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
				DROP TABLE ##Email_HTML
							
			select Nm_Database [Database], Nm_Table [Table], Nm_Index [Index], [Total Days] 
			into ##Email_HTML
			from #Fragmented_Indexes
			where [Total Days] >= @Vl_Parameter --value default = 7 days
						 
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter
							
			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   			   		

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[Total Days] DESC',
				@Ds_Saida = @HTML OUT				-- varchar(max)

			SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space 	 + @Company_Link	
		
			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'								
		
			-- Fl_Type = 1 : ALERT	
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 1			
	END
END

GO


IF ( OBJECT_ID('[dbo].[stpAlert_Cluster_Active_Node]') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_Cluster_Active_Node
GO

CREATE PROCEDURE [dbo].stpAlert_Cluster_Active_Node 
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
	WHERE Nm_Alert = 'Failover Cluster Active Node'

	IF @Fl_Enable = 0
		RETURN
		
	declare @Active_Node VARCHAR(200), @Table_Active_Node VARCHAR(200)
	select @Active_Node = CONVERT(VARCHAR(100), SERVERPROPERTY('ComputerNamePhysicalNetBIOS'))
	SELECT @Table_Active_Node = Nm_Active_server FROM Alert_Cluster_Active_Node 
			
	
	IF @Table_Active_Node <> @Active_Node
	BEGIN	

			IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
				DROP TABLE ##Email_HTML
					
			SELECT @Active_Node [Active Node], @Table_Active_Node [Passive Node]
			into ##Email_HTML
			--FROM Alert_Cluster_Active_Node	

			UPDATE Alert_Cluster_Active_Node
			SET Nm_Active_server = @Active_Node
			where Nm_Active_server <> @Active_Node
											 
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter
			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  @Ds_Message_Alert_PTB
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject = @Ds_Message_Alert_ENG
		   END		   		

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				--@Ds_OrderBy = '[Database Name]',
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

IF ( OBJECT_ID('[dbo].[stpAlert_CPU_Utilization_MI]') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_CPU_Utilization_MI
GO

--[dbo].[stpWhoIsActive_Result]
CREATE PROCEDURE [dbo].[stpAlert_CPU_Utilization_MI]
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Id_Alert_Parameter SMALLINT, @Fl_Enable BIT, @Fl_Type TINYINT, @Vl_Parameter SMALLINT,@Ds_Email VARCHAR(500),@Ds_Profile_Email VARCHAR(200),@Dt_Now DATETIME,@Vl_Parameter_2 INT,
		@Ds_Email_Information_1_ENG VARCHAR(200), @Ds_Email_Information_2_ENG VARCHAR(200), @Ds_Email_Information_1_PTB VARCHAR(200), @Ds_Email_Information_2_PTB VARCHAR(200),
		@Ds_Message_Alert_ENG varchar(1000),@Ds_Message_Clear_ENG varchar(1000),@Ds_Message_Alert_PTB varchar(1000),@Ds_Message_Clear_PTB varchar(1000), @Ds_Subject VARCHAR(500)
	
	DECLARE @Company_Link  VARCHAR(4000),@Line_Space VARCHAR(4000),@Header_Default VARCHAR(4000),@Header VARCHAR(4000),@Fl_Language BIT,@Final_HTML VARCHAR(MAX),@HTML VARCHAR(MAX)		

	declare @Ds_Alinhamento VARCHAR(10),@Ds_OrderBy VARCHAR(MAX) 

	
	--IF  OBJECT_ID('tempdb..##WhoIsActive_Result')	IS NULL
	--	return
					
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
	WHERE Nm_Alert = 'CPU Utilization MI'
	
			
	IF @Fl_Enable = 0
		RETURN

	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		

	--------------------------------------------------------------------------------------------------------------------------------
	-- CPU Utilization
	--------------------------------------------------------------------------------------------------------------------------------	
	IF ( OBJECT_ID('tempdb..#CPU_Utilization') IS NOT NULL )
		DROP TABLE #CPU_Utilization
	
	
	DECLARE @Top INT
    SET @Top =  4 * @Vl_Parameter_2 -- 1 minute = 4 rows

	SELECT TOP (@Top) A.*
	INTO #CPU_Utilization
	FROM master.sys.server_resource_stats A 
	WHERE A.start_time >= DATEADD(MINUTE,-15,GETDATE()) --6 minutes of delay from MI
	ORDER BY start_time desc
		
	--	Do we have CPU problem?	
	IF (
			SELECT COUNT(*)
			FROM #CPU_Utilization
			WHERE avg_cpu_percent > @Vl_Parameter
		) = @Top
	BEGIN	
			IF ISNULL(@Fl_Type, 0) = 0	-- Control Alert/Clear
			BEGIN
				IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
					DROP TABLE ##Email_HTML
						
				SELECT ISNULL(CONVERT(VARCHAR(20), GETDATE(), 120), '-')  [Alert Time],ISNULL(CONVERT(VARCHAR(20), [start_time], 120), '-')  [Log Azure Time],
					resource_name [Resource],sku,virtual_core_count [vCores],avg_cpu_percent [** CPU (%) **],io_requests [IO Request],io_bytes_read [IO bytes Read],io_bytes_written [IO Bytes Written]
				INTO ##Email_HTML
				FROM #CPU_Utilization
							
			
				IF ( OBJECT_ID('tempdb..##Email_HTML_2') IS NOT NULL )
					DROP TABLE ##Email_HTML_2	
				 	
				SELECT TOP 50 *
				INTO ##Email_HTML_2
				FROM ##WhoIsActive_Result		
				 
				-- Get HTML Informations
				SELECT @Company_Link = Company_Link,
					@Line_Space = Line_Space,
					@Header_Default = Header
				FROM HTML_Parameter
			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		
		   			 
			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML',	
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[Log Azure Time] DESC',
				
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
		END
	END		-- END - ALERT
	
	ELSE 
	BEGIN	-- BEGIN - CLEAR				
		IF @Fl_Type = 1
		BEGIN			
			
			IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR') IS NOT NULL )
					DROP TABLE ##Email_HTML_CLEAR
											
				SELECT ISNULL(CONVERT(VARCHAR(20), GETDATE(), 120), '-')  [Alert Time],ISNULL(CONVERT(VARCHAR(20), [start_time], 120), '-')  [Log Azure Time],
					resource_name [Resource],sku,virtual_core_count [vCores],avg_cpu_percent [** CPU (%) **],io_requests [IO Request],io_bytes_read [IO bytes Read],io_bytes_written [IO Bytes Written]
				INTO ##Email_HTML_CLEAR
				FROM #CPU_Utilization
											
			
				IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR_2') IS NOT NULL )
					DROP TABLE ##Email_HTML_CLEAR_2	
				 	
				SELECT TOP 50 *
				INTO ##Email_HTML_CLEAR_2
				FROM ##WhoIsActive_Result
			
				 
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter
			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_CLEAR', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[Log Azure Time] DESC',
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
USE [Traces]
GO


GO
IF ( OBJECT_ID('[dbo].[stpAlert_MaxSize_Growth]') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_MaxSize_Growth
GO
--[dbo].[stpWhoIsActive_Result]
CREATE PROCEDURE [dbo].stpAlert_MaxSize_Growth 
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
	WHERE Nm_Alert = 'MaxSize Growth'


	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		


	IF (OBJECT_ID('tempdb..##Alert_MDFs_Sizes') IS NOT NULL)
		DROP TABLE ##Alert_MDFs_Sizes
			
	CREATE TABLE ##Alert_MDFs_Sizes (
		[Server]			VARCHAR(500),
		[Nm_Database]		VARCHAR(500),
		[Logical_Name]		VARCHAR(500),
		[Type]		VARCHAR(500),
		[Max_Size]			NUMERIC(15,2),
		[Size]				NUMERIC(15,2),
		[Total_Used]	NUMERIC(15,2),
		[Free_Space (MB)] NUMERIC(15,2),
		[Percent_Free] NUMERIC(15,2)
	)

	EXEC sp_MSforeachdb '
		Use [?]

			;WITH cte_datafiles AS 
			(
			  SELECT name, size = size/128.0,max_size,type_desc FROM sys.database_files
			),
			cte_datainfo AS
			(
			  SELECT	name,type_desc, max_size,CAST(size as numeric(15,2)) as size, 
						CAST( (CONVERT(INT,FILEPROPERTY(name,''SpaceUsed''))/128.0) as numeric(15,2)) as used, 
						free = CAST( (size - (CONVERT(INT,FILEPROPERTY(name,''SpaceUsed''))/128.0)) as numeric(15,2))
			  FROM cte_datafiles
			)

			INSERT INTO ##Alert_MDFs_Sizes
			SELECT	@@SERVERNAME, DB_NAME(), name as [Logical_Name],type_desc, (max_size * 8)/1024.00 max_size,size, used, free,
					percent_free = case when size <> 0 then cast((free * 100.0 / size) as numeric(15,2)) else 0 end
			FROM cte_datainfo	
			where max_size <> -1 AND max_size < 268435456
	'	

	--select Nm_Database, Logical_Name, [Type], Size,Total_Used,[Free_Space (MB)],Percent_Free, Max_Size
	--from ##Alert_MDFs_Sizes
	--WHERE  Size > Max_Size * (@Vl_Parameter/100.00)

			
	--	Do we have maxsize problem?
	IF EXISTS	(
				select Nm_Database, Logical_Name, [Type], Size,Total_Used,[Free_Space (MB)],Percent_Free, Max_Size
				from ##Alert_MDFs_Sizes
				WHERE  Size > Max_Size * (@Vl_Parameter/100.00)
				)
	BEGIN	-- BEGIN - ALERT


		IF ISNULL(@Fl_Type, 0) = 0	-- Control Alert/Clear
		BEGIN
			IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
				DROP TABLE ##Email_HTML

			-- Databases with Log FULL
			
			select Nm_Database [Database], Logical_Name [Logical Name], [Type], Size,Total_Used [Total Used (MB)],[Free_Space (MB)] [Free Space (MB)],Percent_Free [Free Space (%)], Max_Size [Max Size (MB)]
			INTO ##Email_HTML
			from ##Alert_MDFs_Sizes
			WHERE  Size > Max_Size * (@Vl_Parameter/100.00)			
				
								
			IF ( OBJECT_ID('tempdb..##Email_HTML_2') IS NOT NULL )
				DROP TABLE ##Email_HTML_2	
				 	
			SELECT TOP 50 *
			INTO ##Email_HTML_2
			FROM ##WhoIsActive_Result
	
				 
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter
			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[Total Used (MB)]',
				@Ds_Saida = @HTML OUT				-- varchar(max)

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

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'								
		
			-- Fl_Type = 1 : ALERT	
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 1			
		END
	END		-- END - ALERT
	ELSE 
	BEGIN	-- BEGIN - CLEAR				
		IF @Fl_Type = 1
		BEGIN			
			
			IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR') IS NOT NULL )
				DROP TABLE ##Email_HTML_CLEAR					
			
			select Nm_Database [Database], Logical_Name [Logical Name], [Type], Size,Total_Used [Total Used (MB)],[Free_Space (MB)] [Free Space (MB)],Percent_Free [Free Space (%)], Max_Size [Max Size (MB)]
			INTO ##Email_HTML_CLEAR
			from ##Alert_MDFs_Sizes	
			
			IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR_2') IS NOT NULL )
				DROP TABLE ##Email_HTML_CLEAR_2					
						
			SELECT TOP 50 *
			INTO ##Email_HTML_CLEAR_2
			FROM ##WhoIsActive_Result

				 
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				  SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		
		
			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_CLEAR', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[Total Used (MB)]',
				@Ds_Saida = @HTML OUT				-- varchar(max)

				   -- First Result
			SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space 	

			IF @Fl_Language = 1
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_PTB)
			ELSE 
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_ENG)			
				

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_CLEAR_2', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[dd hh:mm:ss.mss] desc',
				@Ds_Saida = @HTML OUT				-- varchar(max)
		
		-- Second Result
			SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space + @Company_Link		

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'	
			
			-- Fl_Type = 0 : CLEAR
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 0		
		END		
	END		-- END - CLEAR
END


GO

IF ( OBJECT_ID('[dbo].stpAlert_Database_Growth') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_Database_Growth
GO
USE [Traces]
GO
/****** Object:  StoredProcedure [dbo].[stpAlert_Database_Growth]    Script Date: 08/08/2019 08:04:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stpAlert_Database_Growth]
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
	WHERE Nm_Alert = 'Database Growth'
		

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
		
	if OBJECT_ID('Tempdb..#Alert_Database_Growth') is not null
		DROP table #Alert_Database_Growth

	select B.[Nm_Server], [Nm_Database],
			SUM(CASE WHEN [Dt_Log] = cast(getdate()-1 as date) THEN A.[Nr_Total_Size] ELSE 0 END) AS [Size Yesterday],
			SUM(CASE WHEN [Dt_Log] = cast(getdate() as date)   THEN A.[Nr_Total_Size] ELSE 0 END) AS [Size Today],
			SUM(CASE WHEN [Dt_Log] = cast(getdate() as date)   THEN A.[Nr_Total_Size] ELSE 0 END) 
			- SUM(CASE WHEN [Dt_Log] = cast(getdate()-1 as date) THEN A.[Nr_Total_Size] ELSE 0 END) [Growth (MB)],
			(SUM(CASE WHEN [Dt_Log] = cast(getdate() as date)   THEN A.[Nr_Total_Size] ELSE 0 END) 
			- SUM(CASE WHEN [Dt_Log] = cast(getdate()-1 as date) THEN A.[Nr_Total_Size] ELSE 0 END) )/
			case when SUM(CASE WHEN [Dt_Log] = cast(getdate()-1 as date) THEN A.[Nr_Total_Size] ELSE 0 END) * 100.00 = 0 
				then 1
				else  SUM(CASE WHEN [Dt_Log] = cast(getdate()-1 as date) THEN A.[Nr_Total_Size] ELSE 0 END) * 100.00 
				end
			[Growth (%)]
	into #Alert_Database_Growth
	FROM [dbo].[Table_Size_History] A
		JOIN [dbo].User_Server B ON A.[Id_Server] = B.[Id_Server] 
		JOIN [dbo].User_Table C ON A.[Id_Table] = C.[Id_Table]
		JOIN [dbo].User_Database D ON A.[Id_Database] = D.[Id_Database]
	WHERE	A.[Dt_Log] >= getdate()-2
		AND B.Nm_Server = @@SERVERNAME		
	GROUP BY B.[Nm_Server], [Nm_Database]
	
	if OBJECT_ID('Tempdb..#High_Growth') is not null
		DROP table #High_Growth

	select [Nm_Database],
			[Size Yesterday], [Size Today], [Growth (MB)],[Growth (%)],
			case when [Size Yesterday] < 100000 and [Growth (%)] > 40 then 1
			when [Size Yesterday] > 100000 and [Growth (%)] > 30 then 1
			when [Size Yesterday] > 300000 and [Growth (%)] > 20 then 1
			when [Size Yesterday] > 500000 and [Growth (%)] > 10 then 1			
			else 0
			end [High Growth]
	into #High_Growth
	from #Alert_Database_Growth
	WHERE [Size Yesterday] > @Vl_Parameter * 1024 
		
					
	IF exists (select null from #High_Growth where [High Growth] = 1) 
	BEGIN
		
		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
			DROP TABLE ##Email_HTML

		SELECT	*
		into ##Email_HTML
		FROM #High_Growth
		where [High Growth] = 1
						 
		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter			
						
		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				SET @Ds_Subject =  @Ds_Message_Alert_PTB + @@SERVERNAME 
		END
        ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
			SET @Ds_Subject =  @Ds_Message_Alert_ENG+@@SERVERNAME 
		END		 

		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)			
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Growth (%)] DESC',
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
IF ( OBJECT_ID('[dbo].[stpAlert_CPU_Utilization]') IS NOT NULL ) 
	DROP PROCEDURE [dbo].[stpAlert_CPU_Utilization]
GO

CREATE PROCEDURE [dbo].[stpAlert_CPU_Utilization]
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Id_Alert_Parameter SMALLINT, @Fl_Enable BIT, @Fl_Type TINYINT, @Vl_Parameter SMALLINT,@Ds_Email VARCHAR(500),@Ds_Profile_Email VARCHAR(200),@Dt_Now DATETIME,@Vl_Parameter_2 INT,
		@Ds_Email_Information_1_ENG VARCHAR(200), @Ds_Email_Information_2_ENG VARCHAR(200), @Ds_Email_Information_1_PTB VARCHAR(200), @Ds_Email_Information_2_PTB VARCHAR(200),
		@Ds_Message_Alert_ENG varchar(1000),@Ds_Message_Clear_ENG varchar(1000),@Ds_Message_Alert_PTB varchar(1000),@Ds_Message_Clear_PTB varchar(1000), @Ds_Subject VARCHAR(500)
	
	DECLARE @Company_Link  VARCHAR(4000),@Line_Space VARCHAR(4000),@Header_Default VARCHAR(4000),@Header VARCHAR(4000),@Fl_Language BIT,@Final_HTML VARCHAR(MAX),@HTML VARCHAR(MAX)		

	declare @Ds_Alinhamento VARCHAR(10),@Ds_OrderBy VARCHAR(MAX) 

	
	--IF  OBJECT_ID('tempdb..##WhoIsActive_Result')	IS NULL
	--	return
					
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
	WHERE Nm_Alert = 'CPU Utilization'
	
			
	IF @Fl_Enable = 0
		RETURN

	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		

	--------------------------------------------------------------------------------------------------------------------------------
	-- CPU Utilization
	--------------------------------------------------------------------------------------------------------------------------------	
	IF ( OBJECT_ID('tempdb..#CPU_Utilization') IS NOT NULL )
		DROP TABLE #CPU_Utilization
	
	SELECT TOP(2)
		record_id,
		[SQLProcessUtilization],
		100 - SystemIdle - SQLProcessUtilization as OtherProcessUtilization,
		[SystemIdle],
		100 - SystemIdle AS CPU_Utilization
	INTO #CPU_Utilization
	FROM	( 
				SELECT	record.value('(./Record/@id)[1]', 'int')													AS [record_id], 
						record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int')			AS [SystemIdle],
						record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int')	AS [SQLProcessUtilization], 
						[timestamp] 
				FROM ( 
						SELECT [timestamp], CONVERT(XML, [record]) AS [record] 
						FROM [sys].[dm_os_ring_buffers] 
						WHERE	[ring_buffer_type] = N'RING_BUFFER_SCHEDULER_MONITOR' 
								AND [record] LIKE '%<SystemHealth>%'
					) AS X					   
			) AS Y
	ORDER BY record_id DESC

	
	--	Do we have CPU problem?	
	IF (
			select CPU_Utilization from #CPU_Utilization
			where record_id = (select max(record_id) from #CPU_Utilization)
		) > @Vl_Parameter
	BEGIN	
		IF (
			select CPU_Utilization from #CPU_Utilization
			where record_id = (select min(record_id) from #CPU_Utilization)
		) > @Vl_Parameter
		BEGIN
			IF ISNULL(@Fl_Type, 0) = 0	-- Control Alert/Clear
			BEGIN
				IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
					DROP TABLE ##Email_HTML
						
				-- CPU Information
				select	TOP 1
						CAST([SQLProcessUtilization] AS VARCHAR) [SQL Process (%)],
						CAST((100 - SystemIdle - SQLProcessUtilization) AS VARCHAR) as [Other Process (%)],
						CAST([SystemIdle] AS VARCHAR) AS [System Idle (%)],
						CAST(100 - SystemIdle AS VARCHAR) AS [CPU Utilization (%)]
				INTO ##Email_HTML
				from #CPU_Utilization
				order by record_id DESC							
			
				IF ( OBJECT_ID('tempdb..##Email_HTML_2') IS NOT NULL )
					DROP TABLE ##Email_HTML_2	
				 	
				SELECT TOP 50 *
				INTO ##Email_HTML_2
				FROM ##WhoIsActive_Result		
				 
				-- Get HTML Informations
				SELECT @Company_Link = Company_Link,
					@Line_Space = Line_Space,
					@Header_Default = Header
				FROM HTML_Parameter
			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		
		   			 
			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML',	
				@Ds_Alinhamento  = 'center',
				--@Ds_OrderBy = '[dd hh:mm:ss.mss] desc',
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

				EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'								
		
			-- Fl_Type = 1 : ALERT	
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 1			
		END
	END		-- END - ALERT
	END
	ELSE 
	BEGIN	-- BEGIN - CLEAR				
		IF @Fl_Type = 1
		BEGIN			
			
			IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR') IS NOT NULL )
					DROP TABLE ##Email_HTML_CLEAR
						
				-- CPU Information
				select	TOP 1
						CAST([SQLProcessUtilization] AS VARCHAR) [SQL Process (%)],
						CAST((100 - SystemIdle - SQLProcessUtilization) AS VARCHAR) as [Other Process (%)],
						CAST([SystemIdle] AS VARCHAR) AS [System Idle (%)],
						CAST(100 - SystemIdle AS VARCHAR) AS [CPU Utilization (%)]
				INTO ##Email_HTML_CLEAR
				from #CPU_Utilization
				order by record_id DESC							
			
				IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR_2') IS NOT NULL )
					DROP TABLE ##Email_HTML_CLEAR_2	
				 	
				SELECT TOP 50 *
				INTO ##Email_HTML_CLEAR_2
				FROM ##WhoIsActive_Result
			
				 
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter
			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_CLEAR', -- varchar(max)
				@Ds_Alinhamento  = 'center',
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

				EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'	

			-- Fl_Type = 0 : CLEAR
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 0		
		END		
	END		-- END - CLEAR	

END
GO

GO
IF ( OBJECT_ID('[dbo].[stpAlert_Blocked_Process]') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_Blocked_Process
GO
USE [Traces]
GO
/****** Object:  StoredProcedure [dbo].[stpAlert_Blocked_Process]    Script Date: 7/29/2019 5:01:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stpAlert_Blocked_Process] @Nm_Alert varchar(50)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Id_Alert_Parameter SMALLINT, @Fl_Enable BIT, @Fl_Type TINYINT, @Vl_Parameter SMALLINT,@Ds_Email VARCHAR(500),@Ds_Profile_Email VARCHAR(200),@Dt_Now DATETIME,@Vl_Parameter_2 SMALLINT,
		@Ds_Email_Information_1_ENG VARCHAR(200), @Ds_Email_Information_2_ENG VARCHAR(200), @Ds_Email_Information_1_PTB VARCHAR(200), @Ds_Email_Information_2_PTB VARCHAR(200),
		@Ds_Message_Alert_ENG varchar(1000),@Ds_Message_Clear_ENG varchar(1000),@Ds_Message_Alert_PTB varchar(1000),@Ds_Message_Clear_PTB varchar(1000), @Ds_Subject VARCHAR(500)
	
	DECLARE @Company_Link  VARCHAR(4000),@Line_Space VARCHAR(4000),@Header_Default VARCHAR(4000),@Header VARCHAR(4000),@Fl_Language BIT,@Final_HTML VARCHAR(MAX),@HTML VARCHAR(MAX)		
	
	DECLARE @Ds_Alinhamento VARCHAR(10),@Ds_OrderBy VARCHAR(MAX) 							

	
			
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
	WHERE Nm_Alert = @Nm_Alert --'Blocked Process' or 'Blocked Long Process'

	IF @Fl_Enable = 0
		RETURN
		
	SELECT *
	INTO #WhoIsActive_Result_Lock
	FROM ##WhoIsActive_Result

	
	--	Lock Level used only on Who
	ALTER TABLE #WhoIsActive_Result_Lock
	ADD Lock_Level TINYINT 


	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	

	--	Do we have some lock?
	IF EXISTS	(
					SELECT NULL 
					FROM #WhoIsActive_Result_Lock A
					JOIN #WhoIsActive_Result_Lock B ON A.[Blocking Session ID] = B.[Session ID]
					WHERE	DATEDIFF(SECOND,A.[Start Time], @Dt_Now) > @Vl_Parameter * 60			-- SPID suffering the lock
							AND DATEDIFF(SECOND,B.[Start Time], @Dt_Now) > @Vl_Parameter_2 * 60		-- SPID generating the lock
				)
	BEGIN	-- BEGIN - ALERT


		IF ISNULL(@Fl_Type, 0) = 0	-- Control Alert/Clear
		BEGIN
	
			--	How Many lock do we have?	
			DECLARE @Processes_with_Long_Lock INT = (
										SELECT COUNT(*)
										FROM #WhoIsActive_Result_Lock A
										JOIN #WhoIsActive_Result_Lock B ON A.[Blocking Session ID] = B.[Session ID]
										WHERE	DATEDIFF(SECOND,A.[Start Time], @Dt_Now) > @Vl_Parameter	* 60
												AND DATEDIFF(SECOND,B.[Start Time], @Dt_Now) > @Vl_Parameter_2 * 60
									)
			
			DECLARE @Total_Processes_Lock INT = (
													SELECT COUNT(*)
													FROM #WhoIsActive_Result_Lock A
													WHERE [Blocking Session ID] IS NOT NULL
												)
			--drop table #WhoIsActive_Result_Lock			 


			-- Nivel 0
			UPDATE A
			SET Lock_Level = 0
			FROM #WhoIsActive_Result_Lock A
			WHERE [Blocking Session ID] IS NULL AND [Session ID] IN ( SELECT DISTINCT [Blocking Session ID] 
						FROM #WhoIsActive_Result_Lock WHERE [Blocking Session ID] IS NOT NULL)

			UPDATE A
			SET Lock_Level = 1
			FROM #WhoIsActive_Result_Lock A
			WHERE	Lock_Level IS NULL
					AND [Blocking Session ID] IN ( SELECT DISTINCT [Session ID] FROM #WhoIsActive_Result_Lock WHERE Lock_Level = 0)

			UPDATE A
			SET Lock_Level = 2
			FROM #WhoIsActive_Result_Lock A
			WHERE	Lock_Level IS NULL
					AND [Blocking Session ID] IN ( SELECT DISTINCT [Session ID] FROM #WhoIsActive_Result_Lock WHERE Lock_Level = 1)

			UPDATE A
			SET Lock_Level = 3
			FROM #WhoIsActive_Result_Lock A
			WHERE	Lock_Level IS NULL
					AND [Blocking Session ID] IN ( SELECT DISTINCT [Session ID] FROM #WhoIsActive_Result_Lock WHERE Lock_Level = 2)

			
			-- When we have two process blocking each other on whoisactive
			IF NOT EXISTS(select * from #WhoIsActive_Result_Lock where Lock_Level IS NOT NULL)
			BEGIN
				UPDATE A
				SET Lock_Level = 0
				FROM #WhoIsActive_Result_Lock A
				WHERE [Session ID] IN ( SELECT DISTINCT [Blocking Session ID] 
					FROM #WhoIsActive_Result_Lock WHERE [Blocking Session ID] IS NOT NULL)
          
				UPDATE A
				SET Lock_Level = 1
				FROM #WhoIsActive_Result_Lock A
				WHERE	Lock_Level IS NULL
						AND [Blocking Session ID] IN ( SELECT DISTINCT [Session ID] FROM #WhoIsActive_Result_Lock WHERE Lock_Level = 0)

				UPDATE A
				SET Lock_Level = 2
				FROM #WhoIsActive_Result_Lock A
				WHERE	Lock_Level IS NULL
						AND [Blocking Session ID] IN ( SELECT DISTINCT [Session ID] FROM #WhoIsActive_Result_Lock WHERE Lock_Level = 1)

				UPDATE A
				SET Lock_Level = 3
				FROM #WhoIsActive_Result_Lock A
				WHERE	Lock_Level IS NULL
						AND [Blocking Session ID] IN ( SELECT DISTINCT [Session ID] FROM #WhoIsActive_Result_Lock WHERE Lock_Level = 2)
			END
				
			IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
				DROP TABLE ##Email_HTML
						
			SELECT TOP 50 *
			INTO ##Email_HTML
			FROM #WhoIsActive_Result_Lock
			WHERE Lock_Level IS NOT NULL
		
			 	
			IF ( OBJECT_ID('tempdb..##Email_HTML_2') IS NOT NULL )
				DROP TABLE ##Email_HTML_2	

			SELECT TOP 50 *
			INTO ##Email_HTML_2
			FROM #WhoIsActive_Result_Lock

				 
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter
			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  REPLACE(REPLACE(REPLACE(@Ds_Message_Alert_PTB,'###1',@Processes_with_Long_Lock),'###2',@Vl_Parameter) ,'###3',@Total_Processes_Lock)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(REPLACE(REPLACE(@Ds_Message_Alert_ENG,'###1',@Processes_with_Long_Lock),'###2',@Vl_Parameter) ,'###3',@Total_Processes_Lock)+@@SERVERNAME 
		   END		   		

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[Lock_Level],[dd hh:mm:ss.mss] DESC, [Start Time]',
				@Ds_Saida = @HTML OUT				-- varchar(max)



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
		END
	END		-- END - ALERT
	ELSE 
	BEGIN	-- BEGIN - CLEAR				
		IF @Fl_Type = 1
		BEGIN			
			
			IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR') IS NOT NULL )
				DROP TABLE ##Email_HTML_CLEAR				
							
			SELECT TOP 50 *
			INTO ##Email_HTML_CLEAR
			FROM #WhoIsActive_Result_Lock
		
				 
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_PTB)
				  SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		

			
			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_CLEAR', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[dd hh:mm:ss.mss] desc',

				@Ds_Saida = @HTML OUT				-- varchar(max)

			-- First Result
			SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space + @Company_Link									 			

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
IF ( OBJECT_ID('[dbo].[stpAlert_Database_Status]') IS NOT NULL )
	DROP PROCEDURE [dbo].stpAlert_Database_Status
GO
CREATE PROCEDURE [dbo].[stpAlert_Database_Status] 
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
	WHERE Nm_Alert = 'Database Status'
	
		
	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	

	IF(OBJECT_ID('tempdb..#Temp_Database_Status') IS NOT NULL) 
		DROP TABLE #Temp_Database_Status

	SELECT [name], [state_desc]
	INTO #Temp_Database_Status
	FROM [sys].[databases]
	WHERE [state_desc] NOT IN ('ONLINE','RESTORING')


	--	Do we have log Full?
	IF EXISTS	(
				SELECT TOP 1 [name]
				FROM #Temp_Database_Status
				)
	BEGIN	-- BEGIN - ALERT


		IF ISNULL(@Fl_Type, 0) = 0	-- Control Alert/Clear
		BEGIN
			IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
				DROP TABLE ##Email_HTML

						
			SELECT [name] [Database Name], [state_desc] [Status]
			INTO ##Email_HTML
			FROM #Temp_Database_Status						
						
			CREATE CLUSTERED INDEX SK01_##Email_HTML ON ##Email_HTML([Database Name])
			
			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_Saida = @HTML OUT				-- varchar(max)			
					 
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter
			
			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  @Ds_Message_Alert_PTB + @@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  @Ds_Message_Alert_ENG + @@SERVERNAME 
		   END		   	
		  	
			-- First Result
			SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space + @Company_Link						

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'								
		
			
			-- Fl_Type = 1 : ALERT	
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 1			
		END
	END		-- END - ALERT
	ELSE 
	BEGIN	-- BEGIN - CLEAR				
		IF @Fl_Type = 1
		BEGIN		

			IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR') IS NOT NULL )
				DROP TABLE ##Email_HTML_CLEAR					
				
			SELECT [name] [Database Name], [state_desc] [Status]
			INTO ##Email_HTML_CLEAR
			FROM [sys].[databases]
									
			CREATE CLUSTERED INDEX SK01_##Email_HTML_CLEAR ON ##Email_HTML_CLEAR([Database Name])
				 
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				  SET @Ds_Subject =  @Ds_Message_Clear_PTB + @@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  @Ds_Message_Clear_ENG + @@SERVERNAME 
		   END		   		

			
			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_CLEAR', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_Saida = @HTML OUT				-- varchar(max)

			-- First Result
			SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space + @Company_Link									 			

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'								
		
					
			-- Fl_Type = 0 : CLEAR
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 0		
		END		
	END		-- END - CLEAR

END

GO


/*******************************************************************************************************************************
--	ALERTA: DATABASE SEM BACKUP LOG
*******************************************************************************************************************************/
IF ( OBJECT_ID('[dbo].stpAlert_Database_Without_Log_Backup') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_Database_Without_Log_Backup
GO
CREATE PROCEDURE [dbo].stpAlert_Database_Without_Log_Backup
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
	WHERE Nm_Alert = 'Database Without Log Backup'

	IF @Fl_Enable = 0
		RETURN
	
	
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		

	IF ( OBJECT_ID('tempdb..#Alert_Log_Backup_Database') IS NOT NULL)
		DROP TABLE #Alert_Log_Backup_Database

	SELECT DISTINCT [database_name] AS [Nm_Database], MAX(backup_start_date) as [Data_Backup]
	INTO #Alert_Log_Backup_Database
	FROM [msdb].[dbo].[backupset] B
	JOIN [msdb].[dbo].[backupmediafamily] BF ON B.[media_set_id] = BF.[media_set_id]
	JOIN sys.databases C ON C.name = [database_name]
	WHERE	[type] IN ('L')
		and backup_start_date >= getdate()-2
	Group By database_name				

	--	Do we have backup problems?	
	IF EXISTS (SELECT null FROM #Alert_Log_Backup_Database
				Where DATEDIFF(HH,Data_Backup,GETDATE()) >= @Vl_Parameter)
	BEGIN

		IF ISNULL(@Fl_Type, 0) = 0	
		BEGIN
	
			IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
					DROP TABLE ##Email_HTML	
			
			-- Dados da Tabela do EMAIL
			SELECT [Nm_Database] [Database]
			INTO ##Email_HTML	
			FROM #Alert_Log_Backup_Database		
			Where DATEDIFF(HH,Data_Backup,GETDATE()) >= @Vl_Parameter

			IF ( OBJECT_ID('tempdb..##Email_HTML_2') IS NOT NULL )
					DROP TABLE ##Email_HTML_2	
				 	
			SELECT TOP 50 *
			INTO ##Email_HTML_2
			FROM ##WhoIsActive_Result
		
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter
			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_Saida = @HTML OUT				-- varchar(max)

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

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'							
		
			-- Fl_Type = 1 : ALERT	
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 1			

		END
	END
	ELSE 
	BEGIN	-- INICIO - CLEAR
		IF @Fl_Type = 1
		BEGIN
					
			IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR') IS NOT NULL )
				DROP TABLE ##Email_HTML_CLEAR	
				 	
			SELECT TOP 50 *
			INTO ##Email_HTML_CLEAR
			FROM ##WhoIsActive_Result
				
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_CLEAR', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[dd hh:mm:ss.mss] desc',
				@Ds_Saida = @HTML OUT				-- varchar(max)

			-- First Result
			SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space 		
				
			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'		
			
			-- Fl_Type = 0 : CLEAR
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 0		
		END
	END		-- FIM - CLEAR
END
GO
	/*

	SELECT *
	FROM sys.configurations
	WHERE name = 'Ole Automation Procedures' 
		AND value_in_use = 1
	
	-- Just sysadmin or someone that you give a grant can run OLE Procedures. If a user is sysadmin, he can turn OLE procedure ON by himself. So if you DBA (sysadmin) don't give this acess to anyone and maybe it's not a problem to enable this option.
	-- The best option is use powershell script, but to made this alert scripts easier I will not use that. Feel free to improve this code and use powershell.
	
	EXEC [sp_configure] 'show advanced option', 1
	RECONFIGURE with OVERRIDE
	EXEC [sp_configure] 'Ole Automation Procedures', 1
	RECONFIGURE with OVERRIDE
	EXEC [sp_configure] 'show advanced option', 0
	RECONFIGURE with OVERRIDE
	
	*/

IF ( OBJECT_ID('[dbo].[stpAlert_Disk_Space]') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_Disk_Space
GO

GO
CREATE PROCEDURE [dbo].[stpAlert_Disk_Space]
AS
BEGIN
	
	SET NOCOUNT ON

	DECLARE @Id_Alert_Parameter SMALLINT, @Fl_Enable BIT, @Fl_Type TINYINT, @Vl_Parameter SMALLINT,@Ds_Email VARCHAR(500),@Ds_Profile_Email VARCHAR(200),@Dt_Now DATETIME,@Vl_Parameter_2 INT,
		@Ds_Email_Information_1_ENG VARCHAR(200), @Ds_Email_Information_2_ENG VARCHAR(200), @Ds_Email_Information_1_PTB VARCHAR(200), @Ds_Email_Information_2_PTB VARCHAR(200),
		@Ds_Message_Alert_ENG varchar(1000),@Ds_Message_Clear_ENG varchar(1000),@Ds_Message_Alert_PTB varchar(1000),@Ds_Message_Clear_PTB varchar(1000), @Ds_Subject VARCHAR(500)
	
	DECLARE @Company_Link  VARCHAR(4000),@Line_Space VARCHAR(4000),@Header_Default VARCHAR(4000),@Header VARCHAR(4000),@Fl_Language BIT,@Final_HTML VARCHAR(MAX),@HTML VARCHAR(MAX)		
	
	DECLARE @Ds_Alinhamento VARCHAR(10),@Ds_OrderBy VARCHAR(MAX) 	
	

							
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
	WHERE Nm_Alert = 'Disk Space'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
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
		[Date]			varchar(20)
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
					(100 - 100 * ROUND(@MBFree, 2) / ROUND(@mbtotal, 2)), @SQLDriveSize, CONVERT(VARCHAR(20), GETDATE(), 120))

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
				
	/*******************************************************************************************************************************
	--	Do we have disk space problems?
	*******************************************************************************************************************************/
	IF (
			@Ole_Automation = 1 AND EXISTS	(SELECT NULL FROM #diskspace WHERE [Used (%)] > @Vl_Parameter)
		OR
			@Ole_Automation = 0 AND EXISTS (SELECT NULL FROM #Database_Driver_Letters WHERE [Space Used %]  > @Vl_Parameter)
	   )

	BEGIN	-- 
		IF ISNULL(@Fl_Type, 0) = 0	
		BEGIN				
			
				IF ( OBJECT_ID('tempdb..##Email_HTML_2') IS NOT NULL )
					DROP TABLE ##Email_HTML_2	
				 	
				SELECT TOP 50 *
				INTO ##Email_HTML_2
				FROM ##WhoIsActive_Result
				
				 
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter
			
			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		


		  IF @Ole_Automation = 1
			BEGIN 		
				
			   IF ( OBJECT_ID('tempdb..##Email_HTML_Ole_Automation') IS NOT NULL )
					DROP TABLE ##Email_HTML_Ole_Automation

					select	*
					INTO ##Email_HTML_Ole_Automation
					from #diskspace					


					EXEC dbo.stpExport_Table_HTML_Output
						@Ds_Tabela = '##Email_HTML_Ole_Automation', -- varchar(max)
						@Ds_Alinhamento  = 'center',
						@Ds_OrderBy = '[Drive]',
						@Ds_Saida = @HTML OUT				-- varchar(max)
			END
			ELSE
			BEGIN
					
				   IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
						DROP TABLE ##Email_HTML

					select	*
					INTO ##Email_HTML
					from #Database_Driver_Letters				

					EXEC dbo.stpExport_Table_HTML_Output
						@Ds_Tabela = '##Email_HTML', -- varchar(max)
						@Ds_Alinhamento  = 'center',
						@Ds_OrderBy = '[Disk]',
						@Ds_Saida = @HTML OUT				-- varchar(max)
			END		
				

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

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'								
		
			-- Fl_Type = 1 : ALERT	
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 1			
		
			
		END
	END		-- FIM - ALERTA
	ELSE 
	BEGIN	-- INICIO - CLEAR				
		IF @Fl_Type = 1
		BEGIN


				IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR_2') IS NOT NULL )
					DROP TABLE ##Email_HTML_CLEAR_2	
				 	
				SELECT TOP 50 *
				INTO ##Email_HTML_CLEAR_2
				FROM ##WhoIsActive_Result
			
				 
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter
			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		

		     IF @Ole_Automation = 1
			BEGIN 		
				
			   IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR_Ole_Automation') IS NOT NULL )
					DROP TABLE ##Email_HTML_CLEAR_Ole_Automation

					select	*
					INTO ##Email_HTML_CLEAR_Ole_Automation
					from #diskspace
					

					EXEC dbo.stpExport_Table_HTML_Output
						@Ds_Tabela = '##Email_HTML_CLEAR_Ole_Automation', -- varchar(max)
						@Ds_Alinhamento  = 'center',
						@Ds_OrderBy = '[Drive]',
						@Ds_Saida = @HTML OUT				-- varchar(max)
			END
			ELSE
			BEGIN
					
				   IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR') IS NOT NULL )
						DROP TABLE ##Email_HTML_CLEAR

					select	*
					INTO ##Email_HTML_CLEAR
					from #Database_Driver_Letters
				

					EXEC dbo.stpExport_Table_HTML_Output
						@Ds_Tabela = '##Email_HTML_CLEAR', -- varchar(max)						
						@Ds_Alinhamento  = 'center',
						@Ds_OrderBy = '[Disk]',
						@Ds_Saida = @HTML OUT				-- varchar(max)
			END		
				

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

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'		
			
			-- Fl_Type = 0 : CLEAR
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 0		

		END
	END		
END

GO
GO
IF ( OBJECT_ID('[dbo].stpAlert_IO_Pending') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_IO_Pending
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stpAlert_IO_Pending]
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
	WHERE Nm_Alert = 'IO Pending'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
	SELECT DB_NAME(mf.database_id) AS [Database]
			, mf.physical_name [Physical Name]
			, r.io_pending [IO Pending]
			, r.io_pending_ms_ticks [IO Pending (ms)]
			, r.io_type [IO Type]
			, fs.num_of_reads [Number of Reads]
			, fs.num_of_writes [Number of Writes]
			, GETDATE() [Data]
	INTO #Disk_Result
	FROM sys.dm_io_pending_io_requests AS r
	INNER JOIN sys.dm_io_virtual_file_stats(null,null) AS fs
	ON r.io_handle = fs.file_handle 
	INNER JOIN sys.master_files AS mf
	ON fs.database_id = mf.database_id
	AND fs.file_id = mf.file_id

	insert into Log_IO_Pending([Nm_Database], [Physical_Name], [IO_Pending], [IO_Pending_ms], [IO_Type], [Number_Reads], [Number_Writes], [Dt_Log])
	select * from #Disk_Result

	delete from #Disk_Result
	WHERE [IO Pending (ms)] < @Vl_Parameter*1000
		
	IF EXISTS( SELECT TOP 1 null FROM #Disk_Result )
	BEGIN

		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
				DROP TABLE ##Email_HTML

		SELECT TOP 50 [Database],[Physical Name],[IO Pending],[IO Pending (ms)],[IO Type],[Number of Reads],[Number of Writes],CONVERT(VARCHAR(20), [Data], 120) [Data]
		INTO ##Email_HTML
		FROM #Disk_Result
	
		 
		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter
			
		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB),'###1',@Vl_Parameter)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
		END
        ELSE 
		BEGIN
			SET @Header = REPLACE(REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG),'###1',@Vl_Parameter)
			SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		END		   		

		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[IO Pending (ms)] desc',
			@Ds_Saida = @HTML OUT				-- varchar(max)
					
		-- First Result
		SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space 	

		IF ( OBJECT_ID('tempdb..##Email_HTML_2') IS NOT NULL )
			DROP TABLE ##Email_HTML_2	
				 	
		SELECT TOP 50 *
		INTO ##Email_HTML_2
		FROM ##WhoIsActive_Result

				
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


			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'									
		
		-- Fl_Type = 1 : ALERT	
		INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
		SELECT @Id_Alert_Parameter, @Ds_Subject, 1											
		
	END
END



GO
GO
IF ( OBJECT_ID('[dbo].stpAlert_Large_LDF_File') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_Large_LDF_File
GO
CREATE PROCEDURE [dbo].stpAlert_Large_LDF_File
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
	WHERE Nm_Alert = 'Large LDF File'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
	SELECT CONVERT(VARCHAR(25), DB.name) AS [Database],
	 (SELECT COUNT(1) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'rows') AS [Data Files],
	 (SELECT SUM((size*8)/1024) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'rows') AS [Data MB],
	 (SELECT COUNT(1) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'log') AS [Log Files],
	 (SELECT SUM((size*8)/1024) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'log') AS [Log MB],
	 (SELECT SUM((size*8)/1024) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'log')*100/
	 (SELECT SUM((size*8)/1024) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'rows') [Diff Data Log (%)]
	 INTO #Database_Files
  FROM sys.databases DB
	 WHERE    
	 (SELECT SUM((size*8)/1024) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'log')*100/
	 (SELECT SUM((size*8)/1024) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'rows') > @Vl_Parameter 
	  AND (SELECT SUM((size*8)/1024) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'log') > @Vl_Parameter_2 * 1024
	ORDER BY [Diff Data Log (%)] DESC
    

	IF EXISTS (	SELECT NULL  FROM    #Database_Files)		
	BEGIN	
		IF ISNULL(@Fl_Type, 0) = 0	-- Control Alert/Clear
		BEGIN
			IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
				DROP TABLE ##Email_HTML
						
			SELECT *
			INTO ##Email_HTML
			FROM  #Database_Files
							
			IF ( OBJECT_ID('tempdb..##Email_HTML_2') IS NOT NULL )
				DROP TABLE ##Email_HTML_2	
				 	
			SELECT TOP 50 *
			INTO ##Email_HTML_2
			FROM ##WhoIsActive_Result

				 
		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter			

		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
		END
        ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
			SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		END		   		

		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Diff Data Log (%)] DESC',
			@Ds_Saida = @HTML OUT				-- varchar(max)

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
						
			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'								
		
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
				
				SELECT CONVERT(VARCHAR(25), DB.name) AS [Database],
				 (SELECT COUNT(1) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'rows') AS [Data Files],
				 (SELECT SUM((size*8)/1024) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'rows') AS [Data MB],
				 (SELECT COUNT(1) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'log') AS [Log Files],
				 (SELECT SUM((size*8)/1024) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'log') AS [Log MB],
				 (SELECT SUM((size*8)/1024) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'log')*100/
				 (SELECT SUM((size*8)/1024) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'rows') [Diff Data Log (%)]
				 INTO ##Email_HTML_CLEAR
			  FROM sys.databases DB
			  ORDER BY [Diff Data Log (%)] desc
	

			IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR_2') IS NOT NULL )
				DROP TABLE ##Email_HTML_CLEAR_2	
				 	
			SELECT TOP 50 *
			INTO ##Email_HTML_CLEAR_2
			FROM ##WhoIsActive_Result
	
				 
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter
			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_CLEAR', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[Diff Data Log (%)] DESC',
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

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'		
			
			-- Fl_Type = 0 : CLEAR
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 0		
		END		
	END		-- END - CLEAR	

END
GO

GO
IF ( OBJECT_ID('[dbo].[stpAlert_Log_Full]') IS NOT NULL )
	DROP PROCEDURE [dbo].stpAlert_Log_Full
GO
CREATE PROCEDURE [dbo].[stpAlert_Log_Full] 
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
	WHERE Nm_Alert = 'Log Full'


	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		


	SELECT
    db.[name] AS [Database] ,
    CAST(ls.[cntr_value] / 1024.00 AS DECIMAL(18,2)) AS [Log Size],
    CAST(    CAST(lu.[cntr_value] AS FLOAT) /
                    CASE WHEN CAST(ls.[cntr_value] AS FLOAT) = 0
                            THEN 1
                            ELSE CAST(ls.[cntr_value] AS FLOAT)
                    END AS DECIMAL(18,2)) * 100    AS [Percent Log Used],
    CAST(ds.[cntr_value] / 1024.00 AS DECIMAL(18,2)) AS [Data Size],
   CAST( (CAST(ls.[cntr_value] / 1024.00 AS DECIMAL(18,2))/ CAST(ds.[cntr_value] / 1024.00 AS DECIMAL(18,2)))*100.00 AS NUMERIC(15,2) )AS [Size Proportion (Log/Data)]
    INTO #Alert_File_Log_Full
    FROM [sys].[databases] AS db
    JOIN [sys].[dm_os_performance_counters] AS lu  ON db.[name] = lu.[instance_name]
    JOIN [sys].[dm_os_performance_counters] AS ls  ON db.[name] = ls.[instance_name]
    JOIN [sys].[dm_os_performance_counters] AS ds  ON db.[name] = ds.[instance_name]
    WHERE    lu.[counter_name] LIKE 'Log File(s) Used Size (KB)%'
            AND ls.[counter_name] LIKE 'Log File(s) Size (KB)%'
            AND ds.[counter_name] LIKE 'Data File(s) Size (KB)%'
			AND db.state_desc = 'ONLINE'
			and CAST(ls.[cntr_value] / 1024.00 AS DECIMAL(18,2))  > @Vl_Parameter_2 
			
	--	Do we have log Full?
	IF EXISTS	(
				SELECT	null
				FROM #Alert_File_Log_Full
				WHERE	[Percent Log Used] > @Vl_Parameter
				AND [Log Size] * 1024 > @Vl_Parameter_2 
				)
	BEGIN	-- BEGIN - ALERT


		IF ISNULL(@Fl_Type, 0) = 0	-- Control Alert/Clear
		BEGIN
			IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
				DROP TABLE ##Email_HTML

			-- Databases with Log FULL
			SELECT	*
			INTO ##Email_HTML
			FROM #Alert_File_Log_Full
			WHERE	[Percent Log Used] > @Vl_Parameter
			
				
								
			IF ( OBJECT_ID('tempdb..##Email_HTML_2') IS NOT NULL )
				DROP TABLE ##Email_HTML_2	
				 	
			SELECT TOP 50 *
			INTO ##Email_HTML_2
			FROM ##WhoIsActive_Result
	
				 
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter
			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[Percent Log Used],[Database]',
				@Ds_Saida = @HTML OUT				-- varchar(max)

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

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'								
		
			-- Fl_Type = 1 : ALERT	
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 1			
		END
	END		-- END - ALERT
	ELSE 
	BEGIN	-- BEGIN - CLEAR				
		IF @Fl_Type = 1
		BEGIN			
			
			IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR') IS NOT NULL )
				DROP TABLE ##Email_HTML_CLEAR					
						
			SELECT TOP 50 *
			INTO ##Email_HTML_CLEAR
			FROM #Alert_File_Log_Full			
			
			IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR_2') IS NOT NULL )
				DROP TABLE ##Email_HTML_CLEAR_2					
						
			SELECT TOP 50 *
			INTO ##Email_HTML_CLEAR_2
			FROM ##WhoIsActive_Result

				 
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				  SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		
		
			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_CLEAR', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[Percent Log Used],[Database]',
				@Ds_Saida = @HTML OUT				-- varchar(max)

				   -- First Result
			SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space 	

			IF @Fl_Language = 1
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_PTB)
			ELSE 
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_ENG)			
				

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_CLEAR_2', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[dd hh:mm:ss.mss] desc',
				@Ds_Saida = @HTML OUT				-- varchar(max)
		
		-- Second Result
			SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space + @Company_Link		

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'	
			
			-- Fl_Type = 0 : CLEAR
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 0		
		END		
	END		-- END - CLEAR
END

GO
GO
IF ( OBJECT_ID('[dbo].stpAlert_Memory_Available') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_Memory_Available
GO
CREATE PROCEDURE [dbo].stpAlert_Memory_Available
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
	WHERE Nm_Alert = 'Memory Available'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
	
	--	Do we have Memory problem?	
	IF EXISTS (	SELECT null		
				FROM    sys.dm_os_sys_memory m
				 WHERE   CAST((m.available_physical_memory_kb/1024) AS BIGINT) < @Vl_Parameter*1024 )		
	BEGIN	
		IF ISNULL(@Fl_Type, 0) = 0	-- Control Alert/Clear
		BEGIN
			IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
				DROP TABLE ##Email_HTML
						
			SELECT CAST((m.total_physical_memory_kb/1024) AS BIGINT)  [Total Memory (MB)],
				CAST((m.available_physical_memory_kb/1024) AS BIGINT) [Available Memory (MB)],
				CAST(CAST((m.available_physical_memory_kb/1024) AS BIGINT)*100.00/CAST((m.total_physical_memory_kb/1024) AS BIGINT) AS NUMERIC(9,2))  [Available Memory (%)]
			INTO ##Email_HTML
			FROM    sys.dm_os_sys_memory m					
			
			IF ( OBJECT_ID('tempdb..##Email_HTML_2') IS NOT NULL )
				DROP TABLE ##Email_HTML_2	
				 	
			SELECT TOP 50 *
			INTO ##Email_HTML_2
			FROM ##WhoIsActive_Result
	
				 
		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter			

		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
		END
        ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
			SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		END		   		

		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_Saida = @HTML OUT				-- varchar(max)

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

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'							
		
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
				
			SELECT CAST((m.total_physical_memory_kb/1024) AS BIGINT)  [Total Memory (MB)],
			CAST((m.available_physical_memory_kb/1024) AS BIGINT) [Available Memory (MB)],
			CAST(CAST((m.available_physical_memory_kb/1024) AS BIGINT)*100.00/CAST((m.total_physical_memory_kb/1024) AS BIGINT) AS NUMERIC(9,2))  [Available Memory (%)]
			INTO ##Email_HTML_CLEAR
			FROM    sys.dm_os_sys_memory m		

			IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR_2') IS NOT NULL )
				DROP TABLE ##Email_HTML_CLEAR_2	
				 	
			SELECT TOP 50 *
			INTO ##Email_HTML_CLEAR_2
			FROM ##WhoIsActive_Result

				 
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter
			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_CLEAR', -- varchar(max)
				@Ds_Alinhamento  = 'center',
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

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'		
			
			-- Fl_Type = 0 : CLEAR
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 0		
		END		
	END		-- END - CLEAR	

END

GO

GO
IF ( OBJECT_ID('[dbo].[stpAlert_Page_Corruption]') IS NOT NULL )
	DROP PROCEDURE [dbo].stpAlert_Page_Corruption
GO
CREATE PROCEDURE [dbo].stpAlert_Page_Corruption 
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
	WHERE Nm_Alert = 'Page Corruption'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
	IF(OBJECT_ID('tempdb..#temp_Page_Corruption') IS NOT NULL) 
		DROP TABLE #temp_Page_Corruption

	SELECT SP.*
	INTO #temp_Page_Corruption
	FROM [msdb].[dbo].[suspect_pages] SP
	LEFT JOIN [dbo].Suspect_Pages_History HSP ON	SP.database_id = HSP.database_id AND SP.file_id = HSP.file_id
														AND SP.[page_id] = HSP.[page_id]
														AND CAST(SP.last_update_date AS DATE) = CAST(HSP.Dt_Corruption AS DATE)
	WHERE 	HSP.[page_id] IS NULL	
	
	

	IF EXISTS	(SELECT TOP 1 page_id FROM #temp_Page_Corruption)
	BEGIN	-- BEGIN - ALERT
	
		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
			DROP TABLE ##Email_HTML
		
		SELECT	B.name AS [Database], 
				CAST(file_id AS VARCHAR) AS [File ID], 
				CAST(page_id AS VARCHAR) AS [Page ID], 
				CAST(event_type AS VARCHAR) AS [Event Type], 
				CAST(error_count AS VARCHAR) AS [Error Count],								
				CONVERT(VARCHAR(20), last_update_date, 120) AS [Last Update Date]
		INTO ##Email_HTML
		FROM #temp_Page_Corruption A
		JOIN [sys].[databases] B ON B.[database_id] = A.[database_id]								
										

				 
		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter
			
		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				SET @Ds_Subject =  @Ds_Message_Alert_PTB + @@SERVERNAME 
		END
        ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
			SET @Ds_Subject =  @Ds_Message_Alert_ENG + @@SERVERNAME 
		END		   		

		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)			
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Last Update Date]',
			@Ds_Saida = @HTML OUT				-- varchar(max)

	
		-- First Result
		SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space + @Company_Link	

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'							
		
		INSERT INTO [dbo].Suspect_Pages_History
		SELECT	[database_id] ,
				[file_id] ,
				[page_id] ,
				[event_type] ,
				[last_update_date]
		FROM #temp_Page_Corruption

		-- Fl_Type = 1 : ALERT	
		INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
		SELECT @Id_Alert_Parameter, @Ds_Subject, 1			
		
	END		-- END - ALERT
	
END

GO
GO
IF ( OBJECT_ID('[dbo].stpAlert_Slow_Disk') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_Slow_Disk
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Chamar essa antes
--EXEC stpRead_Error_log 1 --@Actual_Log = 1 - most recent 
-- stpAlert_Slow_Disk 'Slow Disk Every Hour'
-- stpAlert_Slow_Disk 'Slow Disk'

CREATE PROCEDURE [dbo].stpAlert_Slow_Disk @Nm_Alert VARCHAR(100)
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
	WHERE Nm_Alert = @Nm_Alert

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
	IF ( OBJECT_ID('tempdb..#Error_Log_IO') IS NOT NULL ) 
		DROP TABLE #Error_Log_IO

	CREATE TABLE #Error_Log_IO (
		[LogDate]		DATETIME,
		[Process Info]	NVARCHAR(50),
		[Text]			NVARCHAR(MAX)
	)

	-- Error Log
	INSERT INTO #Error_Log_IO
	SELECT *
	FROM ##Error_Log_Result
	WHERE [LogDate] >= DATEADD(hh,@Vl_Parameter*-1,GETDATE())  
		AND [Text] LIKE '%of I/O requests taking longer than 15 seconds%'
		AND DATEPART(HOUR, [LogDate]) >= 6 --ignore admin tasks execution time (you can change this)
		AND DATEPART(HOUR, [LogDate]) < 23
		
	IF EXISTS( SELECT * FROM #Error_Log_IO )
	BEGIN

		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
				DROP TABLE ##Email_HTML

		SELECT	TOP 50
				Convert(VARCHAR(20),[LogDate],120) AS [Log Date],
				[Process Info], 
				[Text]
		INTO ##Email_HTML
		FROM #Error_Log_IO
	
		 
		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter
			
		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB),'###1',@Vl_Parameter)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
		END
        ELSE 
		BEGIN
			SET @Header = REPLACE(REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG),'###1',@Vl_Parameter)
			SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		END		   		

		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Log Date]',
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


IF ( OBJECT_ID('[dbo].stpAlert_SQLServer_Connection') IS NOT NULL )
	DROP PROCEDURE [dbo].stpAlert_SQLServer_Connection
GO

/*******************************************************************************************************************************
--	ALERTA: CONEXAO SQL SERVER
*******************************************************************************************************************************/

CREATE PROCEDURE [dbo].stpAlert_SQLServer_Connection
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
	WHERE Nm_Alert = 'SQL Server Connection'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )	


	DECLARE @Qt_Connections SMALLINT
	SELECT @Qt_Connections = count(*) FROM sys.dm_exec_sessions WHERE session_id > 50

	--Did we have connection Problem?
	IF (@Qt_Connections > @Vl_Parameter)
	BEGIN					            
		IF ISNULL(@Fl_Type, 0) = 0	-- Control Alert/Clear
		BEGIN
			IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
				DROP TABLE ##Email_HTML

			if object_id('tempdb..#Open_Connections') is not null
				drop table #Open_Connections

			SELECT	TOP 25 IDENTITY(INT, 1, 1) AS id, 
					replace(replace(ec.client_net_address,'<',''),'>','') client_net_address, 
					case when es.[program_name] = '' then 'Sem nome na string de conexão' else [program_name] end [program_name], 
					es.[host_name], es.login_name, /*db_name(database_id)*/ '' Base,
					COUNT(ec.session_id)  AS [connection count] 
			into #Open_Connections
			FROM sys.dm_exec_sessions AS es  
			INNER JOIN sys.dm_exec_connections AS ec ON es.session_id = ec.session_id   
			GROUP BY ec.client_net_address, es.[program_name], es.[host_name],/*db_name(database_id),*/ es.login_name  			
			order by [connection count] desc
					
			SELECT	client_net_address [Client Net Address], 
					[program_name] [Program Name], 
					[host_name] [Host Name], 
					login_name [Login Name], 
					Base AS [Database],
					[connection count] [Connection Count] --,id
			INTO ##Email_HTML
			FROM #Open_Connections
			
	
			IF ( OBJECT_ID('tempdb..##Email_HTML_2') IS NOT NULL )
					DROP TABLE ##Email_HTML_2	
				 	
				SELECT TOP 50 *
				INTO ##Email_HTML_2
				FROM ##WhoIsActive_Result
	
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter
			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML', -- varchar(max)				
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[Connection Count] DESC',
				@Ds_Saida = @HTML OUT				-- varchar(max)

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

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'									
		
			-- Fl_Type = 1 : ALERT	
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 1	
		END		
	END		-- END - ALERT
	ELSE 
	BEGIN	-- BEGIN - CLEAR	 
		IF @Fl_Type = 1
		BEGIN
	
			if object_id('tempdb..#Open_Connections_Clear') is not null
				drop table #Open_Connections_Clear

			SELECT	top 25 IDENTITY(INT, 1, 1) AS id, 
					replace(replace(ec.client_net_address,'<',''),'>','') client_net_address, 
					case when es.[program_name] = '' then 'Without a Name' else [program_name] end [program_name], 
					es.[host_name], es.login_name, /*db_name(database_id)*/ '' Base,
					COUNT(ec.session_id)  AS [connection count] 
			into #Open_Connections_Clear
			FROM sys.dm_exec_sessions AS es  
			INNER JOIN sys.dm_exec_connections AS ec  
			ON es.session_id = ec.session_id   
			GROUP BY ec.client_net_address, es.[program_name], es.[host_name],/*db_name(database_id),*/ es.login_name  			
			order by [connection count] desc
		
			IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR') IS NOT NULL )
					DROP TABLE ##Email_HTML_CLEAR

			SELECT	client_net_address [Client Net Address], 
					[program_name] [Program Name], 
					[host_name] [Host Name], 
					login_name [Login Name], 
					Base AS [Database],
					cast([connection count] as varchar) [Connection Count] --,id
			INTO ##Email_HTML_CLEAR
			FROM #Open_Connections_Clear 
			ORDER BY id 
			
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
				 SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_CLEAR', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[Connection Count] DESC',
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

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'		
			
			-- Fl_Type = 0 : CLEAR
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 0		
		END
	END		-- END - CLEAR
END

GO


GO
IF ( OBJECT_ID('[dbo].[stpAlert_SQLServer_Restarted]') IS NOT NULL )
	DROP PROCEDURE [dbo].stpAlert_SQLServer_Restarted
GO
CREATE PROCEDURE [dbo].stpAlert_SQLServer_Restarted 
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
	WHERE Nm_Alert = 'SQL Server Restarted'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	

	-- Last SQL Server Restart date
	IF ( OBJECT_ID('tempdb..#Alerta_SQL_Reiniciado') IS NOT NULL ) 
		DROP TABLE #Alerta_SQL_Reiniciado
	
	SELECT [create_date] 
	INTO #Alerta_SQL_Reiniciado
	FROM [sys].[databases] WITH(NOLOCK)
	WHERE	[database_id] = 2 --  Database "TempDb"
			AND [create_date] >= DATEADD(MINUTE, -@Vl_Parameter, GETDATE())
	
	--	Was SQL Server Restarted?
	IF EXISTS( SELECT * FROM #Alerta_SQL_Reiniciado )
	BEGIN	-- BEGIN - ALERT
	
		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
			DROP TABLE ##Email_HTML

	
		SELECT CONVERT(VARCHAR(20), [create_date], 120) AS [Restart Date]
		INTO ##Email_HTML
		FROM #Alerta_SQL_Reiniciado
		 
		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter
			
		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB),'###1',@Vl_Parameter)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
		END
        ELSE 
		BEGIN
			SET @Header = REPLACE(REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG),'###1',@Vl_Parameter)
			SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		END		   		

		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_Saida = @HTML OUT				-- varchar(max)

	
		-- First Result
		SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space + @Company_Link	

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'								
		
		-- Fl_Type = 1 : ALERT	
		INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
		SELECT @Id_Alert_Parameter, @Ds_Subject, 1			
		
	END		-- END - ALERT
	
END

GO


IF ( OBJECT_ID('[dbo].[stpAlert_Tempdb_MDF_File_Utilization]') IS NOT NULL )
	DROP PROCEDURE [dbo].stpAlert_Tempdb_MDF_File_Utilization
GO

/*******************************************************************************************************************************
--	ALERTA: TEMPDB UTILIZACAO ARQUIVO MDF
*******************************************************************************************************************************/

CREATE PROCEDURE [dbo].stpAlert_Tempdb_MDF_File_Utilization
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
	WHERE Nm_Alert = 'Tempdb MDF File Utilization'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )	
	
	--------------------------------------------------------------------------------------------------------------------------------
	-- TEMPDB Utilization
	--------------------------------------------------------------------------------------------------------------------------------
	IF ( OBJECT_ID('tempdb..#Alert_Tempdb_File_Utilization') IS NOT NULL )
		DROP TABLE #Alert_Tempdb_File_Utilization

	select 
		file_id,
		reserved_MB = CAST((unallocated_extent_page_count+version_store_reserved_page_count+user_object_reserved_page_count +
							internal_object_reserved_page_count+mixed_extent_page_count)*8/1024. AS numeric(15,2)) ,
		unallocated_extent_MB = CAST(unallocated_extent_page_count*8/1024. AS NUMERIC(15,2)),
		internal_object_reserved_MB = CAST(internal_object_reserved_page_count*8/1024. AS NUMERIC(15,2)),
		version_store_reserved_MB = CAST(version_store_reserved_page_count*8/1024. AS NUMERIC(15,2)),
		user_object_reserved_MB = convert(numeric(10,2),round(user_object_reserved_page_count*8/1024.,2))
	into #Alert_Tempdb_File_Utilization
	from tempdb.sys.dm_db_file_space_usage
		
	--	Do we have Tempdb problem?	
	IF EXISTS	(
				select TOP 1 unallocated_extent_MB 
				from #Alert_Tempdb_File_Utilization
				where	reserved_MB > @Vl_Parameter_2 
						and unallocated_extent_MB < reserved_MB * (1 - (@Vl_Parameter / 100.0))
			)

	BEGIN	-- INICIO - ALERTA		
		
		IF ISNULL(@Fl_Type, 0) = 0	-- Control Alert/Clear
		BEGIN
			IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
				DROP TABLE ##Email_HTML
			
			-- TEMPDB Information	
			SELECT	file_id [File ID], 
				reserved_MB [Reserved (MB)],
				CAST( ((1 - (unallocated_extent_MB / reserved_MB)) * 100) AS NUMERIC(15,2)) AS [% Used],
				unallocated_extent_MB [Unallocated Extent (MB)],
				internal_object_reserved_MB [Internal Object Reserved (MB)],
				version_store_reserved_MB [Version Store Reserved (MB)],
				user_object_reserved_MB [User Object Reserved (MB)]
			INTO ##Email_HTML
			FROM #Alert_Tempdb_File_Utilization
					

			IF ( OBJECT_ID('tempdb..##Email_HTML_2') IS NOT NULL )
				DROP TABLE ##Email_HTML_2	
				 	
			SELECT TOP 50 *
			INTO ##Email_HTML_2
			FROM ##WhoIsActive_Result
		
				 
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[% Used] DESC',
				@Ds_Saida = @HTML OUT				-- varchar(max)

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

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'								
		
			-- Fl_Type = 1 : ALERT	
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 1			
		END
	END		-- END - ALERT
	ELSE 
	BEGIN	-- BEGIN - CLEAR				
		IF @Fl_Type = 1
		BEGIN			
			
			IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR') IS NOT NULL )
					DROP TABLE ##Email_HTML_CLEAR						
				
				-- TEMPDB Information	
			SELECT	file_id [File ID], 
				reserved_MB [Reserved (MB)],
				CAST( ((1 - (unallocated_extent_MB / reserved_MB)) * 100) AS NUMERIC(15,2)) AS [% Used],
				unallocated_extent_MB [Unallocated Extent (MB)],
				internal_object_reserved_MB [Internal Object Reserved (MB)],
				version_store_reserved_MB [Version Store Reserved (MB)],
				user_object_reserved_MB [User Object Reserved (MB)]
				INTO ##Email_HTML_CLEAR
				FROM #Alert_Tempdb_File_Utilization					
			
				IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR_2') IS NOT NULL )
					DROP TABLE ##Email_HTML_CLEAR_2	
				 	
				SELECT TOP 50 *
				INTO ##Email_HTML_CLEAR_2
				FROM ##WhoIsActive_Result
	
				 
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_CLEAR', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[% Used] DESC',
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

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'		
			
			-- Fl_Type = 0 : CLEAR
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 0		
		END		
	END		-- END - CLEAR	
END
GO

GO
IF ( OBJECT_ID('[dbo].[stpAlert_Database_Created]') IS NOT NULL )
	DROP PROCEDURE [dbo].stpAlert_Database_Created
GO

CREATE PROCEDURE [dbo].stpAlert_Database_Created
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
	FROM dbo.Alert_Parameter 
	WHERE Nm_Alert = 'Database Created'
	
	IF @Fl_Enable = 0
		RETURN
		
	IF ( OBJECT_ID('tempdb..#Alert_Database_Created') IS NOT NULL ) 
		DROP TABLE #Alert_Database_Created
	
	SELECT	[database_id],
			[name], 
			[recovery_model_desc], 
			[create_date], 
			CASE WHEN [is_auto_close_on] = 0 THEN 'NÃO' ELSE 'SIM' END AS [is_auto_close_on], 
			CASE WHEN [is_auto_shrink_on] = 0 THEN 'NÃO' ELSE 'SIM' END AS [is_auto_shrink_on], 
			CASE WHEN [is_auto_create_stats_on] = 0 THEN 'NÃO' ELSE 'SIM' END AS [is_auto_create_stats_on], 
			CASE WHEN [is_auto_update_stats_on] = 0 THEN 'NÃO' ELSE 'SIM' END AS [is_auto_update_stats_on]
	INTO #Alert_Database_Created
	FROM [sys].[databases] WITH(NOLOCK)
	WHERE	[database_id] <> 2 -- "TempDb"
			AND [create_date] >= DATEADD(HOUR, -@Vl_Parameter, GETDATE())			
	
	--	Did we have a new database?
	IF EXISTS( SELECT null FROM #Alert_Database_Created )
	BEGIN

		IF (OBJECT_ID('tempdb..##Alerta_Database_Files') IS NOT NULL)
			DROP TABLE ##Alerta_Database_Files

		CREATE TABLE ##Alerta_Database_Files (
			[Nm_Database]		VARCHAR(100),
			[Logical_Name]		VARCHAR(100),
			[Size]				NUMERIC(15,2),
			[Total_Used]	NUMERIC(15,2),
			[Free_Space (MB)] NUMERIC(15,2),
			[Percent_Free] NUMERIC(15,2)
		)
		
		IF (OBJECT_ID('tempdb..#Alert_Database_Loop') IS NOT NULL)
			DROP TABLE #Alert_Database_Loop

		SELECT *
		INTO #Alert_Database_Loop
		FROM #Alert_Database_Created
		
		WHILE EXISTS (SELECT TOP 1 database_id FROM #Alert_Database_Loop)
		BEGIN
			DECLARE @DATABASE_ID INT = (SELECT MIN(database_id) FROM #Alert_Database_Loop)

			DECLARE @DB sysname = (SELECT DB_NAME(@DATABASE_ID))

			DECLARE @SQL VARCHAR(max) = 'USE [' + @DB +']' + CHAR(13) + 
			'
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

			INSERT INTO ##Alerta_Database_Files
			SELECT	DB_NAME(), name as [Logical_Name], size, used, free,
					percent_free = case when size <> 0 then cast((free * 100.0 / size) as numeric(15,2)) else 0 end
			FROM cte_datainfo
		    '
		               
			EXEC (@SQL )

			DELETE #Alert_Database_Loop
			WHERE database_id = @DATABASE_ID
		END

		IF (OBJECT_ID('tempdb..#Alert_Database_Created_Data_File') IS NOT NULL)
			DROP TABLE #Alert_Database_Created_Data_File

		SELECT	DB_NAME(A.database_id) AS [Nm_Database],
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
		INTO #Alert_Database_Created_Data_File
		FROM [sys].[master_files] A WITH(NOLOCK)	
		JOIN ##Alerta_Database_Files B ON DB_NAME(A.[database_id]) = B.[Nm_Database] and A.[name] = B.[Logical_Name]
		WHERE	A.[type_desc] <> 'FULLTEXT'
				and A.type = 0	-- (MDF and NDF)
								
		IF (OBJECT_ID('tempdb..#Alert_Database_Created_Log_File') IS NOT NULL)
			DROP TABLE #Alert_Database_Created_Log_File

		SELECT	DB_NAME(A.database_id) AS [Nm_Database],
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
		INTO #Alert_Database_Created_Log_File
		FROM [sys].[master_files] A WITH(NOLOCK)	
		JOIN ##Alerta_Database_Files B ON DB_NAME(A.[database_id]) = B.[Nm_Database] and A.[name] = B.[Logical_Name]
		WHERE	A.[type_desc] <> 'FULLTEXT'
				and A.type = 1	-- (LDF)
		
		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
			DROP TABLE ##Email_HTML

		SELECT	[name] AS [Database], 
				[recovery_model_desc] AS [Recovery Model], 
				CONVERT(VARCHAR(20), [create_date], 120) AS [Create Date],
				[is_auto_close_on] AS [Is Auto Close On], 
				[is_auto_shrink_on] AS [Is Auto Shrink On], 
				[is_auto_create_stats_on] AS [Is Auto Create Stats On], 
				[is_auto_update_stats_on] AS [Is Auto Update Stats On]
		INTO ##Email_HTML
		FROM #Alert_Database_Created

		IF ( OBJECT_ID('tempdb..##Email_HTML_2') IS NOT NULL )
			DROP TABLE ##Email_HTML_2

		SELECT 			[Nm_Database] [Database],
						File_Type [File Type],
						[Logical_Name] [Logical Name],
						[Total_Reserved] [Total Reserved], 
						[Total_Used] [Total Used],
						[Free_Space (MB)] [Free Space (MB)], 
						[Free_Space (%)] [Free Space (%)],
						[MaxSize(MB)] [MaxSize (MB)], 
						[Growth]
		INTO ##Email_HTML_2
		FROM (		SELECT	[Nm_Database],
						'Data' File_Type,
						[Logical_Name],
						CAST([Total_Reserved]	 AS VARCHAR) AS [Total_Reserved], 
						CAST([Total_Used]	 AS VARCHAR) AS [Total_Used],
						CAST([Free_Space (MB)] AS VARCHAR) AS [Free_Space (MB)], 
						CAST([Free_Space (%)]	 AS VARCHAR) AS [Free_Space (%)],
						CAST([MaxSize(MB)]		 AS VARCHAR) AS [MaxSize(MB)], 
						CAST([Growth]			 AS VARCHAR) AS [Growth]
				FROM #Alert_Database_Created_Data_File							
				UNION ALL	
				SELECT	[Nm_Database],
						'Log' File_Type,
						[Logical_Name],
						CAST([Total_Reserved]	 AS VARCHAR) AS [Total_Reserved], 
						CAST([Total_Used]	 AS VARCHAR) AS [Total_Used],
						CAST([Free_Space (MB)] AS VARCHAR) AS [Free_Space (MB)], 
						CAST([Free_Space (%)]	 AS VARCHAR) AS [Free_Space (%)],
						CAST([MaxSize(MB)]		 AS VARCHAR) AS [MaxSize(MB)], 
						CAST([Growth]			 AS VARCHAR) AS [Growth]
				FROM #Alert_Database_Created_Log_File	 ) A					

				 
		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter
			
		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB),'###1',@Vl_Parameter)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
		END
        ELSE 
		BEGIN
			SET @Header = REPLACE(REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG),'###1',@Vl_Parameter)
			SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		END		   		

		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_Saida = @HTML OUT				-- varchar(max)
						
		-- First Result
		SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space 

		EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_2', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_Saida = @HTML OUT				-- varchar(max)			

			IF @Fl_Language = 1
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_PTB)
			ELSE 
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_ENG)				

			-- Second Result
			SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space + @Company_Link			

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'					


		-- Fl_Type = 1 : ALERT	
		INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
		SELECT @Id_Alert_Parameter, @Ds_Subject, 1		
	END -- END - ALERT
END
GO


GO
IF ( OBJECT_ID('[dbo].[stpAlert_Database_Without_Backup]') IS NOT NULL )
	DROP PROCEDURE [dbo].stpAlert_Database_Without_Backup
GO
CREATE PROCEDURE [dbo].stpAlert_Database_Without_Backup 
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
	WHERE Nm_Alert = 'Database Without Backup'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
	-- Verifica a Quantidade Total de Databases
	IF ( OBJECT_ID('tempdb..#Alert_All_databases') IS NOT NULL )
		DROP TABLE #Alert_All_databases

	SELECT [name] AS [Nm_Database]
	INTO #Alert_All_databases
	FROM [sys].[databases] A
		LEFT JOIN [dbo].[Ignore_Databases] B ON A.[name] = B.[Nm_Database]
	WHERE	[name] NOT IN ('tempdb', 'ReportServerTempDB') 
			AND state_desc <> 'OFFLINE'
			and B.[Nm_Database] IS NULL

	-- Verifica a Quantidade de Databases que tiveram Backup nas ultimas 14 horas
	IF ( OBJECT_ID('tempdb..#Alert_Databases_With_Backup') IS NOT NULL)
		DROP TABLE #Alert_Databases_With_Backup

	SELECT DISTINCT [database_name] AS [Nm_Database]
	INTO #Alert_Databases_With_Backup
	FROM [msdb].[dbo].[backupset] B
	JOIN [msdb].[dbo].[backupmediafamily] BF ON B.[media_set_id] = BF.[media_set_id]
	WHERE	[backup_start_date] >= DATEADD(hh, -@Vl_Parameter, GETDATE())
			AND [type] IN ('D','I')

		-- Databases que não tiveram Backup
	IF ( OBJECT_ID('tempdb..#Alert_Databases_Without_Backup') IS NOT NULL )
		DROP TABLE #Alert_Databases_Without_Backup
		
	SELECT A.[Nm_Database]
	INTO #Alert_Databases_Without_Backup
	FROM #Alert_All_databases A WITH(NOLOCK)
	LEFT JOIN #Alert_Databases_With_Backup B WITH(NOLOCK) ON A.[Nm_Database] = B.[Nm_Database]
	WHERE B.[Nm_Database] IS NULL
	
	--	Do we have backups?
	IF EXISTS	(	SELECT TOP 1 [Nm_Database] FROM #Alert_Databases_Without_Backup)
	BEGIN	-- BEGIN - ALERT
	
		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
			DROP TABLE ##Email_HTML
					
		-- Databases without Backups
		SELECT [Nm_Database] [Database]
		INTO ##Email_HTML
		FROM #Alert_Databases_Without_Backup
	
						 
		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter
			
		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB),'###1',@Vl_Parameter)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
		END
        ELSE 
		BEGIN
			SET @Header = REPLACE(REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG),'###1',@Vl_Parameter)
			SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		END		   		

		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Database]',
			@Ds_Saida = @HTML OUT				-- varchar(max)

	
		-- First Result
		SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space + @Company_Link	

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'								
		
		-- Fl_Type = 1 : ALERT	
		INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
		SELECT @Id_Alert_Parameter, @Ds_Subject, 1			
		
	END		-- END - ALERT
	
END

GO
GO
IF ( OBJECT_ID('[dbo].stpAlert_Job_Disabled') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_Job_Disabled
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].stpAlert_Job_Disabled
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
	WHERE Nm_Alert = 'Job Disabled'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
	-- Insert the new Data
	INSERT INTO Status_Job_SQL_Agent(Name, Dt_Referencia, Date_Modified, Fl_Status)
	select A.name , CAST(GETDATE() AS DATE),A.date_modified, enabled 
	FROM msdb.dbo.sysjobs A
		LEFT JOIN Status_Job_SQL_Agent B ON A.name = B.Name AND B.Dt_Referencia = CAST(GETDATE() AS DATE)
	WHERE B.Name IS NULL 

	-- Keep Just 7 days of information
	DELETE FROM dbo.Status_Job_SQL_Agent
	WHERE Dt_Referencia = CAST(GETDATE()-7 AS DATE)
	
	SELECT B.* 
	INTO #Job_Disabled
	FROM Status_Job_SQL_Agent A
		JOIN Status_Job_SQL_Agent B ON A.Name = B.Name
	WHERE A.Dt_Referencia = CAST(GETDATE()-1 AS DATE) --yesterday
		AND B.Dt_Referencia = CAST(GETDATE() AS DATE)	--today
		AND A.Fl_Status = 1 --yesterday
		AND B.Fl_Status = 0 --today

		
	IF EXISTS( SELECT TOP 1 null FROM #Job_Disabled )
	BEGIN

		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
				DROP TABLE ##Email_HTML

		SELECT TOP 50 *
		INTO ##Email_HTML
		FROM #Job_Disabled
	
		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter
			
		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				SET @Ds_Subject =  @Ds_Message_Alert_PTB + @@SERVERNAME 
		END
        ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
			SET @Ds_Subject =  @Ds_Message_Alert_ENG + @@SERVERNAME 
		END		   		


		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = 'Date_Modified DESC',
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
USE Traces
GO

-- Used on the next alert - stpAlert_Job_Failed
IF (OBJECT_ID('[dbo].fncAlert_Change_Invalid_Character') IS NOT NULL)
    DROP FUNCTION [dbo].fncAlert_Change_Invalid_Character
GO

CREATE FUNCTION [dbo].[fncAlert_Change_Invalid_Character] (
    @Text VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @Result NVARCHAR(4000)

    SELECT @Result = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
                            (REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
                                    (REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
                                            (REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
                                                    (REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                                                                                                                    @Text
                                                     ,NCHAR(1),N'?'),NCHAR(2),N'?'),NCHAR(3),N'?'),NCHAR(4),N'?'),NCHAR(5),N'?'),NCHAR(6),N'?')
                                             ,NCHAR(7),N'?'),NCHAR(8),N'?'),NCHAR(11),N'?'),NCHAR(12),N'?'),NCHAR(14),N'?'),NCHAR(15),N'?')
                                     ,NCHAR(16),N'?'),NCHAR(17),N'?'),NCHAR(18),N'?'),NCHAR(19),N'?'),NCHAR(20),N'?'),NCHAR(21),N'?')
                             ,NCHAR(22),N'?'),NCHAR(23),N'?'),NCHAR(24),N'?'),NCHAR(25),N'?'),NCHAR(26),N'?'),NCHAR(27),N'?')
                         ,NCHAR(28),N'?'),NCHAR(29),N'?'),NCHAR(30),N'?'),NCHAR(31),N'?');

    RETURN @Result
END
GO

GO
IF ( OBJECT_ID('[dbo].stpAlert_Job_Failed') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_Job_Failed
GO

CREATE PROCEDURE [dbo].stpAlert_Job_Failed
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
	WHERE Nm_Alert = 'Job Failed'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
	IF ( OBJECT_ID('tempdb..#Result_History_Jobs') IS NOT NULL )
		DROP TABLE #Result_History_Jobs

	CREATE TABLE #Result_History_Jobs (
		[Cod]				INT IDENTITY(1,1),
		[Instance_Id]		INT,
		[Job_Id]			VARCHAR(255),
		[Job_Name]			VARCHAR(255),
		[Step_Id]			INT,
		[Step_Name]			VARCHAR(255),
		[SQl_Message_Id]	INT,
		[Sql_Severity]		INT,
		[SQl_Message]		VARCHAR(4490),
		[Run_Status]		INT,
		[Run_Date]			VARCHAR(20),
		[Run_Time]			VARCHAR(20),
		[Run_Duration]		INT,
		[Operator_Emailed]	VARCHAR(100),
		[Operator_NetSent]	VARCHAR(100),
		[Operator_Paged]	VARCHAR(100),
		[Retries_Attempted]	INT,
		[Nm_Server]			VARCHAR(100)  
	)

	-- Declara as variaveis
	DECLARE @Dt_Start VARCHAR (8)


	SELECT	@Dt_Start  =	CONVERT(VARCHAR(8), (DATEADD (HOUR, -@Vl_Parameter, @Dt_Now)), 112)
	
	INSERT INTO #Result_History_Jobs
	EXEC [msdb].[dbo].[sp_help_jobhistory] 
			@mode = 'FULL', 
			@start_run_date = @Dt_Start

	IF ( OBJECT_ID('tempdb..#Alert_Job_Failed') IS NOT NULL )
		DROP TABLE #Alert_Job_Failed
	
	SELECT	TOP 50
			[Nm_Server] AS [Server],
			[Job_Name], 
			CASE	WHEN [Run_Status] = 0 THEN 'Failed'
					WHEN [Run_Status] = 1 THEN 'Succeeded'
					WHEN [Run_Status] = 2 THEN 'Retry (step only)'
					WHEN [Run_Status] = 3 THEN 'Cancelled'
					WHEN [Run_Status] = 4 THEN 'In-progress message'
					WHEN [Run_Status] = 5 THEN 'Unknown' 
			END AS [Status],
			CAST(	[Run_Date] + ' ' +
					RIGHT('00' + SUBSTRING([Run_Time], (LEN([Run_Time])-5), 2), 2) + ':' +
					RIGHT('00' + SUBSTRING([Run_Time], (LEN([Run_Time])-3), 2), 2) + ':' +
					RIGHT('00' + SUBSTRING([Run_Time], (LEN([Run_Time])-1), 2), 2) AS VARCHAR
				) AS [Dt_Execucao],
			RIGHT('00' + SUBSTRING(CAST([Run_Duration] AS VARCHAR), (LEN([Run_Duration])-5), 2), 2) + ':' +
			RIGHT('00' + SUBSTRING(CAST([Run_Duration] AS VARCHAR), (LEN([Run_Duration])-3), 2), 2) + ':' +
			RIGHT('00' + SUBSTRING(CAST([Run_Duration] AS VARCHAR), (LEN([Run_Duration])-1), 2), 2) AS [Run_Duration],
			CAST([SQl_Message] AS VARCHAR(3990)) AS [SQL_Message]
	INTO #Alert_Job_Failed
	FROM #Result_History_Jobs 
	WHERE 
		 -- [Step_Id] = 0 AND condição para o retry
		  [Run_Status] = 0 AND 
		  DATEADD(SECOND,[Run_Duration], CAST	(	
					[Run_Date] + ' ' + RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-5), 2), 2) + ':' +
					RIGHT('00' + SUBSTRING([Run_Time], (LEN([Run_Time])-3), 2), 2) + ':' +
					RIGHT('00' + SUBSTRING([Run_Time], (LEN([Run_Time])-1), 2), 2) AS DATETIME
				)) >= DATEADD(HOUR, -@Vl_Parameter, @Dt_Now) AND
		  CAST	(	[Run_Date] + ' ' + RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-5), 2), 2) + ':' +
					RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-3), 2), 2) + ':' +
					RIGHT('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-1), 2), 2) AS DATETIME
				) < @Dt_Now

			

	IF EXISTS(SELECT null FROM #Alert_Job_Failed)
	BEGIN
		
		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
			DROP TABLE ##Email_HTML

		SELECT	[Job_Name] [Job Name], 
				[Status] , 
				[Dt_Execucao] [Execution Date], 
				[Run_Duration] [Duration], 
				dbo.fncAlert_Change_Invalid_Character([SQL_Message]) AS [SQL Message]
		INTO ##Email_HTML
		FROM #Alert_Job_Failed

				 
		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter
			
						
		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB),'###1',@Vl_Parameter)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
		END
        ELSE 
		BEGIN
			SET @Header = REPLACE(REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG),'###1',@Vl_Parameter)
			SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		END		 

		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)			
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Execution Date] DESC',
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


GO
IF ( OBJECT_ID('[dbo].stpAlert_Login_Failed') IS NOT NULL )
	DROP PROCEDURE [dbo].stpAlert_Login_Failed
GO
/*******************************************************************************************************************************
--	ALERTA: Falhas Login SQL
*******************************************************************************************************************************/
CREATE procedure [dbo].stpAlert_Login_Failed
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @Id_Alert_Parameter SMALLINT, @Fl_Enable BIT, @Fl_Type TINYINT, @Vl_Parameter SMALLINT,@Ds_Email VARCHAR(500),@Ds_Profile_Email VARCHAR(200),@Dt_Now DATETIME,@Vl_Parameter_2 INT,
		@Ds_Email_Information_1_ENG VARCHAR(200), @Ds_Email_Information_2_ENG VARCHAR(200), @Ds_Email_Information_1_PTB VARCHAR(200), @Ds_Email_Information_2_PTB VARCHAR(200),
		@Ds_Message_Alert_ENG varchar(1000),@Ds_Message_Clear_ENG varchar(1000),@Ds_Message_Alert_PTB varchar(1000),@Ds_Message_Clear_PTB varchar(1000), @Ds_Subject VARCHAR(500)
	
	DECLARE @Company_Link  VARCHAR(4000),@Line_Space VARCHAR(4000),@Header_Default VARCHAR(4000),@Header VARCHAR(4000),@Fl_Language BIT,@Final_HTML VARCHAR(MAX),@HTML VARCHAR(MAX)										

					
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
	WHERE Nm_Alert = 'Login Failed'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
	IF (OBJECT_ID('tempdb..#LoginFailed') IS NOT NULL)
		DROP TABLE #LoginFailed
	
	CREATE TABLE #LoginFailed (
		  Texto           Varchar(Max),
		  Qtd_Erro           INT 
	)
		
	INSERT INTO #LoginFailed(Texto,Qtd_Erro )
	SELECT RTRIM([Text]), COUNT(*)
	FROM ##Error_Log_Result
	WHERE [LogDate] >= GETDATE()-1
		AND [Text] LIKE '%Login failed for user%'
	GROUP BY [Text]
		
	IF ((SELECT sum(Qtd_Erro) FROM #LoginFailed) > @Vl_Parameter)
	BEGIN

		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
				DROP TABLE ##Email_HTML

		select 
			[Texto] [Text],
			Qtd_Erro [Total Error] 
		INTO ##Email_HTML
		from #LoginFailed
				 
		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter


			
		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB),'###1',@Vl_Parameter)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
		END
        ELSE 
		BEGIN
			SET @Header = REPLACE(REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG),'###1',@Vl_Parameter)
			SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		END		   		

		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Total Error]  desc',
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

GO
IF ( OBJECT_ID('[dbo].stpAlert_Long_Runnning_Process') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_Long_Runnning_Process
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stpAlert_Long_Runnning_Process]
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
	WHERE Nm_Alert = 'Long Running Process'

	IF @Fl_Enable = 0
		RETURN
	
	SELECT *
	INTO #WhoIsActive_Result
	FROM ##WhoIsActive_Result
		

	-- Exclui os registros das queries com menos de 2 horas de execução
	DELETE #WhoIsActive_Result	
	where DATEDIFF(HOUR, [Start Time], GETDATE()) < @Vl_Parameter
		OR ISNULL([Wait Info],'') LIKE '%XE_LIVE_TARGET_TVF%' -- IGNORE this wait type
		OR ISNULL([Wait Info],'') LIKE '%BROKER_RECEIVE_WAITFOR%' -- IGNORE this wait type
		OR [Status] = 'sleeping' -- IGNORE this status
		OR ISNULL([Wait Info],'') LIKE '%SP_SERVER_DIAGNOSTICS_SLEEP%' -- IGNORE this wait type
			
	--select * from #WhoIsActive_Result

	-- Do we have long queries?
	IF exists(SELECT NULL FROM #WhoIsActive_Result)
	BEGIN		
			--	select * from #WhoIsActive_Result	

			IF ( OBJECT_ID('tempdb..##Email_HTML_Alert_Long_Runnning_Process') IS NOT NULL )
					DROP TABLE ##Email_HTML_Alert_Long_Runnning_Process

			SELECT	*
			INTO ##Email_HTML_Alert_Long_Runnning_Process
			FROM #WhoIsActive_Result
		
		-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter
			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_Alert_Long_Runnning_Process', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[dd hh:mm:ss.mss] desc',

				@Ds_Saida = @HTML OUT				-- varchar(max)

			-- First Result
			SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space 		
						
		--	EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'							
		
			-- Fl_Type = 1 : ALERT	
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 1	
	
	END		

END  
GO


IF ( OBJECT_ID('[dbo].stpAlert_Slow_File_Growth') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_Slow_File_Growth
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].stpAlert_Slow_File_Growth
AS
BEGIN
	SET NOCOUNT ON

		DECLARE @Id_Alert_Parameter SMALLINT, @Fl_Enable BIT, @Fl_Type TINYINT, @Vl_Parameter SMALLINT,@Ds_Email VARCHAR(500),@Ds_Profile_Email VARCHAR(200),@Dt_Now DATETIME,@Vl_Parameter_2 INT,
		@Ds_Email_Information_1_ENG VARCHAR(200), @Ds_Email_Information_2_ENG VARCHAR(200), @Ds_Email_Information_1_PTB VARCHAR(200), @Ds_Email_Information_2_PTB VARCHAR(200),
		@Ds_Message_Alert_ENG varchar(1000),@Ds_Message_Clear_ENG varchar(1000),@Ds_Message_Alert_PTB varchar(1000),@Ds_Message_Clear_PTB varchar(1000), @Ds_Subject VARCHAR(500)
	
	DECLARE @Company_Link  VARCHAR(4000),@Line_Space VARCHAR(4000),@Header_Default VARCHAR(4000),@Header VARCHAR(4000),@Fl_Language BIT,@Final_HTML VARCHAR(MAX),@HTML VARCHAR(MAX)		
	
	declare @Ds_Alinhamento VARCHAR(10),@Ds_OrderBy VARCHAR(MAX) 	

		
	
	if not exists(SELECT null FROM sys.traces WHERE is_default = 1)
		return
	
							
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
	WHERE Nm_Alert = 'Slow File Growth'

	IF @Fl_Enable = 0
		RETURN

	DECLARE @Ds_Arquivo_Trace VARCHAR(500) = (SELECT [path] FROM sys.traces WHERE is_default = 1);
	DECLARE @Index INT = PATINDEX('%\%', REVERSE(@Ds_Arquivo_Trace));
	DECLARE @Nm_Arquivo_Trace VARCHAR(500) = LEFT(@Ds_Arquivo_Trace, LEN(@Ds_Arquivo_Trace) - @Index) + '\log.trc';

	DECLARE @Dt_Referencia DATETIME = DATEADD(HOUR, @Vl_Parameter_2*-1, GETDATE())

	IF ( OBJECT_ID('tempdb..#Alert_File_Growth') IS NOT NULL ) 
		DROP TABLE #Alert_File_Growth

	SELECT DatabaseName AS Nm_Database,
		   [Filename],
		   (Duration / 1000000) AS Duration,
		   StartTime,
		   EndTime,
		   ROUND((IntegerData * 8.0 / 1024),2) AS Growth_Size,
		   ApplicationName,
		   HostName,
		   LoginName
	INTO #Alert_File_Growth
	FROM::fn_trace_gettable(@Nm_Arquivo_Trace, DEFAULT) A
	WHERE EventClass >= 92
		  AND EventClass <= 95
		  AND StartTime > @Dt_Referencia
		  AND ServerName = @@servername
		  AND ROUND((Duration / 1000000),2) >= @Vl_Parameter
	ORDER BY A.StartTime DESC;
	
	-- Do we have some slow growth?
	IF EXISTS( SELECT null FROM #Alert_File_Growth )
	BEGIN
			
		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
			DROP TABLE ##Email_HTML

		select	TOP 50
				Nm_Database,
				ISNULL(CAST([Filename] AS VARCHAR), '-')		AS [File Name],
				ISNULL(CAST([Duration] AS VARCHAR), '-')		AS [Duration],
				ISNULL(CAST([StartTime] AS VARCHAR), '-')		AS [Start Time],
				ISNULL(CAST([EndTime] AS VARCHAR), '-')			AS [End Time],
				ISNULL(CAST([Growth_Size] AS VARCHAR), '-')		AS [Growth Size],
				ISNULL(CAST([ApplicationName] AS VARCHAR), '-') 	AS [Application],
				ISNULL(CAST([HostName] AS VARCHAR), '-')		AS [Host Name],
				ISNULL(CAST([LoginName] AS VARCHAR), '-')		AS [Login]
		INTO ##Email_HTML
		from #Alert_File_Growth	
		 
		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter
			
		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB),'###1',@Vl_Parameter)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
		END
        ELSE 
		BEGIN
			SET @Header = REPLACE(REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG),'###1',@Vl_Parameter)
			SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		END		   		

		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_Saida = @HTML OUT				-- varchar(max)

	
		-- First Result
		SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space + @Company_Link	

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'									
		
		-- Fl_Type = 1 : ALERT	
		INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
		SELECT @Id_Alert_Parameter, @Ds_Subject, 1			

		END		-- END - ALERT
END

GO


GO
IF ( OBJECT_ID('[dbo].stpAlert_Without_Clear') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_Without_Clear
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************************************************************************
--	Alert: Alerts sem Clear
*******************************************************************************************************************************/
CREATE PROCEDURE [dbo].stpAlert_Without_Clear
AS
BEGIN
	SET NOCOUNT ON
	SET DATEFORMAT YMD

		DECLARE @Id_Alert_Parameter SMALLINT, @Fl_Enable BIT, @Fl_Type TINYINT, @Vl_Parameter SMALLINT,@Ds_Email VARCHAR(500),@Ds_Profile_Email VARCHAR(200),@Dt_Now DATETIME,@Vl_Parameter_2 INT,
		@Ds_Email_Information_1_ENG VARCHAR(200), @Ds_Email_Information_2_ENG VARCHAR(200), @Ds_Email_Information_1_PTB VARCHAR(200), @Ds_Email_Information_2_PTB VARCHAR(200),
		@Ds_Message_Alert_ENG varchar(1000),@Ds_Message_Clear_ENG varchar(1000),@Ds_Message_Alert_PTB varchar(1000),@Ds_Message_Clear_PTB varchar(1000), @Ds_Subject VARCHAR(500)
	
	DECLARE @Company_Link  VARCHAR(4000),@Line_Space VARCHAR(4000),@Header_Default VARCHAR(4000),@Header VARCHAR(4000),@Fl_Language BIT,@Final_HTML VARCHAR(MAX),@HTML VARCHAR(MAX)		
	
	DECLARE @Ds_Alinhamento VARCHAR(10),@Ds_OrderBy VARCHAR(MAX)
		

					
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
	WHERE Nm_Alert = 'Alert Without Clear'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
	IF(OBJECT_ID('tempdb..#Alerts') IS NOT NULL)
		DROP TABLE #Alerts

	CREATE TABLE #Alerts (
		Id_Alert INT,
		Id_Alert_Parameter INT,
		Nm_Alert VARCHAR(200),
		Ds_Message VARCHAR(2000),
		Dt_Alert DATETIME,
		Fl_Type BIT,
		Run_Duration VARCHAR(18)
	)

	DECLARE @Dt_Referencia DATETIME = DATEADD(HOUR, -24, GETDATE())

	INSERT INTO #Alerts
	SELECT [Id_Alert], A.[Id_Alert_Parameter], [Nm_Alert], [Ds_Message], [Dt_Alert], [Fl_Type], NULL	
	FROM [dbo].[Alert] A WITH(NOLOCK)
	JOIN [dbo].[Alert_Parameter] B WITH(NOLOCK) ON A.Id_Alert_Parameter = B.Id_Alert_Parameter
	WHERE [Dt_Alert] > @Dt_Referencia

	IF(OBJECT_ID('tempdb..#Alert_Without_Clear') IS NOT NULL)
		DROP TABLE #Alert_Without_Clear

	CREATE TABLE #Alert_Without_Clear
	(
		[Nm_Alert] VARCHAR(200),
		[Ds_Message] VARCHAR(2000),
		[Dt_Alert] DATETIME,
		[Run_Duration] VARCHAR(18)
	)
	
	INSERT INTO #Alert_Without_Clear
	SELECT	[Nm_Alert], [Ds_Message], [Dt_Alert],
			RIGHT('00' + CAST((DATEDIFF(SECOND,Dt_Alert, GETDATE()) / 86400) AS VARCHAR), 2) + ' Day(s) ' +	-- day
			RIGHT('00' + CAST((DATEDIFF(SECOND,Dt_Alert, GETDATE()) / 3600 % 24) AS VARCHAR), 2) + ':' +		-- Hour
			RIGHT('00' + CAST((DATEDIFF(SECOND,Dt_Alert, GETDATE()) / 60 % 60) AS VARCHAR), 2) + ':' +			-- Minutes
			RIGHT('00' + CAST((DATEDIFF(SECOND,Dt_Alert, GETDATE()) % 60) AS VARCHAR), 2) AS [Run_Duration]	-- Seconds	
	FROM [dbo].[Alert] A WITH(NOLOCK)
	JOIN [dbo].[Alert_Parameter] B WITH(NOLOCK) ON A.Id_Alert_Parameter = B.Id_Alert_Parameter
	WHERE	[Id_Alert] = ( SELECT MAX([Id_Alert]) FROM [dbo].[Alert] B WITH(NOLOCK) WHERE A.Id_Alert_Parameter = B.Id_Alert_Parameter )
			AND B.[Fl_Clear] = 1	-- 
			AND A.[Fl_Type] = 1		-- Alert
	ORDER BY [Dt_Alert]
 

	
	--	 Do we have Alert without Clear?
	IF EXISTS( SELECT null FROM #Alert_Without_Clear )
	BEGIN
			
		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
			DROP TABLE ##Email_HTML
		
		SELECT	[Nm_Alert] [Alert],
				ISNULL([Ds_Message], '-') AS [Message],
				ISNULL(CONVERT(VARCHAR, [Dt_Alert], 120), '-') AS [Alert Date],
				ISNULL([Run_Duration], '-') AS [Opened Duration]
		INTO ##Email_HTML
		FROM #Alert_Without_Clear	

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

		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)
			@Ds_Alinhamento  = 'center',
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

use Traces

GO
IF ( OBJECT_ID('[dbo].stpAlert_Rebuild_Failed') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_Rebuild_Failed
GO
USE [Traces]
GO
/****** Object:  StoredProcedure [dbo].[stpAlert_Rebuild_Failed]    Script Date: 7/29/2019 5:48:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stpAlert_Rebuild_Failed]
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
		@Vl_Parameter = Vl_Parameter,
		@Ds_Email = Ds_Email,
		@Fl_Language = Fl_Language,
		@Ds_Profile_Email = Ds_Profile_Email,
		@Vl_Parameter_2 = Vl_Parameter_2,	
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
	WHERE Nm_Alert = 'Rebuild Failed'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
		
	declare @Dt_Log datetime, @blocking_session_id int

	select top 1 @Dt_Log= Dt_Log, @blocking_session_id = blocking_session_id
	from Log_Whoisactive
	where Dt_Log >= dateadd(hh,-@Vl_Parameter,getdate())
		and blocking_session_id is not null
		and cast(sql_text as varchar(max)) like '%ALTER INDEX%'
	order by Dt_Log desc

	IF ( OBJECT_ID('tempdb..#Rebuild_Failed_By_Lock') IS NOT NULL )
		DROP TABLE #Rebuild_Failed_By_Lock

	select Dt_Log, 
		[dd hh:mm:ss.mss],
		database_name,
		session_id,
		blocking_session_id,
		cast(isnull(sql_text,sql_command) as varchar(max)) Query,
		login_name,
		wait_info,
		status,
		host_name,
		CPU,
		reads,
		writes,
		program_name,
		open_tran_count
	into #Rebuild_Failed_By_Lock
	from Log_Whoisactive	
	where Dt_Log = @Dt_Log	and (session_id = @blocking_session_id or blocking_session_id = @blocking_session_id)

	
	UPDATE #Rebuild_Failed_By_Lock
	SET Query = REPLACE( REPLACE( REPLACE( REPLACE( CAST(Query AS NVARCHAR(4000)), '<?query --', ''), '--?>', ''), '&gt;', '>'), '&lt;', '')
				

	IF EXISTS(SELECT null FROM #Rebuild_Failed_By_Lock)
	BEGIN
		
		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
			DROP TABLE ##Email_HTML

		SELECT	
			CONVERT(VARCHAR(20), Dt_Log, 120) [Log Date], 
			[dd hh:mm:ss.mss] ,
			database_name [Database],
			session_id [Session ID],
			blocking_session_id [Blocking Session ID],
			Query,
			login_name [Login],
			wait_info [Wait Info],
			status [Status],
			host_name [Host Name],
			CPU,
			reads [Reads],
			writes [Writes],
			program_name [Program Name]
		INTO ##Email_HTML
		FROM #Rebuild_Failed_By_Lock
						 
		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter
			
						
		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				SET @Ds_Subject =  @Ds_Message_Alert_PTB + @@SERVERNAME 
		END
        ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
			SET @Ds_Subject =  @Ds_Message_Alert_ENG+@@SERVERNAME 
		END		 

		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)			
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[dd hh:mm:ss.mss] DESC',
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


GO
IF ( OBJECT_ID('[dbo].stpSend_Mail_Executing_Process') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpSend_Mail_Executing_Process
GO

/*******************************************************************************************************************************
--	PROCEDURE ENVIA EMAIL WHOISACTIVE DBA
*******************************************************************************************************************************/

CREATE PROCEDURE [dbo].stpSend_Mail_Executing_Process
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
	WHERE Nm_Alert = 'Process Executing'
	
	IF @Fl_Enable = 0
		RETURN
					
					
	IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
					DROP TABLE ##Email_HTML	
				 	
	SELECT TOP 50 *
	INTO ##Email_HTML
	FROM ##WhoIsActive_Result


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

	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[dd hh:mm:ss.mss] desc',
		@Ds_Saida = @HTML OUT				-- varchar(max)

	-- First Result
	SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space 		

	EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'	
	   
END
GO


IF OBJECT_ID('[dbo].[stpSQLServer_Configuration]') is not null
	DROP PROCEDURE [dbo].[stpSQLServer_Configuration]
GO

Create PROCEDURE [dbo].[stpSQLServer_Configuration]
AS
BEGIN


SET NOCOUNT ON

	DECLARE @Id_Alert_Parameter SMALLINT, @Fl_Enable BIT, @Fl_Type TINYINT, @Vl_Parameter SMALLINT,@Ds_Email VARCHAR(500),@Ds_Profile_Email VARCHAR(200),@Dt_Now DATETIME,@Vl_Parameter_2 INT,
		@Ds_Email_Information_1_ENG VARCHAR(200), @Ds_Email_Information_2_ENG VARCHAR(200), @Ds_Email_Information_1_PTB VARCHAR(200), @Ds_Email_Information_2_PTB VARCHAR(200),
		@Ds_Message_Alert_ENG varchar(1000),@Ds_Message_Clear_ENG varchar(1000),@Ds_Message_Alert_PTB varchar(1000),@Ds_Message_Clear_PTB varchar(1000), @Ds_Subject VARCHAR(500)
	
	DECLARE @Company_Link  VARCHAR(4000),@Line_Space VARCHAR(4000),@Header_Default VARCHAR(4000),@Header VARCHAR(4000),@Fl_Language BIT,@Final_HTML VARCHAR(MAX),@HTML VARCHAR(MAX)		

	declare @Ds_Alinhamento VARCHAR(10),@Ds_OrderBy VARCHAR(MAX) 	

	SET @Final_HTML = ''	
	
				
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
	WHERE Nm_Alert = 'SQL Server Configuration'
	
	IF @Fl_Enable = 0
		RETURN
		
	-- Get HTML Informations
	SELECT @Company_Link = Company_Link,
		@Line_Space = Line_Space,
		@Header_Default = Header
	FROM HTML_Parameter		

/***********************************************************************************************************************************
--	Read Error Log
***********************************************************************************************************************************/
	IF(OBJECT_ID('tempdb..#ErrorLogFiles') IS NOT NULL) DROP TABLE #ErrorLogFiles

	CREATE TABLE #ErrorLogFiles(
		Id_File INT,
		Dt_Creation VARCHAR(20),
		Size BIGINT
	)

	INSERT INTO #ErrorLogFiles
	EXEC sp_enumerrorlogs;


/***********************************************************************************************************************************
--	SQL Server Version
***********************************************************************************************************************************/
	
	IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
		DROP TABLE ##Email_HTML
						
	SELECT  @@VERSION AS [SQL Server Version] INTO ##Email_HTML
	

	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Versão do SQL Server')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','SQL Server Version')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		
	

/***********************************************************************************************************************************
--	Server Configuration
***********************************************************************************************************************************/
	IF ( OBJECT_ID('tempdb..##Email_HTML_1') IS NOT NULL )
		DROP TABLE ##Email_HTML_1
		
	CREATE TABLE ##Email_HTML_1(
		[Configuration] VARCHAR(256) NULL,
		[Value] VARCHAR(256) NULL
	)

	INSERT INTO ##Email_HTML_1
	SELECT 'ServerName' AS [Ds_Configuration], CAST(SERVERPROPERTY('ServerName') AS VARCHAR(256)) AS [Ds_Value]  
	UNION
	SELECT 'InstanceName' AS [Ds_Configuration], CAST(ISNULL(SERVERPROPERTY('InstanceName'), SERVERPROPERTY('ServerName')) AS VARCHAR(256)) AS [Ds_Value]
	UNION
	SELECT 'IsClustered' AS [Ds_Configuration], CASE WHEN SERVERPROPERTY('IsClustered') = 0 THEN 'NÃO' ELSE 'sim' END AS [Ds_Value]
	UNION
	SELECT 'ComputerNamePhysicalNetBIOS' AS [Ds_Configuration], CAST(SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS VARCHAR(256)) AS [Ds_Value]
	UNION
	SELECT 'Collation' AS [Ds_Configuration], CAST(SERVERPROPERTY('Collation') AS VARCHAR(256)) AS [Ds_Value]
	UNION
	SELECT 'IsFullTextInstalled' AS [Ds_Configuration], CASE WHEN SERVERPROPERTY('IsFullTextInstalled') = 0 THEN 'NÃO' ELSE 'SIM' END AS [Ds_Value]
	UNION
	SELECT 'FilestreamConfiguredLevel' AS [Ds_Configuration], CASE WHEN SERVERPROPERTY('FilestreamConfiguredLevel') = 0 THEN 'NÃO' ELSE 'SIM' END AS [Ds_Value]
	UNION
	SELECT 'IsHadrEnabled' AS [Ds_Configuration], CASE WHEN SERVERPROPERTY('IsHadrEnabled') = 0 THEN 'NÃO' ELSE 'SIM' END AS [Ds_Value] 
	UNION
	SELECT 'InstanceDefaultDataPath' AS [Ds_Configuration], ISNULL(CAST(SERVERPROPERTY('InstanceDefaultDataPath') AS VARCHAR(256)), '-') AS [Ds_Value]
	UNION
	SELECT 'InstanceDefaultLogPath' AS [Ds_Configuration], ISNULL(CAST(SERVERPROPERTY('InstanceDefaultLogPath') AS VARCHAR(256)), '-') AS [Ds_Value]
	UNION
	SELECT 'Quantidade de Arquivos do Error Log' AS [Ds_Configuration], CAST(COUNT(*) AS VARCHAR) AS [Ds_Value] FROM #ErrorLogFiles
							 
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Configurações do Servidor')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Server Configuration')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_1', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
				
				

/***********************************************************************************************************************************
--	Instance Configuration
***********************************************************************************************************************************/
					
	IF ( OBJECT_ID('tempdb..##Email_HTML_2') IS NOT NULL )
		DROP TABLE ##Email_HTML_2

	SELECT	name [Name], 
		CAST(value AS VARCHAR(20))			AS [Value],
		CAST(value_in_use AS VARCHAR(20))	AS [Value In Use],
		CAST(minimum AS VARCHAR(20))		AS [Minimum],
		CAST(maximum AS VARCHAR(20))		AS [Maximum],
		[description]
	INTO ##Email_HTML_2
	FROM sys.configurations WITH (NOLOCK)
	ORDER BY name

	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Configurações da Instância')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Instance Configuration')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_2', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Name]',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
				

/***********************************************************************************************************************************
--	Disk Space
***********************************************************************************************************************************/
	DECLARE @OAP_Habilitado sql_variant

	SELECT	@OAP_Habilitado = value_in_use
	FROM sys.configurations WITH (NOLOCK)
	where name = 'Ole Automation Procedures'

	IF(OBJECT_ID('tempdb..#DiskSpace') IS NOT NULL) DROP TABLE #DiskSpace

		CREATE TABLE #DiskSpace (
			[Drive]				VARCHAR(50) ,
			[Size (MB)]		INT,
			[Used (MB)]		INT,
			[Free (MB)]		INT,
			[Free (%)]			INT,
			[Used (%)]			INT,
			[Used by SQL (MB)]	INT, 
			[Date]				SMALLDATETIME
		)
		
	IF (@OAP_Habilitado = 1)
	BEGIN	
		IF(OBJECT_ID('tempdb..#dbspace') IS NOT NULL) DROP TABLE #dbspace

		CREATE TABLE #dbspace (
			[Name]		SYSNAME,
			[Path]	VARCHAR(200),
			[Size]	VARCHAR(10),
			[Drive]		VARCHAR(30)
		)

	

		EXEC sp_MSforeachdb '	Use [?] 
								INSERT INTO #dbspace 
								SELECT	CONVERT(VARCHAR(25), DB_NAME())''Database'', CONVERT(VARCHAR(60), FileName),
										CONVERT(VARCHAR(8), Size/128) ''Size in MB'', CONVERT(VARCHAR(30), Name) 
								FROM [sysfiles]'

		DECLARE @hr INT, @fso INT, @size FLOAT, @TotalSpace INT, @MBFree INT, @Percentage INT, 
				@SQLDriveSize INT, @drive VARCHAR(1), @fso_Method VARCHAR(255), @mbtotal INT	
	
		set @mbtotal = 0

		EXEC @hr = [master].[dbo].[sp_OACreate] 'Scripting.FilesystemObject', @fso OUTPUT

		IF (OBJECT_ID('tempdb..#space') IS NOT NULL) 
			DROP TABLE #space

		CREATE TABLE #space (
			[drive] CHAR(1), 
			[mbfree] INT
		)
	
		INSERT INTO #space EXEC [master].[dbo].[xp_fixeddrives]
	
		DECLARE CheckDrives Cursor For SELECT [drive], [mbfree] 
		FROM #space
	
		Open CheckDrives
		FETCH NEXT FROM CheckDrives INTO @drive, @MBFree

		WHILE(@@FETCH_STATUS = 0)
		BEGIN
			SET @fso_Method = 'Drives("' + @drive + ':").TotalSize'
		
			SELECT @SQLDriveSize = SUM(CONVERT(INT, Size)) 
			FROM #dbspace 
			WHERE SUBSTRING(Path, 1, 1) = @drive
		
			EXEC @hr = sp_OAMethod @fso, @fso_Method, @size OUTPUT
		
			SET @mbtotal = @size / (1024 * 1024)
		
			INSERT INTO #DiskSpace 
			VALUES(	@drive + ':', @mbtotal, @mbtotal-@MBFree, @MBFree, (100 * round(@MBFree, 2) / round(@mbtotal, 2)), 
					(100 - 100 * round(@MBFree,2) / round(@mbtotal, 2)), @SQLDriveSize, GETDATE())

			FETCH NEXT FROM CheckDrives INTO @drive, @MBFree
		END
		CLOSE CheckDrives
		DEALLOCATE CheckDrives
		
	END
							
	IF ( OBJECT_ID('tempdb..##Email_HTML_3') IS NOT NULL )
		DROP TABLE ##Email_HTML_3

	SELECT	[Drive], 
			CAST([Size (MB)] AS VARCHAR) AS [Size (MB)], 
			CAST([Used (MB)] AS VARCHAR) AS [Used (MB)], 
			CAST([Free (MB)] AS VARCHAR) AS [Free (MB)], 
			CAST([Used (%)] AS VARCHAR) AS [Used (%)], 
			CAST([Free (%)] AS VARCHAR) AS [Free (%)], 
			CAST([Used by SQL (MB)] AS VARCHAR) AS [Used by SQL (MB)]
	INTO ##Email_HTML_3
	FROM #DiskSpace
	
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Espaço em Disco no Servidor')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Server Disk Space')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_3', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Drive]',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
				

/***********************************************************************************************************************************
--	Trace Flags
***********************************************************************************************************************************/
	IF ( OBJECT_ID('tempdb..##Email_HTML_4') IS NOT NULL )
		DROP TABLE ##Email_HTML_4
						
	CREATE TABLE ##Email_HTML_4(
		[Trace Flag] INT NULL,
		Status INT NULL,
		Global INT NULL,
		Session INT NULL
	)

	INSERT INTO ##Email_HTML_4
	EXEC ('DBCC TRACESTATUS (-1)')
											 
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Trace Flags Habilitadas')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Enabled Trace Flag')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_4', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
			
------------------------------------------------------------------------------------------------------------------------------------
--	Jobs da Instância - BODY
------------------------------------------------------------------------------------------------------------------------------------
     IF ( OBJECT_ID('tempdb..##Email_HTML_5') IS NOT NULL )
		DROP TABLE ##Email_HTML_5

	SELECT 
		sj.name AS [Job Name],  
		SUSER_SNAME(sj.owner_sid) AS [Job Owner],
		CASE WHEN sj.[enabled] = 1 THEN 'SIM' ELSE 'NÃO' END AS [Enabled],
		ISNULL(op.name,'-') AS Operator,
		CONVERT(VARCHAR(20),sj.date_created,120) AS [Date Created],
		ISNULL(STUFF(STUFF(CAST(js.next_run_date as varchar),7,0,'-'),5,0,'-') + ' ' + 
				STUFF(STUFF(REPLACE(STR(js.next_run_time,6,0),' ','0'),5,0,':'),3,0,':'), '-') AS [Next Run],
		ISNULL(STUFF(STUFF(CAST(jh.run_date as varchar),7,0,'-'),5,0,'-') + ' ' + 
				STUFF(STUFF(REPLACE(STR(jh.run_time,6,0),' ','0'),5,0,':'),3,0,':'), '-') AS [Last Run],
		ISNULL(CASE	WHEN jh.[run_status] = 0 THEN 'Failed'
				WHEN jh.[run_status] = 1 THEN 'Succeeded'
				WHEN jh.[run_status] = 2 THEN 'Retry (step only)'
				WHEN jh.[run_status] = 3 THEN 'Cancelled'
				WHEN jh.[run_status] = 4 THEN 'In-progress message'
				WHEN jh.[run_status] = 5 THEN 'Unknown' 
		END, '-') [Status Last Execution]	
	INTO ##Email_HTML_5
	FROM msdb.dbo.sysjobs AS sj WITH (NOLOCK)
	INNER JOIN msdb.dbo.syscategories AS sc WITH (NOLOCK) ON sj.category_id = sc.category_id
	LEFT OUTER JOIN msdb.dbo.sysjobschedules AS js WITH (NOLOCK) ON sj.job_id = js.job_id
	LEFT JOIN (
			SELECT	j.job_id, MAX(instance_id) instance_id
			FROM msdb.dbo.sysjobs j 
			INNER JOIN msdb.dbo.sysjobhistory jh ON jh.job_id = j.job_id
			GROUP BY j.job_id
		) AS A ON sj.job_id = A.job_id
	LEFT JOIN msdb.dbo.sysjobhistory jh ON jh.instance_id = A.instance_id
	LEFT JOIN msdb.dbo.sysoperators op ON sj.notify_email_operator_id = op.id				    
	ORDER BY sj.name

	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Jobs da Instância ')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','SQL Server Jobs')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_5', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Job Name]',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
				

/***********************************************************************************************************************************
--	SQL Server Alerts
***********************************************************************************************************************************/
	IF ( OBJECT_ID('tempdb..##Email_HTML_6') IS NOT NULL )
		DROP TABLE ##Email_HTML_6
	
	CREATE TABLE ##Email_HTML_6(
		Name VARCHAR(256) NULL, 
		[Event Source] VARCHAR(256) NULL, 
		[Message ID] INT NULL,
		[Severity] INT NULL,
		[Enabled] VARCHAR(3) NULL
	)

	INSERT INTO ##Email_HTML_6
	SELECT name, event_source, message_id, severity, CASE WHEN [enabled] = 1 THEN 'SIM' ELSE 'NÃO' END AS [enabled]
	FROM msdb.dbo.sysalerts WITH (NOLOCK)
	ORDER BY name
	
	IF @@ROWCOUNT = 0
	BEGIN
																	 
		IF @Fl_Language = 1 --Portuguese
		BEGIN
					INSERT INTO ##Email_HTML_6
			SELECT 'Sem Alertas de severidade',NULL,NULL,NULL,null		
			END
		ELSE 
			BEGIN
						INSERT INTO ##Email_HTML_6
			SELECT 'Without Severity Alerts',NULL,NULL,NULL,null	
			END			

	END
															 
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Alertas do SQL Server Agent')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','SQL Server Agent Alerts')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_6', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = 'Name',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
				
				
/***********************************************************************************************************************************
--	Error Log Files
***********************************************************************************************************************************/
	IF ( OBJECT_ID('tempdb..##Email_HTML_7') IS NOT NULL )
			DROP TABLE ##Email_HTML_7
	
	SELECT	CAST(Id_File AS VARCHAR(20))	AS [File ID],
					Dt_Creation [Creation Date], 					
					CAST(Size AS VARCHAR(50))	AS Size
	INTO ##Email_HTML_7
	FROM #ErrorLogFiles WITH (NOLOCK)
	
															 
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Arquivos do Error Log')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Error Log Files')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_7', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Creation Date] desc',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
				

/***********************************************************************************************************************************
--	Database Files
***********************************************************************************************************************************/

	IF (OBJECT_ID('tempdb..##MDFs_Sizes') IS NOT NULL)
		DROP TABLE ##MDFs_Sizes

	CREATE TABLE ##MDFs_Sizes (
		[Server]			VARCHAR(50),
		[Nm_Database]		VARCHAR(100),
		[Logical_Name]		VARCHAR(100),
		[Size]				NUMERIC(15,2),
		[Total_Used]	NUMERIC(15,2),
		[Free_Space (MB)] NUMERIC(15,2),
		[Free Space (%)] NUMERIC(15,2)
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

			INSERT INTO ##MDFs_Sizes
			SELECT	@@SERVERNAME, DB_NAME(), name as [Logical_Name], size, used, free, percent_free = cast((free * 100.0 / size) as numeric(15,2))
			FROM cte_datainfo	
	'
	IF ( OBJECT_ID('tempdb..##Email_HTML_8') IS NOT NULL )
		DROP TABLE ##Email_HTML_8

	SELECT *
	INTO ##Email_HTML_8
	FROM (
		SELECT	1 AS ID,
						DB_NAME(A.database_id) AS [Database],
						[name] AS [Logical Name],
						CASE [file_id] WHEN 1 THEN 'MDF' WHEN 2 THEN 'LDF' ELSE 'NDF' END AS [Type], 		
						CAST(B.[Size] AS VARCHAR) AS [Total Reserved],
						CAST(B.[Total_Used] AS VARCHAR) AS [Total Used],
						CAST(B.[Free_Space (MB)] AS VARCHAR) AS [Free Space (MB)],
						CAST(B.[Free Space (%)] AS VARCHAR) AS [Free Space (%)],
						CAST(CASE WHEN A.[Max_Size] = -1 THEN -1 ELSE (A.[Max_Size] / 1024) * 8 END AS VARCHAR) AS [Max Size (MB)], 
						CASE WHEN [is_percent_growth] = 1 
							THEN CAST(A.[Growth] AS VARCHAR) + ' %'
							ELSE CAST(CAST((A.[Growth] * 8 ) / 1024.00 AS NUMERIC(15, 2)) AS VARCHAR) + ' MB'
						END AS [Growth],
						A.[physical_name] AS [Filename],
						A.file_id [File ID]
		FROM [sys].[master_files] A WITH(NOLOCK)	
			JOIN ##MDFs_Sizes B ON DB_NAME(A.[database_id]) = B.[Nm_Database] and A.[name] = B.[Logical_Name]
		UNION ALL
		SELECT	2 AS ID,
				'TOTAL' AS [Database],
				'-' AS [Logical Name],
				'-' AS [Type],
				CAST(SUM(B.[Size]) AS VARCHAR) AS [Total Reserved],
				CAST(SUM(B.[Total_Used]) AS VARCHAR) AS [Total Used],
				'-' AS [Free Space (MB)],
				'-' AS [Free Space (%)],
				'-' AS [Max Size (MB)], 
				'-' AS [Growth],
				'-' AS [Filename],
				'-' AS [File ID]
		FROM [sys].[master_files] A WITH(NOLOCK)	
			JOIN ##MDFs_Sizes B ON DB_NAME(A.[database_id]) = B.[Nm_Database] and A.[name] = B.[Logical_Name]
		) A
		ORDER BY 	ID, [Database], [File ID]	    
	
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Informações Arquivos Databases')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Database File Informations')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_8', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Database]',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
							

/***********************************************************************************************************************************
--	I/O Operations
***********************************************************************************************************************************/

	IF ( OBJECT_ID('tempdb..##Email_HTML_9') IS NOT NULL )
		DROP TABLE ##Email_HTML_9
							
	SELECT  DB_NAME(fs.database_id) AS [Database Name] ,
			mf.physical_name AS [Physical Name],
			CAST(CAST(io_stall_read_ms / ( 1.0 + num_of_reads ) AS NUMERIC(10, 1)) AS VARCHAR) AS [AVG Read Stall (ms)] ,
			CAST(CAST(io_stall_write_ms / ( 1.0 + num_of_writes ) AS NUMERIC(10, 1)) AS VARCHAR) AS [AVG Write Stall (ms)] ,
			CAST(CAST(( io_stall_read_ms + io_stall_write_ms ) / ( 1.0 + num_of_reads
																+ num_of_writes ) AS NUMERIC(10,
																	1)) AS VARCHAR) AS [AVG IO Stall (ms)]
	INTO ##Email_HTML_9
	FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS fs
	INNER JOIN sys.master_files AS mf WITH ( NOLOCK ) ON fs.database_id = mf.database_id AND fs.[file_id] = mf.[file_id]		
								 

	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Informações de Operações de I/O')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','I/O Operations')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_9', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[AVG IO Stall (ms)] desc',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
	
/***********************************************************************************************************************************
--	Log File Information
***********************************************************************************************************************************/
					
	IF ( OBJECT_ID('tempdb..##Email_HTML_10') IS NOT NULL )
		DROP TABLE ##Email_HTML_10

	SELECT	db.[name] AS [Database Name], db.recovery_model_desc AS [Recovery Model], db.state_desc [Status],  
					CONVERT(DECIMAL(18,2), ls.cntr_value/1024.0)  AS [Log Size (MB)], 
					CAST(CONVERT(DECIMAL(18,2), lu.cntr_value/1024.0) AS VARCHAR) AS [Log Used (MB)],
					CAST(CAST(plu.cntr_value as DECIMAL(18,2)) AS VARCHAR) AS [Log Used (%)], 
					CAST(db.[compatibility_level] AS VARCHAR) AS [DB Compatibility Level], 
					db.page_verify_option_desc AS [Page Verify Option], 
					CASE db.is_auto_close_on WHEN 0 THEN 'NÃO' ELSE 'SIM' END AS [Is Auto Close ON],
					CASE db.is_auto_shrink_on WHEN 0 THEN 'NÃO' ELSE 'SIM' END AS [Is Auto Shrink ON],
					CASE db.is_published WHEN 0 THEN 'NÃO' ELSE 'SIM' END AS [Is Published],
					CASE db.is_distributor WHEN 0 THEN 'NÃO' ELSE 'SIM' END AS [Is Distributor]
			INTO ##Email_HTML_10
			FROM sys.databases AS db WITH (NOLOCK)
			INNER JOIN sys.dm_os_performance_counters AS lu WITH (NOLOCK)
			ON db.name = lu.instance_name
			INNER JOIN sys.dm_os_performance_counters AS ls WITH (NOLOCK)
			ON db.name = ls.instance_name
			INNER JOIN sys.dm_os_performance_counters AS plu WITH (NOLOCK)
			ON db.name = plu.instance_name
			WHERE	lu.counter_name LIKE N'Log File(s) Used Size (KB)%' 
					AND ls.counter_name LIKE N'Log File(s) Size (KB)%'
					AND plu.counter_name LIKE N'Percent Log Used%'
					--AND ls.cntr_value > 0	
	
	    												 
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Informações Arquivos Log (.LDF)')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Log File Information (.LDF)')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_10', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Log Size (MB)] desc',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
				
			
/***********************************************************************************************************************************
--	Informações Virtual Log Files
***********************************************************************************************************************************/
	/* nao funciona no sql server 2008
	IF(OBJECT_ID('tempdb..#VLFInfo') IS NOT NULL) DROP TABLE #VLFInfo

	CREATE TABLE #VLFInfo (
		RecoveryUnitID int, FileID  int,
		FileSize bigint, StartOffset bigint,
		FSeqNo      bigint, [Status]    bigint,
		Parity      bigint, CreateLSN   numeric(38)
	)

	IF(OBJECT_ID('tempdb..#VLFCountResults') IS NOT NULL) DROP TABLE #VLFCountResults
	 
	CREATE TABLE #VLFCountResults(
		DatabaseName sysname, 
		VLFCount int
	)
	 
	EXEC sp_MSforeachdb N'Use [?]; 

					INSERT INTO #VLFInfo 
					EXEC sp_executesql N''DBCC LOGINFO([?])''; 
	 
					INSERT INTO #VLFCountResults 
					SELECT DB_NAME(), COUNT(*) 
					FROM #VLFInfo; 

					TRUNCATE TABLE #VLFInfo;'
	 
	 					
	IF ( OBJECT_ID('tempdb..##Email_HTML_11') IS NOT NULL )
		DROP TABLE ##Email_HTML_11

	SELECT TOP 10	DatabaseName [Database], 
		VLFCount [Total VLF]
	INTO ##Email_HTML_11
	FROM #VLFCountResults
	
											 
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Informações Virtual Log File')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Virtual Log File Informations')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_11', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Total VLF] desc',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
				
*/


/***********************************************************************************************************************************
--	Informações Buffer Pool
***********************************************************************************************************************************/
	IF ( OBJECT_ID('tempdb..##Email_HTML_12') IS NOT NULL )
		DROP TABLE ##Email_HTML_12
		
	IF ( OBJECT_ID('tempdb..#AggregateBufferPoolUsage') IS NOT NULL )
		DROP TABLE #AggregateBufferPoolUsage
		
	SELECT	DB_NAME(database_id) AS [Database],
			CAST(COUNT(*) * 8/1024.0 AS DECIMAL (10,2))  AS CachedSize
	INTO #AggregateBufferPoolUsage
	FROM sys.dm_os_buffer_descriptors WITH (NOLOCK)
	WHERE database_id <> 32767 -- ResourceDB
	GROUP BY DB_NAME(database_id)	
	
	SELECT TOP 5
			[Database], 
			CAST(CachedSize AS VARCHAR) AS [Cached Size (MB)],
			CAST(CAST(CachedSize / SUM(CachedSize) OVER() * 100.0 AS DECIMAL(5,2)) AS VARCHAR) AS [Buffer Pool Percent]
	INTO ##Email_HTML_12
	FROM #AggregateBufferPoolUsage
	ORDER BY [Cached Size (MB)] DESC 
				    				
								 
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Informações Buffer Pool')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Buffer Pool Informations')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_12', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Cached Size (MB)] desc',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		

	
/***********************************************************************************************************************************
--	Informações Waits Stats
***********************************************************************************************************************************/
	IF(OBJECT_ID('tempdb..#Waits') IS NOT NULL) DROP TABLE #Waits

	SELECT wait_type, wait_time_ms/ 1000.0 AS [WaitS],
			  (wait_time_ms - signal_wait_time_ms) / 1000.0 AS [ResourceS],
			   signal_wait_time_ms / 1000.0 AS [SignalS],
			   waiting_tasks_count AS [WaitCount],
			   100.0 *  wait_time_ms / SUM (wait_time_ms) OVER() AS [Percentage],
			   ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS [RowNum]
	INTO #Waits
	FROM sys.dm_os_wait_stats WITH (NOLOCK)
	WHERE [wait_type] NOT IN (
		N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR', N'BROKER_TASK_STOP',
		N'BROKER_TO_FLUSH', N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
		N'CHKPT', N'CLR_AUTO_EVENT', N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE',
		N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE', N'DBMIRROR_WORKER_QUEUE',
		N'DBMIRRORING_CMD', N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
		N'EXECSYNC', N'FSAGENT', N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
		N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', N'HADR_LOGCAPTURE_WAIT', 
		N'HADR_NOTIFICATION_DEQUEUE', N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
		N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP', N'LOGMGR_QUEUE', N'ONDEMAND_TASK_QUEUE',
		N'PWAIT_ALL_COMPONENTS_INITIALIZED', 
		N'PREEMPTIVE_OS_AUTHENTICATIONOPS', N'PREEMPTIVE_OS_CREATEFILE', N'PREEMPTIVE_OS_GENERICOPS',
		N'PREEMPTIVE_OS_LIBRARYOPS', N'PREEMPTIVE_OS_QUERYREGISTRY',
		N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
		N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP', N'QDS_SHUTDOWN_QUEUE', N'REQUEST_FOR_DEADLOCK_SEARCH',
		N'RESOURCE_QUEUE', N'SERVER_IDLE_CHECK', N'SLEEP_BPOOL_FLUSH', N'SLEEP_DBSTARTUP',
		N'SLEEP_DCOMSTARTUP', N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY',
		N'SLEEP_MASTERUPGRADED', N'SLEEP_MSDBSTARTUP', N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
		N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT', N'SP_SERVER_DIAGNOSTICS_SLEEP',
		N'SQLTRACE_BUFFER_FLUSH', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', N'SQLTRACE_WAIT_ENTRIES',
		N'WAIT_FOR_RESULTS', N'WAITFOR', N'WAITFOR_TASKSHUTDOWN', N'WAIT_XTP_HOST_WAIT',
		N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG', N'WAIT_XTP_CKPT_CLOSE', N'XE_DISPATCHER_JOIN',
		N'XE_DISPATCHER_WAIT', N'XE_TIMER_EVENT')
		AND waiting_tasks_count > 0
	 
	IF ( OBJECT_ID('tempdb..##Email_HTML_13') IS NOT NULL )
		DROP TABLE ##Email_HTML_13

	SELECT TOP 5
		MAX (W1.wait_type) AS [Wait Type],
		CAST(CAST (MAX (W1.WaitS) AS DECIMAL (16,2)) AS VARCHAR) AS [Wait (s)],
		CAST(CAST (MAX (W1.ResourceS) AS DECIMAL (16,2)) AS VARCHAR) AS [Resource (s)],
		CAST(CAST (MAX (W1.SignalS) AS DECIMAL (16,2)) AS VARCHAR) AS [Signal (s)],
		CAST(MAX (W1.WaitCount) AS VARCHAR) AS [Wait Count],
		CAST(CAST (MAX (W1.Percentage) AS DECIMAL (5,2)) AS VARCHAR) AS [Wait (%)],
		CAST(CAST ((MAX (W1.WaitS) / MAX (W1.WaitCount)) AS DECIMAL (16,4)) AS VARCHAR) AS [AVG Wait (s)],
		CAST(CAST ((MAX (W1.ResourceS) / MAX (W1.WaitCount)) AS DECIMAL (16,4)) AS VARCHAR) AS [AVG Resource (s)],
		CAST(CAST ((MAX (W1.SignalS) / MAX (W1.WaitCount)) AS DECIMAL (16,4)) AS VARCHAR) AS [AVG Signal (s)]
	INTO ##Email_HTML_13
	FROM #Waits AS W1
	INNER JOIN #Waits AS W2 ON W2.RowNum <= W1.RowNum
	GROUP BY W1.RowNum
	HAVING SUM (W2.Percentage) - MAX (W1.Percentage) < 99 -- percentage threshold
	ORDER BY   CAST (MAX (W1.Percentage) AS DECIMAL (5,2)) DESC

	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Informações Waits Stats')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Wait informations')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_13', -- varchar(max)
				@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Wait (%)] desc',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		


/***********************************************************************************************************************************
--	Page Life Expectancy - HEADER
***********************************************************************************************************************************/
	IF ( OBJECT_ID('tempdb..##Email_HTML_14') IS NOT NULL )
		DROP TABLE ##Email_HTML_14

	-- PLE (Page Life Expectancy) by NUMA Node
	SELECT @@SERVERNAME AS [Server Name], [object_name] [Object Name], instance_name [Instance Name], CAST(cntr_value AS VARCHAR) AS [Page Life Expectancy]
	INTO ##Email_HTML_14
	FROM sys.dm_os_performance_counters WITH (NOLOCK)
	WHERE	[object_name] LIKE N'%Buffer Node%' -- Handles named instances
			AND counter_name = N'Page life expectancy'		
	
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Page Life Expectancy')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Page Life Expectancy')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_14', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		


/***********************************************************************************************************************************
--	Operators Agent - HEADER
***********************************************************************************************************************************/
  	IF ( OBJECT_ID('tempdb..##Email_HTML_15') IS NOT NULL )
		DROP TABLE ##Email_HTML_15
	
	SELECT	name [Name], 
			CASE enabled WHEN 1 THEN 'SIM' ELSE 'NÃO' END AS [Enabled], 
			email_address [Email Address]
	INTO ##Email_HTML_15
	from msdb.dbo.sysoperators				    

	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Operators Agent')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Agent Operators')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_15', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Name] desc',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 	

/***********************************************************************************************************************************
--	Logins - HEADER
***********************************************************************************************************************************/
  	IF ( OBJECT_ID('tempdb..##Email_HTML_16') IS NOT NULL )
		DROP TABLE ##Email_HTML_16
   	    
	select	name [Name], 
			CONVERT(VARCHAR(20),createdate,120) AS [Create Date], 
			CONVERT(VARCHAR(20),updatedate,120) AS [Update Date], 
			dbname [Database], 
			case when sysadmin = 0 then 'NÃO' else 'SIM' end AS [Sysadmin]
	INTO ##Email_HTML_16
	from sys.syslogins
	
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Informações dos Logins')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Logins Information')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_16', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Name] desc',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 	


/***********************************************************************************************************************************
--	Linked Servers - HEADER
***********************************************************************************************************************************/
	IF ( OBJECT_ID('tempdb..##Email_HTML_17') IS NOT NULL )
		DROP TABLE ##Email_HTML_17   
	

	select srvname [Server Name], srvproduct [Server Product], providername [Provider], ISNULL(datasource,'') AS [Data Source]
	INTO ##Email_HTML_17
	from sys.sysservers
	where srvname <> @@SERVERNAME			  
	
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Informações Linked Server')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Linked Server Information')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_17', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Server Name]',

		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 	

/***********************************************************************************************************************************
--	ALERTA - CONEXÕES - HEADER
***********************************************************************************************************************************/
	        
	IF ( OBJECT_ID('tempdb..##Email_HTML_18') IS NOT NULL )
		DROP TABLE ##Email_HTML_18

	SELECT	top 10 
			replace(replace(ec.client_net_address,'<',''),'>','') [Client Net Address], 
			case when es.[program_name] = '' then 'Sem nome na string de conexão' else [program_name] end [Program Name], 
			es.[host_name] [Host Name],
			es.login_name [Login Name],
			CAST(COUNT(ec.session_id) AS VARCHAR) AS [Connection Count] 
	INTO ##Email_HTML_18
	FROM sys.dm_exec_sessions AS es  
	INNER JOIN sys.dm_exec_connections AS ec  
	ON es.session_id = ec.session_id   
	GROUP BY ec.client_net_address, es.[program_name], es.[host_name], es.login_name  			
	order by [Connection Count]  desc
							
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Conexões abertas no SQL Server')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','SQL Server Open Connections')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_18', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Connection Count]  desc',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 	

					
/***********************************************************************************************************************************
--	Backup Information
***********************************************************************************************************************************/
					
	IF ( OBJECT_ID('tempdb..##Email_HTML_19') IS NOT NULL )
		DROP TABLE ##Email_HTML_19
	
	SELECT	db.[name] AS [Database],
			ISNULL((
			SELECT	TOP 1
					CASE type WHEN 'D' THEN 'Full' WHEN 'I' THEN 'Differential' WHEN 'L' THEN 'Transaction log' END + '  ' +
					LTRIM(ISNULL(STR(ABS(DATEDIFF(DAY, GETDATE(),backup_finish_date))) + ' days ago', 'NEVER')) + '  ' +
					CONVERT(VARCHAR(20), backup_start_date, 103) + ' ' + CONVERT(VARCHAR(20), backup_start_date, 108) + 
					'  Duration: ' + CAST(DATEDIFF(second, BK.backup_start_date, BK.backup_finish_date) AS VARCHAR(4)) + ' second(s)'
			FROM msdb..backupset BK WHERE BK.database_name = DB_NAME([database_id]) ORDER BY backup_set_id DESC),'No Backup Records') AS [Last backup]
	INTO ##Email_HTML_19
	FROM sys.databases AS db 
	ORDER BY db.[name]
								
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Informações de Backup')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Backup Information')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_19', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Database]',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
				
/***********************************************************************************************************************************
--	Send the Email
***********************************************************************************************************************************/
	
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Ds_Subject =  @Ds_Message_Alert_PTB+@@SERVERNAME 
	END
    ELSE 
	BEGIN
		SET @Ds_Subject =  @Ds_Message_Alert_ENG+@@SERVERNAME 
	END		   		
				
	-- Second Result
	SET @Final_HTML = @Final_HTML + @Line_Space + @Company_Link			

	EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'							
								
END
GO

/***********************************************************************************************************************************
(C) 2016, Fabricio Lima Soluções em Banco de Dados

Site: http://www.fabriciolima.net/

Feedback: fabricioflima@gmail.com
***********************************************************************************************************************************/

IF ( OBJECT_ID('[dbo].[stpAlert_Severity]') IS NOT NULL )
	DROP PROCEDURE [dbo].stpAlert_Severity
GO

CREATE PROCEDURE stpAlert_Severity
AS
BEGIN
	--------------------------------------------------------------------------------------------------------------------------------
	--	Severity 021 - Fatal Error in Database Processes
	--------------------------------------------------------------------------------------------------------------------------------
	IF EXISTS ( SELECT * FROM [msdb].[dbo].[sysalerts] WHERE name = 'Severity 021' )
	BEGIN
		EXEC [msdb].[dbo].[sp_delete_alert]  @name = N'Severity 021'
	END
	
	EXEC [msdb].[dbo].[sp_add_alert] 
			@name = N'Severity 021', 
			@message_id = 0,
			@severity = 21, 
			@enabled = 1, 
			@delay_between_responses = 60,
			@include_event_description_in = 1

	EXEC [msdb].[dbo].[sp_add_notification]
			@alert_name = N'Severity 021',
			@operator_name = N'DBA_Operator', 
			@notification_method = 7
    

	--------------------------------------------------------------------------------------------------------------------------------
	--	Severity 022 - Fatal Error: Table INTegrity Suspect
	--------------------------------------------------------------------------------------------------------------------------------
	IF EXISTS ( SELECT * FROM [msdb].[dbo].[sysalerts] WHERE name = 'Severity 022' )
	BEGIN
		EXEC [msdb].[dbo].[sp_delete_alert]  @name = N'Severity 022'
	END
	
	EXEC [msdb].[dbo].[sp_add_alert] 
			@name = N'Severity 022', 
			@message_id = 0,
			@severity = 22, 
			@enabled = 1, 
			@delay_between_responses = 60,
			@include_event_description_in = 1


	EXEC [msdb].[dbo].[sp_add_notification] 
			@alert_name = N'Severity 022',
			@operator_name = N'DBA_Operator', 
			@notification_method = 7  


	--------------------------------------------------------------------------------------------------------------------------------
	--	Severity 023 - Fatal Error: Database INTegrity Suspect
	--------------------------------------------------------------------------------------------------------------------------------
	IF EXISTS ( SELECT * FROM [msdb].[dbo].[sysalerts] WHERE name = 'Severity 023' )
	BEGIN
		EXEC [msdb].[dbo].[sp_delete_alert]  @name = N'Severity 023'
	END
	
	EXEC [msdb].[dbo].[sp_add_alert] 
			@name = N'Severity 023', 
			@message_id = 0,
			@severity = 23, 
			@enabled = 1, 
			@delay_between_responses = 60,
			@include_event_description_in = 1
    
	EXEC [msdb].[dbo].[sp_add_notification] 
			@alert_name = N'Severity 023',
			@operator_name = N'DBA_Operator', 
			@notification_method = 7
    
	--------------------------------------------------------------------------------------------------------------------------------
	--	Severity 024 - Fatal Error: Hardware Error
	--------------------------------------------------------------------------------------------------------------------------------
	IF EXISTS ( SELECT * FROM [msdb].[dbo].[sysalerts] WHERE name = 'Severity 024' )
	BEGIN
		EXEC [msdb].[dbo].[sp_delete_alert]  @name = N'Severity 024'
	END
	
	EXEC [msdb].[dbo].[sp_add_alert] 
			@name = N'Severity 024', 
			@message_id = 0,
			@severity = 24, 
			@enabled = 1, 
			@delay_between_responses = 60,
			@include_event_description_in = 1
    


	EXEC [msdb].[dbo].[sp_add_notification] 
			@alert_name = N'Severity 024',
			@operator_name = N'DBA_Operator', 
			@notification_method = 7
    
	
	--------------------------------------------------------------------------------------------------------------------------------
	--	Severity 025 - Fatal Error
	--------------------------------------------------------------------------------------------------------------------------------
	IF EXISTS ( SELECT * FROM [msdb].[dbo].[sysalerts] WHERE name = 'Severity 025' )
	BEGIN
		EXEC [msdb].[dbo].[sp_delete_alert]  @name = N'Severity 025'
	END
	
	EXEC [msdb].[dbo].[sp_add_alert] 
			@name = N'Severity 025', 
			@message_id = 0,
			@severity = 25, 
			@enabled = 1, 
			@delay_between_responses = 60,
			@include_event_description_in = 1
    


	EXEC [msdb].[dbo].[sp_add_notification] 
			@alert_name = N'Severity 025',
			@operator_name = N'DBA_Operator', 
			@notification_method = 7
    



	/*******************************************************************************************************************************
	--	ALERTAS DE PAGINAS CORROMPIDAS
	*******************************************************************************************************************************/

	--------------------------------------------------------------------------------------------------------------------------------
	--	Error Number 823
	--------------------------------------------------------------------------------------------------------------------------------
	IF EXISTS ( SELECT * FROM [msdb].[dbo].[sysalerts] WHERE name = 'Error Number 823' )
	BEGIN
		EXEC [msdb].[dbo].[sp_delete_alert]   @name = N'Error Number 823'
	END
   
	EXEC [msdb].[dbo].[sp_add_alert] 
			@name = N'Error Number 823',
			@message_id = 823,
			@severity = 0,
			@enabled = 1,
			@delay_between_responses = 60,
			@include_event_description_in = 1
		


	EXEC [msdb].[dbo].[sp_add_notification] 
			@alert_name = N'Error Number 823', 
			@operator_name = N'DBA_Operator', 
			@notification_method = 7;



	--------------------------------------------------------------------------------------------------------------------------------
	--	Error Number 824
	--------------------------------------------------------------------------------------------------------------------------------
	IF EXISTS ( SELECT * FROM [msdb].[dbo].[sysalerts] WHERE name = 'Error Number 824' )
	BEGIN
		EXEC [msdb].[dbo].[sp_delete_alert]   @name = N'Error Number 824'
	END
	
	EXEC [msdb].[dbo].[sp_add_alert] 
			@name = N'Error Number 824',
			@message_id = 824,
			@severity = 0,
			@enabled = 1,
			@delay_between_responses = 60,
			@include_event_description_in = 1
 


	EXEC [msdb].[dbo].[sp_add_notification] 
			@alert_name = N'Error Number 824',
			@operator_name = N'DBA_Operator', 
			@notification_method = 7;



	--------------------------------------------------------------------------------------------------------------------------------
	--	Error Number 825
	--------------------------------------------------------------------------------------------------------------------------------
	IF EXISTS ( SELECT * FROM [msdb].[dbo].[sysalerts] WHERE name = 'Error Number 825' )
	BEGIN
		EXEC [msdb].[dbo].[sp_delete_alert]   @name = N'Error Number 825'
	END
	
	EXEC [msdb].[dbo].[sp_add_alert] 
			@name = N'Error Number 825',
			@message_id = 825,
			@severity = 0,
			@enabled = 1,
			@delay_between_responses = 60,
			@include_event_description_in = 1
		

	EXEC [msdb].[dbo].[sp_add_notification] 
			@alert_name = N'Error Number 825', 
			@operator_name = N'DBA_Operator', 
			@notification_method = 7;

END

GO

GO
IF ( OBJECT_ID('[dbo].stpAlert_Slow_Queries') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_Slow_Queries
GO

CREATE PROCEDURE [dbo].stpAlert_Slow_Queries
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
	WHERE Nm_Alert = 'Slow Queries'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
	IF ( OBJECT_ID('tempdb..#Slow_Queries') IS NOT NULL )
		DROP TABLE #Slow_Queries

	SELECT	[StartTime], 
			[DataBaseName], 
			[Duration],
			[Reads],
			[Writes],
			[CPU],
			[TextData]
	INTO #Slow_Queries
	FROM [dbo].[Queries_Profile]
	WHERE [StartTime] >= DATEADD(mi,@Vl_Parameter_2*-1, GETDATE()) -- Like the Trace Job
	ORDER BY [Duration] DESC

	DECLARE @Qt_Slow_Queries INT = ( SELECT COUNT(*) FROM #Slow_Queries ) 

	-- Do we have Slow Queries?
	IF (@Qt_Slow_Queries > @Vl_Parameter)
	BEGIN
			exec [dbo].[stpWhoIsActive_Result]
			
			IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
				DROP TABLE ##Email_HTML
			
			SELECT TOP 50 *
			INTO ##Email_HTML
			FROM ##WhoIsActive_Result
															
			
			IF ( OBJECT_ID('tempdb..##Email_HTML_2') IS NOT NULL )
				DROP TABLE 	##Email_HTML_2
			
			SELECT	TOP 50
					CONVERT(VARCHAR(20), [StartTime], 120)	AS [Start Time], 
					[DataBaseName], 
					CAST([Duration] AS VARCHAR)				AS [Duration],
					CAST([Reads] AS VARCHAR)				AS [Reads],
					CAST([Writes] AS VARCHAR)				AS [Writes],
					CAST([CPU] AS VARCHAR)					AS [CPU],
					SUBSTRING([TextData], 1, 150)			AS [Text Data]
			INTO ##Email_HTML_2
			FROM #Slow_Queries
			 				 

			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  REPLACE(REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter),'###2',@Vl_Parameter_2)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter),'###2',@Vl_Parameter_2)+@@SERVERNAME 
		   END		   		

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[dd hh:mm:ss.mss] desc',
				@Ds_Saida = @HTML OUT				-- varchar(max)

			-- First Result
			SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space 		
				
			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_2', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = 'Duration DESC',
				@Ds_Saida = @HTML OUT				-- varchar(max)			

			IF @Fl_Language = 1
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_PTB)
			ELSE 
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_ENG)				

			-- Second Result
			SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space + @Company_Link			

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'								
		
			-- Fl_Type = 1 : ALERT	
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 1	

	END
END


GO
IF ( OBJECT_ID('[dbo].[stpAlert_CheckDB]') IS NOT NULL )
	DROP PROCEDURE [dbo].stpAlert_CheckDB
GO
CREATE PROCEDURE [dbo].stpAlert_CheckDB 
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
	WHERE Nm_Alert = 'Database Corruption'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
	IF OBJECT_ID('#Result_Corruption') IS NOT NULL
		DROP TABLE #Result_Corruption
		
	SELECT	LogDate,
			SUBSTRING(Text, 15, CHARINDEX(')', Text, 15) - 15) AS Nm_Database,
			SUBSTRING(Text,charindex('found',Text),(charindex('Elapsed time',Text)-charindex('found',Text))) AS Error,   
			Text 
	INTO #Result_Corruption
	FROM ##Error_Log_Result
	WHERE LogDate >= GETDATE() - 1	 
		and Text like '%DBCC CHECKDB (%'
		and Text not like '%IDR%'
		and substring(Text,charindex('found',Text), charindex('Elapsed time',Text) - charindex('found',Text)) <> 'found 0 errors and repaired 0 errors.'
		
	--	Do we have corruption problem?
	IF EXISTS	(SELECT TOP 1 LogDate FROM #Result_Corruption)
	BEGIN	-- BEGIN - ALERT
	
		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
			DROP TABLE ##Email_HTML		

		SELECT	CONVERT(VARCHAR(20), [LogDate], 120) AS [Log Date],
			Nm_Database [Database],
			[Error],
			[Text]
		INTO ##Email_HTML
		FROM #Result_Corruption									
										
				 
		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter
			
		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				SET @Ds_Subject =  @Ds_Message_Alert_PTB + @@SERVERNAME 
		END
        ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
			SET @Ds_Subject =  @Ds_Message_Alert_ENG + @@SERVERNAME 
		END		   		

		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Log Date]',
			@Ds_Saida = @HTML OUT				-- varchar(max)

	
		-- First Result
		SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space + @Company_Link	

		EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'								
		

		-- Fl_Type = 1 : ALERT	
		INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
		SELECT @Id_Alert_Parameter, @Ds_Subject, 1			
		
	END		-- END - ALERT
	
END

GO


IF ( OBJECT_ID('[dbo].stpAlert_Database_Errors') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_Database_Errors
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].stpAlert_Database_Errors
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
	WHERE Nm_Alert = 'Database Errors'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		

	DECLARE @Dt_ref DATE, @Quantity_Errors INT
	SET @Dt_ref = DATEADD(hh,-1*@Vl_Parameter_2,GETDATE()) 
	
	IF ( OBJECT_ID('tempdb..#TOP50_DB_Error') IS NOT NULL ) 
		DROP TABLE #TOP50_DB_Error

	CREATE TABLE #TOP50_DB_Error(
		[Nm_Database]	VARCHAR (MAX),
		[Error]		VARCHAR(MAX),
		[HostName]        VARCHAR(MAX),
		[Quantity]			INT,
		[Sequence]			INT
	)

	
	IF ( OBJECT_ID('tempdb..#Erros_BD') IS NOT NULL ) 
		DROP TABLE #Erros_BD
	
	select  B.name AS Nm_Database,
	   A.client_hostname AS HostName,
			case 
				when err_message like '%deadlocked%'
					then 'Deadlock'
				else
					 err_message
			end AS Error,
			count(*) AS Quantity
	INTO #Erros_BD
	from Log_DB_Error A 
	join sys.databases B on A.database_id = B.database_id 
	where err_timestamp >= @Dt_ref and err_timestamp < dateadd(day,1,@Dt_ref)
	group by	case 
					when err_message like '%deadlocked%'
						then 'Deadlock'
					else
						 err_message
				end	, B.name,A.client_hostname
	order by Quantity desc

	Select @Quantity_Errors = SUM(Quantity) FROM #Erros_BD
	
	-- Do we have error problems?
	IF ( @Quantity_Errors >= @Vl_Parameter )
	BEGIN
	
		 INSERT INTO #TOP50_DB_Error (Nm_Database,[HostName], Error, Quantity, Sequence)
		SELECT TOP 50 [Nm_Database],ISNULL([HostName],'-') AS [HostName],  [Error], [Quantity], 1 as [Sequence]
		FROM #Erros_BD
		ORDER BY [Sequence], [Quantity] DESC

		DELETE TOP (50)	FROM #Erros_BD 	
		
		IF (@@ROWCOUNT <> 0)
		BEGIN
			 INSERT INTO #TOP50_DB_Error (Nm_Database,[HostName], Error, Quantity, Sequence)
			SELECT 'OTHERS' AS [Nm_Database],'-' AS [HostName] , '-' AS [Error], SUM([Quantity]) AS [Quantity], 2 as [Sequence]
			FROM #Erros_BD
			ORDER BY [Sequence], [Quantity] DESC
			
			INSERT INTO #TOP50_DB_Error (Nm_Database,[HostName],Error,Quantity,Sequence)
			SELECT 'TOTAL', '-','-',@Quantity_Errors, 3 AS Sequence
		END
		
		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
			DROP TABLE ##Email_HTML
			
		SELECT	[Sequence],[Nm_Database] [Database], [HostName],
			[Error],
			[Quantity] as [Total Error]
		INTO ##Email_HTML
		FROM #TOP50_DB_Error
								
		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter
			
			
		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Quantity_Errors)+@@SERVERNAME 
		END
        ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
			SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Quantity_Errors)+@@SERVERNAME 
		END		   		

		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Sequence],[Total Error] desc',
			@Ds_Saida = @HTML OUT				-- varchar(max)

		-- First Result
		SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space 		
					
			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'								
		
		-- Fl_Type = 1 : ALERT	
		INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
		SELECT @Id_Alert_Parameter, @Ds_Subject, 1			

	END
END

GO
IF ( OBJECT_ID('[dbo].[stpAlert_Every_Minute]') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_Every_Minute
GO



CREATE PROCEDURE dbo.stpAlert_Every_Minute
AS
BEGIN

	--Alerts
	EXEC dbo.stpWhoIsActive_Result

	-- Just on the business time
	IF ( DATEPART(HOUR, GETDATE()) >= 6 AND DATEPART(HOUR, GETDATE()) < 23 )
	BEGIN
		EXEC dbo.stpAlert_Blocked_Process 'Blocked Process'

		EXEC dbo.stpAlert_Blocked_Process 'Blocked Long Process'

		EXEC dbo.stpAlert_CPU_Utilization

	END

	EXEC dbo.stpAlert_CPU_Utilization_MI

	EXEC dbo.stpAlert_Database_Status

	EXEC dbo.stpAlert_IO_Pending 

	EXEC dbo.stpAlert_Large_LDF_File

	EXEC dbo.stpAlert_Log_Full

	EXEC dbo.stpAlert_Memory_Available

	EXEC dbo.stpAlert_Page_Corruption
	

	-- Executado a cada 20 minutos
	IF ( DATEPART(mi, GETDATE()) %20 = 0 )
	BEGIN
		EXEC dbo.stpAlert_SQLServer_Restarted
	END
	
	-- Every Five minute
	IF  DATEPART(MINUTE,GETDATE()) % 5 = 0 
	BEGIN
		EXEC dbo.stpAlert_Disk_Space
		EXEC dbo.stpAlert_Tempdb_MDF_File_Utilization
	END

	IF  DATEPART(MINUTE,GETDATE()) = 58 -- Every hour
	BEGIN 
		EXEC dbo.stpRead_Error_log 1 -- Just if Error Log size < 5 MB (VL_Parameter_2). 
		EXEC dbo.stpAlert_Slow_Disk 'Slow Disk Every Hour' --Disable by default. Do a update on the table Alert_Parameter
		EXEC dbo.stpAlert_SQLServer_Connection
		EXEC dbo.stpAlert_Database_Without_Log_Backup
		EXEC stpAlert_MaxSize_Growth
	END

	--IF CONVERT(char(20), SERVERPROPERTY('IsClustered')) = 1	
	--BEGIN	
	--	EXEC stpAlert_Cluster_Active_Node
	--	EXEC stpAlert_Cluster_Node_Status
	--END

END
GO
GO
IF ( OBJECT_ID('[dbo].[stpAlert_Every_Day]') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpAlert_Every_Day
GO

CREATE PROCEDURE dbo.stpAlert_Every_Day
AS
BEGIN
	--Alertas Diarios 
	EXEC dbo.stpWhoIsActive_Result

	EXEC dbo.stpAlert_Long_Runnning_Process
	
	EXEC dbo.stpRead_Error_log 0
		
	EXEC dbo.stpAlert_Slow_Disk 'Slow Disk' 

	EXEC dbo.stpAlert_Database_Created

	EXEC dbo.stpAlert_Database_Without_Backup

	EXEC dbo.stpAlert_Job_Disabled

	EXEC dbo.stpAlert_Job_Failed

	EXEC dbo.stpAlert_Login_Failed
	
	EXEC dbo.stpAlert_Slow_File_Growth

	EXEC dbo.stpAlert_Without_Clear

	---- Put after the Rebuild Job
	--EXEC dbo.stpAlert_Rebuild_Failed

	--Enable if use deadlock
	--EXEC dbo.stpAlert_DeadLocks
	
	EXEC stpAlert_Database_Growth

	-- Once a month
	IF DATEPART(dd,GETDATE()) = 1
		EXEC dbo.stpSQLServer_Configuration
			
	IF EXISTS (SELECT * FROM Alert_Parameter WHERE Nm_Alert = 'Database Errors' AND Fl_Enable = 1)
		EXEC dbo.stpAlert_Database_Errors

		--Every Monday
	IF DATEPART(dw,GETDATE()) = 2
		EXEC dbo.stpAlert_Index_Fragmentation

END
	
GO
IF ( OBJECT_ID('[dbo].[stpTest_Alerts]') IS NOT NULL ) 
	DROP PROCEDURE [dbo].stpTest_Alerts
GO

CREATE PROCEDURE stpTest_Alerts
AS
BEGIN
	EXEC stpWhoIsActive_Result

	--SELECT * FROM ##WhoIsActive_Result
	--------------------------------
	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = -1
	WHERE Nm_Alert = 'Database Without Log BACKUP'

	EXEC stpAlert_Database_Without_Log_Backup

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 2
	WHERE Nm_Alert = 'Database Without Log BACKUP'

	EXEC stpAlert_Database_Without_Log_Backup

	--------------------------------

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 0
	WHERE Nm_Alert =  'SQL Server Connection'

	EXEC stpAlert_SQLServer_Connection

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 5000
	WHERE Nm_Alert =  'SQL Server Connection'

	EXEC stpAlert_SQLServer_Connection


	--------------------------------
	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 0
	WHERE Nm_Alert = 'Long Running Process'

	EXEC stpAlert_Long_Runnning_Process

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 2
	WHERE Nm_Alert = 'Long Running Process'

	--------------------------------

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 0,Vl_Parameter_2 = 0
	WHERE Nm_Alert = 'Tempdb MDF File Utilization'

	EXEC stpAlert_Tempdb_MDF_File_Utilization

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 70,Vl_Parameter_2 = 10000
	WHERE Nm_Alert = 'Tempdb MDF File Utilization'

	EXEC stpAlert_Tempdb_MDF_File_Utilization

	----------------
	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 0
	WHERE Nm_Alert = 'CPU Utilization'

	EXEC [stpAlert_CPU_Utilization]

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 85
	WHERE Nm_Alert = 'CPU Utilization'

	EXEC [stpAlert_CPU_Utilization]

	------------------------------

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 100
	WHERE Nm_Alert = 'Memory Available'

	EXEC stpAlert_Memory_Available

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 2
	WHERE Nm_Alert = 'Memory Available'

	EXEC stpAlert_Memory_Available

	----------------------

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter_2 = 0
	WHERE Nm_Alert = 'Large LDF File'

	EXEC stpAlert_Large_LDF_File

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter_2 = 10
	WHERE Nm_Alert = 'Large LDF File'

	EXEC stpAlert_Large_LDF_File

	-------------------------------

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 32000
	WHERE Nm_Alert = 'SQL Server Restarted'

	EXEC stpAlert_SQLServer_Restarted

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 20
	WHERE Nm_Alert = 'SQL Server Restarted'

	------------------
	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 5000
	WHERE Nm_Alert = 'Database Created'

	EXEC stpAlert_Database_Without_Backup

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 24
	WHERE Nm_Alert = 'Database Created'

	-----------------

	EXEC stpAlert_Page_Corruption



	----------
	EXEC stpRead_Error_log @Actual_Log = 1
	EXEC stpAlert_Slow_Disk @Nm_Alert = 'Slow Disk'

	------
	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 0
	WHERE Nm_Alert =  'Login Failed'

	EXEC stpAlert_Login_Failed

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 50
	WHERE Nm_Alert =  'Login Failed'

	---------
	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 2000
	WHERE Nm_Alert =  'Job Failed'

	EXEC stpAlert_Job_Failed

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 24
	WHERE Nm_Alert =  'Job Failed'

	-------------------
	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 0
	WHERE Nm_Alert =  'SQL Server Connection'

	EXEC stpAlert_SQLServer_Connection

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 5000
	WHERE Nm_Alert =  'SQL Server Connection'

	EXEC stpAlert_SQLServer_Connection

	-------------

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 0,Vl_Parameter_2 = 5000
	WHERE Nm_Alert = 'Slow File Growth'

	EXEC stpAlert_Slow_File_Growth

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 1, Vl_Parameter_2 = 24
	WHERE Nm_Alert = 'Slow File Growth'

	EXEC stpAlert_Slow_File_Growth

--------------------------
	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 0, Vl_Parameter_2=0
	WHERE Nm_Alert = 'Log Full'

	EXEC [stpAlert_Log_Full]


	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 85, Vl_Parameter_2=10000000
	WHERE Nm_Alert = 'Log Full'

	EXEC [stpAlert_Log_Full]


	--------------
	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 0
	WHERE Nm_Alert = 'Disk Space'

	EXEC stpAlert_Disk_Space

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 80
	WHERE Nm_Alert = 'Disk Space'

	EXEC stpAlert_Disk_Space

	---------------
	EXEC dbo.stpSend_Mail_Executing_Process

	--------------
	EXEC stpAlert_Without_Clear

	--------------

	EXEC stpSQLServer_Configuration

END


	GO
USE [msdb]

GO
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Alert DB - Every Minute')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Alert DB - Every Minute', @delete_unused_schedule=1
GO
GO

BEGIN TRANSACTION
	DECLARE @ReturnCode INT
	SELECT @ReturnCode = 0
	
	IF NOT EXISTS (SELECT [name] FROM [msdb].[dbo].[syscategories] WHERE [name] = N'Database Maintenance' AND [category_class] = 1)
	BEGIN
		EXEC @ReturnCode = [msdb].[dbo].[sp_add_category] @class = N'JOB', @type = N'LOCAL', @name = N'Database Maintenance'
		
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	END

	DECLARE @jobId BINARY(16)
	EXEC @ReturnCode = [msdb].[dbo].[sp_add_job] 
			@job_name = N'DBA - Alert DB - Every Minute', 
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
	
	------------------------------------------------------------------------------------------------------------------------------------	
	-- Cria o Step 1 do JOB - DBA - Alertas Banco de Dados
	------------------------------------------------------------------------------------------------------------------------------------
	EXEC @ReturnCode = [msdb].[dbo].[sp_add_jobstep] 
			@job_id = @jobId,
			@step_name = N'DBA - Alert Databases',
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
			@command = N'exec dbo.stpAlert_Every_Minute', 
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
			@name = N'DBA - Alertas Banco de Dados', 
			@enabled = 1, 
			@freq_type = 4, 
			@freq_interval = 1, 
			@freq_subday_type = 4, 
			@freq_subday_interval = 1, 
			@freq_relative_interval = 0, 
			@freq_recurrence_factor = 0, 
			@active_start_date = @Dt_Atual, 
			@active_end_date = 99991231, 
			@active_start_time = 30, 
			@active_end_time = 235959
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = [msdb].[dbo].[sp_add_jobserver] @job_id = @jobId, @server_name = N'(local)'
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
COMMIT TRANSACTION

GOTO EndSave

QuitWithRollback:
	IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
	
EndSave:

GO


USE [msdb]

GO
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Alert DB - Every Day')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Alert DB - Every Day', @delete_unused_schedule=1
GO
GO

BEGIN TRANSACTION
	DECLARE @ReturnCode INT
	SELECT @ReturnCode = 0
	
	IF NOT EXISTS (SELECT [name] FROM [msdb].[dbo].[syscategories] WHERE [name] = N'Database Maintenance' AND [category_class] = 1)
	BEGIN
		EXEC @ReturnCode = [msdb].[dbo].[sp_add_category] @class = N'JOB', @type = N'LOCAL', @name = N'Database Maintenance'
		
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	END

	DECLARE @jobId BINARY(16)
	EXEC @ReturnCode = [msdb].[dbo].[sp_add_job] 
			@job_name = N'DBA - Alert DB - Every Day', 
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
	
	EXEC @ReturnCode = [msdb].[dbo].[sp_add_jobstep] 
			@job_id = @jobId,
			@step_name = N'DBA - Alert DB',
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
			@command = N'exec dbo.stpAlert_Every_Day', 
			@database_name = N'Traces', 
			@flags = 0
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = [msdb].[dbo].[sp_update_job] @job_id = @jobId, @start_step_id = 1
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	DECLARE @Dt_Atual VARCHAR(8) = CONVERT(VARCHAR(8), GETDATE(), 112)
		
	EXEC @ReturnCode = [msdb].[dbo].[sp_add_jobschedule] 
			@job_id = @jobId, 
			@name = N'DBA - Alert DB - Every Day', 
		@enabled=1, 
			@freq_type=4, 
			@freq_interval=1, 
			@freq_subday_type=1, 
			@freq_subday_interval=0, 
			@freq_relative_interval=0, 
			@freq_recurrence_factor=0, 
			@active_start_date=20160716, 
			@active_end_date=99991231, 
			@active_start_time=65000, 
			@active_end_time=235959
				
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = [msdb].[dbo].[sp_add_jobserver] @job_id = @jobId, @server_name = N'(local)'
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
COMMIT TRANSACTION

GOTO EndSave

QuitWithRollback:
	IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
	
EndSave:

GO
USE [msdb]

GO
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA - Send Mail Whoisactive')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA - Send Mail Whoisactive', @delete_unused_schedule=1
GO


BEGIN TRANSACTION
	DECLARE @ReturnCode INT
	SELECT @ReturnCode = 0
	
	IF NOT EXISTS (SELECT [name] FROM [msdb].[dbo].[syscategories] WHERE [name] = N'Database Maintenance' AND [category_class] = 1)
	BEGIN
		EXEC @ReturnCode = [msdb].[dbo].[sp_add_category] @class = N'JOB', @type = N'LOCAL', @name = N'Database Maintenance'
		
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	END

	DECLARE @jobId BINARY(16)
	EXEC @ReturnCode = [msdb].[dbo].[sp_add_job]
			@job_name = N'DBA - Send Mail Whoisactive',
			@enabled = 1,
			@notify_level_eventlog = 0,
			@notify_level_email = 2,
			@notify_level_netsend = 0,
			@notify_level_page = 0,
			@delete_level = 0,
			@description = N'No description available.',
			@category_name = N'Database Maintenance',
			@owner_login_name = N'sa',
			@notify_email_operator_name = N'DBA_Operator', 
			@job_id = @jobId OUTPUT
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		
	EXEC @ReturnCode = [msdb].[dbo].[sp_add_jobstep] 
			@job_id = @jobId,
			@step_name = N'Send mail Whoisactive',
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
			@command = N'exec stpWhoIsActive_Result
						exec [stpSend_Mail_Executing_Process]',
			@database_name = N'Traces',
			@flags = 0
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = [msdb].[dbo].[sp_update_job] @job_id = @jobId, @start_step_id = 1
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
	EXEC @ReturnCode = [msdb].[dbo].[sp_add_jobserver] @job_id = @jobId, @server_name = N'(local)'
	
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	
COMMIT TRANSACTION

GOTO EndSave

QuitWithRollback:
	IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
	
EndSave:

GO

USE Traces