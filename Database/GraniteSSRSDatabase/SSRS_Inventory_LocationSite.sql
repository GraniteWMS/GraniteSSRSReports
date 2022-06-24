USE [GraniteDatabase]
GO

/****** Object:  StoredProcedure [dbo].[SSRS_Inventory_LocationSite]    Script Date: 2022/06/22 17:49:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:      Nicole Trevisan
-- Create date: 2022-06-20
-- Description:	List all sites with stock on hand 
-- =============================================
CREATE OR ALTER     PROCEDURE [dbo].[SSRS_Inventory_LocationSite] 

AS

-- exec [SSRS_Inventory_LocationSite] 

BEGIN

	SET NOCOUNT ON;

	SELECT DISTINCT CASE WHEN ISNULL([Location].Site,'') = '' THEN ' None' ELSE [Location].Site END AS Site 
	FROM [MasterItem] with (nolock) 
	INNER JOIN [TrackingEntity] with (nolock) ON [MasterItem].ID = [TrackingEntity].MasterItem_id 
	INNER JOIN [Location] with (nolock) ON [TrackingEntity].Location_id = [Location].ID AND [Location].NonStock = 0
	LEFT OUTER JOIN [CarryingEntity] ON [TrackingEntity].BelongsToEntity_id = [CarryingEntity].ID
	WHERE ([TrackingEntity].Qty > 0) 
	  AND ([TrackingEntity].InStock = 1)
	GROUP BY CASE WHEN ISNULL([Location].Site,'') = '' THEN ' None' ELSE [Location].Site END
	ORDER BY Site 

END
GO


