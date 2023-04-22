SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[ClassComments]
@ClassID int,
@EK Dec(15,15)
as

Declare @Comment1 as  nvarchar(50)
Declare @Comment2 as  nvarchar(50)
Declare @Comment3 as  nvarchar(50)
Declare @Comment4 as  nvarchar(50)
Declare @Comment5 as  nvarchar(50)
Declare @Comment6 as  nvarchar(50)
Declare @Comment7 as  nvarchar(50)
Declare @Comment8 as  nvarchar(50)
Declare @Comment9 as  nvarchar(50)
Declare @Comment10 as  nvarchar(50)
Declare @Comment11 as  nvarchar(50)
Declare @Comment12 as  nvarchar(50)
Declare @Comment13 as  nvarchar(50)
Declare @Comment14 as  nvarchar(50)
Declare @Comment15 as  nvarchar(50)
Declare @Comment16 as  nvarchar(50)
Declare @Comment17 as  nvarchar(50)
Declare @Comment18 as  nvarchar(50)
Declare @Comment19 as  nvarchar(50)
Declare @Comment20 as  nvarchar(50)
Declare @Comment21 as  nvarchar(50)
Declare @Comment22 as  nvarchar(50)
Declare @Comment23 as  nvarchar(50)
Declare @Comment24 as  nvarchar(50)
Declare @Comment25 as  nvarchar(50)
Declare @Comment26 as  nvarchar(50)
Declare @Comment27 as  nvarchar(50)
Declare @Comment28 as  nvarchar(50)
Declare @Comment29 as  nvarchar(50)
Declare @Comment30 as  nvarchar(50)
Declare @CommentName as nvarchar(50)
Declare @CommentRows as int


Select @CommentRows =
	case
		When Comment1 = '' then 0
		When Comment4 = '' then 1
		When Comment7 = '' then 2
		When Comment10 = '' then 3
		When Comment13 = '' then 4
		When Comment16 = '' then 5
		When Comment19 = '' then 6
		When Comment22 = '' then 7
		When Comment25 = '' then 8
		When Comment28 = '' then 9
		else 10
	end
From Settings where SettingID = 1


Select

@CommentName = CommentName,

@Comment1 =
	case
		When Comment1 = '' then null
		else '1. ' + Comment1
	end,
@Comment2 =
	case
		When Comment2 = '' then null
		else '2. ' + Comment2
	end,
@Comment3 =
	case
		When Comment3 = '' then null
		else '3. ' + Comment3
	end,
@Comment4 =
	case
		When Comment4 = '' then null
		else '4. ' + Comment4
	end,
@Comment5 =
	case
		When Comment5 = '' then null
		else '5. ' + Comment5
	end,
@Comment6 =
	case
		When Comment6 = '' then null
		else '6. ' + Comment6
	end,
@Comment7 =
	case
		When Comment7 = '' then null
		else '7. ' + Comment7
	end,
@Comment8 =
	case
		When Comment8 = '' then null
		else '8. ' + Comment8
	end,
@Comment9 =
	case
		When Comment9 = '' then null
		else '9. ' + Comment9
	end,
@Comment10 =
	case
		When Comment10 = '' then null
		else '10. ' + Comment10
	end,
@Comment11 =
	case
		When Comment11 = '' then null
		else '11. ' + Comment11
	end,
@Comment12 =
	case
		When Comment12 = '' then null
		else '12. ' + Comment12
	end,
@Comment13 =
	case
		When Comment13 = '' then null
		else '13. ' + Comment13
	end,
@Comment14 =
	case
		When Comment14 = '' then null
		else '14. ' + Comment14
	end,
@Comment15 =
	case
		When Comment15 = '' then null
		else '15. ' + Comment15
	end,
@Comment16 =
	case
		When Comment16 = '' then null
		else '16. ' + Comment16
	end,
@Comment17 =
	case
		When Comment17 = '' then null
		else '17. ' + Comment17
	end,
@Comment18 =
	case
		When Comment18 = '' then null
		else '18. ' + Comment18
	end,
@Comment19 =
	case
		When Comment19 = '' then null
		else '19. ' + Comment19
	end,
@Comment20 =
	case
		When Comment20 = '' then null
		else '20. ' + Comment20
	end,
@Comment21 =
	case
		When Comment21 = '' then null
		else '21. ' + Comment21
	end,
@Comment22 =
	case
		When Comment22 = '' then null
		else '22. ' + Comment22
	end,
@Comment23 =
	case
		When Comment23 = '' then null
		else '23. ' + Comment23
	end,
@Comment24 =
	case
		When Comment24 = '' then null
		else '24. ' + Comment24
	end,
@Comment25 =
	case
		When Comment25 = '' then null
		else '25. ' + Comment25
	end,
@Comment26 =
	case
		When Comment26 = '' then null
		else '26. ' + Comment26
	end,
@Comment27 =
	case
		When Comment27 = '' then null
		else '27. ' + Comment27
	end,
@Comment28 =
	case
		When Comment28 = '' then null
		else '28. ' + Comment28
	end,
@Comment29 =
	case
		When Comment29 = '' then null
		else '29. ' + Comment29
	end,
@Comment30 =
	case
		When Comment30 = '' then null
		else '30. ' + Comment30
	end

From Settings Where SettingID = 1



Select
	@CommentName as CommentName,
	@CommentRows as CommentRows,
	@Comment1 as Comment1,
	@Comment2 as Comment2,
	@Comment3 as Comment3,
	@Comment4 as Comment4,
	@Comment5 as Comment5,
	@Comment6 as Comment6,
	@Comment7 as Comment7,
	@Comment8 as Comment8,
	@Comment9 as Comment9,
	@Comment10 as Comment10,
	@Comment11 as Comment11,
	@Comment12 as Comment12,
	@Comment13 as Comment13,
	@Comment14 as Comment14,
	@Comment15 as Comment15,
	@Comment16 as Comment16,
	@Comment17 as Comment17,
	@Comment18 as Comment18,
	@Comment19 as Comment19,
	@Comment20 as Comment20,
	@Comment21 as Comment21,
	@Comment22 as Comment22,
	@Comment23 as Comment23,
	@Comment24 as Comment24,
	@Comment25 as Comment25,
	@Comment26 as Comment26,
	@Comment27 as Comment27,
	@Comment28 as Comment28,
	@Comment29 as Comment29,
	@Comment30 as Comment30,
	@ClassID as ClassID,
	@EK as EK

FOR XML RAW




GO
