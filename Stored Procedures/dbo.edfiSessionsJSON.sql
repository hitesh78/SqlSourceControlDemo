SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Don Puls
-- Create date: 5/06/2021
-- Modified dt: 8/10/2021
-- Description:	Takes three parameters and returns the edfi Sessions JSON - This was initially done for Indiana 
--				This returns an array of JSON Session values to send to the DOE Data Exchange		
-- Parameters: Calendar Year, Calendar Year Start Date, Calendar Year End Date
-- =============================================
CREATE         PROCEDURE [dbo].[edfiSessionsJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@SessionsJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	Declare @SchoolID nvarchar(50) = (SELECT EdFiDOESchoolID FROM IntegrationSettings Where ID = 1);

	Set @SessionsJSON = (
		Select
		@SchoolID as [schoolReference.schoolId],
		@SchoolYear as [schoolYearTypeReference.schoolYear],
		convert(date, Min(T.StartDate)) as beginDate,
		convert(date, Max(T.EndDate)) as endDate,
		convert(nvarchar(4), @SchoolYear) + ' ' + E.[Sessions] as [name],
		'http://doe.in.gov/Descriptor/TermDescriptor.xml/' + E.[Sessions] as termDescriptor,
		dbo.getEdFiTotalInstructionalDayCount(Min(T.StartDate), Max(T.EndDate)) as totalInstructionalDays,
		(
			Select
			convert(date, Min(T2.StartDate)) as [gradingPeriodReference.beginDate],
			convert(date, Max(T2.EndDate)) as [gradingPeriodReference.endDate],
			'http://doe.in.gov/Descriptor/GradingPeriodDescriptor.xml/' + E2.EdfiPeriodDesc as [gradingPeriodReference.descriptor],
			dbo.getEdFiTotalInstructionalDayCount(Min(T2.StartDate), Max(T2.EndDate)) as [gradingPeriodReference.totalInstructionalDays]
			From 
			Terms T2
				inner join
			EdfiPeriods E2
				on T2.EdfiPeriodID = E2.EdfiPeriodID
			Where
			T2.ExamTerm = 0        -- exclude exam terms
			and
			T2.TermID not in (Select ParentTermID From Terms)
			and
			T2.StartDate >= Min(T.StartDate)
			and
			T2.EndDate <= Max(T.EndDate)
			and
			E2.[Sessions] = E.[Sessions]
			Group By E2.EdfiPeriodDesc
			Order By convert(date, Min(T2.StartDate)), convert(date, Max(T2.EndDate))
		FOR JSON PATH
		) as gradingPeriods
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
		Group By E.Sessions
		Order By convert(date, Min(T.StartDate)), convert(date, Max(T.EndDate))
		FOR JSON PATH
	);

END
GO
