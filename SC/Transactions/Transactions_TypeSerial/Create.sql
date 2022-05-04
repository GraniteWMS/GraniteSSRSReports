:setvar root "\Process\AssignPickerProcess\Scripts"

USE [$(GraniteDatabase)]
GO

:r $(path)$(root)\SSRS_ParameterSplit.sql
:r $(path)$(root)\SSRS_TransactionsTypeSerial_Data.sql
:r $(path)$(root)\SSRS_TransactionsTypeSerial_GetSerialNumber.sql
:r $(path)$(root)\SSRS_TransactionsTypeSerial_GetTransactionType.sql