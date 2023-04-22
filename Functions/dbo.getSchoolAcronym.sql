SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 4/25/2013
-- Description:	Returns the school acronym that is typically used in password generation 
-- =============================================
CREATE FUNCTION [dbo].[getSchoolAcronym]()
RETURNS nvarchar(10)
AS
BEGIN

Declare @SchoolName nvarchar(100) =
(
Select
replace(replace(replace(SchoolName, ' the ', ' '), ' of ', ' '), '&', '')
From 
Settings
Where SettingID = 1
)


declare @textXML xml =
(
	Select
	cast('<d>' + replace(@SchoolName, ' ', '</d><d>') + '</d>' as xml)
	From 
	Settings 
	Where SettingID = 1
);

declare @Abbr nvarchar(20) = ''

select 
@Abbr = @Abbr + left(T.split.value('.', 'nvarchar(max)'),1)
from 
@textXML.nodes('/d') T(split)

return @Abbr

END

GO
