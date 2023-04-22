SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[ReceivableFamilysPickList] AS
select 
	x.FamilyID as ID,
	x.SessionID,
	MAX(replace(isnull(x.Father +' / ','')+ isnull(x.Mother,''),'&',' ') + ' - ' + s.title) as title 
from
(select distinct 
	st.FamilyID, 
	tt.SessionID,
	st.Father,
	st.Mother
	from receivables r
	inner join TransactionTypes tt on tt.TransactionTypeID = r.TransactionTypeID
	inner join Students st on r.StudentID = st.StudentID
	where st.FamilyID is not null
	) x
inner join Session s on s.SessionID = x.SessionID
group by x.FamilyID, x.SessionID

GO
