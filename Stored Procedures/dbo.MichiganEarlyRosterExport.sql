SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 10-24-1018
-- Description:	Michigan Early Roster Export
-- =============================================
CREATE PROCEDURE [dbo].[MichiganEarlyRosterExport]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	Declare @ProfileID int = (Select ProfileID From ReportProfiles Where ReportName = 'MichiganEarlyRosterReport');
	Declare @SubmittingEntityTypeCode nvarchar(10) = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'SubmittingEntity/SubmittingEntityTypeCode');
	Declare @SubmittingEntityCode nvarchar(10) = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'SubmittingEntity/SubmittingEntityCode');
	Declare @OperatingISDESANumber nvarchar(10) = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'SchoolDemographics/OperatingISDESANumber');
	Declare @OperatingDistrictNumber nvarchar(10) = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'SchoolDemographics/OperatingDistrictNumber');
	Declare @SchoolFacilityNumber nvarchar(10) = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'SchoolDemographics/SchoolFacilityNumber');


	Declare @xmlData xml =
	(
	Select 
	@SubmittingEntityTypeCode as "SubmittingEntity/SubmittingEntityTypeCode",
	@SubmittingEntityCode as "SubmittingEntity/SubmittingEntityCode",
	Lname as "PersonalCore/LastName", 
	Fname as "PersonalCore/FirstName", 
	convert(date,BirthDate) as "PersonalCore/DateOfBirth", 
	left(Sex,1) as "PersonalCore/Gender",
	@OperatingISDESANumber as "SchoolDemographics/OperatingISDESANumber",
	@OperatingDistrictNumber as "SchoolDemographics/OperatingDistrictNumber",
	@SchoolFacilityNumber as "SchoolDemographics/SchoolFacilityNumber",
	xStudentID as "SchoolDemographics/StudentIdNumber",
	case GradeLevel
		when 'PS' then '30'
		when 'PK'then '30'
		when 'K' then '00'
		when '1' then '01'
		when '2' then '02'
		when '3' then '03'
		when '4' then '04'
		when '5' then '05'
		when '6' then '06'
		when '7' then '07'
		when '8' then '08'
		when '9' then '09'
		when '10' then '10'
		when '11' then '11'
		when '12' then '12'
	end as "SchoolDemographics/GradeOrSetting"	
	From Students
	for xml path ('EarlyRoster')
	)


	Select 
	--'http://www.w3.org/2001/XMLSchema-instance' as "@xmlns:xsi",
	'4' as "@SchemaVersionMinor",
	'1.0' as "@SubmittingSystemVersion",
	'EarlyRoster' as "@CollectionName",
	'www.gradelink.com' as "@SubmittingSystemVendor",
	'101' as "@CollectionId",
	'Collection' as "@SchemaVersionMajor",
	'Gradelink' as "@SubmittingSystemName",
	--'http://cepi.state.mi.us/msdsxml/EarlyRosterCollection4.xsd' as "@xsi:noNamespaceSchemaLocation",
	@xmlData
	for xml path ('EarlyRosterGroup')


END
GO
