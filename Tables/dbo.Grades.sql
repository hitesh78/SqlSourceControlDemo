CREATE TABLE [dbo].[Grades]
(
[GradeID] [int] NOT NULL IDENTITY(1, 1),
[CSID] [int] NOT NULL,
[AssignmentID] [int] NOT NULL,
[Grade] [real] NULL,
[LetterGrade] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Grades_LetterGrade] DEFAULT ('NA'),
[Comments] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OutOfCorrect] [real] NULL,
[LowestGrade] [bit] NOT NULL CONSTRAINT [DF_Grades_LowestGrade] DEFAULT ((0)),
[GradeCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NeedToSendGradeAlert] [bit] NOT NULL CONSTRAINT [DF_Grades_NeedToSendGradeAlert] DEFAULT ((0)),
[Completed] [bit] NOT NULL CONSTRAINT [DF_Grades_Completed] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[LogGradeUpdates]
on [dbo].[Grades]
After Update
As
Begin

	Declare @CalcDate datetime = dbo.GLgetdatetime()
	Declare @TheWeekDay nvarchar(10) = (Select DATENAME(weekday, @CalcDate))


	Insert Into ActivityLog(ClassID, TheWeekday, LogDate, Item, BeforeChange, AfterChange)
	Select 
	CS.ClassID,
	@TheWeekDay as TheWeekDay,
	@CalcDate as LogDate,
	dbo.T(-0.1, 'Grade') + ': ' + S.glname + ' /' + A.AssignmentTitle as Item,
	(
		Select 
		case
			when isnull(GradeCode,'') != '' then GradeCode
			else convert(nvarchar(20),convert(Int,round(Grade,0)))
		end
		From Deleted
		Where GradeID = G.GradeID
	) as BeforeChange,
	(
		Select
		case
			when isnull(GradeCode,'') != '' then GradeCode
			else convert(nvarchar(20),convert(Int,round(Grade,0)))
		end
		From Inserted
		Where GradeID = G.GradeID
	) as AfterChange
	From 
	(
		Select 
		I.GradeID,
		I. CSID,
		I.AssignmentID
		From Inserted I
		Where
			((Select Grade from Inserted Where GradeID = I.GradeID) != (Select Grade from Deleted Where GradeID = I.GradeID))	-- Detects changing a grade (Any null values forces a false result)
			or
			((Select GradeCode from Inserted Where GradeID = I.GradeID) != (Select GradeCode from Deleted Where GradeID = I.GradeID))
			or
			((Select Grade from Inserted Where GradeID = I.GradeID) is not null) and ((Select Grade from Deleted Where GradeID = I.GradeID) is null)
			or 
			((Select GradeCode from Inserted Where GradeID = I.GradeID) is not null) and ((Select GradeCode from Deleted Where GradeID = I.GradeID) is null)
			and 
			((Select Grade from Deleted Where GradeID = I.GradeID) is null)	-- Detects adding a grade
			or
			((Select Grade from Inserted Where GradeID = I.GradeID) is null) and ((Select Grade from Deleted Where GradeID = I.GradeID) is not null)	-- Detects deleting a grade	
			
		Union 
		
		Select 
		D.GradeID, 
		D.CSID,
		D.AssignmentID
		From Deleted D
		Where
			((Select Grade from Inserted Where GradeID = D.GradeID) != (Select Grade from Deleted Where GradeID = D.GradeID))	-- Detects changing a grade (Any null values forces a false result)
			or
			((Select GradeCode from Inserted Where GradeID = D.GradeID) != (Select GradeCode from Deleted Where GradeID = D.GradeID))
			or
			((Select Grade from Inserted Where GradeID = D.GradeID) is not null) and ((Select Grade from Deleted Where GradeID = D.GradeID) is null)	-- Detects adding a grade
			or
			((Select Grade from Inserted Where GradeID = D.GradeID) is null) and ((Select Grade from Deleted Where GradeID = D.GradeID) is not null)	-- Detects deleting a grade

	) G
		inner join
	ClassesStudents CS
		on CS.CSID = G.CSID
		inner join
	Students S
		on CS.StudentID = S.StudentID
		inner join
	Assignments A
		on A.AssignmentID = G.AssignmentID
		
