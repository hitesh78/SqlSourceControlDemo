SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ====================================================
-- Modified dt:	9/1/2021
-- Modify Note:	Added "N" to update value per GC-25406
-- ====================================================
CREATE   Procedure [dbo].[analyzeEnrollMeImport] (@table_name nvarchar(50), @table_pk_id int)
as
begin

/*
--
-- todo: @student_record_found can be deprecated if I add RI between students and EnrollmentStudent
-- and on the delete restriction, i could provide instructions on how to delete EnrollmentStudent first.
-- Although I'm not sure about even allowing deleting records entered by parents, but I guess it is OK
-- and I do allow editing so that the school can assist if the parents get stuck...???
--
-- if there is an error on import, records should not be marked as having been imported...
--
	2023.04.13	HC	Added Logic to Import Phones OptIn if School has Smart Send Pro
*/

	declare @table_pk_id_str nvarchar(20) = cast(@table_pk_id as nvarchar(20));
	declare @str nvarchar(MAX);
	declare @crlf nvarchar(10) = char(10);
	declare @ErrLine int;
	Declare @Comm2Enabled bit = (Select Comm2 from Settings)
	declare @origStudentID int = 
		(select StudentID 
			from EnrollmentStudent 
			where EnrollmentStudentID=@table_pk_id)
	declare @studentid int = 
		(select case when ImportStudentID is not null then ImportStudentID else StudentID end
			from EnrollmentStudent 
			where EnrollmentStudentID=@table_pk_id)
	declare @student_record_found bit = 
		case when (select studentid 
			from Students 
			where StudentID=@studentid) is null 
			then 0 else 1 end;
	declare @student_record_already_linked bit = 
		case when (select studentid 
			from vEnrollmentStudent
			where StudentID=@StudentID and Imported=1
			and EnrollmentStudentID<>@table_pk_id ) is not null
			then 1 else 0 end;

	declare @isMedicalHistory bit = 
		case when (select studentid 
			from EnrollmentStudentDefaults
			where isMedicalHistory=1 
				and Page_Medical=1 -- Never overwrite SIS fields unless medical tab was actually reached/edited
			and EnrollmentStudentID=@table_pk_id) is not null
			then 1 else 0 end;

	declare @isMedicalAllergies bit = 
		case when (select studentid 
			from EnrollmentStudentDefaults
			where isMedicalAllergies=1 
				and Page_Medical=1 -- Never overwrite SIS fields unless medical tab was actually reached/edited
			and EnrollmentStudentID=@table_pk_id) is not null
			then 1 else 0 end;

	declare @new_import bit = 
		(case when @studentid >= 1000000000 
			or @student_record_found=0 then 1 else 0 end);
	declare @re_import bit = (case when @new_import=0 and @origStudentID >= 1000000000 
		then 1 else 0 end); 
	declare @CurrentSessionID int = 
		(select SessionID from EnrollmentFormSettings)
	if @student_record_already_linked=1 --and @origStudentID >= 1000000000
	begin
		RAISERROR('<span>You have linked this enrollment to a student that already has an imported enrollment form.  Please check and correct the student selection on the Workflow page.</span> (<span>Student ID</span> %d, <span>Enrollment ID</span> %d)',16,1,
		@StudentID,@table_pk_id );
		return	
	end	


-- make sure default fields are stored in base table so that vEnrollContacts view is accurate
exec [dbo].[glSaveEnrollMeDefaults]

