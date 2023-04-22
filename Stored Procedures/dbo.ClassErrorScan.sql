SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[ClassErrorScan]
as

declare @errorCount int = 0

declare @currentYearRef nvarchar(50) = left(cast(YEAR(GETDATE()-180) as nvarchar(50)),4)+'-08'+'-01'

declare @Term1ID as nvarchar(10) =
(select top 1 cast(TermID as nvarchar(10)) from Terms 
	where StartDate>@currentYearRef 
		and Status = 1
		and TermID not in (select ParentTermID from Terms)
	order by TermTitle desc)


declare @Term2ID as nvarchar(10) =
(select top 1 cast(TermID as nvarchar(10)) from Terms 
	where StartDate>@currentYearRef 
		and TermID<@Term1ID
		and TermID not in (select ParentTermID from Terms)
	order by TermTitle desc)

declare @ClassID int = 1;
declare @SelectedTerms nvarchar(MAX) = @Term1ID+','+@Term2ID+',';
--select @SelectedTerms
declare @ShowClassIDs nvarchar(MAX) = '';


		Declare 
		@FirstTermID int,
		@FirstTermTitle nvarchar(50),
		@SecondTermID int,
		@SecondTermTitle nvarchar(50),
		@SpanishReports bit

		Set @SpanishReports = (Select SpanishReports From Settings Where SettingID = 1)

		Select top 1
		@FirstTermID = TermID,
		@FirstTermTitle = ReportTitle
		From Terms
		Where
		TermID in (Select *  From dbo.SplitCSVIntegers(@SelectedTerms))
		Order By EndDate

		Select top 1
		@SecondTermID = TermID,
		@SecondTermTitle = ReportTitle
		From Terms
		Where
		TermID in (Select *  From dbo.SplitCSVIntegers(@SelectedTerms))
		Order By EndDate desc

		Select
		C.ClassID,
		C.ClassTitle,
		C.ReportTitle,
		C.SpanishTitle,
		C.ReportOrder,
		C.Units,
		C.ClassTypeID,
		CT.ClassTypeName,
		C.SubCommentClassTypeID,
		(Select GradeScaleName From CustomGradeScale Where CustomGradeScaleID = C.CustomGradeScaleID) as GradeScale,
		(Select ClassTypeName From ClassType where ClassTypeID = C.SubCommentClassTypeID) as SubGrade
		into #Q1TermClasses
		From
		Classes C
			inner join
		ClassType CT
			on C.ClassTypeID = CT.ClassTypeID
		Where
		C.ParentClassID = 0
		and
		TermID = @FirstTermID
		Order By C.ClassTitle

		
		
		Select
		C.ClassID,
		C.ClassTitle,
		C.ReportTitle,
		C.SpanishTitle,
		C.ReportOrder,
		C.Units,
		C.ClassTypeID,
		CT.ClassTypeName,
		C.SubCommentClassTypeID,
		(Select GradeScaleName From CustomGradeScale Where CustomGradeScaleID = C.CustomGradeScaleID) as GradeScale,
		(Select ClassTypeName From ClassType where ClassTypeID = C.SubCommentClassTypeID) as SubGrade
		into #Q2TermClasses
		From
		Classes C
			inner join
		ClassType CT
			on C.ClassTypeID = CT.ClassTypeID
		Where 
		C.ParentClassID = 0
		and
		TermID = @SecondTermID
		Order By C.ClassTitle

		
		-- Custom Class/Subgrade Field Differences between Transcript and Configured Values
		-- Configured Field Settings
		Select distinct
		CT.ClassTypeID,
		CT.ClassTypeName,
		CF.CustomFieldName,
		IsNull(CF.CustomFieldSpanishName,'Null') as CustomFieldSpanishName,
		CF.CustomFieldOrder
		into #ConfiguredFields
		From 
		Classes C
			inner join
		ClassType CT
			on C.ClassTypeID = CT.ClassTypeID
			inner join
		CustomFields CF
			on CT.ClassTypeID = CF.ClassTypeID
		Where
		C.TermID = @FirstTermID
		or
		C.TermID = @SecondTermID


		-- Transcript Q1 Field Settings
		Select distinct
		ClassTypeID,
		CustomFieldName,
		IsNull(CustomFieldSpanishName,'Null') as CustomFieldSpanishName,
		CustomFieldOrder
		into #Q1TranscriptFields
		From 
		Transcript
		Where
		TermID = @FirstTermID
		Order By ClassTypeID, CustomFieldOrder
		
		-- Transcript Q2 Field Settings
		Select distinct
		ClassTypeID,
		CustomFieldName,
		IsNull(CustomFieldSpanishName,'Null') as CustomFieldSpanishName,
		CustomFieldOrder
		into #Q2TranscriptFields
		From 
		Transcript
		Where
		TermID = @SecondTermID
		Order By ClassTypeID, CustomFieldOrder

