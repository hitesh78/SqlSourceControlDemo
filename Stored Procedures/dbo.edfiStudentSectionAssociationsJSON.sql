SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Joey
-- Create date: 11/16/2021
-- Modified dt: 06/15/2022
-- Description:	This returns the edfi StudentSectionAssociation JSON 
-- Parameters: Calendar Year 
-- =============================================
CREATE             PROCEDURE [dbo].[edfiStudentSectionAssociationsJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@SJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	Declare @ValidStudentIDs table (StudentID int PRIMARY KEY);
	Insert into @ValidStudentIDs
	Select StudentID
	From dbo.fnEdfiValidStudents(@CalendarStartDate, @CalendarEndDate);

	Declare @SchoolID nvarchar(50) = (SELECT EdFiDOESchoolID FROM IntegrationSettings Where ID = 1);


	set @SJSON = (
		select 
			@SchoolID as [sectionReference.schoolId],
			b.PeriodSymbol as [sectionReference.classPeriodName],
			MAX(b.[Location]) as [sectionReference.classroomIdentificationCode],
			MAX(b.CourseCode) as [sectionReference.localCourseCode],
			'http://doe.in.gov/Descriptor/TermDescriptor.xml/' + b.[Sessions] as [sectionReference.termDescriptor],
			@SchoolYear as [sectionReference.schoolYear],
			b.uniqueSectionCode as [sectionReference.uniqueSectionCode],
			1 as [sectionReference.sequenceOfCourse],
			b.StandTestID as [studentReference.studentUniqueId],
			MAX(b.StartDate) as [beginDate],
			MAX(b.EndDate) as [endDate]
		from (
			Select 
				a.PeriodSymbol,
				isnull(nullif(a.[Location], ''), 'Classroom') as [Location],
				a.CourseCode,
				a.[Sessions],
				isnull(nullif(a.[Location], ''), 'Classroom') + a.CourseCode + CONVERT(nvarchar(20), a.TeacherID) as [uniqueSectionCode],
				a.StandTestID,
				a.StartDate,
				a.EndDate
			From (
				Select 
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
					END as [PeriodSymbol],
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
					END as [Location],
					c.TeacherID,
					c.CourseCode,
					ep.[Sessions],
					cast(t.StartDate as date) as StartDate,
					cast(t.EndDate as date) as EndDate,
					sm.StandTestID
				From Classes c
					inner join Terms t
						on t.TermID = c.TermID
					inner join EdfiPeriods ep
						on ep.EdfiPeriodID = t.EdfiPeriodID
					inner join ClassesStudents cs
						on c.ClassID = cs.ClassID
					inner join Students s
						on cs.StudentID = s.StudentID
					inner join StudentMiscFields sm
						on s.StudentID = sm.StudentID
				Where t.StartDate >= @CalendarStartDate
					and t.EndDate <= @CalendarEndDate
					and ISNULL(NULLIF(c.CourseCode, ''), 'N/A') <> 'N/A' -- covers 3 cases: null, blank and 'N/A'
					and c.ClassTypeID IN (1, 8) -- <> 5
					and s.StudentID in (select StudentID from @ValidStudentIDs)
			) a
		) b
		group by b.uniqueSectionCode, b.Sessions, b.StandTestID, b.PeriodSymbol
		FOR JSON PATH
	);

END
GO
