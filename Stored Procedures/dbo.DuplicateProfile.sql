SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[DuplicateProfile]
	@ProfileID int
as

Declare @ReportName nvarchar(100)
Declare @ProfileName nvarchar(100)
Declare @ProfileJson nvarchar(max)
Declare @NewProfileName nvarchar(100)
Declare @NewProfileJson nvarchar(max)
Declare @NewProfileID int

Select
@ReportName = ReportName,
@ProfileName = ProfileName,
@NewProfileJson = ProfileJson,
@NewProfileName = ProfileName + ' Copy'
From ReportProfiles
Where ProfileID = @ProfileID

Insert into ReportProfiles (ReportName, ProfileName,ProfileJson)
Values(@ReportName, @NewProfileName, @NewProfileJson)

Set @NewProfileID = (Select IDENT_CURRENT('ReportProfiles'))

Insert into ReportSettings (ProfileID, SettingName, SettingValue, BasicSetting, Tooltip, TipImage)
Select
@NewProfileID,
SettingName,
SettingValue,
BasicSetting,
Tooltip,
TipImage
From ReportSettings
Where
ProfileID = @ProfileID


Insert into ReportHTML (ProfileID, HTMLSection, HTML)
Select
@NewProfileID,
HTMLSection,
HTML
From ReportHTML
Where
ProfileID = @ProfileID
GO
