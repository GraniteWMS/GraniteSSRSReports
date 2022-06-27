-- Description:	List all transaction types within date range and user list 
CREATE PROCEDURE [dbo].[SSRS_Transactions_TransactionType] 
	 @StartDate datetime
	,@EndDate datetime
	,@UserID varchar(max)				--- if not used, pass '*' as default
AS

-- exec SSRS_Transactions_TransactionType '2022-01-01', '2022-06-06', '*' 

BEGIN

	SET NOCOUNT ON;

	SELECT @EndDate = DATEADD(d,1,@EndDate)  

	SELECT DISTINCT [Type] 
	FROM [$(GraniteDatabase)].dbo.[Transaction]
	WHERE [Date] BETWEEN @StartDate AND @EndDate 
	  AND (   @UserID = '*' 
		   OR CONVERT(varchar,[User_id]) in (select Item from fn_SSRS_ParameterSplit(@UserID,',')))
	ORDER BY [Type]

END
GO