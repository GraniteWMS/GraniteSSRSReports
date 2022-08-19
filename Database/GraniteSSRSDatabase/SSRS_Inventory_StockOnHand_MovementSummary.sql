-- Description:	List all in stock in stock locations, showing movement per period (3 month buckets).  
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[SSRS_Inventory_SlowMoversSummary] 

	@LocationERP varchar(max)			--- if not used, pass '*' as default

AS

-- exec [SSRS_Inventory_SlowMoversSummary]  'TR' 

BEGIN

	SET NOCOUNT ON;

	SELECT ERPLocation
			, Code
			, Description 
			, ItemType
			, ItemCategory 
			, SUM(CurrentQty) as CurrentQty
			, SUM(QtyIn1) QtyIn1
			, SUM(QtyOut1) QtyOut1
			, SUM(QtyIn2) QtyIn2
			, SUM(QtyOut2) QtyOut2
			, SUM(QtyIn3) QtyIn3
			, SUM(QtyOut3) QtyOut3
 			, SUM(QtyIn4) QtyIn4 
			, SUM(QtyOut4) QtyOut4
			, SUM(QtyIn5) QtyIn5
			, SUM(QtyOut5) QtyOut5
	FROM (
			SELECT L.ERPLocation
				 , MI.Code
				 , MI.Description
				 , MI.Type ItemType 
				 , MI.Category ItemCategory 
				 , TE.Barcode 
				 , L.Name as CurrentLocation
				 , CONVERT(Date, TE.CreatedDate) CreatedDate
				 , TE.Batch
				 , CASE WHEN ISNULL(TE.ExpiryDate,'') = '' THEN '' ELSE TE.ExpiryDate END ExpiryDate
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
			FROM TrackingEntity TE 
			INNER JOIN MasterItem MI ON TE.MasterItem_id = MI.ID 
			INNER JOIN Location L ON TE.Location_id = L.ID AND L.NonStock = 0   
			--OUTER APPLY (SELECT TOP 1 CONVERT(Date, TR.Date) FirstDate    
			--				FROM [Transaction] TR
			--				WHERE TR.TrackingEntity_id = TE.ID  
			--				AND TR.[Type] IN ('RECEIVE', 'TAKEON', 'MANUFACTURE')
			--				GROUP BY CONVERT(Date, TR.Date) 
			--				ORDER BY CONVERT(Date, TR.Date)
			--				) tbl   -- First Transaction date
			OUTER APPLY (SELECT CASE WHEN TR.Type IN ('RECEIVE', 'TAKEON', 'MANUFACTURE') THEN SUM(TR.ToQty) - SUM(TR.FromQty) ELSE 0 END QtyIn
							  , CASE WHEN TR.Type NOT IN ('RECEIVE', 'TAKEON', 'MANUFACTURE') THEN SUM(TR.ToQty) - SUM(TR.FromQty) ELSE 0 END QtyOut 
							FROM [Transaction] TR
							WHERE TR.TrackingEntity_id = TE.ID  
							  AND TR.[Type] IN ('PICK', 'TRANSFER', 'CONSUME', 'RECEIVE', 'TAKEON', 'MANUFACTURE')
							  AND (CONVERT(Date, TR.Date) > DATEADD(month,-3,CONVERT(Date, GETDATE())))  
							GROUP BY TR.Type 
							) tbl1  -- 1st date bucket 
			OUTER APPLY (SELECT CASE WHEN TR.Type IN ('RECEIVE', 'TAKEON', 'MANUFACTURE') THEN SUM(TR.ToQty) - SUM(TR.FromQty) ELSE 0 END QtyIn
							  , CASE WHEN TR.Type NOT IN ('RECEIVE', 'TAKEON', 'MANUFACTURE') THEN SUM(TR.ToQty) - SUM(TR.FromQty) ELSE 0 END QtyOut 
							FROM [Transaction] TR
							WHERE TR.TrackingEntity_id = TE.ID  
							  AND TR.[Type] IN ('PICK', 'TRANSFER', 'CONSUME', 'RECEIVE', 'TAKEON', 'MANUFACTURE')
							  AND (CONVERT(Date, TR.Date) BETWEEN DATEADD(month,-6,CONVERT(Date, GETDATE())) AND DATEADD(month,-3,CONVERT(Date, GETDATE())))  
							GROUP BY TR.Type 
							) tbl2  -- 2nd date bucket 
			OUTER APPLY (SELECT CASE WHEN TR.Type IN ('RECEIVE', 'TAKEON', 'MANUFACTURE') THEN SUM(TR.ToQty) - SUM(TR.FromQty) ELSE 0 END QtyIn
							  , CASE WHEN TR.Type NOT IN ('RECEIVE', 'TAKEON', 'MANUFACTURE') THEN SUM(TR.ToQty) - SUM(TR.FromQty) ELSE 0 END QtyOut 
							FROM [Transaction] TR
							WHERE TR.TrackingEntity_id = TE.ID  
							  AND TR.[Type] IN ('PICK', 'TRANSFER', 'CONSUME', 'RECEIVE', 'TAKEON', 'MANUFACTURE')
							  AND (CONVERT(Date, TR.Date) BETWEEN DATEADD(month,-9,CONVERT(Date, GETDATE())) AND DATEADD(month,-6,CONVERT(Date, GETDATE())))  
							GROUP BY TR.Type
							) tbl3  -- 3rd date bucket 
			OUTER APPLY (SELECT CASE WHEN TR.Type IN ('RECEIVE', 'TAKEON', 'MANUFACTURE') THEN SUM(TR.ToQty) - SUM(TR.FromQty) ELSE 0 END QtyIn
							  , CASE WHEN TR.Type NOT IN ('RECEIVE', 'TAKEON', 'MANUFACTURE') THEN SUM(TR.ToQty) - SUM(TR.FromQty) ELSE 0 END QtyOut 
							FROM [Transaction] TR
							WHERE TR.TrackingEntity_id = TE.ID  
							  AND TR.[Type] IN ('PICK', 'TRANSFER', 'CONSUME', 'RECEIVE', 'TAKEON', 'MANUFACTURE')
							  AND (CONVERT(Date, TR.Date) BETWEEN DATEADD(month,-12,CONVERT(Date, GETDATE())) AND DATEADD(month,-9,CONVERT(Date, GETDATE())))  
							GROUP BY TR.Type 
							) tbl4  -- 4th date bucket 
			OUTER APPLY (SELECT CASE WHEN TR.Type IN ('RECEIVE', 'TAKEON', 'MANUFACTURE') THEN SUM(TR.ToQty) - SUM(TR.FromQty) ELSE 0 END QtyIn
							  , CASE WHEN TR.Type NOT IN ('RECEIVE', 'TAKEON', 'MANUFACTURE') THEN SUM(TR.ToQty) - SUM(TR.FromQty) ELSE 0 END QtyOut 
							FROM [Transaction] TR
							WHERE TR.TrackingEntity_id = TE.ID  
							  AND TR.[Type] IN ('PICK', 'TRANSFER', 'CONSUME', 'RECEIVE', 'TAKEON', 'MANUFACTURE')
							  AND (CONVERT(Date, TR.Date) < DATEADD(month,-12,CONVERT(Date, GETDATE())))  
							GROUP BY TR.Type 
							) tbl5  -- 5th date bucket 
			WHERE TE.Instock =  1 
				AND TE.Qty > 0 
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
				   , TE.Qty
				   , L.Name
		 ) TSQL 
	GROUP BY ERPLocation, Code, Description, ItemType, ItemCategory 
	ORDER BY ERPLocation, Code 

END
GO