BEGIN TRANSACTION
BEGIN TRY
	create table #import
	(
		line int identity(1,1), 
		TargetTableName nvarchar(50), 
		TargetFieldName nvarchar(50),
		TargetValue nvarchar(MAX),
		SourceTableName nvarchar(50), 
		SourceFieldName nvarchar(50),
		SourceValue nvarchar(MAX)
	)

	create table #target
	(
		line int identity(1,1), 
		id int, 
		col nvarchar(100), 
		value nvarchar(MAX)
	)

	create table #source
	(
		line int identity(1,1), 
		id int, 
		col nvarchar(100), 
		value nvarchar(MAX)
	)

	declare @unPivotParam nvarchar(200);
	
	set @unPivotParam = 'where EnrollmentStudentID = ' + @table_pk_id_str
	insert into #source 
		exec unPivotTable 'vEnrollmentStudent', @unPivotParam, "StudentID"

	if @new_import = 0
	begin
		set @unPivotParam = 'where StudentID = ' + cast(@studentid as nvarchar(20))
		insert into #target
			exec unPivotTable 'Students', @unPivotParam, "StudentID"
		insert into #target
			exec unPivotTable 'StudentMiscFields', @unPivotParam, "StudentID"
		insert into #target
			exec unPivotTable 'HealthHistory', @unPivotParam, "StudentID"
	end

--select * into temp6 from #source

	-- Dummy StudentID entry for StudentMiscFields and HealthHistory...
	insert into #source (id,col,value) values (@studentid,'StudentID',@studentid)

