SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 4/30/2013
-- Description:	Used For the StudentInfoPreviewPane uses in the Diocesan Interface
-- =============================================
CREATE Procedure [dbo].[POStudentInfoPreviewPane_anonymous]
@StudentID int,
@SchoolID nvarchar(10)
AS
BEGIN
	SET NOCOUNT ON;


	Declare @AccountID nvarchar(100) = (Select AccountID From Students Where StudentID = @StudentID)
	Declare @LastLoginTime nvarchar(100) = (Select LastLoginTime From Accounts Where AccountID = @AccountID)

	Declare @EligibilityStatus bit =
	(
	select dbo.isStudentEligible(1129)
	)
	

	Declare @SchoolOrgInfo table (SchoolName nvarchar(50), SchoolGroup nvarchar(50))
	Insert into @SchoolOrgInfo
	Select
	SchoolName as SchoolName,
	case
		when POG.POGName like '%Deanery%' then 'Deanery: ' + POG.POGName
		when POG.POGName like '%Region%' then 'Region: ' + POG.POGName
	end as SchoolGroups
	From 
	[LKG].dbo.Schools S
		inner join
	[LKG].dbo.SchoolsParentOrgs SPO
		on S.SchoolID = SPO.SchoolID
		inner join
	[LKG].dbo.SPOGroups SPOG
		on SPO.SPOID = SPOG.SPOID
		inner join
	[LKG].dbo.POGroups POG
		on SPOG.POGID = POG.POGID
	Where
	S.SchoolID = @SchoolID
	and
	(
	POG.POGName like '%Deanery%'
	or
	POG.POGName like '%Region%'
	)

	Declare 
	@SchoolName nvarchar(50) = (Select top 1 SchoolName From @SchoolOrgInfo),
	@SchoolDeanery nvarchar(50) = (Select top 1 replace(SchoolGroup, 'Deanery: ', '') From @SchoolOrgInfo where SchoolGroup like '%Deanery%'),
	@SchoolRegion nvarchar(50) = (Select top 1 replace(SchoolGroup, 'Region: ', '') From @SchoolOrgInfo where SchoolGroup like '%Region%'),
	@SchoolCity nvarchar(50) = (Select SchoolCity From Settings Where SettingID = 1)

	Declare
	@ShortSchoolDeaneryName nvarchar(10) = SUBSTRING(@SchoolDeanery, CHARINDEX(' ',@SchoolDeanery)+1,20)
	-- remove leading zeros
	Set @ShortSchoolDeaneryName = SUBSTRING(@ShortSchoolDeaneryName, PATINDEX('%[^0 ]%', @ShortSchoolDeaneryName + ' '), LEN(@ShortSchoolDeaneryName))


	Declare @FileID int =
	(
	Select top 1
	B.FileID
	From
	StudentBinfiles SB
		inner join
	BinFiles B
		on SB.FileID = B.FileID
	Where
	SB.StudentID = @StudentID
	Order By FileTimestamp desc
	)

	Select 
	@SchoolID as SchoolID,
	@FileID as FileID,
	@EligibilityStatus as EligibilityStatus,
	@LastLoginTime as LastLoginTime,
	@SchoolName as SchoolName,
	@SchoolDeanery as SchoolDeanery,
	@ShortSchoolDeaneryName as ShortSchoolDeaneryName,
	@SchoolRegion as SchoolRegion,
	@SchoolCity as SchoolCity,
	@SchoolID + convert(nvarchar(12),xStudentID) as POStudentID,
	Status as [Status],
	ln.anonymous_last_name Lname,
	case when Sex='Female' then fn.fname_female else fn.fname_male end Fname,
	Mname,
	case 
		when BirthDate = '01/01/1900' then ''
		when ISDATE(BirthDate) = 1 then dbo.GLformatdate(cast(cast(year(birthdate) as varchar(4))+'/01/01' as date))
		else ''
	end as BirthDate, 
	case 
		when ISDATE(BirthDate) = 1 then dbo.getAge(BirthDate)
		else ''
	end as StudentAge, 	
	fn_parents.fname_male+' '+ln.anonymous_last_name Father,
	fn_parents.fname_female+' '+ln.anonymous_last_name Mother,
	LKG.dbo.ScrambleDigits(Phone1) as Phone1,
	LKG.dbo.ScrambleDigits(Phone2) as Phone2,
	LKG.dbo.ScrambleDigits(Phone3) as Phone3,
	fn_parents.fname_male+'@gmail.com' Email1,
	fn_parents.fname_female+'@gmail.com'Email2,
	ln.anonymous_last_name+'@gmail.com' Email3,
	LKG.dbo.ScrambleDigits(Street) as Street,
	City,
	State,
	LKG.dbo.ScrambleDigits(Zip) as Zip,
	LKG.dbo.ScrambleDigits(Street2) as Street2,
	City2,
	State2,
	LKG.dbo.ScrambleDigits(Zip2) as Zip2,
	dbo.GLformatdate(EntryDate) as EntryDate,
	dbo.GLformatdate(GraduationDate) as GraduationDate,
	dbo.GLformatdate(WithdrawalDate) as WithdrawalDate,
	GradeLevel,
	Sex as Gender,
	(select Ethnicity from StudentRoster where StudentID=S.StudentID) as [Ethnicity]
	From 
	Students S
	inner join LKG.dbo.last_names_1000() ln
	on (StudentID+@SchoolID)%1000 = ln.anonymous_lname_id
	inner join LKG.dbo.first_names_500() fn
	on abs(cast(checksum(StudentID,@SchoolID,fname) as bigint))%500 = fn.anonymous_fname_id	
	inner join LKG.dbo.first_names_500() fn_parents
	on abs(cast(checksum(StudentID,@SchoolID,fname,DB_ID()) as bigint))%500 = fn_parents.anonymous_fname_id	
	Where
	StudentID = @StudentID
	FOR XML RAW


End
GO
