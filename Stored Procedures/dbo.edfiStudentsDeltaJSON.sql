SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--=============================================
-- Author:		Don Puls/Joey
-- Create date: 5/26/2021
-- Modified dt: 9/27/2022 
-- Description:	This returns the edfi Students JSON
-- Rev. Notes:	changed how datasnapshot logic works
-- =============================================
CREATE     PROCEDURE [dbo].[edfiStudentsDeltaJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@JobID Uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;


	Declare @NewStudentJSONstr nvarchar(max);
	Declare @NewStudentJSON table (studentUniqueID nvarchar(20) PRIMARY KEY, studentJSON nvarchar(4000));
	Declare @OldStudentJSON table (studentUniqueID nvarchar(20) PRIMARY KEY, studentJSON nvarchar(4000));

	exec edfiStudentsJSON @SchoolYear, @CalendarStartDate, @CalendarEndDate, @NewStudentJSONstr output;

	insert into @NewStudentJSON
	Select
	substring(JSON_VALUE(value, '$."studentUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$."studentUniqueId"')) +1, 30)  as studentUniqueID,
	value as studentJSON
	From
	OPENJSON(@NewStudentJSONstr);


	insert into @OldStudentJSON
	Select
	substring(JSON_VALUE(value, '$."studentUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$."studentUniqueId"')) +1, 30)  as studentUniqueID,
	value as studentJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'Students'
			and
			dataSnapshot is not null
			order by PostStartDateUTC desc
		)
	);

	Update EdfiSubmissionStatus
	Set
	dataDeleted =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + O.studentJSON 
			From 
			@OldStudentJSON O
				left join
			@NewStudentJSON N
				on N.studentUniqueID = O.studentUniqueID
			Where
			N.studentJSON is null
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
		  (
			SELECT N',' + NN.studentJSON 
			From (
				select 
					ISNULL(N.studentUniqueId, O.studentUniqueId) as studentUniqueId,
					ISNULL(N.studentJSON, O.studentJSON) as studentJSON
				from @OldStudentJSON O
					FULL OUTER JOIN @NewStudentJSON N
						on O.studentUniqueId = N.studentUniqueId
			) NN
  
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where
	JobID = @JobID
	and
	edfiResource = 'Students';
	
	-- clears out the old snapshots if real JobID is passed
	IF EXISTS(
		Select 0
		FROM EdfiSubmissionStatus 
		Where edfiResource = 'Students'
			and CalendarYear = @SchoolYear
			and JobID = @JobID)
	BEGIN
		Update EdfiSubmissionStatus
		Set dataDeleted = null,
			dataSnapshot = null
		Where edfiResource = 'Students'
			and CalendarYear = @SchoolYear
			and JobID <> @JobID
	END;

	Select
	(
		SELECT '[' + Stuff(
		  (
			SELECT N',' + N.studentJSON 
			From 
			@NewStudentJSON N
				left join
			@OldStudentJSON O
				on N.studentUniqueID = O.studentUniqueID
			Where
			N.studentJSON != isnull(O.studentJSON,'')
  
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	) as dataToAddUpdate;

END
GO