SELECT @errorCount = @errorCount + COUNT(*) FROM
(
		Select
		1 as tag,
		null as parent,
		@ClassID as [General!1!ClassID],
		@SpanishReports as [General!1!SpanishReports],
		@ShowClassIDs as [General!1!ShowClassIDs],
		@FirstTermTitle as [General!1!FirstTermTitle], 
		@SecondTermTitle as [General!1!SecondTermTitle], 
		null as [Class!2!Q1ClassID],
		null as [Class!2!Q1ClassTitle],
		null as [Class!2!Q1ReportTitle],
		null as [Class!2!Q1SpanishTitle],
		null as [Class!2!Q1ReportOrder],
		null as [Class!2!Q1Units],
		null as [Class!2!Q1ClassTypeName],
		null as [Class!2!Q1GradeScale],
		null as [Class!2!Q1SubGrade],
		null as [Class!2!Q2ClassID],
		null as [Class!2!Q2ClassTitle],
		null as [Class!2!Q2ReportTitle],
		null as [Class!2!Q2SpanishTitle],
		null as [Class!2!Q2ReportOrder],
		null as [Class!2!Q2Units],
		null as [Class!2!Q2ClassTypeName],
		null as [Class!2!Q2GradeScale],
		null as [Class!2!Q2SubGrade]
		
		Union All
		
		Select
		2 as tag,
		1 as parent,
		null as [General!1!ClassID],
		null as [General!1!SpanishReports],
		null as [General!1!ShowClassIDs],
		null as [General!1!FirstTermTitle], 
		null as [General!1!SecondTermTitle], 
		Q1.ClassID as [Class!2!Q1ClassID],
		Q1.ClassTitle as [Class!2!Q1ClassTitle],
		Q1.ReportTitle as [Class!2!Q1ReportTitle],
		Q1.SpanishTitle as [Class!2!Q1SpanishTitle],
		Q1.ReportOrder as [Class!2!Q1ReportOrder],
		Q1.Units as [Class!2!Q1Units],
		Q1.ClassTypeName as [Class!2!Q1ClassTypeName],
		Q1.GradeScale as [Class!2!Q1GradeScale],
		Q1.SubGrade as [Class!2!Q1SubGrade],
		Q2.ClassID as [Class!2!Q2ClassID],
		Q2.ClassTitle as [Class!2!Q2ClassTitle],
		Q2.ReportTitle as [Class!2!Q2ReportTitle],
		Q2.SpanishTitle as [Class!2!Q2SpanishTitle],
		Q2.ReportOrder as [Class!2!Q2ReportOrder],
		Q2.Units as [Class!2!Q2Units],
		Q2.ClassTypeName as [Class!2!Q2ClassTypeName],
		Q2.GradeScale as [Class!2!Q2GradeScale],
		Q2.SubGrade as [Class!2!Q2SubGrade]
		From
		#Q1TermClasses Q1
			inner join
		#Q2TermClasses Q2
			on Q1.ClassTitle = Q2.ClassTitle
		Where
		Q1.SubCommentClassTypeID != Q2.SubCommentClassTypeID
		or
		Q1.ClassTypeID != Q2.ClassTypeID
		or
		Q1.ReportTitle COLLATE Latin1_General_CS_AS != Q2.ReportTitle
		or
		Q1.SpanishTitle COLLATE Latin1_General_CS_AS != Q2.SpanishTitle
		or
		Q1.ReportOrder != Q2.ReportOrder
		or
		Q1.GradeScale != Q2.GradeScale
		or
		Q1.Units != Q2.Units
) x1