End
-- =============================================
-- Author:		Don Puls
-- Create date: 7/24/2014
-- Last update: 8/06/2014 Duke
-- Description:	This Trigger Populates the GLFamilyHTML column on insert
-- =============================================
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateStudentGradeAfterUpdateOrDelete]
 on [dbo].[Grades]
 After Update, Delete
As

SET NOCOUNT ON;

-- **********************
-- Set Grade Alert Flag
-- **********************

Update Grades
Set NeedToSendGradeAlert = GA.GradeAlertFlag
From
Grades G
	inner join
(
	Select
	Gi.GradeID,
	max(
	case
		when
			(CGG.GradeOrder <= AA.HighGradeAlert and AA.HighGradeAlert != 0)
			or
			(CGG.GradeOrder >= AA.LowGradeAlert and AA.LowGradeAlert != 0 and A.EC = 0)	 
		then 1
		else 0
	end
	) as GradeAlertFlag
	From 
	Inserted Gi
		inner join
	Deleted Gd
		on Gi.GradeID = Gd.GradeID
		inner join
	Assignments A
		on Gi.AssignmentID = A.AssignmentID
		inner join
	Classes C
		on A.ClassID = C.ClassID
		inner join
	ClassesStudents CS
		on Gi.CSID = CS.CSID
		inner join
	AccountAlerts AA
		on AA.CSID = CS.CSID
		inner join
	CustomGradeScaleGrades CGG
		on	C.CustomGradeScaleID = CGG.CustomGradeScaleID
			and
			CGG.GradeSymbol = dbo.GetLetterGrade(C.ClassID, Gi.Grade)
		inner join
	Terms T
		on C.TermID = T.TermID
	Where
	T.Status = 1
	and
	C.ClassTypeID in (1,8)
	and
	C.NonAcademic = 0
	and
	A.Weight > 0
	and
	(
	Gi.Grade != Gd.Grade
	or
	(Gd.Grade is null and Gi.Grade is not null)
	)
	Group By Gi.GradeID
) GA
	on G.GradeID = GA.GradeID




-- **********************
-- Set Update Lowest Grade and Class Grade
-- **********************

Declare @ClassID int
Declare @TypeID int

If Update(Grade)
Begin

	Select distinct
	@ClassID = A.ClassID,
	@TypeID = 
		case
			when AT.DropLowestGrade = 1 then AT.TypeID
			else null
		end 
	From 
	AssignmentType AT
		inner join
	Assignments A
		on AT.TypeID = A.TypeID
		inner join
	Inserted I
		on A.AssignmentID = I.AssignmentID			
		
End
Else
Begin

	Select distinct
	@ClassID = A.ClassID,
	@TypeID = 
		case
			when AT.DropLowestGrade = 1 then AT.TypeID
			else null
		end 
	From 
	AssignmentType AT
		inner join
	Assignments A
		on AT.TypeID = A.TypeID
		inner join
	Deleted D
		on A.AssignmentID = D.AssignmentID	
		
End


If @TypeID is not null
Begin
	Execute MarkLowestGrade @TypeID
End

Execute MasterUpdateStudentGrade @ClassID

GO
ALTER TABLE [dbo].[Grades] ADD CONSTRAINT [PK_Grades] PRIMARY KEY CLUSTERED ([GradeID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AssignmentID] ON [dbo].[Grades] ([AssignmentID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [AssignmentID_Index] ON [dbo].[Grades] ([AssignmentID]) INCLUDE ([CSID], [Grade]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CSID] ON [dbo].[Grades] ([CSID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Grades_Index] ON [dbo].[Grades] ([CSID], [AssignmentID], [LowestGrade]) INCLUDE ([Grade]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NeedToSendGradeAlert_Index] ON [dbo].[Grades] ([NeedToSendGradeAlert]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Grades] ADD CONSTRAINT [FK_Grades_Assignments] FOREIGN KEY ([AssignmentID]) REFERENCES [dbo].[Assignments] ([AssignmentID])
GO
ALTER TABLE [dbo].[Grades] ADD CONSTRAINT [FK_Grades_ClassesStudents] FOREIGN KEY ([CSID]) REFERENCES [dbo].[ClassesStudents] ([CSID]) ON DELETE CASCADE
GO
