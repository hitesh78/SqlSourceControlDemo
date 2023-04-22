SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vSession] as
select s.SessionID, 
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


GO
