SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--
-- This view derives from the PhoneNumbers table and adds
-- business rules to filter out work phones that we do not call.
-- We filter out numbres that do not have the Opt. In flag as well
-- as inactive students and teachers, etc.
--
-- Important: This view joins to appropriate parent tables for OptIn 
-- information on parents, students, and staff, and uses that information
-- to exclude any phone numbers that do not have the OptIn flag set.
--
-- In other words, I don't bother replicating that information to 
-- the PhoneNumber base table to avoid the overhead and potential data glitches
-- that result from non-normalized data.  However, keep in mind that a parent
-- phone number in the SIS table may be associated with an OptIn=true flag
-- that isn't reflected when that parents information is replicated to the 
-- StudentContacts table.  However, the data is married in again for the computation
-- of this view....
--
-- Todo: We should probably remove the work phone exception rule from this view
-- and push it as a data entry time input default that helps correctly set the OptIn
-- flag.  And then we can just always rely on OptIn for work phone numbers, thereby
-- simplifying our logic and creating a drop-dead simple rule to explain to clients:
-- "We will call a number if and only if the OptIn flag is set for that number."
--

--***
--*** IMPORTANT:
--*** DUPLICATE ANY CHANGES IN THIS VIEW TO THE SIMILAR VIEW: vPhoneNubersWithOptOut
--***

CREATE VIEW [dbo].[vPhoneNumbers_orig] 
as
with xSettings as (
	select 
		isnull(Comm2DefaultAreaCode,0) as Comm2DefaultAreaCode,
		isnull(AdultSchool,0) as AdultSchool 
	from settings
),
--
-- 3/17/2017 - Add feature to view to check for other instances of the same
--             phone number with a more recent verified on date.  May be able
--             to deprecate this in the future depending on how Matt checks for
--             and synchronizes/updates multiple instances of the same phone number.
--             NOTE: This structure would be better if it were normalized to have
--             a separate verification table with a primary key on Phone #...
pv as (
	select *
	from (
	select 
		Phone,
		ROW_NUMBER() OVER(PARTITION BY phone ORDER BY Phone,VerifiedOn desc) verified_row_lifo,
		phonenumbervalid,
		verifiedon,
		linetype
	from PhoneNumbers
	) xxx where verified_row_lifo=1
),
sc as (
	select
		StudentID scStudentID,
		ContactID scContactID,
		fname scFname,
		lname scLname,
		relationship,
		rolesandpermissions,
		Phone1OptIn scPhone1OptIn,
		Phone2OptIn scPhone2OptIn,
		Phone3OptIn scPhone3OptIn,
		ContactCategory
	from vStudentContacts_orig
),
s as (
	select 
		StudentID sStudentID,
		Phone1OptIn,
		Phone2OptIn,
		Phone3OptIn,
		Family2Phone1OptIn,
		Family2Phone2OptIn,
		fname,
		lname,
		_Status
	from vStudents_orig
	where _Status<>'Inactive'
) 
select 
	xx.PhoneNumberID,	
	ContactID,	
	TeacherID,	
	StudentID,
	fname xFname,
	lname xLname,
	_Status xStatus,
	ContactCategory xContactCategory,
	Type,	
	case when len(xx.phone)<=7 then
		cast(cast(
			case 
			when cast(xx.phone as bigint) between 1000000 and 9999999 
			then Comm2DefaultAreaCode else 0 end as bigint)
		* 10000000 + cast(xx.phone as bigint) as nvarchar(100))
	else xx.phone end
		as Phone,	
	Extension,	
