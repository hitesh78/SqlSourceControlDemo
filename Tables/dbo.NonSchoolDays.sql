CREATE TABLE [dbo].[NonSchoolDays]
(
[DateID] [int] NOT NULL IDENTITY(1, 1),
[Description] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TheDate] [smalldatetime] NULL,
[StartDate] [smalldatetime] NULL,
[EndDate] [smalldatetime] NULL,
[AttendanceSymbol] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventID] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[AddorEditNonSchoolDates]
 on [dbo].[NonSchoolDays]
 After Insert, Update
As
Begin

	Declare @DateID int
	Declare @TheDateDeleted date
	Declare @StartDateDeleted date
	Declare @EndDateDeleted date
	

	Set @DateID = (Select DateID From Inserted)
	
	
	Select 
	@TheDateDeleted = TheDate,
	@StartDateDeleted = StartDate,
	@EndDateDeleted = EndDate
	From Deleted	
	
	
	Declare @TheStartDateRangeDeleted date
	Declare @TheEndDateRangeDeleted date
	
	If @TheDateDeleted is null
	Begin
		Set @TheStartDateRangeDeleted = @StartDateDeleted
		Set @TheEndDateRangeDeleted = @EndDateDeleted
	End
	Else
	Begin
		Set @TheStartDateRangeDeleted = @TheDateDeleted
		Set @TheEndDateRangeDeleted = @TheDateDeleted	
	End
	
	
	Delete Attendance
	From 
	Attendance A
		inner join
	ClassesStudents CS
		on A.CSID = CS.CSID
		inner join
	Classes C
		on C.ClassID = CS.ClassID
	Where
	C.ClassTypeID = 5
	and
	A.ClassDate Between @TheStartDateRangeDeleted and @TheEndDateRangeDeleted
	
	Alter table dbo.Attendance Disable trigger All
	Execute dbo.AddNonSchoolDaysAttendance @DateID, -1
	Alter table dbo.Attendance Enable trigger All	

End
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[DeleteNonSchoolDates]
 on [dbo].[NonSchoolDays]
 After Delete
As
Begin


	Declare @TheDate date
	Declare @StartDate date
	Declare @EndDate date


	Select 
	@TheDate = TheDate,
	@StartDate = StartDate,
	@EndDate = EndDate
	From Deleted


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
	
	
	Alter table dbo.Attendance Disable trigger All
	
	Delete Attendance
	From 
	Attendance A
		inner join
	ClassesStudents CS
		on A.CSID = CS.CSID
		inner join
	Classes C
		on C.ClassID = CS.ClassID
	Where
	C.ClassTypeID = 5
	and
	A.ClassDate Between @TheStartDateRange and @TheEndDateRange
	
	Alter table dbo.Attendance Enable trigger All	

End
GO
ALTER TABLE [dbo].[NonSchoolDays] ADD CONSTRAINT [FK_NonSchoolDays_EdFiCalendarEvents] FOREIGN KEY ([EventID]) REFERENCES [dbo].[EdFiCalendarEvents] ([EventID])
GO
