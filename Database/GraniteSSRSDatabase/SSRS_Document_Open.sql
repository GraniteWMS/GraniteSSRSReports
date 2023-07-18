CREATE PROCEDURE [dbo].[SSRS_Document_Open]
	  @DocumentType varchar(250)		--- list of values with , separation
	
AS 

-- EXEC SSRS_Document_Outbound_Open 'RECEIVING'

BEGIN 

    SET NOCOUNT ON;

	SELECT Document.Number, 
	       CASE WHEN ISNULL(Document.TradingPartnerCode,'') = '' THEN 'None' ELSE Document.TradingPartnerCode END TradingPartnerCode, 
		   CASE WHEN ISNULL(Document.TradingPartnerDescription,'') = '' THEN 'None' ELSE Document.TradingPartnerDescription END TradingPartnerDescription, 
		   Document.CreateDate, Document.ExpectedDate, Document.AuditDate DocumentAuditDate, 
	       DocumentDetail.LineNumber, MasterItem.Code, MasterItem.Description, DocumentDetail.Qty, DocumentDetail.ActionQty, DocumentDetail.AuditDate LineAuditDate  
	FROM Document 
	INNER JOIN DocumentDetail on Document.ID = DocumentDetail.Document_id 
	                         AND DocumentDetail.Completed = 0
							 AND DocumentDetail.Cancelled = 0
							 AND DocumentDetail.Qty - DocumentDetail.ActionQty > 0 
	INNER JOIN MasterItem on DocumentDetail.Item_id = MasterItem.ID 
	WHERE Document.Status NOT IN ('COMPLETE', 'CANCELED', 'CANCELLED') 
	  AND Document.[Type] in (select Item from fn_SSRS_ParameterSplit(@DocumentType,','))


END