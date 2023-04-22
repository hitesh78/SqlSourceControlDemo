SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[StudentPickList] as
select 
  top 100 percent -- hack to allow "sorted" view as I recall...
  *
from
(Select 
StudentID as ID, 
glName + ' #'+cast(xStudentID as nvarchar(20)) + ISNULL(' ('+Status+')', '') as title,
glName as ord
from Students
where (Active=1 or Status = 'New Enrollment') and StudentID<>-1
) x
order by ord
GO
