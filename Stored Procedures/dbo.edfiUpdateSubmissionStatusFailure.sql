SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Joey Guziejka
-- Create date: 6/17/2021
-- Modified dt: 6/17/2021
-- Description: updates the edfiSubmissionStatus on failure
-- Parameters: jobId
-- =============================================
Create     PROCEDURE [dbo].[edfiUpdateSubmissionStatusFailure]
@jobId uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE EdfiSubmissionStatus
	SET PostEndDateUTC = GETUTCDATE(),
		PostStatus = 'Errors'
	WHERE JobID = @jobId 
	and PostEndDateUTC is null
END
GO
