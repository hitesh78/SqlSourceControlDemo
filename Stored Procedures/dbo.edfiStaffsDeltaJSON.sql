SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--=============================================
-- Author:		Joey
-- Create date: 7/15/2021
-- Modified dt: 9/27/2022 
-- Description:	This returns the edfi Staffs JSON - This was initially done for Indiana 
-- Rev. Notes:	changed how datasnapshot logic works
-- =============================================
CREATE      PROCEDURE [dbo].[edfiStaffsDeltaJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@JobID Uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	Declare @NewStaffJSONstr nvarchar(max);
	Declare @NewStaffJSON table (staffUniqueId nvarchar(30) PRIMARY KEY, staffJSON nvarchar(4000));
	Declare @OldStaffJSON table (staffUniqueId nvarchar(30) PRIMARY KEY, staffJSON nvarchar(4000));

	exec edfiStaffsJSON @NewStaffJSONstr output;

	insert into @NewStaffJSON
	Select
	JSON_VALUE(value, '$."staffUniqueId"'),
	value as staffJSON
	From
	OPENJSON(@NewStaffJSONstr);


	insert into @OldStaffJSON
	Select
	JSON_VALUE(value, '$."staffUniqueId"'),
	value as staffJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'Staffs'
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
			SELECT N',' + O.staffJSON 
			From 
			@OldStaffJSON O
				left join
			@NewStaffJSON N
				on N.staffUniqueId = O.staffUniqueId
			Where
			N.staffJSON is null
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
		  (
			SELECT N',' + NN.staffJSON 
			From (
				select 
					ISNULL(N.staffUniqueId, O.staffUniqueId) as staffUniqueId,
					ISNULL(N.staffJSON, O.staffJSON) as staffJSON
				from @OldStaffJSON O 
					FULL OUTER JOIN @NewStaffJSON N
						on O.staffUniqueId = N.staffUniqueId
			) NN
  
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where
	JobID = @JobID
	and
	edfiResource = 'Staffs';

	-- clears out the old snapshots if real JobID is passed
	IF EXISTS(
		Select 0
		FROM EdfiSubmissionStatus 
		Where edfiResource = 'Staffs'
			and CalendarYear = @SchoolYear
			and JobID = @JobID)
	BEGIN
		Update EdfiSubmissionStatus
		Set dataDeleted = null,
			dataSnapshot = null
		Where edfiResource = 'Staffs'
			and CalendarYear = @SchoolYear
			and JobID <> @JobID
	END;

	Select
	(
		SELECT '[' + Stuff(
		  (
			SELECT N',' + N.staffJSON 
			From 
			@NewStaffJSON N
				left join
			@OldStaffJSON O
				on N.staffUniqueId = O.staffUniqueId
			Where
			N.staffJSON != isnull(O.staffJSON,'')
  
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	) as dataToAddUpdate;


END
GO
