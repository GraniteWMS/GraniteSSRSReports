-- Description:	List all sites with stock on hand 
CREATE PROCEDURE [dbo].[SSRS_Inventory_LocationSite] 

AS

-- exec [SSRS_Inventory_LocationSite] 

BEGIN

	SET NOCOUNT ON;

	SELECT DISTINCT CASE WHEN ISNULL([Location].Site,'') = '' THEN ' None' ELSE [Location].Site END AS Site 
	FROM [$(GraniteDatabase)].dbo.[MasterItem] with (nolock) 
	INNER JOIN [$(GraniteDatabase)].dbo.[TrackingEntity] with (nolock) ON [MasterItem].ID = [TrackingEntity].MasterItem_id 
	INNER JOIN [$(GraniteDatabase)].dbo.[Location] with (nolock) ON [TrackingEntity].Location_id = [Location].ID AND [Location].NonStock = 0
	LEFT OUTER JOIN [$(GraniteDatabase)].dbo.[CarryingEntity] ON [TrackingEntity].BelongsToEntity_id = [CarryingEntity].ID
	WHERE ([TrackingEntity].Qty > 0) 
	  AND ([TrackingEntity].InStock = 1)
	GROUP BY CASE WHEN ISNULL([Location].Site,'') = '' THEN ' None' ELSE [Location].Site END
	ORDER BY Site 

END
GO