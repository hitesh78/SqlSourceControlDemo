SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vEnrollContacts] as 
/*
-- 7/27/2015: FOLLOWING MADE OBSOLETE BY NEW SQL JOB TO UPDATE ENROLLMENTSTUDENT FIELDS ON SUBMIT,
--            CHANGING REFERENCES TO vEnrollmentStudent TO EnrollmentStudent!!
-- Pull data from vEnrollmentStudent instead of EnrollmentStudent since some fields (pages of fields)
-- that were defaulted from siblings may not even be stored for this student in the main table.
  2023.04.13	HC	Added Phone1OptIn, Phone2OptIn, Phone3OptIn 
*/

select ROW_NUMBER() OVER (partition by EnrollmentStudentID order  by EnrollmentStudentID) InstanceID, * from 
(
select EnrollmentStudentID,StudentID,Contact1Fname Fname,Contact1Lname Lname,null Mname, null suffix, 
Contact1Relationship Relationship,
Contact1Phone1 Phone1, Contact1Phone2 Phone2, 
case when isnull(Contact1Phone1,'')='' or DB_NAME()='1081' then '' else 'Phone 1' end 
   + case when DB_NAME()='1081' then '(DOB)' else '' end as Phone1Desc, 
case when isnull(Contact1Phone2,'')='' then '' else 'Phone 2' end Phone2Desc, 
null as Phone3, null as Phone3Desc,
null as Phone1OptIn,
null as Phone2OptIn,
null as Phone3OptIn,
null as Email1,
Contact1Addr Addr, null Addr2,
null city, null state, null zip,
null Occupation, null Employer,
dbo.ConcatWithDelimiter(Contact1Roles,
case when DB_NAME()='1081' then '(EnrollMe Add''l Family)' else '(EnrollMe Contact 1)' end,
'; ') Roles
from EnrollmentStudent
where EnrollmentStudentID is not null

union all
select EnrollmentStudentID,StudentID,Contact2Fname Fname,Contact2Lname Lname,null Mname, null suffix, 
Contact2Relationship Relationship,
Contact2Phone1 Phone1,Contact2Phone2 Phone2,
case when isnull(Contact2Phone1,'')='' or DB_NAME()='1081' then '' else 'Phone 1' end 
   + case when DB_NAME()='1081' then '(DOB)' else '' end as Phone1Desc, 
case when isnull(Contact2Phone2,'')='' then '' else 'Phone 2' end Phone2Desc, 
null as Phone3, null as Phone3Desc, 
null as Phone1OptIn,
null as Phone2OptIn,
null as Phone3OptIn,
null as Email1,
Contact2Addr Addr, null Addr2,
null city, null state, null zip,
null Occupation, null Employer,
dbo.ConcatWithDelimiter(Contact2Roles,
case when DB_NAME()='1081' then '(EnrollMe Add''l Family)' else '(EnrollMe Contact 2)' end,
'; ') Roles
from EnrollmentStudent
where EnrollmentStudentID is not null

union all
select EnrollmentStudentID,StudentID,Contact3Fname Fname,Contact3Lname Lname,null Mname, null suffix, 
Contact3Relationship Relationship,
Contact3Phone1 Phone1,Contact3Phone2 Phone2,
case when isnull(Contact3Phone1,'')='' or DB_NAME()='1081' then '' else 'Phone 1' end 
   + case when DB_NAME()='1081' then '(DOB)' else '' end as Phone1Desc, 
case when isnull(Contact3Phone2,'')='' then '' else 'Phone 2' end Phone2Desc, 
null as Phone3, null as Phone3Desc,
null as Phone1OptIn,
null as Phone2OptIn,
null as Phone3OptIn,
null as Email1,
Contact3Addr Addr, null Addr2,
null city, null state, null zip,
null Occupation, null Employer,
dbo.ConcatWithDelimiter(Contact3Roles,
case when DB_NAME()='1081' then '(EnrollMe Add''l Family)' else '(EnrollMe Contact 3)' end,
'; ') Roles
from EnrollmentStudent
where EnrollmentStudentID is not null

union all
select EnrollmentStudentID,StudentID,Contact4Fname Fname,Contact4Lname Lname,null Mname, null suffix, 
Contact4Relationship Relationship,
Contact4Phone1 Phone1,Contact4Phone2 Phone2,
case when isnull(Contact4Phone1,'')='' or DB_NAME()='1081' then '' else 'Phone 1' end 
   + case when DB_NAME()='1081' then '(DOB)' else '' end as Phone1Desc, 
case when isnull(Contact4Phone2,'')='' then '' else 'Phone 2' end Phone2Desc, 
null as Phone3, null as Phone3Desc,
null as Phone1OptIn,
null as Phone2OptIn,
null as Phone3OptIn,
null as Email1,
Contact4Addr Addr, null Addr2,
null city, null state, null zip,
null Occupation, null Employer,
dbo.ConcatWithDelimiter(Contact4Roles,
case when DB_NAME()='1081' then '(EnrollMe Add''l Family)' else '(EnrollMe Contact 4)' end,
'; ') Roles
from EnrollmentStudent
where EnrollmentStudentID is not null

union all
select EnrollmentStudentID,StudentID,Contact5Fname Fname,Contact5Lname Lname,null Mname, null suffix, 
Contact5Relationship Relationship,
Contact5Phone1 Phone1,Contact5Phone2 Phone2,
case when isnull(Contact5Phone1,'')='' or DB_NAME()='1081' then '' else 'Phone 1' end 
   + case when DB_NAME()='1081' then '(DOB)' else '' end as Phone1Desc, 
case when isnull(Contact5Phone2,'')='' then '' else 'Phone 2' end Phone2Desc, 
null as Phone3, null as Phone3Desc,
null as Phone1OptIn,
null as Phone2OptIn,
null as Phone3OptIn,
null as Email1,
Contact5Addr Addr, null Addr2,
null city, null state, null zip,
null Occupation, null Employer,
dbo.ConcatWithDelimiter(Contact5Roles,
case when DB_NAME()='1081' then '(EnrollMe Add''l Family)' else '(EnrollMe Contact 5)' end,
'; ') Roles
from EnrollmentStudent
where EnrollmentStudentID is not null

union all
select EnrollmentStudentID,StudentID,Contact6Fname Fname,Contact6Lname Lname,null Mname, null suffix, 
Contact6Relationship Relationship,
Contact6Phone1 Phone1,Contact6Phone2 Phone2,
case when isnull(Contact6Phone1,'')='' or DB_NAME()='1081' then '' else 'Phone 1' end 
   + case when DB_NAME()='1081' then '(DOB)' else '' end as Phone1Desc, 
case when isnull(Contact6Phone2,'')='' then '' else 'Phone 2' end Phone2Desc, 
null as Phone3, null as Phone3Desc,
null as Phone1OptIn,
null as Phone2OptIn,
null as Phone3OptIn,
null as Email1,
Contact6Addr Addr, null Addr2,
null city, null state, null zip,
null Occupation, null Employer,
dbo.ConcatWithDelimiter(Contact6Roles,
case when DB_NAME()='1081' then '(EnrollMe Add''l Family)' else '(EnrollMe Contact 6)' end,
'; ') Roles
from EnrollmentStudent
where EnrollmentStudentID is not null

union all
select EnrollmentStudentID,StudentID,FatherFname Fname,FatherLname Lname,FatherMname Mname, FatherSuffix Suffix,
'Father/Parent 2' Relationship,
FatherHomePhone Phone1, FatherCellPhone Phone2,
case when isnull(FatherHomePhone,'')='' then '' else 'Home/Primary' end Phone1Desc, 
case when isnull(FatherCellPhone,'')='' then '' else 'Cell' end Phone2Desc, 
FatherWorkPhone Phone3, 
case when isnull(FatherWorkPhone,'')='' 
then '' else dbo.ConcatWithDelimiter('ext. '+FatherWorkExtension,'Work',' - ') end Phone3Desc,
case when ISNULL(FatherHomePhone, '') <> '' Then 1 Else 0 END as Phone1OptIn,
case when ISNULL(FatherCellPhone, '') <> '' Then 1 Else 0 END as Phone2OptIn,
case when ISNULL(FatherWorkPhone, '') <> '' Then 1 Else 0 END as Phone3OptIn,
FatherEmail as Email1,
FatherAddressLine1 Addr, FatherAddressLine2 Addr2,
FatherCity city, FatherState state, FatherZip zip,
FatherOccupation Occupation, FatherEmployer Employer,
dbo.ConcatWithDelimiter(FatherRoles,'(EnrollMe Contact)','; ') Roles
from EnrollmentStudent
where EnrollmentStudentID is not null 
and (select count(*) from EnrollmentStudent 
		where Page_Father=1)>0 -- indicates father page is used / on in settings

union all
select EnrollmentStudentID,StudentID,MotherFname Fname,MotherLname Lname,MotherMname Mname, MotherSuffix Suffix,
'Mother/Parent 1' Relationship,
MotherHomePhone Phone1, MotherCellPhone Phone2,
case when isnull(MotherHomePhone,'')='' then '' else 'Home/Primary' end Phone1Desc, 
case when isnull(MotherCellPhone,'')='' then '' else 'Cell' end Phone2Desc, 
MotherWorkPhone Phone3, 
case when isnull(MotherWorkPhone,'')='' 
then '' else dbo.ConcatWithDelimiter('ext. '+MotherWorkExtension,'Work',' - ') end Phone3Desc,
case when ISNULL(MotherHomePhone, '') <> '' Then 1 Else 0 END as Phone1OptIn,
case when ISNULL(MotherCellPhone, '') <> '' Then 1 Else 0 END as Phone2OptIn,
case when ISNULL(MotherWorkPhone, '') <> '' Then 1 Else 0 END as Phone3OptIn,
MotherEmail as Email1,
MotherAddressLine1 Addr, MotherAddressLine2 Addr2,
MotherCity city, MotherState state, MotherZip zip,
MotherOccupation Occupation, MotherEmployer Employer,
dbo.ConcatWithDelimiter(MotherRoles,'(EnrollMe Contact)','; ') Roles
from EnrollmentStudent
where EnrollmentStudentID is not null 
and (select count(*) from EnrollmentStudent 
		where Page_Mother=1)>0 -- indicates mother page is used / on in settings

union all
select EnrollmentStudentID,StudentID,Guardian1Fname Fname,Guardian1Lname Lname,Guardian1Mname Mname, Guardian1Suffix Suffix,
Guardian1Relationship Relationship,
Guardian1HomePhone Phone1, Guardian1CellPhone Phone2,
case when isnull(Guardian1HomePhone,'')='' then '' else 'Home/Primary' end Phone1Desc, 
case when isnull(Guardian1CellPhone,'')='' then '' else 'Cell' end Phone2Desc, 
Guardian1WorkPhone Phone3, 
case when isnull(Guardian1WorkPhone,'')='' 
then '' else dbo.ConcatWithDelimiter('ext. '+Guardian1WorkExtension,'Work',' - ') end Phone3Desc,
case when ISNULL(Guardian1HomePhone, '') <> '' Then 1 Else 0 END as Phone1OptIn,
case when ISNULL(Guardian1CellPhone, '') <> '' Then 1 Else 0 END as Phone2OptIn,
case when ISNULL(Guardian1WorkPhone, '') <> '' Then 1 Else 0 END as Phone3OptIn,
Guardian1Email as Email1,
Guardian1AddressLine1 Addr, Guardian1AddressLine2 Addr2,
Guardian1City city, Guardian1State state, Guardian1Zip zip,
Guardian1Occupation Occupation, Guardian1Employer Employer,
dbo.ConcatWithDelimiter(Guardian1Roles,'(EnrollMe Contact)','; ') Roles
from EnrollmentStudent
where EnrollmentStudentID is not null
and (select count(*) from EnrollmentStudent 
		where Page_Guardian1=1)>0 -- indicates guardian 1 page is used / on in settings

union all
select EnrollmentStudentID,StudentID,Guardian2Fname Fname,Guardian2Lname Lname,Guardian2Mname Mname, Guardian2Suffix Suffix,
Guardian2Relationship Relationship,
Guardian2HomePhone Phone1, Guardian2CellPhone Phone2,
case when isnull(Guardian2HomePhone,'')='' then '' else 'Home/Primary' end Phone1Desc, 
case when isnull(Guardian2CellPhone,'')='' then '' else 'Cell' end Phone2Desc, 
Guardian2WorkPhone Phone3, 
case when isnull(Guardian2WorkPhone,'')='' 
then '' else dbo.ConcatWithDelimiter('ext. '+Guardian2WorkExtension,'Work',' - ') end Phone3Desc,
case when ISNULL(Guardian2HomePhone, '') <> '' Then 1 Else 0 END as Phone1OptIn,
case when ISNULL(Guardian2CellPhone, '') <> '' Then 1 Else 0 END as Phone2OptIn,
case when ISNULL(Guardian2WorkPhone, '') <> '' Then 1 Else 0 END as Phone3OptIn,
Guardian2Email as Email1,
Guardian2AddressLine1 Addr, Guardian2AddressLine2 Addr2,
Guardian2City city, Guardian2State state, Guardian2Zip zip,
Guardian2Occupation Occupation, Guardian2Employer Employer,
dbo.ConcatWithDelimiter(Guardian2Roles,'(EnrollMe Contact)','; ') Roles
from EnrollmentStudent
where EnrollmentStudentID is not null
and (select count(*) from EnrollmentStudent 
		where Page_Guardian2=1)>0 -- indicates guardian 1 page is used / on in settings

union all
select EnrollmentStudentID,StudentID,DoctorFname Fname,DoctorLname Lname,null Mname,null Suffix,
'Doctor' Relationship,
DoctorPhone Phone1, null Phone2,
null Phone1Desc, 
null Phone2Desc, 
null Phone3, 
null Phone3Desc,
null as Phone1OptIn,
null as Phone2OptIn,
null as Phone3OptIn,
null as Email1,
DoctorAddress Addr, null Addr2,
null city, null state, null zip,
null Occupation, null Employer,
'(EnrollMe Contact)' Roles
from EnrollmentStudent
where EnrollmentStudentID is not null

union all
select EnrollmentStudentID,StudentID,DentistFname Fname,DentistLname Lname,null Mname,null Suffix,
'Dentist' Relationship,
DentistPhone Phone1, null Phone2,
null Phone1Desc, 
null Phone2Desc, 
null Phone3, 
null Phone3Desc,
null as Phone1OptIn,
null as Phone2OptIn,
null as Phone3OptIn,
null as Email1,
DentistAddress Addr, null Addr2,
null city, null state, null zip,
null Occupation, null Employer,
'(EnrollMe Contact)' Roles
from EnrollmentStudent
where EnrollmentStudentID is not null
) x
where (Lname is not null or Fname is not null)


GO
