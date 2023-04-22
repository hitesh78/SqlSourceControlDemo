CREATE TABLE [dbo].[CustomGradeScaleGrades]
(
[GradeID] [int] NOT NULL IDENTITY(1, 1),
[CustomGradeScaleID] [int] NOT NULL,
[GradeSymbol] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GradeDescription] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GradeOrder] [int] NOT NULL,
[LowPercentage] [decimal] (5, 2) NULL,
[LetterGradeConversion] [decimal] (5, 2) NULL,
[GPAValue] [decimal] (5, 3) NULL,
[DefaultGrade] [int] NULL,
[ExcludeGradeCalculation] [bit] NULL,
[edfiCourseCompletionStatus] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateGradeAfterLGConvChange]
 on [dbo].[CustomGradeScaleGrades]
 After Update
As



Declare @LetterGradeConversionInserted decimal(5,2)
Declare @LetterGradeConversionDeleted decimal(5,2)
Set @LetterGradeConversionInserted = (Select LetterGradeConversion From Inserted)
Set @LetterGradeConversionDeleted = (Select LetterGradeConversion From Deleted)

If Update(LetterGradeConversion) and @LetterGradeConversionInserted != @LetterGradeConversionDeleted
Begin

Declare @TheLetterGrade nvarchar(5)
Declare @ThePercentageGrade dec(5,2)
Declare @CustomGradeScaleID int

Set @CustomGradeScaleID = (Select CustomGradeScaleID From Inserted)

Set @TheLetterGrade = (Select GradeSymbol From Inserted)
Set @ThePercentageGrade = @LetterGradeConversionInserted



ALTER TABLE Grades DISABLE TRIGGER ALL

Update Grades
  Set Grade = @ThePercentageGrade
Where 
Grade is not Null
and
GradeID in 
(
Select G.GradeID
from
Classes C
	inner join
Terms T
	on C.TermID = T.TermID
	inner join
Assignments A
	on C.ClassID = A.ClassID
	inner join
Grades G
	on G.AssignmentID = A.AssignmentID

Where
C.CustomGradeScaleID = @CustomGradeScaleID
and
C.ClassTypeID in (1,2,8)
and
T.Status = 1
and
A.GradeStyle = 2
and
G.LetterGrade = @TheLetterGrade	    
)
	
ALTER TABLE Grades ENABLE TRIGGER ALL	
	

End
GO
ALTER TABLE [dbo].[CustomGradeScaleGrades] ADD CONSTRAINT [PK_CustomGradeScaleGrades] PRIMARY KEY CLUSTERED ([GradeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CustomGradeScaleID] ON [dbo].[CustomGradeScaleGrades] ([CustomGradeScaleID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomGradeScaleGrades] ADD CONSTRAINT [FK_CustomGradeScaleGrades_CustomGradeScale] FOREIGN KEY ([CustomGradeScaleID]) REFERENCES [dbo].[CustomGradeScale] ([CustomGradeScaleID]) ON DELETE CASCADE
GO
