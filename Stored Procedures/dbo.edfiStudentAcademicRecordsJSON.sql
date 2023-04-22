SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Joey
-- Create date: 01/12/2022
-- Modified dt: 03/23/2023
-- Description:	edfi student academic records   
-- Rev. Notes:	adds distinct to edfiDescriptorsAndTypes queries
-- =============================================
CREATE       PROCEDURE [dbo].[edfiStudentAcademicRecordsJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@SPAJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;
	
	Declare @TermStartDate nvarchar(12);
	Declare @TermEndDate nvarchar(12);

	Declare @SchoolType nvarchar(50) = (Select SchoolType From Settings Where SettingID = 1);
	Declare @SchoolID nvarchar(50) = (SELECT EdFiDOESchoolID FROM IntegrationSettings Where ID = 1);

	Declare @ValidStudentIDs table (StudentID int PRIMARY KEY);
	Insert into @ValidStudentIDs
	Select StudentID
	From dbo.fnEdfiValidStudents(@CalendarStartDate, @CalendarEndDate);

	Declare @ValidTerms table (TermID int, StartDate datetime, EndDate datetime, TermDesc nvarchar(100))
	INSERT INTO @ValidTerms
	SELECT 
		TermID,
		StartDate,
		EndDate,
		e.[Sessions] as TermDesc
	FROM Terms t
		inner join EdfiPeriods e
			on e.EdfiPeriodID = t.EdfiPeriodID
	WHERE t.ExamTerm = 0	-- exclude exam terms
		and t.TermID not in (Select ParentTermID From Terms)
		and t.StartDate >= @CalendarStartDate
		and t.EndDate <= @CalendarEndDate;

	Declare @AttendanceEvents table (ID nvarchar(10), edfiAttendanceEvent nvarchar(50));
	Insert into @AttendanceEvents
	Select
		A.ID,
		EA.edfiAttendanceEvent 
	From AttendanceSettings A
		inner join EdfiAttendanceEvents EA
			on A.edfiAttendanceEventID = EA.edfiAttendanceEventID
	Where A.MultiSelect = 0 and A.ExcludedAttendance = 0;

	Declare @StudentIDsWithAttendance table (StudentID int PRIMARY KEY, StudentFirstAttendanceDate date);
	Insert into @StudentIDsWithAttendance
	Select distinct
		S.StudentID,
		min(A.ClassDate) as StudentFirstAttendanceDate
	From Terms T
		inner join EdfiPeriods E
			on T.EdfiPeriodID = E.EdfiPeriodID
		inner join Classes C
			on T.TermID = C.TermID
		inner join ClassesStudents CS
			on C.ClassID = CS.ClassID
		inner join Attendance A
			on A.CSID = CS.CSID
		inner join Students S
			on S.StudentID = CS.StudentID
	Where T.ExamTerm = 0 -- exclude exam terms
	and T.TermID not in (Select ParentTermID From Terms)
	and T.StartDate >= @CalendarStartDate
	and T.EndDate <= @CalendarEndDate
	and C.ClassTypeID = 5
	and S.StudentID in (select StudentID from @ValidStudentIDs)
	and case
		when A.Att1 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att1')
		when A.Att2 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att2')
		when A.Att3 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att3')
		when A.Att4 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att4')
		when A.Att5 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att5')
		when A.Att6 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att6')
		when A.Att7 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att7')
		when A.Att8 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att8')
		when A.Att9 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att9')
		when A.Att10 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att10')
		when A.Att11 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att11')
		when A.Att12 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att12')
		when A.Att13 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att13')
		when A.Att14 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att14')
		when A.Att15 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att15')
	end is not null
	Group By S.StudentID;

	Select 
		@TermStartDate = StartDate,
		@TermEndDate = EndDate
	From dbo.fnGetStartEndDatesByYear(@SchoolYear);

	Declare @diplomaLevelTypes table (CodeValue nvarchar(20) PRIMARY KEY, ShortDescription nvarchar(250));
	INSERT into @diplomaLevelTypes
	SELECT distinct CodeValue, ShortDescription 
	FROM LKG.dbo.edfiDescriptorsAndTypes where [Name] = 'DiplomaLevelType';
		
	Declare @achievementCategories table (CodeValue nvarchar(250) PRIMARY KEY);
	INSERT INTO @achievementCategories
	SELECT distinct CodeValue
	FROM LKG.dbo.edfiDescriptorsAndTypes where [Name] = 'AchievementCategoryDescriptor';

	set @SPAJSON = (
		select
			@SchoolID as [educationOrganizationReference.educationOrganizationId],
			@SchoolYear as [schoolYearTypeReference.schoolYear],
			b.StandTestID as [studentReference.studentUniqueId],
			'http://doe.in.gov/Descriptor/TermDescriptor.xml/' + t.TermDesc as [termDescriptor],
			(
				SELECT distinct
					ts.DiplomaType as [diplomaType],
					dt.ShortDescription as [diplomaLevelType],
					cast(convert(date, b.GraduationDate) as nvarchar(12)) as [diplomaAwardDate]
				FROM Tests ts
					inner join @diplomaLevelTypes dt
						on dt.CodeValue = ts.DiplomaLevelType
				WHERE ts.StudentID = b.StudentID
					and ts.Item = 'Degree'
					and isnull(CONVERT(nvarchar(20),b.GraduationDate), '') <> ''
				FOR JSON PATH
			) as [diplomas],
			(
				SELECT distinct
					ts.RecognitionType as [recognitionType],
					'http://doe.in.gov/Descriptor/AchievementCategoryDescriptor.xml/' + ts.AchievementCategory as [achievementCategoryDescriptor],
					ts.LocalPathway as [achievementCategorySystem]
				FROM Tests ts
					inner join @achievementCategories a
						on a.CodeValue = ts.AchievementCategory
				WHERE ts.StudentID = b.StudentID
					and ts.Item = 'Degree'
					and isnull(CONVERT(nvarchar(20),b.GraduationDate), '') <> ''
				FOR JSON PATH
			) as [recognitions]
		from (
			select 
				a.StudentID,
				a.StandTestID,
				a.GraduationDate,
				case
					when a.EntryDate is not null and a.EntryDate > isnull(a.firstDoA, '1900-01-01') and a.EntryDate > @TermStartDate
					then cast(convert(date, isnull(a.EntryDate, '1900-01-01')) as nvarchar(12))
					when a.firstDoA >= @TermStartDate and a.firstDoA < @TermEndDate
					then cast(convert(date, a.firstDoA) as nvarchar(12))
					else @TermStartDate
				end as [StartDate],
				CASE
					WHEN isnull(a.WithdrawalDate, '') = '' 
					THEN @TermEndDate
					ELSE a.WithdrawalDate
				END as [EndDate]
			from (
				select 
					s.StudentID,
					sm.StandTestID,
					s.EntryDate,
					s.GraduationDate,
					(Select StudentFirstAttendanceDate From @StudentIDsWithAttendance Where StudentID = s.StudentID) as firstDoA,
					CASE
						WHEN isnull(s.WithdrawalDate, '') != '' and isnull(s.WithdrawReason, '') != '' 
						THEN cast(convert(date, s.WithdrawalDate) as nvarchar(12))
						ELSE ''
					END as WithdrawalDate
				from Students s
					left join StudentMiscFields sm
						on sm.StudentID = s.StudentID
				where s.StudentID in (select StudentID from @ValidStudentIDs)
			) a
		) b
			inner join @ValidTerms t
				on (
					(t.StartDate BETWEEN b.StartDate AND b.EndDate)
					or 
					(t.EndDate BETWEEN b.StartDate AND b.EndDate)
				)
		FOR JSON PATH
	);

END
GO
