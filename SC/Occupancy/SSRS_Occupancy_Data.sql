CREATE PROCEDURE [SSRS_Occupancy_Data] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [Name]
	  ,(rank() over(order by [Name])-1)/20 RowID
	  ,(row_number()over(order by [Name])-1)%20 RowNum
	  ,CASE 
		WHEN ID NOT IN (SELECT Location_id 
						FROM TrackingEntity
						WHERE InStock = 1) 
		THEN 0 
		ELSE 1 
	   END AS Occupied
	FROM [Location]
	ORDER BY [Name]
END
GO