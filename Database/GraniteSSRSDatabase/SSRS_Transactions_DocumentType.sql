-- Description:	List all documents with Transactions within date range, user list, type list and process list 
CREATE PROCEDURE [dbo].[SSRS_Transactions_DocumentType] 
	 @StartDate datetime
	,@EndDate datetime
	,@UserID varchar(max)                   --- if not used, pass '*' as default 
	,@TransactionType varchar(max)          --- if not used, pass '*' as default
	,@TransactionProcess varchar(max)		--- if not used, pass '*' as default
AS

-- exec SSRS_Transactions_DocumentType '2022-01-01', '2022-06-06', '*', '*', '*' 

BEGIN

	SET NOCOUNT ON;

	SELECT @EndDate = DATEADD(d,1,@EndDate)  

	SELECT DISTINCT [Document].Type 
	FROM [$(GraniteDatabase)].dbo.[Transaction] 
	INNER JOIN [$(GraniteDatabase)].dbo.[Document] on [Transaction].Document_id = [Document].ID 
	WHERE ([Date] BETWEEN @StartDate AND @EndDate)
	  AND (   @UserID = '*' 
		   OR CONVERT(varchar,[User_id]) in (select Item from fn_SSRS_ParameterSplit(@UserID,',')))
	  AND (   @TransactionType = '*' 
		   OR [Transaction].[Type] in (select Item from fn_SSRS_ParameterSplit(@TransactionType,',')))
	  AND (   @TransactionProcess = '*' 
		   OR CASE WHEN ISNULL(Process,'') = '' 
				   THEN [Transaction].[Type] 
				   ELSE Process END in (select Item from fn_SSRS_ParameterSplit(@TransactionProcess,','))) 
	ORDER BY [$(GraniteDatabase)].dbo.[Document].[Type] 

END
GO