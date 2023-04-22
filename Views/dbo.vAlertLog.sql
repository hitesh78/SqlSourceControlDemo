SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vAlertLog] as
select a.AlertID, cast(a.AlertDate as date) as AlertDate, 
    RIGHT(rtrim(a.AlertDate),7) as AlertTime, 
    cs.StudentID, c.ClassTitle, 
    t.glName as TeacherName,
    a.AlertType,a.email,a.AlertDescription 
from AlertLog a 
inner join ClassesStudents cs on a.CSID = cs.CSID
inner join Classes c on cs.ClassID = c.ClassID
inner join Teachers t on c.TeacherID = t.TeacherID
GO
