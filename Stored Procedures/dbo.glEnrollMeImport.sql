SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[glEnrollMeImport] (@table_name nvarchar(50), @table_pk_id int)
as
begin

DECLARE @errmsg nvarchar(MAX) = null
DECLARE @errsev int
DECLARE @errsta int
DECLARE @errnum int
DECLARE @errpro nvarchar(4000)
DECLARE @errlin int
DECLARE @table_pk_id_str nvarchar(20) = cast(@table_pk_id as nvarchar(20))

--BEGIN TRANSACTION
--BEGIN TRY

	declare @importCode nvarchar(MAX)
--	declare @importNotes nvarchar(MAX)

	select	@importCode = e1.AutoImportCode --,
--			@importNotes = e1.AutoImportNotes
		from EnrollStudentStatusDates e1
		inner join EnrollmentStudent es
		on es.EnrollmentStudentID = e1.EnrollmentStudentID
		inner join  EnrollStudentStatusDates e2
		on e1.EnrollStudentStatusDateID = e2.EnrollStudentStatusDateID
		and e1.UpdateDate = (Select MAX(UpdateDate) 
			from EnrollStudentStatusDates e3 where e3.EnrollmentStudentID = e2.EnrollmentStudentID)
		where es.FormStatus='Approved' and e1.AutoImportCode is not null
			and e1.EnrollmentStudentID = @table_pk_id

	if @importCode is not null --and @importCode>''
	begin
		set @importCode = '
DECLARE @errmsg nvarchar(MAX) = ''''
DECLARE @errsev int
DECLARE @errsta int
DECLARE @errnum int
DECLARE @errpro nvarchar(4000)
DECLARE @errlin int
BEGIN TRANSACTION
BEGIN TRY
		' + @importCode + '
END TRY
BEGIN CATCH

	IF @@TRANCOUNT > 0
		ROLLBACK

	SELECT @errmsg = ERROR_MESSAGE(), 
		@errsev = ERROR_SEVERITY(), 
		@errsta = ERROR_STATE(),
		@errnum = ERROR_NUMBER(),
		@errpro = ERROR_PROCEDURE(),
		@errlin = ERROR_LINE()
		
	IF @errpro is null
		set @errpro = ''(Import Map Script)'';

	SET @errmsg = @errmsg + isnull(''<br/>Error #:   '' + CAST(@errnum as nvarchar(20)),'''')
						  + ''<br/>Procedure: '' + @errpro
						  + isnull(''<br/>Line #:    '' 
						  + CAST(@ImportErrorLine/*declared in plan code*/ as nvarchar(20)),'''')

	update EnrollStudentStatusDates 
		set AutoImportErrors = @errmsg
		where EnrollStudentStatusDateID = 
			(select EnrollStudentStatusDateID 
				from vEnrollStudentStatusDates
				where EnrollmentStudentID = '+@table_pk_id_str+');
				
END CATCH

IF @errmsg is null or @errmsg=''''
begin
	insert into EnrollStudentStatusDates 
		(EnrollmentStudentID,FormStatus,ImportStudentID,SessionID,AutoImportErrors)
	select '+@table_pk_id_str+', ''Imported'', ImportStudentID, SessionID, null
	from EnrollmentStudent where EnrollmentStudentID = '+@table_pk_id_str+'
end
IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
';

		exec (@importCode);
		
		if @errmsg is not null and @errmsg!=''
			RAISERROR(@errmsg,16,2)

	end

--END TRY
--BEGIN CATCH

--	IF @@TRANCOUNT > 0
--		ROLLBACK TRANSACTION

--	SELECT @errmsg = ERROR_MESSAGE(), 
--		@errsev = ERROR_SEVERITY(), 
--		@errsta = ERROR_STATE(),
--		@errnum = ERROR_NUMBER(),
--		@errpro = ERROR_PROCEDURE(),
--		@errlin = ERROR_LINE()
--	if CHARINDEX('(Import Map Script)', @errmsg) = -1
--	begin
--		SET @errmsg = @errmsg + '<br/>Error #:   ' + CAST(@errnum as nvarchar(20))
--							  + '<br/>Procedure: ' + @errpro
--							  + '<br/>Line #:    ' + CAST(@errlin as nvarchar(20))
--	end
--	RAISERROR(@errmsg,@errsev,@errsta)

--END CATCH

--IF @@TRANCOUNT > 0
--	COMMIT TRANSACTION
		
end

GO
