-- Description:	List all items within expiry month range and older 
CREATE PROCEDURE [dbo].[SSRS_Inventory_StockExpiry]

@ExpiryMonths int

-- exec [SSRS_Inventory_StockExpiry] 6 
AS
BEGIN

	SET NOCOUNT ON;

	SELECT RTRIM(TrackingEntity.Barcode) as Barcode, TrackingEntity.MasterItem_id, RTRIM(MasterItem.Code) as Code, RTRIM(MasterItem.Description) as Description, 
	       MasterItem.Category as ItemCategory, MasterItem.Type as ItemType, 
	       CASE WHEN ISNULL(TrackingEntity.ExpiryDate,'') = '' THEN '' ELSE CONVERT(varchar,TrackingEntity.ExpiryDate,111) END ExpiryDate, 
		   TrackingEntity.Qty as QtyOnHand, 
		   Location.ERPLocation, Location.Site as LocationSite, Location.Name AS Location, Location.Category as LocationCategory, Location.Type as LocationType, 
		   TrackingEntity.SerialNumber, TrackingEntity.Batch, 
		   TrackingEntity.CreatedDate as ReceivedDate,
		   isnull((select SUM(Qty)
				   from ( select me.Code
				               , [Transaction].FromMasterItem_id
							   , [Transaction].Date
							   , [Transaction].Type
							   , CASE WHEN [Transaction].Type = 'PICK' THEN [Transaction].ActionQty ELSE -[Transaction].ActionQty END as Qty  
						  from [$(GraniteDatabase)].dbo.[Transaction] 
						  inner join [$(GraniteDatabase)].dbo.MasterItem me on [Transaction].FromMasterItem_id = me.ID
						  where [Transaction].FromMasterItem_id = TrackingEntity.MasterItem_id 
						    and [Transaction].Type IN ('PICK', 'UNPICK') 
							and DATEFROMPARTS(year([Transaction].Date), month([Transaction].Date), '01') = DATEFROMPARTS(year(getdate()), month(getdate()), '01') 
						) TSQL
				   group by Code),0.00) as [QtySold CurrentMth], 
		   isnull((select SUM(Qty)
				   from (select me.Code
				              , [Transaction].FromMasterItem_id
							  , [Transaction].Date
							  , [Transaction].Type
							  , CASE WHEN [Transaction].Type = 'PICK' THEN [Transaction].ActionQty ELSE -[Transaction].ActionQty END as Qty
							  , DATEFROMPARTS(YEAR([Transaction].Date), month([Transaction].Date), '01') as TransMonth
							  , DATEADD(MONTH, DATEDIFF(month, 0, GETDATE()) -1, 0) as CalculatedMonth 
						 from [$(GraniteDatabase)].dbo.[Transaction] with (nolock)
						 inner join [$(GraniteDatabase)].dbo.MasterItem me with (nolock) on [Transaction].FromMasterItem_id = me.ID
						 where [Transaction].FromMasterItem_id = TrackingEntity.MasterItem_id 
						   and [Transaction].Type IN ('PICK', 'UNPICK') 
						   and DATEFROMPARTS(year([Transaction].Date), month([Transaction].Date), '01') = DATEFROMPARTS(year(DATEADD(month, -1, getdate())), month(DATEADD(month, -1, getdate())), '01')
						) TSQL
				group by Code),0.00) as [QtySold CurrentMth Less1], 
		   isnull((select SUM(Qty)
				   from (select me.Code
				              , [Transaction].FromMasterItem_id
							  , [Transaction].Date
							  , [Transaction].Type
							  , CASE WHEN [Transaction].Type = 'PICK' THEN [Transaction].ActionQty ELSE -[Transaction].ActionQty END as Qty
							  , DATEFROMPARTS(YEAR([Transaction].Date), month([Transaction].Date), '01') as TransMonth
							  , DATEADD(MONTH, DATEDIFF(month, 0, GETDATE()) -2, 0) as CalculatedMonth 
						 from [$(GraniteDatabase)].dbo.[Transaction] with (nolock)
						 inner join [$(GraniteDatabase)].dbo.MasterItem me with (nolock) on [Transaction].FromMasterItem_id = me.ID
						 where [Transaction].FromMasterItem_id = TrackingEntity.MasterItem_id 
						   and [Transaction].Type IN ('PICK', 'UNPICK') 
						   and DATEFROMPARTS(year([Transaction].Date), month([Transaction].Date), '01') = DATEFROMPARTS(year(DATEADD(month, -2, getdate())), month(DATEADD(month, -2, getdate())), '01')
						) TSQL
				group by Code),0.00) as [QtySold CurrentMth Less2]
	FROM [$(GraniteDatabase)].dbo.TrackingEntity with (nolock) 
	INNER JOIN [$(GraniteDatabase)].dbo.MasterItem with (nolock) ON TrackingEntity.MasterItem_id = MasterItem.ID 
	INNER JOIN [$(GraniteDatabase)].dbo.Location with (nolock) ON TrackingEntity.Location_id = Location.ID and Location.NonStock = 0 
	WHERE TrackingEntity.ExpiryDate IS NOT NULL
	  AND DATEDIFF(MM, GETDATE(), TrackingEntity.ExpiryDate) < @ExpiryMonths
	  AND TrackingEntity.InStock = 1
	  AND TrackingEntity.Qty > 0
	ORDER BY TrackingEntity.ExpiryDate


END
GO