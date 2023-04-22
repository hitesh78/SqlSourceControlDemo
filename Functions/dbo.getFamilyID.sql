SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 7/21/2014
-- Description:	Gets FamilyID
-- =============================================
CREATE FUNCTION [dbo].[getFamilyID]
(
	@Lname nvarchar(50),
	@Father nvarchar(50),
	@Mother nvarchar(50),
	@Street nvarchar(50),
	@Email1 nvarchar(50),
	@Phone1 nvarchar(50)
)
RETURNS int
AS
BEGIN

	Return
	isnull(
		(
			case
				when -- If a Father or Mother is not specified then you have to match on lastName and email1, or Phone1 or Street
					(
						(isnull(ltrim(rtrim(@Father)),'') = '' or isnull(ltrim(rtrim(@Mother)),'') = '')
					)
					and
					isnull(ltrim(rtrim(@Street)),'') + isnull(ltrim(rtrim(@Email1)),'') + isnull(ltrim(rtrim(@Phone1)),'') != '' 
				then
					(
					Select top 1 FamilyID 
					From Students
					Where
					FamilyID is not null
					and
					ltrim(rtrim(Lname)) = ltrim(rtrim(@Lname))
					and
					isnull(ltrim(rtrim(Father)),'') = isnull(ltrim(rtrim(@Father)),'')
					and
					isnull(ltrim(rtrim(Mother)),'') = isnull(ltrim(rtrim(@Mother)),'')
					and
						(	-- Matching on the first 5/8 characters is all that is required
						isnull(ltrim(rtrim(@Street)),'') != '' and left(isnull(ltrim(rtrim(@Street)),''),5) = left(isnull(ltrim(rtrim(Street)),''),5)
						or
						isnull(ltrim(rtrim(@Email1)),'') != '' and left(isnull(ltrim(rtrim(@Email1)),''),5) = left(isnull(ltrim(rtrim(Email1)),''),5)
						or
						isnull(ltrim(rtrim(@Phone1)),'') != '' and isnull(ltrim(rtrim(@Phone1)),'') = isnull(ltrim(rtrim(Phone1)),'')
						)
					)
				when -- When Father and Mother are specified then just match on Lname, Father, Mother
					(isnull(ltrim(rtrim(@Father)),'') != '' and isnull(ltrim(rtrim(@Mother)),'') != '')
				then
					(
					Select top 1 FamilyID 
					From Students
					Where
					ltrim(rtrim(Lname)) = ltrim(rtrim(@Lname))
					and
					isnull(ltrim(rtrim(Father)),'') = isnull(ltrim(rtrim(@Father)),'')
					and
					isnull(ltrim(rtrim(Mother)),'') = isnull(ltrim(rtrim(@Mother)),'')
					and
					FamilyID is not null
					)
				else null
				end
				
		),
		isnull((Select MAX(FamilyID) + 1 From Families), 1001)
	)	

END

GO
