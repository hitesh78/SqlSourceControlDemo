SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 7/15/2020
-- Description:	Exports Transcript Info. Used for the "Export" button within the Transcript tab.
-- =============================================
CREATE PROCEDURE [dbo].[TranscriptExport]
AS
BEGIN
	SET NOCOUNT ON;


Select 
TranscriptID,
TermID,
TermTitle,
TermStart,
TermEnd,
StudentID,
GradeLevel,
Fname,
Mname,
Lname,
StaffTitle,
TFname,
TLname,
ClassID,
ClassTitle,
ClassUnits,
UnitsEarned,
Period,
LetterGrade,
AlternativeGrade,
PercentageGrade,
GPAPoints,
ConcludeDate,
GPABoost,
CalculateGPA
From
(
	Select 
	0 as tag,
	'TranscriptID' as TranscriptID,
	'TermID' as TermID,
	'TermTitle' as TermTitle,
	'TermStart' as TermStart,
	'TermEnd' as TermEnd,
	'StudentID' as StudentID,
	'GradeLevel' as GradeLevel,
	'Fname' as Fname,
	'Mname' as Mname,
	'Lname' as Lname,
	'StaffTitle' as StaffTitle,
	'TFname' as TFname,
	'TLname' as TLname,
	'ClassID' as ClassID,
	'ClassTitle' as ClassTitle,
	'ClassUnits' as ClassUnits,
	'UnitsEarned' as UnitsEarned,
	'Period' as [Period],
	'LetterGrade' as LetterGrade,
	'AlternativeGrade' as AlternativeGrade,
	'PercentageGrade' as PercentageGrade,
	'GPAPoints' as GPAPoints,
	'ConcludeDate' as ConcludeDate,
	'GPABoost' as GPABoost,
	'CalculateGPA' as CalculateGPA

	Union

	SELECT 1 as tag
		  , convert(nvarchar(100),[TranscriptID]) as TranscriptID
		  ,convert(nvarchar(100),[TermID]) as TermID
		  ,isnull(replace(rtrim(ltrim(TermTitle)), ',', ' '),'') as TermTitle
		  ,convert(nvarchar(100),convert(date, TermStart)) as TermStart
		  ,convert(nvarchar(100),convert(date, TermEnd)) as TermEnd
		  ,convert(nvarchar(100),[StudentID]) as StudentID
		  ,isnull(replace(rtrim(ltrim(GradeLevel)), ',', ' '),'') as GradeLevel
		  ,isnull(replace(rtrim(ltrim(Fname)), ',', ' '),'') as Fname
		  ,isnull(replace(rtrim(ltrim(Mname)), ',', ' '),'') as Mname
		  ,isnull(replace(rtrim(ltrim(Lname)), ',', ' '),'') as Lname
		  ,isnull(replace(rtrim(ltrim(StaffTitle)), ',', ' '),'') as StaffTitle
		  ,isnull(replace(rtrim(ltrim(TFname)), ',', ' '),'') as TFname
		  ,isnull(replace(rtrim(ltrim(TLname)), ',', ' '),'') as TLname
		  ,convert(nvarchar(100),[ClassID]) as ClassID
		  ,isnull(replace(rtrim(ltrim(ClassTitle)), ',', ' '),'') as ClassTitle
		  ,convert(nvarchar(100),[ClassUnits]) as ClassUnits
		  ,convert(nvarchar(100),[UnitsEarned]) as UnitsEarned
		  ,isnull(replace(rtrim(ltrim(Period)), ',', ' '),'') as [Period]
		  ,isnull(replace(rtrim(ltrim(LetterGrade)), ',', ' '),'') as LetterGrade
		  ,isnull(replace(rtrim(ltrim(AlternativeGrade)), ',', ' '),'') as AlternativeGrade
		  ,convert(nvarchar(100),[PercentageGrade]) as PercentageGrade
		  ,convert(nvarchar(100),[UnitGPA]) as GPAPoint
		  ,convert(nvarchar(100),[ConcludeDate]) as ConcludeDate
		  ,convert(nvarchar(100),[GPABoost]) as GPABoost
		  ,convert(nvarchar(100),[CalculateGPA]) as CalculateGPA
	  FROM [Transcript]
	  Where 
	  ClassTypeID in (1,8) 
	  and 
	  ParentClassID = 0
) x
Order By x.tag
END
GO
