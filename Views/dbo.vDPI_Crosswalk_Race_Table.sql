SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[vDPI_Crosswalk_Race_Table] AS 
	SELECT 
		-- Don't mix null and 0 since report grids handle null nicely...
		CASE 
			WHEN Individual_Race_Key=0
			THEN Null ELSE Individual_Race_Key 
		END AS Individual_Race_Key,
		-- Use binary to match identical sets of races between our race junction table and DPI Crosswalk table
		Hispanic 
			+ Indian_Alaskan*2 
			+ Asian*4 
			+ Black*8 
			+ Pacific*16 
			+ White*32 AS BinaryRacesCode,
		Hispanic,
		Indian_Alaskan,
		Asian,
		Black,
		Pacific,
		White,
		Aggregate_Reporting_Category,
		case when Hispanic=1 then 'Hispanic/Latino;' else '' end
		+ case when Indian_Alaskan=1 then 'American Indian / Native Alaskan;' else '' end
		+ case when Asian=1 then 'Asian;' else '' end
		+ case when Black=1 then 'Black / African American;' else '' end
		+ case when Pacific=1 then 'Native Hawaiian / Other Pacific Islander;' else '' end
		+ case when White=1 then 'White;' else '' end
			as FederalRaceCodes
	FROM (values
		-- hack to support StudentRaces CTE in vDPI_Export_Rev2.sql
		-- where we may have Hispanic entered as a Race in SIS...
		(null,  1,0,0,0,0,0,'H'), 
		-- Table as provided from DPI...
		('0001',1,1,0,0,0,0,'H'),
		('0002',1,0,1,0,0,0,'H'),
		('0003',1,0,0,1,0,0,'H'),
		('0004',1,0,0,0,1,0,'H'),
		('0005',1,0,0,0,0,1,'H'),
		('0006',1,1,1,0,0,0,'H'),
		('0007',1,1,0,1,0,0,'H'),
		('0008',1,1,0,0,1,0,'H'),
		('0009',1,1,0,0,0,1,'H'),
		('0010',1,0,1,1,0,0,'H'),
		('0011',1,0,1,0,1,0,'H'),
		('0012',1,0,1,0,0,1,'H'),
		('0013',1,0,0,1,1,0,'H'),
		('0014',1,0,0,1,0,1,'H'),
		('0015',1,0,0,0,1,1,'H'),
		('0016',1,1,1,1,0,0,'H'),
		('0017',1,1,1,0,1,0,'H'),
		('0018',1,1,1,0,0,1,'H'),
		('0019',1,1,0,1,1,0,'H'),
		('0020',1,1,0,1,0,1,'H'),
		('0021',1,1,0,0,1,1,'H'),
		('0022',1,0,1,1,1,0,'H'),
		('0023',1,0,1,1,0,1,'H'),
		('0024',1,0,1,0,1,1,'H'),
		('0025',1,0,0,1,1,1,'H'),
		('0026',1,1,1,1,1,0,'H'),
		('0027',1,1,1,1,0,1,'H'),
		('0028',1,1,1,0,1,1,'H'),
		('0029',1,1,0,1,1,1,'H'),
		('0030',1,0,1,1,1,1,'H'),
		('0031',1,1,1,1,1,1,'H'),
		('0033',0,1,0,0,0,0,'I'),
		('0034',0,0,1,0,0,0,'A'),
		('0035',0,0,0,1,0,0,'B'),
		('0036',0,0,0,0,1,0,'P'),
		('0037',0,0,0,0,0,1,'W'),
		('0038',0,1,1,0,0,0,'T'),
		('0039',0,1,0,1,0,0,'T'),
		('0040',0,1,0,0,1,0,'T'),
		('0041',0,1,0,0,0,1,'T'),
		('0042',0,0,1,1,0,0,'T'),
		('0043',0,0,1,0,1,0,'T'),
		('0044',0,0,1,0,0,1,'T'),
		('0045',0,0,0,1,1,0,'T'),
		('0046',0,0,0,1,0,1,'T'),
		('0047',0,0,0,0,1,1,'T'),
		('0048',0,1,1,1,0,0,'T'),
		('0049',0,1,1,0,1,0,'T'),
		('0050',0,1,1,0,0,1,'T'),
		('0051',0,1,0,1,1,0,'T'),
		('0052',0,1,0,1,0,1,'T'),
		('0053',0,1,0,0,1,1,'T'),
		('0054',0,0,1,1,1,0,'T'),
		('0055',0,0,1,1,0,1,'T'),
		('0056',0,0,1,0,1,1,'T'),
		('0057',0,0,0,1,1,1,'T'),
		('0058',0,1,1,1,1,0,'T'),
		('0059',0,1,1,1,0,1,'T'),
		('0060',0,1,1,0,1,1,'T'),
		('0061',0,1,0,1,1,1,'T'),
		('0062',0,0,1,1,1,1,'T'),
		('0063',0,1,1,1,1,1,'T')) 
	as Crosswalk_Data (
		Individual_Race_Key,
		Hispanic,
		Indian_Alaskan,
		Asian,
		Black,
		Pacific,
		White,
		Aggregate_Reporting_Category)
GO
