SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 11/2/2016
-- Description:	Georgia State Transcript Export
-- =============================================
CREATE Procedure [dbo].[GeorgiaTranscriptExport]
@ReportType nvarchar(20),
@Terms nvarchar(100),
@StudentIDs nvarchar(2000),
@GradeLevel nvarchar(5),
@theClassID int
AS
BEGIN


--Declare
--@ReportType nvarchar(20) = 'ByStudent',
--@Terms nvarchar(100) = '61,62,67,63,64,68,,',
--@StudentIDs nvarchar(2000) = '2,',
--@GradeLevel nvarchar(5),
--@theClassID int


	SET NOCOUNT ON;

	Declare 
	@LowTranscriptGradeLevel int = 9,
	@HiTranscriptGradeLevel int = 12

	Declare @GeorgiaStateTranscriptsExportUsePercentageGrade bit = (Select GeorgiaStateTranscriptsExportUsePercentageGrade From Settings Where SettingID = 1)


	Declare @StudentIDsTable table (StudentID int)
	Insert into @StudentIDsTable
	Select distinct StudentID 
	From Transcript
	Where
	case 
		when @ReportType = 'ByStudent' and StudentID in (Select IntegerID From dbo.SplitCSVIntegers(@StudentIDs)) then 1
		when @ReportType = 'ByClass' and ClassID = @theClassID then 1
		when @ReportType = 'ByGradeLevel' and GradeLevel = @GradeLevel and TermID in (Select IntegerID From dbo.SplitCSVIntegers(@Terms)) then 1	
		else 0
	end = 1



	Declare @Sep nchar(1) = '='
	Declare @LineBreak nvarchar(2) = CHAR(13) + CHAR(10);
	Declare @CurrentDate date = dbo.glgetdate();
	Declare
	@SchoolCode nvarchar(100),
	@SchoolName nvarchar(100),
	@SchoolStreet nvarchar(100),
	@SchoolCity nvarchar(100),
	@SchoolState nvarchar(50),
	@SchoolZip nvarchar(20),
	@SchoolPhone nvarchar(30),
	@SchoolFax nvarchar(30)

	Select
	@SchoolCode = SchoolCode,  --Schools need to enter their CEEB Code in Settings > School Code
	@SchoolName = SchoolName,
	@SchoolStreet = SchoolStreet, 
	@SchoolCity = SchoolCity,
	@SchoolState = 'GA',
	@SchoolZip = SchoolZip,
	@SchoolPhone = SchoolPhone,
	@SchoolFax = SchoolFax
	From Settings
	Where
	SettingID = 1

	OPEN MASTER KEY DECRYPTION BY PASSWORD = 'GL<3sDogs!';
	OPEN SYMMETRIC KEY SymmetricKey1 DECRYPTION BY CERTIFICATE Certificate1;

	-- ******* Comment out below lines to see table format *******
	Declare @theText nvarchar(max) =
	(
	Select 
	replace(
	(
		Select N'' + DataColumn		-- for Carriage Return add CHAR(13) in single quotes
		From
		(
	-- ******* Comment out above lines to see table format *******

			-- Header Record
			Select 
			'0' as HeaderOrder,
			null as StudentID,
			null as orderTermEndNumber,
			null as orderClassTitle,
			'HR' + @Sep + 'XSTFF1.1'  + @Sep +  convert(char(8), getdate(), 112) 
			+ @LineBreak
			as DataColumn

			Union

			-- School Demographic Info
			Select
			'1' as HeaderOrder,
			T.StudentID as StudentID,
			null as orderTermEndNumber,
			null as orderClassTitle,
			'01' + @Sep + 
			@SchoolCode + @Sep +  --Schools need to enter their CEEB Code in Settings > School Code
			@SchoolName + @Sep + 
			@SchoolStreet + @Sep + 
			@SchoolCity + @Sep + 
			@SchoolState + @Sep + 
			@SchoolZip + @Sep + 
			@SchoolPhone + @Sep + 
			@SchoolFax +
			@LineBreak
			as DataColumn
			From 
			Transcript T
				inner join
			@StudentIDsTable St
				on St.StudentID = T.StudentID
			Where
			T.ClassTypeID in (1,8)
			and
			(
				T.GradeLevel in ('9', '10', '11', '12') 
				or
				T.IgnoreTranscriptGradeLevelFilter = 1
			) 
			and
			T.ParentTermID = 0	-- Only show parent terms like the transcript					


			Union

			-- Student Demographic Info
			Select
			'1' as HeaderOrder,
			T.StudentID as StudentID,
			null as orderTermEndNumber,
			null as orderClassTitle,
			'02' + @Sep + 
			@Sep +		-- Remove Student Indicator
			convert(nvarchar(30),S.StudentID) + @Sep +
			isnull(SM.GOVid_plaintext,'') + @Sep +	
			S.Lname + @Sep + 
			S.Fname + @Sep + 
			isnull(S.Mname,'') + @Sep + 
			isnull(S.Street,'') + ' ' + isnull(S.Street2,'') + @Sep + 
			isnull(S.City,'') + @Sep +
			isnull(case when S.State ='Georgia' then 'GA' else S.State end, '') + @Sep +			
			isnull(S.Zip,'') + @Sep + 
			isnull(S.Phone1,'') + @Sep + 
			isnull(convert(char(8), S.BirthDate, 112),'')+ @Sep + 
			isnull(upper(left(S.Sex,1)),'') + @Sep + 
			@Sep +		-- Race Black font = remove??
			isnull(convert(char(4),year(S.GraduationDate)),'') + @Sep + 	--Schools need to enter the Students GraduationDate in Students Code
			isnull(right('0'+convert(nvarchar(2),max(convert(int,T.GradeLevel))),2),'') +  
			@Sep +
(	 -- Grade Point Average A
Select
isnull(
convert (nvarchar(10),
convert(decimal(4,3),
Sum(UnitGPA)/Sum(ClassUnits)
))
,'')
From 
Transcript
where
StudentID = S.StudentID	
and 
ClassTypeID in (1, 2)
and
(case
	when IgnoreTranscriptGradeLevelFilter = 1 then 1
	when GradeLevel = 'K' and @LowTranscriptGradeLevel <= 0 then 1
	when GradeLevel = 'PK' and @LowTranscriptGradeLevel <= -1 then 1
	when GradeLevel = 'PS' and @LowTranscriptGradeLevel <= -2 then 1
	when ISNUMERIC(GradeLevel) = 1 and GradeLevel between convert(int, @LowTranscriptGradeLevel) and convert(int, @HiTranscriptGradeLevel) then 1
	else 0
end) = 1
and
ParentTermID = 0
and
(AlternativeGrade is null or AlternativeGrade = '')
and
CalculateGPA = 1
and
CustomGradeScaleID in (Select CustomGradeScaleID From CustomGradeScale Where CalculateGPA = 1)
and
LetterGrade is not null
and
UnitGPA is not null
)	+		
@Sep + 
(	 -- Grade Point Average B
Select
isnull(
convert (nvarchar(10),
convert(decimal(4,3),
	sum( -- Sum all this 

	( -- * UnitEarned 
	( -- - GPABoost
	( -- case statement
	case UnitsEarned
		when 0 then 0
		else UnitGPA/UnitsEarned
	end)
	- GPABoost)
	*UnitsEarned)
	) -- Sum all this 
	/Sum(ClassUnits)
))
,'')
From 
Transcript
where
StudentID = S.StudentID	
and 
ClassTypeID in (1, 2)
and
(case
	when IgnoreTranscriptGradeLevelFilter = 1 then 1
	when GradeLevel = 'K' and @LowTranscriptGradeLevel <= 0 then 1
	when GradeLevel = 'PK' and @LowTranscriptGradeLevel <= -1 then 1
	when GradeLevel = 'PS' and @LowTranscriptGradeLevel <= -2 then 1
	when ISNUMERIC(GradeLevel) = 1 and GradeLevel between convert(int, @LowTranscriptGradeLevel) and convert(int, @HiTranscriptGradeLevel) then 1
	else 0
end) = 1
and
ParentTermID = 0
and
(AlternativeGrade is null or AlternativeGrade = '')
and
CalculateGPA = 1
and
CustomGradeScaleID in (Select CustomGradeScaleID From CustomGradeScale Where CalculateGPA = 1)
and
LetterGrade is not null
and
UnitGPA is not null
)	+ 		@Sep + '-1' + -- Class Rank
			@Sep + '-1' + -- Class Size
			@Sep + '-1' + -- Class Rank 2
			@Sep + 
			isnull(convert(nvarchar(8), S.EntryDate, 112),'') + @Sep + 
			isnull(convert(nvarchar(8), S.WithdrawalDate, 112),'') + @Sep + 
			isnull(convert(nvarchar(8), S.GraduationDate, 112),'') + @Sep + 
			case 
				when isnull(LTRIM(RTRIM(S.Father)),'') = '' then S.Mother
				when isnull(LTRIM(RTRIM(S.Mother)),'') = '' then S.Father
				else S.Father + ' & ' + S.Mother
			end + @Sep +
			isnull(S.Street,'') + @Sep + 
			isnull(S.Street2,'') + @Sep + 
			isnull(S.City,'') + @Sep + 
			isnull(case when S.State ='Georgia' then 'GA' else S.State end, '') + @Sep +	
			isnull(S.Zip,'') + @Sep + 
			isnull(S.Phone1,'') + @Sep +
			@Sep + -- Student's Counselor Name (Leave Blank)
			case
				--	when S.WithdrawalDate is not null then 'W'	** This is no-longer or possibly never was applicable see FD #349433  -dp 11/1/2021 
				when @CurrentDate >= S.GraduationDate then 'G'
				else 'E'
			end + @Sep + -- Student's Status (W=Withdrew; G=Graduated; E=Enrolled)
			case 
				when Affiliations like '%DiplomaType=%' 
					then substring(Affiliations, (PATINDEX('%DiplomaType=%' , Affiliations) + 12), 1)
				else 'C' 
			end -- Diploma Type (C = College Preparatory), 
				-- This defualts to "C" but a school can customize this by 
				-- By adding the exact text "DiplomaType=G" as a tag within Students UI to change it to "G"  
				-- they can set default tags/Dipoma Types so they show in the tags drop-down by going to Students > Admin > Coding
			+ @Sep + 
			@Sep + -- Student's Graduation Program of Study (Leave Blank which defaults to "College Preparatory")
			'Weighted' + @Sep +  -- GPA A Label
			'Unweighted' + -- GPA B Label
			@LineBreak
			as DataColumn
			From 
			Transcript T
				inner join
			Students S	
				on T.StudentID = S.StudentID
				inner join
			@StudentIDsTable St
				on St.StudentID = S.StudentID
				inner join
			vStudentMiscFields SM
				on S.StudentID = SM.StudentID
			Where
			T.ClassTypeID in (1,8)
			and
			(
				T.GradeLevel in ('9', '10', '11', '12') 
				or
				T.IgnoreTranscriptGradeLevelFilter = 1
			)	
			and
			T.ParentTermID = 0	-- Only show parent terms like the transcript
			Group By 
			T.StudentID, 
			S.StudentID, 
			SM.GOVid_plaintext, 
			S.Lname, S.Fname, 
			S.Mname, 
			S.Street, 
			S.Street2, 
			S.City, 
			S.State, 
			S.Zip, 
			S.Phone1, 
			S.BirthDate, 
			S.Sex, 
			S.GraduationDate, 
			S.EntryDate, 
			S.WithdrawalDate, 
			S.WithdrawalDate, 
			S.Father, 
			S.Mother,
			case 
				when Affiliations like '%DiplomaType=%' 
					then substring(Affiliations, (PATINDEX('%DiplomaType=%' , Affiliations) + 12), 1)
				else 'C' 
			end

			Union

			-- Academic Session (Repeat as Needed)
			Select distinct
			'1' as HeaderOrder,
			T.StudentID as StudentID,
			convert(char(8), T.TermEnd, 112) as orderTermEndNumber,
			null as orderClassTitle,
			'03' + @Sep +
			case 
				when PATINDEX('%**%', T.TermTitle) > 0 then substring(T.TermTitle, (PATINDEX('%**%', T.TermTitle)+2), 60)
				else ''
			end + @Sep +		-- School Name only use if different from current school
			LEFT(CONVERT(varchar, T.TermEnd,112),6) + @Sep +		-- Session Date
			right('0'+convert(nvarchar(2),T.GradeLevel),2) + @Sep +	-- Student Grade Level
			case 
				when PATINDEX('%**%', T.TermTitle) > 0 and isnull(T.TermReportTitle,'') = '' then 'T'
				else T.TermReportTitle
			end + @Sep +
			convert(char(8), T.TermStart, 112) + @Sep +
			convert(char(8), T.TermEnd, 112) +
			@LineBreak
			as DataColumn
			From 
			Transcript T
				inner join
			Students S	
				on T.StudentID = S.StudentID
				inner join
			@StudentIDsTable St
				on St.StudentID = S.StudentID
			Where
			T.ClassTypeID in (1,8)
			and
			(
				T.GradeLevel in ('9', '10', '11', '12') 
				or
				T.IgnoreTranscriptGradeLevelFilter = 1
			)
			and
			T.ParentTermID = 0	-- Only show parent terms like the transcript

			Union

			-- Course Info(Repeat as Needed)
			Select distinct
			'1' as HeaderOrder,
			T.StudentID as StudentID,
			convert(char(8), T.TermEnd, 112) as orderTermEndNumber,
			T.ClassTitle as orderClassTitle,
			'04' + @Sep +
			convert(nvarchar(6),convert(decimal(5,3),T.ClassUnits)) + @Sep +
			convert(nvarchar(6),convert(decimal(5,3),T.UnitsEarned)) + @Sep +
			case 
				when @GeorgiaStateTranscriptsExportUsePercentageGrade = 1 and T.ClassTypeID = 8 and T.PercentageGrade is null then T.LetterGrade
				when @GeorgiaStateTranscriptsExportUsePercentageGrade = 1 then convert(nvarchar(4), convert(int,round(T.PercentageGrade,0)))
				else T.LetterGrade
			end + @Sep +
			@Sep +	-- Course Honors Indicator - not required
			@Sep +	-- Course College Prep Indicator - not required
			T.ClassTitle + @Sep +
			T.CourseCode + @Sep +
			@Sep +	-- Course Repeat Indicator - not required
			@Sep +	-- Course Subject Area Indicator - not required
			case 
				when T.GradeLevel not in ('9', '10', '11', '12') then 'M'
				else ''
			end + @Sep + -- Credit Qualifier - Required - Used to indicate if the HS credit class was taken in Non HS GradeLevel (NH=Not HighSchool).
			case 
				when T.TermTitle like '%**%' then 'T'
				else ''
			end + @Sep + -- (TOH=Transferred from Other Highschool)
			@Sep + -- POS – Program of Study - not required
			
			-- Required - The Weighting Indicator is the alphanumeric code that is defined in the legend of the transcript (W=Weighted).
			-- (FD 136901 / DS-864 - Union following codes; these are not mutually exclusive; but hopefully all 3 never apply if the spec is true that field width is limited to 2!!)
			-- Due to the limit of 2 characters for this AP can only be used if both Rigor and DualEnrollment are false
			-- Also H can only be used if at least one item Rigor or DualEnrolment is false
			-- This is a flaw in the spec but Per FD 238719 GAFutures reccomends removing 'H' or 'AP' when things won't fit.

			-- 07/09/2021 per FD#302027 and conversations Tom had with GAFutures when DualEnrollment is select they cannot/should not have Honors or Rigor
			-- So I'm changing the logic below for H to use "and" operator - dp
			case
				when GPABoost = 0.50 and (DualEnrollment = 0 and Rigor = 0)then 'H'
				when GPABoost = 1.00 and DualEnrollment = 0 and Rigor = 0 then 'AP'  
				else ''
			end + 
			case
				when DualEnrollment = 1 then 'D' -- FD 135579 / DS-834 Changed form 'DE' to 'D'
				else ''
			end + 
			case
				when Rigor = 1 then 'R'
				else ''
			end + 
			--

			@LineBreak
			as DataColumn
			From 
			Transcript T
				inner join
			Students S	
				on T.StudentID = S.StudentID
				inner join
			@StudentIDsTable St
				on St.StudentID = S.StudentID
			Where
			T.ClassTypeID in (1,8)
			and
			(
				T.GradeLevel in ('9', '10', '11', '12') 
				or
				T.IgnoreTranscriptGradeLevelFilter = 1
			)
			and
			T.LetterGrade is not null
			and
			isnull(T.CourseCode,'') != ''
			and
			T.ParentTermID = 0	-- Only show parent terms like the transcript
			

			
	-- *******Comment out below lines to see table format*******		
		) x
		Order By HeaderOrder, StudentID, orderTermEndNumber, orderClassTitle
		FOR XML PATH(''),TYPE)
	  .value('text()[1]','nvarchar(max)'
	)
	,
	'='
	,
	CHAR(30)
	) -- end of replace function
	 as XAPData
	)

	Select @theText as theData

	--******* Coment out above lines to see table format ********


	--Print CAST(@theText AS NTEXT)
	


	CLOSE SYMMETRIC KEY SymmetricKey1


END

GO
