SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Don Puls
-- Create date: 5/19/2013
-- Modified dt: 1/04/2022 ~JG (GC-33928)
-- Description:	Retrieves StudentInfoDisciplinePreviewPane Info
--				Returns 4 seperate xml streams of data
-- =============================================
CREATE   Procedure [dbo].[StudentInfoDisciplinePreviewPane] 
	@DisciplineID int
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Get Incident Info
	Select
	1 as tag,
	null as parent,
	S.StudentID as [Discipline!1!StudentID],
	S.Lname as [Discipline!1!Lname],
	S.Fname as [Discipline!1!Fname],
	S.glname as [Discipline!1!Sname], 
	S.Mother as [Discipline!1!Mother],
	S.Father as [Discipline!1!Father],
	S.Phone1 as [Discipline!1!Phone1],
	S.Phone2 as [Discipline!1!Phone2],
	S.Phone3 as [Discipline!1!Phone3],
	S.Email1 as [Discipline!1!Email1],
	S.Email2 as [Discipline!1!Email2],
	S.Email3 as [Discipline!1!Email3],
	D.DisciplineID as [Discipline!1!DisciplineID],
	D.DateOfIncident as [Discipline!1!CalcDate],
	dbo.GLformatdate(DateOfIncident) as [Discipline!1!Date],
	dbo.GLformatdate(DateReportClosed) as [Discipline!1!DateReportClosed],
	'|' + replace(D.IncidentCodes, '; ', '|') + '|' as [Discipline!1!Incident],
	replace(D.IncidentCodes, '; ', '<br/>') as [Discipline!1!IncidentHTML],
	D.IncidentDesc as [Discipline!1!IncidentDesc],
	D.IncidentHist as [Discipline!1!PrivateNotes],
	D.GradeLevel as [Discipline!1!GradeLevel],
	D.Location as [Discipline!1!Location],
	D.ReferredBy as [Discipline!1!ReferredBy],
	D.ReferredTo as [Discipline!1!ReferredTo],
	D.TeacherID as [Discipline!1!TeacherID]
	From 
	Students S
		inner join
	Discipline D
		on S.StudentID = D.StudentID
	Where
	D.DisciplineID = @DisciplineID
	FOR XML EXPLICIT




	-- Get Incident Action Details
	Select
	1 as tag,
	null as parent,
	DA.xml_pk_id as [DisciplineAction!1!xml_pk_id],
	DA.ActionTaken as [DisciplineAction!1!ActionTaken],
	DA.ReferredTo as [DisciplineAction!1!ReferredTo],
	DA.StartDate as [DisciplineAction!1!StartDate],
	DA.EndDate as [DisciplineAction!1!EndDate],
	DA.Duration as [DisciplineAction!1!Duration],
	DA.Units as [DisciplineAction!1!Units],
	DA.Notes as [DisciplineAction!1!Notes],
	DA.TeacherID as [DisciplineAction!1!TeacherID]
	From 
	(
	Select
	xml_pk_id,
	table_pk_id,
	(
		SELECT
		doc.col.value('Type[1]', 'nvarchar(50)')
		FROM xml_fields.nodes('.') doc(col) 
	) as ActionTaken,
	(
		SELECT
		doc.col.value('NumUnits[1]', 'nvarchar(10)')
		FROM xml_fields.nodes('.') doc(col) 
	) as Duration,
	(
		SELECT
		doc.col.value('Units[1]', 'nvarchar(20)')
		FROM xml_fields.nodes('.') doc(col) 
	) as Units,	
	(
		SELECT
		doc.col.value('StartDate[1]', 'nvarchar(50)')
		FROM xml_fields.nodes('.') doc(col) 
	) as StartDate,
	(
		SELECT
		doc.col.value('EndDate[1]', 'nvarchar(50)')
		FROM xml_fields.nodes('.') doc(col) 
	) as EndDate,
	(
		SELECT
		doc.col.value('ReferredTo[1]', 'nvarchar(50)')
		FROM xml_fields.nodes('.') doc(col) 
	) as ReferredTo,
	(
		SELECT
		doc.col.value('Notes[1]', 'nvarchar(500)')
		FROM xml_fields.nodes('.') doc(col) 
	) as Notes,
	(
		SELECT
		doc.col.value('TeacherID[1]', 'nvarchar(10)')
		FROM xml_fields.nodes('.') doc(col) 
	) as TeacherID	
	From 
	xml_records X
	Where
	X.entityName like '%DisciplineActionTaken%'
	) as DA
	Where
	DA.table_pk_id = @DisciplineID
	Order By dbo.toDBDate(DA.StartDate), dbo.toDBDate(DA.EndDate)
	FOR XML EXPLICIT


	-- Get Student Discpline History
	Declare @StudentID int = (Select StudentID From Discipline Where DisciplineID = @DisciplineID)
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


	Select
	1 as tag,
	null as parent,
	@IncidentsTodayCount as [IncidentCount!1!IncidentsTodayCount],
	@IncidentsThisWeekCount as [IncidentCount!1!IncidentsThisWeekCount]
	FOR XML EXPLICIT



	-- Get Autocomplete list data
	Declare @ACDisciplineReferredBy nvarchar(4000) =
	(
	SELECT SUBSTRING(
	(
	Select distinct ', ' + 
	'"' + Title + '"' 
	From vSelectOptions
	Where
	SelectListID = 13
	and
	rtrim(ltrim(ISNULL(Title, ''))) != ''
	FOR XML PATH('')),2,200000) AS DisciplineReferredBy
	)
	Set @ACDisciplineReferredBy = replace(@ACDisciplineReferredBy, '&amp;', '&');

	Declare @ACDisciplineReferredTo nvarchar(4000) =
	(
	SELECT SUBSTRING(
	(
	Select distinct ', ' + 
	'"' + Title + '"' 
	From vSelectOptions
	Where
	SelectListID = 14
	and
	rtrim(ltrim(ISNULL(Title, ''))) != ''
	FOR XML PATH('')),2,200000) AS DisciplineReferredTo
	);
	Set @ACDisciplineReferredTo = replace(@ACDisciplineReferredTo, '&amp;', '&'); 

	Declare @edfiEnabled bit = (
		Select cast(ISNULL((
		    Select 
			    SS.[Enabled] 
		    From [LKG].dbo.glServices S
			    left join [LKG].dbo.glSchoolServices SS
				    on S.ServiceID = SS.ServiceID
		    Where S.ServiceID = 31 and SchoolID = (Select SchoolID From Settings where SettingID = 1)
	    ), 0) as bit)
	);

	Declare @schoolType nvarchar(50) = (
		Select ISNULL((
		    Select 
			    SchoolType 
		    From Settings 
		    Where SettingID = 1
	    ), '')
	);

	Declare @ACDisciplineIncidentCodes nvarchar(2000);

	IF @edfiEnabled = 1 and @schoolType = 'PublicSchool'
	BEGIN
		SELECT @ACDisciplineIncidentCodes = SUBSTRING(
		(
			Select 
				', ' + '"' + Title + '"'
			From vSelectOptions 
			Where SelectListID = 11
			Order By Title
			FOR XML PATH('')
		),2,200000)
	END
	ELSE
	BEGIN
		SELECT @ACDisciplineIncidentCodes = SUBSTRING(
		(
			Select 
				distinct ', ' + '"' + IncidentCodes + '"' 
			From Discipline
			Where rtrim(ltrim(ISNULL(IncidentCodes, ''))) != ''
			FOR XML PATH('')
		),2,200000) -- AS DisciplineIncidentCodes
	END

	Declare @LocationValues table(Location nvarchar(200))
	Insert into @LocationValues
	-- commented the above out as schools complained about seeing non-configured values (FD#329758)
	-- Hopefully schools will just configure the below, but we can always add an option if some schools want to see this.
	-- remove the below commented code if no issues and some time has past. - dp 9/13/2021
	--Select distinct Location
	--From Discipline
	--Where
	--rtrim(ltrim(ISNULL(Location, ''))) != ''
	--UNion
	Select distinct Title
	From vSelectOptions
	Where
	SelectListID = 1
	and
	rtrim(ltrim(ISNULL(Title, ''))) != ''




	Declare @ACDisciplineLocation nvarchar(max) =
	(
	SELECT SUBSTRING(
	(
	Select distinct ', ' + 
	'"' + Location + '"' 
	From @LocationValues
	Where
	rtrim(ltrim(ISNULL(Location, ''))) != ''
	FOR XML PATH('')),2,200000) AS DisciplineLocation
	)


	Declare @ACActionReferredTo nvarchar(2000) =
	(
	SELECT SUBSTRING(
	(
	Select ', ' + 
	'"' + Title + '"' 
	From SelectOptions
	Where
	SelectListID = 15
	Order By Title
	FOR XML PATH('')),2,200000) AS ActionReferredTo
	)

	Declare @ACActionActionTaken nvarchar(2000) =
	(
	SELECT SUBSTRING(
	(
	Select ', ' + 
	'"' + Title + '"' 
	From vSelectOptions 
	Where SelectListID = 12
	Order By Title
	FOR XML PATH('')),2,200000) AS ActionActionTaken
	)


	Select
	1 as tag,
	null as parent,
	@ACDisciplineReferredBy as [Autocomplete!1!DisciplineReferredBy],
	@ACDisciplineReferredTo as [Autocomplete!1!DisciplineReferredTo],
	@ACDisciplineIncidentCodes as [Autocomplete!1!DisciplineIncidentCodes],
	@ACDisciplineLocation as [Autocomplete!1!DisciplineLocation],
	@ACActionReferredTo as [Autocomplete!1!ActionReferredTo],
	@ACActionActionTaken as [Autocomplete!1!ActionActionTaken]
	FOR XML EXPLICIT
	
	
	-- Get Default and Custom Entered IncidentCodes
	IF @edfiEnabled = 1 and @schoolType = 'PublicSchool'
	BEGIN
		select 
			1 as tag,
			null as parent,
			Title as [MultiSelect!1!IncidentCode]
		From vSelectOptions 
		Where SelectListID = 11
		FOR XML EXPLICIT
	END
	ELSE
	BEGIN
		Select 
		1 as tag,
		null as parent,
		IncidentCodes as [MultiSelect!1!IncidentCode]
		From 
		dbo.GetMultiSelectIncidentCodes()
		FOR XML EXPLICIT
	END
END


GO
