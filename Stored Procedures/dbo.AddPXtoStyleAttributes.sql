SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* 
=============================================
-- Author:		Don Puls
-- Create date: 8/30/2013
-- Description:	
Adds px to the following style attributes: top, left, width, height
Ignores attributes that already contain px
Corrects hieght misspellings
collapse white space around certain characters such as : and ;
=============================================
*/
CREATE Procedure [dbo].[AddPXtoStyleAttributes] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


Declare @temp table(ID int identity(1,1), GradeID int)

Insert into @temp
Select
ProfileID
FROM 
ReportProfiles
WHERE 
ReportName = 'ProgressReport'

Declare @NumLines int = @@RowCount
Declare @LineNumber int = 1
Declare @ProfileID int

Declare @SSP int -- Starting Search Position
Declare @Iteration int
Declare @AttributeCount int

While @LineNumber <= @NumLines  -- Loop through each ProfileID
Begin

	Set @ProfileID = (Select GradeID From @temp Where ID = @LineNumber) 
	
	----------------------
	-- Remove Spacing
	----------------------
	UPDATE ReportHTML
	Set HTML = REPLACE(HTML, ': ', ':')
	Where ProfileID = @ProfileID
	
	UPDATE ReportHTML
	Set HTML = REPLACE(HTML, ' :', ':')
	Where ProfileID = @ProfileID	
	
	UPDATE ReportHTML
	Set HTML = REPLACE(HTML, ' ;', ';')
	Where ProfileID = @ProfileID	

	UPDATE ReportHTML
	Set HTML = REPLACE(HTML, ' ''', '''')
	Where ProfileID = @ProfileID
	
	UPDATE ReportHTML
	Set HTML = REPLACE(HTML, ' "', '"')
	Where ProfileID = @ProfileID		
	----------------------
	
	
	
	-------------------------------------------
	-- Add px to all the "top" style attributes
	-------------------------------------------
	-- Check values ending with ; character
	Set @SSP = 
	(
	Select
	CharIndex('top:', HTML, 0)
	FROM 
	ReportHTML
	Where 
	ProfileID = @ProfileID
	)		
	if exists (Select HTML From ReportHTML Where ProfileID = @ProfileID and HTML like '%;%')	
	Begin
		Set @Iteration = 1
		Set @AttributeCount = 
		(
			select 
			(len(HTML)-len(replace(HTML,'top:',''))) /LEN('top:')
			FROM 
			ReportHTML
			Where 
			ProfileID = @ProfileID
		)	
		while (@Iteration <= @AttributeCount and @AttributeCount > 0)
		Begin
			if
			(
				Select
				ISNUMERIC(
					substring(
						HTML, 
						CharIndex('top:', HTML, @SSP) + 4,
						case 
							when CharIndex(';', HTML, CharIndex('top:', HTML, @SSP) + 4 ) - (CharIndex('top:', HTML, @SSP) + 4) < 1 then 0
							else CharIndex(';', HTML, CharIndex('top:', HTML, @SSP) + 4 ) - (CharIndex('top:', HTML, @SSP) + 4)  
						end
					)
				) as DimensionValueIsNUmeric
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			) = 1
			Begin
				
				UPDATE ReportHTML
				Set HTML =
					STUFF(
					HTML, 
					CharIndex(';', HTML, CharIndex('top:', HTML, @SSP)),
					0,
					'px')
				Where ProfileID = @ProfileID
				
				Set @SSP = 
				(
				Select
				CharIndex('top:', HTML) + 8
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
				)
				
			End
				
			Set @SSP = 
			(
				Select
				CharIndex('top:', HTML, @SSP + 8)
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			)									
			
			Set @Iteration = @Iteration + 1
		
		End -- While Loop	
	End -- IF Statement

	-- Check values ending with " character
	Set @SSP = 
	(
	Select
	CharIndex('top:', HTML, 0)
	FROM 
	ReportHTML
	Where 
	ProfileID = @ProfileID
	)		
	if exists (Select HTML From ReportHTML Where ProfileID = @ProfileID and HTML like '%style="%')	
	Begin
		Set @Iteration = 1
		Set @AttributeCount = 
		(
			select 
			(len(HTML)-len(replace(HTML,'top:',''))) /LEN('top:')
			FROM 
			ReportHTML
			Where 
			ProfileID = @ProfileID
		)	
		while (@Iteration <= @AttributeCount and @AttributeCount > 0)
		Begin
			if
			(
				Select
				ISNUMERIC(
					substring(
						HTML, 
						CharIndex('top:', HTML, @SSP) + 4,
						case 
							when CharIndex('"', HTML, CharIndex('top:', HTML, @SSP) + 4 ) - (CharIndex('top:', HTML, @SSP) + 4) < 1 then 0
							else CharIndex('"', HTML, CharIndex('top:', HTML, @SSP) + 4 ) - (CharIndex('top:', HTML, @SSP) + 4)  
						end
					)
				) as DimensionValueIsNUmeric
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			) = 1
			Begin
				
				UPDATE ReportHTML
				Set HTML =
					STUFF(
					HTML, 
					CharIndex('"', HTML, CharIndex('top:', HTML, @SSP)),
					0,
					'px')
				Where ProfileID = @ProfileID
				
				Set @SSP = 
				(
				Select
				CharIndex('top:', HTML) + 8
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
				)
				
			End
				
			Set @SSP = 
			(
				Select
				CharIndex('top:', HTML, @SSP + 8)
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			)									
			
			Set @Iteration = @Iteration + 1
		
		End -- While Loop	
	End -- IF Statement
	
	-- Check values ending with ' character
	Set @SSP = 0; 
	if exists (Select HTML From ReportHTML Where ProfileID = @ProfileID and HTML like '%style=''%')
	
	
	-- Check values ending with ; character
	Set @SSP = 
	(
	Select
	CharIndex('top:', HTML, 0)
	FROM 
	ReportHTML
	Where 
	ProfileID = @ProfileID
	)		
	if exists (Select HTML From ReportHTML Where ProfileID = @ProfileID and HTML like '%style=''%')	
	Begin
		Set @Iteration = 1
		Set @AttributeCount = 
		(
			select 
			(len(HTML)-len(replace(HTML,'top:',''))) /LEN('top:')
			FROM 
			ReportHTML
			Where 
			ProfileID = @ProfileID
		)	
		while (@Iteration <= @AttributeCount and @AttributeCount > 0)
		Begin
			if
			(
				Select
				ISNUMERIC(
					substring(
						HTML, 
						CharIndex('top:', HTML, @SSP) + 4,
						case 
							when CharIndex(CHAR(39), HTML, CharIndex('top:', HTML, @SSP) + 4 ) - (CharIndex('top:', HTML, @SSP) + 4) < 1 then 0
							else CharIndex(CHAR(39), HTML, CharIndex('top:', HTML, @SSP) + 4 ) - (CharIndex('top:', HTML, @SSP) + 4)  
						end
					)
				) as DimensionValueIsNUmeric
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			) = 1
			Begin
				
				UPDATE ReportHTML
				Set HTML =
					STUFF(
					HTML, 
					CharIndex(CHAR(39), HTML, CharIndex('top:', HTML, @SSP)),
					0,
					'px')
				Where ProfileID = @ProfileID
				
				Set @SSP = 
				(
				Select
				CharIndex('top:', HTML) + 8
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
				)
				
			End
				
			Set @SSP = 
			(
				Select
				CharIndex('top:', HTML, @SSP + 8)
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			)									
			
			Set @Iteration = @Iteration + 1
		
		End -- While Loop	
	End -- IF Statement


	---------------------------------------------
	-- Add px to all the "left" style attributes
	---------------------------------------------
	-- Check values ending with ; character
	Set @SSP = 
	(
	Select
	CharIndex('left:', HTML, 0)
	FROM 
	ReportHTML
	Where 
	ProfileID = @ProfileID
	)		
	if exists (Select HTML From ReportHTML Where ProfileID = @ProfileID and HTML like '%;%')	
	Begin
		Set @Iteration = 1
		Set @AttributeCount = 
		(
			select 
			(len(HTML)-len(replace(HTML,'left:',''))) /LEN('left:')
			FROM 
			ReportHTML
			Where 
			ProfileID = @ProfileID
		)	
		while (@Iteration <= @AttributeCount and @AttributeCount > 0)
		Begin
			if
			(
				Select
				ISNUMERIC(
					substring(
						HTML, 
						CharIndex('left:', HTML, @SSP) + 5,
						case 
							when CharIndex(';', HTML, CharIndex('left:', HTML, @SSP) + 5 ) - (CharIndex('left:', HTML, @SSP) + 5) < 1 then 0
							else CharIndex(';', HTML, CharIndex('left:', HTML, @SSP) + 5 ) - (CharIndex('left:', HTML, @SSP) + 5)  
						end
					)
				) as DimensionValueIsNUmeric
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			) = 1
			Begin
				
				UPDATE ReportHTML
				Set HTML =
					STUFF(
					HTML, 
					CharIndex(';', HTML, CharIndex('left:', HTML, @SSP)),
					0,
					'px')
				Where ProfileID = @ProfileID
				
				Set @SSP = 
				(
				Select
				CharIndex('left:', HTML) + 8
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
				)
				
			End
				
			Set @SSP = 
			(
				Select
				CharIndex('left:', HTML, @SSP + 8)
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			)									
			
			Set @Iteration = @Iteration + 1
		
		End -- While Loop	
	End -- IF Statement

	-- Check values ending with " character
	Set @SSP = 
	(
	Select
	CharIndex('left:', HTML, 0)
	FROM 
	ReportHTML
	Where 
	ProfileID = @ProfileID
	)		
	if exists (Select HTML From ReportHTML Where ProfileID = @ProfileID and HTML like '%style="%')	
	Begin
		Set @Iteration = 1
		Set @AttributeCount = 
		(
			select 
			(len(HTML)-len(replace(HTML,'left:',''))) /LEN('left:')
			FROM 
			ReportHTML
			Where 
			ProfileID = @ProfileID
		)	
		while (@Iteration <= @AttributeCount and @AttributeCount > 0)
		Begin
			if
			(
				Select
				ISNUMERIC(
					substring(
						HTML, 
						CharIndex('left:', HTML, @SSP) + 5,
						case 
							when CharIndex('"', HTML, CharIndex('left:', HTML, @SSP) + 5 ) - (CharIndex('left:', HTML, @SSP) + 5) < 1 then 0
							else CharIndex('"', HTML, CharIndex('left:', HTML, @SSP) + 5 ) - (CharIndex('left:', HTML, @SSP) + 5)  
						end
					)
				) as DimensionValueIsNUmeric
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			) = 1
			Begin
				
				UPDATE ReportHTML
				Set HTML =
					STUFF(
					HTML, 
					CharIndex('"', HTML, CharIndex('left:', HTML, @SSP)),
					0,
					'px')
				Where ProfileID = @ProfileID
				
				Set @SSP = 
				(
				Select
				CharIndex('left:', HTML) + 8
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
				)
				
			End
				
			Set @SSP = 
			(
				Select
				CharIndex('left:', HTML, @SSP + 8)
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			)									
			
			Set @Iteration = @Iteration + 1
		
		End -- While Loop	
	End -- IF Statement


	-- Check values ending with ' character
	Set @SSP = 
	(
	Select
	CharIndex('left:', HTML, 0)
	FROM 
	ReportHTML
	Where 
	ProfileID = @ProfileID
	)		
	if exists (Select HTML From ReportHTML Where ProfileID = @ProfileID and HTML like '%style=''%')	
	Begin
		Set @Iteration = 1
		Set @AttributeCount = 
		(
			select 
			(len(HTML)-len(replace(HTML,'left:',''))) /LEN('left:')
			FROM 
			ReportHTML
			Where 
			ProfileID = @ProfileID
		)	
		while (@Iteration <= @AttributeCount and @AttributeCount > 0)
		Begin
			if
			(
				Select
				ISNUMERIC(
					substring(
						HTML, 
						CharIndex('left:', HTML, @SSP) + 5,
						case 
							when CharIndex(CHAR(39), HTML, CharIndex('left:', HTML, @SSP) + 5 ) - (CharIndex('left:', HTML, @SSP) + 5) < 1 then 0
							else CharIndex(CHAR(39), HTML, CharIndex('left:', HTML, @SSP) + 5 ) - (CharIndex('left:', HTML, @SSP) + 5)  
						end
					)
				) as DimensionValueIsNUmeric
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			) = 1
			Begin
				
				UPDATE ReportHTML
				Set HTML =
					STUFF(
					HTML, 
					CharIndex(CHAR(39), HTML, CharIndex('left:', HTML, @SSP)),
					0,
					'px')
				Where ProfileID = @ProfileID
				
				Set @SSP = 
				(
				Select
				CharIndex('left:', HTML) + 8
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
				)
				
			End
				
			Set @SSP = 
			(
				Select
				CharIndex('left:', HTML, @SSP + 8)
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			)									
			
			Set @Iteration = @Iteration + 1
		
		End -- While Loop	
	End -- IF Statement	
	
	
	-----------------------------------------------
	---- Add px to all the "width" style attributes
	-----------------------------------------------
	
	-- Check values ending with ; character
	Set @SSP = 
	(
	Select
	CharIndex('width:', HTML, 0)
	FROM 
	ReportHTML
	Where 
	ProfileID = @ProfileID
	)		
	if exists (Select HTML From ReportHTML Where ProfileID = @ProfileID and HTML like '%;%')	
	Begin
		Set @Iteration = 1
		Set @AttributeCount = 
		(
			select 
			(len(HTML)-len(replace(HTML,'width:',''))) /LEN('width:')
			FROM 
			ReportHTML
			Where 
			ProfileID = @ProfileID
		)	
		while (@Iteration <= @AttributeCount and @AttributeCount > 0)
		Begin
			if
			(
				Select
				ISNUMERIC(
					substring(
						HTML, 
						CharIndex('width:', HTML, @SSP) + 6,
						case 
							when CharIndex(';', HTML, CharIndex('width:', HTML, @SSP) + 6 ) - (CharIndex('width:', HTML, @SSP) + 6) < 1 then 0
							else CharIndex(';', HTML, CharIndex('width:', HTML, @SSP) + 6 ) - (CharIndex('width:', HTML, @SSP) + 6)  
						end
					)
				) as DimensionValueIsNUmeric
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			) = 1
			Begin
				
				UPDATE ReportHTML
				Set HTML =
					STUFF(
					HTML, 
					CharIndex(';', HTML, CharIndex('width:', HTML, @SSP)),
					0,
					'px')
				Where ProfileID = @ProfileID
				
				Set @SSP = 
				(
				Select
				CharIndex('width:', HTML) + 8
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
				)
				
			End
				
			Set @SSP = 
			(
				Select
				CharIndex('width:', HTML, @SSP + 8)
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			)									
			
			Set @Iteration = @Iteration + 1
		
		End -- While Loop	
	End -- IF Statement
	
	-- Check values ending with " character
	Set @SSP = 
	(
	Select
	CharIndex('width:', HTML, 0)
	FROM 
	ReportHTML
	Where 
	ProfileID = @ProfileID
	)		
	if exists (Select HTML From ReportHTML Where ProfileID = @ProfileID and HTML like '%style="%')	
	Begin
		Set @Iteration = 1
		Set @AttributeCount = 
		(
			select 
			(len(HTML)-len(replace(HTML,'width:',''))) /LEN('width:')
			FROM 
			ReportHTML
			Where 
			ProfileID = @ProfileID
		)	
		while (@Iteration <= @AttributeCount and @AttributeCount > 0)
		Begin
			if
			(
				Select
				ISNUMERIC(
					substring(
						HTML, 
						CharIndex('width:', HTML, @SSP) + 6,
						case 
							when CharIndex('"', HTML, CharIndex('width:', HTML, @SSP) + 6 ) - (CharIndex('width:', HTML, @SSP) + 6) < 1 then 0
							else CharIndex('"', HTML, CharIndex('width:', HTML, @SSP) + 6 ) - (CharIndex('width:', HTML, @SSP) + 6)  
						end
					)
				) as DimensionValueIsNUmeric
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			) = 1
			Begin
				
				UPDATE ReportHTML
				Set HTML =
					STUFF(
					HTML, 
					CharIndex('"', HTML, CharIndex('width:', HTML, @SSP)),
					0,
					'px')
				Where ProfileID = @ProfileID
				
				Set @SSP = 
				(
				Select
				CharIndex('width:', HTML) + 8
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
				)
				
			End
				
			Set @SSP = 
			(
				Select
				CharIndex('width:', HTML, @SSP + 8)
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			)									
			
			Set @Iteration = @Iteration + 1
		
		End -- While Loop	
	End -- IF Statement
	
	-- Check values ending with ' character
	Set @SSP = 
	(
	Select
	CharIndex('width:', HTML, 0)
	FROM 
	ReportHTML
	Where 
	ProfileID = @ProfileID
	)		
	if exists (Select HTML From ReportHTML Where ProfileID = @ProfileID and HTML like '%style=''%')	
	Begin
		Set @Iteration = 1
		Set @AttributeCount = 
		(
			select 
			(len(HTML)-len(replace(HTML,'width:',''))) /LEN('width:')
			FROM 
			ReportHTML
			Where 
			ProfileID = @ProfileID
		)	
		while (@Iteration <= @AttributeCount and @AttributeCount > 0)
		Begin
			if
			(
				Select
				ISNUMERIC(
					substring(
						HTML, 
						CharIndex('width:', HTML, @SSP) + 6,
						case 
							when CharIndex(CHAR(39), HTML, CharIndex('width:', HTML, @SSP) + 6 ) - (CharIndex('width:', HTML, @SSP) + 6) < 1 then 0
							else CharIndex(CHAR(39), HTML, CharIndex('width:', HTML, @SSP) + 6 ) - (CharIndex('width:', HTML, @SSP) + 6)  
						end
					)
				) as DimensionValueIsNUmeric
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			) = 1
			Begin
				
				UPDATE ReportHTML
				Set HTML =
					STUFF(
					HTML, 
					CharIndex(CHAR(39), HTML, CharIndex('width:', HTML, @SSP)),
					0,
					'px')
				Where ProfileID = @ProfileID
				
				Set @SSP = 
				(
				Select
				CharIndex('width:', HTML) + 8
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
				)
				
			End
				
			Set @SSP = 
			(
				Select
				CharIndex('width:', HTML, @SSP + 8)
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			)									
			
			Set @Iteration = @Iteration + 1
		
		End -- While Loop	
	End -- IF Statement

	------------------------------------------------
	---- Add px to all the "height" style attributes
	------------------------------------------------
	
	-----------------------------------------------------
	-- Correct Misspelling of "height" style attribute
	-----------------------------------------------------
	UPDATE ReportHTML
	Set HTML = REPLACE(HTML, 'hieght', 'height')
	Where ProfileID = @ProfileID
	
	
	-- Check values ending with ; character
	Set @SSP = 
	(
	Select
	CharIndex('height:', HTML, 0)
	FROM 
	ReportHTML
	Where 
	ProfileID = @ProfileID
	)		
	if exists (Select HTML From ReportHTML Where ProfileID = @ProfileID and HTML like '%;%')	
	Begin
		Set @Iteration = 1
		Set @AttributeCount = 
		(
			select 
			(len(HTML)-len(replace(HTML,'height:',''))) /LEN('height:')
			FROM 
			ReportHTML
			Where 
			ProfileID = @ProfileID
		)	
		while (@Iteration <= @AttributeCount and @AttributeCount > 0)
		Begin
			if
			(
				Select
				ISNUMERIC(
					substring(
						HTML, 
						CharIndex('height:', HTML, @SSP) + 7,
						case 
							when CharIndex(';', HTML, CharIndex('height:', HTML, @SSP) + 7 ) - (CharIndex('height:', HTML, @SSP) + 7) < 1 then 0
							else CharIndex(';', HTML, CharIndex('height:', HTML, @SSP) + 7 ) - (CharIndex('height:', HTML, @SSP) + 7)  
						end
					)
				) as DimensionValueIsNUmeric
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			) = 1
			Begin
				
				UPDATE ReportHTML
				Set HTML =
					STUFF(
					HTML, 
					CharIndex(';', HTML, CharIndex('height:', HTML, @SSP)),
					0,
					'px')
				Where ProfileID = @ProfileID
				
				Set @SSP = 
				(
				Select
				CharIndex('height:', HTML) + 8
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
				)
				
			End
				
			Set @SSP = 
			(
				Select
				CharIndex('height:', HTML, @SSP + 8)
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			)									
			
			Set @Iteration = @Iteration + 1
		
		End -- While Loop	
	End -- IF Statement
	
	-- Check values ending with " character
	Set @SSP = 
	(
	Select
	CharIndex('height:', HTML, 0)
	FROM 
	ReportHTML
	Where 
	ProfileID = @ProfileID
	)		
	if exists (Select HTML From ReportHTML Where ProfileID = @ProfileID and HTML like '%style="%')	
	Begin
		Set @Iteration = 1
		Set @AttributeCount = 
		(
			select 
			(len(HTML)-len(replace(HTML,'height:',''))) /LEN('height:')
			FROM 
			ReportHTML
			Where 
			ProfileID = @ProfileID
		)	
		while (@Iteration <= @AttributeCount and @AttributeCount > 0)
		Begin
			if
			(
				Select
				ISNUMERIC(
					substring(
						HTML, 
						CharIndex('height:', HTML, @SSP) + 7,
						case 
							when CharIndex('"', HTML, CharIndex('height:', HTML, @SSP) + 7 ) - (CharIndex('height:', HTML, @SSP) + 7) < 1 then 0
							else CharIndex('"', HTML, CharIndex('height:', HTML, @SSP) + 7 ) - (CharIndex('height:', HTML, @SSP) + 7)  
						end
					)
				) as DimensionValueIsNUmeric
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			) = 1
			Begin
				
				UPDATE ReportHTML
				Set HTML =
					STUFF(
					HTML, 
					CharIndex('"', HTML, CharIndex('height:', HTML, @SSP)),
					0,
					'px')
				Where ProfileID = @ProfileID
				
				Set @SSP = 
				(
				Select
				CharIndex('height:', HTML) + 8
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
				)
				
			End
				
			Set @SSP = 
			(
				Select
				CharIndex('height:', HTML, @SSP + 8)
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			)									
			
			Set @Iteration = @Iteration + 1
		
		End -- While Loop	
	End -- IF Statement
	

	-- Check values ending with ' character
	Set @SSP = 
	(
	Select
	CharIndex('height:', HTML, 0)
	FROM 
	ReportHTML
	Where 
	ProfileID = @ProfileID
	)		
	if exists (Select HTML From ReportHTML Where ProfileID = @ProfileID and HTML like '%style=''%')	
	Begin
		Set @Iteration = 1
		Set @AttributeCount = 
		(
			select 
			(len(HTML)-len(replace(HTML,'height:',''))) /LEN('height:')
			FROM 
			ReportHTML
			Where 
			ProfileID = @ProfileID
		)	
		while (@Iteration <= @AttributeCount and @AttributeCount > 0)
		Begin
			if
			(
				Select
				ISNUMERIC(
					substring(
						HTML, 
						CharIndex('height:', HTML, @SSP) + 7,
						case 
							when CharIndex(CHAR(39), HTML, CharIndex('height:', HTML, @SSP) + 7 ) - (CharIndex('height:', HTML, @SSP) + 7) < 1 then 0
							else CharIndex(CHAR(39), HTML, CharIndex('height:', HTML, @SSP) + 7 ) - (CharIndex('height:', HTML, @SSP) + 7)  
						end
					)
				) as DimensionValueIsNUmeric
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			) = 1
			Begin
				
				UPDATE ReportHTML
				Set HTML =
					STUFF(
					HTML, 
					CharIndex(CHAR(39), HTML, CharIndex('height:', HTML, @SSP)),
					0,
					'px')
				Where ProfileID = @ProfileID
				
				Set @SSP = 
				(
				Select
				CharIndex('height:', HTML) + 8
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
				)
				
			End
				
			Set @SSP = 
			(
				Select
				CharIndex('height:', HTML, @SSP + 8)
				FROM 
				ReportHTML
				Where 
				ProfileID = @ProfileID
			)									
			
			Set @Iteration = @Iteration + 1
		
		End -- While Loop	
	End -- IF Statement
	
	


	Set @LineNumber = @LineNumber + 1

End  -- Loop through each ProfileID




END -- End of Stored Procedure


GO
