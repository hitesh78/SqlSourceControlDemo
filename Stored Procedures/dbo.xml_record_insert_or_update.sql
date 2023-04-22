SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[xml_record_insert_or_update]
(
	@mainPart nvarchar(50),
	@partName nvarchar(50),
    @table_name nchar(32),
    @entity nchar(32),
    @table_pk_id int,
    @xml_pk_id int = 0, -- 0 is the equiv of null but used for PK
    @xml_fields xml,
	@xml_pk_updates nvarchar(MAX) = '' OUTPUT -- return list of temp and new xml_pk_id's for new rows
)
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Cases where structured, XML data is translated and written to conventional SQL tables...
	if @entity = 'SIS-Student'
	begin
		-- Strip off RaceCodes tags...
		declare @race_codes nvarchar(2000) = 
			(SELECT doc.col.value('RaceCodes[1]', 'nvarchar(2000)') RaceCodes
				FROM @xml_fields.nodes('/STUDENTINFO') doc(col));
		set @race_codes = REPLACE(@race_codes,'; ',',');
		
		insert into StudentRace 
		select @table_pk_id as StudentID,IntegerID as RaceID
			from dbo.SplitCSVIntegers(@race_codes) x
			where IntegerID not in 
				(Select RaceID from StudentRace where StudentID=@table_pk_id)

		delete from StudentRace 
			where StudentID = @table_pk_id 
				and RaceID not in
					(Select IntegerID from dbo.SplitCSVIntegers(@race_codes) x)

		return
	end
	

	DECLARE @xmlPkUpdates nvarchar(MAX) = @xml_pk_updates
	DECLARE @new_pk_id numeric(38,0)
	
	IF @xml_pk_id = 0
	BEGIN
		SELECT  @xml_pk_id = t.c.value('xml_pk_id[1]','int')
		FROM    @xml_fields.nodes('/') AS t(c)
		--IF @xml_pk_id IS NULL
		--BEGIN
		--	SET @xml_pk_updates = '<error>Root PK_ID not found. No data saved.</error>'
		--	RETURN
		--END
	END
	
	---- And xml_pk_id for root element now that we have extracted it...
	--SET @xml_fields.modify(
	--'
	--	delete (/xml_pk_id[1])
	--')
	
	-- See if we have records from a nested form/entity to 
	-- explode to detail rows...
	--DECLARE @glFormId int = (
	--	SELECT glFormId FROM LKG.dbo.glForms
	--	WHERE entityName = @entity )
	DECLARE @glFormId int = (
	SELECT glFormId FROM LKG.dbo.vGlForms
	WHERE glFormName = @partName and glMainPart = @mainPart )
	
	IF @glFormId IS NOT NULL
	BEGIN
		DECLARE @tblSubForms TABLE
		(
			lineNumber int Identity(1,1) PRIMARY KEY
		,	glFormId int
		,	glFormName nvarchar(30)
		,	entityName nvarchar(32)
		)
		
		INSERT INTO @tblSubForms
		SELECT glFormId,glFormName,entityName
		FROM LKG.dbo.vGlForms
		WHERE (glParentFormId = @glFormId)
		-- 4/14/11 now we allow saving indivual parts (like glGrids) - Duke
		OR (glFormId = @glFormId) 
		--WHERE (@xml_pk_id IS NOT NULL AND glParentFormId = @glFormId)
		---- 4/14/11 now we allow saving indivual parts (like glGrids) - Duke
		--OR (@xml_pk_id IS NULL AND glFormId = @glFormId) 
		
		DECLARE @NumLines int = @@ROWCOUNT
		DECLARE @lineNumber int = 1
		
		WHILE @lineNumber <= @NumLines
		BEGIN
			DECLARE @subFormId int
			DECLARE @subFormName nvarchar(30)
			DECLARE @subFormEntityName nvarchar(32)

			SELECT 
				@subFormId = x.glFormId
			,	@subFormName = x.glFormName
			,	@subFormEntityName = x.entityName
			FROM @tblSubForms x
			WHERE lineNumber = @lineNumber

			--------------------------------------------------------
			-- Extract subform XML into separate xml_records rows --
			--------------------------------------------------------

			DECLARE @temp table
			(
				lineNumber2 int Identity(1,1) PRIMARY KEY
			,	xmlPkId int
			,	xmlData xml
			,	isEmpty bit
			)
			
			DELETE FROM @temp
			
			INSERT INTO @temp (xmlPkId, xmlData)
			SELECT  t.c.value('xml_pk_id[1]','int') as xmlPkId,
					t.c.query('node()[not(self::xml_pk_id)]') AS xmlData
			FROM    @xml_fields.nodes('/*') AS t(c)
			WHERE	t.c.exist('node()[not(self::xml_pk_id)]') = 1 AND
					t.c.value('local-name(.)', 'nvarchar(max)') = @subFormName
			DECLARE @NumLines2 int = @@ROWCOUNT

			--
			-- Before deleting any rows, make sure the table_pk_id and xml_pk_id both agree
			-- before allowing any possible (bad) xml_pk_id's to cause the deletion of 
			-- data originally associated with another table.  Should never happen, but
			-- this is a good sanity check.
			--
			DECLARE @DELETE_SANITY INT
			SELECT @DELETE_SANITY = COUNT(*) 
			FROM xml_records 
			WHERE table_pk_id != @table_pk_id
				AND xml_pk_id IN 
				(
					SELECT  t.c.value('xml_pk_id[1]','int') as xmlPkId
					FROM    @xml_fields.nodes('/*') AS t(c)
					WHERE	t.c.exist('node()[not(self::xml_pk_id)]') = 0 AND
							t.c.value('local-name(.)', 'nvarchar(max)') = @subFormName
				) 
			IF @DELETE_SANITY > 0
			BEGIN
				DECLARE @ERRMSG nvarchar(200) = 'SQL: xml_insert_or_update() - table_pk_id (' 
				+ cast(@table_pk_id as nvarchar(20)) +
				') and xml_pk_id(s) mismatch - updates for this record have not been completed'
				-- abort sproc and capture in ADO.NET
				RAISERROR(@ERRMSG,20,-1) WITH LOG
				RETURN
			END
			
			-- Delete rows with absolutely no field values
			-- TODO: Do we want to start to report on these via output parameter?
			-- TODO: Do we want to use deprecate flag/date instead of deleting?
			DELETE FROM xml_records 
			WHERE table_pk_id = @table_pk_id -- make sure a glitch in xml_pk_id cannot delete another records xml data!
				AND xml_pk_id IN 
				(
					SELECT  t.c.value('xml_pk_id[1]','int') as xmlPkId
					FROM    @xml_fields.nodes('/*') AS t(c)
					WHERE	t.c.exist('node()[not(self::xml_pk_id)]') = 0 AND
							t.c.value('local-name(.)', 'nvarchar(max)') = @subFormName
				) 

			-- Following needed becuase Identity column in @temp 
			-- does not re-seed each time through this loop
			-- and we cannot force table variables to do so 
			-- with a drop or truncate!!!
			DECLARE @firstRowNumber2 int = (SELECT MIN(lineNumber2) FROM @temp)

			DECLARE @lineNumber2 int = @firstRowNumber2
			WHILE @lineNumber2 <= @firstRowNumber2 + @NumLines2 - 1
			BEGIN
				DECLARE @xmlPkId int
				DECLARE @xmlData xml

				SELECT @xmlPkId=x.xmlPkId, @xmlData = x.xmlData
				FROM @temp x
				WHERE lineNumber2 = @lineNumber2

				IF @xmlPkId IS NULL
					SET @xmlPkUpdates = @xmlPkUpdates 
						+ '<error>No xml_pk_id for a row in sub form: '
						+ @subFormName
						+ '</error>'
				ELSE
				BEGIN
					-- Insert Sub Form data into its own xml_records row...
					EXEC dbo.xml_record_insert_or_update 
						@mainPart = @mainPart,
						@partName = @partName,
						@table_name = @table_name,
						@entity = @subFormEntityName,
						@table_pk_id = @table_pk_id,
						@xml_pk_id = @xmlPkId,
						@xml_fields = @xmlData,
						@xml_pk_updates = @xmlPkUpdates OUTPUT
						
					SET @xml_pk_updates = @xml_pk_updates + @xmlPkUpdates
				END
									
				SET @lineNumber2 = @lineNumber2 + 1
			END

			-- And remove the Sub Form data from xml_fields!
			SET @xml_fields.modify(
			'
				delete (//*[local-name()=sql:variable("@subFormName")])
			')
			
			SET @lineNumber = @lineNumber + 1
		END
	END

	IF @xml_pk_id IS NOT NULL
	BEGIN
	
		-- And xml_pk_id for root element now that we have extracted it...
		SET @xml_fields.modify(
		'
			delete (/xml_pk_id[1])
		')

		-- If this is a new record (xml_pk_id < 0) then add rather than update
		-- and capture database assigned xml_pk_id identity value for return to 
		-- client.
		IF @xml_pk_id <= 0
		BEGIN
			SET @xmlPkUpdates = @xmlPkUpdates 
				+ '<xml_row_added><temp_id>'+CAST(@xml_pk_id AS nvarchar(MAX))
				+ '</temp_id>'
				
			INSERT INTO xml_records
				(table_name, entityName, table_pk_id, xml_fields)
			VALUES 
				(@table_name, @entity, @table_pk_id, @xml_fields);
			SELECT @new_pk_id = @@IDENTITY

			SET @xmlPkUpdates = @xmlPkUpdates 
				+ '<assigned_id>'+CAST(@new_pk_id AS nvarchar(MAX))
				+ '</assigned_id></xml_row_added>'
		END
		ELSE
		BEGIN
			--
			-- Before updating any rows, make sure the table_pk_id and xml_pk_id agree
			-- before allowing any possible (bad) xml_pk_id's to cause the update of 
			-- data originally associated with another row.  Should never happen, but
			-- this is a good sanity check.
			--
			DECLARE @UPDATE_SANITY INT
			SELECT @UPDATE_SANITY = COUNT(*) 
				FROM xml_records
				WHERE (table_name != @table_name
					OR entityName != @entity
					OR table_pk_id != @table_pk_id)
					AND xml_pk_id = @xml_pk_id
			IF @UPDATE_SANITY > 0
			BEGIN
				DECLARE @ERRMSG2 nvarchar(200) = 'SQL: xml_insert_or_update() - table_pk_id (' 
				+ cast(@table_pk_id as nvarchar(20)) +
				') or table_name (' + RTRIM(@table_name) + ')' +
				' or entity (' + RTRIM(@entity) + ')' +
				', and xml_pk_id(s) mismatch - updates for this record have not been completed'
				-- abort sproc and capture in ADO.NET
				RAISERROR(@ERRMSG2,20,-1) WITH LOG
				RETURN
			END					

			UPDATE xml_records
			SET xml_fields = @xml_fields
			WHERE table_name = @table_name
				AND entityName = @entity
				and table_pk_id = @table_pk_id
				and xml_pk_id = @xml_pk_id
			IF @@ROWCOUNT=0
			BEGIN
				-- TODO: Production code should probably abort entire transaction on any errors...
				SET @xmlPkUpdates = @xmlPkUpdates 
					+ '<error>xml_pk_id = '
					+ CAST(@xml_pk_id AS nvarchar(MAX))
					+ ' not found for update.</error>'
			END
		END

		SET @xml_pk_updates = @xmlPkUpdates
	
	END
END




GO
