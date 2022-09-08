-- Description:	List summary all transactions by user within date range, user list 
-- =============================================
ALTER PROCEDURE [dbo].[SSRS_KPI_TransactionsSummaryPerUser] 

	 @StartDate datetime
	,@EndDate datetime
	,@UserID varchar(max)				--- if not used, pass '*' as default

AS

-- exec [SSRS_KPI_TransactionsSummaryPerUser] '2022-01-01', '2022-06-30', '0,CHARLES'

BEGIN

	SET NOCOUNT ON;

	SELECT @EndDate = DATEADD(d,1,@EndDate)  

	DECLARE @tempTransactionTypes TABLE ( Type varchar(50) ) 
	INSERT INTO @tempTransactionTypes 
	SELECT DISTINCT [Transaction].Type 
	FROM dbo.[Transaction] 
	INNER JOIN dbo.[Users] ON [Users].ID = [Transaction].[User_id] 
	WHERE (   @UserID = '*' 
		   OR CONVERT(varchar,[Name]) in (select Item from fn_SSRS_ParameterSplit(@UserID,',')))
	  AND (FORMAT([Transaction].[Date], 'yyyy.MM.dd HH:mm:ss t') BETWEEN FORMAT(@StartDate, 'yyyy.MM.dd HH:mm:ss t') AND FORMAT(@EndDate, 'yyyy.MM.dd HH:mm:ss t'))

	--select * from @tempTransactionTypes

	DECLARE @tempTransactions TABLE ( Type varchar(50)
									 ,Name varchar(50) 
									 --,Date datetime   
									 ,TransDate date 
									 ,ActionQty decimal(19,4) 
									 ,ScanCount int 
									 ,DocCount int )
	INSERT INTO @tempTransactions 
	SELECT [Transaction].Type 
		  ,UPPER([Users].Name)    
		  --,[Transaction].[Date] 
		  ,CONVERT(VARCHAR, [Transaction].Date, 101) 
		  ,SUM(ISNULL([Transaction].ActionQty,0)) 
		  ,COUNT(ISNULL([Transaction].ID,0)) 
		  ,COUNT(DISTINCT ISNULL([Transaction].Document_id,0)) 
	FROM dbo.[Transaction] 
	INNER JOIN dbo.[Users] ON [Users].ID = [Transaction].[User_id] 
	INNER JOIN @tempTransactionTypes TT on TT.Type = [Transaction].Type 
	WHERE (   @UserID = '*' 
		   OR CONVERT(varchar,[Name]) in (select Item from fn_SSRS_ParameterSplit(@UserID,',')))
	  AND (FORMAT([Transaction].[Date], 'yyyy.MM.dd HH:mm:ss t') BETWEEN FORMAT(@StartDate, 'yyyy.MM.dd HH:mm:ss t') AND FORMAT(@EndDate, 'yyyy.MM.dd HH:mm:ss t'))
	GROUP BY [Users].Name, [Transaction].Type, CONVERT(VARCHAR, [Transaction].Date, 101)
	ORDER BY [Users].Name, [Transaction].Type, CONVERT(VARCHAR, [Transaction].Date, 101)

	SELECT * FROM @tempTransactions

END