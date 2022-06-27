-- Description:	List all users with transactions within date range 
CREATE PROCEDURE [dbo].[SSRS_Transactions_User] 
	 @StartDate datetime
	,@EndDate datetime
AS
-- exec SSRS_Transactions_User '2022-01-01', '2022-06-06' 
BEGIN

	SET NOCOUNT ON;

	SELECT @EndDate = DATEADD(d,1,@EndDate)  

	SELECT UPPER([Name]) [Name],ID
	FROM [$(GraniteDatabase)].dbo.Users with (nolock)
	WHERE [Name] <> 'INTEGRATION' 
	 AND ID IN (SELECT DISTINCT [User_id]
				FROM [$(GraniteDatabase)].dbo.[Transaction]
				WHERE [Date] BETWEEN @StartDate AND @EndDate
			   )
	ORDER BY Users.[Name] 

END
GO