SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[LunchAttendanceSettings]
as
select * from AttendanceSettings where Title>'' and PresentValue=0 and AbsentValue=0 and MultiSelect=1 and ExcludedAttendance=1
GO
