SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--=============================================
--Author:		Don Puls
-- Create date: 5/26/2021
-- Modified   : 5/27/2021 
-- Description:	This returns the edfi Students JSON - This was initially done for Indiana 
-- Parameters: None
-- =============================================
CREATE      PROCEDURE [dbo].[edfiSessionsDeltaJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@JobID Uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;


	Declare @NewEventsJSONstr nvarchar(max);

	exec edfiSessionsJSON @SchoolYear, @CalendarStartDate, @CalendarEndDate, @NewEventsJSONstr output;


	Update EdfiSubmissionStatus
	Set
	dataSnapshot = @NewEventsJSONstr
	Where
	JobID = @JobID
	and
	edfiResource = 'Sessions';


	Select @NewEventsJSONstr as dataToAddUpdate;


END
GO
