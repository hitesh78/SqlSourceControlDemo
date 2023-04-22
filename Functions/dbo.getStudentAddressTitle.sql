SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 8/20/2018
-- Description:	Table to store "To the parents of [Fname] [Lname]" text in the proper format for the 
-- specific language of that school 
-- =============================================
/*
Sample Usage:
Select 
Sa.AddressTitle
From 
Students S
	inner join
dbo.getStudentAddressTitle() Sa
	on S.StudentID = Sa.StudentID
*/

CREATE FUNCTION [dbo].[getStudentAddressTitle]()
RETURNS @X TABLE
(
StudentID int Primary Key,
AddressTitle nvarchar(100)
) 

AS
BEGIN
INSERT INTO @X 
	Select
	StudentID,
	case (Select AdminDefaultLanguage From Settings)
	when 'Spanish' then
		case when (Select AdultSchool From Settings) = 0
			then  N'A los Padres de ' + Fname  +  N' ' + Lname
			else  Fname  +  N' ' + Lname
		end		
	when 'Chinese' then
		case when (Select AdultSchool From Settings) = 0
			then  N'致 ' + Lname  +  Fname + N' 的家长'
			else  Lname  +  N' ' + Fname
		end		
	else -- Default to English; covers 'English' AND '' cases (field can be blank but not null)... 
		case when (Select AdultSchool From Settings) = 0
			then  N'To the Parents of ' + Fname  +  N' ' + Lname
			else  Fname  +  N' ' + Lname
		end		
	end as AddressTitle
	From Students
RETURN;
END
GO
