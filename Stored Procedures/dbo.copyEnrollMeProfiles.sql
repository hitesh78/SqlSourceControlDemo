SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[copyEnrollMeProfiles] (@table_name nvarchar(50), @table_pk_id int) as
begin

	declare @src nvarchar(50) = (select SchoolID from LKG_OnlineFormSettings
							where ID = (Select Profiles_SchoolID from EnrollmentFormSettings))
	declare @dst nvarchar(50) = (select DB_NAME())

	declare @SessionID int
	declare @Import_Settings bit
	declare @Import_HTML bit
	declare @Clear_HTML bit
	declare @Add_Grade_Options bit
	declare @Import_Programs bit
	declare @Clear_Programs bit
	declare @numRows int

	declare @sql nvarchar(MAX)
	
	select 
		@SessionID = SessionID,
		@Import_Settings = Profiles_Import_Settings,
		@Import_HTML = Profiles_Import_HTML,
		@Clear_HTML = Profiles_Clear_HTML,
		@Add_Grade_Options = Profiles_Add_Grade_Options,
		@Import_Programs = Profiles_Import_Programs,
		@Clear_Programs = Profiles_Clear_Programs
	from EnrollmentFormSettings
							
	if @Import_Settings = 1
	begin
		set @sql = '
			if (select count(*) from [13].dbo.EnrollmentFormSettings) > 0
			begin
				delete from [15].dbo.EnrollmentFormSettings
				
				insert into [15].dbo.EnrollmentFormSettings
				(
					ID,
					SessionID,
					RelegiousFields,
					EnrollFormCSS,
					EnrollSiteBannerHTML,
					EnrollSiteBannerOption,
					HomeChurch,
					Configurable_Fields_To_Incl,
					New_Enroll_Fields_To_Incl,
					EnrollMeDemo,
					StartedStatusMsg,
					SubmittedStatusMsg,
					InProcessStatusMsg,
					PendingStatusMsg,
					CancelledStatusMsg,
					ApprovedStatusMsg,
					NotApprovedStatusMsg,
					EnableStartedStatusEmail,
					EnableSubmittedStatusEmail,
					EnableInProcessStatusEmail,
					EnablePendingStatusEmail,
					EnableCancelledStatusEmail,
					EnableApprovedStatusEmail,
					EnableNotApprovedStatusEmail,
					SubscriptionRenewal,
					UDF_Title_1,
					UDF_value_1,
					UDF_Title_2,
					UDF_value_2,
					UDF_Title_3,
					UDF_value_3,
					UDF_Title_4,
					UDF_value_4,
					UDF_Title_5,
					UDF_value_5,
					UDF_Title_6,
					UDF_value_6,
					UDF_Title_7,
					UDF_value_7,
					UDF_Title_8,
					UDF_value_8,
					UDF_Title_9,
					UDF_value_9
				)
			select 	ID,
					@SessionID as SessionID,
					RelegiousFields,
					EnrollFormCSS,
					EnrollSiteBannerHTML,
					EnrollSiteBannerOption,
					HomeChurch,
					Configurable_Fields_To_Incl,
					New_Enroll_Fields_To_Incl,
					EnrollMeDemo,
					StartedStatusMsg,
					SubmittedStatusMsg,
					InProcessStatusMsg,
					PendingStatusMsg,
					CancelledStatusMsg,
					ApprovedStatusMsg,
					NotApprovedStatusMsg,
					EnableStartedStatusEmail,
					EnableSubmittedStatusEmail,
					EnableInProcessStatusEmail,
					EnablePendingStatusEmail,
					EnableCancelledStatusEmail,
					EnableApprovedStatusEmail,
					EnableNotApprovedStatusEmail,
					SubscriptionRenewal,
					UDF_Title_1,
					UDF_value_1,
					UDF_Title_2,
					UDF_value_2,
					UDF_Title_3,
					UDF_value_3,
					UDF_Title_4,
					UDF_value_4,
					UDF_Title_5,
					UDF_value_5,
					UDF_Title_6,
					UDF_value_6,
					UDF_Title_7,
					UDF_value_7,
					UDF_Title_8,
					UDF_value_8,
					UDF_Title_9,
					UDF_value_9
				FROM
					[13].dbo.EnrollmentFormSettings
			end
		'
		set @sql = replace(replace(replace(@sql,'[13]','['+@src+']'),'[15]','['+@dst+']'),'@SessionID',@SessionID)
		exec (@sql)
	end

	if @Add_Grade_Options = 1
	begin
		set @sql = '
			insert into [15].dbo.GradeLevelOptions
				(GradeLevelOption,GradeLevel)
			select GradeLevelOption,GradeLevel 
				from [13].dbo.GradeLevelOptions
				where ltrim(GradeLevelOption) 
					not in (Select ltrim(GradeLevelOption) 
						from [15].dbo.GradeLevelOptions)
		'
		set @sql = replace(replace(replace(@sql,'[13]','['+@src+']'),'[15]','['+@dst+']'),'@SessionID',@SessionID)
		exec (@sql)
	end

	if @Import_Programs = 1
	begin
		set @sql = '
			insert into [15].dbo.Enrollmentprograms
				(SessionID,EnrollmentProgram)
			select * 
			from 
				(select distinct @SessionID as SessionID,ep.EnrollmentProgram 
				from [13].dbo.Enrollmentprograms ep)
					missing_programs
			where EnrollmentProgram 
			not in (Select distinct EnrollmentProgram from [15].dbo.Enrollmentprograms)
		'
		set @sql = replace(replace(replace(@sql,'[13]','['+@src+']'),'[15]','['+@dst+']'),'@SessionID',@SessionID)
		exec (@sql)
	end

	if @Import_HTML = 1
	begin
		set @sql = '
					select @numRows = COUNT(*)
					from [13].dbo.Enrollmentprograms ep
					inner join [13].dbo.OnlineFormPages ofp
					on ep.EnrollmentProgramID = ofp.EnrollmentProgramID
					left join [15].dbo.EnrollmentPrograms ep2
					on ep.EnrollmentProgram = ep2.EnrollmentProgram
					where ep2.EnrollmentProgram is null
		'
		set @sql = replace(replace(replace(@sql,'[13]','['+@src+']'),'[15]','['+@dst+']'),'@SessionID',@SessionID)
		exec sp_executesql @sql, N'@numRows int output', @numRows output
		if @numRows > 0
		begin
			raiserror('HTML pages were not imported because one or more programs referenced in source HTML pages were not found. Please import these programs.',16,1)
			return		
		end


		set @sql = '
					select @numRows = COUNT(*)
					from [13].dbo.GradeLevelOptions ep
					inner join [13].dbo.OnlineFormPages ofp
					on ep.GradeLevelOptionID = ofp.GradeLevelOptionID
					left join [15].dbo.GradeLevelOptions ep2
					on ep.GradeLevelOption = ep2.GradeLevelOption
					where ep2.GradeLevelOption is null
		'
		set @sql = replace(replace(replace(@sql,'[13]','['+@src+']'),'[15]','['+@dst+']'),'@SessionID',@SessionID)
		exec sp_executesql @sql, N'@numRows int output', @numRows output
		if @numRows > 0
		begin
			raiserror('HTML pages were not imported because one or more grade level options referenced in source HTML pages were not found. Please import these grade level options.',16,1)
			return		
		end


		set @sql = '
			insert into [15].dbo.OnlineFormPages (
				EnrollmentProgramID,
				FormName,
				WizardPage,
				SessionID,
				GradeLevelFrom,
				GradeLevelThru,
				FormType,
				FormStatus,
				PageHtml,
				GradeLevelOptionID,
				ShowOrHidePage)
			select
				(select max(EnrollmentProgramID) 
					from [15].dbo.EnrollmentPrograms
					where EnrollmentProgram = 
						(select EnrollmentProgram from [13].dbo.EnrollmentPrograms 
							where EnrollmentProgramID = ofp.EnrollmentProgramID)
					) as EnrollmentProgramID,
				FormName,
				WizardPage,
				@SessionID,
				GradeLevelFrom,
				GradeLevelThru,
				FormType,
				FormStatus,
				PageHtml,
				(select max(GradeLevelOptionID) 
					from [15].dbo.GradeLevelOptions
					where GradeLevelOption = 
						(select GradeLevelOption from [13].dbo.GradeLevelOptions 
							where GradeLevelOptionID = ofp.GradeLevelOptionID)
					) as GradeLevelOptionID,
				ShowOrHidePage
			from
				[13].dbo.OnlineFormPages ofp
		'
		if @Clear_HTML = 1
		begin
		set @sql = '
			delete from [15].dbo.OnlineFormPages
		' + @sql
		end
		set @sql = replace(replace(replace(@sql,'[13]','['+@src+']'),'[15]','['+@dst+']'),'@SessionID',@SessionID)
		exec (@sql)

	end

end


GO
