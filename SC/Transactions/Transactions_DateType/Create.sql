:setvar root "\Process\AssignPickerProcess\Scripts"

USE [$(GraniteDatabase)]
GO

:r $(path)$(root)\SSRS_ParameterSplit.sql
:r $(path)$(root)\SSRS_TransactionsDateType_Data.sql
:r $(path)$(root)\SSRS_TransactionsDateType_GetTransactionType.sql