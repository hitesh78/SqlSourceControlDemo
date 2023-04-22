SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Legacy/Joey
-- Create Date: Legacy
-- Modified dt: 02/09/2023, 03/02/2023
-- Rev. Notes:	first payment override not correct when fee is 0, attempt 2
-- =============================================
CREATE     VIEW [dbo].[vPSPayments] as
with Pmnts as (
	select 
		p.PSPaymentID,
		p.PSCustomerID,
		p.PSAccountID,
		p.PSAmount,
		p.PSIsDebit,
		p.PSReferenceID,
		p.PSLatitude,
		p.PSLongitude,
		p.PSStatus,
		p.PSRecurringScheduleID,
		p.PSPaymentType,
		p.PSPaymentSubtype,
		p.PSProviderAuthCode,
		p.PSTraceNumber,
		p.PSPaymentDate,
		p.PSReturnDate,
		p.PSEstimatedSettleDate,
		p.PSActualSettledDate,
		p.PSCanVoidUntil,
		p.PSInvoiceID,
		p.PSInvoiceNumber,
		p.PSOrderID,
		p.PSDescription,
		p.PSLastModified,
		p.PSCreatedOn,
		p.PSCVV,
		p.PSErrorCode,
		p.PSErrorDescription,
		p.PSMerchantActionText,p.PSIsDecline,
		p.GLCreatingUserID,
		p.GLID,
		COALESCE(p.GLXrefID, cast(pc.StudentID as nvarchar(20))) as GLXrefID,
		p.GLPaymentPurpose,
		p.GLPaymentContext,
		p.GLFamilyHTML,
		-- Get requisite plan information if present so that
		-- we can infer an installment StatementAmount for individual payments reporting
		-- (need to allocate rounding errors, see Pmnts2 CTE)
		pln.PaymentsAmount as PlanStatementAmount,
		pln.TotalNumberOfPayments + 
			case 
				when isnull(pln.FirstPaymentAmount,0.00)>0.00 
				then 1 
				else 0 
			end as PlanNumberOfPayments,
		round(pln.PaymentsAmount / nullif((pln.TotalNumberOfPayments + 
			case 
				when isnull(pln.FirstPaymentAmount, 0.00) > 0.00 
				then 1 
				else 0 
			end), 0), 2) as PlanInstallmentStatementAmount,
		case 
			when isnull(p.PSRecurringScheduleID,0) > 0 and 
				(select min(PSPaymentID) from PSPayments where PSRecurringScheduleID = p.PSRecurringScheduleID) = p.PSPaymentID
			then 1 
			else 0 
		end as PlanIsFirstInstallment,
		isnull(
			case 
				when ((pln.TotalDueAmount - p.psamount) / pln.TotalNumberOfPayments) / p.psamount not between .98 and 1.02 
				then 1 
				else 0 
			end
		, 0) as FirstPaymentOverride,
		cast(isnull(
			case 
				when pln.ConvenienceFeeRate not like '$%'
				then pln.ConvenienceFeeRate 
				else N'0.00' 
			end
		, N'0.00') as float) as ConvenienceFeeRate,
		isnull(cast(replace(replace(p.StatementAmount,'$',''),',','') as money), p.PSAmount) as QuickPayStatementAmount,
		-- We store Pay Plan convenience fees in PSPaymentPlans,
		-- and Quick Pay convenience fees in PSPayments...
		-- (check for presents of plan information and use that if found)
		ISNULL(
			case 
				when pln.ACHorCC is not null
				then 
					case 
						when pln.ACHorCC='ACH' 
						then pln.ConvenienceFeeRate
						else pln.ConvenienceFeeRate+'%' 
					end
				else
					case 
						when p.PSPaymentType='ACH' 
						then p.ConvenienceFee
						else p.ConvenienceFee+'%' 
					end
			end
		, '') as ConvenienceFee
	from PSPayments p
	left join PSPaymentPlans pln
		on pln.PSPaymentPlanId = p.PSRecurringScheduleID
	LEFT join PSCustomers pc
		on pc.PSCustomerID = p.PSCustomerID
),
Pmnts2 as (
	select 
		*,
		case 
			when PlanStatementAmount is null 
			then QuickPayStatementAmount
			else
				--
				-- DS-220 / FD 113140 - Convenience fees were not being computed
				-- correctly for the individual payment installments associated 
				-- with payment plans with more than one installment and a first
				-- payment amount override that varies from the computed flat/even
				-- default pay plan.  This glitch likely impacts ACH flat rate fees
				-- also, but I focused this fix only on the cc percentage fee case
				-- needed in the referenced ticket for school #1882....  I wanted 
				-- to be very conservative and not risk disrupting the report for 
				-- any other cases at this time.  TODO: Needs further review and 
				-- a cleaner generic solution.  Not that this infers whether or not
				-- there is a first installment override in the code above by
				-- check for a variance of +/- 2% (the not between ... code above)
				--
				case 
					when FirstPaymentOverride = 1 and ConvenienceFeeRate > 0 
					then round(PSAmount / (1.00 + ConvenienceFeeRate/100.00) ,2)
					when FirstPaymentOverride = 1 and ConvenienceFeeRate = 0 --and PlanIsFirstInstallment = 1 -- JG Added 2/9/23 ... 2
					then PSAmount
					when PlanIsFirstInstallment = 1
					then PlanStatementAmount - PlanInstallmentStatementAmount * (PlanNumberOfPayments - 1) 
					else PlanInstallmentStatementAmount
				end 
		end as StatementAmount
	from Pmnts
)
select 
	*, 
	round(PSAmount - StatementAmount, 2) as ConvenienceAmount
from Pmnts2

GO
