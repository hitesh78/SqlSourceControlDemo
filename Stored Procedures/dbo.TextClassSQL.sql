SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 9/22/2022
-- Description:	This sproc is used by middle tier code to get PhoneNumbers and Names when Texting A Class group
-- =============================================
CREATE   PROCEDURE [dbo].[TextClassSQL]
	@class nvarchar(1000), 
	@StudentIDExcludes nvarchar(1000)
AS
BEGIN

	SET NOCOUNT ON;



	-- Get a List of StudentIDs and all their Parent/Student PhoneNumbers that are OptedIn from both Demographics and StudentContacts
	-- The phone numbers are parsed to a clean 10 digit number so it can be joined against the PhoneNumbers table
	-- This query assumes they have 10 digits in their phone fields or the number is excluded
	Declare @OptInPhoneNumbers table (StudentID int, PhoneNumber bigint, INDEX Oindex NONCLUSTERED (StudentID, PhoneNumber));
	Insert into @OptInPhoneNumbers
	Select
	StudentID,
	PhoneNumber
	From
	(
		Select
		StudentID,
		Phone1OptIn as PhoneOptIn,
		replace(
			replace(
				replace(
					replace(
						replace(
							replace(
								replace(ltrim(rtrim(value)),'(cell)', ''),
							'work',''), 
						'(home/primary)', ''),
					'(', ''),
				')', ''),
			'-', ''),
		' ', '') as PhoneNumber
		From 
		Students
		CROSS APPLY STRING_SPLIT(Phone1, ';')
		Where
		ltrim(rtrim(Phone1)) != ''

		Union

		Select
		StudentID,
		Phone2OptIn as PhoneOptIn,
		replace(
			replace(
				replace(
					replace(
						replace(
							replace(
								replace(ltrim(rtrim(value)),'(cell)', ''),
							'work',''), 
						'(home/primary)', ''),
					'(', ''),
				')', ''),
			'-', ''),
		' ', '') as PhoneNumber
		From 
		Students
		CROSS APPLY STRING_SPLIT(Phone2, ';')
		Where
		ltrim(rtrim(Phone2)) != ''

		Union

		Select
		StudentID,
		Phone3OptIn as PhoneOptIn,
		replace(
			replace(
				replace(
					replace(
						replace(
							replace(
								replace(ltrim(rtrim(value)),'(cell)', ''),
							'work',''), 
						'(home/primary)', ''),
					'(', ''),
				')', ''),
			'-', ''),
		' ', '') as PhoneNumber
		From 
		Students
		CROSS APPLY STRING_SPLIT(Phone3, ';')
		Where
		ltrim(rtrim(Phone3)) != ''

		Union

		Select
		StudentID,
		Phone1OptIn as PhoneOptIn,
			replace(
				replace(
					replace(
						replace(
							replace(
								replace(
									replace(ltrim(rtrim(Phone1Num)),'(cell)', ''),
								'work',''), 
							'(home', ''),
						'(', ''),
					')', ''),
				'-', ''),
			' ', '') as PhoneNumber
		From StudentContacts
		Where
		RolesAndPermissions = '(SIS Parent Contact)'

		Union

		Select
		StudentID,
		Phone2OptIn as PhoneOptIn,
			replace(
				replace(
					replace(
						replace(
							replace(
								replace(
									replace(ltrim(rtrim(Phone2Num)),'(cell)', ''),
								'work',''), 
							'(home', ''),
						'(', ''),
					')', ''),
				'-', ''),
			' ', '') as PhoneNumber
		From StudentContacts
		Where
		RolesAndPermissions = '(SIS Parent Contact)'

		Union

		Select
		StudentID,
		Phone3OptIn as PhoneOptIn,
			replace(
				replace(
					replace(
						replace(
							replace(
								replace(
									replace(ltrim(rtrim(Phone3Num)),'(cell)', ''),
								'work',''), 
							'(home', ''),
						'(', ''),
					')', ''),
				'-', ''),
			' ', '') as PhoneNumber
		From StudentContacts
		Where
		RolesAndPermissions = '(SIS Parent Contact)'
	) x
	Where
	len(PhoneNumber) = 10
	and
	ISNUMERIC(PhoneNumber) = 1
	and
	PhoneOptIn = 1;


	Declare @GeneralizeGuardianLabels bit;
	Declare @Comm2DefaultAreaCode int;
	SELECT 
		@GeneralizeGuardianLabels = GeneralizeGuardianLabels,
		@Comm2DefaultAreaCode = isnull(Comm2DefaultAreaCode,0)
	From Settings Where SettingID = 1


	declare @classIds table (ClassID int primary key)
	insert into @classIds
	select distinct ClassID
	from 
	Classes C
		inner join 
	Terms Tm 
		on C.TermID = Tm.TermID  
	where 
	ClassTitle = @class
	and C.ClassID != 135
	and C.ParentClassID = 0
	and Tm.STATUS = 1
	and Tm.TermID not in (SELECT ParentTermID FROM Terms);


	select                           
		S.StudentID as ID,             
		S.glname as [Name],
		null as Phone, 
		case 
			when len(p.phone)<=7 then
				cast(
					cast(
						case 
							when cast(p.phone as bigint) between 1000000 and 9999999 
								then @Comm2DefaultAreaCode 
							else 0 
						end 
					as bigint)
					* 10000000 + cast(p.phone as bigint) 
					as nvarchar(100)
				)
			else p.phone 
		end	as Phone3,
		p.LineType as PhoneLineType,
		--p.Type as PhoneRoleType,
		p.PhoneNumberValid as isValid,     
		'Student' as Access 
	FROM 
	Students S    
		inner join 
	ClassesStudents CS 
		on S.StudentID = CS.StudentID  
		inner join 
	Classes C 
		on C.ClassID = CS.ClassID      
		inner join 
	PhoneNumbers p
		on S.StudentID = p.StudentID
		inner join
	@OptInPhoneNumbers O
		on O.StudentID = S.StudentID and O.PhoneNumber = p.Phone
	WHERE 
	S.Active = 1
	and 
	C.ClassID IN (select distinct ClassID from @classIds)
	and 
	S.StudentID not in (SELECT value FROM STRING_SPLIT(@StudentIDExcludes, ','))

	UNION 
   
	Select 
	S.StudentID as [ID], 
	case 
		when @GeneralizeGuardianLabels = 1 
		then 'Family of ' + S.glname +IIF(sc.Relationship='Father', ' Guardian 1', ' Guardian 2')
		else sc.Relationship + ' of ' + S.glname 
	end as [Name],
	case 
		when len(LEFT(p.Phone,14))<=7 then
			cast(
				cast(
					case 
						when cast(LEFT(p.Phone,14) as bigint) between 1000000 and 9999999 
							then @Comm2DefaultAreaCode 
						else 0 
					end 
				as bigint)
				* 10000000 + cast(LEFT(p.Phone,14) as bigint) 
				as nvarchar(100)
			)
		else LEFT(p.Phone,14) 
	end	as Phone,
	null as Phone3,
	p.LineType as PhoneLineType,
	--p.Type as PhoneRoleType,
	p.PhoneNumberValid as isValid,
	'Family' as Access
	From 
	Classes C
		inner join 
	ClassesStudents CS 
		on C.ClassID = CS.ClassID 
		inner join 
	Students S 
		on S.StudentID = CS.StudentID 
		left join 
	StudentContacts sc 
		on sc.StudentID = S.StudentID
		inner join 
	(
		Select 
			n.Phone,
			n.LineType,
			n.PhoneNumberValid,
			--n.Type,
			n.ContactID,
			case 
				when extension like '%work%' 
					or extension like '%x%'
					or extension like '%w.%'
					or extension like '%w)%'
					or extension+' ' like '%w %'
					or extension like '%wk%'
					or type like '%work%' 
				then 1
				else 0
			end as isWorkPhone
		from PhoneNumbers n
		Where
		ContactID is not null
	) p 
		on sc.ContactID = p.ContactID
		inner join
	@OptInPhoneNumbers O
		on O.StudentID = S.StudentID and O.PhoneNumber = p.Phone
	WHERE 
	S.Active = 1  
	and S.StudentID not in (SELECT value FROM STRING_SPLIT(@StudentIDExcludes, ','))
	and C.ClassID IN (select distinct ClassID from @classIds)
	and dbo.ContactCategory(sc.Relationship) = 'PARENT' 
	and p.isWorkPhone = 0



END
GO
