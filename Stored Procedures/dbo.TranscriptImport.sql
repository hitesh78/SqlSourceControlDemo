SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[TranscriptImport] @xmlTranscriptData xml
AS

with XMLNAMESPACES ('http://tempuri.org/XMLSchema.xsd' as ns1)
select	tranData.*,
		Students.StudentID sID,
		Students.Fname sFname,
		Students.Mname sMname,
		Students.Lname sLname,
		ClassType.ClassTypeID,
		Transcript.TermTitle tTermTitle,
		Transcript.TermID tTermID,
		Transcript.TermStart tTermStart,
		Transcript.TermEnd tTermEnd
INTO #TRANSCRIPT_IMPORT_TEMP
FROM
(SELECT 
	Tbl.Col.value('ns1:StudentID[1]','int') StudentID,
	Tbl.Col.value('ns1:StudentFirstName[1]','nvarchar(30)') Fname,
	Tbl.Col.value('ns1:StudentMiddleName[1]','nvarchar(30)') Mname,
	Tbl.Col.value('ns1:StudentLastName[1]','nvarchar(30)') Lname,
	Tbl.Col.value('ns1:TermTitle[1]','nvarchar(100)') TermTitle,
	Tbl.Col.value('ns1:TermStart[1]','datetime') TermStart,
	Tbl.Col.value('ns1:TermEnd[1]','datetime') TermEnd,
	Tbl.Col.value('ns1:ClassTitle[1]','nvarchar(40)') ClassTitle,
	Tbl.Col.value('ns1:ClassType[1]','nvarchar(100)') ClassType,
	Tbl.Col.value('ns1:ClassUnits[1]','decimal(7,4)') ClassUnits,
	Tbl.Col.value('ns1:LetterGrade[1]','nvarchar(5)') LetterGrade,
	Tbl.Col.value('ns1:AlternativeGrade[1]','nvarchar(5)') AlternativeGrade,
	Tbl.Col.value('ns1:GradeLevel[1]','nvarchar(5)') GradeLevel,
	Tbl.Col.value('ns1:PercentageGrade[1]','nvarchar(7)') PercentageGrade,
	Tbl.Col.value('ns1:GPABoost[1]','nvarchar(7)') GPABoost
FROM (select @xmlTranscriptData xmlTranData) dummy
CROSS APPLY xmlTranData.nodes('/ns1:ROOT/ns1:ROW') Tbl(Col)) tranData
LEFT OUTER JOIN Students ON	-- allow matching on StudentID or name...
	(tranData.StudentID <> 0 AND tranData.StudentID = Students.StudentID)
	OR (tranData.StudentID = 0
		AND tranData.Fname = Students.Fname
		-- AND tranData.Mname = Students.Mname  -- ** ONLY USE IF NO MIDDLE NAMES AVAIL AND FIRST + LAST ARE UNIQUE **
		AND tranData.Lname = Students.Lname)
LEFT OUTER JOIN ClassType ON tranData.ClassType = ClassType.ClassTypeName
LEFT OUTER JOIN (
	SELECT	TermTitle,TermID,
			MAX(TermStart) TermStart,
			MAX(TermEnd) TermEnd
	FROM Transcript
	GROUP BY TermTitle,TermID ) Transcript 
ON Transcript.TermTitle = tranData.TermTitle -- AND Transcript.TermID >= 10000


-- School 595 specific cleanups...

--UPDATE #TRANSCRIPT_IMPORT_TEMP SET GradeLevel = '20'

--UPDATE #TRANSCRIPT_IMPORT_TEMP SET TermStart = '09/03/2009', TermEnd = '11/21/2009' 
--where TermTitle='T1 2009-10'
--UPDATE #TRANSCRIPT_IMPORT_TEMP SET TermStart = '09/03/2010', TermEnd = '11/21/2010' 
--where TermTitle='T1 2010-11'

--UPDATE #TRANSCRIPT_IMPORT_TEMP SET TermStart = '11/22/2007', TermEnd = '03/08/2008' 
--where TermTitle='T2 2007-08'
--UPDATE #TRANSCRIPT_IMPORT_TEMP SET TermStart = '11/22/2009', TermEnd = '03/08/2010' 
--where TermTitle='T2 2009-10'
--UPDATE #TRANSCRIPT_IMPORT_TEMP SET TermStart = '11/22/2009', TermEnd = '03/08/2010' 
--where TermTitle='T2 2010-11'

