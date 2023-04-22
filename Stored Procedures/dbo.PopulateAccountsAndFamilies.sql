SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Don Puls
-- Create date: 7/21/2014
-- Modified dt: 1/21/2022 ~JG
-- Description:	Populates Accounts and Families tables on Student insert/update
-- Mod Desc:	Replace single quotes in account ID's: REPLACE(@text, char(0x0027), '')
-- =============================================
CREATE   Procedure [dbo].[PopulateAccountsAndFamilies] 
@FamilyInfo FamilyTableType ReadOnly
AS
BEGIN
	SET NOCOUNT ON;

	/*
	Select only distinct Families and populate Accounts and Families tables
	AccountIDs will consist of concatenated:
	- the full last name 
	- the dash symbol "-"
	- first initial of the Father
	- first initial of the Mother
	If the AccountID already exists in the Accounts then a number will be appended to differentiate
	the AccountID 
	*/

	-- 1. Populate into editable temp table
	declare @tempFamilies table(ID int identity(1,1), AccountID nvarchar(50), FamilyID int)
	Insert into @tempFamilies
	Select distinct
	REPLACE(ltrim(rtrim(S.Lname)), char(0x0027), '') + '-' +
	isnull(LEFT(ltrim(rtrim(
		case 
			when patindex('%,%',S.Father) = 0 then Father
			else substring(S.Father, patindex('%,%',S.Father) + 1, 100)
		end
	)), 1),N'') + 
	isnull(LEFT(ltrim(rtrim(
		case 
			when patindex('%,%',S.Mother) = 0 then Mother
			else substring(S.Mother, patindex('%,%',S.Mother) + 1, 100)
		end
	)), 1),N''),
	S.FamilyID
	From @FamilyInfo S
	Where
	S.FamilyID not in (Select FamilyID From Families)

	-- Iterate over @tempFamilies and update AccountID with appended # if conflicts exist
	Declare @NumLines int = @@RowCount
	Declare @LineNumber int = 1
	Declare @AccountNum int
	Declare @OrigAccountID nvarchar(50)
	Declare @AccountID nvarchar(50)
 
	While @LineNumber <= @NumLines
	Begin
	
		set @OrigAccountID = (Select AccountID From @tempFamilies Where ID = @LineNumber)
		set @AccountID = @OrigAccountID
		set @AccountNum = 1
		while exists (Select 1 From Accounts Where AccountID = @AccountID)
			or exists (Select 1 From @tempFamilies Where AccountID = @AccountID and ID<>@LineNumber)
		Begin
			Set @AccountID = @OrigAccountID + CONVERT(nvarchar(10), @AccountNum)
			Set @AccountNum = @AccountNum + 1
		End  
	
		Update @tempFamilies set AccountID = @AccountID Where ID = @LineNumber
		
		Set @LineNumber = @LineNumber + 1
	End	
 
	-- Insert into Accounts
	Insert into Accounts(AccountID, ThePassword, Access)
	Select
	replace(AccountID, char(146), char(39)),
	max(dbo.GeneratePassword()), -- DS-479 avoid dups
	'Family'
	From 
	@tempFamilies
	group by AccountID			-- DS-479 avoid dups

	-- Insert into Families
	Insert into Families (AccountID, FamilyID)
	Select
	replace(AccountID, char(146), char(39)),
	max(FamilyID) 		-- DS-479 avoid dups
	From 
	@tempFamilies	
	group by AccountID 	-- DS-479 avoid dups

END

GO
