USE [GraniteDatabase]
GO

/****** Object:  StoredProcedure [dbo].[SSRS_Transactions]    Script Date: 2022/06/24 06:29:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:      Alessandro Trevisan
-- Create date: 2022-06-06
-- Description:	List all transactions within date range, user list, type list, processlist, documenttype list, documentnumber list, Code / Batch / Serial 
-- =============================================
CREATE OR ALTER   PROCEDURE [dbo].[SSRS_Transactions] 

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
         , FromTrackingEntity.ExpiryDate AS FromExpiryDate 
		 , FromPallet.Barcode AS FromPallet 
         , FromMaster.Code AS FromCode 
         , FromMaster.Description AS FromDescription 

         , ToTrackingEntity.Barcode AS ToBarcode 
         , ToTrackingEntity.Batch AS ToBatch 
         , ToTrackingEntity.SerialNumber AS ToSerialNumber 
         , ToTrackingEntity.ExpiryDate AS ToExpiryDate 
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
	      FROM [Transaction] with (nolock) 
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
				   OR TrackingEntity_id in (select ID from TrackingEntity 
				                            where Barcode in (select Item from fn_SSRS_ParameterSplit(@Barcode,','))))
			  AND (   @Pallet = '*' 
				   OR TrackingEntity_id in (select ID from TrackingEntity 
				                            where BelongsToEntity_id in (select ID from CarryingEntity
				                                                         where Barcode in (select Item from fn_SSRS_ParameterSplit(@Pallet,',')))))
			  AND (   @Batch = '*' 
				   OR TrackingEntity_id in (select ID from TrackingEntity 
				                            where Batch in (select Item from fn_SSRS_ParameterSplit(@Batch,','))))
			  AND (   @SerialNumber = '*' 
				   OR TrackingEntity_id in (select ID from TrackingEntity 
				                            where SerialNumber in (select Item from fn_SSRS_ParameterSplit(@SerialNumber,','))))
			  AND (   @Code = '*' 
				   OR TrackingEntity_id in (select ID from TrackingEntity 
				                            where MasterItem_id in (select ID from MasterItem 
				                                                    where Code in (select Item from fn_SSRS_ParameterSplit(@Code,',')))))
		  ) Trans 
	LEFT OUTER JOIN [TrackingEntity] FromTrackingEntity with (nolock) ON FromTrackingEntity.ID = Trans.FromTrackingEntity_id 
	LEFT OUTER JOIN [CarryingEntity] FromPallet with (nolock) ON FromPallet.ID = FromTrackingEntity.BelongsToEntity_id 
	LEFT OUTER JOIN [MasterItem] FromMaster with (nolock) ON FromMaster.ID = FromTrackingEntity.MasterItem_id 
	LEFT OUTER JOIN [TrackingEntity] ToTrackingEntity with (nolock) ON ToTrackingEntity.ID = Trans.TrackingEntity_id 
	LEFT OUTER JOIN [CarryingEntity] ToPallet with (nolock) ON ToTrackingEntity.BelongsToEntity_id = ToPallet.ID 
	LEFT OUTER JOIN [MasterItem] ToMaster with (nolock) ON ToMaster.ID = ToTrackingEntity.MasterItem_id 

	LEFT OUTER JOIN [Location] AS FromLocation with (nolock) ON FromLocation.ID = Trans.FromLocation_id 
	LEFT OUTER JOIN [Location] AS ToLocation with (nolock) ON ToLocation.ID = Trans.ToLocation_id 
	LEFT OUTER JOIN [Users] with (nolock) ON Trans.User_id = Users.ID 
	LEFT OUTER JOIN [DocumentDetail] with (nolock) ON DocumentDetail.ID = Trans.DocumentLine_id AND DocumentDetail.Document_id = Trans.Document_id
	LEFT OUTER JOIN [Document] with (nolock) ON Document.ID = DocumentDetail.Document_id 
	 
	ORDER BY Trans.Date, Trans.ID 

END
GO


