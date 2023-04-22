SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Don Puls
-- Create date: 6/17/2013
-- Description:	Returns Incident Codes to be used in Multi-Select Lists on UI
-- =============================================
CREATE   FUNCTION [dbo].[GetMultiSelectIncidentCodes]()
RETURNS 
@MultiSelectValues table
(
IncidentCodes nvarchar(1000)
) 

AS
Begin

	Declare @tmpMultiSelectValues table(IncidentCodes nvarchar(1000)) 
	Declare @UseOnlyAdminConfIncidentCodes bit = (Select UseOnlyAdminConfIncidentCodes From Settings Where SettingID = 1)
	
	if @UseOnlyAdminConfIncidentCodes = 0
	Begin
		-- Custom Entered IncidentCodes
		Declare @csvIncidentCodes nvarchar(2000) =
		(
		SELECT SUBSTRING(
		(
		Select distinct ', ' + 
		replace(IncidentCodes, '; ', ',') 
		From 
		Discipline
		FOR XML PATH('')),2,200000) AS IncidentCodes
		)

		Insert into @tmpMultiSelectValues
		Select distinct * 
		From dbo.SplitCSVStrings(@csvIncidentCodes) 
	End

	if exists (Select * From SelectOptions Where SelectListID = 11)
	Begin
		-- Get School Specific Incident Codes
		Insert into @tmpMultiSelectValues
		select Title 
		From SelectOptions 
		Where 
		SelectListID = 11
	End
	Else
	Begin
		-- Get Defaults
		Insert into @tmpMultiSelectValues
		select Title 
		From vSelectOptions 
		Where 
		SelectListID = 11
	End

	insert into @MultiSelectValues
	Select distinct IncidentCodes
	From
	@tmpMultiSelectValues
	Order By IncidentCodes

	RETURN;
End
GO
