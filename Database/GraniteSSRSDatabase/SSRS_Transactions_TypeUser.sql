USE [GraniteDatabase]
GO

/****** Object:  StoredProcedure [dbo].[SSRS_Transactions_TypeUser]    Script Date: 2022/06/24 06:30:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Alessandro Trevisan
-- Create date: 2022-06-06
-- Description:	List all users with transactions within date range and type 
-- =============================================
CREATE OR ALTER   PROCEDURE [dbo].[SSRS_Transactions_TypeUser] 

	 @StartDate datetime
	,@EndDate datetime
	,@TransactionType varchar(max)

AS

-- exec SSRS_Transactions_TypeUser '2022-01-01', '2022-06-06','PICK'  

BEGIN

	SET NOCOUNT ON;

	SELECT @EndDate = DATEADD(d,1,@EndDate)  

	SELECT UPPER([Name]) [Name],ID
	FROM Users with (nolock)
	WHERE [Name] <> 'INTEGRATION' 
	 AND ID IN (SELECT DISTINCT [User_id]
				FROM [Transaction]
				WHERE [Date] BETWEEN @StartDate AND @EndDate
			      AND (   @TransactionType = '*' 
		               OR [Type] in (select Item from fn_SSRS_ParameterSplit(@TransactionType,',')))
			   )
	ORDER BY Users.[Name] 

END
GO


