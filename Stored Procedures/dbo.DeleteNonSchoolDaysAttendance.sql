SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[DeleteNonSchoolDaysAttendance]
	@DateID int,
	@ClassID int
as

Begin

	Declare @TheDate date
	Declare @StartDate date
	Declare @EndDate date

	Select 
	@TheDate = TheDate,
	@StartDate = StartDate,
	@EndDate = EndDate
	From dbo.NonSchoolDays
	Where
	DateID = @DateID



	Declare @TheStartDateRange date
	Declare @TheEndDateRange date

	
	If @TheDate is null
	Begin
		Set @TheStartDateRange = @StartDate
		Set @TheEndDateRange = @EndDate
	End
	Else
	Begin
		Set @TheStartDateRange = @TheDate
		Set @TheEndDateRange = @TheDate	
	End
	
	
	Delete From Attendance
	From Attendance A
		inner join
	ClassesStudents CS
		on A.CSID = CS.CSID
	Where 
	CS.ClassID = @ClassID
	and
	A.ClassDate between @TheStartDateRange and @TheEndDateRange


End


GO
