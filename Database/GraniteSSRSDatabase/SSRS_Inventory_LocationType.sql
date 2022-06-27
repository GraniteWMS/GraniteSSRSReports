-- Description:	List all sites with stock on hand 
CREATE PROCEDURE [dbo].[SSRS_Inventory_LocationType] 
	 @LocationSite varchar(max)			--- if not used, pass '*' as default
	,@LocationERP varchar(max)			--- if not used, pass '*' as default

AS

-- exec [SSRS_Inventory_LocationType] '*', '*' 

BEGIN

	SET NOCOUNT ON;

	SELECT DISTINCT CASE WHEN ISNULL([Location].Type,'') = '' THEN ' None' ELSE [Location].Type END Type  
	FROM [$(GraniteDatabase)].dbo.[MasterItem] with (nolock) 
	INNER JOIN [$(GraniteDatabase)].dbo.[TrackingEntity] with (nolock) ON [MasterItem].ID = [TrackingEntity].MasterItem_id 
	INNER JOIN [$(GraniteDatabase)].dbo.[Location] with (nolock) ON [TrackingEntity].Location_id = [Location].ID AND [Location].NonStock = 0
	LEFT OUTER JOIN [$(GraniteDatabase)].dbo.[CarryingEntity] ON [TrackingEntity].BelongsToEntity_id = [CarryingEntity].ID
	WHERE ([TrackingEntity].Qty > 0) 
	  AND ([TrackingEntity].InStock = 1)
	  AND (   @LocationSite = '*' 
		   OR CASE WHEN ISNULL([Location].Site,'') = '' THEN ' None' ELSE [Location].Site END in (select Item from fn_SSRS_ParameterSplit(@LocationSite,',')))
	  AND (   @LocationERP = '*' 
           OR CASE WHEN ISNULL([Location].ERPLocation,'') = '' THEN ' None' ELSE [Location].ERPLocation END in (select Item from fn_SSRS_ParameterSplit(@LocationERP,',')))
	GROUP BY CASE WHEN ISNULL([Location].Type,'') = '' THEN ' None' ELSE [Location].Type END 
	ORDER BY Type 

END
GO


