-- Description:	List all data in outbound Documents for route, stop, document, within date range  
--              Execute pick instruction with selection to get updated pick from instructions
-- =============================================
CREATE  PROCEDURE [dbo].[SSRS_Document_PickSlip_Route]

	 @Route varchar(max)
    ,@Stop varchar(max)
	,@ExpectedDateFrom date
	,@ExpectedDateTo date
	,@DocumentNumber varchar(max) 
	
AS 

-- EXEC SSRS_Document_PickSlip_Route 'None', 'None', '2022-09-01', '2022-09-30', '138745,137970,138466'

BEGIN 

    SET NOCOUNT ON;

	-- get valid documents 
	DECLARE @DocumentList TABLE 
		( ID INT NOT NULL IDENTITY(1, 1)
		 ,DocumentNumber varchar(50)
		)
	INSERT INTO @DocumentList 
	SELECT DISTINCT D.Number DocumentNumber
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
	  AND D.[Number] IN (select Item from fn_SSRS_ParameterSplit(@DocumentNumber,','))
	ORDER BY D.Number  

	-- execute Pick recommendation for documents 
	DECLARE @DocumentCount int = (select count(*) from @DocumentList) 
	DECLARE @CurrentCount int = 1 
	DECLARE @CurrentDocument varchar(50) 

	WHILE @CurrentCount <= @DocumentCount 
	BEGIN 
		SELECT @CurrentDocument = (select DocumentNumber from @DocumentList where ID = @CurrentCount) 

		EXEC Logic_UpdatePickRecommendation @CurrentDocument 

		SELECT @CurrentCount = @CurrentCount + 1 
	END

	DECLARE @RouteList varchar(max) 
	SELECT @RouteList = COALESCE(@RouteList + ', ' ,'') + x.[Route] 
	FROM (SELECT DISTINCT CASE WHEN ISNULL(D.[Route],'') = '' OR TRIM(D.[Route]) = '' THEN 'None' ELSE D.[Route] END [Route]
		  FROM Document D
		  INNER JOIN @DocumentList DL on D.Number = DL.DocumentNumber 
		  ) x

	DECLARE @StopList varchar(max) 
	SELECT @StopList = COALESCE(@StopList + ', ' ,'') + x.[Stop] 
	FROM (SELECT DISTINCT CASE WHEN ISNULL(D.[Stop],'') = '' OR TRIM(D.[Stop]) = '' THEN 'None' ELSE D.[Stop] END [Stop]
		  FROM Document D
		  INNER JOIN @DocumentList DL on D.Number = DL.DocumentNumber 
		  ) x

	-- fetch data for report 
	SELECT D.Number DocumentNumber
		  ,D.[Type] DocumentType
		  ,CASE WHEN ISNULL(D.[Route],'') = '' OR TRIM(D.[Route]) = '' THEN 'None' ELSE D.[Route] END [Route] 
		  ,CASE WHEN ISNULL(D.[Stop],'') = '' OR TRIM(D.[Stop]) = '' THEN 'None' ELSE D.[Stop] END [Stop] 
		  ,CONVERT(Date, D.ExpectedDate) ExpectedDate 
		  ,D.TradingPartnerCode
		  ,D.TradingPartnerDescription
		  ,DD.LinePriority 
		  ,DD.LineNumber
		  ,MI.Code
		  ,MI.Description
		  ,DD.Qty - DD.ActionQty OutstandingQty 
		  ,DD.Instruction 
		  ,@RouteList as [RouteList]
		  ,@StopList as [StopList]
	FROM Document D
	INNER JOIN @DocumentList DL on D.Number = DL.DocumentNumber 
	INNER JOIN DocumentDetail DD on D.ID = DD.Document_id 
	INNER JOIN MasterItem MI on DD.Item_id = MI.ID 
	WHERE D.Type IN ('ORDER') --, 'TRANSFER') 
	  AND DD.Completed = 0 
	  AND DD.Cancelled = 0 
	  AND DD.Qty - DD.ActionQty > 0 
	ORDER BY D.Route, D.Stop, CONVERT(Date, D.ExpectedDate), D.Number, DD.LinePriority 

END
GO


