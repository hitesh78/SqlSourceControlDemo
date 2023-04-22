SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Joey
-- Create date: 09/28/2022
-- Modified dt: 03/10/2023
-- Description:	moves an entry from dataSnapshot to dataDeleted
-- Rev. Notes:  adds term to key, and adds param
-- =============================================
CREATE     Procedure [dbo].[edfiDeleteStudentAttendance]
@SchoolYear int,
@StudentUniqueId nvarchar(100),
@Date nvarchar(20),
@Category nvarchar(100),
@Term nvarchar(100)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @SnapshotJSON table (theKey nvarchar(150) PRIMARY KEY, theJSON nvarchar(1000));
	Declare @DeletedJSON table (theDate nvarchar(150) PRIMARY KEY, theJSON nvarchar(1000));

	Declare @theDeleteKey nvarchar(200) = @StudentUniqueId + ':' + @Date + ':' + @Category + ':' + @Term;
	Declare @PostID int;

	set @PostID = (
		Select top 1 PostID 
		From EdfiSubmissionStatus 
		Where CalendarYear = @SchoolYear
			and edfiResource = 'StudentsSchoolAttendanceEvents'
			and dataSnapshot is not null
		order by PostStartDateUTC desc);

	insert into @SnapshotJSON
	Select distinct
	JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + JSON_VALUE(value, '$."eventDate"') + ':' +
	substring(JSON_VALUE(value, '$."attendanceEventCategoryDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$."attendanceEventCategoryDescriptor"')) + 5, 100) + ':' + 
	substring(JSON_VALUE(value, '$.sessionReference."termDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$.sessionReference."termDescriptor"')) + 5, 100) as theKey,
	value as theJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where PostID = @PostID
		)
	);

	insert into @DeletedJSON
	Select distinct
	JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + JSON_VALUE(value, '$."eventDate"') + ':' +
	substring(JSON_VALUE(value, '$."attendanceEventCategoryDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$."attendanceEventCategoryDescriptor"')) + 5, 100) + ':' + 
	substring(JSON_VALUE(value, '$.sessionReference."termDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$.sessionReference."termDescriptor"')) + 5, 100) as theKey,
	value as theJSON
	From
	OPENJSON(
		(
			Select top 1 dataDeleted 
			From EdfiSubmissionStatus 
			Where
			PostID = @PostID
		)
	)
	UNION
	Select theKey, theJSON
	From @SnapshotJSON S
	Where S.theKey = @theDeleteKey

	Update EdfiSubmissionStatus
	Set dataDeleted =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + D.theJSON 
			From @DeletedJSON D
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + O.theJSON 
			From @SnapshotJSON O
			Where O.theKey <> @theDeleteKey
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where PostID = @PostID;

END

GO
