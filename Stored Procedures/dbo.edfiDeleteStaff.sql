SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Joey
-- Create date: 01/10/2022
-- Modified dt: 01/18/2022
-- Description:	moves entries from dataSnapshot to dataDeleted
-- Parameters: SchoolYear, staffUniqueID
-- =============================================
CREATE     Procedure [dbo].[edfiDeleteStaff]
@SchoolYear int,
@StaffUniqueID nvarchar(30)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @SectionSnapshotJSON table (staffUniqueID nvarchar(30), aJSON nvarchar(1000));
	Declare @SectionDeletedJSON table (staffUniqueID nvarchar(30), aJSON nvarchar(1000));

	Declare @AssignmentSnapshotJSON table (staffUniqueID nvarchar(30), aJSON nvarchar(1000));
	Declare @AssignmentsDeletedJSON table (staffUniqueID nvarchar(30), aJSON nvarchar(1000));

	Declare @ContactsSnapshotJSON table (staffUniqueID nvarchar(30), cJSON nvarchar(1000));
	Declare @ContactsDeletedJSON table (staffUniqueID nvarchar(30), cJSON nvarchar(1000));
	
	Declare @EmploymentSnapshotJSON table (staffUniqueID nvarchar(30), eJSON nvarchar(1000));
	Declare @EmploymentDeletedJSON table (staffUniqueID nvarchar(30), eJSON nvarchar(1000));
	
	Declare @StaffSnapshotJSON table (staffUniqueID nvarchar(30) PRIMARY KEY, sJSON nvarchar(4000));
	Declare @StaffDeletedJSON table (staffUniqueID nvarchar(30) PRIMARY KEY, sJSON nvarchar(4000));

	Declare @SectionPostID int;
	Declare @AssignmentPostID int;
	Declare @ContactsPostID int;
	Declare @EmploymentPostID int;
	Declare @StaffPostID int;

	-- section post id
	Set @SectionPostID = (
		Select top 1 PostID 
		From EdfiSubmissionStatus 
		Where CalendarYear = @SchoolYear
			and edfiResource = 'StaffSectionAssociations'
			and dataSnapshot is not null
		order by PostStartDateUTC desc
	);
	-- assignment post id
	Set @AssignmentPostID = (
		Select top 1 PostID 
		From EdfiSubmissionStatus 
		Where CalendarYear = @SchoolYear
			and edfiResource = 'StaffEducationOrganizationAssignmentAssociations'
			and dataSnapshot is not null
		order by PostStartDateUTC desc
	);
	-- contact post id
	Set @ContactsPostID = (
		Select top 1 PostID 
		From EdfiSubmissionStatus 
		Where CalendarYear = @SchoolYear
			and edfiResource = 'StaffEducationOrganizationContactAssociations'
			and dataSnapshot is not null
		order by PostStartDateUTC desc
	);
	-- emp post id
	Set @EmploymentPostID = (
		Select top 1 PostID
		From EdfiSubmissionStatus
		Where CalendarYear = @SchoolYear
			and edfiResource = 'StaffEducationOrganizationEmploymentAssociations'
			and dataSnapshot is not null
		order by PostStartDateUTC desc
	);
	-- staff post id
	Set @StaffPostID = (
		Select top 1 PostID
		From EdfiSubmissionStatus
		Where CalendarYear = @SchoolYear
			and edfiResource = 'Staffs'
			and dataSnapshot is not null
		order by PostStartDateUTC desc
	);

	-- load section snapshot
	insert into @SectionSnapshotJSON
	Select
	JSON_VALUE(value, '$.staffReference."staffUniqueId"') as staffUniqueID,
	value as aJSON
	From
	OPENJSON(
		(
			Select dataSnapshot 
			From EdfiSubmissionStatus 
			Where PostID = @SectionPostID
		)
	);

	-- load section deleted
	insert into @SectionDeletedJSON
	Select
	JSON_VALUE(value, '$.staffReference."staffUniqueId"') as staffUniqueID,
	value as aJSON
	From
	OPENJSON(
		(
			Select dataDeleted 
			From EdfiSubmissionStatus 
			Where PostID = @SectionPostID
		)
	)
	UNION
	Select staffUniqueID, aJSON 
	From @SectionSnapshotJSON A
	Where A.staffUniqueID = @staffUniqueID;

	-- load assignment snapshot
	insert into @AssignmentSnapshotJSON
	Select
	JSON_VALUE(value, '$.staffReference."staffUniqueId"') as staffUniqueID,
	value as aJSON
	From
	OPENJSON(
		(
			Select dataSnapshot 
			From EdfiSubmissionStatus 
			Where PostID = @AssignmentPostID
		)
	);

	-- load assignment deleted
	insert into @AssignmentsDeletedJSON
	Select
	JSON_VALUE(value, '$.staffReference."staffUniqueId"') as staffUniqueID,
	value as aJSON
	From
	OPENJSON(
		(
			Select dataDeleted 
			From EdfiSubmissionStatus 
			Where PostID = @AssignmentPostID
		)
	)
	UNION
	Select staffUniqueID, aJSON 
	From @AssignmentSnapshotJSON A
	Where A.staffUniqueID = @staffUniqueID;

	-- load contact snapshot
	insert into @ContactsSnapshotJSON
	Select
	JSON_VALUE(value, '$.staffReference."staffUniqueId"') as staffUniqueID,
	value as cJSON
	From
	OPENJSON(
		(
			Select dataSnapshot 
			From EdfiSubmissionStatus 
			Where PostID = @ContactsPostID
		)
	);

	-- load contact deleted
	insert into @ContactsDeletedJSON
	Select
	JSON_VALUE(value, '$.staffReference."staffUniqueId"') as staffUniqueID,
	value as cJSON
	From
	OPENJSON(
		(
			Select dataDeleted 
			From EdfiSubmissionStatus 
			Where PostID = @ContactsPostID
		)
	)
	UNION
	Select staffUniqueID, cJSON
	From @ContactsSnapshotJSON A
	Where A.staffUniqueID = @staffUniqueID;

	-- load emp snapshot
	insert into @EmploymentSnapshotJSON
	Select
	JSON_VALUE(value, '$.staffReference."staffUniqueId"') as staffUniqueID,
	value as eJSON
	From
	OPENJSON(
		(
			Select dataSnapshot 
			From EdfiSubmissionStatus 
			Where PostID = @EmploymentPostID
		)
	);

	-- load emp deleted
	insert into @EmploymentDeletedJSON
	Select
	JSON_VALUE(value, '$.staffReference."staffUniqueId"') as staffUniqueID,
	value as eJSON
	From
	OPENJSON(
		(
			Select dataDeleted 
			From EdfiSubmissionStatus 
			Where PostID = @EmploymentPostID
		)
	)
	UNION
	Select staffUniqueID, eJSON
	From @EmploymentSnapshotJSON E
	Where E.staffUniqueID = @staffUniqueID;

	-- load staff snapshot
	insert into @StaffSnapshotJSON
	Select
	JSON_VALUE(value, '$."staffUniqueId"') as staffUniqueID,
	value as sJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where PostID = @StaffPostID
		)
	);

	-- load staff deleted
	insert into @StaffDeletedJSON
	Select
	JSON_VALUE(value, '$."staffUniqueId"') as staffUniqueID,
	value as sJSON
	From
	OPENJSON(
		(
			Select top 1 dataDeleted 
			From EdfiSubmissionStatus 
			Where PostID = @StaffPostID
		)
	)
	UNION
	Select staffUniqueID, sJSON
	From @StaffSnapshotJSON S
	Where S.staffUniqueID = @staffUniqueID;

	-- update section resource
	Update EdfiSubmissionStatus
	Set dataDeleted =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + D.aJSON
			From @SectionDeletedJSON D
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + S.aJSON
			From @SectionSnapshotJSON S
			Where S.staffUniqueID <> @staffUniqueID
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where PostID = @SectionPostID;

	-- update assignment resource
	Update EdfiSubmissionStatus
	Set dataDeleted =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + D.aJSON
			From @AssignmentsDeletedJSON D
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + S.aJSON
			From @AssignmentSnapshotJSON S
			Where S.staffUniqueID <> @staffUniqueID
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where PostID = @AssignmentPostID;

	-- update assignment resource
	Update EdfiSubmissionStatus
	Set dataDeleted =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + D.aJSON
			From @AssignmentsDeletedJSON D
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + S.aJSON
			From @AssignmentSnapshotJSON S
			Where S.staffUniqueID <> @staffUniqueID
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where PostID = @AssignmentPostID;

	-- update contact resource
	Update EdfiSubmissionStatus
	Set dataDeleted =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + D.cJSON
			From @ContactsDeletedJSON D
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + S.cJSON
			From @ContactsSnapshotJSON S
			Where S.staffUniqueID <> @staffUniqueID
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where PostID = @ContactsPostID;

	-- update emp resource
	Update EdfiSubmissionStatus
	Set dataDeleted =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + D.eJSON
			From @EmploymentDeletedJSON D
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + S.eJSON
			From @EmploymentSnapshotJSON S
			Where S.staffUniqueID <> @staffUniqueID
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where PostID = @EmploymentPostID;

	-- update staff resource
	Update EdfiSubmissionStatus
	Set dataDeleted =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + D.sJSON 
			From @StaffDeletedJSON D
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + S.sJSON
			From @StaffSnapshotJSON S
			Where S.staffUniqueID <> @staffUniqueID
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where PostID = @StaffPostID;

END

GO
