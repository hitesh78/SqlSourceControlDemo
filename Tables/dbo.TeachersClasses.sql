CREATE TABLE [dbo].[TeachersClasses]
(
[TCID] [int] NOT NULL IDENTITY(1, 1),
[TeacherID] [int] NOT NULL,
[ClassID] [int] NOT NULL,
[TeacherRole] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateLPClassViewForSecondaryTeacherOnInsert]
 on [dbo].[TeachersClasses]
 After Insert
As


--First add TeacherTerm record if one does not exist for Secondary Teacher
insert into TeacherTerms (TeacherID, TermID) 
Select x.TeacherID, x.TermID
From
(
Select distinct
I.TeacherID, C.TermID
From 
Inserted I
	inner join
Classes C
	on I.ClassID = C.ClassID
) x
Where
not exists
(
Select * From TeacherTerms
Where
TeacherID = x.TeacherID
and
TermID = x.TermID
)

	



-- Second Update the New Teacher's CalendarDisplayClasses value
Update TeacherTerms
Set 
CalendarDisplayClasses = 
(
SELECT Stuff(
  (SELECT N', ' + ClassTitle From Classes 
	Where
	(
		TeacherID = I.TeacherID
		or
		ClassID in (Select ClassID From TeachersClasses Where TeacherID = I.TeacherID)
	)
	and
	TermID = I.TermID
	and
	ClassTypeID in (1,8)
  FOR XML PATH(''),TYPE)
  .value('text()[1]','nvarchar(max)'),1,2,N'')
),
AdminCalendarDisplayClasses = 
(
SELECT Stuff(
  (SELECT N', ' + ClassTitle From Classes 
	Where
	(
		TeacherID = I.TeacherID
		or
		ClassID in (Select ClassID From TeachersClasses Where TeacherID = I.TeacherID)
	)
	and
	TermID = I.TermID
	and
	ClassTypeID in (1,8)
  FOR XML PATH(''),TYPE)
  .value('text()[1]','nvarchar(max)'),1,2,N'')
)
From
TeacherTerms TT
	inner join
(
	Select I.TeacherID, C.TermID
	From 
	Inserted I
		inner join
	Classes C
		on I.ClassID = C.ClassID	
) I
on
	TT.TeacherID = I.TeacherID and TT.TermID = I.TermID
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateLPClassViewOnNewSecondaryTeacher]
 on [dbo].[TeachersClasses]
 After Insert
As


Update TeacherTerms
Set 
CalendarDisplayClasses = 
(
SELECT Stuff(
  (SELECT N', ' + ClassTitle From Classes 
	Where
	(
		TeacherID = I.TeacherID
		or
		ClassID in (Select ClassID From TeachersClasses Where TeacherID = I.TeacherID)
	)
	and
	TermID = I.TermID
	and
	ClassTypeID in (1,8)
  FOR XML PATH(''),TYPE)
  .value('text()[1]','nvarchar(max)'),1,2,N'')
),
AdminCalendarDisplayClasses = 
(
SELECT Stuff(
  (SELECT N', ' + ClassTitle From Classes 
	Where
	(
		TeacherID = I.TeacherID
		or
		ClassID in (Select ClassID From TeachersClasses Where TeacherID = I.TeacherID)
	)
	and
	TermID = I.TermID
	and
	ClassTypeID in (1,8)
  FOR XML PATH(''),TYPE)
  .value('text()[1]','nvarchar(max)'),1,2,N'')
)
From
TeacherTerms TT
	inner join
(
	Select 
	I.TeacherID, 
	(Select TermID From Classes Where ClassID = I.ClassID) as TermID
	From 
	Inserted I
) I
on
	TT.TeacherID = I.TeacherID 
GO
ALTER TABLE [dbo].[TeachersClasses] ADD CONSTRAINT [PK_TeachersClasses] PRIMARY KEY CLUSTERED ([TCID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ClassID] ON [dbo].[TeachersClasses] ([ClassID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TeacherID] ON [dbo].[TeachersClasses] ([TeacherID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TeachersClasses] ADD CONSTRAINT [FK_TeachersClasses_Classes] FOREIGN KEY ([ClassID]) REFERENCES [dbo].[Classes] ([ClassID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[TeachersClasses] ADD CONSTRAINT [FK_TeachersClasses_Teachers] FOREIGN KEY ([TeacherID]) REFERENCES [dbo].[Teachers] ([TeacherID]) ON DELETE CASCADE
GO
