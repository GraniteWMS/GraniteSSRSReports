USE [GraniteDatabase]
GO

/****** Object:  StoredProcedure [dbo].[SSRS_Inventory_StockToReplenish]    Script Date: 2022/06/22 17:50:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:      Nicole Trevisan
-- Create date: 2022-06-20
-- Description:	List all suggested replenish 
-- =============================================
ALTER       PROCEDURE [dbo].[SSRS_Inventory_StockToReplenish] 

AS

-- exec [SSRS_Inventory_StockToReplenish] 

BEGIN

	SET NOCOUNT ON;

	SELECT MasterItem.Code
		 , MasterItem.Description
		 , MasterItem.Type ItemType
		 , MasterItem.Category ItemCategory 
		 , Location.Barcode PickfaceLocation 
		 , Location.Name PickfaceLocationName
		 , MAX(ISNULL(MasterItem.MinimumPickfaceQuantity,0)) MinimumQty
		 , MAX(ISNULL(MasterItem.OptimalPickfaceQuantity,0)) OptimalQty 
		 , SUM(ISNULL(TrackingEntity.Qty,0)) PickFaceQty 
		 , MAX(ISNULL(MasterItem.OptimalPickfaceQuantity,0)) - SUM(ISNULL(TrackingEntity.Qty,0)) AS ReplenishQty 
	--	 , SUM(Replen.QtyOnHand) AvailableQty 
	FROM MasterItem with (nolock) 
	LEFT JOIN Location with (nolock) on MasterItem.PickfaceLocation_id = Location.ID  
	LEFT JOIN TrackingEntity with (nolock) on MasterItem.ID = TrackingEntity.MasterItem_id 
										  AND MasterItem.PickfaceLocation_id = TrackingEntity.Location_id 
										  AND TrackingEntity.InStock = 1 
	--LEFT JOIN (SELECT MI.ID AS MasterID 
	--				, L.Site
	--				, L.ERPLocation
	--				, L.ID AS LocationID 
	--				, L.Barcode AS Location
	--				, L.Name AS LocationName
	--				, SUM(TE.Qty) AS QtyOnHand 
	--		   FROM TrackingEntity TE with (nolock) 
	--		   INNER JOIN Location L with (nolock) ON TE.Location_id = L.ID and L.NonStock = 0 
	--		   INNER JOIN MasterItem MI with (nolock) ON TE.MasterItem_id = MI.ID 
	--		   WHERE TE.InStock = 1 
	--			 AND TE.Qty > 0 
	--		   GROUP BY MI.ID
	--				  , MI.Code
	--				  , L.ID 
	--				  , L.Site
	--				  , L.ERPLocation
	--				  , L.Barcode 
	--				  , L.Name 
	--		) Replen ON Replen.MasterID = MasterItem.ID AND Replen.LocationID <> MasterItem.PickfaceLocation_id 

	WHERE PickfaceLocation_id IS NOT NULL 
	GROUP BY MasterItem.Code
		 , MasterItem.Description
		 , MasterItem.Type
		 , MasterItem.Category
		 , Location.Barcode  
		 , Location.Name 
	ORDER BY MAX(ISNULL(MasterItem.OptimalPickfaceQuantity,0)) - SUM(ISNULL(TrackingEntity.Qty,0)) desc 


END
GO


