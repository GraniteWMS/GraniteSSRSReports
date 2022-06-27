-- Description:	List all suggested reorder  
CREATE PROCEDURE [dbo].[SSRS_Inventory_StockToReorder] 

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
	FROM [$(GraniteDatabase)].dbo.MasterItem with (nolock) 
	LEFT JOIN [$(GraniteDatabase)].dbo.Location with (nolock) on MasterItem.PickfaceLocation_id = Location.ID 
	LEFT JOIN [$(GraniteDatabase)].dbo.TrackingEntity with (nolock) on MasterItem.ID = TrackingEntity.MasterItem_id 
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