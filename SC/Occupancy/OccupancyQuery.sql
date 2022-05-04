SELECT [Name]
	  ,(rank() over(order by [Name])-1)/20 RowID
	  ,(row_number()over(order by [Name])-1)%20 RowNum
	  ,CASE 
		WHEN ID NOT IN 
			(SELECT Location_id 
			 FROM TrackingEntity
			 WHERE InStock = 1) 
		THEN 0 
		ELSE 1 
	   END AS Occupied
FROM [Location]
WHERE [Name] LIKE '%-%'
ORDER BY [Name]