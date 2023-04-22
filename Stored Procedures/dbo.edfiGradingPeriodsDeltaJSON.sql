SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--=============================================
-- Author:		Joey 
-- Create date: 6/14/2021
-- Modified   : 6/14/2021 
-- Description:	This returns all of edfi grading periods JSON - This was initially done for Indiana 
-- Parameters: None
-- =============================================
CREATE      PROCEDURE [dbo].[edfiGradingPeriodsDeltaJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@JobID Uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;


	Declare @NewEventsJSONstr nvarchar(max);

	exec edfiGradingPeriodsJSON @SchoolYear, @CalendarStartDate, @CalendarEndDate, @NewEventsJSONstr output;

	Update EdfiSubmissionStatus
	Set
	dataSnapshot = @NewEventsJSONstr
	Where
	JobID = @JobID
	and
	edfiResource = 'GradingPeriods';


	Select @NewEventsJSONstr as dataToAddUpdate;

END
GO
