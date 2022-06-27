-- Description:	List all transactions within date range, user list and type list 
CREATE PROCEDURE [dbo].[SSRS_Transactions_TransactionProcess] 
	 @StartDate datetime
	,@EndDate datetime
	,@UserID varchar(max)				--- if not used, pass '*' as default
	,@TransactionType varchar(max)      --- if not used, pass '*' as default
AS

-- exec SSRS_Transactions_TransactionProcess '2021-10-20', '2022-06-20', '*', '*'  

BEGIN

	SET NOCOUNT ON;

	SELECT @EndDate = DATEADD(d,1,@EndDate)  

	SELECT DISTINCT ISNULL(Process,[Type]) AS Process 
	FROM [$(GraniteDatabase)].dbo.[Transaction]
	WHERE [Date] BETWEEN @StartDate AND @EndDate
	  AND (   @UserID = '*' 
		   OR CONVERT(varchar,[User_id]) in (select Item from fn_SSRS_ParameterSplit(@UserID,',')))
	  AND (   @TransactionType = '*' 
	       OR [Transaction].[Type] in (select Item from fn_SSRS_ParameterSplit(@TransactionType,','))) 
	ORDER BY ISNULL(Process,[Type])

END
GO