CREATE PROCEDURE [dbo].[SSRS_Transaction_GetSerialNumber] 
	@StartDate datetime,
	@EndDate datetime, 
	@Type varchar(MAX) 
AS

-- exec SSRS_Transaction_GetSerialNumber '2022/02/05', '2022/04/21', 'RECEIVE'

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT DISTINCT CASE WHEN ISNULL(SerialNumber,'') = '' THEN 'BLANK' END as SerialNumber
	FROM TrackingEntity
	--WHERE SerialNumber <> ''
	ORDER BY CASE WHEN ISNULL(SerialNumber,'') = '' THEN 'BLANK' END
END
GO


