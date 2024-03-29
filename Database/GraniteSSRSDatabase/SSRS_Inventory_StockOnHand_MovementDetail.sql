-- Description:	List all in stock barcodes in stock locations, calculating # days in stock, shoing movement per period (3 month buckets).  
--              Filter on barcodes with DaysInStock > than parameter 
-- =============================================
CREATE OR ALTER   PROCEDURE [dbo].[SSRS_Inventory_StockOnHand_MovementDetail] 

	 @LocationERP varchar(max)			--- if not used, pass '*' as default
	,@DaysInStock int 

AS

-- exec [SSRS_Inventory_StockOnHand_MovementDetail] 'TR', 0

BEGIN

	SET NOCOUNT ON;

	SELECT L.ERPLocation
	     , MI.Code
		 , MI.Description 
		 , MI.Type ItemType 
		 , MI.Category ItemCategory 
		 , TE.Barcode 
		 , L.Name as CurrentLocation
	     , CONVERT(Date, TE.CreatedDate) CreatedDate
		 , TE.Batch
		 , CASE WHEN ISNULL(TE.ExpiryDate,'') = '' THEN '' ELSE CONVERT(varchar,TE.ExpiryDate,111) END ExpiryDate
		 , TE.SerialNumber 
		 , TE.Qty as CurrentQty
		 , SUM(tbl1.QtyIn) QtyIn1
		 , SUM(tbl1.QtyOut) QtyOut1
		 , SUM(tbl2.QtyIn) QtyIn2
		 , SUM(tbl2.QtyOut) QtyOut2
		 , SUM(tbl3.QtyIn) QtyIn3
		 , SUM(tbl3.QtyOut) QtyOut3
		 , SUM(tbl4.QtyIn) QtyIn4
		 , SUM(tbl4.QtyOut) QtyOut4
		 , SUM(tbl5.QtyIn) QtyIn5
		 , SUM(tbl5.QtyOut) QtyOut5
		 , DATEDIFF(day,CONVERT(Date, TE.CreatedDate),CONVERT(Date, GETDATE())) DaysInStock 
	FROM [$(GraniteDatabase)].dbo.TrackingEntity TE 
	INNER JOIN [$(GraniteDatabase)].dbo.MasterItem MI ON TE.MasterItem_id = MI.ID 
	INNER JOIN [$(GraniteDatabase)].dbo.Location L ON TE.Location_id = L.ID AND L.NonStock = 0   
	--OUTER APPLY (SELECT TOP 1 CONVERT(Date, TR.Date) FirstDate    
	--				FROM [$(GraniteDatabase)].dbo.[Transaction] TR
	--				WHERE TR.TrackingEntity_id = TE.ID  
	--				AND TR.[Type] IN ('RECEIVE', 'TAKEON', 'MANUFACTURE')
	--				GROUP BY CONVERT(Date, TR.Date) 
	--				ORDER BY CONVERT(Date, TR.Date)
	--				) tbl   -- First Transaction date
	OUTER APPLY (SELECT CASE WHEN TR.Type IN ('RECEIVE', 'TAKEON', 'MANUFACTURE') THEN SUM(TR.ToQty) - SUM(TR.FromQty) ELSE 0 END QtyIn
	                  , CASE WHEN TR.Type NOT IN ('RECEIVE', 'TAKEON', 'MANUFACTURE') THEN SUM(TR.ToQty) - SUM(TR.FromQty) ELSE 0 END QtyOut 
					FROM [$(GraniteDatabase)].dbo.[Transaction] TR
					WHERE TR.TrackingEntity_id = TE.ID  
					  AND TR.[Type] IN ('PICK', 'TRANSFER', 'CONSUME', 'RECEIVE', 'TAKEON', 'MANUFACTURE')
					  AND (CONVERT(Date, TR.Date) > DATEADD(month,-3,CONVERT(Date, GETDATE())))  
					GROUP BY TR.Type 
					) tbl1  -- 1st date bucket 
	OUTER APPLY (SELECT CASE WHEN TR.Type IN ('RECEIVE', 'TAKEON', 'MANUFACTURE') THEN SUM(TR.ToQty) - SUM(TR.FromQty) ELSE 0 END QtyIn
	                  , CASE WHEN TR.Type NOT IN ('RECEIVE', 'TAKEON', 'MANUFACTURE') THEN SUM(TR.ToQty) - SUM(TR.FromQty) ELSE 0 END QtyOut 
					FROM [$(GraniteDatabase)].dbo.[Transaction] TR
					WHERE TR.TrackingEntity_id = TE.ID  
					  AND TR.[Type] IN ('PICK', 'TRANSFER', 'CONSUME', 'RECEIVE', 'TAKEON', 'MANUFACTURE')
					  AND (CONVERT(Date, TR.Date) BETWEEN DATEADD(month,-6,CONVERT(Date, GETDATE())) AND DATEADD(month,-3,CONVERT(Date, GETDATE())))  
					GROUP BY TR.Type 
					) tbl2  -- 2nd date bucket 
	OUTER APPLY (SELECT CASE WHEN TR.Type IN ('RECEIVE', 'TAKEON', 'MANUFACTURE') THEN SUM(TR.ToQty) - SUM(TR.FromQty) ELSE 0 END QtyIn
	                  , CASE WHEN TR.Type NOT IN ('RECEIVE', 'TAKEON', 'MANUFACTURE') THEN SUM(TR.ToQty) - SUM(TR.FromQty) ELSE 0 END QtyOut 
					FROM [$(GraniteDatabase)].dbo.[Transaction] TR
					WHERE TR.TrackingEntity_id = TE.ID  
					  AND TR.[Type] IN ('PICK', 'TRANSFER', 'CONSUME', 'RECEIVE', 'TAKEON', 'MANUFACTURE')
					  AND (CONVERT(Date, TR.Date) BETWEEN DATEADD(month,-9,CONVERT(Date, GETDATE())) AND DATEADD(month,-6,CONVERT(Date, GETDATE())))  
					GROUP BY TR.Type
					) tbl3  -- 3rd date bucket 
	OUTER APPLY (SELECT CASE WHEN TR.Type IN ('RECEIVE', 'TAKEON', 'MANUFACTURE') THEN SUM(TR.ToQty) - SUM(TR.FromQty) ELSE 0 END QtyIn
	                  , CASE WHEN TR.Type NOT IN ('RECEIVE', 'TAKEON', 'MANUFACTURE') THEN SUM(TR.ToQty) - SUM(TR.FromQty) ELSE 0 END QtyOut 
					FROM [$(GraniteDatabase)].dbo.[Transaction] TR
					WHERE TR.TrackingEntity_id = TE.ID  
					  AND TR.[Type] IN ('PICK', 'TRANSFER', 'CONSUME', 'RECEIVE', 'TAKEON', 'MANUFACTURE')
					  AND (CONVERT(Date, TR.Date) BETWEEN DATEADD(month,-12,CONVERT(Date, GETDATE())) AND DATEADD(month,-9,CONVERT(Date, GETDATE())))  
					GROUP BY TR.Type 
					) tbl4  -- 4th date bucket 
	OUTER APPLY (SELECT CASE WHEN TR.Type IN ('RECEIVE', 'TAKEON', 'MANUFACTURE') THEN SUM(TR.ToQty) - SUM(TR.FromQty) ELSE 0 END QtyIn
	                  , CASE WHEN TR.Type NOT IN ('RECEIVE', 'TAKEON', 'MANUFACTURE') THEN SUM(TR.ToQty) - SUM(TR.FromQty) ELSE 0 END QtyOut 
					FROM [$(GraniteDatabase)].dbo.[Transaction] TR
					WHERE TR.TrackingEntity_id = TE.ID  
					  AND TR.[Type] IN ('PICK', 'TRANSFER', 'CONSUME', 'RECEIVE', 'TAKEON', 'MANUFACTURE')
					  AND (CONVERT(Date, TR.Date) < DATEADD(month,-12,CONVERT(Date, GETDATE())))  
					GROUP BY TR.Type 
					) tbl5  -- 5th date bucket 
	WHERE TE.Instock =  1 
		AND TE.Qty > 0 
		AND DATEDIFF(day,CONVERT(Date, TE.CreatedDate),CONVERT(Date, GETDATE())) >= @DaysInStock 
		AND (   @LocationERP = '*' 
				OR CASE WHEN ISNULL(L.ERPLocation,'') = '' THEN ' None' ELSE L.ERPLocation END in (select Item from fn_SSRS_ParameterSplit(@LocationERP,',')))
	GROUP BY MI.Code
	       , MI.Description
		   , MI.Type 
		   , MI.Category
		   , L.ERPLocation
		   , TE.Barcode
		   , CONVERT(Date, TE.CreatedDate)
		   , TE.Batch
		   , TE.ExpiryDate
		   , TE.SerialNumber 
		   , TE.Qty
		   , L.Name
	ORDER BY CASE WHEN ISNULL(TE.ExpiryDate,'') = '' THEN '' ELSE CONVERT(varchar,TE.ExpiryDate,111) END 
	--L.ERPLocation, MI.Code, CONVERT(Date, TE.CreatedDate), TE.Barcode  

END
GO

