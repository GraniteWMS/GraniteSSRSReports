USE [CleanSlate]
GO

/****** Object:  StoredProcedure [dbo].[SSRS_Document_PickSlip_Route_Document]    Script Date: 2022/08/26 13:16:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Description:	List all outbound Documents for route, stop and ExpectedDate range  
-- =============================================
CREATE PROCEDURE [dbo].[SSRS_Document_PickSlip_Route_Document] 

	 @Route varchar(max)
    ,@Stop varchar(max)
	,@ExpectedDateFrom date
	,@ExpectedDateTo date

AS

-- exec SSRS_Document_PickSlip_Route_Document 'None', 'None', '2022-09-01', '2022-09-06'

BEGIN

	SET NOCOUNT ON;

	SELECT DISTINCT D.Number DocumentNumber, CONVERT(DATE, D.ExpectedDate), 
	       CONCAT(CONVERT(DATE, D.ExpectedDate), ' - ', D.Number, ' - ', D.TradingPartnerDescription) DocumentDescription
		   ,Route, Stop 
	FROM Document D
	INNER JOIN DocumentDetail DD on D.ID = DD.Document_id 
	INNER JOIN MasterItem MI on DD.Item_id = MI.ID 
	WHERE D.Type IN ('ORDER') --, 'TRANSFER') 
	  AND DD.Completed = 0 
	  AND DD.Cancelled = 0 
	  AND DD.Qty - DD.ActionQty > 0 
	  --AND ISNULL(D.[Route],'None') IN (select Item from fn_SSRS_ParameterSplit(@Route,','))
	  --AND ISNULL(D.[Stop],'None') IN (select Item from fn_SSRS_ParameterSplit(@Stop,','))
	  AND CASE WHEN ISNULL([Route],'') = '' OR TRIM([Route]) = '' THEN 'None' ELSE [Route] END IN (select Item from fn_SSRS_ParameterSplit(@Route,','))
	  AND CASE WHEN ISNULL([Stop],'') = '' OR TRIM([Stop]) = '' THEN 'None' ELSE [Stop] END IN (select Item from fn_SSRS_ParameterSplit(@Stop,','))
	  AND CONVERT(Date, D.ExpectedDate) >= @ExpectedDateFrom  
	  AND CONVERT(Date, D.ExpectedDate) <= @ExpectedDateTo 
	ORDER BY CONVERT(DATE, D.ExpectedDate), D.Number   

END
GO


