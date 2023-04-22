SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Joey
-- Create date: 12/17/2021
-- Modified dt: 01/18/2021
-- Description:	This returns the edfi discipline action JSON 
-- Parameters: Calendar Year
-- =============================================
CREATE         PROCEDURE [dbo].[edfiDisciplineActionsJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@DIJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;
	
	Declare @ValidStudentIDs table (StudentID int PRIMARY KEY);
	Insert into @ValidStudentIDs
	Select StudentID
	From dbo.fnEdfiValidStudents(@CalendarStartDate, @CalendarEndDate);

	Declare @SchoolID nvarchar(50) = (SELECT EdFiDOESchoolID FROM IntegrationSettings Where ID = 1);

	Declare @SchoolType nvarchar(50) = (Select SchoolType From Settings Where SettingID = 1);

	Declare @SchoolDayHours int = (SELECT CAST(ROUND(DATEDIFF(MINUTE, DailyBeginTime, DailyEndTime)/60.0, 0) as int) FROM EdfiODS Where SchoolYear = @SchoolYear);

	set @DIJSON = (
		Select
			@SchoolID as [assignmentSchoolReference.schoolId],
			@SchoolID as [responsibilitySchoolReference.schoolId],
			sm.StandTestID as [studentReference.studentUniqueId],
			CASE
				-- Units: days
				WHEN DA.Duration IS NOT NULL AND DA.Units = 'Days'
				THEN cast(convert(decimal, DA.Duration) as int)
				-- Units: hours
				WHEN DA.Duration IS NOT NULL AND DA.Units = 'Hours'
				THEN cast(ROUND(convert(decimal, DA.Duration)/@SchoolDayHours, 0) as int)
				-- Units: mins
				WHEN DA.Duration IS NOT NULL AND DA.Units = 'Minutes'
				THEN cast(ROUND((convert(decimal, DA.Duration)/60)/@SchoolDayHours, 0) as int)
				-- Start - End
				WHEN DA.StartDate IS NOT NULL AND DA.EndDate IS NOT NULL
				THEN DATEDIFF(DAY, DA.StartDate, DA.EndDate)
				ELSE 1
			END as [actualDisciplineActionLength],
			DA.xml_pk_id as [identifier],
			cast(COALESCE(DA.StartDate, d.DateOfIncident) as date) as [disciplineDate],
			(
				Select 'http://doe.in.gov/Descriptor/DisciplineDescriptor.xml/' + DA.ActionTaken as [disciplineDescriptor]
				FOR JSON PATH
			) as [disciplines],
			(
				select 
					d.DisciplineID as [disciplineIncidentReference.incidentIdentifier],
					@SchoolID as [disciplineIncidentReference.schoolId]
				FOR JSON PATH
			) as [disciplineIncidents]
		From (
			Select
				xml_pk_id,
				table_pk_id,
				(
					SELECT
					doc.col.value('Type[1]', 'nvarchar(50)')
					FROM xml_fields.nodes('.') doc(col) 
				) as ActionTaken,
				(
					SELECT
					doc.col.value('NumUnits[1]', 'nvarchar(10)')
					FROM xml_fields.nodes('.') doc(col) 
				) as Duration,
				(
					SELECT
					doc.col.value('Units[1]', 'nvarchar(20)')
					FROM xml_fields.nodes('.') doc(col) 
				) as Units,	
				(
					SELECT
					doc.col.value('StartDate[1]', 'nvarchar(50)')
					FROM xml_fields.nodes('.') doc(col) 
				) as StartDate,
				(
					SELECT
					doc.col.value('EndDate[1]', 'nvarchar(50)')
					FROM xml_fields.nodes('.') doc(col) 
				) as EndDate
			From xml_records X
			Where X.entityName like '%DisciplineActionTaken%'
		) as DA
			inner join Discipline d
				on d.DisciplineID = DA.table_pk_id
			inner join dbo.fnEdfiValidTeachers() vt
				on d.TeacherID = vt.TeacherID
			inner join StudentMiscFields sm
				on sm.StudentID = d.StudentID
		Where d.DateOfIncident between @CalendarStartDate and @CalendarEndDate
			and DA.ActionTaken IN (select Title from vSelectOptions where SelectListID = 12)
			and d.StudentID in (select StudentID from @ValidStudentIDs)
			and @SchoolType = 'PublicSchool'
		FOR JSON PATH
	);

END
GO
