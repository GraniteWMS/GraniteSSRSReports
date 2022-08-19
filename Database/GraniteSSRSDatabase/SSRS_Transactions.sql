-- Description:	List all transactions within date range, user list, type list, processlist, documenttype list, documentnumber list, Code / Batch / Serial 
CREATE OR ALTER PROCEDURE [dbo].[SSRS_Transactions] 
	 @StartDate datetime
	,@EndDate datetime
	,@UserID varchar(max)				--- if not used, pass '*' as default

	,@TransactionType varchar(max)		--- if not used, pass '*' as default
	,@TransactionProcess varchar(max)   --- if not used, pass '*' as default

	,@DocumentType varchar(max)         --- if not used, pass '*' as default  
	,@DocumentID varchar(max)			--- if not used, pass '*' as default 

	,@Barcode varchar(100)              --- if not used, pass '*' as default 	
	,@Pallet varchar(100)               --- if not used, pass '*' as default 	
	,@Code varchar(250)					--- if not used, pass '*' as default 
	,@Batch varchar(100)				--- if not used, pass '*' as default 
	,@SerialNumber varchar(100)			--- if not used, pass '*' as default 

AS

-- exec [SSRS_Transactions] '2021-10-20', '2022-06-20', '*', '*', '*', '*', '*', '*', '*', '*', '*', '*'

