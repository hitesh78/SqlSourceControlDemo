SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Don Puls
-- Create date: 10/04/2018
-- Modified dt: 09/29/2021 ~JG
-- Description:	Checks if Email is valid for given AccountID
-- =============================================
CREATE   FUNCTION [dbo].[isAccountEmailValid]
(
	@AccountID nvarchar(100),
	@Email nvarchar(100)
)
RETURNS bit
AS
BEGIN
	Declare @AccessType nvarchar(10) = (Select Access From Accounts Where AccountID = @AccountID);
	Declare @AdultSchool bit = (Select AdultSchool From Settings Where SettingID = 1);

	Return
	(
		Select 
		case 
			when @AccessType = 'Family' and exists 
				(	
					Select * 
					From Students S
						inner join Families F
							on S.FamilyID = F.FamilyID 
					Where F.AccountID = @AccountID 
						and (S.Email1 = @Email or S.Email2 = @Email)
				) then 1
			when @AccessType = 'Family2' and exists 
				(	
					Select * 
					From Students S
						inner join Families F
							on S.Family2ID = F.FamilyID 
					Where F.AccountID = @AccountID 
						and (S.Email6 = @Email or S.Email7 = @Email)
				) then 1
			when @AccessType = 'Student' and @AdultSchool = 0 and exists 
				(
					Select * 
					From Students 
					Where AccountID = @AccountID 
						and (Email8 = @Email or SchoolEmail = @Email)
				) then 1
			when @AccessType = 'Student' and @AdultSchool = 1 and exists 
				(
					Select * 
					From Students S
					Where AccountID = @AccountID 
						and (S.Email1 = @Email or S.Email2 = @Email or S.Email3 = @Email)
				) then 1
			when @AccessType = 'Teacher' and exists 
				(
					Select * 
					From Teachers 
					Where AccountID = @AccountID 
						and (Email = @Email or Email2 = @Email or Email3 = @Email)
				) then 1
			when @AccessType = 'Principal' and exists 
				(
					Select * 
					From Teachers 
					Where AccountID = @AccountID 
						and (Email = @Email or Email2 = @Email or Email3 = @Email)
				) then 1
			when @AccessType = 'Admin' and exists 
				(
					Select * 
					From Teachers 
					Where AccountID = @AccountID 
						and (Email = @Email or Email2 = @Email or Email3 = @Email)
				) then 1
			else 0
		end
	)
END
GO
