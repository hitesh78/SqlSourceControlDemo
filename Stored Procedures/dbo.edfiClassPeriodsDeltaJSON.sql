SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--=============================================
-- Author:		Joey G
-- Create date: 10/14/2021
-- Modified dt: 09/20/2022
-- Description:	edfi class periods
-- Rev. Notes:	changed how datasnapshot logic works
-- =============================================
CREATE       PROCEDURE [dbo].[edfiClassPeriodsDeltaJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@JobID Uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	Declare @NewPeriodJSONstr nvarchar(max);
	Declare @NewPeriodJSON table (cpname nvarchar(40) PRIMARY KEY, cpJSON nvarchar(1000));
	Declare @OldPeriodJSON table (cpname nvarchar(40) PRIMARY KEY, cpJSON nvarchar(1000));

	exec edfiClassPeriodsJSON @NewPeriodJSONstr output;

	insert into @NewPeriodJSON
	Select
	JSON_VALUE(value, '$."name"') as cpname,
	value as cpJSON
	From
	OPENJSON(@NewPeriodJSONstr);


	insert into @OldPeriodJSON
	Select
	JSON_VALUE(value, '$."name"') as cpname,
	value as cpJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'ClassPeriods'
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
			SELECT N',' + O.cpJSON 
			From @OldPeriodJSON O
				left join @NewPeriodJSON N
					on N.cpname = O.cpname
			Where N.cpJSON is null  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + NN.cpJSON
			From (			
				SELECT 
					ISNULL(N.cpname, O.cpname) as cpname,
					ISNULL(N.cpJSON, O.cpJSON) as cpJSON
				FROM @OldPeriodJSON O
					FULL OUTER JOIN @NewPeriodJSON N
						on O.cpname = N.cpname
			) NN
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where JobID = @JobID
		and edfiResource = 'ClassPeriods';

	-- clears out the old snapshots is real JobID is passed
	IF EXISTS(
		Select 0
		FROM EdfiSubmissionStatus 
		Where edfiResource = 'ClassPeriods'
			and CalendarYear = @SchoolYear
			and JobID = @JobID)
	BEGIN
		Update EdfiSubmissionStatus
		Set dataDeleted = null,
			dataSnapshot = null
		Where edfiResource = 'ClassPeriods'
			and CalendarYear = @SchoolYear
			and JobID <> @JobID
	END;

	Select
	(
		SELECT '[' + Stuff(
		  (
			SELECT N',' + N.cpJSON 
			From @NewPeriodJSON N
				left join @OldPeriodJSON O
				on N.cpname = O.cpname
			Where N.cpJSON != isnull(O.cpJSON,'')
  
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	) as dataToAddUpdate;

END
GO