--UPDATE #TRANSCRIPT_IMPORT_TEMP SET TermTitle='T3 2010-11'
--where TermTitle='T3?? 2010-11'

--UPDATE #TRANSCRIPT_IMPORT_TEMP SET TermStart = '03/09/2010', TermEnd = '06/15/2010' 
--where TermTitle='T3 2009-10'
--UPDATE #TRANSCRIPT_IMPORT_TEMP SET TermStart = '03/09/2011', TermEnd = '06/15/2011' 
--where TermTitle='T3 2010-11'

-- 
-- RUN EXCEPTION TESTS:
-- 
DECLARE @ERRORS_FOUND int
SET @ERRORS_FOUND = 0

SELECT * FROM #TRANSCRIPT_IMPORT_TEMP

SELECT CAST('Name associated with StudentID must exactly match name provided in import.' as nvarchar(80)) as Error, * 
FROM #TRANSCRIPT_IMPORT_TEMP
WHERE (Fname<>'' AND Fname<>sFname) 
	--OR (Mname<>'' AND Mname<>sMname)
	OR (Lname<>'' AND Lname<>sLname)
SET @ERRORS_FOUND = @ERRORS_FOUND + @@ROWCOUNT

SELECT CAST('Class type incorrect or not found in database.' as nvarchar(80)) as Error, * 
FROM #TRANSCRIPT_IMPORT_TEMP
WHERE ClassTypeID IS NULL
	OR NOT (
		ClassType = 'Standard'
		OR ClassType = 'Honors'
		OR ClassType = 'Credit / No Credit' )
SET @ERRORS_FOUND = @ERRORS_FOUND + @@ROWCOUNT

SELECT CAST('Grade level is a required field.' as nvarchar(80)) as Error, * 
FROM #TRANSCRIPT_IMPORT_TEMP
WHERE GradeLevel = ''
SET @ERRORS_FOUND = @ERRORS_FOUND + @@ROWCOUNT

SELECT CAST('Term start and end are required fields.' as nvarchar(80)) as Error, * 
FROM #TRANSCRIPT_IMPORT_TEMP
WHERE TermStart < '1950-1-1' OR TermEnd < '1950-1-1'
SET @ERRORS_FOUND = @ERRORS_FOUND + @@ROWCOUNT

SELECT CAST('Duplicate names in GradeLink prevent name-only matching.' as nvarchar(80)) as Error, x.*
FROM (SELECT 
sFname,
-- sMname,
sLname,MIN(sID) minID, MAX(sID) maxID
FROM #TRANSCRIPT_IMPORT_TEMP
GROUP BY sFname,
-- sMname,
sLname) x
WHERE minID<>maxID
SET @ERRORS_FOUND = @ERRORS_FOUND + @@ROWCOUNT

SELECT CAST('Term Title may not match name of GradeLink grading term or a duplicated term.' as nvarchar(80)) as Error, x.*
FROM (SELECT 
		tTermTitle,MIN(tTermID) minID, MAX(tTermID) maxID
		FROM #TRANSCRIPT_IMPORT_TEMP
		GROUP BY tTermTitle) x
WHERE minID<>maxID OR minID<10000
SET @ERRORS_FOUND = @ERRORS_FOUND + @@ROWCOUNT

SELECT CAST('This term, class and student has already been imported - no duplicates allowed.' as nvarchar(80)) as Error, x.*
FROM (SELECT temp.* FROM #TRANSCRIPT_IMPORT_TEMP temp
		INNER JOIN Transcript
			ON Transcript.TermTitle = temp.TermTitle
				AND Transcript.StudentID = temp.sID
				AND Transcript.ClassTypeID = temp.ClassTypeID
				AND Transcript.ClassTitle = temp.ClassTitle) x
SET @ERRORS_FOUND = @ERRORS_FOUND + @@ROWCOUNT 

