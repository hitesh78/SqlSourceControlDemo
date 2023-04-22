SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


-- =============================================
-- Author:		Joey
-- Create date: 10/12/2021
-- Modified dt: 04/08/2022 
-- Description:	Returns start and end dates for a school year 
-- =============================================
CREATE   FUNCTION [dbo].[fnGetStartEndDatesByYear]
(
	@Year int
)
RETURNS 
@Dates TABLE
(
	[Year] int,
	StartDate nvarchar(12),
	EndDate nvarchar(12),
	LastYearEndDate nvarchar(12),
	SystemStartDate nvarchar(12),
	SystemEndDate nvarchar(12)
)
AS
BEGIN

	Declare @SchoolStartMonth int;
	Declare @SchoolEndMonth int;
	Declare @SystemStartDate nvarchar(12);
	Declare @SystemEndDate nvarchar(12);
	Declare @LastYearEndDate nvarchar(12);

	Select
		@SchoolStartMonth = SchoolStartMonth,
		@SchoolEndMonth = SchoolEndMonth
	From Settings where SettingID = 1;

	Select
		@SystemStartDate = 
			case 
				when @SchoolStartMonth > @SchoolEndMonth 
				then CAST(@Year - 1 as char(4)) + '-' + right('0' + convert(varchar(2), @SchoolStartMonth), 2) + '-01'
				else CAST(@Year as char(4)) + '-' + right('0' + convert(varchar(2), @SchoolStartMonth), 2) + '-01'
			end,
		@SystemEndDate = CAST(eomonth(CAST(@Year as char(4)) + '-' + right('0' + convert(nvarchar(2), @SchoolEndMonth), 2) + '-01') as nvarchar(12));

	Select 
		@LastYearEndDate = cast(convert(date, Max(EndDate)) as nvarchar(12))
    From Terms
    Where TermID not in (Select ParentTermID From Terms) -- exclude terms that have child terms
        and ExamTerm = 0 -- exclude exam terms "
		and TermTitle not like '%Sum%'
		and StartDate < @SystemStartDate
		and EndDate < @SystemStartDate;

	Insert into @Dates
    Select
		@Year as [Year],
		cast(convert(date, Min(StartDate)) as nvarchar(12)) as [StartDate],
        cast(convert(date, Max(EndDate)) as nvarchar(12)) as [EndDate],
		isnull(@LastYearEndDate, cast(convert(date, DATEADD(year, -1, @SystemEndDate)) as nvarchar(12))) as [LastYearEndDate],
		@SystemStartDate as [SystemStartDate],
		@SystemEndDate as [SystemEndDate]
    From Terms
    Where TermID not in (Select ParentTermID From Terms) -- exclude terms that have child terms
        and ExamTerm = 0 -- exclude exam terms "
		and TermTitle not like '%Sum%'
		and StartDate >= @SystemStartDate
		and EndDate < @SystemEndDate;

	RETURN

END
GO
