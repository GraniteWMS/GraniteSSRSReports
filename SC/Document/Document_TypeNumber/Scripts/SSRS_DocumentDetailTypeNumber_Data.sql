CREATE PROCEDURE [dbo].[SSRS_DocumentDetailTypeNumber_Data] 
	-- Add the parameters for the stored procedure here
	@Type varchar(MAX),
	@Number varchar(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF ISNULL(@Number,'')  = ''
	BEGIN
		SELECT dbo.[Document].Number, dbo.[Document].TradingPartnerDescription, dbo.DocumentDetail.ID AS OrderDetailId, dbo.DocumentDetail.LineNumber,
			   dbo.MasterItem.Code, dbo.MasterItem.Description, dbo.DocumentDetail.Qty, dbo.DocumentDetail.Qty - ISNULL(dbo.DocumentDetail.ActionQty, 0) AS Outstanding,
			   ISNULL(Tracking.OnHand, 0) AS QtyOnHand, ISNULL(PickSlip.PickedQty, 0) AS PickedQty, ISNULL(PickSlip.PickslipQty, 0) AS PickSlipQty, dbo.[Document].Status,
			   dbo.[Document].Type AS Type, dbo.[Document].Site
		FROM dbo.[Document] 
			INNER JOIN dbo.DocumentDetail ON dbo.[Document].ID = dbo.DocumentDetail.Document_id 
			INNER JOIN dbo.MasterItem ON dbo.DocumentDetail.Item_id = dbo.MasterItem.ID 
			LEFT OUTER JOIN (SELECT DISTINCT LinkedDetail_id, SUM(Qty) AS PickslipQty, SUM(ActionQty) AS PickedQty
							 FROM dbo.DocumentDetail AS DocumentDetail_1
							 GROUP BY LinkedDetail_id) AS PickSlip ON dbo.DocumentDetail.ID = PickSlip.LinkedDetail_id 
			LEFT OUTER JOIN (SELECT DISTINCT dbo.TrackingEntity.MasterItem_id, ISNULL(SUM(dbo.TrackingEntity.Qty), 0) AS OnHand
							 FROM dbo.TrackingEntity 
								LEFT OUTER JOIN dbo.MasterItem AS MasterItem_1 ON dbo.TrackingEntity.MasterItem_id = MasterItem_1.ID
							 WHERE (dbo.TrackingEntity.InStock = 1)
							 GROUP BY dbo.TrackingEntity.MasterItem_id) AS Tracking ON dbo.DocumentDetail.Item_id = Tracking.MasterItem_id 
		WHERE (dbo.[Document].Type IN (SELECT Item FROM dbo.SSRS_ParameterSplit(@Type,',')))
	END
	ELSE
	BEGIN
		SELECT dbo.[Document].Number, dbo.[Document].TradingPartnerDescription, dbo.DocumentDetail.ID AS OrderDetailId, dbo.DocumentDetail.LineNumber,
			   dbo.MasterItem.Code, dbo.MasterItem.Description, dbo.DocumentDetail.Qty, dbo.DocumentDetail.Qty - ISNULL(dbo.DocumentDetail.ActionQty, 0) AS Outstanding,
			   ISNULL(Tracking.OnHand, 0) AS QtyOnHand, ISNULL(PickSlip.PickedQty, 0) AS PickedQty, ISNULL(PickSlip.PickslipQty, 0) AS PickSlipQty, dbo.[Document].Status,
			   dbo.[Document].Type AS Type, dbo.[Document].Site
		FROM dbo.[Document] 
			INNER JOIN dbo.DocumentDetail ON dbo.[Document].ID = dbo.DocumentDetail.Document_id 
			INNER JOIN dbo.MasterItem ON dbo.DocumentDetail.Item_id = dbo.MasterItem.ID 
			LEFT OUTER JOIN (SELECT DISTINCT LinkedDetail_id, SUM(Qty) AS PickslipQty, SUM(ActionQty) AS PickedQty
							 FROM dbo.DocumentDetail AS DocumentDetail_1
							 GROUP BY LinkedDetail_id) AS PickSlip ON dbo.DocumentDetail.ID = PickSlip.LinkedDetail_id 
			LEFT OUTER JOIN (SELECT DISTINCT dbo.TrackingEntity.MasterItem_id, ISNULL(SUM(dbo.TrackingEntity.Qty), 0) AS OnHand
							 FROM dbo.TrackingEntity 
								LEFT OUTER JOIN dbo.MasterItem AS MasterItem_1 ON dbo.TrackingEntity.MasterItem_id = MasterItem_1.ID
							 WHERE (dbo.TrackingEntity.InStock = 1)
							 GROUP BY dbo.TrackingEntity.MasterItem_id) AS Tracking ON dbo.DocumentDetail.Item_id = Tracking.MasterItem_id 
		WHERE (dbo.[Document].Type IN (SELECT Item FROM dbo.SSRS_ParameterSplit(@Type,',')))
		  AND Number = @Number
	END
END
GO


