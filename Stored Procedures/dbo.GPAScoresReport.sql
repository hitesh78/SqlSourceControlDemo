SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[GPAScoresReport] 
@GradeLevel nvarchar(20), 
@ReportType nvarchar(7), 
@TermType nvarchar(15), 
@TermIDs nvarchar(1000), 
@TheCount int, 
@ClassID int, 
@EK Decimal(15,15),
@Sort nvarchar(10),
@GPAStart nvarchar(10),
@GPAEnd nvarchar(10),
@ExcludeLetterGrade nvarchar(10),
@ClassFilter nvarchar(200)

AS


Declare @StartValue decimal(5,2)
Declare @EndValue decimal(5,2)
Declare @FactorGPARange bit = 1

Select
@StartValue = -2,
@EndValue = 200.00

If @GPAStart != ''
Begin
	Set @StartValue = convert(decimal(5,2), @GPAStart)
End

If @GPAEnd != ''
Begin
	Set @EndValue = convert(decimal(5,2), @GPAEnd)
End



If @StartValue = -2 and @EndValue = 200.00
Begin
	Set @FactorGPARange = 0
End





Declare 
@CountTermsOutsideCurrentSchoolYear int,
@CountTermsActive int,
@FilterByCurrentStudents bit = 0,
@DaySpanOfSelectedTerms int,
@FilterByLatestTermStudents bit = 0

Declare @CurrentStudents table (StudentID int)
Declare @LatestTermStudents table (StudentID int) 


Declare @CalcDate datetime = dbo.GLgetdatetime()

-- See if any terms are outside of the current school year
Select 
@CountTermsOutsideCurrentSchoolYear = count(IntegerID )
From SplitCSVIntegers(@TermIDs)
Where
IntegerID not in (Select * From dbo.GetYearTermIDsByDate(@CalcDate))


-- See if any selected terms are curretnly active or a parent of an active child term
Select 
@CountTermsActive = count(IntegerID )
From SplitCSVIntegers(@TermIDs)
Where
IntegerID in 
(
Select TermID
From Terms
Where
Status = 1
or
TermID in (Select ParentTermID From Terms Where Status = 1)
or
TermID in (Select * From dbo.GetYearTermIDsByDate(GETDATE()))
)



If	@CountTermsOutsideCurrentSchoolYear > 0 
	and  
	@CountTermsActive > 0 
	and
	@GradeLevel != '0'
Begin
	Set @FilterByCurrentStudents = 1
	Insert into @CurrentStudents
	Select StudentID
	From Students 
	Where
	Active = 1
	and
	GradeLevel = @GradeLevel
End



-- Of Terms Selected See if the dates span more then 400 days. 

Declare @MinDate date = (Select Min(StartDate) From Terms Where TermID in (Select IntegerID From SplitCSVIntegers(@TermIDs)));
Declare @MaxDate date = (Select Max(EndDate) From Terms Where TermID in (Select IntegerID From SplitCSVIntegers(@TermIDs)));
set @DaySpanOfSelectedTerms = datediff(day, @MinDate, @MaxDate);


-- If dates span more than 400 days and filtering by GradeLevel then filter 
-- Students based on their Gradelevel in the most recent Term selected
If @GradeLevel != '0' and @DaySpanOfSelectedTerms > 400 and @FilterByCurrentStudents = 0
Begin
	Set @FilterByLatestTermStudents = 1
	Declare @LatestTermID int = (	
									Select top 1 TermID
									From Terms
									Where 
									TermID in (Select IntegerID From SplitCSVIntegers(@TermIDs))
									and
									EndDate = @MaxDate
								);
	Insert into @LatestTermStudents
	Select distinct StudentID
	From Transcript 
	Where
	TermID = @LatestTermID
	and
	GradeLevel = @GradeLevel
End




declare @ActiveTermIDs table (TermID int)
insert into @ActiveTermIDs
Select TermID
From 
Terms 
Where 
[Status] = 1



Declare 
@TransciptTermCount int = 0,
@ActiveTermCount int = 0

Select 
@TransciptTermCount = count(IntegerID)
From SplitCSVIntegers(@TermIDs)
Where
IntegerID not in (Select TermID From @ActiveTermIDs)

-- if only one transcript term is selected and it is also the only active term
-- Then set TranscriptTermCount to 1 
Declare @TotalTermsSelected int
Select 
@TotalTermsSelected = count(IntegerID)
From SplitCSVIntegers(@TermIDs)

If
@TermType = 'Transcript'
and 
@TotalTermsSelected = 1
and 
(
Select 
IntegerID
From SplitCSVIntegers(@TermIDs)
) in 
(
Select TermID
From 
Terms 
Where 
[Status] = 1
)
Begin
	Set @TransciptTermCount = 1
