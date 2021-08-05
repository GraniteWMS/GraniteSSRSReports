USE [GraniteDatabase]
GO

/****** Object:  View [dbo].[SSRS_vw_Inbound_Receiving]    Script Date: 8/5/2021 6:01:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[SSRS_vw_Inbound_Receiving]
AS
SELECT        RTRIM(Number) AS Number, RTRIM(TradingPartnerCode) AS TradingPartnerCode, RTRIM(TradingPartnerDescription) AS TradingPartnerDescription, RTRIM(LineNumber) AS LineNumber, RTRIM(Code) AS Code, 
                         RTRIM(Description) AS Description, RTRIM(ItemCategory) AS ItemCategory, RTRIM(ItemType) AS ItemType, RTRIM(TransactionType) AS TransactionType, RTRIM([User]) AS [User], MAX(Qty) AS Qty, MAX(ActionQty) AS ActionQty, 
                         MAX(Qty) - MAX(ActionQty) AS QtyOutstanding, MAX(DetailActionDate) AS DetailActionDate, DetailStatus, DocumentActionDate, DocumentCreateDate, DocumentStatus, RTRIM(DocumentUOM) AS DocumentUOM, 
                         DocumentUOMConversion, RTRIM(ItemUOM) AS ItemUOM
FROM            (SELECT        dbo.[Document].Number, dbo.[Document].TradingPartnerCode, dbo.[Document].TradingPartnerDescription, dbo.DocumentDetail.LineNumber, dbo.MasterItem.Code, dbo.MasterItem.Description, 
                                                    dbo.MasterItem.Category AS ItemCategory, dbo.MasterItem.Type AS ItemType, dbo.MasterItem.UOM AS ItemUOM, dbo.DocumentDetail.Qty, ISNULL(dbo.DocumentDetail.ActionQty, 0) AS ActionQty, 
                                                    ISNULL(dbo.DocumentDetail.Qty, 0) - ISNULL(dbo.DocumentDetail.ActionQty, 0) AS QtyOutstanding, TSQL_1.TransactionDate AS DetailActionDate, dbo.Type.Name AS TransactionType, dbo.Users.Name AS [User], 
                                                    dbo.[Document].CreateDate AS DocumentCreateDate, dbo.[Document].ActionDate AS DocumentActionDate, dbo.[Document].Status AS DocumentStatus, dbo.DocumentDetail.Status AS DetailStatus, 
                                                    dbo.DocumentDetail.UOM AS DocumentUOM, dbo.DocumentDetail.UOMConversion AS DocumentUOMConversion
                          FROM            dbo.MasterItem RIGHT OUTER JOIN
                                                    dbo.DocumentDetail ON dbo.MasterItem.ID = dbo.DocumentDetail.Item_id LEFT OUTER JOIN
                                                    dbo.Users RIGHT OUTER JOIN
                                                        (SELECT        Transaction_1.DocumentLine_id, Transaction_1.User_id AS UserID, Transaction_1.Date AS TransactionDate
                                                          FROM            dbo.[Transaction] AS Transaction_1 LEFT OUTER JOIN
                                                                                    dbo.TrackingEntity ON dbo.TrackingEntity.ID = Transaction_1.TrackingEntity_id
                                                          GROUP BY dbo.TrackingEntity.MasterItem_id, Transaction_1.DocumentLine_id, Transaction_1.User_id, Transaction_1.Date) AS TSQL_1 ON dbo.Users.ID = TSQL_1.UserID ON 
                                                    TSQL_1.DocumentLine_id = dbo.DocumentDetail.ID RIGHT OUTER JOIN
                                                    dbo.[Document] LEFT OUTER JOIN
                                                    dbo.Type ON dbo.[Document].Type = dbo.Type.Name ON dbo.DocumentDetail.Document_id = dbo.[Document].ID
                          WHERE        (dbo.Type.Name IN ('RECEIVING'))) AS TSQL
GROUP BY Number, TradingPartnerCode, LineNumber, Code, Description, ItemCategory, ItemType, TransactionType, [User], TradingPartnerDescription, DocumentCreateDate, DocumentActionDate, DocumentStatus, DetailStatus, 
                         DocumentUOM, DocumentUOMConversion, ItemUOM
GO


