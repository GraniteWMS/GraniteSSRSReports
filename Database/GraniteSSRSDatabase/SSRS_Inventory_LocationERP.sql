-- Description:	List all sites with stock on hand 
CREATE PROCEDURE [dbo].[SSRS_Inventory_LocationERP] 
	 @LocationSite varchar(max)			--- if not used, pass '*' as default
AS

-- exec [SSRS_Inventory_LocationERP] '*' 

BEGIN

	SET NOCOUNT ON;

	SELECT DISTINCT CASE WHEN ISNULL([Location].ERPLocation,'') = '' THEN ' None' ELSE [Location].ERPLocation END ERPLocation 
	FROM [$(GraniteDatabase)].dbo.[MasterItem] with (nolock) 
	INNER JOIN [$(GraniteDatabase)].dbo.[TrackingEntity] with (nolock) ON [MasterItem].ID = [TrackingEntity].MasterItem_id 
	INNER JOIN [$(GraniteDatabase)].dbo.[Location] with (nolock) ON [TrackingEntity].Location_id = [Location].ID AND [Location].NonStock = 0
	LEFT OUTER JOIN [$(GraniteDatabase)].dbo.[CarryingEntity] ON [TrackingEntity].BelongsToEntity_id = [CarryingEntity].ID
	WHERE ([TrackingEntity].Qty > 0) 
	  AND ([TrackingEntity].InStock = 1)
	  AND (   @LocationSite = '*' 
		   OR CASE WHEN ISNULL([Location].Site,'') = '' THEN ' None' ELSE [Location].Site END in (select Item from fn_SSRS_ParameterSplit(@LocationSite,',')))
	GROUP BY CASE WHEN ISNULL([Location].ERPLocation,'') = '' THEN ' None' ELSE [Location].ERPLocation END 
	ORDER BY ERPLocation 

END
GO