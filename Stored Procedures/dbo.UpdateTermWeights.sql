SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/**********************************************************************/
CREATE Procedure [dbo].[UpdateTermWeights]
@ParentTermID int
As

Declare 
@TermWeight dec(5,2),
@SubTermCount dec(5,2),
@ExamTermCount int,
@ExamTermWeight int

Set @SubTermCount = (Select count(*) From Terms Where ParentTermID = @ParentTermID)
Set @ExamTermCount = (Select count(*) From Terms Where ParentTermID = @ParentTermID and ExamTerm = 1)

If @SubTermCount > 1
Begin
	If @ExamTermCount > 0
	Begin
		Set @ExamTermWeight = (Select TermWeight From Terms Where ParentTermID = @ParentTermID and ExamTerm = 1)
		Set @TermWeight = (100 - @ExamTermWeight) / (@SubTermCount - 1)

		Update Terms
		Set TermWeight =  @TermWeight
		Where ParentTermID = @ParentTermID and ExamTerm = 0
	End
	Else
	Begin
		Set @TermWeight = 100 / @SubTermCount

		Update Terms
		Set TermWeight =  @TermWeight
		Where ParentTermID = @ParentTermID
	End
End
Else if @ExamTermCount = 0
Begin
	if @ParentTermID = 0
	Begin
	  Set @TermWeight = -1
	End
	Else
	Begin
	  Set @TermWeight = 100
	End

	Update Terms
	Set TermWeight =  @TermWeight
	Where ParentTermID = @ParentTermID
End


/**********************************************************************/
SET QUOTED_IDENTIFIER ON 

GO
