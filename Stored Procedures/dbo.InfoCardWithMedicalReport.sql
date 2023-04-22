SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Don Puls
-- Create date: 8/25/2021
-- Modified dt: 1/25/2022
-- Description:	Used for Report: Students > Reports > Info card with Medical
-- [gc-34561] Support Grade Level 'All'
-- =============================================
CREATE       PROCEDURE [dbo].[InfoCardWithMedicalReport] 
@Criteria nvarchar(50),
@StudentID int,
@GradeFilter nvarchar(20),
@GradesFrom nvarchar(20)
AS
BEGIN

	SET NOCOUNT ON;


	-- sex  
	Declare @TT_Male nvarchar(50) = dbo.T(0,'Male');  
	Declare @TT_Female nvarchar(50) = dbo.T(0,'Female');  

	-- _Status  
	Declare @TT_Active nvarchar(50) = dbo.T(0, 'Active');  
	Declare @TT_Alumnus nvarchar(50) = dbo.T(0, 'Alumnus');  
	Declare @TT_Inactive nvarchar(50) = dbo.T(0, 'Inactive');   

	-- TylenolChildOrJunior  
	Declare @TT_Adult nvarchar(50) = dbo.T(0,'Adult');  
	Declare @TT_Junior nvarchar(50) = dbo.T(0,'Junior');  
	Declare @TT_Child nvarchar(50) = dbo.T(0,'Child');  
	Declare @TT_TylenolOK nvarchar(50) = dbo.T(0,'Tylenol OK');  
	Declare @TT_HomePrimary nvarchar(50) = dbo.T(0,'Home/Primary');  
	Declare @TT_Cell nvarchar(50) = dbo.T(0,'Cell');  
	Declare @TT_Home nvarchar(50) = dbo.T(0,'Home');  
	Declare @TT_Phone nvarchar(50) = dbo.T(0,'Phone');      


	--********************************************************************************************************************
	--************ The following SQL was implemented to avoid SQL Compatibility delays going to level 130 ****************
	--********************************************************************************************************************

	Declare @StudentMedInfo table (StudentID int, LineNum int, Health_Condition nvarchar(200), Present nvarchar(20), Details nvarchar(100), Comments nvarchar(2000))
	Declare @StudentMedInfo2 table (StudentID int, LineNum int, Health_Condition nvarchar(200), Present nvarchar(20), Details nvarchar(100), Comments nvarchar(2000))


	Insert into @StudentMedInfo
	select 
		StudentID,
		ROW_NUMBER() OVER (PARTITION BY StudentID ORDER BY StartDate)+19 LineNum, -- any unique # after 19
		Medication 
		+ ISNULL(
			CASE WHEN ISNULL(OTCorRx,'')+ISNULL(TakenAtSchool,'')>'' THEN ' (' ELSE '' END 
			+ dbo.ConcatWithDelimiter(OTCorRx,case 
				when TakenAtSchool='Yes' then 'Taken at school'
				when TakenAtSchool='No' then 'Not taken at school'
				else null end, ', ')
			+ CASE WHEN ISNULL(OTCorRx,'')+ISNULL(TakenAtSchool,'')>'' THEN ')' ELSE '' END, 
		''),
		'Yes',
		dbo.ConcatWithDelimiter('Start '+dbo.GLformatdate(StartDate),
			dbo.ConcatWithDelimiter('Stop '+dbo.GLformatdate(StopDate),
				DoseAndFreq,', '),', '),
		dbo.ConcatWithDelimiter(ReasonTaken, cast(Notes as nvarchar(max)), ' - ')
	from vMedications;


	;with
	HealthHx(StudentID, LineNum, Health_Condition, Present, Details, Comments)
	as (
		select StudentID, 1, 'Allergies', Allergies, Allergies_attribs, Allergies_Comments
		from HealthHistory
		union
		select StudentID, 2, 'Asthma', Asthma, Asthma_attribs, Asthma_Comments
		from HealthHistory
		union
		select StudentID, 3, 'Attention Deficit Disorder (ADD/ADHD)', ADD_ADHD, '', ADD_ADHD_Comments
		from HealthHistory
		union
		select StudentID, 4, 'Bone/Muscle Condition', BoneOrMuscleCond, '', BoneOrMuscleCond_Comments
		from HealthHistory
		union
		select StudentID, 5, 'Diabetes', Diabetes, Diabetes_attribs, Diabetes_Comments
		from HealthHistory
		union
		select StudentID, 6, 'Chronic Ear or Throat Infections', EarThroatInf, '', EarThroatInf_Comments
		from HealthHistory
		union
		select StudentID, 7, 'Emotional Problems', EmotionalProb, '', EmotionalProb_Comments
		from HealthHistory
		union
		select StudentID, 8, 'Fainting / sudden loss of consciousness', Fainting, '', Fainting_Comments
		from HealthHistory
		union
		select StudentID, 9, 'Frequent Headaches or Migraines', Headaches, '', Headaches_Comments
		from HealthHistory
		union
		select StudentID, 10, 'Head Injuries or Any Major Accidents', MajorInjury, '', MajorInjury_Comments
		from HealthHistory
		union
		select StudentID, 11, 'Heart, Blood Disease or High Blood Pressure', HeartBlood, '', HeartBlood_Comments
		from HealthHistory
		union
		select StudentID, 12, 'Hearing Loss', HearingLoss, HearingLoss_attribs, HearingLoss_Comments
		from HealthHistory
		union
		select StudentID, 13, 'Physical Handicap', PhysicalHandicap, '', PhysicalHandicap_Comments
		from HealthHistory
		union
		select StudentID, 14, 'Seizure Disorder', Seizures, '', Seizures_Comments
		from HealthHistory
		union
		select StudentID, 15, 'Skin Problems', SkinProb, '', SkinProb_Comments
		from HealthHistory
		union
		select StudentID, 16, 'Urinary/Bowel Condition', UrinaryBowel, '', UrinaryBowel_Comments
		from HealthHistory
		union
		select StudentID, 17, 'Vision Problems', Vision, Vision_attribs, Vision_Comments
		from HealthHistory
		union
		select StudentID, 18, 'Hospitalizations & Operations', HospOper, '', HospOper_Comments
		from HealthHistory
		union
		select StudentID, 19, 'Other concerns', Concerns, Concerns_attribs, Concerns_Comments
		from HealthHistory	
		union
		-- Include medications everywhere that health history is presented....
		Select * From @StudentMedInfo
		union
		select StudentID, 21, case when NurseNotesPublic !='' then 'Nurse Notes' else null end, case when NurseNotesPublic !='' then 'Yes' else 'No' end,'', NurseNotesPublic
		from HealthHistory
	)
	INSERT INTO @StudentMedInfo2
	select * from HealthHx
	where Present='Yes';


	--********************************************************************************************************************
	--********************************************************************************************************************
	--********************************************************************************************************************

 

	select 
	dbo.glgetdate() as glDate,  
	s.FullName,
	s.mother,
	s.Father,   
	s.AddressDescription as AddressDescription,    
	s.AddressDescription2,   
	s.address1,
	s.Address2,   
	case 
		when s.Sex = 'Female' then replace(s.SexAndEthnicity, 'Female', @TT_Female)   
		when s.Sex = 'Male' then replace(s.SexAndEthnicity, 'Male', @TT_Male)   
	end as SexAndEthnicity,   
	dbo.GLformatdate(s.BirthDate) as BirthDate,   
	s.Phones as StudentPhones,   
	s.Emails as StudentEmails,   
	s.Parents,   
	isnull(s.Family2Phones,'') as Family2Phones,   
	isnull(s.Family2Emails,'') as Family2Emails,   
	isnull(s.Family2Parents,'') as Family2Parents,   
	s.GradeLevX as Grade,   
	case s._Status    
		when 'Active' then @TT_Active    
		when 'Alumnus' then @TT_Alumnus    
		when 'Inactive' then @TT_Inactive    
		else s._Status   
	end as Status,   
	m.FamStat as FamStat,   
	case 
		when m.MedicalInsurance is null then es.InsuranceCompany + isnull(CHAR(13)+CHAR(10) + es.InsurancePolicyNumber, '')     
		else m.MedicalInsurance 
	end MedicalInsurance,   
	es.HospitalPreference,   
	dbo.ConcatWithDelimiter(    
		m.MedAlert,    
		case when es.ListAllergies is null then '' else es.ListAllergies end,     
		char(13)+char(10)
	) as ListAllergies,   
	dbo.ConcatWithDelimiter(
		m.MedAlertNotes,   
		dbo.ConcatWithDelimiter(    
			case 
				when es.TylenolOK = 'Yes' then 
					'('+       
					case es.TylenolChildOrJunior       
						when 'Adult' then @TT_Adult       
						when 'Junior' then @TT_Junior       
						when 'Child' then @TT_Child       
						else es.TylenolChildOrJunior      
					end + ' ' + @TT_TylenolOK     
				else null -- this null removes appended ')' below
			end + 
			')',    
			case when es.MedicationsDesc is null then '' else es.MedicationsDesc end,    
			CHAR(13)+char(10)
		), 
		char(13)+char(10)
	) MedicationsDesc,   
	s.xStudentID,
	(select count(*) cnt from @StudentMedInfo2 where StudentID = s.StudentID) as MedCnt,  
	c.*   
	from 
	StudentRoster_orig s  
		left join
	EnrollmentStudent es
		on	isnull(cast(es.ImportStudentID as bigint),cast(es.StudentID as bigint)) = s.StudentID 
			and
			EnrollmentStudentID in (
				select      
				MAX(EnrollmentStudentID) EnrollmentStudentID   
				from EnrollmentStudent es   
				where 
				isnull(cast(es.ImportStudentID as bigint),cast(es.StudentID as bigint)) is not null   
				and 
				FormStatus is not null and FormStatus<>'Started'  
				group by isnull(cast(es.ImportStudentID as bigint),cast(es.StudentID as bigint))   
			)  
		left join 
	vStudentMiscFields m  
		on m.StudentID=s.StudentID
		left join   
	(
		select    
		sc.Emails,
		sc.Name,   
		REPLACE(   
			REPLACE(   
				REPLACE(   
					REPLACE(    
						sc.Phones,    
						'Home/Primary',@TT_HomePrimary
					),    
					'Cell',@TT_Cell
				),    
				'Home',@TT_Home
			),    
			'Phone',@TT_Phone
		) as Phones,   
		sc.Relation as Relation,   
		sc.RelationAndName as RelationAndName,    
		sc.Occupation, 
		sc.Employer,   
		cc.AddressLine1, 
		cc.AddressLine2,
		cc.City, 
		cc.State, 
		cc.Zip,   
		cc.Relationship,
		cc.StudentID ContactStudentID,
		cc.RolesAndPermissions
		from 
		vStudentContacts cc   
			inner join
		Studentcontactsdisplay2 sc   
			on sc.ContactID = cc.ContactID

		union   
				
		select    
		'' Emails,
		Health_Condition as Name,
		'' as Phones,
		'Medical-History' as Relation,   
		'zzz'+cast(1000+LineNum as varchar(5)) as RelationAndName,
		--dbo.TranslateDelimitedList(Details) as Occupation, 
		Details as Occupation, 
		Comments as Employer,   
		'' AddressLine1, 
		'' AddressLine2, 
		'' City, 
		'' State, 
		'' Zip,   
		'' Relationship,   
		StudentID as ContactStudentID,    
		'' RolesAndPermissions  
		from 
		@StudentMedInfo2
	) c  
		on s.StudentID = c.ContactStudentID      
	where 
	(  
		(@Criteria = 'SingleStudent' and cast(s.StudentID as varchar(10)) = @StudentID)  
		or 
		(@Criteria = 'AllStudents' and s.active=1)    
		or 
		(@Criteria = 'Reenrollment' and s._status='Reenrollment')    
		or 
		(@Criteria = 'NotReenrolled' and s._status='Active')    
		or 
		(@Criteria = 'Inactive' and s._status='Inactive')    
		or 
		(@Criteria = 'Alumni' and s._status='Alumnus')    
		or 
		(@Criteria = 'NewEnrollments' and s._status='New Enrollment')    
		or 
		(@Criteria = 'AllInactive' and s._status in ('Inactive', 'New Enrollment', 'Alumnus'))      
	--   and s.FullName is not null -- KILLS PERFORMANCE; filter out on REPORT     
	)
	and 
	(
		@GradeFilter = 'false' 
		or          
		@Criteria = 'SingleStudent'
		or 
		s.GradeLevel=@GradesFrom
		or
		@GradesFrom = 'All'
	)   
	
	order by FullName, xStudentID, relationship

END
GO
