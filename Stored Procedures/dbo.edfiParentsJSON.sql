SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Joey
-- Create date: 08/06/2021
-- Modified dt: 10/07/2022
-- Description:	This returns the edfi Parents JSON
-- Parameters: Calendar Year --  Fname or Lname
-- =============================================
CREATE    PROCEDURE [dbo].[edfiParentsJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@SPAJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;
	
	Declare @SchoolID nvarchar(50) = (SELECT EdFiDOESchoolID FROM IntegrationSettings Where ID = 1);

	Declare @ValidStudentIDs table (StudentID int PRIMARY KEY);
	Insert into @ValidStudentIDs
	Select StudentID
	From dbo.fnEdfiValidStudents(@CalendarStartDate, @CalendarEndDate);

	set @SPAJSON = (
		select 
			Fname as [firstName],
			isnull(Lname,'') as [lastSurname],
			@SchoolID + '_' + convert(nvarchar(20), sc.ContactID) as [parentUniqueId]
		from StudentContacts sc
		where 
		sc.StudentID in (select StudentID from @ValidStudentIDs)
		and 
		(isnull(Fname,'') <> ''
		or 
		isnull(Lname,'') <> '')
		and
		Relationship in ('Father', 'Mother') 
		and 
		RolesAndPermissions = '(SIS Parent Contact)'
		FOR JSON PATH
	);


END
GO
