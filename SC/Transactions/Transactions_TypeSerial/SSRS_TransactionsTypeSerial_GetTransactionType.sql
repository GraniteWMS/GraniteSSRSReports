USE [GraniteDatabaseDE]
GO

/****** Object:  StoredProcedure [dbo].[SSRS_Transaction_GetTransactionType]    Script Date: 22/04/26 12:09:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[SSRS_TransactionsTypeSerial_GetTransactionType] 
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


