SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Don Puls
-- Create date: 7/23/2014
-- Description:	Recieves an AccountID and returns the FamilyName and siblings
-- =============================================
CREATE FUNCTION [dbo].[getFamiliyNameFromAccountID]
(
@AccountID nvarchar(20)
)
RETURNS nvarchar(300)
AS
BEGIN
	RETURN 
	(
	Select
	case
		when isnull(ltrim(rtrim(replace(Father, ',', ''))),'') = '' and isnull(ltrim(rtrim(replace(Mother, ',', ''))),'') = '' then ltrim(rtrim(Lname))
		when isnull(ltrim(rtrim(replace(Father, ',', ''))),'') = '' and isnull(ltrim(rtrim(replace(Mother, ',', ''))),'') != ''	
			then ltrim(rtrim(replace(replace(Mother, ',', ''), Lname, '')	)) + ' ' + ltrim(rtrim(Lname))
		when isnull(ltrim(rtrim(replace(Father, ',', ''))),'') != '' and isnull(ltrim(rtrim(replace(Mother, ',', ''))),'') = ''	
			then ltrim(rtrim(replace(replace(Father, ',', ''), Lname, '')	)) + ' ' + ltrim(rtrim(Lname))
		else ltrim(rtrim(replace(replace(Father, ',', ''), Lname, '')	)) + ' & ' + 
				ltrim(rtrim(replace(replace(Mother, ',', ''), Lname, '')	)) + 
			' ' + ltrim(rtrim(Lname))
	end as FamiliyName
	From Students
	Where
	AccountID = @AccountID
	)	
END

GO
