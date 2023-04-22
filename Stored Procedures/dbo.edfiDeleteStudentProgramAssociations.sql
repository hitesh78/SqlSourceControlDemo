SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Joey
-- Create date: 03/29/2023
-- Modified dt: 03/31/2023
-- Description:	moves a student program assc from dataSnapshot to dataDeleted
-- Rev. Notes:	added ability to also do SpecialEdResource
-- =============================================
CREATE   Procedure [dbo].[edfiDeleteStudentProgramAssociations]
@SchoolYear int,
@StudentUniqueId nvarchar(100),
@ProgramName nvarchar(100),
@BeginDate nvarchar(100),
@EdfiResource nvarchar(100)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @SnapshotJSON table (studentProgramKey nvarchar(200) PRIMARY KEY, cpJSON nvarchar(4000));
	Declare @DeletedJSON table (studentProgramKey nvarchar(200) PRIMARY KEY, cpJSON nvarchar(4000));

	Declare @PostID int = (
		Select top 1 PostID 
		From EdfiSubmissionStatus 
		Where CalendarYear = @SchoolYear
			and edfiResource = @EdfiResource
			and dataSnapshot is not null
		order by PostStartDateUTC desc
	);

	Declare @deleteProgramKey nvarchar(100) = @StudentUniqueId + ':' + @ProgramName + ':' + @BeginDate;

	-- load snapshot
	insert into @SnapshotJSON
	Select
	JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + JSON_VALUE(value, '$.programReference."name"') + ':' + JSON_VALUE(value, '$."beginDate"')	as studentProgramKey,
	value as cpJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where PostID = @PostID
		)
	);

	-- load deleted
	insert into @DeletedJSON
	Select
	JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + JSON_VALUE(value, '$.programReference."name"') + ':' + JSON_VALUE(value, '$."beginDate"')	as studentProgramKey,
	value as cpJSON
	From
	OPENJSON(
		(
			Select top 1 dataDeleted 
			From EdfiSubmissionStatus 
			Where PostID = @PostID
		)
	)
	UNION
	Select studentProgramKey, cpJSON
	From @SnapshotJSON S
	Where S.studentProgramKey = @deleteProgramKey;

	-- update session resource
	Update EdfiSubmissionStatus
	Set dataDeleted =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + D.cpJSON
			From @DeletedJSON D
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + O.cpJSON
			From @SnapshotJSON O
			Where O.studentProgramKey <> @deleteProgramKey
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where PostID = @PostID;

END

GO
