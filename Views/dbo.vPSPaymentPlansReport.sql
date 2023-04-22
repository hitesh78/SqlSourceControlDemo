SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Joey
-- Create date: 06/20/2022
-- Modified dt: 06/21/2022
-- Description:	Payment Report, based on vPS_API_PaymentPlans 
-- =============================================
CREATE   VIEW [dbo].[vPSPaymentPlansReport] AS

with InstallmentStatus
(
	RecurringScheduleId,
	PaymentsSettledAmount,
	PaymentsSettledCount,
	PaymentsFailedAmount,
	PaymentsFailedCount,
	PaymentsReversedAmount,
	PaymentReversedCount,
	LastPaymentUpdate,
	LastPaymentStatus
) as (
	select 
		p.PSRecurringScheduleID,
		SUM(case when p.PSStatus = 'Settled' then PSAmount else 0 end),
		SUM(case when p.PSStatus = 'Settled' then 1 else 0 end),
		SUM(case when p.PSStatus = 'Failed' or p.PSStatus = 'Returned' then PSAmount else 0 end),
		SUM(case when p.PSStatus = 'Failed' or p.PSStatus = 'Returned' then 1 else 0 end),
		SUM(case when p.PSStatus = 'Voided' or p.PSStatus = 'Reversed' then PSAmount else 0 end),
		SUM(case when p.PSStatus = 'Voided' or p.PSStatus = 'Reversed' then 1 else 0 end),
		MAX(p.PSLastModified),
		MAX(p.PSStatus)
	from PSPayments p
	where p.PSRecurringScheduleID > 0
	group by p.PSRecurringScheduleID
)
select
	CASE
		WHEN isnull(rp.FirstPaymentDate, '') <> ''
		THEN rp.FirstPaymentDate
		ELSE rp.StartDate
	END as StartDate,
	CASE isnull(session_context(N'AdminLanguage'), N'English')
		WHEN N'Chinese'
		THEN RTRIM(LTRIM(ISNULL(rp.CustomerLastName, N''))) + RTRIM(LTRIM(ISNULL(rp.CustomerFirstName, N'')))
		ELSE RTRIM(LTRIM(ISNULL(rp.CustomerLastName, N''))) + RTRIM(LTRIM(ISNULL(N', ' + rp.CustomerFirstName, N''))) 
	END as PayerName,
	s.glname as StudentName,
	REPLACE(SUBSTRING(rp.[Description], 1, 
		CASE CHARINDEX('Payer''s purpose:', rp.[Description]) 
			WHEN 0 
			THEN LEN(rp.[Description]) 
			ELSE CHARINDEX('Payer''s purpose:', rp.[Description]) - 2 
		END), 'are authorizing','have authorized') as [Description],
	RTRIM(LTRIM(SUBSTRING(rp.[Description], 
		CASE CHARINDEX('Payer''s purpose:', rp.[Description])
			WHEN 0 
			THEN LEN(rp.[Description]) + 16
			ELSE CHARINDEX('Payer''s purpose:', rp.[Description]) + 16
		END, 2048))) as Purpose,
	a.AccountType as PayBy,
	right(a.AccountNoLast4,8) as Account,
	CASE 
		WHEN rp.TotalNumberOfPayments = 1 
		THEN IIF(rp.FirstPaymentDate IS NULL, 'Single Payment', 'Two Payments')
		ELSE IIF(rp.ExecutionFrequencyType = 'LastofMonth', 'Monthly, on last day', '') + 
				IIF(rp.ExecutionFrequencyType = 'SpecificDayofMonth', 'Monthly, on day ' + 
					CAST(rp.ExecutionFrequencyParameter as nvarchar(10)), '')			
	END as Frequency,
	IIF(rp.ScheduleStatus = 'Expired', 'Concluded', rp.ScheduleStatus) as ScheduleStatus,
	ins.LastPaymentUpdate as LastPayUpdate,
	ins.LastPaymentStatus as LastPayStat,
	rp.TotalDueAmount as Total,
	rp.TotalNumberOfPayments + IIF(rp.FirstPaymentDate IS NOT NULL, 1, 0) as NumberPayments,
	rp.TotalAmountPaid as Submitted,
	rp.NumberOfPaymentsMade + IIF(rp.FirstPaymentDone = 1, 1, 0) as NumberSubmitted,
	ins.PaymentsSettledAmount as Settled,
	isnull(ins.PaymentsSettledCount, 0) as NumberSettled,
	ins.PaymentsFailedAmount as Failed,
	isnull(ins.PaymentsFailedCount, 0) as NumberFailed,
	ins.PaymentsReversedAmount as Reversed,
	isnull(ins.PaymentReversedCount, 0) as NumberReversed,
	rp.TotalDueAmount - rp.TotalAmountPaid as Remaining,
	rp.NumberOfPaymentsRemaining + (IIF(rp.FirstPaymentDate IS NOT NULL, 1, 0) - IIF(rp.FirstPaymentDone = 1, 1, 0)) as NumberRemaining,
	rp.PaymentAmount as Payment,
	nullif(rp.FirstPaymentAmount, 0.00) as [1stPay],
	rp.PaymentPlanID as PlanId,
	rp.PauseUntilDate as PauseUntil,
	rp.NextScheduleDate,
	isnull(rp.DateOfLastPaymentMade, rp.FirstPaymentDate) as LastPmntMade,
	isnull(IIF((DATEDIFF(SECOND, rp.LastModified, ins.LastPaymentUpdate) > 0), rp.LastModified, ins.LastPaymentUpdate), rp.LastModified) as LastModified,
	a.PaymentType,
	a.CustomerID,
	a.AccountID,
	c.StudentID,
	c.FamilyID as OrigFamilyID,
	c.GLFamilyInfo as OrigFamilyInfo,
	CASE
		WHEN ScheduleStatus <> 'Deleted' and FirstPaymentDone = 'false' and NumberOfPaymentsMade = 0 and isnull(PaymentsFailedCount,0) = 0 
		THEN 1 
		ELSE 0 
	END as showDeleteButton,
	CASE
		WHEN ScheduleStatus = 'Active' and (select AutoPayAllowSuspend from settings) = 1
		THEN 1 
		ELSE 0 
	END as showSuspendButton,
	CASE 
		WHEN ScheduleStatus = 'Suspended' 
		THEN 1 
		ELSE 0 
	END as showResumeButton,
	(
		select 
			isnull(IIF((DATEDIFF(SECOND, lpus.LastModified, GETUTCDATE()) <= 15), 1, 0), 0)
		from (
			SELECT MAX(psrp.LastModified) as LastModified 
			FROM PSRecurringPayments psrp 
			WHERE psrp.CustomerID = rp.CustomerId
		) lpus
	) as showAsNewlyCreated,
	isnull(
		IIF((rp.ScheduleStatus = 'Deleted' and DATEDIFF(MINUTE, rp.LastModified, GETUTCDATE()) > 3), 1, 0 ) + 
			IIF((rp.ScheduleStatus in ('Expired','Concluded') and DATEDIFF(DAY, rp.LastModified, GETUTCDATE()) > 31), 1, 0)
	, 0) as showAsHistoryOnly
from PSRecurringPayments rp
	inner join PSCustomers c
		on c.PSCustomerID = rp.CustomerId
	inner join PSPaymentPlans pp
		on pp.PSPaymentPlanId = rp.PaymentPlanID
	left join (
		SELECT
			'ACH' as PaymentType,
			PSCustomerID as CustomerID, 
			PSACHAccountID as AccountID, 
			PSACHBankAccountNumber as AccountNoLast4,
			CASE 
				WHEN PSACHAccountTypeID = 1 
				THEN 'Checking' 
				ELSE 'Savings' 
			END as AccountType
		FROM PSACHAccounts
		UNION
		select
			'CC' as PaymentType,
			PSCustomerID as CustomerID,
			PSCCAccountID as AccountID,
			PSCCNumber as AccountNoLast4,
			PSCCTypeID as AccountType
		from PSCCAccounts
	) a
		on a.AccountID = rp.AccountId
	left join InstallmentStatus ins
		on rp.PaymentPlanID = ins.RecurringScheduleId
	left join Students s
		on s.StudentID = c.StudentID


GO
