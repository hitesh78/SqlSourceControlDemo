SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Joey
-- Create date: 10/06/2021
-- Modified dt: 11/22/2022
-- Description:	when syncing individual record
-- Rev. Notes:	updates ssa 
-- =============================================
CREATE       PROCEDURE [dbo].[edfiGetResourceForSync]
@TheUniqueID nvarchar(100),
@Resource nvarchar(100),
@SchoolYear int
AS
BEGIN
	SET NOCOUNT ON;

	Declare @OldJSON table (theKey nvarchar(150) PRIMARY KEY, theJSON nvarchar(2000));
	Declare @NewSnapshot table (theKey nvarchar(150) PRIMARY KEY, theJSON nvarchar(2000));
	Declare @jsonItem nvarchar(max);
	Declare @TermStartDate nvarchar(12);
	Declare @TermEndDate nvarchar(12);
	Declare @LastYearEndDate nvarchar(12);
	Declare @firstAttendanceDate date;
	Declare @SchoolID nvarchar(50);
	Declare @StateID nvarchar(50);
	Declare @CurrentEdOrgID nvarchar(50);
	
	Declare @SchoolType nvarchar(50) = (Select SchoolType From Settings Where SettingID = 1);

	SELECT 
		@SchoolID = EdFiDOESchoolID,
		@StateID = EdFiStateOrgID
	FROM IntegrationSettings Where ID = 1;

	Set @CurrentEdOrgID = IIF(@SchoolType = 'PublicSchool', @StateID, @SchoolID);

	Declare @postID int = (	
		Select top 1 PostID 
		From EdfiSubmissionStatus 
		Where CalendarYear = @SchoolYear
			and edfiResource = @Resource
			and dataSnapshot is not null
		order by PostStartDateUTC desc);

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
	from dbo.fnGetStartEndDatesByYear(@SchoolYear);
	
	IF @Resource = 'Calendars'
	BEGIN
		Select 0;
	END
	ELSE IF @Resource = 'CalendarDates'
	BEGIN
		Select 0;
	END
	ELSE IF @Resource = 'GradingPeriods'
	BEGIN
		Select 0;
	END
	ELSE IF @Resource = 'Sessions'
	BEGIN
		Select 0;
	END
	ELSE IF @Resource = 'Students'
	BEGIN
		Select 0;
	END
	ELSE IF @Resource = 'StudentSchoolAssociations'
	BEGIN

		insert into @OldJSON
		Select
		substring(JSON_VALUE(value, '$.studentReference."studentUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$.studentReference."studentUniqueId"')) +1, 30)  as theKey,
		value as theJSON
		From
		OPENJSON(
			(
				Select dataSnapshot 
				From EdfiSubmissionStatus 
				Where PostID = @postID
			)
		);

		Set @firstAttendanceDate = (
			Select 
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
				inner join StudentMiscFields sm
					on sm.StudentID = S.StudentID
			Where T.ExamTerm = 0        -- exclude exam terms
				and T.TermID not in (Select ParentTermID From Terms)
				and T.StartDate >= @TermStartDate
				and T.EndDate <= @TermEndDate
				and C.ClassTypeID = 5
				and sm.StandTestID = @TheUniqueID
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
			);

		Set @jsonItem = (
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
						@firstAttendanceDate as firstDoA,
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
					Where sm.StandTestID = @TheUniqueID --s.StudentID in (select StudentID from @ValidStudentIDs)
				) a
			) b
			where entryDateCalc <> ''
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		);

		insert into @NewSnapshot
		Select 
			theKey,
			theJSON
		From @OldJSON
		Where theKey <> @TheUniqueID
		UNION
		Select
			@TheUniqueID as theKey,
			@jsonItem as theJSON;

		Update EdfiSubmissionStatus
		Set
		dataSnapshot =
		(
			SELECT '[' + Stuff(
				(
				SELECT N',' + N.theJSON 
				From @NewSnapshot N
				FOR XML PATH(''),TYPE)
				.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where PostID = @postID;

		Select @jsonItem;

	END
	ELSE IF @Resource = 'StudentsSchoolAttendanceEvents'
	BEGIN
		Select 0;
	END
	ELSE IF @Resource = 'StudentsEducationOrgAssociations'
	BEGIN

		insert into @OldJSON
		Select
		substring(JSON_VALUE(value, '$.studentReference."studentUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$.studentReference."studentUniqueId"')) +1, 30)  as theKey,
		value as theJSON
		From
		OPENJSON(
			(
				Select dataSnapshot 
				From EdfiSubmissionStatus 
				Where PostID = @postID
			)
		);

		Set @firstAttendanceDate = (
			Select 
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
				inner join StudentMiscFields sm
					on sm.StudentID = S.StudentID
			Where T.ExamTerm = 0        -- exclude exam terms
				and T.TermID not in (Select ParentTermID From Terms)
				and T.StartDate >= @TermStartDate
				and T.EndDate <= @TermEndDate
				and C.ClassTypeID = 5
				and sm.StandTestID = @TheUniqueID
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
			);

	
		Set @jsonItem = (
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
					@firstAttendanceDate as firstDoA,
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
				Where sm.StandTestID = @TheUniqueID
			) a
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		);

		insert into @NewSnapshot
		Select 
			theKey,
			theJSON
		From @OldJSON
		Where theKey <> @TheUniqueID
		UNION
		Select
			@TheUniqueID as theKey,
			@jsonItem as theJSON;

		Update EdfiSubmissionStatus
		Set
		dataSnapshot =
		(
			SELECT '[' + Stuff(
				(
				SELECT N',' + N.theJSON 
				From @NewSnapshot N
				FOR XML PATH(''),TYPE)
				.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where PostID = @postID;

		Select @jsonItem;

	END
	ELSE IF @Resource = 'StudentProgramAssociations'
	BEGIN
		Select 0;
	END
	ELSE IF @Resource = 'Staffs'
	BEGIN
		Select 0;
	END
	ELSE IF @Resource = 'StaffEducationOrganizationEmploymentAssociations'
	BEGIN -- allows for multiples

		Declare @empStatuses table(CodeValue nvarchar(30));
		insert into @empStatuses
		select CodeValue from Lkg.dbo.edfiDescriptorsAndTypes where [Name] = 'EmploymentStatusDescriptor';
		
		-- old json
		insert into @OldJSON
		Select
		substring(JSON_VALUE(value, '$.staffReference."staffUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$.staffReference."staffUniqueId"')) +1, 30) +  
		JSON_VALUE(value, '$.educationOrganizationReference."educationOrganizationId"') as staffUniqueId,
		value as seoeaJSON
		From OPENJSON(
			(
				Select dataSnapshot 
				From EdfiSubmissionStatus 
				Where PostID = @postID
			)
		);

		-- new item(s)
		set @jsonItem = (
			select A.* 
			from (
				select
					@SchoolID as [educationOrganizationReference.educationOrganizationId],
					StatePersonnelNumber as [staffReference.staffUniqueId],
					'http://doe.in.gov/Descriptor/EmploymentStatusDescriptor.xml/' + EmploymentType as [employmentStatusDescriptor],
					HireDate as [hireDate],
					ReleaseDate as [endDate],
					Round(DATEDIFF(day, cast(T.StartDateAtJob as date), Getdate())/365,0) as [yearsOfPriorProfessionalExperience]
				from Teachers T
				where  T.StatePersonnelNumber = @TheUniqueID 
					and EmploymentType IN (select CodeValue from @empStatuses)
				union all
				select
					@StateID as [educationOrganizationReference.educationOrganizationId],
					StatePersonnelNumber as [staffReference.staffUniqueId],
					'http://doe.in.gov/Descriptor/EmploymentStatusDescriptor.xml/' + EmploymentType as [employmentStatusDescriptor],
					HireDate as [hireDate],
					ReleaseDate as [endDate],
					Round(DATEDIFF(day, cast(T.StartDateAtJob as date), Getdate())/365,0) as [yearsOfPriorProfessionalExperience]
				from Teachers T
				where T.StatePersonnelNumber = @TheUniqueID
					and EmploymentType IN (select CodeValue from @empStatuses) 
					and @SchoolType = 'PublicSchool'
			) A
			FOR JSON PATH
		);

		-- new snapshot
		insert into @NewSnapshot
		select
			theKey,
			theJSON
		from @OldJSON
		where theKey NOT LIKE @TheUniqueID + '%'
		UNION
		Select
			substring(JSON_VALUE(value, '$.staffReference."staffUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$.staffReference."staffUniqueId"')) +1, 30) + 
			JSON_VALUE(value, '$.educationOrganizationReference."educationOrganizationId"') as theKey,
			value as theJSON
		From OPENJSON(
			(
				Select @jsonItem
			)
		);

		-- update submission
		update EdfiSubmissionStatus
		set dataSnapshot = 
		(
			SELECT '[' + Stuff(
				(
				SELECT N',' + N.theJSON 
				From @NewSnapshot N
				FOR XML PATH(''),TYPE)
				.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		where PostID = @postID;

		select @jsonItem;
	END
	ELSE IF @Resource = 'Parents'
	BEGIN
		Select 0;
	END
	ELSE IF @Resource = 'StudentParentAssociations'
	BEGIN
		Select 0;
	END
	ELSE IF @Resource = 'StaffEducationOrganizationAssignmentAssociations'
	BEGIN -- allows for multiples
		
		declare @staffCodes table(CodeValue nvarchar(500));
		insert into @staffCodes
		select CodeValue from LKG.dbo.edfiDescriptorsAndTypes where [Name] = 'StaffClassificationDescriptor';

		-- old json
		insert into @OldJSON
		Select
			substring(JSON_VALUE(value, '$.staffReference."staffUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$.staffReference."staffUniqueId"')) +1, 30)  + ':' +
			substring(JSON_VALUE(value, '$."staffClassificationDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$."staffClassificationDescriptor"')) + 5, 100) as theKey,
			value as seoeaJSON
		From OPENJSON(
			(
				Select dataSnapshot 
				From EdfiSubmissionStatus 
				Where PostID = @postID
			)
		);
		-- new item(s)
		set @jsonItem = (
			Select distinct
				CASE
					WHEN @SchoolType = 'PublicSchool' and (
						a.TheString = 'Superintendent' or
						a.TheString = 'Assistant Superintendent' or
						a.TheString = 'LEA Administrator' or
						a.TheString = 'Chief Technology Officer' or
						a.TheString = 'Special Education Director' or
						a.TheString = 'Corporation Test Coordinator' or
						a.TheString = 'School Administrator') 
					THEN @StateID
					ELSE @SchoolID 
				END as [educationOrganizationReference.educationOrganizationId],
				StatePersonnelNumber as [staffReference.staffUniqueId],
				CASE
					WHEN @SchoolType = 'PublicSchool' and (
						a.TheString = 'Superintendent' or
						a.TheString = 'Assistant Superintendent' or
						a.TheString = 'LEA Administrator' or
						a.TheString = 'Chief Technology Officer' or
						a.TheString = 'Special Education Director' or
						a.TheString = 'Corporation Test Coordinator' or
						a.TheString = 'School Administrator') 
					THEN @StateID
					ELSE @SchoolID 
				END as [employmentStaffEducationOrganizationEmploymentAssociationReference.educationOrganizationId],
				StatePersonnelNumber as [employmentStaffEducationOrganizationEmploymentAssociationReference.staffUniqueId],
				'http://doe.in.gov/Descriptor/EmploymentStatusDescriptor.xml/' + 
					EmploymentType as [employmentStaffEducationOrganizationEmploymentAssociationReference.employmentStatusDescriptor],
				HireDate as [employmentStaffEducationOrganizationEmploymentAssociationReference.hireDate],
				HireDate as [beginDate],
				ReleaseDate as [endDate],
				1 as [orderOfAssignment],
				JobTitle as [positionTitle],
				'http://doe.in.gov/Descriptor/StaffClassificationDescriptor.xml/' + 
					CASE 
						WHEN isnull(a.TheString, '') IN (select CodeValue from @staffCodes)
						THEN a.TheString
						WHEN StaffType = 1
						THEN 'Teacher'
						WHEN StaffType = 2
						THEN 'School Administrator'
						WHEN StaffType = 3
						THEN 'Principal'
						ELSE 'Other' 
					END as [staffClassificationDescriptor]
			from Teachers v 
				OUTER APPLY dbo.SplitCSVStrings(
					(
					Select EdFiRole 
					from Teachers t
					where t.TeacherID = v.TeacherID
					)
				) a
			where v.StatePersonnelNumber = @TheUniqueID -- technically staff id
			FOR JSON PATH 
		);
		
		-- new snapshot
		insert into @NewSnapshot
		Select 
			theKey,
			theJSON
		From @OldJSON
		Where theKey NOT LIKE @TheUniqueID +'%'
		UNION
		Select
			substring(JSON_VALUE(value, '$.staffReference."staffUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$.staffReference."staffUniqueId"')) +1, 30)  + ':' +
			substring(JSON_VALUE(value, '$."staffClassificationDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$."staffClassificationDescriptor"')) + 5, 100) as theKey,
			value as theJSON
		From OPENJSON(
			(
				select @jsonItem
			)
		);
		
		-- update submission
		Update EdfiSubmissionStatus
		Set dataSnapshot =
		(
			SELECT '[' + Stuff(
				(
				SELECT N',' + N.theJSON 
				From @NewSnapshot N
				FOR XML PATH(''),TYPE)
				.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where PostID = @postID;

		Select @jsonItem;
	END
	ELSE IF @Resource = 'StaffEducationOrganizationContactAssociations'
	BEGIN
		Select 0;
	END
	ELSE
	BEGIN
		Select 0;
	END


END
GO
