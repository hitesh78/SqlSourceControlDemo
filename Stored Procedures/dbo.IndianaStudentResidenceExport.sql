SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 5/1/2020
-- Description:	csv export for IndianaS tudent Residence Export
-- =============================================
CREATE PROCEDURE [dbo].[IndianaStudentResidenceExport] 
AS
BEGIN

	SET NOCOUNT ON;

	Declare @SchoolCode nvarchar(50) = (Select SchoolCode From Settings Where SettingID = 1)

	Select
	isnull(replace(rtrim(ltrim(@SchoolCode)), ',', ' '),'') as [School Code],
	isnull(replace(rtrim(ltrim(SM.StandTestID)), ',', ' '),'') as [Student Test Number],
	isnull(replace(rtrim(ltrim(S.Street)), ',', ' '),'') as [Street Address],
	isnull(replace(rtrim(ltrim(S.City)), ',', ' '),'') as [City],
	isnull(replace(replace(rtrim(ltrim(S.State)), ',', ' '), 'Indiana', 'IN'),'') as [State/Province],
	isnull(replace(rtrim(ltrim(S.Zip)), ',', ' '),'') as [Postal Code]
	From 
	Students S
		inner join
	StudentMiscFields SM
		on S.StudentID = SM.StudentID
	Where
	S.Active = 1
	and
	isnull(SM.StandTestID,'') != ''
	and
	S.GradeLevel in ('PK','k','1','2','3','4','5','6','7','8','9','10','11','12','13') 
	and
	replace(replace(rtrim(ltrim(S.State)), ',', ' '), 'Indiana', 'IN') = 'IN'

END
GO
