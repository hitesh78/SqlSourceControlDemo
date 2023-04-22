SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 11/29/2016
-- Description:	Returns Data for the Apple School Manager Export
-- =============================================
CREATE Procedure [dbo].[AppleSchoolManagerExport]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	DECLARE @NL nCHAR(2) = CHAR(13) + CHAR(10);

	-- Get Locations
	Select
	'gl' + DB_NAME() as location_id,
	isnull(REPLACE(SchoolName, '"', '\"'),'')as location_name
	From 
	Settings
	Where 
	SettingID = 1


	-- Get Staff
	Select
	'glt' + DB_NAME() + convert(nvarchar(10),TeacherID) as person_id,
	'glt' + DB_NAME() + convert(nvarchar(10),TeacherID) as person_number,
	isnull(REPLACE(Fname, '"', '\"'),'') as first_name,
	isnull(REPLACE(Mname, '"', '\"'),'') as middle_name,
	isnull(REPLACE(Lname, '"', '\"'),'') as last_name,
	isnull(Email,'') as email_address,
	'gl' + DB_NAME() + isnull(REPLACE(AccountID, '"', '\"'),'') as sis_username,
	'gl' + DB_NAME() as location_id
	From
	Teachers
	Where
	TeacherID in 
	(
		Select C.TeacherID
		From
		ClassesStudents CS
			inner join
		Classes C
			on C.ClassID = CS.ClassID
			inner join
		Terms T
			on C.TermID = T.TermID
		Where
		C.ClassID != 135
		and
		C.ParentClassID = 0
		and
		(
		C.ClassTypeID in (1,8)
		or
		C.ClassTypeID > 99
		)
		and
		T.Status = 1	

		Union

		Select TC.TeacherID
		From
		ClassesStudents CS
			inner join
		Classes C
			on C.ClassID = CS.ClassID
			inner join
		Terms T
			on C.TermID = T.TermID
			inner join
		TeachersClasses TC
			on TC.TeacherID != C.TeacherID and TC.ClassID = C.ClassID
		Where
		C.ClassID != 135
		and
		C.ParentClassID = 0
		and
		(
		C.ClassTypeID in (1,8)
		or
		C.ClassTypeID > 99
		)
		and
		T.Status = 1	

	)


	-- Get Students

	Declare @ProfileID int = (Select ProfileID From ReportProfiles Where ReportName = 'MiscSettings')
	Declare @ASME_ReplaceFnameWithNickName nvarchar(10) = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Apple School Manager - Replace Student FirstName with NickName')


	Select distinct
	'gls' + DB_NAME() + convert(nvarchar(10),S.StudentID) as person_id,
	'gls' + DB_NAME() + convert(nvarchar(10),S.xStudentID) as person_number,
	case 
		when @ASME_ReplaceFnameWithNickName = 'yes' and ltrim(rtrim(isnull(S.NickName,''))) != '' then isnull(REPLACE(S.NickName, '"', '\"'),'')
		else isnull(REPLACE(S.Fname, '"', '\"'),'') 
	end as first_name,
	isnull(REPLACE(S.Mname, '"', '\"'),'') as middle_name,
	isnull(REPLACE(S.Lname, '"', '\"'),'') as last_name,
	isnull(S.GradeLevel,'') as grade_level,
	case
		when (select ASMUseStudentEmail from settings) = 1 then isnull(SchoolEmail,'')
		else isnull(Email1,'')
	end as email_address,
	'gl' + DB_NAME() + isnull(REPLACE(S.AccountID, '"', '\"'),'') as sis_username,
	'' as password_policy,
	'gl' + DB_NAME() as location_id
	From 
	Students S
		inner join
	ClassesStudents CS
		on S.StudentID = CS.StudentID
		inner join
	Classes C
		on CS.ClassID = C.ClassID
		inner join
	Terms T
		on C.TermID = T.TermID
	Where
	T.Status = 1



	-- Get Courses
	Select distinct
	isnull(REPLACE(C.ClassTitle, '"', '\"'),'') as course_id, 
	isnull(C.CourseCode,'') as course_number,
	isnull(REPLACE(C.ReportTitle, '"', '\"'),'') as course_name,
	'gl' + DB_NAME() as location_id
	From
	ClassesStudents CS
		inner join
	Classes C
		on C.ClassID = CS.ClassID
		inner join
	Terms T
		on C.TermID = T.TermID
	Where
	C.ClassID != 135
	and
	C.ParentClassID = 0
	and
	(
	C.ClassTypeID in (1,8)
	or
	C.ClassTypeID > 99
	)
	and
	T.Status = 1


	-- Get Classes
	Select distinct
	C.ClassID as class_id,
	'' as class_number,
	isnull(REPLACE(C.ClassTitle, '"', '\"'),'') as course_id,
	'glt' + DB_NAME() + convert(nvarchar(10),C.TeacherID) as instructor_id,
	isnull('glt' + DB_NAME() +
		convert(nvarchar(20), 
			(
			Select top 1 TeacherID 
			From 
			TeachersClasses 
			Where ClassID = C.ClassID and TeacherID != C.TeacherID and TeacherID > 0
			) 
		)
	,'') as instructor_id_2,
	'' as instructor_id_3,
	'gl' + DB_NAME() as location_id
	From
	ClassesStudents CS
		inner join
	Classes C
		on C.ClassID = CS.ClassID
		inner join
	Terms T
		on C.TermID = T.TermID
	Where
	C.ClassID != 135
	and
	C.ParentClassID = 0
	and
	(
	C.ClassTypeID in (1,8)
	or
	C.ClassTypeID > 99
	)
	and
	T.Status = 1



	-- Get Roster
	Select distinct
	CS.CSID as roster_id,
	CS.ClassID as class_id,
	'gls' + DB_NAME() + convert(nvarchar(10),CS.StudentID) as student_id
	From
	ClassesStudents CS
		inner join
	Classes C
		on C.ClassID = CS.ClassID
		inner join
	Terms T
		on C.TermID = T.TermID
	Where
	C.ClassID != 135
	and
	C.ParentClassID = 0
	and
	(
	C.ClassTypeID in (1,8)
	or
	C.ClassTypeID > 99
	)
	and
	T.Status = 1


END
GO
