SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[vSessionBill] as
select top 100000 s.SessionID, 
s.Title 
+ case when 
(select MIN(dateadd(ss,SessionID,cast(FromDate as datetime)))
	from Session where Status='Open') 
	= dateadd(ss,s.SessionID,cast(s.FromDate as datetime))
and s.Status='Open' then ' *' else '' end as _Title,
s.Title as Title, 
s.FromDate, s.ThruDate,  
BillingFromDate,BillingThruDate,
isnull(Status,'Open') Status,
BillingClosedDate,
SuppressOnlineStatements
from Session s
where s.BillingFromDate is not null
order by s.BillingFromDate desc
GO
