SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
NOTE: The field ordering and naming is used to support the default grid formatting on the
      Financial->Payments->AutoPay Plans tab.  So don't make changes here without reviewing
	  the impact on that report...
*/
CREATE VIEW [dbo].[vPS_API_PaymentPlans] as

with LatestPlanUpdatedForStudent
	(StudentID,LastModified) 
as
(
	select StudentID,max(pp.LastModified)
	from PS_API_PaymentPlans pp
	inner join PSCustomers c
	on pp.CustomerId = c.PSCustomerID
	group by c.StudentID
),
LatestUpdated
	(RecurringScheduleId,LastModified,Status) 
as
(
	select RecurringScheduleId,max(LastModified),max(p.Status)
	from PS_API_Payments p
	where RecurringScheduleId>0
	group by RecurringScheduleId
),
InstallmentStatus
(
	RecurringScheduleId,
	PaymentsSettledAmount,
	PaymentsSettledCount,
	PaymentsFailedAmount,
	PaymentsFailedCount,
	PaymentsReversedAmount, -- refunded or voided (not we don't know if 'refund completed' for sure as PS creates 
	PaymentReversedCount,
	LastPaymentUpdate,
	LastPaymentStatus
)
as
(
	select 
		p.RecurringScheduleId,

		SUM(CAST(case when p.Status='Settled' then Amount else '0.00' end as Money)),
		SUM(case when p.Status='Settled' then 1 else 0 end),

		SUM(CAST(case when p.Status='Failed' or p.Status='Returned' then Amount else '0.00' end as Money)),
		SUM(case when p.Status='Failed' or p.Status='Returned' then 1 else 0 end),

		SUM(CAST(case when p.Status='Voided' or p.Status='Reversed' then Amount else '0.00' end as Money)),
		SUM(case when p.Status='Voided' or p.Status='Reversed' then 1 else 0 end),

		MAX(cast(lu.LastModified as datetime)),
		MAX(lu.Status)
	from PS_API_Payments p
	left join LatestUpdated lu
	on p.RecurringScheduleId = lu.RecurringScheduleId
	where p.RecurringScheduleId>0
	group by p.RecurringScheduleId
)

select
--
-- Note: This view supports the payment plan report by ordering, formatting and naming fields
-- for virtual direct presentation in that grid.  Pay simple data is renamed and interpreted/computed
-- to support easy user understanding.  It should be noted that this could obscure important details
-- from pay simple so care should be taken understand this view and to monitor raw, pay simple feedback.
--
-- In general, this view is probably better than the PS_API_PaymentPlans table for use in other functions
-- too as it provides a consistent view of the pay simple payments plan world and pulls in useful details
-- to from other GL tables to augment the view.
--
-- Any time this view is modified, the reporting function that simply does a "select *" may need to be reviewed
-- and modified/updated.....
--
-- ALSO PLEASE NOTE: THe base table retains a copy of all prior versions of pay plan records as an
-- historical/audit trail.  This view filters out all but the latest version of pay plan rows 
-- (see the inner join at the end of this view)...
--

-- RAW FIELDS THAT ARE MODIFIED BELOW....
--p.CustomerId,
--p.CustomerFirstName,p.CustomerLastName,p.CustomerCompany,
--p.NextScheduleDate,
--p.BalanceRemaining,p.NumberOfPaymentsRemaining,
--p.PauseUntilDate,
--p.PaymentAmount,
--p.FirstPaymentDone,
--p.DateOfLastPaymentMade,
--p.TotalAmountPaid,p.NumberOfPaymentsMade,
--p.TotalDueAmount,p.TotalNumberOfPayments,
--p.PaymentSubType,
--p.AccountId, p.InvoiceNumber,p.OrderId,
--p.FirstPaymentAmount,
--p.FirstPaymentDate,p.StartDate,
--p.ExecutionFrequencyType,p.ExecutionFrequencyParameter,
--p.Id,
--p.CreatedOn,p.UniqueID,p.UpdateTime,

	-- First payment date (if present) and Start date combined
	-- as a simplified 'Start Date' metephore...
	case when FirstPaymentDate>'' 
		then FirstPaymentDate else StartDate end 
		as StartDate,


    case isnull(session_context(N'AdminLanguage'),N'English') 
	when N'Chinese' 
	then RTRIM(LTRIM(ISNULL(p.CustomerLastName,N'')))
		+ RTRIM(LTRIM(ISNULL(p.CustomerFirstName,N'')))
	else RTRIM(LTRIM(ISNULL(p.CustomerLastName,N'')))
		+ RTRIM(LTRIM(ISNULL(N', '+p.CustomerFirstName,N''))) 
	end
	AS PayerName,

	s.glName as StudentName,

	SUBSTRING(p.Description, 1, CASE CHARINDEX('Payer''s purpose:', p.Description) 
		WHEN 0 THEN LEN(p.Description) 
		ELSE CHARINDEX('Payer''s purpose:', p.Description)-2 END) AS Description,
    RTRIM(LTRIM(SUBSTRING(p.Description, CASE CHARINDEX('Payer''s purpose:', p.Description) 
		WHEN 0 THEN LEN(p.Description)+16 
		ELSE CHARINDEX('Payer''s purpose:', p.Description)+16 END, 2048))) AS Purpose,

	a.AccountType as PayBy,
	right(a.AccountNoLast4,8) as Account,

	case when TotalNumberOfPayments=1 then 
		case when FirstPaymentDate='' then 'Single Payment' else 'Two Payments' end
	else  
		case when ExecutionFrequencyType='LastofMonth' then 'Monthly, on last day' else '' end
		+ case when ExecutionFrequencyType='SpecificDayofMonth' 
			then 'Monthly, on day '+CAST(ExecutionFrequencyParameter as nvarchar(10)) else '' end
	end as Frequency,

	-- Change 'Expired' status to 'Concluded' as I think this term is more recognizable by users
	-- (I would have prefered 'Completed' but that sounds like it might imply all payments were successful, which may not be true)
	case when p.ScheduleStatus='Expired' then 'Concluded' else p.ScheduleStatus end as ScheduleStatus,	

	LastPaymentUpdate LastPayUpdate,
	LastPaymentStatus LastPayStat,

	cast(TotalDueAmount as money) Total,
	case when FirstPaymentDate>'' then 1 else 0 end + TotalNumberOfPayments 
		as NumberPayments,

    cast(TotalAmountPaid as money) 
--		+ cast(case when FirstPaymentDone='true' 
--			then FirstPaymentAmount else '0.00' end as money)
		as Submitted, 
    NumberOfPaymentsMade + case when FirstPaymentDone='true' then 1 else 0 end 
		as NumberSubmitted, 

	PaymentsSettledAmount Settled,
	isnull(PaymentsSettledCount,0) NumberSettled,
	PaymentsFailedAmount Failed,
	isnull(PaymentsFailedCount,0) NumberFailed,
	PaymentsReversedAmount Reversed,
	isnull(PaymentReversedCount,0) NumberReversed,

--    cast(BalanceRemaining as money) as Remaining, -- Not reliable????
    cast(TotalDueAmount as money) - cast(TotalAmountPaid as money) as Remaining,
	case when FirstPaymentDate>'' then 1 else 0 end
		- case when FirstPaymentDone='true' then 1 else 0 end 
		+ NumberOfPaymentsRemaining as NumberRemaining,

	CAST(PaymentAmount as money) as Payment,

    case when cast(FirstPaymentAmount as money)=0 
		then null else cast(FirstPaymentAmount as money) end
		as [1stPay],

	p.Id as PlanId,

	PauseUntilDate as PauseUntil, 

    case when NextScheduleDate='0001-01-01T00:00:00Z' then null else NextScheduleDate end
	    as NextScheduleDate,  

	case when DateOfLastPaymentMade>'' 
		then DateOfLastPaymentMade else FirstPaymentDate end 
		as LastPmntMade, -- no longer reported, now we favor LastPaymentUpdate fields...

	isnull(case when datediff(second,p.LastModified,InstallmentStatus.LastPaymentUpdate)>0
		then p.LastModified else InstallmentStatus.LastPaymentUpdate end, p.LastModified)
		as LastModified,

	a.PaymentType,
	a.CustomerID,
	a.AccountID,

	c.StudentID, c.FamilyID as OrigFamilyID,
	c.GLFamilyInfo as OrigFamilyInfo,

	case when ScheduleStatus<>'Deleted' 
			and FirstPaymentDone='false' 
			and NumberOfPaymentsMade=0 
			and isnull(PaymentsFailedCount,0)=0 then 1 else 0 end
	    as showDeleteButton,
    case when ScheduleStatus='Active' 
		and (select AutoPayAllowSuspend from settings)=1
		then 1 else 0 end
        as showSuspendButton,
    case when ScheduleStatus='Suspended' then 1 else 0 end
        as showResumeButton,

	-- Highlight Pay Plan last created (or updated) in the UI if read within 15 seconds of update...
	-- case when DATEDIFF(SECOND,CreatedOn,GETUTCDATE())<=30 then 1 else 0 end +
	isnull(case when DATEDIFF(SECOND,lpus.LastModified,GETUTCDATE())<=15 then 1 else 0 end, 0)
	as showAsNewlyCreated,

	-- Show deleted pay plans for three minutes and concluded plans for one month before considering them
	-- as historical entries that users must request to be display...
	isnull(case when  p.ScheduleStatus='Deleted' and DATEDIFF(MINUTE,p.LastModified,GETUTCDATE())>3 then 1 else 0 end
		 + case when  p.ScheduleStatus in ('Expired','Concluded') and DATEDIFF(DAY,p.LastModified,GETUTCDATE())>31 then 1 else 0 end, 0)
	as showAsHistoryOnly

from PS_API_PaymentPlans p
left /*inner*/ join (
	select	'ACH' as PaymentType,
			PSCustomerID as CustomerID, 
			PSACHAccountID as AccountID, 
			PSACHBankAccountNumber as AccountNoLast4,
			case when PSACHAccountTypeID=1 then 'Checking' else 'Savings' end as AccountType
			from PSACHAccounts
	union select
			'CC' as PaymentType,
			PSCustomerID as CustomerID,
			PSCCAccountID as AccountID,
			PSCCNumber as AccountNoLast4,
			PSCCTypeID as AccountType
			from PSCCAccounts
) a
on p.AccountId = a.AccountID
left/*inner*/ join PSCustomers c
on p.CustomerId = c.PSCustomerID
left join Students s
on c.StudentID = s.StudentID
left join InstallmentStatus
on p.Id = InstallmentStatus.RecurringScheduleId
left join LatestPlanUpdatedForStudent lpus
on c.StudentID = lpus.StudentID and p.LastModified = lpus.LastModified

-- Important: hide historical version of records and only present latest now...
inner join ( select id PlanId, max(cast(LastModified as datetime)) LastModified from PS_API_PaymentPlans group by id ) x
    on p.id = x.PlanId and cast(p.LastModified as datetime) = x.LastModified

GO
