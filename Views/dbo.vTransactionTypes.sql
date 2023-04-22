SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vTransactionTypes] AS
SELECT 
	tt.TransactionTypeID, 
	tt.SessionID, 
	tt.Title, 
	tt.ReceivableCategory, 
	tt.DB_CR_Code, 
	tt.GLAccount,
	cast(tt.Amount as money) as Amount, 
	cast(tt.Notes as nvarchar(MAX)) as Notes,
	s.title as SessionTitle,
	s._title as _SessionTitle,
	tt.Title 
		+ ' (' + case when isnull(tt.Amount,0)=0 then '' else +'$'+convert(nvarchar(16),tt.Amount,1)+' ' end + rtrim(tt.DB_CR_Code)+')'
		+ ' - ' + s.title as TitleWithSession,
	isnull(r.inUseLock,'No') as inUseLock,
	tt.FinAid, tt.AttendanceCode, aset.Title as AttendanceTitle,
	(case when tt.AttendanceCode IS NOT NULL then 1 else 0 end) AS lunchBilling,
	tt.daycare_tax_report 
FROM TransactionTypes tt
INNER JOIN vSession s on s.SessionID = tt.SessionID
LEFT JOIN AttendanceSettings aset on aset.ID = tt.AttendanceCode
LEFT JOIN (
	select distinct TransactionTypeID,'Yes' as inUseLock from Receivables
	union select distinct TransactionTypeID,'Yes' as inUseLock from Contract
) r on r.TransactionTypeID = tt.TransactionTypeID
where balanceTransferType = 0
union all
select 
	-1 as TransactionTypeID, 
	(Select SessionID from vSession where _Title like '%*') as SessionID,
	'' as Title, 
	'' as ReceivableCategory, 
	'' as DB_CR_Code, 
	'' as GLAccount, 
	cast(0.00 as money) as Amount, 
	null as Notes,
	(Select Title from vSession where _Title like '%*') as  SessionTitle,
	(Select _Title from vSession where _Title like '%*') as  _SessionTitle,
	'' as SessionWithTitle,
	'No' as inUseLock,
	null as FinAid, null as AttendanceCode, '' as AttendanceTitle,
	0 as lunchBilling,
	0 as daycare_tax_report



GO
