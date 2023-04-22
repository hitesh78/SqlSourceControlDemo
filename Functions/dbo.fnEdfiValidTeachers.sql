SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 9/7/2021
-- Description:	Returns a list of teachers that have all the correct required data for Data Exchange
-- 
-- =============================================
Create FUNCTION [dbo].[fnEdfiValidTeachers] ()
RETURNS 
@TeacherIDs TABLE
(
	TeacherID int NOT NULL PRIMARY KEY
)
AS
BEGIN

	Insert into @TeacherIDs
	Select TeacherID
	From Teachers
	Where
	Active = 1
	and
	isnull(rtrim(ltrim(StatePersonnelNumber)),'') != ''
	and 
	isnull(Fname,'') <> ''
	and 
	isnull(Lname,'') <> ''
	and
	isnull(Hiredate,'') <> ''
	and
	isnull(Hiredate,'') <> '1900-01-01'
	and
	(
		isnull(ltrim(rtrim(Email)),'') LIKE '%_@%_.__%'
		or
		isnull(ltrim(rtrim(Email2)),'') LIKE '%_@%_.__%'
		or
		isnull(ltrim(rtrim(Email3)),'') LIKE '%_@%_.__%'
	)
	and
	EmploymentType IN (select CodeValue from Lkg.dbo.edfiDescriptorsAndTypes where [Name] = 'EmploymentStatusDescriptor')

	RETURN

End
GO
