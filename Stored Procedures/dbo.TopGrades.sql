SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[TopGrades] 
@GradeLevel nvarchar(20), 
@ReportType nvarchar(6), 
@TermType nvarchar(15), 
@TermIDs nvarchar(100),
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

-- Set Starting Values to encompass all GPA values enacase they
-- leave one field blank.
Select
@StartValue = -2,
@EndValue = 200


If @GPAStart != ''
Begin
	Set @StartValue = convert(decimal(5,2), @GPAStart)
End

If @GPAEnd != ''
Begin
	Set @EndValue = convert(decimal(5,2), @GPAEnd)
End


Declare @TheCount2 int
Declare @TermTitle nvarchar(100)
Declare @TermID int


Set @TheCount2 = @TheCount + 1
Set @TermID = (Select top 1 IntegerID From SplitCSVIntegers(@TermIDs))
Set @TermTitle = (Select TermTitle From Terms Where TermID = @TermID) + ' (Active)'



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

Set @Search1 = (Select top 1 SearchValue From @SearchStringTable)
Delete From @SearchStringTable Where SearchValue = @Search1
Set @Search1 = '%' + @Search1 + '%'
Set @Search2 = (Select top 1 SearchValue From @SearchStringTable)
Delete From @SearchStringTable Where SearchValue = @Search2
Set @Search2 = '%' + @Search2 + '%'
Set @Search3 = (Select top 1 SearchValue From @SearchStringTable)
Delete From @SearchStringTable Where SearchValue = @Search3
Set @Search3 = '%' + @Search3 + '%'
Set @Search4 = (Select top 1 SearchValue From @SearchStringTable)
Delete From @SearchStringTable Where SearchValue = @Search4
Set @Search4 = '%' + @Search4 + '%'
Set @Search5 = (Select top 1 SearchValue From @SearchStringTable)
Delete From @SearchStringTable Where SearchValue = @Search5
Set @Search5 = '%' + @Search5 + '%'
Set @Search6 = (Select top 1 SearchValue From @SearchStringTable)
Delete From @SearchStringTable Where SearchValue = @Search6
Set @Search6 = '%' + @Search6 + '%'
Set @Search7 = (Select top 1 SearchValue From @SearchStringTable)
Delete From @SearchStringTable Where SearchValue = @Search7
Set @Search7 = '%' + @Search7 + '%'
Set @Search8 = (Select top 1 SearchValue From @SearchStringTable)
Delete From @SearchStringTable Where SearchValue = @Search8
Set @Search8 = '%' + @Search8 + '%'
Set @Search9 = (Select top 1 SearchValue From @SearchStringTable)
Delete From @SearchStringTable Where SearchValue = @Search9
Set @Search9 = '%' + @Search9 + '%'
Set @Search10 = (Select top 1 SearchValue From @SearchStringTable)
Delete From @SearchStringTable Where SearchValue = @Search10
Set @Search10 = '%' + @Search10 + '%'


Select
		S.StudentID as StudentID,
		S.xStudentID as xStudentID,
		S.glname as Student,
		S.GradeLevel,
		(
		Select
		case
			when sum(C2.Units) = 0 then -1
			else convert(decimal(6,2),round((sum(dbo.getUnitGPA(C2.ClassID, CS2.StudentGrade)) / sum(C2.Units)),4))
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
		end as AveragePercentageGrade
into #Scores		
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
		
		
		
		
				
		
			
Group By S.StudentID, S.xStudentID, S.glname, S.GradeLevel


Declare @AverageScore decimal(6,2)
Declare @AverageGPA decimal(6,2)


SET ROWCOUNT @TheCount
Select *
into #Scores2
From #Scores
Order BY AverageGrade desc, AveragePercentageGrade desc




Select
@AverageGPA = avg(AverageGrade),
@AverageScore = avg(AveragePercentageGrade)
From #Scores2


if @Sort = 'GPA'
Begin
	if (@ReportType = 'top')
	Begin

		SET ROWCOUNT @TheCount2
		Select 	
			1 as tag,
			Null as parent,
			@AverageGPA as [One!1!AverageGPA],
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
			AverageGrade as [Two!2!AverageGrade],
			AveragePercentageGrade as [Two!2!AveragePercentageGrade]
		From #Scores
		Where
		case
			when @StartValue = -2 and @EndValue = 200 then 1
			when AverageGrade between @StartValue and @EndValue then 1
			else 0
		end = 1
 
		Order BY tag, [Two!2!AverageGrade] desc, [Two!2!AveragePercentageGrade] desc
		FOR XML EXPLICIT

	End
	Else
	Begin

		SET ROWCOUNT @TheCount2
		Select 	1 as tag,
				Null as parent,
				@AverageGPA as [One!1!AverageGPA],
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
			AverageGrade as [Two!2!AverageGrade],
			AveragePercentageGrade as [Two!2!AveragePercentageGrade]
		From #Scores
		Where 	
		case
			when @StartValue = -2 and @EndValue = 200 then 1
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
		Select 	1 as tag,
				Null as parent,
				@AverageGPA as [One!1!AverageGPA],
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
			AverageGrade as [Two!2!AverageGrade],
			AveragePercentageGrade as [Two!2!AveragePercentageGrade]
		From #Scores
		Where 	
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
		Select 	1 as tag,
				Null as parent,
				@AverageGPA as [One!1!AverageGPA],
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
			AverageGrade as [Two!2!AverageGrade],
			AveragePercentageGrade as [Two!2!AveragePercentageGrade]
		From #Scores
		Where 	
		case
			when @StartValue = -2 and @EndValue = 200 then 1
			when AveragePercentageGrade between @StartValue and @EndValue then 1
			else 0
		end = 1
		Order BY tag, [Two!2!AveragePercentageGrade], [Two!2!AverageGrade]
		FOR XML EXPLICIT

	End

End

drop table #Scores


SET ROWCOUNT 0
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
Order By 1
FOR XML RAW


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

GO
