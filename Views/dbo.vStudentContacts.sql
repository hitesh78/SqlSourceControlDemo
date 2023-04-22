SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vStudentContacts] as

select *, 
		'<b>'+FullName+'</b>' as ContactName,
        dbo.ConcatWithDelimiter('<b>'+Relationship+'</b>',
				RolesAndPermissions,'<br />') 
			as RelationshipAndRoles,
		
        dbo.ConcatWithDelimiter(
	        dbo.ConcatWithDelimiter(Email1,Email2,'<br />'),
	        Email3,'<br />') as Emails,
        dbo.ConcatWithDelimiter(
	        dbo.ConcatWithDelimiter(Phone1,Phone2,'<br />'),
	        Phone3,'<br />') as Phones,
	    dbo.ConcatWithDelimiter(dbo.ConcatWithDelimiter(
			AddressLine1,AddressLine2,'<br/>'),
			dbo.ConcatWithDelimiter(dbo.ConcatWithDelimiter(
				City,State,', '),Zip,' ')
			,'<br/>') as ContactAddress,
        dbo.ConcatWithDelimiter(Occupation,Employer,'<br />') as OccupationAndEmployer,

		dbo.ConcatWithDelimiter(GradeLevel,Class,'-') as Grade,
        dbo.ConcatWithDelimiter(StudentFather,StudentMother,'<br />') as StudentParents,
        
        '' as blank

FROM
(
	select
	-StudentID id,
	null ContactID, s.FullName, StudentID,
	'' Title, s.Fname, s.Mname, s.Lname, '' Suffix, '(Student record)' Relationship,
	'' RolesAndPermissions,
	s.FullName as StudentFullName,
	s.Fname as StudentFname, s.Lname as StudentLname,
	s.xStudentID, s.FamilyID, s.GradeLevel, s.Class, s._Status Status, s.Father StudentFather, s.Mother StudentMother,
	s.Phone1,s.Phone2,s.Phone3,
	null as Phone1OptIn, null as Phone2OptIn, Phone3OptIn, 
	s.Email1,s.Email2,s.Email3,
	s.Street AddressLine1, '' AddressLine2, s.City, s.State, s.Zip,
	'' as Occupation, '' as Employer,
	'' as notes, 
	'SIBLING' as ContactCategory
	
	from vStudents s
	where s.StudentID<>-1

	union select
	 
	c.ContactID id,
	c.ContactID,
	c.FullName,
	c.StudentID,
	c.Title, c.Fname, c.Mname, c.Lname, c.Suffix,c.Relationship,
	replace(c.RolesAndPermissions,'; ','<br/>') RolesAndPermissions,

	s.FullName as StudentFullName,
	s.Fname as StudentFname, s.Lname as StudentLname,
	s.xStudentID, s.FamilyID, s.GradeLevel, s.Class, s._Status Status, 
	s.Father StudentFather, s.Mother StudentMother,

	dbo.ConcatWithDelimiter(c.Phone1Num,c.Phone1Desc,' - ') Phone1,
	dbo.ConcatWithDelimiter(c.Phone2Num,c.Phone2Desc,' - ') Phone2,
	dbo.ConcatWithDelimiter(c.Phone3Num,c.Phone3Desc,' - ') Phone3,

	c.Phone1OptIn,c.Phone2OptIn,c.Phone3OptIn, 

	dbo.ConcatWithDelimiter(c.Email1,c.Email1Desc,' - ') Email1,
	dbo.ConcatWithDelimiter(c.Email2,c.Email2Desc,' - ') Email2,
	dbo.ConcatWithDelimiter(c.Email3,c.Email3Desc,' - ') Email3,

	c.AddressLine1, c.AddressLine2, c.City, c.State, c.Zip,
	c.Occupation, c.Employer, 

	Notes,

	-- 
	-- following is the same rule (and should remain the same) 
	-- as around line 85 in Settings_Comm2_Conversion.sql (and StudentInformation.aspx javascript!)
	-- so I've created a function for this "rule":
	dbo.ContactCategory(c.Relationship) ContactCategory

	from StudentContacts c 
	inner join vStudents s on s.StudentID = c.StudentID
	where s.StudentID<>-1
) x

GO
