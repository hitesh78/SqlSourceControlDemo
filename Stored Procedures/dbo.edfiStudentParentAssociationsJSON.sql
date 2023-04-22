SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Joey
-- Create date: 08/10/2021
-- Modified dt: 12/02/2022
-- Description:	This returns the edfi student Parent ascn JSON
-- Parameters: Calendar Year, Re-added filter on Fname & Lname
-- =============================================
CREATE   PROCEDURE [dbo].[edfiStudentParentAssociationsJSON]
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
			@SchoolID + '_' + convert(nvarchar(20), sc.ContactID) as [parentReference.parentUniqueId],
			sm.StandTestID as [studentReference.studentUniqueId]
		from StudentContacts sc
			inner join Students s
			on s.StudentID = sc.StudentID
			left join StudentMiscFields sm
			on sm.StudentID = s.StudentID
		where 
		sc.StudentID in (select StudentID from @ValidStudentIDs)
		and 
		isnull(sc.Fname,'') <> ''
		and 
		isnull(sc.Lname,'') <> ''
		and
		sc.Relationship in ('Father', 'Mother') 
		and 
		sc.RolesAndPermissions = '(SIS Parent Contact)'
		FOR JSON PATH
	);


END
GO
