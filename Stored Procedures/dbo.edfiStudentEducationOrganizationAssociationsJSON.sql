SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






-- =============================================
-- Author:		Don Puls
-- Create date: 5/10/2021
-- Modified dt: 08/22/2022
-- Description:	This returns the edfi StudentEducationOrganizationAssociations JSON 
-- Parameters: Calendar Year
-- =============================================
CREATE              PROCEDURE [dbo].[edfiStudentEducationOrganizationAssociationsJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@SEOAJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	
	Declare @TermStartDate nvarchar(12);
	Declare @TermEndDate nvarchar(12);
	Declare @LastYearEndDate nvarchar(12);
	Declare @AttendanceEvents table (ID nvarchar(10), edfiAttendanceEvent nvarchar(50));
	Insert into @AttendanceEvents
	Select
		A.ID,
		EA.edfiAttendanceEvent 
	From AttendanceSettings A
		inner join EdfiAttendanceEvents EA
			on A.edfiAttendanceEventID = EA.edfiAttendanceEventID
	Where A.MultiSelect = 0 and A.ExcludedAttendance = 0;

	Select 
		@TermStartDate = StartDate,
		@TermEndDate = EndDate,
		@LastYearEndDate = LastYearEndDate
	From dbo.fnGetStartEndDatesByYear(@SchoolYear);

	Declare @ValidStudentIDs table (StudentID int PRIMARY KEY);
	Insert into @ValidStudentIDs
	Select StudentID
	From dbo.fnEdfiValidStudents(@CalendarStartDate,@CalendarEndDate);

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
	and T.StartDate >= @TermStartDate
	and T.EndDate <= @TermEndDate
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

	Declare @SchoolType nvarchar(50) = (Select SchoolType From Settings Where SettingID = 1);

	Declare @SchoolID nvarchar(50);
	Declare @StateID nvarchar(50);
	Declare @CurrentEdOrgID nvarchar(50);
	
	SELECT 
		@SchoolID = EdFiDOESchoolID,
		@StateID = EdFiStateOrgID
	FROM IntegrationSettings Where ID = 1;

	Set @CurrentEdOrgID = IIF(@SchoolType = 'PublicSchool', @StateID, @SchoolID);
	
	set @SEOAJSON = (
		Select 
		@CurrentEdOrgId as [educationOrganizationReference.educationOrganizationId],
		a.StandTestID as [studentReference.studentUniqueId],
		case
			when Affiliations like '%Choice%' and @SchoolType = 'PublicSchool'
			then 'http://doe.in.gov/Descriptor/ADMCodeDescriptor.xml/1'
			when Affiliations like '%Choice%' and @SchoolType <> 'PublicSchool'
			then 'http://doe.in.gov/Descriptor/ADMCodeDescriptor.xml/10'
			else ''
		end as [admCodeDescriptor],		
		case
			when a.EntryDate is not null and a.EntryDate > isnull(a.firstDoA, '1900-01-01')
			then cast(convert(date, isnull(a.EntryDate, '1900-01-01')) as nvarchar(12))
			when a.firstDoA >= @TermStartDate and a.firstDoA < @TermEndDate
			then cast(convert(date, a.firstDoA) as nvarchar(12))
			when isnull(a.EntryDate, '1900-01-01') > @LastYearEndDate and isnull(a.EntryDate, '1900-01-01') <= @TermStartDate
			then cast(convert(date, isnull(a.EntryDate, '1900-01-01')) as nvarchar(12))
			else @TermStartDate end	as [beginDate],
		case
			when a.WithdrawalDate != '' 
			then a.WithdrawalDate
			when getdate() >=  @TermEndDate  
			then @TermEndDate 
			else null
		end as [endDate],
		case
			when Affiliations like '%Choice%' 
			then 'http://doe.in.gov/Descriptor/ResponsibilityDescriptor.xml/Funding' 
			else 'http://doe.in.gov/Descriptor/ResponsibilityDescriptor.xml/Attendance'
		end as [responsibilityDescriptor],
		(
			Select
			a.schoolCorpResponsibilityDescriptor,
			a.schoolCorpId
			From
			(
				Select 
				'http://doe.in.gov/Descriptor/ResponsibilityDescriptor.xml/Accountability' as [schoolCorpResponsibilityDescriptor],
				@SchoolID as [schoolCorpId]
				UNION
				Select
				'http://doe.in.gov/Descriptor/ResponsibilityDescriptor.xml/Legal Settlement' as [schoolCorpResponsibilityDescriptor],
				'10' + RIGHT('0000' + CAST(isnull(CorpNumberIndiana_DOE_MV, 0) as nvarchar(20)),4) + '0000' as [schoolCorpId]
			) a
			FOR JSON PATH
		) as [additionalEdOrgResponsibilities]

		From 
		 (
			Select
				sm.StandTestID,
				s.EntryDate,
				(Select StudentFirstAttendanceDate From @StudentIDsWithAttendance Where StudentID = s.StudentID) as firstDoA,
				s.GradeLevel,
				s.Affiliations,
				s.StudentID,
				sm.CorpNumberIndiana_DOE_MV,
				cast(convert(date, s.WithdrawalDate) as nvarchar(12)) as WithdrawalDate,
				s.WithdrawReason,
				sm.PrimaryEdSchool
			From Students s
				left join StudentMiscFields sm
					on s.StudentID = sm.StudentID
			Where s.StudentID in (select StudentID from @ValidStudentIDs)
		) a

		FOR JSON PATH
	);
END
GO