SELECT CAST('This student '''+x.Lname+'/'+x.Fname+'''was not found in the Students table.' as nvarchar(80)) as Error, x.*
FROM (SELECT temp.* FROM #TRANSCRIPT_IMPORT_TEMP temp
		WHERE sID IS NULL) x
SET @ERRORS_FOUND = @ERRORS_FOUND + @@ROWCOUNT
/*
SELECT CAST('Duplicate rows encountered for student,term and grade.' as nvarchar(80)) as Error, x.*
FROM (SELECT temp.* FROM #TRANSCRIPT_IMPORT_TEMP temp
		WHERE AlternativeGrade='DUP') x
SET @ERRORS_FOUND = @ERRORS_FOUND + @@ROWCOUNT -- comment this out to allow these to be imported 
                                               -- (AlternativeGrade is set to DUP if imported)
*/
-- TODO: Add a test for unique term titles by termstart and termend dates

--
-- STOP PROCESSING IF ERRORS FOUND...
--
IF @ERRORS_FOUND <> 0
	RAISERROR('PLEASE REVIEW THE ERRORS FOUND IN THE PRIOR QUERIES, CORRECT THEM, AND RETRY THE IMPORT.',10,-1)
ELSE
BEGIN

	BEGIN TRANSACTION -- MAKE THIS AN ALL OR NOTHING IMPORT!
	
	Declare @ImportConcludeDate nvarchar(30) = 'GLImport:' + CONVERT (char(20), getdate())
	
	PRINT 'IMPORT TERMS NOT PREVIOUSLY USED...'
	--
	-- DETERMINE IF WE NEED TO ASSIGN UNIQUE IDs TO NEW TERM TITLES (USE VALUES > 10000)
	--
	SELECT 	TermTitle, 
			MIN(tTermID) TermID
		INTO #TRAN_IMP_NEW_TERM_TITLES
		FROM #TRANSCRIPT_IMPORT_TEMP
		WHERE tTermID IS NULL
		GROUP BY TermTitle 
	IF @@ROWCOUNT <> 0
	BEGIN
		DECLARE @START_NEW_TERM_IDS int
		SET @START_NEW_TERM_IDS = (SELECT MAX(TermID) FROM Transcript)
		IF @START_NEW_TERM_IDS IS NULL OR @START_NEW_TERM_IDS < 10000
			SET @START_NEW_TERM_IDS = 10000
		SELECT @START_NEW_TERM_IDS
		PRINT 'ASSIGN TERM IDs...'
		-- Add a counter field to help compute TermID if needed...
		ALTER TABLE #TRAN_IMP_NEW_TERM_TITLES
			ADD ID_OFFSET int IDENTITY(1,1)
		-- Compute new term IDs
		UPDATE #TRAN_IMP_NEW_TERM_TITLES
			SET TermID = @START_NEW_TERM_IDS + ID_OFFSET
		-- Assign new term IDs
		UPDATE #TRANSCRIPT_IMPORT_TEMP
			SET tTermID = y.TermID
		FROM #TRANSCRIPT_IMPORT_TEMP x
			INNER JOIN #TRAN_IMP_NEW_TERM_TITLES y
			ON x.TermTitle = y.TermTitle

	END
	
	SELECT * FROM  #TRAN_IMP_NEW_TERM_TITLES
	
	DROP TABLE #TRAN_IMP_NEW_TERM_TITLES

	SELECT * FROM #TRANSCRIPT_IMPORT_TEMP

	DECLARE @StudentID int
	DECLARE @Fname nvarchar(30)
	DECLARE @Mname nvarchar(30)
	DECLARE @Lname nvarchar(30)
	DECLARE @TermID int
	DECLARE @TermStart datetime
	DECLARE @TermEnd datetime
	DECLARE @TermTitle nvarchar(100)
	DECLARE @ClassTitle nvarchar(40)
	DECLARE @ClassTypeID int
	DECLARE @ClassUnits decimal(7,4)
	DECLARE @LetterGrade nvarchar(5)
	DECLARE @AlternativeGrade nvarchar(5)
	DECLARE @GradeLevel nvarchar(20) -- this seems like a wacky grade level width but it matches transcript!
	DECLARE @TheLetterGrade nvarchar(5) -- a working variable that was used in Don's code...

	Declare @CreditNoCreditPassingGrade int  -- prob not needed by import????
	Declare @CustomGradeScaleID int
	Declare @PercentageGrade nvarchar(7)
	Declare @LetterGradeGPA decimal(7,4)
	Declare @GPABoostChar nvarchar(7)
	Declare @GPABoost decimal(5,2)

	DECLARE import_cursor CURSOR FOR
	SELECT  
	 sID,
	 sFname,sMname,sLname,
	 tTermID,
	 TermStart,
	 TermEnd,
	 TermTitle,
	 ClassTitle,ClassTypeID,ClassUnits,
	 LetterGrade,AlternativeGrade,
	 GradeLevel, PercentageGrade, GPABoost
	FROM #TRANSCRIPT_IMPORT_TEMP

	OPEN import_cursor;

	FETCH NEXT FROM import_cursor
	  INTO	@StudentID,@Fname,@Mname,@Lname,
			@TermID,@TermStart,@TermEnd,@TermTitle,
			@ClassTitle,@ClassTypeID,@ClassUnits,
			@LetterGrade,@AlternativeGrade,
			@GradeLevel, @PercentageGrade, @GPABoostChar

	-- **** BEGIN ********************************************
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @GPABoost = CASE @GPABoostChar WHEN '' THEN 0 ELSE cast(@GPABoostChar as numeric(5,2)) END

		-- =================================================================
		-- PORTIONS OF THE FOLLOWING CODE ARE COPIED FROM AddGradeToTranscript.xml
		-- =================================================================

		Set @CreditNoCreditPassingGrade = 
			(Select CreditNoCreditPassingGrade From Settings 
				Where SettingID = 1)

		Set @CustomGradeScaleID = 
			(Select CustomGradeScaleID From CustomGradeScale 
				Where GradeScaleName = '**Standard')

		if @GPABoost > 0
		begin
			print @Fname+','+@ClassTitle+','+@LetterGrade+','+@GPABoostChar
			print @GPABoost
		end

		If LTRIM(@LetterGrade) = '' AND LTRIM(@PercentageGrade) <> ''
		Begin
		-- *******Calculate Letter Grade******************
			Select top 1 
			@TheLetterGrade = GradeSymbol,
			@LetterGradeGPA = 
			(
			case 
				when GPAValue = 0 then 0
				else GPAValue + @GPABoost -- 6-23-11 use GPABoost from transcript import file rather than Grade Scale for now. 
			end							  
			)
			From CustomGradeScaleGrades
			where 
			CustomGradeScaleID = @CustomGradeScaleID
			and
			LowPercentage <= @PercentageGrade
			Order By LowPercentage desc

			SET @LetterGrade = @TheLetterGrade
			print @Fname+' '+@Lname+','+@ClassTitle+','+@PercentageGrade+'-->'+@TheLetterGrade

		End
		Else
		Begin
			If @ClassTypeID = 8
			Begin
				Set @TheLetterGrade = (Select
					Case 
					  when @LetterGrade = 'Credit' then 'CR'
					  when @LetterGrade = 'No Credit' then 'NC'
					  else @LetterGrade
					End)
				-- Set @PercentageGrade = null
				Set @LetterGradeGPA  = null
			End
			Else
			Begin
				Select top 1 
				@TheLetterGrade = @LetterGrade,
				@LetterGradeGPA = 
				(
				case 
					when GPAValue = 0 then 0
					else GPAValue + @GPABoost -- 6-23-11 use GPABoost from transcript import file rather than Grade Scale for now. 
				end							  
				)
				--, @PercentageGrade = null
				From 
				CustomGradeScaleGrades CGG
				inner join
				CustomGradeScale CG
				on CG.CustomGradeScaleID = CGG.CustomGradeScaleID
				where 
				CG.CustomGradeScaleID = @CustomGradeScaleID
				and
				CGG.GradeSymbol = @LetterGrade
			End
		End

		Declare @UnitsEarned decimal(6,2)
		
		If @TheLetterGrade in ('F', 'NC')
		Begin
		Set @UnitsEarned = 0
		End
		Else
		Begin
		Set @UnitsEarned = @ClassUnits
		End

		Declare @UnitGPA Decimal(5,2)
		Declare @FunctionType int
		
		Set @FunctionType = 1

		Set @UnitGPA = @LetterGradeGPA * @UnitsEarned

		-- =================================================================

		PRINT 'Importing... ' + @Fname+' '+@Mname+' '+@Lname+', '+@ClassTitle+', '+@TermTitle

		INSERT INTO Transcript 
		(
		StudentID,
		Fname,Mname,Lname,
		TermID,TermStart,TermEnd,TermTitle,
		ClassTitle,ClassTypeID,ClassUnits,
		LetterGrade,AlternativeGrade,
		GradeLevel,
		PercentageGrade,
		UnitsEarned, 
		UnitGPA, 
		CustomGradeScaleID,
		GPABoost,
		ConcludeDate
		 )
		VALUES 
		(
		@StudentID,@Fname,@Mname,@Lname,
		@TermID,@TermStart,@TermEnd,@TermTitle,
		@ClassTitle,@ClassTypeID,@ClassUnits,
		@LetterGrade,@AlternativeGrade,
		@GradeLevel,
		CASE @PercentageGrade WHEN '' THEN null ELSE cast(@PercentageGrade as numeric(5,2)) END,
		@UnitsEarned, 
		@UnitGPA, 
		@CustomGradeScaleID,
		@GPABoost,
		@ImportConcludeDate
		)
		-- Rollback the transaction if there were any errors
		IF @@ERROR <> 0
		BEGIN
			PRINT 'ERROR OR DUPLICATE FOUND: Term:' + cast(@TermID as nvarchar(10)) 
				+ ', Title: '+@TermTitle
				+', StudentID: '+cast(@StudentID as nvarchar(10))
				+', Fname:'+@Fname
				+', Lname:'+@Lname
				+', ClassTypeID: '+cast(@ClassTypeID as nvarchar(10))
				+', ClassTitle: '+@ClassTitle
				
			UPDATE Transcript SET AlternativeGrade='DUP'
				WHERE TermID=@TermID and StudentID=@StudentID and ClassTitle=@ClassTitle and ClassTypeID=@ClassTypeID
		 
			IF @@ERROR <> 0
			BEGIN
				-- Rollback the transaction
				ROLLBACK

				-- Raise an error and return 
				RAISERROR ('There were errors when trying to insert into Transcript. Entire import aborted.', 16, 1)
				RETURN
			END
		END

		FETCH NEXT FROM import_cursor
		  INTO	@StudentID,@Fname,@Mname,@Lname,
				@TermID,@TermStart,@TermEnd,@TermTitle,
				@ClassTitle,@ClassTypeID,@ClassUnits,
				@LetterGrade,@AlternativeGrade,
				@GradeLevel,@PercentageGrade, @GPABoostChar
	END
	
	CLOSE import_cursor
	DEALLOCATE import_cursor
	-- **** END **********************************************

	COMMIT -- I HOPE IT ALL WORKED!

	-- select * from Transcript

END

DROP TABLE #TRANSCRIPT_IMPORT_TEMP

-- Don's fix for ClassID:

Declare @MaxClassID int = (Select MAX(ClassID) From Transcript)
 
If @MaxClassID < 100000 -- ClassIDs for imported or records added manually should start at 100001
Begin
      Set @MaxClassID = 100001
End
Declare @ClassData table (TermID int, ClassTitle nvarchar(50))
Declare @ClassData2 table (NewClassID int, TermID int, ClassTitle nvarchar(50))
 
Insert into @ClassData
Select distinct
TermID,
ClassTitle
From Transcript
Where
ClassID = 0
 
Insert into @ClassData2
Select
convert(int, ROW_NUMBER() OVER(ORDER BY TermID, ClassTitle)) + @MaxClassID as NewClassID,
TermID,
ClassTitle
From @ClassData
 
Update Transcript
Set ClassID = C.NewClassID
From
@ClassData2 C
      inner join
Transcript T
      on C.TermID = T.TermID
      and
      C.ClassTitle = T.ClassTitle
Where
T.ClassID = 0
 

GO
