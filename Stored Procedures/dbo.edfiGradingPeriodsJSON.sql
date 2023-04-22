SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Don Puls
-- Create date: 5/06/2021
-- Modified dt: 7/01/2021
-- Description:	Takes three parameters and returns the edfi Grading Periods JSON - This was initially done for Indiana 
--				This returns an array of JSON Grading Period values to send to the DOE Data Exchange		
-- Parameters: Calendar Year, Calendar Year Start Date, Calendar Year End Date
-- =============================================
CREATE        PROCEDURE [dbo].[edfiGradingPeriodsJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@GradingPeriodsJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	Declare @SchoolID nvarchar(50) = (SELECT EdFiDOESchoolID FROM IntegrationSettings Where ID = 1);


	set @GradingPeriodsJSON = (
		Select
		@SchoolID as [schoolReference.schoolId],
		@SchoolYear as [schoolYearTypeReference.schoolYear],
		convert(date,Min(T.StartDate)) as beginDate,
		convert(date,Max(T.EndDate)) as endDate,
		'http://doe.in.gov/Descriptor/GradingPeriodDescriptor.xml/' + E.EdfiPeriodDesc as descriptor,
		dbo.getEdFiTotalInstructionalDayCount(Min(T.StartDate), Max(T.EndDate)) as totalInstructionalDays
		From 
		Terms T
			inner join
		EdfiPeriods E
			on T.EdfiPeriodID = E.EdfiPeriodID
		Where
		T.ExamTerm = 0        -- exclude exam terms
		and
		T.TermID not in (Select ParentTermID From Terms)
		and
		T.StartDate >= @CalendarStartDate
		and
		T.EndDate <= @CalendarEndDate
		Group By E.EdfiPeriodDesc
		order by beginDate, endDate
		FOR JSON PATH
	);

END
GO
