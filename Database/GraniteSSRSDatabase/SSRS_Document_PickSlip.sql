CREATE  PROCEDURE [dbo].[SSRS_Document_PickSlip]
    @DocumentNumber varchar(50)
	
AS 

-- EXEC SSRS_Document_PickSlip '-39124'

BEGIN 

    SET NOCOUNT ON;
    DECLARE @DOCNUMBER varchar(30)
    DECLARE @DOCTYPE varchar(30)
    DECLARE @ORDERNUMBER varchar(30)
    DECLARE @TRADINGPARTNERCODE varchar(20)
    DECLARE @TRADINGPARTNERDESC varchar(60)
	DECLARE @ID bigint
	DECLARE @OUTSTANDINGQTY decimal(19,4)
	DECLARE @TEQTY decimal(19,4)
	DECLARE @ITEMCODE  varchar(50)
	DECLARE @ITEMDESCRIPTION  varchar(100)
	DECLARE @QTYALOCATTED decimal(19,4)
	DECLARE @LINENUMBER varchar(50)

	DECLARE @ReturnTable TABLE 
	(
		 DocumentNumber varchar(30)
		,DocumentType varchar(30)
		,OrderNumber varchar(30)
		,TradingPartnerCode  varchar(20)
		,TradingPartnerDescription varchar(60)
		,LineNumber varchar(50)
		,Code varchar(50)
		,Description varchar (100)
		,Barcode varchar(30)
		,Qty  decimal(19,4)
		,OutstandingQty  decimal(19,4)
		,SerialNumber  varchar(30)
		,CreatedDate DateTime
		,Batch  varchar(50)
		,ExpiryDate  DateTime
		,Site  varchar(30)
		,ERPLocation varchar(15)
		,Location varchar(30)
	)
	
    SET @QTYALOCATTED = 0;
    
    DECLARE header CURSOR FOR
	SELECT  PickSlip.Number
	       ,PickSlip.[Type]
		   ,CASE WHEN OrderHeader.Number IS NULL 
		         THEN PickSlip.Number 
				 ELSE OrderHeader.Number 
				 END as OrderNumber
		   ,CASE WHEN PickSlip.TradingPartnerCode IS NULL 
		         THEN OrderHeader.TradingPartnerCode 
				 ELSE PickSlip.TradingPartnerCode 
				 END AS TradingPartnerCode
		   ,CASE WHEN PickSlip.TradingPartnerDescription IS NULL 
		         THEN OrderHeader.TradingPartnerDescription 
				 ELSE PickSlip.TradingPartnerDescription 
				 END AS TradingPartnerDescription
		   ,MasterItem.Code
		   ,PickSlipDetail.LineNumber 
		   ,PickSlipDetail.Qty
		   ,MasterItem.Description		   
	FROM [$(GraniteDatabase)].dbo.[Document] AS PickSlip with (nolock) 
	INNER JOIN [$(GraniteDatabase)].dbo.[DocumentDetail] AS PickSlipDetail with (nolock) ON PickSlip.ID = PickSlipDetail.Document_id 
	INNER JOIN [$(GraniteDatabase)].dbo.[MasterItem] AS MasterItem with (nolock) ON MasterItem.ID = PickSlipDetail.Item_id  
	LEFT JOIN [$(GraniteDatabase)].dbo.[DocumentDetail] AS OrderDetail with (nolock) ON OrderDetail.ID = PickSlipDetail.LinkedDetail_id 
	LEFT JOIN [$(GraniteDatabase)].dbo.[Document] AS OrderHeader with (nolock) ON OrderDetail.Document_id = OrderHeader.ID 
    WHERE (PickSlipDetail.Completed = 0) 
	   OR (PickSlipDetail.Completed IS NULL)
	GROUP BY PickSlip.Number, PickSlip.[Type], MasterItem.Code, MasterItem.Description, MasterItem.UOM, PickSlipDetail.Comment, 
	         PickSlipDetail.LineNumber, PickSlipDetail.Qty, PickSlipDetail.ActionQty, PickSlipDetail.FromLocation, 
			 PickSlip.TradingPartnerCode, PickSlip.TradingPartnerDescription, 
			 OrderHeader.Number, OrderHeader.TradingPartnerCode, OrderHeader.TradingPartnerDescription
	HAVING ((SUM(PickSlipDetail.Qty) - SUM(ISNULL(PickSlipDetail.ActionQty, 0))) > 0 AND PickSlip.Number = @DocumentNumber)
	OPEN header;

	FETCH NEXT FROM header 
	INTO @DOCNUMBER, @DOCTYPE, @ORDERNUMBER, @TRADINGPARTNERCODE, @TRADINGPARTNERDESC, @ITEMCODE, @LINENUMBER, @OUTSTANDINGQTY, @ITEMDESCRIPTION;
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		DECLARE detail CURSOR FOR
		SELECT [TrackingEntity].ID
		      ,[TrackingEntity].Qty
		FROM [$(GraniteDatabase)].dbo.[Location] with (nolock) 
		INNER JOIN [$(GraniteDatabase)].dbo.[TrackingEntity] with (nolock) ON [Location].ID = [TrackingEntity].Location_id 
		INNER JOIN [$(GraniteDatabase)].dbo.[MasterItem] with (nolock) ON [TrackingEntity].MasterItem_id = [MasterItem].ID
		WHERE ([MasterItem].Code = @ITEMCODE) 
		  AND ([TrackingEntity].InStock = 1) 
		  AND ([TrackingEntity].Qty > 0)
		  AND (ISNULL([TrackingEntity].OnHold,0) = 0) 
		OPEN detail;
		
		FETCH NEXT FROM detail 
		INTO @ID,@TEQTY;
		
		IF @@FETCH_STATUS <> 0 
			BEGIN
				INSERT INTO @ReturnTable 
						( DocumentNumber
						, DocumentType
						, OrderNumber
						, TradingPartnerCode
						, TradingPartnerDescription
						, LineNumber
						, Code
						, Description
						, OutstandingQty
						) 
					values
						( @DOCNUMBER
						, @DOCTYPE
						, @ORDERNUMBER
						, @TRADINGPARTNERCODE
						, @TRADINGPARTNERDESC
						, @LINENUMBER
						, @ITEMCODE
						, @ITEMDESCRIPTION
						, @OUTSTANDINGQTY
						)
			END

		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			IF (@QTYALOCATTED < @OUTSTANDINGQTY) --check if qty fullfil 
			BEGIN

					SET @QTYALOCATTED  = (@QTYALOCATTED + @TEQTY) 
				
					INSERT INTO @ReturnTable 
							( DocumentNumber
							, DocumentType
							, OrderNumber
							, TradingPartnerCode
							, TradingPartnerDescription
							, LineNumber
							, Code
							, Description
							, Barcode
							, Qty
							, SerialNumber
							, CreatedDate
							, Batch
							, ExpiryDate
							, Site
							, ERPLocation
							, Location
							, OutstandingQty
							) 
					SELECT    @DOCNUMBER
							, @DOCTYPE
							, @ORDERNUMBER
							, @TRADINGPARTNERCODE
							, @TRADINGPARTNERDESC
							, @LINENUMBER 
							, [MasterItem].Code
							, [MasterItem].Description
							, [TrackingEntity].Barcode
							, [TrackingEntity].Qty
							, [TrackingEntity].SerialNumber
							, [TrackingEntity].CreatedDate
							, [TrackingEntity].Batch
							, [TrackingEntity].ExpiryDate
							, [Location].Site
							, [Location].ERPLocation
							, [Location].Name AS Location
							, @OUTSTANDINGQTY
					FROM [$(GraniteDatabase)].dbo.[Location] with (nolock) 
					INNER JOIN [$(GraniteDatabase)].dbo.[TrackingEntity] with (nolock) ON [Location].ID = [TrackingEntity].Location_id 
					INNER JOIN [$(GraniteDatabase)].dbo.[MasterItem] with (nolock) ON [TrackingEntity].MasterItem_id = [MasterItem].ID
					WHERE ([TrackingEntity].id = @ID)

			END
		
		FETCH NEXT FROM detail 
		INTO @ID,@TEQTY;
		END --WHILE @@FETCH_STATUS = 0
		
		--reset
		SET @QTYALOCATTED = 0;
		CLOSE detail;
		DEALLOCATE detail;
		
		FETCH NEXT FROM header 
		INTO @DOCNUMBER, @DOCTYPE, @ORDERNUMBER, @TRADINGPARTNERCODE, @TRADINGPARTNERDESC, @ITEMCODE, @LINENUMBER, @OUTSTANDINGQTY, @ITEMDESCRIPTION;
	END

	CLOSE header;
	DEALLOCATE header;
	
	--return
	SELECT * FROM @ReturnTable
--	ORDER BY [Location]

END