SELECT @errorCount = @errorCount + COUNT(*) FROM
(		
		-- Find Classes only in Q1
		Select 
		1 as tag,
		null as parent,
		ClassID as [Q1ClassOnly!1!Q1ClassID],
		ClassTitle as [Q1ClassOnly!1!Q1ClassTitle]
		From
		#Q1TermClasses
		Where
		ClassTitle not in (Select ClassTitle From #Q2TermClasses)
) x2

SELECT @errorCount = @errorCount + COUNT(*) FROM
(		
		-- Find Classes only in Q2
		Select 
		1 as tag,
		null as parent,
		ClassID as [Q2ClassOnly!1!Q2ClassID],
		ClassTitle as [Q2ClassOnly!1!Q2ClassTitle]
		From
		#Q2TermClasses
		Where
		ClassTitle not in (Select ClassTitle From #Q1TermClasses)
) x3
		
SELECT @errorCount = @errorCount + COUNT(*) FROM
(		
		-- Select Q1 Field Differences
		Select
		1 as tag,
		null as parent,
		T.ClassTypeID as [Q1FieldDiff!1!ClassTypeID],
		IsNull((Select ClassTypeName From ClassType Where ClassTypeID = T.ClassTypeID),'ClassTypeID No Longer Exists') as [Q1FieldDiff!1!ClassTypeName],
		T.CustomFieldName as [Q1FieldDiff!1!CustomFieldName],
		T.CustomFieldSpanishName as [Q1FieldDiff!1!CustomFieldSpanishName],
		T.CustomFieldOrder as [Q1FieldDiff!1!CustomFieldOrder]
		From
		#ConfiguredFields C
			right join
		#Q1TranscriptFields T
			on 
			C.ClassTypeID = T.ClassTypeID
			and
			C.CustomFieldName = T.CustomFieldName
			and
			C.CustomFieldSpanishName = T.CustomFieldSpanishName
			and
			C.CustomFieldOrder = T.CustomFieldOrder
		Where
		T.ClassTypeID > 99
		and
		C.ClassTypeID is null
--		Order By T.ClassTypeID, T.CustomFieldOrder
) x4	

SELECT @errorCount = @errorCount + COUNT(*) FROM
(		
		-- Select Q2 Field Differences
		Select
		1 as tag,
		null as parent,
		T.ClassTypeID as [Q2FieldDiff!1!ClassTypeID],
		IsNull((Select ClassTypeName From ClassType Where ClassTypeID = T.ClassTypeID),'ClassTypeID No Longer Exists') as [Q2FieldDiff!1!ClassTypeName],
		T.CustomFieldName as [Q2FieldDiff!1!CustomFieldName],
		T.CustomFieldSpanishName as [Q2FieldDiff!1!CustomFieldSpanishName],
		T.CustomFieldOrder as [Q2FieldDiff!1!CustomFieldOrder]
		From
		#ConfiguredFields C
			right join
		#Q2TranscriptFields T
			on 
			C.ClassTypeID = T.ClassTypeID
			and
			C.CustomFieldName = T.CustomFieldName
			and
			C.CustomFieldSpanishName = T.CustomFieldSpanishName
			and
			C.CustomFieldOrder = T.CustomFieldOrder
		Where 
		T.ClassTypeID > 99
		and
		C.ClassTypeID is null
--		Order By T.ClassTypeID, T.CustomFieldOrder
) x5		
		
		
		
		drop table #Q1TermClasses
		drop table #Q2TermClasses
		drop table #ConfiguredFields
		drop table #Q1TranscriptFields
		drop table #Q2TranscriptFields
-- select @errorCount,@SelectedTerms,(Select EndDate from Terms where TermID=@Term1ID)
	
update LKG.dbo.Schools 
set ClassErrorCount = @errorCount, 
ClassTermsAnalyzed = @SelectedTerms,
ClassNextTermEnd = (Select EndDate from Terms where TermID=@Term1ID)
	where SchoolID = DB_NAME()

GO
