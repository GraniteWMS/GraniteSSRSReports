-- Description:	List all stops in outbound Documents for route 
-- =============================================
CREATE PROCEDURE [dbo].[SSRS_Document_PickSlip_Route_Stop] 

	 @Route varchar(max)

AS

-- exec SSRS_Document_PickSlip_Route_Stop 'None'  

BEGIN

	SET NOCOUNT ON;

	SELECT DISTINCT 
	       --CASE WHEN ISNULL(RTRIM([Stop]),'') = '' THEN '' ELSE RTRIM([Stop]) END [Stop], 
	       --CASE WHEN ISNULL(RTRIM([Stop]),'') = '' THEN 'None' ELSE RTRIM([Stop]) END StopDescription 
	       CASE WHEN ISNULL(RTRIM([Stop]),'') = '' OR TRIM([Stop]) = '' THEN '' ELSE RTRIM([Stop]) END [Stop], 
	       CASE WHEN ISNULL(RTRIM([Stop]),'') = '' OR TRIM([Stop]) = '' THEN 'None' ELSE RTRIM([Stop]) END StopDescription 
	FROM [Document] 
	WHERE [Type] in ('ORDER') --, 'TRANSFER') 
--	  AND ISNULL([Route],'None') IN (select Item from fn_SSRS_ParameterSplit(@Route,','))
	  AND CASE WHEN ISNULL([Route],'') = '' OR TRIM([Route]) = '' THEN 'None' ELSE [Route] END IN (select Item from fn_SSRS_ParameterSplit(@Route,','))
	ORDER BY [Stop]

END
GO


