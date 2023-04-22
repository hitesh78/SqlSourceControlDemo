SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   VIEW [dbo].[vSelectOptions]
AS
/*
Modified 1/4/2022 ~JG
*/
with Sett as (
  select 
    case 
		when AdminDefaultLanguage = 'English' or InternationalSchool = 0 
		then 1 
		else 0 
	end as [isDomestic],
	SchoolType,
	cast(ISNULL((
		    Select 
			    SS.[Enabled] 
		    From [LKG].dbo.glServices S
			    left join [LKG].dbo.glSchoolServices SS
				    on S.ServiceID = SS.ServiceID
		    Where S.ServiceID = 31 and SchoolID = Settings.SchoolID
	    ), 0) as bit) as [edfiEnabled]
  from Settings 
)
SELECT 
  x.SelectListID,
  max(x.SelectOptionID) SelectOptionID,
  x.Title,
  max(x.Code) Code,
  max(x.SortOrder) SortOrder
from (
	SELECT
		SelectListID, 
		SelectOptionID, 
		Title, 
		Code,
		case 
			when SelectListID=2 
			then CAST(CHARINDEX(Title,N'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')+1000 as VARCHAR(4)) 
			ELSE Title 
		END AS SortOrder
	FROM SelectOptions
	WHERE CASE 
			WHEN (select edfiEnabled from Sett) = 1 and (select SchoolType from Sett) = 'PublicSchool' and SelectListID in (11, 12) then 0
			ELSE 1
		END = 1
/* BL => Override SelectListID 11 and 12 when edfi us enabled and they are a Public School */
UNION
(
	SELECT 
		DISTINCT 11 AS SelectListID, 
		IncidentTypeID + 8000 AS SelectOptionID, 
		CodeValue AS Title, 
		null as Code, 
		CodeValue AS SortOrder
	FROM LKG.dbo.EdFiIncidentTypes
	WHERE (select edfiEnabled from Sett) = 1 
		and (select SchoolType from Sett) = 'PublicSchool'
)
UNION
(
	select 
		12 as SelectListID,
		SelectOptionID,
		Title,
		null as Code,
		Title as SortOrder
	from (
		select
			9001 as SelectOptionID,
			'In-School Suspension' as Title
		union
		select
			9002 as SelectOptionID,
			'Out-of-School Suspension' as Title
		union
		select
			9003 as SelectOptionID,
			'Expulsion' as Title
		union
		select
			9004 as SelectOptionID,
			'Arrest, Bullying, or Gang-Related Activity' as Title
	) a
	where (select edfiEnabled from Sett) = 1 
		and (select SchoolType from Sett) = 'PublicSchool'
)
UNION
(SELECT     13 AS SelectListID, TeacherID AS SelectOptionID, 
			glName AS Title, null as Code, glName AS SortOrder
 FROM         Teachers
 WHERE     (AccountID <> N'glinit') AND (AccountID <> N'gladmin') AND (Active = 1) AND
                            (SELECT     count(*)
                              FROM          SelectOptions
                              WHERE      SelectListID = 13) = 0)
UNION
(SELECT     14 AS SelectListID, TeacherID AS SelectOptionID, 
			glName AS Title, null as Code, glName AS SortOrder
 FROM         Teachers
 WHERE     (AccountID <> N'glinit') AND (AccountID <> N'gladmin') AND (Active = 1) AND
                            (SELECT     count(*)
                              FROM          SelectOptions
                              WHERE      SelectListID = 14) = 0)
UNION
(SELECT DISTINCT 1 AS SelectListID, 0 AS SelectOptionID, Location, null as Code, upper(location) AS SortOrder
 FROM         Discipline
 WHERE     (SELECT     count(*)
                        FROM          SelectOptions
                        WHERE      SelectListID = 1) = 0)
UNION
(SELECT DISTINCT 3 AS SelectListID, 0 AS SelectOptionID, Title, null as Code, upper(Title) AS SortOrder
 FROM         StudentContacts
 WHERE     (SELECT     count(*)
                        FROM          SelectOptions
                        WHERE      SelectListID = 3) = 0)
UNION
(SELECT DISTINCT 4 AS SelectListID, 0 AS SelectOptionID, Suffix, null as Code, upper(Suffix) AS SortOrder
 FROM         StudentContacts
 WHERE     (SELECT     count(*)
                        FROM          SelectOptions
                        WHERE      SelectListID = 4) = 0)
UNION
(SELECT DISTINCT 5 AS SelectListID, 0 AS SelectOptionID, Relationship, null as Code, upper(Relationship) AS SortOrder
 FROM         StudentContacts
 WHERE     (SELECT     count(*)
                        FROM          SelectOptions
                        WHERE      SelectListID = 5) = 0)
UNION
(SELECT DISTINCT 16 AS SelectListID, 0 AS SelectOptionID, Immunization, null as Code, upper(Immunization) AS SortOrder
 FROM         Immunizations
 WHERE     (SELECT     count(*)
                        FROM          SelectOptions
                        WHERE      SelectListID = 16) = 0) 

UNION
(SELECT DISTINCT 20 AS SelectListID, 0 AS SelectOptionID, Ethnicity, null as Code, upper(Ethnicity) AS SortOrder
 FROM         Students  )                       

UNION 
	SELECT 
		lists.SelectListID,
		opts.SelectOptionID + 1000000,
		case when opts.SelectListID in (
			22, -- US States,
			42, -- EM page/field descriptor,
			56  -- Countries 
			) then opts.Title  -- I18n: don't translate these yet...
		else dbo.T(0,opts.Title) end  COLLATE DATABASE_DEFAULT as Title, 
			opts.Code COLLATE DATABASE_DEFAULT,
		case when opts.SelectListID=2 
			then CAST(CHARINDEX(opts.Title,N'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')+1000 as NVARCHAR(4)) 
			ELSE opts.Title END COLLATE DATABASE_DEFAULT AS SortOrder 
	FROM LKG.dbo.SelectOptions opts
	INNER JOIN LKG.dbo.SelectLists lists 
	ON lists.SelectListID = opts.SelectListID
	WHERE 
    -- Make school entries and LKG US States additive lists 
    -- for domestic schools (English admin lang & not international)
    (opts.SelectListID = 22 and (select isDomestic from Sett)=1)
    or
    -- Default to any LKG entries if no local, school entries...
		opts.SelectListID not in (SELECT DISTINCT SelectListID from SelectOptions)

) x 
where x.Title is not null
group by SelectListID, Title 
--order by SelectListID 

GO
