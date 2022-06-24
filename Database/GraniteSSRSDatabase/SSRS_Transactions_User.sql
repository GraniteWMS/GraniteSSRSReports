USE [GraniteDatabase]
GO

/****** Object:  StoredProcedure [dbo].[SSRS_Transactions_User]    Script Date: 2022/06/24 06:30:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Alessandro Trevisan
-- Create date: 2022-06-06
-- Description:	List all users with transactions within date range 
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[SSRS_Transactions_User] 

	 @StartDate datetime
	,@EndDate datetime

AS

-- exec SSRS_Transactions_User '2022-01-01', '2022-06-06' 

BEGIN

	SET NOCOUNT ON;

	SELECT @EndDate = DATEADD(d,1,@EndDate)  

	SELECT UPPER([Name]) [Name],ID
	FROM Users with (nolock)
	WHERE [Name] <> 'INTEGRATION' 
	 AND ID IN (SELECT DISTINCT [User_id]
				FROM [Transaction]
				WHERE [Date] BETWEEN @StartDate AND @EndDate
			   )
	ORDER BY Users.[Name] 

END
GO


