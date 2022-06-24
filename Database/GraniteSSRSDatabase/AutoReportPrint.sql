USE [GraniteDatabase]
GO

/****** Object:  StoredProcedure [dbo].[AutoReportPrint]    Script Date: 2022/06/24 10:00:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Nicole Trevisan 
-- Create date: 2022-06-13
-- Description:	Auto print SSRS report 
-- Dependancy:  SSRS must be installed & configured 
--              Report to print must be deployed to SSRS portal 
--              Printer must be installed on server and accessable 
-- =============================================
CREATE OR ALTER   PROCEDURE [dbo].[AutoReportPrint] 
	  @sPrinterName varchar(max)	-- printer must be installed on the server, use the windows printer name 
	, @sReportName varchar(max)		-- SSRS report name including folder, i.e. 
	                                --      '/Process Reports/Sage Invoice', NB!!!!! must have the "/" to start else wont find the report
	, @sPrintQty integer			-- 1 
	, @sLorP varchar(20)			-- 'Landscape' / 'Portrait' value only 
	, @sParm1Name varchar(50)		-- Must be the same as the report parameter1 name
	, @sParm1Value varchar(50)		-- value for parameter1 
AS
BEGIN

	SET NOCOUNT ON;

	--SET @sPrinterName = 'Sales Printer' 
	--SET @sReportName = '/Sales Invoice'		--'/Sales Invoice'		--'/Sales Delivery Note
	--SET @sPrintQty = 1						-- 1
	--SET @sLorP = 'Landscape' 
	--SET @sParm1Name = 'InvNumber'
	--SET @sParm1Value = 'INV0460692' 

	DECLARE @authHeader NVARCHAR(64);
	DECLARE @contentType NVARCHAR(64);
	DECLARE @postData NVARCHAR(2000);
	DECLARE @responseText NVARCHAR(2000);
	DECLARE @responseXML NVARCHAR(2000);
	DECLARE @ret INT;
	DECLARE @status NVARCHAR(32);
	DECLARE @statusText NVARCHAR(32);
	DECLARE @token INT;
	DECLARE @url NVARCHAR(256);
	DECLARE @body varchar(8000)

	SELECT @body = 'sPrinterName='+@sPrinterName+'&sReportName='+@sReportName+'&sPrintQty='+CONVERT(varchar,@sPrintQty)+'&sLorP='+@sLorP+'&sParm1Name='+@sParm1Name+'&sParm1Value='+@sParm1Value 

	SET @contentType = 'application/x-www-form-urlencoded';

	-- Set your desired url where you want to fire request
	SET @url = 'http://xxxxx:40095/PrintSSRSReport.asmx/Report_1Parm'

	-- Open a connection
	EXEC @ret = sp_OACreate 'MSXML2.ServerXMLHTTP', @token OUT;
	IF @ret <> 0 RAISERROR('Unable to open HTTP connection.', 10, 1);

	-- make a request
	EXEC @ret = sp_OAMethod @token, 'open', NULL, 'POST', @url, 'false';
	EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Content-type', @contentType;
	EXEC @ret = sp_OAMethod @token, 'send', null, @body

	-- Handle response
	EXEC @ret = sp_OAGetProperty @token, 'status', @status OUT;
	EXEC @ret = sp_OAGetProperty @token, 'statusText', @statusText OUT;
	EXEC @ret = sp_OAGetProperty @token, 'responseText', @responseText OUT;

	SELECT @status, @statusText, @responseText

	---- Close the connection.
	EXEC @ret = sp_OADestroy @token;
	IF @ret <> 0 RAISERROR('Unable to close HTTP connection.', 10, 1);
	
END
GO


