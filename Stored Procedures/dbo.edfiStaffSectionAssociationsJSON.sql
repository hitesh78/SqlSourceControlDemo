SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Joey
-- Create date: 01/13/2022
-- Modified dt: 06/15/2022
-- Description:	This returns the edfi staffsectionassociations JSON  
-- Parameters: Calendar Year
-- =============================================
CREATE     PROCEDURE [dbo].[edfiStaffSectionAssociationsJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@SPAJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	Declare @SchoolID nvarchar(50) = (SELECT EdFiDOESchoolID FROM IntegrationSettings Where ID = 1);

	set @SPAJSON = (
		select
			b.staffUniqueId as [staffReference.staffUniqueId],
			@SchoolID as [sectionReference.schoolId],
			b.classroomIdentificationCode as [sectionReference.classroomIdentificationCode],
			b.classPeriodName as [sectionReference.classPeriodName],
			MAX(b.localCourseCode) as [sectionReference.localCourseCode],
			'http://doe.in.gov/Descriptor/TermDescriptor.xml/' + b.termDescriptor as [sectionReference.termDescriptor],
			@SchoolYear as [sectionReference.schoolYear],
			b.uniqueSectionCode as [sectionReference.uniqueSectionCode],
			1 as [sectionReference.sequenceOfCourse],
			'http://doe.in.gov/Descriptor/ClassroomPositionDescriptor.xml/' + MAX(b.teacherRole) as [classroomPositionDescriptor],
			MAX(beginDate) as beginDate,
			MAX(endDate) as endDate
		from (
			select
				a.staffUniqueId,
				isnull(nullif(a.classroomIdentificationCode, ''), 'Classroom') as [classroomIdentificationCode],
				a.classPeriodName,
				a.localCourseCode,
				a.termDescriptor,
				isnull(nullif(a.classroomIdentificationCode, ''), 'Classroom') + a.localCourseCode + CONVERT(nvarchar(20), a.TeacherID) as [uniqueSectionCode],
				a.teacherRole,
				beginDate,
				endDate
			from (
				-- primary
				select
					c.TeacherID,
					t.StatePersonnelNumber as [staffUniqueId],
					CASE
						WHEN c.ScheduleType = 1
						THEN c.[Location]
						WHEN c.ScheduleType IN (2, 3)
						THEN (
							Select [Location] 
							From Locations 
							Where LocationID = Coalesce(
								nullif(c.LocationOnMonday,0),
								nullif(c.LocationOnTuesday,0),
								nullif(c.LocationOnWednesday,0),
								nullif(c.LocationOnThursday,0),
								nullif(c.LocationOnFriday,0),
								nullif(c.LocationOnSaturday,0),
								nullif(c.LocationOnSunday,0),
								nullif(c.BLocationOnMonday,0),
								nullif(c.BLocationOnTuesday,0),
								nullif(c.BLocationOnWednesday,0),
								nullif(c.BLocationOnThursday,0),
								nullif(c.BLocationOnFriday,0),
								nullif(c.BLocationOnSaturday,0),
								nullif(c.BLocationOnSunday,0), 0))				
						ELSE ''
					END as [classroomIdentificationCode],
					CASE
						WHEN c.ScheduleType = 1
						THEN (
							Select PeriodSymbol 
							From [Periods]
							Where PeriodID = c.[Period])
						WHEN c.ScheduleType IN (2, 3)
						THEN (
							Select PeriodSymbol 
							From [Periods]
							Where PeriodID = Coalesce(
								nullif(PeriodOnMonday,0),
								nullif(PeriodOnTuesday,0),
								nullif(PeriodOnWednesday,0),
								nullif(PeriodOnThursday,0),
								nullif(PeriodOnFriday,0),
								nullif(PeriodOnSaturday,0),
								nullif(PeriodOnSunday,0),
								nullif(BPeriodOnMonday,0),
								nullif(BPeriodOnTuesday,0),
								nullif(BPeriodOnWednesday,0),
								nullif(BPeriodOnThursday,0),
								nullif(BPeriodOnFriday,0),
								nullif(BPeriodOnSaturday,0),
								nullif(BPeriodOnSunday,0), 0))
						ELSE ''
					END as [classPeriodName],
					c.CourseCode as [localCourseCode],
					ep.[Sessions] as [termDescriptor],
					isnull(nullif(c.TeacherRole, ''), '0') as [teacherRole],
					cast(tm.StartDate as nvarchar(12)) as [beginDate],
					cast(tm.EndDate as nvarchar(12)) as [endDate]
				from Classes c 
					inner join Teachers t
						on t.TeacherID = c.TeacherID
					inner join dbo.fnEdfiValidTeachers() vt
						on t.TeacherID = vt.TeacherID
					inner join Terms tm
						on tm.TermID = c.TermID
					inner join EdfiPeriods ep
						on ep.EdfiPeriodID = tm.EdfiPeriodID
				where tm.StartDate >= @CalendarStartDate
					and tm.EndDate <= @CalendarEndDate
					and ISNULL(NULLIF(c.CourseCode, ''), 'N/A') <> 'N/A' -- covers 3 cases: null, blank and 'N/A'
					and c.ClassTypeID IN (1, 8) -- <> 5
				--
				UNION ALL
				-- secondary			
				select
					tc.TeacherID,
					t.StatePersonnelNumber as [staffUniqueId],
					CASE
						WHEN c.ScheduleType = 1
						THEN c.[Location]
						WHEN c.ScheduleType IN (2, 3)
						THEN (
							Select [Location] 
							From Locations 
							Where LocationID = Coalesce(
								nullif(c.LocationOnMonday,0),
								nullif(c.LocationOnTuesday,0),
								nullif(c.LocationOnWednesday,0),
								nullif(c.LocationOnThursday,0),
								nullif(c.LocationOnFriday,0),
								nullif(c.LocationOnSaturday,0),
								nullif(c.LocationOnSunday,0),
								nullif(c.BLocationOnMonday,0),
								nullif(c.BLocationOnTuesday,0),
								nullif(c.BLocationOnWednesday,0),
								nullif(c.BLocationOnThursday,0),
								nullif(c.BLocationOnFriday,0),
								nullif(c.BLocationOnSaturday,0),
								nullif(c.BLocationOnSunday,0), 0))				
						ELSE ''
					END as [classroomIdentificationCode],
					CASE
						WHEN c.ScheduleType = 1
						THEN (
							Select PeriodSymbol 
							From [Periods]
							Where PeriodID = c.[Period])
						WHEN c.ScheduleType IN (2, 3)
						THEN (
							Select PeriodSymbol 
							From [Periods]
							Where PeriodID = Coalesce(
								nullif(PeriodOnMonday,0),
								nullif(PeriodOnTuesday,0),
								nullif(PeriodOnWednesday,0),
								nullif(PeriodOnThursday,0),
								nullif(PeriodOnFriday,0),
								nullif(PeriodOnSaturday,0),
								nullif(PeriodOnSunday,0),
								nullif(BPeriodOnMonday,0),
								nullif(BPeriodOnTuesday,0),
								nullif(BPeriodOnWednesday,0),
								nullif(BPeriodOnThursday,0),
								nullif(BPeriodOnFriday,0),
								nullif(BPeriodOnSaturday,0),
								nullif(BPeriodOnSunday,0), 0))
						ELSE ''
					END as [classPeriodName],
					c.CourseCode as [localCourseCode],
					ep.[Sessions] as [termDescriptor],
					tc.TeacherRole as [teacherRole],
					cast(tm.StartDate as nvarchar(12)) as [beginDate],
					cast(tm.EndDate as nvarchar(12)) as [endDate]
				from TeachersClasses tc 
					inner join Teachers t
						on t.TeacherID = tc.TeacherID
					inner join dbo.fnEdfiValidTeachers() vt
						on t.TeacherID = vt.TeacherID
					inner join Classes c
						on c.ClassID = tc.ClassID
					inner join Terms tm
						on tm.TermID = c.TermID
					inner join EdfiPeriods ep
						on ep.EdfiPeriodID = tm.EdfiPeriodID
				where tm.StartDate >= @CalendarStartDate
					and tm.EndDate <= @CalendarEndDate
					and c.ClassTypeID IN (1, 8) -- <> 5
					and ISNULL(NULLIF(c.CourseCode, ''), 'N/A') <> 'N/A' -- covers 3 cases: null, blank and 'N/A'
					and ISNULL(tc.TeacherRole, '') <> ''
			) a
		) b
		group by b.staffUniqueId, b.uniqueSectionCode, termDescriptor, b.classroomIdentificationCode, b.classPeriodName
		FOR JSON PATH
	);

END
GO
