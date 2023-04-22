SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Joey
-- Create date: 05/27/2022
-- Modified dt: 06/13/2022
-- Description:	Adds a new payment
-- =============================================
CREATE   PROCEDURE [dbo].[AddNewPayment]
@PaymentID bigint,
@CustomerID int,
@CustomerFirstName nvarchar(250),
@CustomerLastName nvarchar(250),
@CustomerCompany nvarchar(250),
@ReferenceID int,
@Status nvarchar(64),
@RecurringScheduleID bigint,
@PaymentType nvarchar(32),
@PaymentSubtype nvarchar(32),
@ProviderAuthCode nvarchar(256),
@TraceNumber nvarchar(64),
@PaymentDate datetime,
@ReturnDate datetime,
@EstimatedSettleDate datetime,
@ActualSettledDate datetime,
@CanVoidUntil datetime,
@ErrorCode int,
@ErrorDescription nvarchar(120),
@MerchantActionText nvarchar(250),
@IsDecline bit,
@AccountID int,
@InvoiceID bigint,
@Amount money,
@IsDebit bit,
@InvoiceNumber nvarchar(64),
@OrderID nvarchar(64),
@Description nvarchar(max),
@Latitude nvarchar(64),
@Longitude nvarchar(64),
@LastModified datetime,
@CreatedOn datetime
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRANSACTION;

	-- customer
	UPDATE [dbo].PSCustomers WITH (UPDLOCK, SERIALIZABLE)
	SET PSFirstName = @CustomerFirstName,
		PSLastName = @CustomerLastName,
		PSCompany = @CustomerCompany
	WHERE PSCustomerID = @CustomerID;

	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO [dbo].PSCustomers (PSCustomerID, PSFirstName, PSLastName, PSCompany)
		VALUES (@CustomerID, @CustomerFirstName, @CustomerLastName, @CustomerCompany);
	END

	-- payment
	UPDATE [dbo].PSPayments WITH (UPDLOCK, SERIALIZABLE)
	SET PSCustomerID = @CustomerID,
		PSAccountID = @AccountID,
		PSAmount = @Amount,
		PSIsDebit = @IsDebit,
		PSReferenceID = @ReferenceID,
		PSLatitude = @Latitude,
		PSLongitude = @Longitude,
		PSStatus = @Status,
		PSRecurringScheduleID = @RecurringScheduleID,
		PSPaymentType = @PaymentType,
		PSPaymentSubtype = @PaymentSubtype,
		PSProviderAuthCode = @ProviderAuthCode,
		PSTraceNumber = @TraceNumber,
		PSPaymentDate = @PaymentDate,
		PSReturnDate = @ReturnDate,
		PSEstimatedSettleDate = @EstimatedSettleDate,
		PSActualSettledDate = @ActualSettledDate,
		PSCanVoidUntil = @CanVoidUntil,
		PSInvoiceID = @InvoiceID,
		PSInvoiceNumber = @InvoiceNumber,
		PSOrderID = @OrderID,
		PSDescription = @Description,
		PSLastModified = @LastModified,
		PSCreatedOn = @CreatedOn,
		PSErrorCode = @ErrorCode,
		PSErrorDescription = @ErrorDescription,
		PSMerchantActionText = @MerchantActionText,
		PSIsDecline = @IsDecline
	WHERE PSPaymentID = @PaymentID;

	IF @@ROWCOUNT = 0
	BEGIN 
		INSERT INTO [dbo].PSPayments (
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
			PSErrorCode,
			PSErrorDescription,
			PSMerchantActionText,
			PSIsDecline
		) VALUES (
			@PaymentID,
			@CustomerID,
			@AccountID,
			@Amount,
			@IsDebit,
			@ReferenceID,
			@Latitude,
			@Longitude,
			@Status,
			@RecurringScheduleID,
			@PaymentType,
			@PaymentSubtype,
			@ProviderAuthCode,
			@TraceNumber,
			@PaymentDate,
			@ReturnDate,
			@EstimatedSettleDate,
			@ActualSettledDate,
			@CanVoidUntil,
			@InvoiceID,
			@InvoiceNumber,
			@OrderID,
			@Description,
			@LastModified,
			@CreatedOn,
			@ErrorCode,
			@ErrorDescription,
			@MerchantActionText,
			@IsDecline
		);
	END 
	
	COMMIT TRANSACTION;
END
GO
