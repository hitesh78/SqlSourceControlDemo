SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 4/30/2013
-- Description:	Used For the StudentInfoPreviewPane uses in the Diocesan Interface
-- =============================================
CREATE Procedure [dbo].[POStudentInfoPreviewPane]
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
	Lname,
	Fname,
	Mname,
	case 
		when BirthDate = '01/01/1900' then ''
		when ISDATE(BirthDate) = 1 then dbo.GLformatdate(BirthDate)
		else ''
	end as BirthDate, 
	case 
		when ISDATE(BirthDate) = 1 then dbo.getAge(BirthDate)
		else ''
	end as StudentAge, 	
	Father,
	Mother,
	Phone1,
	Phone2,
	Phone3,
	Email1,
	Email2,
	Email3,
	Street,
	City,
	State,
	Zip,
	Street2,
	City2,
	State2,
	Zip2,
	dbo.GLformatdate(EntryDate) as EntryDate,
	dbo.GLformatdate(GraduationDate) as GraduationDate,
	dbo.GLformatdate(WithdrawalDate) as WithdrawalDate,
	GradeLevel,
	Sex as Gender,
	(select Ethnicity from StudentRoster where StudentID=S.StudentID) as [Ethnicity]
	From 
	Students S
	Where
	StudentID = @StudentID
	FOR XML RAW


End
GO
