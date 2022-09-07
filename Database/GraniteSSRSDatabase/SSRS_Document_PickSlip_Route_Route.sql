-- Description:	List all routes in outbound Documents 
-- =============================================
CREATE PROCEDURE [dbo].[SSRS_Document_PickSlip_Route_Route] 

AS

-- exec SSRS_Document_PickSlip_Route_Route 

BEGIN

	SET NOCOUNT ON;

	SELECT DISTINCT 
	       --CASE WHEN ISNULL([Route],'') = '' THEN '' ELSE [Route] END [Route], 
	       --CASE WHEN ISNULL([Route],'') = '' THEN 'None' ELSE [Route] END RouteDescription 
	       CASE WHEN ISNULL([Route],'') = '' OR TRIM([Route]) = '' THEN '' ELSE [Route] END [Route], 
	       CASE WHEN ISNULL([Route],'') = '' OR TRIM([Route]) = '' THEN 'None' ELSE [Route] END RouteDescription 
	FROM [Document] 
	WHERE [Type] in ('ORDER') --, 'TRANSFER') 
	ORDER BY [Route]

END
GO


