-- Description:	List all sites with stock on hand 
CREATE PROCEDURE [dbo].[SSRS_Inventory_LocationCategory] 

	 @LocationSite varchar(max)			--- if not used, pass '*' as default
	,@LocationERP varchar(max)			--- if not used, pass '*' as default
	,@LocationType varchar(max)			--- if not used, pass '*' as default
	--,@LocationCategory varchar(max)		--- if not used, pass '*' as default
	--,@ItemType varchar(max)			    --- if not used, pass '*' as default 
	--,@ItemCategory varchar(max)			--- if not used, pass '*' as default 
	--,@Code varchar(250)					--- if not used, pass '*' as default 
	--,@SerialNumber varchar(250)			--- if not used, pass '*' as default 
	--,@Batch varchar(250)				--- if not used, pass '*' as default 

AS

-- exec [SSRS_Inventory_LocationCategory] '*', '*', '*' 

BEGIN

	SET NOCOUNT ON;

	SELECT DISTINCT CASE WHEN ISNULL([Location].Category,'') = '' THEN ' None' ELSE [Location].Category END Category 
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
	  AND (   @LocationType  = '*' 
           OR CASE WHEN ISNULL([Location].Type,'') = '' THEN ' None' ELSE [Location].Type END in (select Item from fn_SSRS_ParameterSplit(@LocationType,',')))
	GROUP BY CASE WHEN ISNULL([Location].Category,'') = '' THEN ' None' ELSE [Location].Category END 
	ORDER BY Category 

END
GO