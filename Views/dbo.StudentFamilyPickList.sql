SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[StudentFamilyPickList] as
select top 100 percent *
from
(Select 
StudentID as ID, 
case when Active=1 or _Status = 'New Enrollment' then ' ' else '~ ' end + Fname+' '+Lname/*FullName*/ + ' - ' + cast(FamilyOrTempID as nvarchar(10)) as title,
case when Active=1 or _Status = 'New Enrollment' then ' ' else '' end + Fname+' '+Lname/*FullName*/ as ord
from vStudents
where (
	Active=1 or _Status = 'New Enrollment'
	or StudentID in (Select StudentID from Receivables)
	) and StudentID<>-1
) x
order by ord
GO
