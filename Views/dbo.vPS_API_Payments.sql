SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* =============================================
** Modified:	4/15/2021
** Modified-by: Joey G
** Reason:		Need full CanVoidUntil datetime
** ============================================= */
CREATE   VIEW [dbo].[vPS_API_Payments] AS
SELECT
	p.ID as PaymentID,
	left(p.PaymentDate,10) PaymentDate, 
    case isnull(session_context(N'AdminLanguage'),N'English') 
		when N'Chinese' 
		then RTRIM(LTRIM(ISNULL(p.CustomerLastName,N''))) + RTRIM(LTRIM(ISNULL(p.CustomerFirstName,N'')))
		else RTRIM(LTRIM(ISNULL(p.CustomerLastName,N''))) + RTRIM(LTRIM(ISNULL(N', '+p.CustomerFirstName,N''))) 
	end	AS PayerName,
	p.Amount,
	case
		when p.PaymentType='ACH' and psp.ConvenienceFee='$0.00' 
		then 0.00     
		else isnull(psp.ConvenienceAmount, 0.00) -- temporary patch for Fresh Desk #34261, etc.
	end as Fee,
	case
		when p.PaymentType='ACH' and psp.ConvenienceFee='$0.00' 
		then p.Amount 
		else isnull(psp.StatementAmount,p.Amount) -- temporary patch for Fresh Desk #34261, etc.
	end as NetPaid, 
    psp.ConvenienceFee FeeRate, 
	p.PaymentType,
    s.glName as StudentName, 
    -- s.Father, s.Mother,
	dbo.ConcatWithDelimiter(
        replace(psp.GLPaymentPurpose, 'Online Billing Payment', 'Billing'), 
        p.Description, ': ') Description,
-- As I was typing this up, I tested the filter I suggested above on 'Settled' 
-- status + Settled Date (i.e. to help with bank reconciliation) and I encoutered one problem: 
-- the Status filter found both Settled and RefundSettled!  So I modified the status column results 
-- of 'RefundSettled' and 'ReversePosted' to 'Refund Completed' and 
-- 'Reverse Completed', respectively.  This makes all the status codes I've seen in 
-- DB 13 so far unique in that no status is an exact partial string match of another status.  
-- This is a small example of the type of business rules we may build in over time to help 
-- make this dataset easier to use.
	replace(replace(p.Status, 'RefundSettled', 'Refund Completed'), 'ReversePosted', 'Reverse Completed') Status,
	p.ProviderAuthCode,
	p.TraceNumber,
	left(p.ActualSettledDate,10) SettledDate,
-- TODO: Review: Are there any advantages to...
-- ISNULL(left(p.ActualSettledDate,10),left(p.EstimatedSettleDate,10) + '(est.)') SettledDate,
	left(p.EstimatedDepositDate,10) as EstDeposit,
	p.RecurringScheduleId,
	p.CanVoidUntil,
	p.LastModified, 
    replace(psp.GLFamilyHTML,'<br/>',char(13)) FamilyInformation,
    p.PaymentSubType -- must be last column, used as dummy for proper right scrolling
	from PS_API_Payments p
	-- IMPORTANT: hide historical version of records and only present latest now...
		inner join ( 
				select id PaymentID, max(dateadd(SECOND,ascii(Status),LastModified)) LastModified 
				from PS_API_Payments group by id ) x
			on p.id = x.PaymentID and dateadd(SECOND,ascii(Status),p.LastModified) = x.LastModified
		left join vPSPayments psp
			on psp.PSPaymentID = cast(p.ID as int)
		left join Students s
			on psp.GLXrefID = s.StudentID

GO
