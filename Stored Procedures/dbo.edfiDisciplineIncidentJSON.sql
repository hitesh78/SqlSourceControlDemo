SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Joey
-- Create date: 11/03/2021
-- Modified dt: 06/29/2022
-- Description:	This returns the edfi discipline incident JSON 
-- Parameters: Calendar Year 
-- =============================================
CREATE   PROCEDURE [dbo].[edfiDisciplineIncidentJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@DIJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	Declare @SchoolID nvarchar(50) = (SELECT EdFiDOESchoolID FROM IntegrationSettings Where ID = 1);

	Declare @SchoolType nvarchar(50) = (Select SchoolType From Settings Where SettingID = 1);

	set @DIJSON = (
		Select
			@SchoolID as [schoolReference.schoolId],
			t.StatePersonnelNumber as [staffReference.staffUniqueId],
			cast(convert(date, d.DateOfIncident) as nvarchar(12)) as [incidentDate],
			d.DisciplineID as [incidentIdentifier],
			(
				Select distinct
					'http://doe.in.gov/Descriptor/BehaviorDescriptor.xml/' + 
					CASE
						WHEN RTRIM(LTRIM(value)) in (Select CodeValue From LKG.dbo.EdFiIncidentTypes)
						THEN RTRIM(LTRIM(value))
						ELSE 'Other'
					END as [behaviorDescriptor]
					From Discipline dd
						CROSS APPLY string_split(IncidentCodes, ';')
					where dd.DisciplineID = d.DisciplineID
				FOR JSON PATH
			) as [behaviors]
		From Discipline d
			inner join Teachers t
				on t.TeacherID = d.TeacherID
			inner join dbo.fnEdfiValidTeachers() vt
				on t.TeacherID = vt.TeacherID
		Where d.DateOfIncident between @CalendarStartDate and @CalendarEndDate
			and @SchoolType = 'PublicSchool'
		FOR JSON PATH
	);

END
GO
