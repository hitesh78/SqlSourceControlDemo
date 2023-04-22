SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Don Puls/Joey
-- Create date: 05/10/2021
-- Modified dt: 11/18/2022 
-- Description:	returns the edfi StudentSchoolAssociations JSON
-- Rev. Notes:	updated the entry date logic again
-- =============================================
CREATE       PROCEDURE [dbo].[edfiStudentSchoolAssociationsJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@StudentSchoolAssociationsJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	Declare @TermStartDate nvarchar(12);
	Declare @TermEndDate nvarchar(12);
	Declare @LastYearEndDate nvarchar(12);
	Declare @SchoolType nvarchar(50) = (Select SchoolType From Settings Where SettingID = 1);

	Declare @AttendanceEvents table (ID nvarchar(10), edfiAttendanceEvent nvarchar(50));
	Insert into @AttendanceEvents
	Select
		A.ID,
		EA.edfiAttendanceEvent 
	From AttendanceSettings A
		inner join EdfiAttendanceEvents EA
			on A.edfiAttendanceEventID = EA.edfiAttendanceEventID
	Where A.MultiSelect = 0 and A.ExcludedAttendance = 0;

	Declare @ValidStudentIDs table (StudentID int PRIMARY KEY);
	Insert into @ValidStudentIDs
	Select StudentID
	From dbo.fnEdfiValidStudents(@CalendarStartDate, @CalendarEndDate);

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

	Declare @SchoolID nvarchar(50) = (SELECT EdFiDOESchoolID FROM IntegrationSettings Where ID = 1);

	Select 
		@TermStartDate = StartDate,
		@TermEndDate = EndDate,
		@LastYearEndDate = LastYearEndDate
	From dbo.fnGetStartEndDatesByYear(@SchoolYear);

	set @StudentSchoolAssociationsJSON = (
		Select 
			@SchoolID as [schoolReference.schoolId],
			@SchoolYear as [classOfSchoolYearTypeReference.schoolYear],
			@SchoolYear as [schoolYearTypeReference.schoolYear],
			b.StandTestID as [studentReference.studentUniqueId],
			b.entryDateCalc as [entryDate],
			b.entryGradeLevelDescriptor,
			b.exitWithdrawDate,
			b.exitWithdrawTypeDescriptor,
			b.primarySchool
		from (
			select
			a.StandTestID,
			case--1
				when a.EntryDate is null and a.firstDoA is not null
				then cast(convert(date, a.firstDoA) as nvarchar(12))
				--2
				when a.EntryDate is null and a.firstDoA is null
				then @TermStartDate
				--3
				when a.EntryDate is not null and a.EntryDate < @TermStartDate and a.firstDoA is null 
				then @TermStartDate
				--4
				when a.EntryDate is not null and a.EntryDate < @TermStartDate and a.firstDoA is not null 
				then cast(convert(date, a.firstDoA) as nvarchar(12))
				--5
				when a.EntryDate is not null and a.EntryDate >= @TermStartDate and a.firstDoA is null and a.EntryDate <= @TermEndDate
				then cast(convert(date, a.EntryDate) as nvarchar(12))
				--6
				when a.EntryDate is not null and a.EntryDate >= @TermStartDate and a.firstDoA is null and a.EntryDate > @TermEndDate
				then '' -- remove
				--7 
				when a.EntryDate is not null and a.EntryDate >= @TermStartDate and a.firstDoA is not null and a.EntryDate < a.firstDoA
				then cast(convert(date, a.EntryDate) as nvarchar(12))
				--8
				when a.EntryDate is not null and a.EntryDate >= @TermStartDate and a.firstDoA is not null and a.EntryDate >= a.firstDoA
				then cast(convert(date, a.firstDoA) as nvarchar(12))
				else '' -- remove
			end as [entryDateCalc],
			'http://doe.in.gov/Descriptor/GradeLevelDescriptor.xml/' + 
				CASE 
					WHEN [GradeLevel] = 'K' THEN 'KG'
					WHEN [GradeLevel] = 'PS' THEN 'PK'
					WHEN len([GradeLevel]) = 1 THEN '0' + [GradeLevel]
					ELSE [GradeLevel]
				END as [entryGradeLevelDescriptor],
			CASE
				WHEN @SchoolType = 'default' and isnull(a.WithdrawalDate, '') = '' and GETDATE() >= @TermEndDate 
				THEN @TermEndDate
				ELSE a.WithdrawalDate
			END as [exitWithdrawDate],		
			CASE 
				WHEN isnull(a.WithdrawReason, '') <> '' --and a.WithdrawalDate is not null
				THEN 'http://doe.in.gov/Descriptor/ExitWithdrawTypeDescriptor.xml/' + WithdrawReason
				WHEN GETDATE() >= @TermEndDate 
				then 'http://doe.in.gov/Descriptor/ExitWithdrawTypeDescriptor.xml/50'
				ELSE NULL
			END as [exitWithdrawTypeDescriptor],
			cast(a.PrimaryEdSchool ^ 1 as bit) as [primarySchool] -- "^ 1" reverses the boolean value
			From (
				Select
					sm.StandTestID,
					s.EntryDate,
					(Select StudentFirstAttendanceDate From @StudentIDsWithAttendance Where StudentID = s.StudentID) as firstDoA,
					s.GradeLevel,				
				case
					When isnull(s.WithdrawalDate, '') != '' and isnull(s.WithdrawReason, '') != '' then
					cast(convert(date, s.WithdrawalDate) as nvarchar(12))
					else ''
				End as WithdrawalDate,
				case
					When isnull(s.WithdrawalDate, '') != '' and isnull(s.WithdrawReason, '') != '' then
					s.WithdrawReason
					else ''
				End as WithdrawReason,				
					sm.PrimaryEdSchool
				From Students s
					left join StudentMiscFields sm
						on s.StudentID = sm.StudentID
				Where s.StudentID in (select StudentID from @ValidStudentIDs)
			) a
		) b
		where entryDateCalc <> ''
		FOR JSON PATH
	);


END
GO
