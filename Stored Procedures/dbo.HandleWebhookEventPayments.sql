SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Joey
-- Create date: 03/29/2022
-- Modified dt: 09/19/2022
-- Description:	adds payment_returned 
-- =============================================
CREATE   PROCEDURE [dbo].[HandleWebhookEventPayments]
@EventLogID bigint,
@EventType nvarchar(50),
@CreatedAt datetime,
@PaymentID int,					-- Uniquely identifies the Payment associated with the event.
@CustomerID int,				-- Uniquely identifies the Customer associated with the event.
@AccountID int,					-- Uniquely identifies the Customer payment method associated with the event.
@PaymentStatus nvarchar(50),	-- Indicates the current state of the Payment object. Valid values: authorized,chargeback,failed,pending,posted,refund_settled,returned,reversed,reverse_n_s_f,reverse_posted,settled,voided
@Amount money,					-- Payment amount in US dollars.
@PaymentType nvarchar(50),		-- Type of payment: credit_card or ach.
@PaymentSource nvarchar(50),	-- PaySimple module where payment originated. Valid values: process_one_time, recurring_payment, payment_plan, payment_store, buyer_portal, api3, api4, ios, android, batch_upload, online_store, subscription, virtual_terminal, payment_form_store, order_details, embeddable, ios_pos, android_pos.
@EstimatedDepositDate datetime,	-- Estimated date the funds will be deposited in merchant's bank account.
@FailureCode int,				-- Code associated with failure(see[Payment Failure / Decline Codes])(ref:payment-failure-codes)
@FailureReason nvarchar(max),	-- Message associated with failure(see[Payment Failure / Decline Codes])(ref:payment-failure-codes)
@IsDecline bit,					-- Indicates if the payment request was declined or failed for another reason.
@SettlementBatchID nvarchar(100),--settlement batch id
@RefundPaymentID int			-- Uniquely identifies the Refund Payment associated with the event.
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRANSACTION;

	DECLARE @glStatus nvarchar(20);
	DECLARE @glNotes nvarchar(100);

	DECLARE @modifiedDt datetime = GETUTCDATE();
	DECLARE @paymentDate date = CONVERT(date, @CreatedAt);

	IF @EventType = 'payment_refunded'
	BEGIN
		-- Sent when payment is refunded or a standalone credit card credit is issued. 
		-- For standalone credit card credits, payment_id will be 0.
		-- we need to insert refund by refund_payment_id if it doesn't already exist
		-- the new payment refund uses the RefundPaymentID

		-- upsert new refund payment
		UPDATE [dbo].PSPayments WITH (UPDLOCK, SERIALIZABLE)
		SET PSCreatedOn = @CreatedAt,
			PSPaymentDate = ISNULL(PSPaymentDate, @paymentDate), -- use set date before calculated date
			PSCustomerID = @CustomerID,
			PSAccountID = COALESCE(@AccountID, PSAccountID, 0),
			PSStatus = @PaymentStatus,
			PSAmount = COALESCE(@Amount, PSAmount, 0), -- TBD may need to * -1
			PSPaymentType = ISNULL(@PaymentType, PSPaymentType),
			PaymentSource = ISNULL(@PaymentSource, PaymentSource),
			PSEstimatedSettleDate = ISNULL(@EstimatedDepositDate, PSEstimatedSettleDate),
			PSErrorCode = ISNULL(@FailureCode, PSErrorCode),
			PSErrorDescription = ISNULL(@FailureReason, PSErrorDescription),
			PSIsDecline = ISNULL(@IsDecline, PSIsDecline),
			SettlementBatchID = ISNULL(@SettlementBatchID, SettlementBatchID),
			CurrentEventType = @EventType,
			PSLastModified = @modifiedDt,
			PSReferenceID = @PaymentID,
			@glStatus = 'OK', 
			@glNotes = 'Updated'
		WHERE PSPaymentID = @RefundPaymentID;

		IF @@ROWCOUNT = 0
		BEGIN TRY
			INSERT INTO [dbo].PSPayments (
				PSPaymentID, 
				PSCustomerID, 
				PSAccountID, 
				PSAmount, 
				PSStatus, 
				PSPaymentType, 
				PSPaymentDate,
				PSEstimatedSettleDate,
				PSLastModified, 
				PSCreatedOn, 
				CurrentEventType, 
				PaymentSource,
				SettlementBatchID,
				PSReferenceID
			) VALUES (
				@RefundPaymentID, 
				@CustomerID, 
				ISNULL(@AccountID, 0), 
				ISNULL(@Amount, 0),  -- TBD may need to * -1
				@PaymentStatus, 
				@PaymentType, 
				@paymentDate,
				@EstimatedDepositDate,
				@modifiedDt, 
				@CreatedAt, 
				@EventType, 
				@PaymentSource,
				@SettlementBatchID,
				@PaymentID
			);
			SELECT @glStatus = 'OK', @glNotes = 'Inserted';
		END TRY
		BEGIN CATCH
			SELECT @glStatus = 'SKIP', @glNotes = 'Failed to insert';
		END CATCH
		-- update the status on the original payment when ID is not 0
		IF @PaymentID <> 0
		BEGIN
			UPDATE [dbo].PSPayments
			SET PSStatus = 'Reversed',
				PSReferenceID = @RefundPaymentID,
				PSLastModified = @modifiedDt,
				CurrentEventType = @EventType
			WHERE PSPaymentID = @PaymentID;
		END
	END
	ELSE IF @EventType = 'payment_returned' -- only update, not enough for insert
	BEGIN
		UPDATE [dbo].PSPayments WITH (UPDLOCK, SERIALIZABLE)
		SET PSCreatedOn = @CreatedAt,
			PSCustomerID = @CustomerID,
			PSStatus = @PaymentStatus,
			PSErrorDescription = ISNULL(@FailureReason, PSErrorDescription),
			CurrentEventType = @EventType,
			PSLastModified = @modifiedDt,
			@glStatus = 'OK', 
			@glNotes = 'Updated'
		WHERE PSPaymentID = @PaymentID;

		IF @@ROWCOUNT = 0
		BEGIN
			SELECT @glStatus = 'FAIL', @glNotes = 'Failed to update';
		END
	END
	ELSE -- for all other events
	BEGIN
		UPDATE [dbo].PSPayments WITH (UPDLOCK, SERIALIZABLE)
		SET PSCreatedOn = @CreatedAt,
			PSPaymentDate = ISNULL(PSPaymentDate, @paymentDate), -- use set date before calculated date
			PSCustomerID = @CustomerID,
			PSAccountID = COALESCE(@AccountID, PSAccountID, 0),
			PSStatus = @PaymentStatus,
			PSAmount = COALESCE(@Amount, PSAmount, 0),
			PSPaymentType = ISNULL(@PaymentType, PSPaymentType),
			PaymentSource = ISNULL(@PaymentSource, PaymentSource),
			PSEstimatedSettleDate = ISNULL(@EstimatedDepositDate, PSEstimatedSettleDate),
			PSActualSettledDate = IIF(@EventType = 'payment_settled', @CreatedAt, null),
			PSErrorCode = ISNULL(@FailureCode, PSErrorCode),
			PSErrorDescription = ISNULL(@FailureReason, PSErrorDescription),
			PSIsDecline = ISNULL(@IsDecline, PSIsDecline),
			SettlementBatchID = ISNULL(@SettlementBatchID, SettlementBatchID),
			CurrentEventType = @EventType,
			PSLastModified = @modifiedDt,
			@glStatus = 'OK', 
			@glNotes = 'Updated'
		WHERE PSPaymentID = @PaymentID
			AND @CreatedAt >= PSCreatedOn;

		IF @@ROWCOUNT = 0
		BEGIN TRY
			INSERT INTO [dbo].PSPayments (
				PSPaymentID, 
				PSCustomerID, 
				PSAccountID, 
				PSAmount, 
				PSStatus, 
				PSPaymentType, 
				PSPaymentDate,
				PSEstimatedSettleDate, 
				PSActualSettledDate,
				PSLastModified, 
				PSCreatedOn, 
				CurrentEventType,
				PaymentSource,
				SettlementBatchID
			) VALUES (
				@PaymentID, 
				@CustomerID, 
				ISNULL(@AccountID, 0), 
				ISNULL(@Amount, 0), 
				@PaymentStatus, 
				@PaymentType, 
				@paymentDate,
				@EstimatedDepositDate, 
				IIF(@EventType = 'payment_settled', @CreatedAt, null),
				@modifiedDt, 
				@CreatedAt, 
				@EventType, 
				@PaymentSource,
				@SettlementBatchID
			);
			SELECT @glStatus = 'OK', @glNotes = 'Inserted';
		END TRY
		BEGIN CATCH
			SELECT @glStatus = 'SKIP', @glNotes = 'Failed to insert';
		END CATCH
	END

	UPDATE [LKG].[dbo].WebhookEventLogPaySimple WITH (UPDLOCK, SERIALIZABLE)
	SET glStatus = ISNULL(@glStatus, 'Error'),
		ModifiedUtc = @modifiedDt,
		glInfo = (
			SELECT DB_NAME() as [db], 
			IIF(@EventType = 'payment_refunded', @RefundPaymentID, @PaymentID) as [paymentId], 
			COALESCE(@glNotes, @glStatus, '') as [notes] 
			FOR JSON PATH)
	WHERE ID = @EventLogID;

	COMMIT TRANSACTION;

END
GO
