SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
/* =============================================
** Author:		Joey Guziejka
** Created:		4/2/2021
** Version:		1
** Description:	Gets the race mapping data for oneroster  
** select * from fnOneRosterRaceDemographics()
** ============================================= */
CREATE   FUNCTION [dbo].[fnOneRosterRaceDemographics] ()
RETURNS TABLE
AS
RETURN
(
	SELECT
		_r.StudentID,
		MAX(CASE
			WHEN _r.race like '%american indian%' or _r.race like '%native american%' or _r.race like '%alaska%'
			THEN 1
			ELSE 0
		END) as [americanIndianOrAlaskaNative],
		MAX(CASE
			WHEN _r.race IN ('asian', 'filipino', 'chinese', 'japanese', 'korean', 'thai')
			THEN 1
			ELSE 0
		END) as [asian],
		MAX(CASE
			WHEN _r.race like '%black%' or _r.race like '%african%'
			THEN 1
			ELSE 0
		END) as [blackOrAfricanAmerican],
		MAX(CASE
			WHEN _r.race like '%hawaiian%' or _r.race like '%pacific island%'
			THEN 1
			ELSE 0
		END) as [nativeHawaiianOrOtherPacificIslander],
		MAX(CASE
			WHEN _r.race IN ('white','caucasian')
			THEN 1
			ELSE 0
		END) as [white],
		MAX(CASE
			WHEN _r.race = 'Two or more races'
			THEN 1
			ELSE 0
		END) as [demographicRaceTwoOrMoreRaces],
		MAX(CASE
			WHEN _r.race like '%hispanic%' or _r.race like '%latino%'
			THEN 1
			ELSE 0
		END) as [hispanicOrLatinoEthnicity],
		count (*) as noop
	FROM (
		SELECT 
			sr.StudentID,
			COALESCE(NULLIF(FederalRaceMapping, ''), [Name]) as race
		FROM Students st
			inner join StudentRace sr
				on st.StudentID = sr.StudentID
			inner join Race ra
				on ra.RaceID = sr.RaceID
		WHERE st.Active = 1
	) _r
	GROUP BY _r.StudentID
)

GO