End


if @TermType = 'nonTranscript'
Begin
	set @ActiveTermCount = 1
End



Declare @TheCount2 int
Declare @TermStartTitle nvarchar(100)
Declare @TermEndTitle nvarchar(100)
Declare @TermTitle nvarchar(100)


Set @TheCount2 = @TheCount + 1

Select TermTitle, EndDate
into #tmpTerms
From Terms
Where
TermID in (Select IntegerID From SplitCSVIntegers(@TermIDs))

Set @TermStartTitle = (Select top 1 TermTitle From #tmpTerms Order By EndDate)
Set @TermEndTitle = (Select top 1 TermTitle From #tmpTerms Order By EndDate desc)

If @TermStartTitle = @TermEndTitle
Begin
	Set @TermTitle = @TermStartTitle
End
Else
Begin
	Set @TermTitle = @TermStartTitle + ' - ' + @TermEndTitle
End





Declare @SearchStringTable table (SearchValue nvarchar(50))

Insert into @SearchStringTable
Select TheString From dbo.SplitCSVStrings(@ClassFilter)

Declare
@Search1 nvarchar(50),
@Search2 nvarchar(50),
@Search3 nvarchar(50),
@Search4 nvarchar(50),
@Search5 nvarchar(50),
@Search6 nvarchar(50),
@Search7 nvarchar(50),
@Search8 nvarchar(50),
@Search9 nvarchar(50),
@Search10 nvarchar(50)

Set @Search1 = (Select top 1 ltrim(rtrim(SearchValue)) From @SearchStringTable)
Delete From @SearchStringTable Where SearchValue = @Search1
Set @Search1 = '%' + @Search1 + '%'
Set @Search2 = (Select top 1 ltrim(rtrim(SearchValue)) From @SearchStringTable)
Delete From @SearchStringTable Where SearchValue = @Search2
Set @Search2 = '%' + @Search2 + '%'
Set @Search3 = (Select top 1 ltrim(rtrim(SearchValue)) From @SearchStringTable)
Delete From @SearchStringTable Where SearchValue = @Search3
Set @Search3 = '%' + @Search3 + '%'
Set @Search4 = (Select top 1 ltrim(rtrim(SearchValue)) From @SearchStringTable)
Delete From @SearchStringTable Where SearchValue = @Search4
Set @Search4 = '%' + @Search4 + '%'
Set @Search5 = (Select top 1 ltrim(rtrim(SearchValue)) From @SearchStringTable)
Delete From @SearchStringTable Where SearchValue = @Search5
Set @Search5 = '%' + @Search5 + '%'
Set @Search6 = (Select top 1 ltrim(rtrim(SearchValue)) From @SearchStringTable)
Delete From @SearchStringTable Where SearchValue = @Search6
Set @Search6 = '%' + @Search6 + '%'
Set @Search7 = (Select top 1 ltrim(rtrim(SearchValue)) From @SearchStringTable)
Delete From @SearchStringTable Where SearchValue = @Search7
Set @Search7 = '%' + @Search7 + '%'
Set @Search8 = (Select top 1 ltrim(rtrim(SearchValue)) From @SearchStringTable)
Delete From @SearchStringTable Where SearchValue = @Search8
Set @Search8 = '%' + @Search8 + '%'
Set @Search9 = (Select top 1 ltrim(rtrim(SearchValue)) From @SearchStringTable)
Delete From @SearchStringTable Where SearchValue = @Search9
Set @Search9 = '%' + @Search9 + '%'
Set @Search10 = (Select top 1 ltrim(rtrim(SearchValue)) From @SearchStringTable)
Delete From @SearchStringTable Where SearchValue = @Search10
Set @Search10 = '%' + @Search10 + '%'






Declare @StudentsWithLowGrades table
(
StudentID int
)



Insert into @StudentsWithLowGrades
Select 	
StudentID
From 	
Transcript T
	inner join
CustomGradeScaleGrades CGG
	on	CGG.CustomGradeScaleID = T.CustomGradeScaleID
		and
		T.LetterGrade = CGG.GradeSymbol
Where 
T.ClassTypeID in (1, 2) 
and 
T.TermID in (Select IntegerID From SplitCSVIntegers(@TermIDs))
and
CGG.GradeOrder >= dbo.GetLowGradeOrder(T.CustomGradeScaleID, @ExcludeLetterGrade)
and
(
T.ClassTitle like @Search1
or
T.ClassTitle like @Search2
or
T.ClassTitle like @Search3
or
T.ClassTitle like @Search4
or
T.ClassTitle like @Search5
or
T.ClassTitle like @Search6
or
T.ClassTitle like @Search7
or
T.ClassTitle like @Search8
or
T.ClassTitle like @Search9
or
T.ClassTitle like @Search10
or
isnull(ltrim(rtrim(@ClassFilter)),'') = ''
)



Declare @LGStudentID table (StudentID int, CustomGradeScaleID int, GradeOrder int)
insert into @LGStudentID
Select
StudentID,
C.CustomGradeScaleID,
CGG.GradeOrder
From 
Classes C
	inner join
ClassesStudents CS
	on C.ClassID = CS.ClassID
	inner join
CustomGradeScaleGrades CGG
	on	C.CustomGradeScaleID = CGG.CustomGradeScaleID
		and
		dbo.GetLetterGrade(CS.ClassID, CS.StudentGrade) = CGG.GradeSymbol
Where
C.ClassTypeID in (1, 2, 8) 
and 
C.TermID in (Select IntegerID From SplitCSVIntegers(@TermIDs))
and
(
C.ClassTitle like @Search1
or
C.ClassTitle like @Search2
or
C.ClassTitle like @Search3
or
C.ClassTitle like @Search4
or
C.ClassTitle like @Search5
or
C.ClassTitle like @Search6
or
C.ClassTitle like @Search7
or
C.ClassTitle like @Search8
or
C.ClassTitle like @Search9
or
C.ClassTitle like @Search10
or
isnull(ltrim(rtrim(@ClassFilter)),'') = ''
)




Create table #ScoresInit
(
StudentID int,
xStudentID bigint,
Student nvarchar(60),
GradeLevel nvarchar(5),
AverageGrade decimal(6,3),
AveragePercentageGrade decimal(6,2),
ClassUnits decimal(10,6),
TermCount int
)
  
Insert into #ScoresInit
Select 	
StudentID as StudentID,
(Select xStudentID From Students Where StudentID = T.StudentID) as xStudentID,
(
Select
glname
From Students
where
StudentID = T.StudentID
) as Student,
REPLACE(LTRIM(REPLACE(max(RIGHT('000'+CAST(GradeLevel AS nvarchar(3)),3)),'0', ' ')), ' ', '0') as GradeLevel,
(
	Select
	case
		when sum(T2.ClassUnits) = 0 then -1
		else convert(decimal(6,3),sum(T2.UnitGPA)/sum(T2.ClassUnits))
	end
	From 
	Transcript T2 
	where 	
	TermID in (Select IntegerID From SplitCSVIntegers(@TermIDs))
	and
	case	-- exclude any selected Active terms	
		when @TermType = 'Transcript' then 1
		when @CountTermsActive > 0 and T2.TermID not in (Select TermID From @ActiveTermIDs) then 1
		else 0
	end = 1	
	and
	ClassTypeID in (1, 2)
	and
	case
		when @GradeLevel = '0' then 1
		when @FilterByCurrentStudents = 1 and StudentID in (Select StudentID From @CurrentStudents) then 1
		when @FilterByLatestTermStudents = 1 and StudentID in (Select StudentID From @LatestTermStudents) then 1
		when @FilterByCurrentStudents = 0 and @FilterByLatestTermStudents = 0 and isnull(GradeLevel, '0') = @GradeLevel then 1
		else 0
	end = 1
	and
	UnitGPA is not null
	and
	CustomGradeScaleID in (Select CustomGradeScaleID From CustomGradeScale Where CalculateGPA = 1)
	and
	T.StudentID = T2.StudentID
	and 
	(T2.AlternativeGrade is null or T2.AlternativeGrade = '')
	and
	T2.LetterGrade is not null
	and
	(
	T2.ClassTitle like @Search1
	or
	T2.ClassTitle like @Search2
	or
	T2.ClassTitle like @Search3
	or
	T2.ClassTitle like @Search4
	or
	T2.ClassTitle like @Search5
	or
	T2.ClassTitle like @Search6
	or
	T2.ClassTitle like @Search7
	or
	T2.ClassTitle like @Search8
	or
	T2.ClassTitle like @Search9
	or
	T2.ClassTitle like @Search10
	or
	isnull(ltrim(rtrim(@ClassFilter)),'') = ''
	)	
) as AverageGrade,
(
case
	-- I commented out the below line as it was showing blank % Score values with it in. 
	-- with it commented out it will still calculate the % Score for all the other records that have a percentage grade
	-- Plus for GPA if already filters out records with no lettergrade so this no works closer to GPA
	-- This edit was made to fix SF ticket #192935. - dp 2/14/2023
	--when count(ClassUnits) != count(All PercentageGrade) then null	
	when sum(ClassUnits) = 0 then convert(decimal(6,2),round((avg(PercentageGrade)),4))
	else convert(decimal(6,2),round((sum(PercentageGrade*ClassUnits) / sum(ClassUnits)),4))
end
) as AveragePercentageGrade,
Sum(ClassUnits),
@TransciptTermCount
From 
Transcript T
Where 	
TermID in (Select IntegerID From SplitCSVIntegers(@TermIDs))
and
case	-- exclude any selected Active terms	
	when @TermType = 'Transcript' then 1
	when @CountTermsActive > 0 and T.TermID not in (Select TermID From @ActiveTermIDs) then 1
	else 0
end = 1
and
ClassTypeID in (1, 2)
and
case
	when @GradeLevel = '0' then 1
	when @FilterByCurrentStudents = 1 and StudentID in (Select StudentID From @CurrentStudents) then 1
	when @FilterByLatestTermStudents = 1 and StudentID in (Select StudentID From @LatestTermStudents) then 1
	when @FilterByCurrentStudents = 0 and @FilterByLatestTermStudents = 0 and isnull(GradeLevel, '0') = @GradeLevel then 1
	else 0
end = 1
and
case
	when @ExcludeLetterGrade = '' or @ExcludeLetterGrade is null then 1
	when T.StudentID not in (Select StudentID From @StudentsWithLowGrades) then 1
	else 0
end = 1	
and
T.LetterGrade is not null
and
(
T.ClassTitle like @Search1
or
T.ClassTitle like @Search2
or
T.ClassTitle like @Search3
or
T.ClassTitle like @Search4
or
T.ClassTitle like @Search5
or
T.ClassTitle like @Search6
or
T.ClassTitle like @Search7
or
T.ClassTitle like @Search8
or
T.ClassTitle like @Search9
or
T.ClassTitle like @Search10
or
isnull(ltrim(rtrim(@ClassFilter)),'') = ''
)
Group By StudentID

Union

Select
		S.StudentID as StudentID,
		S.xStudentID as xStudentID,
		S.glname as Student,
		S.GradeLevel,
		(
		Select
		case
			when sum(C2.Units) = 0 then -1
			else convert(decimal(6,3),round((sum(dbo.getUnitGPA(C2.ClassID, CS2.StudentGrade)) / sum(C2.Units)),4))
		end
		From 	Students S2 
					inner join 
				ClassesStudents CS2
					on S2.StudentID = CS2.StudentID
					inner join 
				Classes C2
					on C2.ClassID = CS2.ClassID
					inner join
				Terms T2
					on C2.TermID = T2.TermID
					inner join
				CustomGradeScale CG2
					on C2.CustomGradeScaleID = CG2.CustomGradeScaleID
		where
				case
					when @GradeLevel = '0' then 1
					when S2.GradeLevel = @GradeLevel then 1
					else 0
				end = 1
				and
				CG2.CalculateGPA = 1
				and
				C2.ClassTypeID in (1,2)
				and 
				S2.StudentID = S.StudentID
				and 
				(CS2.AlternativeGrade is null or CS2.AlternativeGrade = '')
				and
				CS2.StudentGrade is not null
				and
				T2.TermID in (Select IntegerID From SplitCSVIntegers(@TermIDs))	
				and
				case	-- if Active term Selected then query off of this term
					when @TermType = 'Transcript' then 0
					when @CountTermsActive > 0 and T2.TermID in (Select TermID From @ActiveTermIDs) then 1
					else 0
				end = 1	
				and
				C2.NonAcademic = 0		
				and
				(
				C2.ReportTitle like @Search1
				or
				C2.ReportTitle like @Search2
				or
				C2.ReportTitle like @Search3
				or
				C2.ReportTitle like @Search4
				or
				C2.ReportTitle like @Search5
				or
				C2.ReportTitle like @Search6
				or
				C2.ReportTitle like @Search7
				or
				C2.ReportTitle like @Search8
				or
				C2.ReportTitle like @Search9
				or
				C2.ReportTitle like @Search10
				or
				isnull(ltrim(rtrim(@ClassFilter)),'') = ''
				)					
		) as AverageGrade,
		case
			when sum(C.Units) = 0 then convert(decimal(6,2),round((avg(CS.StudentGrade)),4))
			else convert(decimal(6,2),round((sum(CS.StudentGrade*C.Units) / sum(C.Units)),4))
		end as AveragePercentageGrade,
		Sum(C.Units),
		1
From 	Students S 
			inner join 
		ClassesStudents CS
			on S.StudentID = CS.StudentID
			inner join 
		Classes C
			on C.ClassID = CS.ClassID
			inner join
		Terms T
			on C.TermID = T.TermID
			inner join
		CustomGradeScale CG
			on C.CustomGradeScaleID = CG.CustomGradeScaleID
where 	
		CS.StudentGrade is not null
		and 
		case
			when @GradeLevel = '0' then 1
			when S.GradeLevel = @GradeLevel then 1
			else 0
		end = 1
		and
		C.ClassTypeID = 1
		and
		case
			when @ExcludeLetterGrade = '' or @ExcludeLetterGrade is null then 1
			when S.StudentID not in (Select StudentID From @LGStudentID Where GradeOrder >= dbo.GetLowGradeOrder(CustomGradeScaleID, @ExcludeLetterGrade))then 1
			else 0
		end = 1
		and
		case	-- if Active term Selected then query off of this term
			when @TermType = 'Transcript' then 0
			when @CountTermsActive > 0 and T.TermID in (Select TermID From @ActiveTermIDs) then 1
			else 0
		end = 1		
		and
		C.NonAcademic = 0	
		and
		(
		C.ReportTitle like @Search1
		or
		C.ReportTitle like @Search2
		or
		C.ReportTitle like @Search3
		or
		C.ReportTitle like @Search4
		or
		C.ReportTitle like @Search5
		or
		C.ReportTitle like @Search6
		or
		C.ReportTitle like @Search7
		or
		C.ReportTitle like @Search8
		or
		C.ReportTitle like @Search9
		or
		C.ReportTitle like @Search10
		or
		isnull(ltrim(rtrim(@ClassFilter)),'') = ''
		)					
Group By S.StudentID, S.xStudentID, S.glname, S.Lname, S.Fname, S.Mname, S.GradeLevel



Declare @CalculateGPAto3Decimals bit = (Select CalculateGPAto3Decimals From Settings Where SettingID = 1) 


Select 
StudentID,
xStudentID,
Student,
GradeLevel,
case 
	when SUM(ClassUnits) = 0 or Sum(AverageGrade) is null then -1
	when @CalculateGPAto3Decimals = 1 then
		convert(decimal(6,3),round(sum(AverageGrade*ClassUnits) / sum(ClassUnits),4)) 
	else
		convert(decimal(6,2),round(sum(AverageGrade*ClassUnits) / sum(ClassUnits),4)) 
end as AverageGrade,
case 
	when SUM(ClassUnits) = 0 then convert(decimal(6,2),SUM(AveragePercentageGrade*TermCount)/sum(TermCount))
	else
		convert(decimal(6,2),round(
		(sum(AveragePercentageGrade*ClassUnits) / sum(ClassUnits))
		,4)) 
end as AveragePercentageGrade
into #Scores
From #ScoresInit 
Group By StudentID, xStudentID, Student, GradeLevel





Declare @AverageScore decimal(6,2)
Declare @AverageGPA decimal(6,3)

If @Sort = 'GPA'
Begin
	--SET ROWCOUNT @TheCount
	Select top (@TheCount) *
	into #Scores2
	From #Scores
	Where
	case
		when @FactorGPARange = 0 then 1
		when AverageGrade between @StartValue and @EndValue then 1
		else 0
	end = 1		
	Order BY AverageGrade desc, AveragePercentageGrade desc

	Select 
	@AverageGPA = avg(AverageGrade),
	@AverageScore = avg(AveragePercentageGrade)
	From #Scores2
End
Else
Begin
	--SET ROWCOUNT @TheCount
	Select top (@TheCount) *
	into #Scores3
	From #Scores
	Where
	case
		when @FactorGPARange = 0 then 1
		when AverageGrade between @StartValue and @EndValue then 1
		else 0
	end = 1		
	Order BY AveragePercentageGrade desc, AverageGrade desc

	Select
	@AverageGPA = avg(AverageGrade),
	@AverageScore = avg(AveragePercentageGrade)
	From #Scores3
End



if @Sort = 'GPA'
Begin
	if (@ReportType = 'top')
	Begin

		SET ROWCOUNT @TheCount2
		Select 	
			1 as tag,
			Null as parent,
			case @CalculateGPAto3Decimals
				when 1 then convert(nvarchar(10), CONVERT(decimal(6,3), @AverageGPA))
				else convert(nvarchar(10), CONVERT(decimal(6,2), @AverageGPA))
			end as [One!1!AverageGPA],
			@AverageScore as [One!1!AverageScore],			
			@TermTitle as [One!1!TermTitle],
			@Sort as [One!1!Sort],
			@ClassID as [One!1!ClassID],
			@EK as [One!1!EK],
			@ReportType as [One!1!ReportType],
			@TermType as [One!1!TermType],
			@TermIDs as [One!1!TermIDs],
			@GradeLevel as [One!1!GradeLevel],
			@TheCount as [One!1!TheCount],
			@GPAStart as [One!1!GPAStart],
			@GPAEnd as [One!1!GPAEnd],
			@ExcludeLetterGrade as [One!1!ExcludeLetterGrade],
			@ClassFilter as [One!1!ClassFilter],
			datename(month,dbo.GLgetdatetime()) + ' ' + datename(day,dbo.GLgetdatetime()) + ', ' + datename(year,dbo.GLgetdatetime()) As [One!1!TheDate],
			Null as [Two!2!StudentID],
			Null as [Two!2!Student],
			Null as [Two!2!GradeLevel],
			Null as [Two!2!AverageGrade],
			Null as [Two!2!AveragePercentageGrade]

		Union All

		Select 	
			2 as tag,
			1 as parent,
			Null as [One!1!AverageGPA],
			Null as [One!1!AverageScore],			
			Null as [One!1!TermTitle],
			Null as [One!1!Sort],
			Null  as [One!1!ClassID],
			Null  as [One!1!EK],
			Null  as [One!1!ReportType],
			Null as [One!1!TermType],
			Null as [One!1!TermIDs],
			Null  as [One!1!GradeLevel],
			Null  as [One!1!TheCount],
			Null as [One!1!GPAStart],
			Null as [One!1!GPAEnd],
			Null as [One!1!ExcludeLetterGrade],
			Null as [One!1!ClassFilter],		
			Null  As [One!1!TheDate],
			xStudentID as [Two!2!StudentID],
			Student as [Two!2!Student],
			GradeLevel as [Two!2!GradeLevel],
			case @CalculateGPAto3Decimals
				when 1 then convert(nvarchar(10), CONVERT(decimal(6,3), AverageGrade))
				else convert(nvarchar(10), CONVERT(decimal(6,2), AverageGrade))
			end as [Two!2!AverageGrade],
			AveragePercentageGrade as [Two!2!AveragePercentageGrade]
		From #Scores
		where 	
		case
			when @FactorGPARange = 0 then 1
			when AverageGrade between @StartValue and @EndValue then 1
			else 0
		end = 1
		Order BY tag, [Two!2!AverageGrade] desc, [Two!2!AveragePercentageGrade] desc
		FOR XML EXPLICIT

	End
	Else
	Begin

		SET ROWCOUNT @TheCount2
		Select 	
			1 as tag,
			Null as parent,
			case @CalculateGPAto3Decimals
				when 1 then convert(nvarchar(10), CONVERT(decimal(6,3), @AverageGPA))
				else convert(nvarchar(10), CONVERT(decimal(6,2), @AverageGPA))
			end as [One!1!AverageGPA],
			@AverageScore as [One!1!AverageScore],			
			@TermTitle as [One!1!TermTitle],
			@Sort as [One!1!Sort],
			@ClassID as [One!1!ClassID],
			@EK as [One!1!EK],
			@ReportType as [One!1!ReportType],
			@TermType as [One!1!TermType],
			@TermIDs as [One!1!TermIDs],
			@GradeLevel as [One!1!GradeLevel],
			@TheCount as [One!1!TheCount],
			@GPAStart as [One!1!GPAStart],
			@GPAEnd as [One!1!GPAEnd],
			@ExcludeLetterGrade as [One!1!ExcludeLetterGrade],
			@ClassFilter as [One!1!ClassFilter],			
			datename(month,dbo.GLgetdatetime()) + ' ' + datename(day,dbo.GLgetdatetime()) + ', ' + datename(year,dbo.GLgetdatetime()) As [One!1!TheDate],
			Null as [Two!2!StudentID],
			Null as [Two!2!Student],
			Null as [Two!2!GradeLevel],
			Null as [Two!2!AverageGrade],
			Null as [Two!2!AveragePercentageGrade]

		Union All

		Select 	
			2 as tag,
			1 as parent,
			Null as [One!1!AverageGPA],
			Null as [One!1!AverageScore],			
			Null as [One!1!TermTitle],
			Null as [One!1!Sort],
			Null  as [One!1!ClassID],
			Null  as [One!1!EK],
			Null  as [One!1!ReportType],
			Null as [One!1!TermType],
			Null as [One!1!TermIDs],
			Null  as [One!1!GradeLevel],
			Null  as [One!1!TheCount],
			Null as [One!1!GPAStart],
			Null as [One!1!GPAEnd],
			Null as [One!1!ExcludeLetterGrade],
			Null as [One!1!ClassFilter],		
			Null  As [One!1!TheDate],
			xStudentID as [Two!2!StudentID],
			Student as [Two!2!Student],
			GradeLevel as [Two!2!GradeLevel],
			case @CalculateGPAto3Decimals
				when 1 then convert(nvarchar(10), CONVERT(decimal(6,3), AverageGrade))
				else convert(nvarchar(10), CONVERT(decimal(6,2), AverageGrade))
			end as [Two!2!AverageGrade],
			AveragePercentageGrade as [Two!2!AveragePercentageGrade]
		From #Scores
		where 	
		case
			when @FactorGPARange = 0 then 1
			when AverageGrade between @StartValue and @EndValue then 1
			else 0
		end = 1
		Order BY tag, [Two!2!AverageGrade], [Two!2!AveragePercentageGrade]
		FOR XML EXPLICIT

	End

End
Else	-- Sort
Begin

	if (@ReportType = 'top')
	Begin


		SET ROWCOUNT @TheCount2
		Select 	
			1 as tag,
			Null as parent,
			case @CalculateGPAto3Decimals
				when 1 then convert(nvarchar(10), CONVERT(decimal(6,3), @AverageGPA))
				else convert(nvarchar(10), CONVERT(decimal(6,2), @AverageGPA))
			end as [One!1!AverageGPA],
			@AverageScore as [One!1!AverageScore],			
			@TermTitle as [One!1!TermTitle],
			@Sort as [One!1!Sort],
			@ClassID as [One!1!ClassID],
			@EK as [One!1!EK],
			@ReportType as [One!1!ReportType],
			@TermType as [One!1!TermType],
			@TermIDs as [One!1!TermIDs],
			@GradeLevel as [One!1!GradeLevel],
			@TheCount as [One!1!TheCount],
			@GPAStart as [One!1!GPAStart],
			@GPAEnd as [One!1!GPAEnd],
			@ExcludeLetterGrade as [One!1!ExcludeLetterGrade],
			@ClassFilter as [One!1!ClassFilter],		
			datename(month,dbo.GLgetdatetime()) + ' ' + datename(day,dbo.GLgetdatetime()) + ', ' + datename(year,dbo.GLgetdatetime()) As [One!1!TheDate],
			Null as [Two!2!StudentID],
			Null as [Two!2!Student],
			Null as [Two!2!GradeLevel],
			Null as [Two!2!AverageGrade],
			Null as [Two!2!AveragePercentageGrade]

		Union All

		Select 	
			2 as tag,
			1 as parent,
			Null as [One!1!AverageGPA],
			Null as [One!1!AverageScore],			
			Null as [One!1!TermTitle],
			Null as [One!1!Sort],
			Null  as [One!1!ClassID],
			Null  as [One!1!EK],
			Null  as [One!1!ReportType],
			Null as [One!1!TermType],
			Null as [One!1!TermIDs],
			Null  as [One!1!GradeLevel],
			Null  as [One!1!TheCount],
			Null as [One!1!GPAStart],
			Null as [One!1!GPAEnd],
			Null as [One!1!ExcludeLetterGrade],
			Null as [One!1!ClassFilter],		
			Null  As [One!1!TheDate],
			xStudentID as [Two!2!StudentID],
			Student as [Two!2!Student],
			GradeLevel as [Two!2!GradeLevel],
			case @CalculateGPAto3Decimals
				when 1 then convert(nvarchar(10), CONVERT(decimal(6,3), AverageGrade))
				else convert(nvarchar(10), CONVERT(decimal(6,2), AverageGrade))
			end as [Two!2!AverageGrade],
			AveragePercentageGrade as [Two!2!AveragePercentageGrade]
		From #Scores
		where 	
		case
			when @StartValue = -2 and @EndValue = 200 then 1
			when AveragePercentageGrade between @StartValue and @EndValue then 1
			else 0
		end = 1
		Order BY tag, [Two!2!AveragePercentageGrade] desc, [Two!2!AverageGrade] desc
		FOR XML EXPLICIT

	End
	Else
	Begin

		SET ROWCOUNT @TheCount2
		Select 	
			1 as tag,
			Null as parent,
			case @CalculateGPAto3Decimals
				when 1 then convert(nvarchar(10), CONVERT(decimal(6,3), @AverageGPA))
				else convert(nvarchar(10), CONVERT(decimal(6,2), @AverageGPA))
			end as [One!1!AverageGPA],
			@AverageScore as [One!1!AverageScore],			
			@TermTitle as [One!1!TermTitle],
			@Sort as [One!1!Sort],
			@ClassID as [One!1!ClassID],
			@EK as [One!1!EK],
			@ReportType as [One!1!ReportType],
			@TermType as [One!1!TermType],
			@TermIDs as [One!1!TermIDs],
			@GradeLevel as [One!1!GradeLevel],
			@TheCount as [One!1!TheCount],
			@GPAStart as [One!1!GPAStart],
			@GPAEnd as [One!1!GPAEnd],
			@ExcludeLetterGrade as [One!1!ExcludeLetterGrade],
			@ClassFilter as [One!1!ClassFilter],		
			datename(month,dbo.GLgetdatetime()) + ' ' + datename(day,dbo.GLgetdatetime()) + ', ' + datename(year,dbo.GLgetdatetime()) As [One!1!TheDate],
			Null as [Two!2!StudentID],
			Null as [Two!2!Student],
			Null as [Two!2!GradeLevel],
			Null as [Two!2!AverageGrade],
			Null as [Two!2!AveragePercentageGrade]

		Union All

		Select 	
			2 as tag,
			1 as parent,
			Null as [One!1!AverageGPA],
			Null as [One!1!AverageScore],			
			Null as [One!1!TermTitle],
			Null as [One!1!Sort],
			Null  as [One!1!ClassID],
			Null  as [One!1!EK],
			Null  as [One!1!ReportType],
			Null as [One!1!TermType],
			Null as [One!1!TermIDs],
			Null  as [One!1!GradeLevel],
			Null  as [One!1!TheCount],
			Null as [One!1!GPAStart],
			Null as [One!1!GPAEnd],
			Null as [One!1!ExcludeLetterGrade],
			Null as [One!1!ClassFilter],		
			Null  As [One!1!TheDate],
			xStudentID as [Two!2!StudentID],
			Student as [Two!2!Student],
			GradeLevel as [Two!2!GradeLevel],
			case @CalculateGPAto3Decimals
				when 1 then convert(nvarchar(10), CONVERT(decimal(6,3), AverageGrade))
				else convert(nvarchar(10), CONVERT(decimal(6,2), AverageGrade))
			end as [Two!2!AverageGrade],
			AveragePercentageGrade as [Two!2!AveragePercentageGrade]
		From #Scores
		where 	
		case
			when @StartValue = -2 and @EndValue = 200 then 1
			when AveragePercentageGrade between @StartValue and @EndValue then 1
			else 0
		end = 1
		Order BY tag, [Two!2!AveragePercentageGrade], [Two!2!AverageGrade]
		FOR XML EXPLICIT

	End



End



Create table #IncludedClasses (ClassTitle nvarchar(100))

SET ROWCOUNT 0


Insert into #IncludedClasses
Select distinct
T.ClassTitle	
From 
Transcript T
Where 	
TermID in (Select IntegerID From SplitCSVIntegers(@TermIDs))
and
ClassTypeID in (1, 2)
and
case
	when @GradeLevel = '0' then 1
	when @FilterByCurrentStudents = 1 and StudentID in (Select StudentID From @CurrentStudents) then 1
	when @FilterByLatestTermStudents = 1 and StudentID in (Select StudentID From @LatestTermStudents) then 1
	when @FilterByCurrentStudents = 0 and @FilterByLatestTermStudents = 0 and isnull(GradeLevel, '0') = @GradeLevel then 1
	else 0
end = 1
and
(
T.ClassTitle like @Search1
or
T.ClassTitle like @Search2
or
T.ClassTitle like @Search3
or
T.ClassTitle like @Search4
or
T.ClassTitle like @Search5
or
T.ClassTitle like @Search6
or
T.ClassTitle like @Search7
or
T.ClassTitle like @Search8
or
T.ClassTitle like @Search9
or
T.ClassTitle like @Search10
or
isnull(ltrim(rtrim(@ClassFilter)),'') = ''
)	

Union

Select distinct C.ReportTitle as ClassTitle
From 	Students S 
			inner join 
		ClassesStudents CS
			on S.StudentID = CS.StudentID
			inner join 
		Classes C
			on C.ClassID = CS.ClassID
			inner join
		Terms T
			on C.TermID = T.TermID
where 	
case
	when @GradeLevel = '0' then 1
	when S.GradeLevel = @GradeLevel then 1
	else 0
end = 1
and
ClassTypeID = 1
and
T.TermID in (Select IntegerID From SplitCSVIntegers(@TermIDs))
and
C.NonAcademic = 0	
and
(
C.ReportTitle like @Search1
or
C.ReportTitle like @Search2
or
C.ReportTitle like @Search3
or
C.ReportTitle like @Search4
or
C.ReportTitle like @Search5
or
C.ReportTitle like @Search6
or
C.ReportTitle like @Search7
or
C.ReportTitle like @Search8
or
C.ReportTitle like @Search9
or
C.ReportTitle like @Search10
or
isnull(ltrim(rtrim(@ClassFilter)),'') = ''
)


Select ClassTitle
From #IncludedClasses
Order By 1
FOR XML RAW



set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON


/****** Object:  StoredProcedure [dbo].[TopGrades]    Script Date: 06/02/2008 23:26:58 ******/
SET ANSI_NULLS ON



Drop table #tmpTerms
Drop table #Scores
Drop table #Scores2
--Drop table #Scores3
Drop table #ScoresInit
Drop table #IncludedClasses
GO
