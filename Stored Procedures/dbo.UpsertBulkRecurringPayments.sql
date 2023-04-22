SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Joey
-- Create date: 07/13/2022
-- Modified dt: 07/13/2022
-- Description:	bulk upsert recurring payment data
-- =============================================
CREATE   PROCEDURE [dbo].[UpsertBulkRecurringPayments]
@PaymentData dbo.PSRecurringPaymentsTableType READONLY
AS
BEGIN
	SET NOCOUNT ON;

	MERGE INTO PSRecurringPayments as _target
	USING @PaymentData as _source
	ON _target.PaymentPlanID = _source.Id
	WHEN MATCHED THEN 
		UPDATE SET
			_target.PaymentPlanID = _source.Id,
			_target.CustomerId = _source.CustomerId,
			_target.CustomerFirstName = _source.CustomerFirstName,
			_target.CustomerLastName = _source.CustomerLastName,
			_target.CustomerCompany = _source.CustomerCompany,
			_target.NextScheduleDate = _source.NextScheduleDate,
			_target.BalanceRemaining = _source.BalanceRemaining,
			_target.NumberOfPaymentsRemaining = _source.NumberOfPaymentsRemaining,
			_target.PauseUntilDate = _source.PauseUntilDate,
			_target.PaymentAmount = _source.PaymentAmount,
			_target.FirstPaymentDone = _source.FirstPaymentDone,
			_target.DateOfLastPaymentMade = _source.DateOfLastPaymentMade,
			_target.TotalAmountPaid = _source.TotalAmountPaid,
			_target.NumberOfPaymentsMade = _source.NumberOfPaymentsMade,
			_target.TotalDueAmount = _source.TotalDueAmount,
			_target.TotalNumberOfPayments = _source.TotalNumberOfPayments,
			_target.PaymentSubType = _source.PaymentSubType,
			_target.AccountId = _source.AccountId,
			_target.InvoiceNumber = _source.InvoiceNumber,
			_target.OrderId = _source.OrderId,
			_target.FirstPaymentAmount = _source.FirstPaymentAmount,
			_target.FirstPaymentDate = _source.FirstPaymentDate,
			_target.StartDate = _source.StartDate,
			_target.ScheduleStatus = _source.ScheduleStatus,
			_target.ExecutionFrequencyType = _source.ExecutionFrequencyType,
			_target.ExecutionFrequencyParameter = _source.ExecutionFrequencyParameter,
			_target.[Description] = _source.[Description],
			_target.LastModified = _source.LastModified,
			_target.CreatedOn = _source.CreatedOn
	WHEN NOT MATCHED THEN
		INSERT (
			PaymentPlanID,
			CustomerId,
			CustomerFirstName,
			CustomerLastName,
			CustomerCompany,
			NextScheduleDate,
			BalanceRemaining,
			NumberOfPaymentsRemaining,
			PauseUntilDate,
			PaymentAmount,
			FirstPaymentDone,
			DateOfLastPaymentMade,
			TotalAmountPaid,
			NumberOfPaymentsMade,
			TotalDueAmount,
			TotalNumberOfPayments,
			PaymentSubType,
			AccountId,
			InvoiceNumber,
			OrderId,
			FirstPaymentAmount,
			FirstPaymentDate,
			StartDate,
			ScheduleStatus,
			ExecutionFrequencyType,
			ExecutionFrequencyParameter,
			[Description],
			LastModified,
			CreatedOn
		) VALUES (
			_source.Id,
			_source.CustomerId,
			_source.CustomerFirstName,
			_source.CustomerLastName,
			_source.CustomerCompany,
			_source.NextScheduleDate,
			_source.BalanceRemaining,
			_source.NumberOfPaymentsRemaining,
			_source.PauseUntilDate,
			_source.PaymentAmount,
			_source.FirstPaymentDone,
			_source.DateOfLastPaymentMade,
			_source.TotalAmountPaid,
			_source.NumberOfPaymentsMade,
			_source.TotalDueAmount,
			_source.TotalNumberOfPayments,
			_source.PaymentSubType,
			_source.AccountId,
			_source.InvoiceNumber,
			_source.OrderId,
			_source.FirstPaymentAmount,
			_source.FirstPaymentDate,
			_source.StartDate,
			_source.ScheduleStatus,
			_source.ExecutionFrequencyType,
			_source.ExecutionFrequencyParameter,
			_source.[Description],
			_source.LastModified,
			_source.CreatedOn
		);

END
GO
