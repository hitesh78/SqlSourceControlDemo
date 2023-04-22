SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 2/14/2022
-- Description:	Get List of Secondary Teachers along with their Teacher Role
-- =============================================
CREATE   PROCEDURE [dbo].[GetSecondaryTeachers]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @temp table(ID int identity(1,1), TeacherID int, Lname nvarchar(100), Fname nvarchar(100), glname nvarchar(100), StaffRoles nvarchar(50))
	Declare @TeacherRoles table (TeacherID int, Lname nvarchar(100), Fname nvarchar(100), glname nvarchar(100), TeacherRole nvarchar(50))

	Insert into @temp (TeacherID, Lname, Fname, glname, StaffRoles)
	Select 
	TeacherID,
	Lname,
	Fname,
	glname,
	StaffRoles
	From Teachers
	where 
	StaffType = 1
	and
	Active = 1
	and
	TeacherID <> -1

	Declare @NumLines int = @@RowCount
	Declare @LineNumber int = 1
	Declare 
	@TeacherID int,
	@Lname nvarchar(50),
	@Fname nvarchar(50),
	@glname nvarchar(50),
	@StaffRoles nvarchar(50)

	While @LineNumber <= @NumLines
	Begin

		Select 
		@TeacherID = TeacherID,
		@Lname = Lname,
		@Fname = Fname,
		@glname = glname,
		@StaffRoles = StaffRoles
		From @temp 
		Where ID = @LineNumber; 

		Insert into @TeacherRoles (TeacherID, Lname, Fname, glname, TeacherRole)
		select 
		@TeacherID as TeacherID,
		@Lname as Lname,
		@Fname as Fname,
		@glname as glname,
		value
		From string_split(@StaffRoles,',')

		Set @LineNumber = @LineNumber + 1

	End



	Select distinct
	1 as tag,
	null as parent,
	-- append * as TeacherID 127 and 27 where both being disabled when only 27 schould have been
	'*' + convert(nvarchar(10),TeacherID) + ':' + convert(nvarchar(30),TeacherRole) as [Staff!1!TeacherID],
	case
		when TeacherRole = '4' then glname + ' - Co-Teacher'
		when TeacherRole = 'EL Co-Teacher' then glname + ' - EL Co-Teacher'
		else glname
	end as [Staff!1!TeacherName]
	From @TeacherRoles
	Where
	TeacherRole in ('0', '4', 'EL Co-Teacher')
	Order By 
	[Staff!1!TeacherName], [Staff!1!TeacherID]
	FOR XML EXPLICIT

END
GO
