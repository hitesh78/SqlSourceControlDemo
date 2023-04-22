SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 5/18/2013
-- Description:	Retuns StudentInfoDiscipline Main List
-- =============================================
CREATE Procedure [dbo].[StudentInfoDisciplineMainList]
@ClassID int,
@EK decimal(15,15),
@StudentID int,
@DateFilter nvarchar(50),
@StudentFilter nvarchar(50),
@IncidentFilter nvarchar(50),
@LocationFilter nvarchar(50),
@ReferredByFilter nvarchar(50),
@ReferredToFilter nvarchar(50),
@ResultFilter nvarchar(50),
@RecordsToDisplay int,
@SelectedDisciplineID int,
@NumDaysOfDisciplineToShow int

AS
BEGIN
	SET NOCOUNT ON;

	
	Declare @TotalIncidents int

	if @StudentID = -1		-- Admin UI
	Begin
		Set @TotalIncidents = 
		(
			Select COUNT(*) 
			From 
			Students S
				inner join
			Discipline D
				on S.StudentID = D.StudentID
			Where
			case
				when ltrim(rtrim(isnull(@DateFilter,''))) = '' then 1
				when len(ltrim(rtrim(@DateFilter))) = 1 and ltrim(rtrim(@DateFilter)) = substring(dbo.GLformatdate(DateOfIncident), 1,1) then 1
				when len(ltrim(rtrim(@DateFilter))) != 1 and dbo.GLformatdate(DateOfIncident) like '%' + ltrim(rtrim(@DateFilter)) + '%' then 1
				else 0
			end = 1
			and
			case
				when ltrim(rtrim(isnull(@StudentFilter,''))) = '' then 1
				when len(ltrim(rtrim(@StudentFilter))) = 1 and ltrim(rtrim(@StudentFilter)) = substring(S.glname, 1,1) then 1
				when len(ltrim(rtrim(@StudentFilter))) != 1 and S.glname like '%' + ltrim(rtrim(@StudentFilter)) + '%' then 1
				else 0
			end = 1
			and
			case
				when ltrim(rtrim(isnull(@IncidentFilter,''))) = '' then 1
				when len(ltrim(rtrim(@IncidentFilter))) = 1 and ltrim(rtrim(@IncidentFilter)) = substring(D.IncidentCodes, 1,1) then 1
				when len(ltrim(rtrim(@IncidentFilter))) != 1 and D.IncidentCodes like '%' + ltrim(rtrim(@IncidentFilter)) + '%' then 1
				else 0
			end = 1
			and
			case
				when ltrim(rtrim(isnull(@LocationFilter,''))) = '' then 1
				when len(ltrim(rtrim(@LocationFilter))) = 1 and ltrim(rtrim(@LocationFilter)) = substring(D.Location, 1,1) then 1
				when len(ltrim(rtrim(@LocationFilter))) != 1 and D.Location like '%' + ltrim(rtrim(@LocationFilter)) + '%' then 1
				else 0
			end = 1
			and
			case
				when ltrim(rtrim(isnull(@ReferredByFilter,''))) = '' then 1
				when len(ltrim(rtrim(@ReferredByFilter))) = 1 and ltrim(rtrim(@ReferredByFilter)) = substring(D.ReferredBy, 1,1) then 1
				when len(ltrim(rtrim(@ReferredByFilter))) != 1 and D.ReferredBy like '%' + ltrim(rtrim(@ReferredByFilter)) + '%' then 1
				else 0
			end = 1
			and
			case
				when ltrim(rtrim(isnull(@ReferredToFilter,''))) = '' then 1
				when len(ltrim(rtrim(@ReferredToFilter))) = 1 and ltrim(rtrim(@ReferredToFilter)) = substring(D.ReferredTo, 1,1) then 1
				when len(ltrim(rtrim(@ReferredToFilter))) != 1 and D.ReferredTo like '%' + ltrim(rtrim(@ReferredToFilter)) + '%' then 1
				else 0
			end = 1
			and	
			case
				when ltrim(rtrim(isnull(@ResultFilter,''))) = '' then 1
				when len(ltrim(rtrim(@ResultFilter))) = 1 and ltrim(rtrim(@ResultFilter)) = substring(
					rtrim(ltrim((
						SELECT SUBSTRING(
						(
						Select ';' + 
						DA.Result
						From
						(
							Select
							table_pk_id,
							(
								SELECT
								isnull(doc.col.value('NumUnits[1]', 'nvarchar(10)') +  ' ','') + -- UnitAmount
								isnull(doc.col.value('Units[1]', 'nvarchar(20)') +  ' ','') + -- Unit
								isnull(doc.col.value('Type[1]', 'nvarchar(50)'),'') as Result
								FROM xml_fields.nodes('.') doc(col) 
							) as Result
							From 
							xml_records X
							Where
							X.entityName like '%DisciplineActionTaken%'
						) DA
						Where
						DA.table_pk_id = D.DisciplineID
						FOR XML PATH('')
						)
						,2,200000) AS CSV
					)))		
				, 1,1) then 1
				when len(ltrim(rtrim(@ResultFilter))) != 1 and 
					rtrim(ltrim((
						SELECT SUBSTRING(
						(
						Select ';' + 
						DA.Result
						From
						(
							Select
							table_pk_id,
							(
								SELECT
								isnull(doc.col.value('NumUnits[1]', 'nvarchar(10)') +  ' ','') + -- UnitAmount
								isnull(doc.col.value('Units[1]', 'nvarchar(20)') +  ' ','') + -- Unit
								isnull(doc.col.value('Type[1]', 'nvarchar(50)'),'') as Result
								FROM xml_fields.nodes('.') doc(col) 
							) as Result
							From 
							xml_records X
							Where
							X.entityName like '%DisciplineActionTaken%'
						) DA
						Where
						DA.table_pk_id = D.DisciplineID
						FOR XML PATH('')
						)
						,2,200000) AS CSV
					)))		
				 like '%' + ltrim(rtrim(@ResultFilter)) + '%' then 1
				else 0
			end = 1		
		)
	End
	else
	Begin
		Set @RecordsToDisplay = 1000000
	End

	Declare @TodaysDate date = dbo.glgetdatetime()
	Declare @LastWeeksDate date = 
			DATEADD(DAY, -7, dbo.GLgetdatetime())

	Declare @IncidentsTodayCount int = 
	(
	Select COUNT(*)
	From Discipline
	Where 
	StudentID = @StudentID
	and
	DateOfIncident = @TodaysDate
	)

	Declare @IncidentsThisWeekCount int =
	(
	Select COUNT(*)
	From Discipline
	Where 
	StudentID = @StudentID
	and
	DateOfIncident > @LastWeeksDate
	)
	
	
	Declare @FilterRecordsPastDate date
	if (@NumDaysOfDisciplineToShow is not null)
	Begin
		Set @FilterRecordsPastDate = DATEADD(DAY, (@NumDaysOfDisciplineToShow * -1), dbo.GLgetdatetime())
	End


	Select
	1 as tag,
	null as parent,
	@ClassID as [Top!1!ClassID],
	@EK as [Top!1!EK],
	@SelectedDisciplineID as [Top!1!SelectedDisciplineID],
	@StudentID as [Top!1!StudentID],
	@DateFilter as [Top!1!DateFilter],
	@StudentFilter as [Top!1!StudentFilter],
	@IncidentFilter as [Top!1!IncidentFilter],
	@LocationFilter as [Top!1!LocationFilter],
	@ReferredByFilter as [Top!1!ReferredByFilter],
	@ReferredToFilter as [Top!1!ReferredToFilter],
	@ResultFilter as [Top!1!ResultFilter],
	@RecordsToDisplay as [Top!1!RecordsToDisplay],
	@IncidentsTodayCount as [Top!1!IncidentsTodayCount],
	@IncidentsThisWeekCount as [Top!1!IncidentsThisWeekCount],
	@TotalIncidents as [Top!1!TotalIncidents],
	null as [Discipline!2!DisciplineID],
	null as [Discipline!2!CalcDate],
	null as [Discipline!2!Date],
	null as [Discipline!2!Student],
	null as [Discipline!2!Incident],
	null as [Discipline!2!Location],
	null as [Discipline!2!ReferredBy],
	null as [Discipline!2!ReferredTo],
	null as [Discipline!2!IncidentDesc],
	null as [Discipline!2!Result]

	Union

	select *
	From
	(
	select distinct top (@RecordsToDisplay)
	2 as tag,
	1 as parent,
	@ClassID as [Top!1!ClassID],
	@EK as [Top!1!EK],
	null as [Top!1!SelectedDisciplineID],
	null as [Top!1!StudentID],
	null as [Top!1!DateFilter],
	null as [Top!1!StudentFilter],
	null as [Top!1!IncidentFilter],
	null as [Top!1!LocationFilter],
	null as [Top!1!ReferredByFilter],
	null as [Top!1!ReferredToFilter],
	null as [Top!1!ResultFilter],
	null as [Top!1!RecordsToDisplay],
	null as [Top!1!IncidentsTodayCount],
	null as [Top!1!IncidentsThisWeekCount],	
	null as [Top!1!TotalIncidents],
	D.DisciplineID as [Discipline!2!DisciplineID],
	D.DateOfIncident as [Discipline!2!CalcDate],
	dbo.GLformatdate(DateOfIncident) as [Discipline!2!Date],
	S.glname as [Discipline!2!Student], 
	replace(D.IncidentCodes, '; ', '<br/>') as [Discipline!2!Incident],
	D.Location as [Discipline!2!Location],
	D.ReferredBy as [Discipline!2!ReferredBy],
	D.ReferredTo as [Discipline!2!ReferredTo],
	D.IncidentDesc as [Discipline!2!IncidentDesc],
	replace(rtrim(ltrim(
		(
			SELECT SUBSTRING(
			(
			Select ';' + 
			DA.Result
			From
			(
				Select
				table_pk_id,
				(
					SELECT
					isnull(doc.col.value('NumUnits[1]', 'nvarchar(10)') +  ' ','') + -- UnitAmount
					isnull(doc.col.value('Units[1]', 'nvarchar(20)') +  ' ','') + -- Unit
					isnull(doc.col.value('Type[1]', 'nvarchar(50)'),'') as Result
					FROM xml_fields.nodes('.') doc(col) 
				) as Result
				From 
				xml_records X
				Where
				X.entityName like '%DisciplineActionTaken%'
			) DA
			Where
			DA.table_pk_id = D.DisciplineID
			FOR XML PATH('')
			)
			,2,200000) AS CSV
		))), ';', '<br/>'
	) as [Discipline!2!Result]
	From 
	Students S
		inner join
	Discipline D
		on S.StudentID = D.StudentID
	Where
	case
		when @StudentID = -1 then 1
		when D.StudentID = @StudentID then 1
		else 0
	end = 1
	and	
	case
		when @NumDaysOfDisciplineToShow is null then 1
		when DateOfIncident > @FilterRecordsPastDate then 1
		else 0
	end = 1	
	and
	case
		when ltrim(rtrim(isnull(@DateFilter,''))) = '' then 1
		when len(ltrim(rtrim(@DateFilter))) = 1 and ltrim(rtrim(@DateFilter)) = substring(dbo.GLformatdate(DateOfIncident), 1,1) then 1
		when len(ltrim(rtrim(@DateFilter))) != 1 and dbo.GLformatdate(DateOfIncident) like '%' + ltrim(rtrim(@DateFilter)) + '%' then 1
		else 0
	end = 1
	and
	case
		when ltrim(rtrim(isnull(@StudentFilter,''))) = '' then 1
		when len(ltrim(rtrim(@StudentFilter))) = 1 and ltrim(rtrim(@StudentFilter)) = substring(S.glname, 1,1) then 1
		when len(ltrim(rtrim(@StudentFilter))) != 1 and S.glname like '%' + ltrim(rtrim(@StudentFilter)) + '%' then 1
		else 0
	end = 1
	and
	case
		when ltrim(rtrim(isnull(@IncidentFilter,''))) = '' then 1
		when len(ltrim(rtrim(@IncidentFilter))) = 1 and ltrim(rtrim(@IncidentFilter)) = substring(D.IncidentCodes, 1,1) then 1
		when len(ltrim(rtrim(@IncidentFilter))) != 1 and D.IncidentCodes like '%' + ltrim(rtrim(@IncidentFilter)) + '%' then 1
		else 0
	end = 1
	and
	case
		when ltrim(rtrim(isnull(@LocationFilter,''))) = '' then 1
		when len(ltrim(rtrim(@LocationFilter))) = 1 and ltrim(rtrim(@LocationFilter)) = substring(D.Location, 1,1) then 1
		when len(ltrim(rtrim(@LocationFilter))) != 1 and D.Location like '%' + ltrim(rtrim(@LocationFilter)) + '%' then 1
		else 0
	end = 1
	and
	case
		when ltrim(rtrim(isnull(@ReferredByFilter,''))) = '' then 1
		when len(ltrim(rtrim(@ReferredByFilter))) = 1 and ltrim(rtrim(@ReferredByFilter)) = substring(D.ReferredBy, 1,1) then 1
		when len(ltrim(rtrim(@ReferredByFilter))) != 1 and D.ReferredBy like '%' + ltrim(rtrim(@ReferredByFilter)) + '%' then 1
		else 0
	end = 1
	and
	case
		when ltrim(rtrim(isnull(@ReferredToFilter,''))) = '' then 1
		when len(ltrim(rtrim(@ReferredToFilter))) = 1 and ltrim(rtrim(@ReferredToFilter)) = substring(D.ReferredTo, 1,1) then 1
		when len(ltrim(rtrim(@ReferredToFilter))) != 1 and D.ReferredTo like '%' + ltrim(rtrim(@ReferredToFilter)) + '%' then 1
		else 0
	end = 1
	and	
	case
		when ltrim(rtrim(isnull(@ResultFilter,''))) = '' then 1
		when len(ltrim(rtrim(@ResultFilter))) = 1 and ltrim(rtrim(@ResultFilter)) = substring(
			rtrim(ltrim((
				SELECT SUBSTRING(
				(
				Select ';' + 
				DA.Result
				From
				(
					Select
					table_pk_id,
					(
						SELECT
						isnull(doc.col.value('NumUnits[1]', 'nvarchar(10)') +  ' ','') + -- UnitAmount
						isnull(doc.col.value('Units[1]', 'nvarchar(20)') +  ' ','') + -- Unit
						isnull(doc.col.value('Type[1]', 'nvarchar(50)'),'') as Result
						FROM xml_fields.nodes('.') doc(col) 
					) as Result
					From 
					xml_records X
					Where
					X.entityName like '%DisciplineActionTaken%'
				) DA
				Where
				DA.table_pk_id = D.DisciplineID
				FOR XML PATH('')
				)
				,2,200000) AS CSV
			)))		
		, 1,1) then 1
		when len(ltrim(rtrim(@ResultFilter))) != 1 and 
			rtrim(ltrim((
				SELECT SUBSTRING(
				(
				Select ';' + 
				DA.Result
				From
				(
					Select
					table_pk_id,
					(
						SELECT
						isnull(doc.col.value('NumUnits[1]', 'nvarchar(10)') +  ' ','') + -- UnitAmount
						isnull(doc.col.value('Units[1]', 'nvarchar(20)') +  ' ','') + -- Unit
						isnull(doc.col.value('Type[1]', 'nvarchar(50)'),'') as Result
						FROM xml_fields.nodes('.') doc(col) 
					) as Result
					From 
					xml_records X
					Where
					X.entityName like '%DisciplineActionTaken%'
				) DA
				Where
				DA.table_pk_id = D.DisciplineID
				FOR XML PATH('')
				)
				,2,200000) AS CSV
			)))		
		 like '%' + ltrim(rtrim(@ResultFilter)) + '%' then 1
		else 0
	end = 1		
	Order By [Discipline!2!CalcDate] desc, [Discipline!2!Student]
	) x
	FOR XML EXPLICIT


END


GO
