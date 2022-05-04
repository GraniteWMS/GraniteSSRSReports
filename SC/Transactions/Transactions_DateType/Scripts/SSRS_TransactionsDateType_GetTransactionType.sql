CREATE PROCEDURE [dbo].[SSRS_TransactionsDateType_GetTransactionType] 
	@StartDate datetime,
	@EndDate datetime 
AS

-- exec SSRS_Transaction_GetTransactionType '2022/02/01', '2022/04/21' 

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT DISTINCT [Type]
	FROM [Transaction]
	WHERE [Date] BETWEEN @StartDate AND @EndDate 
	ORDER BY [Type] 

END
GO


