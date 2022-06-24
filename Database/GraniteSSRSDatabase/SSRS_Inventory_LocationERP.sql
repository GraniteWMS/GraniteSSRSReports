USE [GraniteDatabase]
GO

/****** Object:  StoredProcedure [dbo].[SSRS_Inventory_LocationERP]    Script Date: 2022/06/22 17:49:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:      Nicole Trevisan
-- Create date: 2022-06-20
-- Description:	List all sites with stock on hand 
-- =============================================
CREATE OR ALTER     PROCEDURE [dbo].[SSRS_Inventory_LocationERP] 

	 @LocationSite varchar(max)			--- if not used, pass '*' as default

AS

-- exec [SSRS_Inventory_LocationERP] '*' 

BEGIN

	SET NOCOUNT ON;

	SELECT DISTINCT CASE WHEN ISNULL([Location].ERPLocation,'') = '' THEN ' None' ELSE [Location].ERPLocation END ERPLocation 
	FROM [MasterItem] with (nolock) 
	INNER JOIN [TrackingEntity] with (nolock) ON [MasterItem].ID = [TrackingEntity].MasterItem_id 
	INNER JOIN [Location] with (nolock) ON [TrackingEntity].Location_id = [Location].ID AND [Location].NonStock = 0
	LEFT OUTER JOIN [CarryingEntity] ON [TrackingEntity].BelongsToEntity_id = [CarryingEntity].ID
	WHERE ([TrackingEntity].Qty > 0) 
	  AND ([TrackingEntity].InStock = 1)
	  AND (   @LocationSite = '*' 
		   OR CASE WHEN ISNULL([Location].Site,'') = '' THEN ' None' ELSE [Location].Site END in (select Item from fn_SSRS_ParameterSplit(@LocationSite,',')))
	GROUP BY CASE WHEN ISNULL([Location].ERPLocation,'') = '' THEN ' None' ELSE [Location].ERPLocation END 
	ORDER BY ERPLocation 

END
GO


