SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   VIEW [dbo].[vGradeLevelOptions] as

select
	glo.GradeLevelOptionID,
	glo.GradeLevelOption,
	glo.GradeLevel,
	CASE glo.GradeLevel
		WHEN 'PS' THEN '0001'
		WHEN 'PK' THEN '0002'
		WHEN 'K' THEN '0003'
		ELSE RIGHT('000' + cast(convert(int, glo.GradeLevel) * 10 as nvarchar(10)), 4)
    END as GradeLevelSort
from GradeLevelOptions glo;
GO
