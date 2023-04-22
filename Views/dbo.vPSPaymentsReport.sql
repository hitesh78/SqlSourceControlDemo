SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Joey
-- Create date: 05/17/2022
-- Modified dt: 05/24/2022
-- Description:	Payment Report, based on vPS_API_Payments
-- =============================================

CREATE   VIEW [dbo].[vPSPaymentsReport] AS
	SELECT
		p.PSPaymentID as PaymentID,
		convert(date, p.PSPaymentDate) as PaymentDate,
		case isnull(session_context(N'AdminLanguage'),N'English') 
			when N'Chinese' 
			then RTRIM(LTRIM(ISNULL(c.PSLastName,N''))) + RTRIM(LTRIM(ISNULL(c.PSFirstName,N'')))
			else RTRIM(LTRIM(ISNULL(c.PSLastName,N''))) + RTRIM(LTRIM(ISNULL(N', ' + c.PSFirstName,N'')))
		end	AS PayerName,
		p.PSAmount as Amount,
		case
			when p.PSPaymentType = 'ACH' and p.ConvenienceFee = '$0.00' 
			then 0.00     
			else isnull(p.ConvenienceAmount, 0.00) -- temporary patch for Fresh Desk #34261, etc.
		end as Fee,
		case
			when p.PSPaymentType = 'ACH' and p.ConvenienceFee = '$0.00' 
			then p.PSAmount 
			else isnull(p.StatementAmount,p.PSAmount) -- temporary patch for Fresh Desk #34261, etc.
		end as NetPaid, 
		p.ConvenienceFee as FeeRate, 
		p.PSPaymentType as PaymentType,
		s.glName as StudentName,
		dbo.ConcatWithDelimiter(replace(p.GLPaymentPurpose, 'Online Billing Payment', 'Billing'), p.PSDescription, ': ') as [Description],
		replace(replace(p.PSStatus, 'RefundSettled', 'Refund Completed'), 'ReversePosted', 'Reverse Completed') as [Status],
		isnull(p.PSProviderAuthCode, '') as ProviderAuthCode,
		isnull(p.PSTraceNumber, '') as TraceNumber,
		isnull(cast(convert(date, p.PSActualSettledDate) as nvarchar(12)), '') as SettledDate,
		isnull(cast(convert(date, p.PSEstimatedSettleDate) as nvarchar(12)), '') as EstDeposit,
		isnull(p.PSRecurringScheduleId, 0) as RecurringScheduleId,
		p.PSCanVoidUntil as CanVoidUntil,
		p.PSLastModified as LastModified, 
		replace(p.GLFamilyHTML, '<br/>', char(13)) as FamilyInformation,
		p.PSPaymentSubType as PaymentSubType -- must be last column, used as dummy for proper right scrolling
	FROM vPSPayments p
		left join Students s
			on p.GLXrefID = s.StudentID
		inner join PSCustomers c
			on c.PSCustomerID = p.PSCustomerID

GO
