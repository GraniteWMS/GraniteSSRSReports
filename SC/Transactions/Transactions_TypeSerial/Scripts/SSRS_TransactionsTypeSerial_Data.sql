CREATE PROCEDURE [dbo].[SSRS_TransactionsTypeSerial_Data] 
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime,
	@Type varchar(MAX), 
	@SerialNo varchar(MAX) 
AS

-- exec SSRS_Transaction_GetReportData '2022/02/05', '2022/04/21', 'RECEIVE', 11 

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT dbo.[Transaction].ID, dbo.TrackingEntity.Barcode, dbo.MasterItem.Code, dbo.MasterItem.Description, dbo.[Transaction].Date, dbo.TrackingEntity.Batch, 
			dbo.TrackingEntity.SerialNumber, dbo.TrackingEntity.ExpiryDate, dbo.[Transaction].FromQty, dbo.[Transaction].ToQty, 
			dbo.[Transaction].ActionQty, dbo.[Transaction].UOM, dbo.[Transaction].Comment, dbo.[Transaction].IntegrationDate,
			dbo.[Transaction].Process, dbo.Users.Name AS [User], dbo.[Transaction].DocumentReference, dbo.[Document].Number AS Document, dbo.[Transaction].IntegrationStatus, 
			dbo.CarryingEntity.Barcode AS Pallet, L1.Name AS FromLocation, L2.Name AS ToLocation, L3.Site, 
			dbo.[Transaction].Type AS Type, dbo.[Transaction].IntegrationReference
	FROM dbo.[Transaction] 
		LEFT OUTER JOIN dbo.TrackingEntity ON dbo.TrackingEntity.ID = dbo.[Transaction].TrackingEntity_id 
		LEFT OUTER JOIN dbo.MasterItem ON dbo.MasterItem.ID = dbo.TrackingEntity.MasterItem_id 
		LEFT OUTER JOIN dbo.CarryingEntity ON dbo.[Transaction].ContainableEntity_id = dbo.CarryingEntity.ID 
		LEFT OUTER JOIN dbo.Location AS L1 ON dbo.[Transaction].FromLocation_id = L1.ID 
		LEFT OUTER JOIN dbo.Location AS L2 ON dbo.[Transaction].ToLocation_id = L2.ID 
		LEFT OUTER JOIN dbo.Location AS L3 ON dbo.TrackingEntity.Location_id = L3.ID 
		LEFT OUTER JOIN dbo.Users ON dbo.[Transaction].User_id = dbo.Users.ID 
		LEFT OUTER JOIN dbo.[Document] ON dbo.[Document].ID = dbo.[Transaction].Document_id
	--WHERE dbo.[Transaction].Type = @Type 
	--  AND dbo.[Transaction].Date BETWEEN @StartDate AND @EndDate
	--  AND dbo.[Transaction].[User_id] = @UserID
	WHERE dbo.[Transaction].Date BETWEEN @StartDate AND @EndDate 
	AND dbo.[Transaction].Type in (select Item from dbo.fn_SSRS_ParameterSplit(@Type,',')) 
	AND CASE WHEN ISNULL(dbo.TrackingEntity.SerialNumber,'') = '' THEN 'BLANK' END in (select Item from dbo.fn_SSRS_ParameterSplit(@SerialNo,',')) 
	

END
GO