--drop table temp6
--select * into temp6a from #import

	insert into #import
		select 
			case when t.TargetTableName is null 
				then '*None*' else t.TargetTableName end as TargetTableName,
			case when t.TargetFieldName is null
				then sv.col else t.TargetFieldName end as TargetFieldName,
			replace(isnull(tg.value,''),' 12:00AM',''),
			'vEnrollmentStudent',
			t.ShortSourceFieldName, -- sv.col
			replace(sv.value,' 12:00AM','')
		from (select * from LKG_ImportTargets where SourceTableName = 'vEnrollmentStudent') t
		full outer join (select * from #source where CHARINDEX('HTML',col)=0 and CHARINDEX('_CSS_',col)=0 ) sv 
			on sv.col = t.ShortSourceFieldName
		left join #target tg on t.TargetFieldName = tg.col
		where t.TargetTableName != '*None*' 
			or (t.TargetTableName = '*None*' and isnull(t.ImportLogicCode,'') != 'Repeated_Field')
		order by t.TargetTableName desc, t.SortOrder

--drop table temp8
--select * into temp8 from #import

	delete #source
	set @unPivotParam = 'where EnrollmentStudentID = ' + @table_pk_id_str
	insert into #source
		exec unPivotTable 'vEnrollContacts', @unPivotParam, "InstanceID"

--select * into temp5 from #source

	insert into #import
		select t.TargetTableName,t.TargetFieldName,'',
			t.SourceTableName+ isnull('_'+CAST(x.id as nvarchar(10)),'') SourceTableName,
			t.ShortSourceFieldName,sv.value
		from LKG_ImportTargets t
		cross join (Select distinct id from #source s) x
		full outer join #source sv on sv.col = t.ShortSourceFieldName and sv.id = x.id
		where t.SourceTableName = 'vEnrollContacts' and t.TargetTableName='StudentContacts'
		order by t.TargetTableName,t.SourceTableName+'_'+CAST(x.id as nvarchar(10)),t.SortOrder


	delete #source
	set @unPivotParam = 'where EnrollmentStudentID = ' + @table_pk_id_str
	insert into #source
		exec unPivotTable 'vEnrollMedications', @unPivotParam, "InstanceID"

--select * into temp5 from #source

	insert into #import
		select t.TargetTableName,t.TargetFieldName,'',
			t.SourceTableName+ isnull('_'+CAST(x.id as nvarchar(10)),'') SourceTableName,
			t.ShortSourceFieldName,sv.value
		from LKG_ImportTargets t
		cross join (Select distinct id from #source s) x
		full outer join #source sv on sv.col = t.ShortSourceFieldName and sv.id = x.id
		where t.SourceTableName = 'vEnrollMedications' and t.TargetTableName='Medications'
		order by t.TargetTableName,t.SourceTableName+'_'+CAST(x.id as nvarchar(10)),t.SortOrder


	-- Pull current ethnicity value from StudentRoster view...
	update #import set TargetValue = isnull(
			(select Ethnicity 
				from StudentRoster
				where StudentID = @studentid), '')
		where targetfieldname='Ethnicity' and targettablename='Students'

	-- Pull current ethnicity value from StudentRoster view...
	update #import set SourceValue = 
			replace(replace(replace(SourceValue,'<br/>',';')+'~',';~',''),'~','')
		where targetfieldname='Ethnicity' and targettablename='Students'

	declare @raceCodes nvarchar(4000) = (select SourceValue from #import where targetfieldname='Ethnicity' and targettablename='Students');

--select * into temp4 from #import

	declare @strCode nvarchar(MAX) = 'declare @ImportErrorLine int = 0;'
	
	if @new_import=1
	begin
		set @strCode = @strCode + '

set @ImportErrorLine = 0;

-- define family ID (will only be used for New Enrollments)
declare @ImportFamilyID int;

-- did user explicitly specify a family ID?  If so, use it...
set @ImportFamilyID = (
	select ImportFamilyID from EnrollmentStudent
	where EnrollmentStudentID = ' + @table_pk_id_str + ');

-- if family ID was not specified explicitly then see if any new enrollment family group
-- is already imported to a student with an SIS family ID!
if @ImportFamilyID is null
	set @ImportFamilyID = (
		select (Select MAX(s.FamilyID) from Students s
				inner join EnrollmentStudent es1 
				on es1.ImportStudentID = s.StudentID
				where es1.EnrollFamilyID = es.EnrollFamilyID
					and es1.EnrollFamilyID is not null
				)
		from EnrollmentStudent es 
		where EnrollmentStudentID = ' + @table_pk_id_str + ');

-- Go fetch a new family ID for all incoming New Enrollments...
--if @ImportFamilyID is null
--	set @ImportFamilyID = (select ID from FamilyPickList where Title like ''%Next Family #%'');

set @ImportErrorLine = 1;
declare @nextID bigint = isnull(dbo.MaxNumericStudentAndAccountID(),0) + 1;
set @ImportErrorLine = 2;
insert into SIS_UpdateLogin_view (xStudentID, AccountID, ThePassword)
	values ( @nextID, CAST(@nextID as nvarchar(18)), dbo.GeneratePassword() );
set @ImportErrorLine = 3;
declare @studentID int = (select StudentID from Students where xStudentID = @nextID);' + @crlf
	end
	else
	begin
		set @strCode = @strCode + '

declare @StudentID int;

set @StudentID = (
	select isnull(ImportStudentID,StudentID) from EnrollmentStudent
	where EnrollmentStudentID = ' + @table_pk_id_str + ');
	
if @StudentID<>'+cast(@StudentID as nvarchar(20))+'
raiserror(''You have changed the student link information on the Workflow page, please review the Workflow tab to make sure you want to link this enrollment to the selected student and then press the Create Import button again to refresh the import plan. Then you may retry the import.'',16,1);	

set @ImportErrorLine = 1;

delete from StudentContacts
	where RolesAndPermissions like ''%(EnrollMe%'' and studentID=@StudentID

delete from Medications
	where ReasonTaken like ''%(EnrollMe%'' and studentID=@StudentID
'
	end

	set @ErrLine = 4;

	declare @planTime nvarchar(20) = convert(nvarchar(20),getdate(),21);

	declare @importPlan nvarchar(MAX) = '
	<table class="glTableXY smallTD">
	<tr><th colspan="6" style="font-size:14px">'
	+ case when @new_import=1 
			then 'New Enrollment Import Plan'  
			else 
				(case when @re_import=1 then 'New Enrollment Re-Import plan' else 'Re-enrollment Import Plan' end)
			end + ', '+@planTime
	+'</th></tr><tbody>';
	
	declare @excludedFields nvarchar(MAX) = '
	<table class="glTableXY smallTD">
	<tr><th colspan="5" style="font-size:14px; color: maroon;">
	Items Excluded Due to no Corresponding Field in Gradelink</th></tr><tbody>';
	
	declare @rowNum int = 0;
	declare @rowColor nvarchar(10) = '';
	declare @priorTargetTable nvarchar(100) = ''
	declare @priorSourceTable nvarchar(100) = ''
	declare @TargetTableName nvarchar(100)
	declare @TargetFieldName nvarchar(100)
	declare @TargetValue nvarchar(MAX)
	declare @SourceTableName nvarchar(100)
	declare @SourceFieldName nvarchar(100)
	declare @SourceValue nvarchar(MAX)
	declare @UpdateCode nvarchar(MAX) = ''
	declare @InsertCode1 nvarchar(MAX) = ''
	declare @InsertCode2 nvarchar(MAX) = ''
	declare @sqlSourceValue nvarchar(MAX)
	declare @importableFields int = 0;
	declare @ImportThisField bit;

	Declare @NumLines int = (select COUNT(*) from #import)
	Declare @LineNumber int = 1
	While @LineNumber <= @NumLines
	Begin
		select 
			@TargetTableName = TargetTableName,
			@TargetFieldName = TargetFieldName, 
			@TargetValue = TargetValue,
			@SourceTableName = i.SourceTableName,
			@SourceFieldName = SourceFieldName, 
			@SourceValue = rtrim(ltrim(isnull(SourceValue,''))) 
			from #import i where line=@LineNumber
		set @LineNumber = @LineNumber + 1	
			
--		if @TargetTableName = '*None*'
--			continue;

		if @SourceFieldName='StudentID'
			set @sqlSourceValue = '@studentid'
		else if @SourceFieldName='EnrollFamilyID'
			set @sqlSourceValue = '@ImportFamilyID'
		else 
			set @sqlSourceValue 
				= case when @SourceValue='' 
					then '''''' -- 'null' 
					else 'N'''+replace(@SourceValue,'''','''''')+'''' end -- GC-25406 ~ JG --

		if @priorTargetTable +':'+ @priorSourceTable <> @TargetTableName +':'+ @SourceTableName
		begin
			if @TargetTableName != '*None*'
			begin
				set @rowNum = @rowNum + 1;
				if @rowNum%2 = 1
					set @rowColor = '#B3DCD2'; -- green
				else
					set @rowColor = '#BFCBE8'; -- blue
			end
			else
				set @rowColor = '#B3DCD2'; -- green

			set @str = 
				'<tr style="background-color:'+@rowColor
				+'"><td colspan="5" style="text-align:left; font-style:italic; '
				+'font-weight:bold; height:28px; vertical-align:bottom; color:black;">';

			set @str = @str	
				+'<span style="position: relative; top: 2px; font-size: 13px;">Transfer EnrollMe '
				+ replace(replace(@SourceTableName,'vEnrollment',''),'vEnroll','')
				+ ' to Gradelink ' + @TargetTableName + ' Table:</span>'

			set @str = @str + '</td>'

			set @str = @str+'</tr>'

			if @TargetTableName = '*None*'
			begin
				set @excludedFields = @excludedFields + @str 
			end
			else
				set @importPlan = @importPlan + @str 
			
			if @UpdateCode <> '' 
			begin
				if @priorTargetTable != '*None*'
				begin
					-- following code repeated below ---
					if (@new_import=0 or @priorTargetTable='Students') 
						and @priorTargetTable <> 'StudentContacts'
						and @priorTargetTable <> 'Medications'
					begin
						set @strCode = @strCode + 'set @ImportErrorLine = ' + 
							CAST(@ErrLine as nvarchar(10)) + @crlf
						set @ErrLine = @ErrLine + 1;

						IF @priorTargetTable like 'StudentMiscFields'
							set @strCode = @strCode + 'INSERT StudentMiscFields (StudentID) select @StudentID where @StudentID not in (Select StudentID from StudentMiscFields);' + @crlf

						IF @priorTargetTable like 'HealthHistory'
							set @strCode = @strCode + 'INSERT HealthHistory (StudentID) select @StudentID where @StudentID not in (Select StudentID from HealthHistory);' + @crlf

						set @strCode = @strCode + 'update '+@priorTargetTable+' set '+@UpdateCode
							+ ' where StudentID = @StudentID;' + @crlf
					end
					else
					begin
						set @strCode = @strCode + 'set @ImportErrorLine = ' + 
							CAST(@ErrLine as nvarchar(10)) + @crlf
						set @ErrLine = @ErrLine + 1;
						set @strCode = @strCode + 'insert into '+@priorTargetTable+' ('+@InsertCode1+')' + @crlf
							+'values ('+@InsertCode2+');' + @crlf
					end
				end
				set @UpdateCode = ''
				set @InsertCode1 = ''
				set @InsertCode2 = ''
				-- End of repeated code ---
			end
			set @priorTargetTable = @TargetTableName;
			set @priorSourceTable = @SourceTableName;
		end

		if @new_import = 1 or @re_import=1
		begin
			if @TargetFieldName = 'StudentID' and (isnull(@SourceValue,'') != '')
				set @SourceValue = @SourceValue + '(TBD)'
			else if @TargetFieldName = 'FamilyID' 
				set @SourceValue = @SourceValue + '(TBD)'
		end
		
		if @new_import=0 and @TargetFieldName = 'FamilyID'
			continue; -- re-enrolls already have or do not have fam id...

		declare @raceCodeHandling bit = case when @SourceFieldName='EthnicityAndRace' then 1 else 0 end;

		if (@raceCodeHandling=1)
		begin
			if @SourceValue='Decline to respond' and isnull(@TargetValue,'')<>''
			begin
				set @SourceValue = @SourceValue + '<br/>(''Decline'' will not import or overwrite existing race info)';
				set @ImportThisField = 0;
			end
			else 
				set @ImportThisField = case when isnull(@SourceValue,'')<>'' then 1 else 0 end;
			
			if @ImportThisField = 0
				set @raceCodes = null; -- ensure we don't import

		end
		else if @TargetFieldName='FamStat' and isnull(@TargetValue,'')<>''
			set @ImportThisField = 0; -- TFS 2593/2594
		else if @SourceFieldName like 'Import%' and isnull(@SourceValue,'')=''
			set @ImportThisField = 0; -- TFS 2586
		else if @SourceFieldName in ('Degree','Major', 'term_start') and isnull(@SourceValue,'')=''
			set @ImportThisField = 0; -- TFS 2586
		else if 
			-- Do not overwrite email with blank email values since users can maintain email addresses
			-- through parent logins and thus email address may exist in SIS that didn't even originate in EnrollMe.
			-- Note: This rule is imperfect because, rarely, a user will want to simply delete an email address
			-- via EnrollMe, but I'm guessing this is a very rare case.
			@SourceFieldName like '%Email%'
			-- Also do not overwrite StudentMiscFields that may have been imported
			-- and entered previously in SIS but not entered this time around.
			or @TargetTableName = 'StudentMiscFields'
		begin
			set @ImportThisField = case when isnull(@SourceValue,'')<>'' then 1 else 0 end;
		end
		else
		begin
			set @ImportThisField  
				= case when 
				 (isnull(@TargetValue,'')<>'' or isnull(@SourceValue,'')<>'') -- go ahead and erase blanked out fields now, 7/20/15
					and 
					not (@new_import=0 and @SourceFieldName='GradeLevel') -- don't overwrite gradelevel for reenrollments!
					/* 
					-- handled in source view now, comment out...
					and not (@re_import=1 and @SourceFieldName='SIS_Import_Status') -- don't overwrite status on re-import of new enrollment!
					*/
					then 1 else 0 end;
		end

		-- If Smart Send is enabled; opt-in by default for enrollment | For Re-enrollment respect existing opt-in value; import only if its null (default)
		IF ((@TargetTableName ='Students' and  @TargetFieldName in ('Phone1OptIn', 'Phone2OptIn', 'Phone3OptIn', 'Family2Phone1OptIn', 'Family2Phone2OptIn')) OR 
			(@TargetTableName ='StudentContacts' and  @TargetFieldName in ('Phone1OptIn', 'Phone2OptIn', 'Phone3OptIn')))
			BEGIN
				IF (ISNULL(@Comm2Enabled, 0) = 1)
					BEGIN
						IF ISNULL(@TargetValue, '') = ''
							SET @ImportThisField = 1
						ELSE
							SET @ImportThisField = 0
					END
				ELSE
					BEGIN
						SET @ImportThisField  = 0
					END
			END



		if isnull(@SourceValue,'') = ''  and @TargetTableName = '*None*'
			continue; -- no need to see excluded fields not entered

		set @sqlSourceValue = replace(@sqlSourceValue,'<br/>','; '); -- 7/20/15 - e.g., phones numbers are formatted for html
		
		if @ImportThisField = 1 and @raceCodeHandling = 0
		begin
			if @UpdateCode <> ''
			begin
				set @UpdateCode = @UpdateCode + ', '
				set @InsertCode1 = @InsertCode1 + ', '
				set @InsertCode2 = @InsertCode2 + ', '
			end
			set @UpdateCode = @UpdateCode + @TargetFieldName + '=' + @sqlSourceValue
			set @InsertCode1 = @InsertCode1 + @TargetFieldName
			set @InsertCode2 = @InsertCode2 + @sqlSourceValue
		end
		
		if @SourceValue is not null and PATINDEX('%HTML',@SourceFieldName)=0
		begin
			set @str = 
				+'<tr style="background-color:'+@rowColor+'">'
				+'<td style="padding-left: 15px; color: DarkBlue; max-width: 150px; word-wrap: break-word;">'
				+@SourceFieldName
				+'</td><td style="background-color: #E0E0E0; max-width: 150px; word-wrap: break-word;">'
				+@SourceValue
				+'</td>';

			if @TargetTableName != '*None*'
			begin
				set @str = @str
					+'<td style="text-align: center; vertical-align: top; width: 33px;">'
				if @ImportThisField = 1
					set @str = @str + '<img src="/images/arrow-right-blue.png" style="width:27px;"/>' 
				set @str = @str
					+'</td>'
					+'<td style="color: DarkBlue; max-width: 150px; word-wrap: break-word;">'+@TargetFieldName+'</td>'
					
				if @new_import=0 
						and @TargetTableName <> 'StudentContacts'
						and @TargetTableName <> 'Medications'
					set @str = @str
						+'</td><td style="max-width: 150px; word-wrap: break-word; background-color: #E0E0E0">'
						+@TargetValue+'</td>'
				else
					set @str = @str + '<td></td>'
			end		
			
			set @str = @str + '</tr>'

			if @TargetTableName = '*None*'
				set @excludedFields = @excludedFields + @str 
			else
				set @importPlan = @importPlan + @str 

			if @ImportThisField = 1
				set @importableFields = @importableFields + 1;				
		end
	end

	if @UpdateCode <> '' and @priorTargetTable != '*None*'
	begin
		-- following code repeated above
		if (@new_import=0 or @priorTargetTable='Students') 
			and @priorTargetTable <> 'StudentContacts'
			and @priorTargetTable <> 'Medications'
		begin
			set @strCode = @strCode + 'set @ImportErrorLine = ' + 
				CAST(@ErrLine as nvarchar(10)) + @crlf
			set @ErrLine = @ErrLine + 1;
			set @strCode = @strCode + 'update '+@priorTargetTable+' set '+@UpdateCode
				+ ' where StudentID = @StudentID;' + @crlf
		end
		else
		begin
			set @strCode = @strCode + 'set @ImportErrorLine = ' + 
				CAST(@ErrLine as nvarchar(10)) + @crlf
			set @ErrLine = @ErrLine + 1;
			set @strCode = @strCode + 'insert into '+@priorTargetTable+' ('+@InsertCode1 + ')' + @crlf
				+'values ('+@InsertCode2+')' + @crlf
		end
		set @UpdateCode = ''
		set @InsertCode1 = ''
		set @InsertCode2 = ''
		-- End of repeated code ---
	end

	set @strCode = @strCode + 'set @ImportErrorLine = ' + 
		CAST(@ErrLine as nvarchar(10)) + @crlf
	set @ErrLine = @ErrLine + 1;
	set @strCode = @strCode + 'update EnrollmentStudent '
		+'set ImportStudentID = @studentID '
/*
	if @new_import=0 -- make sure apps reassigned as re-enrollments get re-enroll (actual) Student ID
	begin
		set @strCode = @strCode +', StudentID = @studentID '
	end			
*/
	set @strCode = @strCode +' where EnrollmentStudentID='
		+ @table_pk_id_str + @crlf

	set @strCode = @strCode + 'set @ImportErrorLine = ' + 
		CAST(@ErrLine as nvarchar(10)) + @crlf
	set @ErrLine = @ErrLine + 1;

	if @raceCodes is not null
	begin
		set @strCode = @strCode + 'set @ImportErrorLine = ' + 
			CAST(@ErrLine as nvarchar(10)) + @crlf
		set @ErrLine = @ErrLine + 1;
		set @strCode = @strCode + 'exec dbo.EnrollmeImportRaceCodes @StudentID,'''+@raceCodes+''''
	end

	set @strCode = @strCode + 'set @ImportErrorLine = ' + 
		CAST(@ErrLine as nvarchar(10)) + @crlf
	set @ErrLine = @ErrLine + 1;

	update e1 
		set AutoImportNotes = @importPlan +
			'<tfoot><tr><td colspan="10" style="background-color: #AEB9D4; font-weight: bold; text-align: center; font-style: italic;">'	
			+ CAST(@importableFields as nvarchar(100)) 
			+ ' fields queued for import </td></tr></tfoot></table>',
		AutoImportExclusions = @excludedFields +
			'<tfoot><tr><td colspan="10" style="background-color: #AEB9D4; color: maroon; font-weight: bold; text-align: center; font-style: italic;">'	
			+ 'Note: This is only the list of built-in Enrollme fields that are not included in the import;<br/>'
			+ 'any custom fields that are specifc to your school are also excluded.</td></tr></tfoot></table>',
		AutoImportCode  -- null flags no code generated 
			= case when @strCode='' then null else @strCode end,
		AutoImportErrors = null
	from EnrollStudentStatusDates e1
		inner join  EnrollStudentStatusDates e2
		on e1.EnrollStudentStatusDateID = e2.EnrollStudentStatusDateID
		and e1.UpdateDate = (Select MAX(UpdateDate) 
	from EnrollStudentStatusDates e3 where e3.EnrollmentStudentID = e2.EnrollmentStudentID)
	where e1.EnrollmentStudentID = @table_pk_id

	if @@ROWCOUNT=0
	begin
		insert into EnrollStudentStatusDates
			(EnrollmentStudentID,FormStatus,AutoImportNotes,SessionID)
		values
			(@table_pk_id,'',@importPlan + CAST(@NumLines as nvarchar(100)) 
					+ ' fields queued for import </td></tr></tfoot></table>',@CurrentSessionID)
	end

	drop table #source
	drop table #target
	drop table #import

END TRY
BEGIN CATCH

	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
	
	DECLARE @errmsg nvarchar(MAX)
	DECLARE @errsev int
	DECLARE @errsta int
	DECLARE @errnum int
	DECLARE @errpro nvarchar(200)
	DECLARE @errlin int
	SELECT @errmsg = ERROR_MESSAGE(), 
		@errsev = ERROR_SEVERITY(), 
		@errsta = ERROR_STATE(),
		@errnum = ERROR_NUMBER(),
		@errpro = ERROR_PROCEDURE(),
		@errlin = ERROR_LINE()
	SET @errmsg = @errmsg + '<br/>Error #:   ' + CAST(@errnum as nvarchar(20))
						  + '<br/>Procedure: ' + @errpro
						  + '<br/>Line #:    ' + CAST(@errlin as nvarchar(20))
		
	RAISERROR(@errmsg,@errsev,@errsta)

END CATCH

IF @@TRANCOUNT > 0
	COMMIT TRANSACTION

end
GO
