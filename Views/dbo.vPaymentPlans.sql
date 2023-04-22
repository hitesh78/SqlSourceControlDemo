SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vPaymentPlans]
as
select 
	p.PaymentPlanID,
	p.SessionID,
	p.Title,
	p.TotalAmount,
	p.Date1,
	p.Amount1,
	p.Date2,
	p.Amount2,
	p.Date3,
	p.Amount3,
	p.Date4,
	p.Amount4,
	p.Date5,
	p.Amount5,
	p.Date6,
	p.Amount6,
	p.Date7,
	p.Amount7,
	p.Date8,
	p.Amount8,
	p.Date9,
	p.Amount9,
	p.Date10,
	p.Amount10,
	p.Date11,
	p.Amount11,
	p.Date12,
	p.Amount12,
	p.DescPrefix1,
	p.DescPrefix2,
	p.DescPrefix3,
	p.DescPrefix4,
	p.DescPrefix5,
	p.DescPrefix6,
	p.DescPrefix7,
	p.DescPrefix8,
	p.DescPrefix9,
	p.DescPrefix10,
	p.DescPrefix11,
	p.DescPrefix12,
	s.title as SessionTitle,
	s._title as _SessionTitle,
	p.Title + ' - ' + s.title as TitleWithSession
from PaymentPlans p
INNER JOIN vSession s on s.SessionID = p.SessionID
union all
select 
	-1 as PaymentPlanID, 
	(Select SessionID from vSession where _Title like '%*') as SessionID,
	'' as Title, 
	cast(0.00 as money) as TotalAmount,
	GETDATE() as Date1,
	cast(0.00 as money) as Amount1, 
	null as Date2,
	null as Amount2, 
	null as Date3,
	null as Amount3, 
	null as Date4,
	null as Amount4, 
	null as Date5,
	null as Amount5, 
	null as Date6,
	null as Amount6, 
	null as Date7,
	null as Amount7, 
	null as Date8,
	null as Amount8, 
	null as Date9,
	null as Amount9, 
	null as Date10,
	null as Amount10, 
	null as Date11,
	null as Amount11, 
	null as Date12,
	null as Amount12,
	'' as DescPrefix1,
	'' as DescPrefix2,
	'' as DescPrefix3,
	'' as DescPrefix4,
	'' as DescPrefix5,
	'' as DescPrefix6,
	'' as DescPrefix7,
	'' as DescPrefix8,
	'' as DescPrefix9,
	'' as DescPrefix10,
	'' as DescPrefix11,
	'' as DescPrefix12,
	(Select Title from vSession where _Title like '%*') as  SessionTitle,
	(Select _Title from vSession where _Title like '%*') as  _SessionTitle,
	'' as SessionWithTitle
	

GO