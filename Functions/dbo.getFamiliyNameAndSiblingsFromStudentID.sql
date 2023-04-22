SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Don Puls
-- Create date: 7/23/2014
-- Description:	Recieves a StudentID and returns the FamilyName and siblings
--				Updated to also show StudentID in output
--				Used in Gradelink's AutoPost Payments feature
-- =============================================
CREATE   FUNCTION [dbo].[getFamiliyNameAndSiblingsFromStudentID]
(
@StudentID int
)
RETURNS nvarchar(300)
AS
BEGIN
	Declare @CRNL nchar(2) = CHAR(13) + CHAR(10)
	RETURN 
	(
	Select
	case
		when isnull(ltrim(rtrim(replace(Father, ',', ''))),'') = '' and isnull(ltrim(rtrim(replace(Mother, ',', ''))),'') = '' then ltrim(rtrim(Lname))
		when isnull(ltrim(rtrim(replace(Father, ',', ''))),'') = '' and isnull(ltrim(rtrim(replace(Mother, ',', ''))),'') != ''	
			then ltrim(rtrim(replace(replace(Mother, ',', ''), Lname, '')	)) + ' ' + ltrim(rtrim(Lname))
		when isnull(ltrim(rtrim(replace(Father, ',', ''))),'') != '' and isnull(ltrim(rtrim(replace(Mother, ',', ''))),'') = ''	
			then ltrim(rtrim(replace(replace(Father, ',', ''), Lname, '')	)) + ' ' + ltrim(rtrim(Lname))
		else ltrim(rtrim(replace(replace(Father, ',', ''), Lname, '')	)) + ' & ' + ltrim(rtrim(replace(replace(Mother, ',', ''), Lname, '')	)) + ' ' + ltrim(rtrim(Lname))
	end +
	(	-- get Sibling Students Info
		Select
		  (	Select 
				case 
					when StudentID = @StudentID then @CRNL + N'<b> - ' + ltrim(rtrim(Fname)) + ' (' + 
								case 
									when isnumeric(GradeLevel) = 0 then Gradelevel
									else dbo.GetNumberAsOrdinalString(GradeLevel)
								end
								+ ') <span style="color:#617291">' + convert(varchar(20), xStudentID) + '</span></b>' 
					else @CRNL + N' - ' + ltrim(rtrim(Fname)) + ' (' + 
							case 
								when isnumeric(GradeLevel) = 0 then Gradelevel
								else dbo.GetNumberAsOrdinalString(GradeLevel)
							end
							+ ') <span style="color:#617291">' + convert(varchar(20), xStudentID) + '</span>'
				end
			From Students
			Where FamilyID = S.FamilyID
			FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)')
	)	
	From Students S
	Where
	StudentID = @StudentID
	)	
END


GO
