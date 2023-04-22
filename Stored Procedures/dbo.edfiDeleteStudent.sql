SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Joey
-- Create date: 6/28/2021
-- Modified dt: 10/4/2021
-- Description:	moves an entry from dataSnapshot to dataDeleted
-- Parameters: SchoolYear, StudentUniqueID
-- =============================================
CREATE     Procedure [dbo].[edfiDeleteStudent]
@SchoolYear int,
@StudentUniqueID nvarchar(30)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @AttendanceSnapshotJSON table (studentUniqueID nvarchar(30), attendanceJSON nvarchar(1000));
	Declare @AttendanceDeletedJSON table (studentUniqueID nvarchar(30), attendanceJSON nvarchar(1000));


	Declare @AssociationSnapshotJSON table (studentUniqueID nvarchar(30), ssAssnJSON nvarchar(1000));
	Declare @AssociationDeletedJSON table (studentUniqueID nvarchar(30), ssAssnJSON nvarchar(1000));
	

	Declare @EducationOrgSnapshotJSON table (studentUniqueID nvarchar(30), edOrgJSON nvarchar(1000));
	Declare @EducationOrgDeletedJSON table (studentUniqueID nvarchar(30), edOrgJSON nvarchar(1000));
	

	Declare @StudentParentSnapshotJSON table (studentUniqueID nvarchar(30), spJSON nvarchar(1000));
	Declare @StudentParentDeletedJSON table (studentUniqueID nvarchar(30), spJSON nvarchar(1000));
	

	Declare @StudentProgramSnapshotJSON table (studentUniqueID nvarchar(30), spJSON nvarchar(1000));
	Declare @StudentProgramDeletedJSON table (studentUniqueID nvarchar(30), spJSON nvarchar(1000));
	

	Declare @StudentSnapshotJSON table (studentUniqueID nvarchar(30) PRIMARY KEY, studentJSON nvarchar(4000));
	Declare @StudentDeletedJSON table (studentUniqueID nvarchar(30) PRIMARY KEY, studentJSON nvarchar(4000));


	Declare @AttendancePostID int;
	Declare @AssociationPostID int;
	Declare @EducationOrgPostID int;
	Declare @StudentParentPostID int;
	Declare @StudentProgramPostID int;
	Declare @StudentPostID int;

	-- attendance post id
	Set @AttendancePostID = (Select top 1 PostID 
			From EdfiSubmissionStatus 
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'StudentsSchoolAttendanceEvents'
			and
			dataSnapshot is not null
			order by PostStartDateUTC desc);

	-- association post id
	Set @AssociationPostID = (Select top 1 PostID 
			From EdfiSubmissionStatus 
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'StudentSchoolAssociations'
			and
			dataSnapshot is not null
			order by PostStartDateUTC desc);

	-- ed org post
	Set @EducationOrgPostID = (Select top 1 PostID
			From EdfiSubmissionStatus
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'StudentsEducationOrgAssociations'
			and
			dataSnapshot is not null
			order by PostStartDateUTC desc
	);
	-- student parent
	Set @StudentParentPostID = (Select top 1 PostID
			From EdfiSubmissionStatus
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'StudentParentAssociations'
			and
			dataSnapshot is not null
			order by PostStartDateUTC desc
	);
	-- student program
	Set @StudentProgramPostID = (Select top 1 PostID
			From EdfiSubmissionStatus
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'StudentProgramAssociations'
			and
			dataSnapshot is not null
			order by PostStartDateUTC desc
	);
	-- student post id
	Set @StudentPostID = (Select top 1 PostID 
			From EdfiSubmissionStatus 
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'Students'
			and
			dataSnapshot is not null
			order by PostStartDateUTC desc);

	-- load attendance snapshot
	insert into @AttendanceSnapshotJSON
	Select
	JSON_VALUE(value, '$.studentReference."studentUniqueId"') as studentUniqueID,
	value as attendanceJSON
	From
	OPENJSON(
		(
			Select dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			PostID = @AttendancePostID
		)
	);

	-- load attendance deleted
	insert into @AttendanceDeletedJSON
	Select
	JSON_VALUE(value, '$.studentReference."studentUniqueId"') as studentUniqueID,
	value as attendanceJSON
	From
	OPENJSON(
		(
			Select dataDeleted 
			From EdfiSubmissionStatus 
			Where
			PostID = @AttendancePostID
		)
	)
	UNION
	Select studentUniqueID, attendanceJSON 
	From @AttendanceSnapshotJSON A
	Where
	A.studentUniqueID = @StudentUniqueID;

	-- load association snapshot
	insert into @AssociationSnapshotJSON
	Select
	substring(JSON_VALUE(value, '$.studentReference."studentUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$.studentReference."studentUniqueId"')) +1, 30)  as studentUniqueID,
	value as ssAssnJSON
	From
	OPENJSON(
		(
			Select dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			PostID = @AssociationPostID
		)
	);

	-- load association deleted
	insert into @AssociationDeletedJSON
	Select
	substring(JSON_VALUE(value, '$.studentReference."studentUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$.studentReference."studentUniqueId"')) +1, 30)  as studentUniqueID,
	value as ssAssnJSON
	From
	OPENJSON(
		(
			Select dataDeleted 
			From EdfiSubmissionStatus 
			Where
			PostID = @AssociationPostID
		)
	)
	UNION
	Select studentUniqueID, ssAssnJSON
	From @AssociationSnapshotJSON A
	Where
	A.studentUniqueID = @StudentUniqueID;

	-- load ed-org snapshot
	insert into @EducationOrgSnapshotJSON
	Select
	substring(JSON_VALUE(value, '$.studentReference."studentUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$.studentReference."studentUniqueId"')) +1, 30)  as studentUniqueID,
	value as edOrgJSON
	From
	OPENJSON(
		(
			Select dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			PostID = @EducationOrgPostID
		)
	);

	-- load ed-org deleted
	insert into @EducationOrgDeletedJSON
	Select
	substring(JSON_VALUE(value, '$.studentReference."studentUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$.studentReference."studentUniqueId"')) +1, 30)  as studentUniqueID,
	value as edOrgJson
	From
	OPENJSON(
		(
			Select dataDeleted 
			From EdfiSubmissionStatus 
			Where
			PostID = @EducationOrgPostID
		)
	)
	UNION
	Select studentUniqueID, edOrgJson
	From @EducationOrgSnapshotJSON E
	Where
	E.studentUniqueID = @StudentUniqueID;

	-------------------------------------------------------------

	-- load ed-org snapshot
	insert into @StudentParentSnapshotJSON
	Select
	substring(JSON_VALUE(value, '$.studentReference."studentUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$.studentReference."studentUniqueId"')) +1, 30)  as studentUniqueID,
	value as edOrgJSON
	From
	OPENJSON(
		(
			Select dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			PostID = @EducationOrgPostID
		)
	);

	-- load ed-org deleted
	insert into @EducationOrgDeletedJSON
	Select
	substring(JSON_VALUE(value, '$.studentReference."studentUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$.studentReference."studentUniqueId"')) +1, 30)  as studentUniqueID,
	value as edOrgJson
	From
	OPENJSON(
		(
			Select dataDeleted 
			From EdfiSubmissionStatus 
			Where
			PostID = @EducationOrgPostID
		)
	)
	UNION
	Select studentUniqueID, edOrgJson
	From @EducationOrgSnapshotJSON E
	Where
	E.studentUniqueID = @StudentUniqueID;







	-----------------------------------------------
	-- load student snapshot
	insert into @StudentSnapshotJSON
	Select
	substring(JSON_VALUE(value, '$."studentUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$."studentUniqueId"')) +1, 30)  as studentUniqueID,
	value as studentJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			PostID = @StudentPostID
		)
	);

	-- load student deleted
	insert into @StudentDeletedJSON
	Select
	substring(JSON_VALUE(value, '$."studentUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$."studentUniqueId"')) +1, 30)  as studentUniqueID,
	value as studentJSON
	From
	OPENJSON(
		(
			Select top 1 dataDeleted 
			From EdfiSubmissionStatus 
			Where
			PostID = @StudentPostID
		)
	)
	UNION
	Select studentUniqueID, studentJSON
	From @StudentSnapshotJSON S
	Where
	S.studentUniqueID = @StudentUniqueID;

	-- update attendance resource
	--select * from @AttendanceSnapshotJSON
	--select * from @AttendanceDeletedJSON
	Update EdfiSubmissionStatus
	Set dataDeleted =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + D.attendanceJSON
			From 
			@AttendanceDeletedJSON D
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + S.attendanceJSON
			From 
			@AttendanceSnapshotJSON S
			Where
			S.studentUniqueID <> @StudentUniqueID
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where PostID = @AttendancePostID;

	-- update association resource
	--select * from @AssociationSnapshotJSON
	--select * from @AssociationDeletedJSON
	Update EdfiSubmissionStatus
	Set dataDeleted =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + D.ssAssnJSON
			From 
			@AssociationDeletedJSON D
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + S.ssAssnJSON
			From 
			@AssociationSnapshotJSON S
			Where
			S.studentUniqueID <> @StudentUniqueID
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where PostID = @AssociationPostID;

	-- update student resource
	--select * from @StudentSnapshotJSON
	--select * from @StudentDeletedJSON
	Update EdfiSubmissionStatus
	Set dataDeleted =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + D.studentJSON 
			From 
			@StudentDeletedJSON D
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + S.studentJSON
			From 
			@StudentSnapshotJSON S
			Where
			S.studentUniqueID <> @StudentUniqueID
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where PostID = @StudentPostID;

END

GO
