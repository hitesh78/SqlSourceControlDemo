SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 2016-08-22
-- Description:	Find classes with missing LP Colors or LP Periods and Populate them
-- =============================================
CREATE Procedure [dbo].[AddLPColorsAndPeriods]
As
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	-- Set Class Colors and Schedule
	Declare @LPColors table (colorNumID int identity(1,1), ColorOrder int, Color nvarchar(20))

	Insert into @LPColors
	Select 1,'Emerald' Union
	Select 2,'Aquamarine' Union
	Select 3,'Sapphire' Union
	Select 4,'Amethyst' Union
	Select 5,'SatinLace' Union
	Select 6,'Ruby' Union
	Select 7,'Sunset' Union
	Select 8,'Goldbar' Union
	Select 9,'Chocolate' Union
	Select 10,'Magnesium'
	Declare @LPColorCount int = @@RowCount

	Declare @Terms table (termNumID int identity(1,1),TermID int)
	Insert into @Terms
	Select TermID From Terms
	Declare @TermCount int = @@RowCount


	Declare @Teachers table (teacherNumID int identity(1,1),TeacherID int)
	Insert into @Teachers
	Select TeacherID From Teachers Where StaffType = 1
	Declare @TeacherCount int = @@RowCount


	Declare @Classes table (classNumID int, ClassID int)
	Declare @BlankClasses table (classNumID int identity(1,1),ClassID int)
	Declare @ClassCount int
	Declare @colorLineNumber int = 1
	Declare @termLineNumber int = 1
	Declare @teacherLineNumber int = 1
	Declare @classLineNumber int = 1
	Declare @TermID int
	Declare @TeacherID int
	Declare @ClassID int
	Declare @LPColor nvarchar(20)

	While @termLineNumber <= @TermCount
	Begin

		Set @TermID = (Select TermID From @Terms Where termNumID = @termLineNumber) 

		While @teacherLineNumber <= @TeacherCount
		Begin
			Set @TeacherID = (Select TeacherID From @Teachers Where teacherNumID = @teacherLineNumber)

			Insert into @Classes
			Select row_number() OVER (ORDER BY ClassID), ClassID 
			From Classes 
			Where 
			TermID = @TermID
			and
			TeacherID = @TeacherID
			and
			ClassTypeID in (1,8)
			and
			ClassID in 
			(
				Select ClassID From Classes 
				Where
				isnull(ltrim(rtrim(LPClassColor)),'') = ''
				and
				ClassTypeID in (1,8)
				and
				ClassTitle != 'InitClass'
				and
				TermID in
				(
				Select TermID From Terms
				Where
				EndDate > '2016-07-01'
				and
				ParentClassID = 0
				)		
			)
			Order By ClassTitle
			Set @ClassCount = @@RowCount
			
			--select 
			--@TermID as whileTermID,
			--@TeacherID as whileTeacherID,
			--@classLineNumber as whileclassLineNumber,
			--@ClassCount as WhileClassCount
			
			While @classLineNumber <= @ClassCount
			Begin
				--Select * From @Classes

				Set @ClassID = (Select ClassID From @Classes Where classNumID = @classLineNumber)
				Set @LPColor = (Select Color From @LPColors Where colorNumID = @colorLineNumber)	
					
				Update Classes
				Set 
				LPClassColor = @LPColor,
				PeriodOnSunday = case 
									when (Select AttSunday From Settings Where SettingID = 1) = 0 then 0
									else Period 
								 end,
				PeriodOnMonday = case 
									when (Select AttMonday From Settings Where SettingID = 1) = 0 then 0
									else Period 
								 end,
				PeriodOnTuesday = case 
									when (Select AttTuesday From Settings Where SettingID = 1) = 0 then 0
									else Period 
								  end,
				PeriodOnWednesday = case 
										when (Select AttWednesday From Settings Where SettingID = 1) = 0 then 0
										else Period 
									end,
				PeriodOnThursday = case 
									when (Select AttThursday From Settings Where SettingID = 1) = 0 then 0
									else Period 
								   end,
				PeriodOnFriday = case 
									when (Select AttFriday From Settings Where SettingID = 1) = 0 then 0
									else Period 
								 end,
				PeriodOnSaturday = 	case 
										when (Select AttSaturday From Settings Where SettingID = 1) = 0 then 0
										else Period 
									end,
				BPeriodOnSunday = case 
									when (Select AttSunday From Settings Where SettingID = 1) = 0 then 0
									else Period 
								 end,
				BPeriodOnMonday = case 
									when (Select AttMonday From Settings Where SettingID = 1) = 0 then 0
									else Period 
								 end,
				BPeriodOnTuesday = case 
									when (Select AttTuesday From Settings Where SettingID = 1) = 0 then 0
									else Period 
								  end,
				BPeriodOnWednesday = case 
										when (Select AttWednesday From Settings Where SettingID = 1) = 0 then 0
										else Period 
									end,
				BPeriodOnThursday = case 
									when (Select AttThursday From Settings Where SettingID = 1) = 0 then 0
									else Period 
								   end,
				BPeriodOnFriday = case 
									when (Select AttFriday From Settings Where SettingID = 1) = 0 then 0
									else Period 
								 end,
				BPeriodOnSaturday = case 
										when (Select AttSaturday From Settings Where SettingID = 1) = 0 then 0
										else Period 
									end			
				Where
				ClassID = @ClassID 

				--Select 
				--@classLineNumber as varclassLineNumber,
				--@ClassID as varClassID

				
				--Select 
				--TermID,
				--ClassID,
				--ClassTitle,
				--@LPColor as LPColor
				--From
				--Classes Where ClassID = @ClassID
				

				Set @classLineNumber = @classLineNumber + 1
				Set @colorLineNumber = @colorLineNumber + 1
				if @colorLineNumber = 11 Set @colorLineNumber = 1

			End 
			
			Delete From @Classes
			Set @classLineNumber = 1
			Set @colorLineNumber = 1
			Set @ClassCount = 0
			

			Set @teacherLineNumber = @teacherLineNumber + 1

		End
		Set @termLineNumber = @termLineNumber + 1
		Set @teacherLineNumber = 1

	End

END

GO
