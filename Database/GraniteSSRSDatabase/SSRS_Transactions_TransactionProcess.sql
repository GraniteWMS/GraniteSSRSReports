USE [GraniteDatabase]
GO

/****** Object:  StoredProcedure [dbo].[SSRS_Transactions_TransactionProcess]    Script Date: 2022/06/24 06:29:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Alessandro Trevisan
-- Create date: 2022-06-13
-- Description:	List all transactions within date range, user list and type list 
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[SSRS_Transactions_TransactionProcess] 

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
	FROM [Transaction]
	WHERE [Date] BETWEEN @StartDate AND @EndDate
	  AND (   @UserID = '*' 
		   OR CONVERT(varchar,[User_id]) in (select Item from fn_SSRS_ParameterSplit(@UserID,',')))
	  AND (   @TransactionType = '*' 
	       OR [Transaction].[Type] in (select Item from fn_SSRS_ParameterSplit(@TransactionType,','))) 
	ORDER BY ISNULL(Process,[Type])

END
GO


