USE [GraniteDatabase]
GO

/****** Object:  StoredProcedure [dbo].[SSRS_Inventory_StockToReorder]    Script Date: 2022/06/22 17:50:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:      Nicole Trevisan
-- Create date: 2022-06-20
-- Description:	List all suggested reorder  
-- =============================================
ALTER       PROCEDURE [dbo].[SSRS_Inventory_StockToReorder] 

AS

-- exec [SSRS_Inventory_StockToReorder] 

BEGIN

	SET NOCOUNT ON;

	SELECT MasterItem.Code 
		 , MasterItem.Description 
		 , MasterItem.Type ItemType 
		 , MasterItem.Category ItemCategory 
		 , MAX(ISNULL(MasterItem.MaximumReorderQty,0)) MaxReorder 
		 , MAX(ISNULL(MasterItem.MinimumReorderQty,0)) MinReorder 
		 , SUM(ISNULL(TrackingEntity.Qty,0)) QtyOnHand 
		 , MAX(ISNULL(MasterItem.MaximumReorderQty,0)) - SUM(ISNULL(TrackingEntity.Qty,0)) AS ReorderQty 
	FROM MasterItem with (nolock) 
	LEFT JOIN Location with (nolock) on MasterItem.PickfaceLocation_id = Location.ID 
	LEFT JOIN TrackingEntity with (nolock) on MasterItem.ID = TrackingEntity.MasterItem_id 
										  AND MasterItem.PickfaceLocation_id = TrackingEntity.Location_id 
										  AND TrackingEntity.InStock = 1 
	GROUP BY MasterItem.Code 
		   , MasterItem.Description 
		   , MasterItem.Type 
		   , MasterItem.Category 
	HAVING MAX(ISNULL(MasterItem.MaximumReorderQty,0)) > 0 OR MAX(ISNULL(MasterItem.MinimumReorderQty,0)) > 0 
	ORDER BY MAX(ISNULL(MasterItem.MaximumReorderQty,0)) - SUM(ISNULL(TrackingEntity.Qty,0)) desc 

END
GO


