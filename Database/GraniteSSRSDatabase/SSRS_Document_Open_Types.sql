CREATE PROCEDURE [dbo].[SSRS_Document_Open_Types]
AS 

-- EXEC SSRS_Document_Types 

BEGIN 

    SET NOCOUNT ON;

	SELECT DISTINCT Document.[Type] 
	FROM Document 
	INNER JOIN DocumentDetail on Document.ID = DocumentDetail.Document_id 
	                         AND DocumentDetail.Completed = 0
							 AND DocumentDetail.Cancelled = 0
							 AND DocumentDetail.Qty - DocumentDetail.ActionQty > 0 
	INNER JOIN MasterItem on DocumentDetail.Item_id = MasterItem.ID 
	WHERE Document.Status NOT IN ('COMPLETE', 'CANCELED', 'CANCELLED') 

END