BEGIN

	SET NOCOUNT ON;

	SELECT @EndDate = DATEADD(d,1,@EndDate)  

	SELECT CONVERT(DATE,Trans.Date,23) TransDate
         , Trans.[Date] 
         , FromTrackingEntity.Barcode AS FromBarcode 
         , FromTrackingEntity.Batch AS FromBatch 
         , FromTrackingEntity.SerialNumber AS FromSerialNumber 
		 , CASE WHEN ISNULL(FromTrackingEntity.ExpiryDate,'') = '' THEN '' ELSE CONVERT(varchar,FromTrackingEntity.ExpiryDate,111) END AS FromExpiryDate
		 , FromPallet.Barcode AS FromPallet 
         , FromMaster.Code AS FromCode 
         , FromMaster.Description AS FromDescription 

         , ToTrackingEntity.Barcode AS ToBarcode 
         , ToTrackingEntity.Batch AS ToBatch 
         , ToTrackingEntity.SerialNumber AS ToSerialNumber 
		 , CASE WHEN ISNULL(ToTrackingEntity.ExpiryDate,'') = '' THEN '' ELSE CONVERT(varchar,ToTrackingEntity.ExpiryDate,111) END AS ToExpiryDate
         , ToPallet.Barcode AS ToPallet
         , ToMaster.Code AS ToCode 
         , ToMaster.Description AS ToDescription 

		 , FromLocation.Site AS FromSite
		 , FromLocation.ERPLocation FromERP 
         , FromLocation.Name AS FromLocationName
         , FromLocation.Barcode AS FromLocation
		 , ToLocation.Site AS ToSite
		 , ToLocation.ERPLocation ToERP 
         , ToLocation.Name AS ToLocationName 
		 , ToLocation.Barcode AS ToLocation 
         , Trans.FromQty
         , Trans.ToQty
         , Trans.ActionQty
         , Document.Number AS Document 
		 , DocumentDetail.LineNumber 
         , Trans.DocumentReference
         , Trans.Comment
         , Trans.Type AS Type
         , Trans.Process
         , Users.Name AS [User]
         , Trans.IntegrationDate
         , Trans.IntegrationStatus
         , Trans.IntegrationReference
         , Trans.ID
	FROM (
	      SELECT ID
	            ,[Date]
				,FromQty
				,ToQty
				,ActionQty
				,UOM
				,UOMConversion
				,DocumentReference
				,Comment
				,IntegrationStatus
				,IntegrationDate
				,IntegrationReference
				,TrackingEntity_id
				,ContainableEntity_id
				,FromTrackingEntity_id 
				,[User_id]
				,FromLocation_id 
				,ToLocation_id
				,FromMasterItem_id
				,ToMasterItem_id
				,Document_id
				,DocumentLine_id
				,Type
				,CASE WHEN ISNULL(Process,'') = '' 
		              THEN [Type] 
				      ELSE Process END AS Process
				,ReversalTransaction_id
	      FROM [$(GraniteDatabase)].dbo.[Transaction] with (nolock) 
		  WHERE   ([Date] BETWEEN @StartDate AND @EndDate)
			  AND (   @UserID = '*' 
				   OR CONVERT(varchar,[User_id]) in (select Item from fn_SSRS_ParameterSplit(@UserID,',')))

			  AND (   @TransactionType = '*' 
				   OR [Type] in (select Item from fn_SSRS_ParameterSplit(@TransactionType,',')))
			  AND (   @TransactionProcess = '*' 
				   OR ISNULL(Process,[Type]) in (select Item from fn_SSRS_ParameterSplit(@TransactionProcess,',')))
			  AND (   @DocumentID = '*' 
				   OR CONVERT(varchar,[Document_id]) in (select Item from fn_SSRS_ParameterSplit(@DocumentID,',')))
			  AND (   @Barcode = '*' 
				   OR TrackingEntity_id in (select ID from [$(GraniteDatabase)].dbo.TrackingEntity 
				                            where Barcode in (select Item from fn_SSRS_ParameterSplit(@Barcode,','))))
			  AND (   @Pallet = '*' 
				   OR TrackingEntity_id in (select ID from [$(GraniteDatabase)].dbo.TrackingEntity 
				                            where BelongsToEntity_id in (select ID from [$(GraniteDatabase)].dbo.CarryingEntity
				                                                         where Barcode in (select Item from fn_SSRS_ParameterSplit(@Pallet,',')))))
			  AND (   @Batch = '*' 
				   OR TrackingEntity_id in (select ID from [$(GraniteDatabase)].dbo.TrackingEntity 
				                            where Batch in (select Item from fn_SSRS_ParameterSplit(@Batch,','))))
			  AND (   @SerialNumber = '*' 
				   OR TrackingEntity_id in (select ID from [$(GraniteDatabase)].dbo.TrackingEntity 
				                            where SerialNumber in (select Item from fn_SSRS_ParameterSplit(@SerialNumber,','))))
			  AND (   @Code = '*' 
				   OR TrackingEntity_id in (select ID from [$(GraniteDatabase)].dbo.TrackingEntity 
				                            where MasterItem_id in (select ID from [$(GraniteDatabase)].dbo.MasterItem 
				                                                    where Code in (select Item from fn_SSRS_ParameterSplit(@Code,',')))))
		  ) Trans 
	LEFT OUTER JOIN [$(GraniteDatabase)].dbo.[TrackingEntity] FromTrackingEntity with (nolock) ON FromTrackingEntity.ID = Trans.FromTrackingEntity_id 
	LEFT OUTER JOIN [$(GraniteDatabase)].dbo.[CarryingEntity] FromPallet with (nolock) ON FromPallet.ID = FromTrackingEntity.BelongsToEntity_id 
	LEFT OUTER JOIN [$(GraniteDatabase)].dbo.[MasterItem] FromMaster with (nolock) ON FromMaster.ID = FromTrackingEntity.MasterItem_id 
	LEFT OUTER JOIN [$(GraniteDatabase)].dbo.[TrackingEntity] ToTrackingEntity with (nolock) ON ToTrackingEntity.ID = Trans.TrackingEntity_id 
	LEFT OUTER JOIN [$(GraniteDatabase)].dbo.[CarryingEntity] ToPallet with (nolock) ON ToTrackingEntity.BelongsToEntity_id = ToPallet.ID 
	LEFT OUTER JOIN [$(GraniteDatabase)].dbo.[MasterItem] ToMaster with (nolock) ON ToMaster.ID = ToTrackingEntity.MasterItem_id 

	LEFT OUTER JOIN [$(GraniteDatabase)].dbo.[Location] AS FromLocation with (nolock) ON FromLocation.ID = Trans.FromLocation_id 
	LEFT OUTER JOIN [$(GraniteDatabase)].dbo.[Location] AS ToLocation with (nolock) ON ToLocation.ID = Trans.ToLocation_id 
	LEFT OUTER JOIN [$(GraniteDatabase)].dbo.[Users] with (nolock) ON Trans.User_id = Users.ID 
	LEFT OUTER JOIN [$(GraniteDatabase)].dbo.[DocumentDetail] with (nolock) ON DocumentDetail.ID = Trans.DocumentLine_id AND DocumentDetail.Document_id = Trans.Document_id
	LEFT OUTER JOIN [$(GraniteDatabase)].dbo.[Document] with (nolock) ON Document.ID = DocumentDetail.Document_id 
	 
	ORDER BY Trans.Date, Trans.ID 

END
GO