--	CountryCode,	
--	TextAlertCapable,	
--	TextOptOut,	
--	TextAllowed,	
--	VoiceAllowed,	
--	Preferred,	
	pv.PhoneNumberValid,	
	pv.VerifiedOn,
	pv.LineType,
	case 
	when extension like '%work%' 
		or extension like '%x%'
		or extension like '%w.%'
		or extension like '%w)%'
		or extension+' ' like '%w %'
		or extension like '%wk%'
		or type like '%work%' 
	then
		1
	else
		0
	end as isWorkPhone,
	case when len(xx.phone)<7 or len(xx.phone)>7 then 0 else
		 case when cast(xx.phone as bigint) between 1000000 and 9999999 
		 and Comm2DefaultAreaCode <> 0 then 1 else 0 end end
		 as isDefaultAreaCodeApplied,
	case when 
		case when len(xx.phone)<7 or len(xx.phone)>7 then 0 else
			 case when cast(xx.phone as bigint) between 1000000 and 9999999 
			 and Comm2DefaultAreaCode <> 0 then 1 else 0 end end
			 + case when len(xx.phone)=10 then 1 else 0 end
		 = 1 then 1 else 0 end as isNumberOfDigitsValid
from (
	select xSettings.*,p.*,
		scFname fname,
		scLname lname,
		_Status,
		ContactCategory
	from 
		xSettings
		cross join PhoneNumbers p
		inner join sc on scContactID = p.ContactID
		inner join s on sStudentID = scStudentID 
		where (
			-- 
			-- Phones with a contact or contact-and-student record that we can confirm as Opt'd in...
			-- 
			scContactID = p.ContactID and (
				-- Parents replicated from student to contacts file ------------------------
				( AdultSchool=0 and rolesandpermissions='(SIS Parent Contact)' 
					and (
						-- SIS father and mother Opt Ins (may match up to 3 parsed phone #s)...
						(Relationship='Father' and Phone1OptIn=1) or 
						(Relationship='Mother' and Phone2OptIn=1) or
						(Relationship='Father 2' and Family2Phone1OptIn=1) or 
						(Relationship='Mother 2' and Family2Phone2OptIn=1) 
					) 
				) or (
				-- Contacts entered directly with a Comm2 callable ContactCategory ---------
					(rolesandpermissions<>'(SIS Parent Contact)' and isnull(ContactCategory,'')>'') and (
						-- individual contacts phones with individual Opt In flags...
						(p.Type='Phone 1' and scPhone1OptIn=1) or 
						(p.Type='Phone 2' and scPhone2OptIn=1) or
						(p.Type='Phone 3' and scPhone3OptIn=1) )
					and	( sc.relationship<>'Father/Parent 2' and sc.relationship<>'Mother/Parent 1' )
					/*
					** DS-1033 / FD 147366 - Parent opt. out (not OptIn) takes precedence
					**   over EM mother/father contacts since the information is from the
					**   same source and it is too much work expect schools to opt. out of 
					**   bother areas.
					**
					** Following didn't work, runs too slowly, so I made a quick EM specific rule above
					( sc.ContactCategory<>'PARENT' or p.phone not in (
						select phone 
						from vPhoneNumbersWithOptOuts vpnwoo
						inner join StudentContacts _sc on vpnwoo.ContactID = _sc.ContactID
						where _sc.StudentID = sc.StudentID
							and vpnwoo.OptIn = 0 
							and vpnwoo.rolesandpermissions = '(SIS Parent Contact)'
						)
					)
					*/
				)
			) 
		) 
	union
	select xSettings.*,p.*,
		fname,
		lname,
		_Status,
		'STUDENT' as ContactCategory	
	from 
		xSettings
		cross join PhoneNumbers p
		inner join s on sStudentID = p.StudentID 
	where 
		(p.Type='Phone' and Phone3OptIn=1)
		or (AdultSchool=1 and p.Type='Phone 1' and Phone1OptIn=1)
		or (AdultSchool=1 and p.Type='Phone 2' and Phone2OptIn=1)
		or (AdultSchool=1 and p.Type='Phone 3' and Phone3OptIn=1)
	union
	select xSettings.*,p.*,
		fname,
		lname,
		case when t.Active=1 then 'Active' else 'Inactive' end _Status,
		case when StaffType=1 then 'Teacher' else '' end 
			+ case when StaffType=2 then 'Admin (limited)' else '' end
			+ case when StaffType=3 then 'Admin (Full)' else '' end
			as ContactCategory	
	from 
		xSettings
		cross join PhoneNumbers p
		inner join Teachers t on t.TeacherID = p.TeacherID 
) xx
inner join pv on xx.phone=pv.phone
GO
