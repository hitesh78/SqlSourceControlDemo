SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Joey Guziejka
-- Create date: 5/20/2021
-- Modified dt: 5/21/2021
-- Description: updates the edfiSubmissionStatus 
-- Parameters: jobId, edfiResource, status, title, request, response
-- =============================================
CREATE     PROCEDURE [dbo].[edfiUpdateSubmissionStatus]
@jobId uniqueidentifier,
@edfiResource nvarchar(100),
@status nvarchar(50),
@title nvarchar(50),
@request nvarchar(max) null,
@results nvarchar(max) null
AS
BEGIN
	SET NOCOUNT ON;

	Declare @PostID int = (Select PostID From EdfiSubmissionStatus Where JobID = @jobId and edfiResource = @edfiResource);

	UPDATE EdfiSubmissionStatus
	SET PostStartDateUTC = IIF(@status = 'InProcess', GETUTCDATE(), PostStartDateUTC),
		PostEndDateUTC = IIF(@status = 'Success' or @status = 'Errors', GETUTCDATE(), null),
		PostStatus = @status,
		ResourceTitle = @title,
		PostRequest = IIF(@request is null, PostRequest, @request),
		PostResults = @results
	WHERE PostID = @PostID

	If @status = 'Errors'
	Begin			-- Update Snapshot removing records that errored in post
		exec edfiUpdateSnapshotDataOnError @PostID, @edfiResource
	End

END
GO
