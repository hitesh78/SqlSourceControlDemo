SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









-- =============================================
-- Author:		Joey
-- Create date: 01/11/2022
-- Modified dt: 07/15/2022
-- Description:	This returns the edfi course transcript JSON
-- Parameters: Calendar Year 
-- =============================================
CREATE    PROCEDURE [dbo].[edfiCourseTranscriptsJSON]
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
		select distinct
			a.ClassID,
			1088000000 as [courseReference.educationOrganizationId],
			a.CourseCode as [courseReference.code],
			@SchoolID as [schoolReference.schoolId],
			a.StandTestID as [studentAcademicRecordReference.studentUniqueId],
			@SchoolID as [studentAcademicRecordReference.educationOrganizationId],
			@SchoolYear as [studentAcademicRecordReference.schoolYear],
			'http://doe.in.gov/Descriptor/TermDescriptor.xml/' + a.[Sessions] as [studentAcademicRecordReference.termDescriptor],
			a.TranscriptID as [alternativeCourseCode],
			a.[courseAttemptResultType],
			CASE 
				WHEN a.HighSchoolLevel = 0
				THEN NULL
				ELSE a.UnitsEarned
			END as [earnedCredits],
			CASE 
				WHEN a.courseAttemptResultType IN ('No grade awarded', 'Incomplete')
				THEN NULL
				WHEN a.HighSchoolLevel = 0
				THEN NULL
				ELSE a.CreditType
			END as [earnedCreditType],
			CASE
				WHEN a.HighSchoolLevel = 0
				THEN NULL
				WHEN a.courseAttemptResultType IN ('No grade awarded', 'Incomplete')
				THEN NULL
				ELSE GpaValue
			END as [finalNumericGradeEarned],
			CASE 
				WHEN (isnull(nullif(a.PostSecondaryInstitution, '00'), '') <> '')
				THEN 'http://doe.in.gov/Descriptor/PostSecondaryInstitutionDescriptor.xml/' + CONVERT(nvarchar(10), a.PostSecondaryInstitution)
				ELSE NULL 
			END as [postSecondaryInstitutionDescriptor]
		from (
			select
				tr.ClassID,
				tr.CourseCode,
				sm.StandTestID,
				e.[Sessions],
				tr.TranscriptID,
				tr.UnitsEarned,
				tr.UnitGPA,
				tr.PostSecondaryInstitution,
				tr.CreditType,
				tr.HighSchoolLevel,
				LTRIM(RTRIM(tr.GradeLevel)) as GradeLevel,
				CASE
					WHEN COALESCE(tr.LetterGrade, tr.AlternativeGrade, 'nm') = 'nm'
					THEN 'No grade awarded'
					WHEN isnull(tr.LetterGrade, '') <> '' -- is not null
					THEN (
							CASE WHEN tr.LetterGrade = 'CR' THEN 'Pass'
								 WHEN tr.LetterGrade = 'NC' THEN 'Fail'
								 else
									(select edfiCourseCompletionStatus 
									from CustomGradeScaleGrades c 
									where c.CustomGradeScaleID = tr.CustomGradeScaleID
									and c.GradeSymbol = tr.LetterGrade) END
						)
					ELSE 'No grade awarded'
				END as [courseAttemptResultType],
				CASE
					WHEN (tr.LetterGrade IN ('A+','A','A-') or (tr.PercentageGrade >= 90 and tr.LetterGrade = 'CR')) THEN '4.0'
					WHEN (tr.LetterGrade IN ('B+','B','B-') or (tr.PercentageGrade >= 80 and tr.PercentageGrade < 90 and tr.LetterGrade = 'CR')) THEN '3.0'
					WHEN (tr.LetterGrade IN ('C+','C','C-') or (tr.PercentageGrade >= 70 and tr.PercentageGrade < 80 and tr.LetterGrade = 'CR')) THEN '2.0'
					WHEN (tr.LetterGrade IN ('D+','D','D-') or (tr.PercentageGrade < 70 and tr.LetterGrade = 'CR') or (tr.PercentageGrade >= (select CreditNoCreditPassingGrade from Settings))) THEN '1.0'
					ELSE '0.0'
				END as [GpaValue]
		from Transcript tr
			inner join Students s
				on s.StudentID = tr.StudentID
			inner join Terms t
				on t.TermID = tr.TermID
			left join StudentMiscFields sm
				on sm.StudentID = s.StudentID
			inner join EdfiPeriods e
				on t.EdfiPeriodID = e.EdfiPeriodID
		where s.StudentID in (select StudentID from @ValidStudentIDs)
			and t.ExamTerm = 0        -- exclude exam terms
			and t.TermID not in (Select ParentTermID From Terms)
			and t.StartDate >= @CalendarStartDate
			and t.EndDate <= @CalendarEndDate
			and isnull(nullif(tr.CourseCode, ''), 'N/A') <> 'N/A'
			and tr.ClassTypeID IN (1, 8)
		) a
		FOR JSON PATH
	);


END
GO
