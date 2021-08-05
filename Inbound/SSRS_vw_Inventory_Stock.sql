USE [GraniteDatabase]
GO

/****** Object:  View [dbo].[SSRS_vw_Inventory_Stock]    Script Date: 8/5/2021 6:03:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[SSRS_vw_Inventory_Stock]
AS
SELECT        dbo.TrackingEntity.Barcode, dbo.TrackingEntity.OnHold, dbo.TrackingEntity.Qty AS QtyOnHand, RTRIM(dbo.TrackingEntity.Batch) AS Batch, RTRIM(dbo.TrackingEntity.SerialNumber) AS SerialNumber, 
                         dbo.TrackingEntity.CreatedDate, dbo.TrackingEntity.ExpiryDate, dbo.TrackingEntity.ManufactureDate, dbo.CarryingEntity.Barcode AS Pallet, RTRIM(dbo.MasterItem.Code) AS Code, RTRIM(dbo.MasterItem.Description) 
                         AS Description, RTRIM(dbo.MasterItem.UOM) AS UOM, RTRIM(dbo.Location.Name) AS Location, CASE WHEN dbo.MasterItem.Type IS NULL THEN '' ELSE RTRIM(dbo.MasterItem.Type) END AS ItemType, 
                         CASE WHEN dbo.MasterItem.Category IS NULL THEN '' ELSE RTRIM(dbo.MasterItem.Category) END AS ItemCategory, CASE WHEN dbo.Location.ERPLocation IS NULL THEN '' ELSE RTRIM(dbo.Location.ERPLocation) 
                         END AS ERPLocation, CASE WHEN dbo.Location.Site IS NULL THEN '' ELSE RTRIM(dbo.Location.Site) END AS LocationSite, CASE WHEN dbo.Location.Type IS NULL THEN '' ELSE RTRIM(dbo.Location.Type) 
                         END AS LocationType, CASE WHEN dbo.Location.Category IS NULL THEN '' ELSE RTRIM(dbo.Location.Category) END AS LocationCategory, CASE WHEN dbo.TrackingEntity.OnHold = 1 THEN 1 ELSE 0 END AS OnHoldCount, 
                         CASE WHEN dbo.TrackingEntity.OnHold = 1 THEN dbo.TrackingEntity.Qty ELSE 0 END AS OnHoldQty
FROM            dbo.TrackingEntity INNER JOIN
                         dbo.Location ON dbo.TrackingEntity.Location_id = dbo.Location.ID INNER JOIN
                         dbo.MasterItem ON dbo.TrackingEntity.MasterItem_id = dbo.MasterItem.ID LEFT OUTER JOIN
                         dbo.CarryingEntity ON dbo.TrackingEntity.BelongsToEntity_id = dbo.CarryingEntity.ID
WHERE        (dbo.TrackingEntity.InStock = 1) AND (dbo.Location.NonStock = 0) AND (dbo.TrackingEntity.Qty > 0)
GO


