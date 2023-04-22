SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Joey
-- Create date: 10/14/2021
-- Modified dt: 10/15/2021
-- Description:	
-- =============================================
CREATE       PROCEDURE [dbo].[edfiLocationsJSON]
--@SchoolYear int,
--@CalendarStartDate date,
--@CalendarEndDate date,
@SPAJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	Declare @SchoolID nvarchar(50) = (SELECT EdFiDOESchoolID FROM IntegrationSettings Where ID = 1);

	set @SPAJSON = (
		Select 
			@SchoolID as [schoolReference.schoolId],
			[Location] as [classroomIdentificationCode]
		From (
			Select
				'Classroom' as [Location]
			UNION
			select 
				[Location]
			from Locations 
			Where isnull([Location], '') <> ''
			UNION
			Select distinct
				[Location]
			from Classes
			where ISNULL([Location], '') <> ''
			) a
		FOR JSON PATH
	);

END
GO
