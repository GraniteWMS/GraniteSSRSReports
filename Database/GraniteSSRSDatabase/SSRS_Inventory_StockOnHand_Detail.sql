USE [GraniteDatabase]
GO

/****** Object:  StoredProcedure [dbo].[SSRS_Inventory_StockOnHand_Detail]    Script Date: 2022/06/22 17:50:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:      Nicole Trevisan
-- Create date: 2022-06-20
-- Description:	List all stock on hand (detail)
-- =============================================
CREATE OR ALTER       PROCEDURE [dbo].[SSRS_Inventory_StockOnHand_Detail] 

	 @LocationSite varchar(max)			--- if not used, pass '*' as default
	,@LocationERP varchar(max)			--- if not used, pass '*' as default
	,@LocationType varchar(max)			--- if not used, pass '*' as default
	,@LocationCategory varchar(max)		--- if not used, pass '*' as default
	,@ItemType varchar(max)			    --- if not used, pass '*' as default 
	,@ItemCategory varchar(max)			--- if not used, pass '*' as default 
	,@Code varchar(250)					--- if not used, pass '*' as default 
	,@SerialNumber varchar(250)			--- if not used, pass '*' as default 
	,@Batch varchar(250)				--- if not used, pass '*' as default 

AS

-- exec [SSRS_Inventory_StockOnHand_Detail] '*', '*', '*', '*', '*', '*', '*', '*', '*'

BEGIN

	SET NOCOUNT ON;

	SELECT CASE WHEN ISNULL([Location].[Site],'') = '' THEN '' ELSE [Location].[Site] END [Site] 
	     , CASE WHEN ISNULL([Location].[ERPLocation],'') = '' THEN '' ELSE [Location].[ERPLocation] END ERPLocation 
		 , CASE WHEN ISNULL([Location].[Type],'') = '' THEN '' ELSE [Location].[Type] END AS LocationType
		 , CASE WHEN ISNULL([Location].[Category],'') = '' THEN '' ELSE [Location].[Category] END AS LocationCategory 
		 , [Location].Barcode AS Location
		 , [Location].Name AS LocationName
		 , [MasterItem].Code
		 , [MasterItem].Description 
		 , CASE WHEN ISNULL([MasterItem].Type,'') = '' THEN '' ELSE [MasterItem].Type END AS ItemType 
		 , CASE WHEN ISNULL([MasterItem].Category,'') = '' THEN '' ELSE [MasterItem].Category END AS ItemCategory
		 , [TrackingEntity].Barcode 
		 , CASE WHEN ISNULL([CarryingEntity].Barcode,'') = '' THEN '' ELSE [CarryingEntity].Barcode END AS Pallet
		 , CASE WHEN ISNULL([TrackingEntity].SerialNumber,'') = '' THEN '' ELSE [TrackingEntity].SerialNumber END AS SerialNumber
		 , CASE WHEN ISNULL([TrackingEntity].Batch,'') = '' THEN '' ELSE [TrackingEntity].Batch END AS Batch
		 , [TrackingEntity].ExpiryDate
		 , [TrackingEntity].CreatedDate 
		 , [TrackingEntity].ManufactureDate 
		 , [TrackingEntity].OnHold 
	     , SUM([TrackingEntity].Qty) AS Qty
		 , CASE WHEN [TrackingEntity].OnHold = 1 THEN SUM([TrackingEntity].Qty) ELSE 0 END AS QtyOnHold 
	FROM [MasterItem] with (nolock) 
	INNER JOIN [TrackingEntity] with (nolock) ON [MasterItem].ID = [TrackingEntity].MasterItem_id 
	INNER JOIN [Location] with (nolock) ON [TrackingEntity].Location_id = [Location].ID AND [Location].NonStock = 0
	LEFT OUTER JOIN [CarryingEntity] ON [TrackingEntity].BelongsToEntity_id = [CarryingEntity].ID
	WHERE ([TrackingEntity].Qty > 0) 
	  AND ([TrackingEntity].InStock = 1)
	  AND (   @LocationSite = '*' 
		   OR CASE WHEN ISNULL([Location].Site,'') = '' THEN ' None' ELSE [Location].Site END in (select Item from fn_SSRS_ParameterSplit(@LocationSite,',')))
	  AND (   @LocationERP = '*' 
           OR CASE WHEN ISNULL([Location].ERPLocation,'') = '' THEN ' None' ELSE [Location].ERPLocation END in (select Item from fn_SSRS_ParameterSplit(@LocationERP,',')))
	  AND (   @LocationType = '*' 
           OR CASE WHEN ISNULL([Location].Type,'') = '' THEN ' None' ELSE [Location].Type END in (select Item from fn_SSRS_ParameterSplit(@LocationType,',')))
	  AND (   @LocationCategory = '*' 
           OR CASE WHEN ISNULL([Location].Category,'') = '' THEN ' None' ELSE [Location].Category END in (select Item from fn_SSRS_ParameterSplit(@LocationCategory,',')))
	  AND (   @ItemType = '*' 
           OR CASE WHEN ISNULL([MasterItem].Type,'') = '' THEN ' None' ELSE [MasterItem].Type END in (select Item from fn_SSRS_ParameterSplit(@ItemType,',')))
	  AND (   @Code = '*' 
		   OR [MasterItem].Code in (select Item from fn_SSRS_ParameterSplit(@Code,',')))
	  AND (   @Batch = '*' 
		   OR [TrackingEntity].Batch in (select Item from fn_SSRS_ParameterSplit(@Batch,',')))
	  AND (   @SerialNumber = '*' 
		   OR [TrackingEntity].SerialNumber in (select Item from fn_SSRS_ParameterSplit(@SerialNumber,',')))
	GROUP BY [Location].Site
	       , [Location].ERPLocation 
		   , [Location].Type 
		   , [Location].Category  
		   , [Location].Barcode 
		   , [Location].Name 
		   , [MasterItem].Code
		   , [MasterItem].Description 
		   , [MasterItem].Type 
		   , [MasterItem].Category 
		   , [TrackingEntity].Barcode 
		   , [CarryingEntity].Barcode 
		   , [TrackingEntity].SerialNumber
		   , [TrackingEntity].Batch
		   , [TrackingEntity].ExpiryDate
		   , [TrackingEntity].CreatedDate
		   , [TrackingEntity].ManufactureDate
		   , [TrackingEntity].OnHold 
	ORDER BY [Location].Site
	       , [Location].ERPLocation 
		   , [MasterItem].Code
		   , [TrackingEntity].Barcode 
		   , [CarryingEntity].Barcode 
END
GO


