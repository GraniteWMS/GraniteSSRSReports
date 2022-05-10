CREATE PROCEDURE [dbo].[SSRS_DocumentDetailTypeNumber_GetType] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT dbo.[Document].Type
	FROM dbo.[Document] 
END
GO


