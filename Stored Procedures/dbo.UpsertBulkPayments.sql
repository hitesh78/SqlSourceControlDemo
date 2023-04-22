SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Joey
-- Create date: 07/11/2022
-- Modified dt: 07/11/2022
-- Description:	bulk upsert payment data
-- =============================================
CREATE   PROCEDURE [dbo].[UpsertBulkPayments]
@PaymentData dbo.PSPaymentsTableType READONLY
AS
BEGIN
	SET NOCOUNT ON;

	MERGE INTO PSPayments as _target
	USING @PaymentData as _source
	ON _target.PSPaymentID = _source.PSPaymentID
	WHEN MATCHED THEN 
		UPDATE SET
			_target.PSPaymentID = _source.PSPaymentID,
			_target.PSCustomerID = _source.PSCustomerID,
			_target.PSAccountID = _source.PSAccountID,
			_target.PSAmount = _source.PSAmount,
			_target.PSIsDebit = _source.PSIsDebit,
			_target.PSReferenceID = _source.PSReferenceID,
			_target.PSLatitude = _source.PSLatitude,
			_target.PSLongitude = _source.PSLongitude,
			_target.PSStatus = _source.PSStatus,
			_target.PSRecurringScheduleID = _source.PSRecurringScheduleID,
			_target.PSPaymentType = _source.PSPaymentType,
			_target.PSPaymentSubtype = _source.PSPaymentSubtype,
			_target.PSProviderAuthCode = _source.PSProviderAuthCode,
			_target.PSTraceNumber = _source.PSTraceNumber,
			_target.PSPaymentDate = _source.PSPaymentDate,
			_target.PSReturnDate = _source.PSReturnDate,
			_target.PSEstimatedSettleDate = _source.PSEstimatedSettleDate,
			_target.PSActualSettledDate = _source.PSActualSettledDate,
			_target.PSCanVoidUntil = _source.PSCanVoidUntil,
			_target.PSInvoiceID = _source.PSInvoiceID,
			_target.PSInvoiceNumber = _source.PSInvoiceNumber,
			_target.PSOrderID = _source.PSOrderID,
			_target.PSDescription = _source.PSDescription,
			_target.PSLastModified = _source.PSLastModified,
			_target.PSCreatedOn = _source.PSCreatedOn,
			_target.PSCVV = _source.PSCVV,
			_target.PSErrorCode = _source.PSErrorCode,
			_target.PSErrorDescription = _source.PSErrorDescription,
			_target.PSMerchantActionText = _source.PSMerchantActionText,
			_target.PSIsDecline = _source.PSIsDecline
	WHEN NOT MATCHED THEN
		INSERT (
			PSPaymentID,
			PSCustomerID,
			PSAccountID,
			PSAmount,
			PSIsDebit,
			PSReferenceID,
			PSLatitude,
			PSLongitude,
			PSStatus,
			PSRecurringScheduleID,
			PSPaymentType,
			PSPaymentSubtype,
			PSProviderAuthCode,
			PSTraceNumber,
			PSPaymentDate,
			PSReturnDate,
			PSEstimatedSettleDate,
			PSActualSettledDate,
			PSCanVoidUntil,
			PSInvoiceID,
			PSInvoiceNumber,
			PSOrderID,
			PSDescription,
			PSLastModified,
			PSCreatedOn,
			PSCVV,
			PSErrorCode,
			PSErrorDescription,
			PSMerchantActionText,
			PSIsDecline
		) VALUES (
			_source.PSPaymentID,
			_source.PSCustomerID,
			_source.PSAccountID,
			_source.PSAmount,
			_source.PSIsDebit,
			_source.PSReferenceID,
			_source.PSLatitude,
			_source.PSLongitude,
			_source.PSStatus,
			_source.PSRecurringScheduleID,
			_source.PSPaymentType,
			_source.PSPaymentSubtype,
			_source.PSProviderAuthCode,
			_source.PSTraceNumber,
			_source.PSPaymentDate,
			_source.PSReturnDate,
			_source.PSEstimatedSettleDate,
			_source.PSActualSettledDate,
			_source.PSCanVoidUntil,
			_source.PSInvoiceID,
			_source.PSInvoiceNumber,
			_source.PSOrderID,
			_source.PSDescription,
			_source.PSLastModified,
			_source.PSCreatedOn,
			_source.PSCVV,
			_source.PSErrorCode,
			_source.PSErrorDescription,
			_source.PSMerchantActionText,
			_source.PSIsDecline
		);

END
GO
