SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Joey Guziejka
-- Create date: 06/28/2021 
-- Modified dt: 06/28/2021
-- Description: updates the snapshot on resync missing process
-- Parameters: edfiResource, year, json
-- =============================================
CREATE   PROCEDURE [dbo].[edfiUpdateSnapshotOnResyncMissing]
@edfiResource nvarchar(100),
@year int,
@json nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PostID int;
	DECLARE @dataSnapshot nvarchar(max);
	Declare @NewSnapshot table (theJSON nvarchar(4000));
	
	SELECT TOP 1 
		@PostID = PostID,
		@dataSnapshot = dataSnapshot
	FROM EdfiSubmissionStatus es
	WHERE CalendarYear = @year
		and edfiResource = @edfiResource
		and dataSnapshot is not null
	ORDER BY PostStartDateUTC DESC;

	INSERT INTO @NewSnapshot
	SELECT value as theJSON
	FROM OPENJSON(@dataSnapshot)
	UNION
	SELECT value as theJson
	FROM OPENJSON(@json);

	UPDATE EdfiSubmissionStatus
	SET dataSnapshot = (
		SELECT '[' + Stuff(
		(
			SELECT N',' + N.theJSON 
			From @NewSnapshot N
			FOR XML PATH(''),TYPE).value('text()[1]','nvarchar(max)'),1,1,N''
		) + ']')
	WHERE PostID = @PostID;

END
GO
