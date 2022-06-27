-- Description:	List all transactions within date range user and type and user list    
CREATE PROCEDURE [dbo].[SSRS_KPI_TransactionsPerUser] 

	 @StartDate datetime
	,@EndDate datetime
	,@UserID varchar(max)					--- if not used, pass '*' as default 
	,@TransactionType varchar(max)			--- if not used, pass '*' as default 

AS

-- exec SSRS_KPI_TransactionsPerUser '2022-01-01', '2022-06-06', '*', 'PICK' 

BEGIN

	SET NOCOUNT ON;

	SELECT @EndDate = DATEADD(d,1,@EndDate)  

	SELECT CONVERT(VARCHAR, [Transaction].Date, 101) AS Date
			, UPPER([Users].Name) AS Name 
			, SUM([Transaction].ActionQty) AS ActionQty
			, COUNT([Transaction].ID) AS ScanCount
			, COUNT(DISTINCT [Transaction].Document_id) AS DocCount
			, [Transaction].Type 
			, ISNULL([Transaction].Process, [Transaction].Type) AS Process
	FROM [$(GraniteDatabase)].dbo.[Transaction] 
	LEFT OUTER JOIN [$(GraniteDatabase)].dbo.[Users] ON [Transaction].[User_id] = [Users].ID 
	WHERE [Transaction].[Date] BETWEEN @StartDate AND @EndDate 
	  AND (   @UserID = '*' 
		   OR CONVERT(varchar,[User_id]) in (select Item from fn_SSRS_ParameterSplit(@UserID,',')))
	  AND (   @TransactionType = '*' 
		   OR [Type] in (select Item from fn_SSRS_ParameterSplit(@TransactionType,',')))
	GROUP BY CONVERT(VARCHAR, [Transaction].Date, 101), [Users].Name, [Transaction].Type, [Transaction].Process
	ORDER BY [Users].Name, CONVERT(VARCHAR, [Transaction].Date, 101), [Transaction].Type

END
GO