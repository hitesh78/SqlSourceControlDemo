SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vInvoicePeriods] AS
SELECT 
	ip.InvoicePeriodID, 
	ip.SessionID, 
	ip.Title, 
	ip.FromDate, 
	ip.ThruDate,
	ip.Status,
	ip.Opened,
	ip.Closed,
	s.title as SessionTitle,
	s._title as _SessionTitle,
	ip.Title + ' - ' + s.title as TitleWithSession,
	ip.BillingNote,
	dbo.GLformatdate(ip.FromDate) 
	+ ' (' + left(ip.Title,CHARINDEX(' ',ip.Title)) +'period open)'
	+ ' - ' + s.title PeriodOpen,
	dbo.GLformatdate(ip.ThruDate) 
	+ ' (' +  left(ip.Title,CHARINDEX(' ',ip.Title)) +'period close)'
	+ ' - ' + s.title PeriodClose,
	convert(varchar(10),ip.FromDate,102) as FromDateSortable,
	
	(select COUNT(*) cnt from Receivables
	where Date between ip.FromDate and ip.ThruDate
	and TransactionTypeID 
		in (Select TransactionTypeID 
				from TransactionTypes tt
				inner join attendancesettings aset 
					on tt.AttendanceCode = aset.id
				where 
					tt.SessionID = ip.SessionID /* and -- FD 105415 some schools do not use CHARGE :(
					tt.DB_CR_Code = 'Charge' */ /*safeguard*/)) NumLunchCharges,

	(select SUM(amount) cnt from Receivables
		where Date between ip.FromDate and ip.ThruDate
		and TransactionTypeID 
		in (Select TransactionTypeID 
				from TransactionTypes tt
				inner join attendancesettings aset 
					on tt.AttendanceCode = aset.id
				where 
					tt.SessionID = ip.SessionID /* and -- FD 105415 some schools do not use CHARGE :(
					tt.DB_CR_Code = 'Charge' */ /*safeguard*/)) SumLunchCharges,
				
	-- The next two fields are designed to provide good performance when querying
	-- this view with "where InvoicePeriodID=".  And performance could be further 
	-- improved by somehow calling funcLunchCharges only once to get both count and sum....	
	(select count(amount) from funclunchcharges(ip.InvoicePeriodID)) NumPendLunchCharges,	
	(select sum(amount) from funclunchcharges(ip.InvoicePeriodID)) SumPendLunchCharges,

	NumPendInstallmentDB,
	SumPendInstallmentDB,
	NumPendInstallmentCR,
	SumPendInstallmentCR,

	NumInstallmentDB,
	SumInstallmentDB,
	NumInstallmentCR,
	SumInstallmentCR,

	st.*,
	case when ip.SessionID_TransferBalances is null then 0 else 1 end as _CloseSessionInfo,
	ip.SessionID_TransferBalances,
	case when ip.status='Closed' then 'Yes' else 'No' end as inUseLock
	
FROM InvoicePeriods ip
INNER JOIN vSession s on s.SessionID = ip.SessionID
CROSS JOIN (Select EnableInstallmentBilling,EnableLunchBilling from Settings) st
LEFT JOIN (
	select 	
		InvoicePeriodID,
		sum(case when db_cr='Debit' then cnt else 0 end) NumPendInstallmentDB,
		sum(case when db_cr='Debit' then amt else 0 end) SumPendInstallmentDB,
		sum(case when db_cr='Credit' then cnt else 0 end) NumPendInstallmentCR,
		sum(case when db_cr='Credit' then amt else 0 end) SumPendInstallmentCR
	from
	(select 
		ip.InvoicePeriodID, 
		case when tt.DB_CR_Code in ('Payment','Credit Memo') 
			then 'Credit' else 'Debit' end db_cr, 
		SUM(case when isnull(amnt,0)=0 then 0 else 1 end) cnt, 
		SUM(isnull(amnt,0)) amt 
	from ContractNormalized cn
	inner join TransactionTypes tt 
		on cn.TransactionTypeID=tt.TransactionTypeID
	inner join InvoicePeriods ip
		on cn.date between ip.FromDate and dbo.MinDate(getdate(),ip.ThruDate)
			and cn.SessionID = ip.SessionID
	group by ip.InvoicePeriodID,tt.DB_CR_Code) 
	as PendingInstallments
	group by InvoicePeriodID
) pending on pending.InvoicePeriodID = ip.InvoicePeriodID
LEFT JOIN (
	select 	
		InvoicePeriodID,
		sum(case when db_cr='Debit' then cnt else 0 end) NumInstallmentDB,
		sum(case when db_cr='Debit' then amt else 0 end) SumInstallmentDB,
		sum(case when db_cr='Credit' then cnt else 0 end) NumInstallmentCR,
		sum(case when db_cr='Credit' then amt else 0 end) SumInstallmentCR
	from
	(select 
		ip.InvoicePeriodID,
		case when tt.DB_CR_Code in ('Payment','Credit Memo') 
			then 'Credit' else 'Debit' end db_cr, 
		COUNT(*) cnt, 
		SUM(rc.Amount) amt 
	from Receivables rc
	inner join TransactionTypes tt 
		on rc.TransactionTypeID=tt.TransactionTypeID
	inner join InvoicePeriods ip
		on rc.date between ip.FromDate and ip.ThruDate
			and tt.SessionID = ip.SessionID
	where rc.ContractID is not null
	group by ip.InvoicePeriodID,tt.DB_CR_Code, FromDate, ThruDate
	)
	as PostedInstallments
	group by InvoicePeriodID
) posted on posted.InvoicePeriodID = ip.InvoicePeriodID
GO
