-- Description:	List all users with transactions within date range and type 
CREATE PROCEDURE [dbo].[SSRS_Transactions_TypeUser] 

	 @StartDate datetime
	,@EndDate datetime
	,@TransactionType varchar(max)

AS

-- exec SSRS_Transactions_TypeUser '2022-01-01', '2022-06-06','PICK'  

BEGIN

	SET NOCOUNT ON;

	SELECT @EndDate = DATEADD(d,1,@EndDate)  

	SELECT UPPER([Name]) [Name],ID
	FROM [$(GraniteDatabase)].dbo.Users with (nolock)
	WHERE [Name] <> 'INTEGRATION' 
	 AND ID IN (SELECT DISTINCT [User_id]
				FROM [$(GraniteDatabase)].dbo.[Transaction]
				WHERE [Date] BETWEEN @StartDate AND @EndDate
			      AND (   @TransactionType = '*' 
		               OR [Type] in (select Item from fn_SSRS_ParameterSplit(@TransactionType,',')))
			   )
	ORDER BY Users.[Name] 

END
GO


