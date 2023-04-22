SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 10/30/2018
-- Description:	Gets FamilyID2 (based on existing getFamilyID function)
-- =============================================
CREATE FUNCTION [dbo].[getFamily2ID]
(
	@Lname nvarchar(50),
	@Family2Name1 nvarchar(50),
	@Family2Name2 nvarchar(50),
	@Street2 nvarchar(50),
	@Email6 nvarchar(50),
	@Email7 nvarchar(50),
	@Family2Phone1 nvarchar(50),
	@Family2Phone2 nvarchar(50)
)
RETURNS int
AS
BEGIN
	declare @rv int =
--	isnull(
		(
			case
				when -- If a Father or Mother is not specified then you have to match on lastName and email1, or Phone1 or Street
					(
						(isnull(ltrim(rtrim(@Family2Name1)),'') = '' or isnull(ltrim(rtrim(@Family2Name2)),'') = '')
					)
					and
					(
						isnull(ltrim(rtrim(@Street2)),'') + isnull(ltrim(rtrim(@Email6)),'') + isnull(ltrim(rtrim(@Family2Phone1)),'') != '' 
						or
						isnull(ltrim(rtrim(@Street2)),'') + isnull(ltrim(rtrim(@Email7)),'') + isnull(ltrim(rtrim(@Family2Phone2)),'') != '' 
					)
				then
					(
					Select top 1 Family2ID 
					From Students
					Where
					Family2ID is not null
					and
					ltrim(rtrim(Lname)) = ltrim(rtrim(@Lname))
					and
					isnull(ltrim(rtrim(Family2Name1)),'') = isnull(ltrim(rtrim(@Family2Name1)),'')
					and
					isnull(ltrim(rtrim(Family2Name2)),'') = isnull(ltrim(rtrim(@Family2Name2)),'')
					and
						(	-- Matching on the first 5/8 characters is all that is required
						isnull(ltrim(rtrim(@Street2)),'') != '' and left(isnull(ltrim(rtrim(@Street2)),''),5) = left(isnull(ltrim(rtrim(Street2)),''),5)
						or
						isnull(ltrim(rtrim(@Email6)),'') != '' and left(isnull(ltrim(rtrim(@Email6)),''),5) = left(isnull(ltrim(rtrim(Email6)),''),5)
						or
						isnull(ltrim(rtrim(@Email7)),'') != '' and left(isnull(ltrim(rtrim(@Email7)),''),5) = left(isnull(ltrim(rtrim(Email7)),''),5)
						or
						isnull(ltrim(rtrim(@Family2Phone1)),'') != '' and isnull(ltrim(rtrim(@Family2Phone1)),'') = isnull(ltrim(rtrim(Family2Phone1)),'')
						or
						isnull(ltrim(rtrim(@Family2Phone2)),'') != '' and isnull(ltrim(rtrim(@Family2Phone2)),'') = isnull(ltrim(rtrim(Family2Phone2)),'')
						)
					)
				when -- When Father and Mother are specified then just match on Lname, Father, Mother
					(isnull(ltrim(rtrim(@Family2Name1)),'') != '' and isnull(ltrim(rtrim(@Family2Name2)),'') != '')
				then
					(
					Select top 1 Family2ID 
					From Students
					Where
					ltrim(rtrim(Lname)) = ltrim(rtrim(@Lname))
					and
					isnull(ltrim(rtrim(Family2Name1)),'') = isnull(ltrim(rtrim(@Family2Name1)),'')
					and
					isnull(ltrim(rtrim(Family2Name2)),'') = isnull(ltrim(rtrim(@Family2Name2)),'')
					and
					Family2ID is not null
					)
				else null
				end
--		),isnull((Select MAX(FamilyID) + 1 From Families), 1001)
		)

	-- See DS-479 regarding justification for this update to replace simple isnull handling above
	IF (@rv is null)
		-- Assign new family ID
		-- use session context variable to increment if multiple new IDs needed
	BEGIN
		SET @rv = 
			-- get prior new value from this session if available
			ISNULL(CAST(SESSION_CONTEXT(N'LastNewFamilyID') AS INT), 
			-- else get last high value from table
			isnull((Select MAX(FamilyID) From Families), 	
			-- else initialize first value if needed
			1000))
			-- and increment last value for the next, new records
			+ 1; 										 	
		-- save this new family ID assigned in this session in case
		-- we need additional new values in this session to process
		-- a batch of new rows...
		EXEC sp_set_session_context N'LastNewFamilyID', @rv;
	END

	RETURN @rv;
END

GO
