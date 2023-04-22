SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[getGradeScaleLegend]
(
@StudentID int,
@TermID int
)
RETURNS nchar(2000)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @GradeScaleLegend nvarchar(2000)

	-- Add the T-SQL statements to compute the return value here

Declare @GradeScaleLegends as table (GS nvarchar(2000))

Set @GradeScaleLegend = ' '
Declare 
@GradeSymbol nvarchar(120),
@GradeDescription nvarchar(100),
@PreviousGradeScaleLowPercentage int,
@GradeScaleLowPercentage int,
@GradeOrder int,
@GradeID int,
@CGID int,
@ShowPercentage bit,
@TopGradeID int

Declare @tmpCustomGradeScaleGrades table
(
GradeID int identity,
GradeSymbol nvarchar(120),
GradeDescription nvarchar(100),
LowPercentage decimal (5,2),
GradeOrder int
)

Declare @tmpCustomGradeScales table (CGID int, ShowPercentage bit, CGOrder int)


Insert into @tmpCustomGradeScales
Select 
C.CustomGradeScaleID,
ShowPercentageGrade,
COUNT(*) as TheCount
From 
Classes C
	inner join
ClassesStudents CS
	on C.ClassID = CS.ClassID
	inner join
CustomGradeScale CG
	on C.CustomGradeScaleID = CG.CustomGradeScaleID
Where
CS.StudentID = @StudentID
and
C.TermID = @TermID
and
C.ClassTypeID in (1,2)
and
C.NonAcademic = 0
group by C.CustomGradeScaleID, CG.ShowPercentageGrade
Order By TheCount desc


while exists(Select * From @tmpCustomGradeScales)
Begin

	Select top 1 
	@CGID = CGID,
	@ShowPercentage = ShowPercentage
	From @tmpCustomGradeScales

	Insert into @tmpCustomGradeScaleGrades
	Select 
	GradeSymbol, 
	GradeDescription,
	ceiling(LowPercentage) as LowPercentage, 
	GradeOrder
	from CustomGradeScaleGrades
	Where CustomGradeScaleID = @CGID
	Order By GradeOrder
	
	Set @TopGradeID = (Select top 1 GradeID From @tmpCustomGradeScaleGrades)



	While exists(Select * From @tmpCustomGradeScaleGrades)
	Begin

		Select top 1
		@GradeID = GradeID,
		@GradeSymbol = 
		case 
			when GradeSymbol = 'ch' then '<img src="../../images/checkMarkAlpha.gif" width="14" height="13"/>'
			else GradeSymbol
		end,
		@GradeDescription = GradeDescription,
		@GradeOrder = GradeOrder,
		@GradeScaleLowPercentage = LowPercentage
		From @tmpCustomGradeScaleGrades
		

		If @ShowPercentage = 0
		Begin
			Set @GradeScaleLegend = @GradeScaleLegend + '<span style="white-space:nowrap">' + @GradeSymbol + '=(' + @GradeDescription + ')</span>  '
		End
		Else
		Begin

			If @GradeID = @TopGradeID
			Begin
				Set @GradeScaleLegend = @GradeScaleLegend + '<span style="white-space:nowrap">' + @GradeSymbol + '=(' + convert(nvarchar(3),@GradeScaleLowPercentage) + '-100)</span>  '
			End
			Else
			Begin
				Set @GradeScaleLegend = @GradeScaleLegend + '<span style="white-space:nowrap">' + @GradeSymbol + '=(' + convert(nvarchar(3),@GradeScaleLowPercentage) + '-'+ convert(nvarchar(3),@PreviousGradeScaleLowPercentage) + ')</span>  '
			End

			Set @PreviousGradeScaleLowPercentage = @GradeScaleLowPercentage - 1

		End

		Delete From @tmpCustomGradeScaleGrades Where GradeID = @GradeID

	End	-- While Loop

	insert into @GradeScaleLegends
	Select @GradeScaleLegend
	
	Set @GradeScaleLegend = ' '

	Delete From @tmpCustomGradeScales Where CGID = @CGID

End -- GradeScale While Loop


	Set @GradeScaleLegend = ''
	
	Select
	@GradeScaleLegend = @GradeScaleLegend + GS
	From
	@GradeScaleLegends
	Group By GS
	
	-- Return the result of the function
	Return @GradeScaleLegend


END

GO
