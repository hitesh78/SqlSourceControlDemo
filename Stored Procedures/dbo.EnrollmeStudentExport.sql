SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- ===========================================================================
-- Author:		Freddy
-- Create date: 2021-10-01
-- Description:	Export Data from EnrollMeStudent based on Fields selected

-- ===============================Script ======================================
CREATE             Procedure [dbo].[EnrollmeStudentExport]
(
	@Fields nvarchar(max),
	@Session nvarchar(10)
)
AS
BEGIN
	Declare @cmd nvarchar(max)
	Declare @data Table(entityName nvarchar(50), table_pk_id bigint, xml_fields xml);
	Declare @parsedData Table(entityName nvarchar(50), PKID bigint, tag nvarchar(100), val nvarchar(100));
	Declare @splitFields Table(fieldName nvarchar(100), src nvarchar(20));
	Declare @tableFields Table(fieldName nvarchar(100));

	Insert into @data
	select 
		entityName,
		table_pk_id,
		xml_fields
	from vxml_records 
	where table_name = 'vEnrollmentStudent';

	Insert into @parsedData
	select 
		d.entityName,
		d.table_pk_id as PKID,
		t.c.value('local-name(.)', 'nvarchar(100)') as tag,
		t.c.value('(.)[1]', 'nvarchar(100)') as val
	From @data d
		outer apply d.xml_fields.nodes('/*') t(c)

	--select distinct tag from @parsedData
	
	Insert into @tableFields
	SELECT 
		COLUMN_NAME as fieldName
   FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = N'vEnrollmentStudent' and COLUMN_NAME <> 'SessionID' and COLUMN_NAME not like '%HTML%' 
	Group by COLUMN_NAME,ORDINAL_POSITION
	Having COUNT(case when (rtrim(ltrim( COLUMN_NAME )) = '' or rtrim(ltrim( COLUMN_NAME )) is null) then NULL else rtrim(ltrim(COLUMN_NAME)) end) > 0;

	--select * from @tableFields

	insert into @splitFields
	select 
		a.TheString as fieldName,
		CASE
			WHEN (select distinct tag from @parsedData where tag = a.TheString) is not null
			THEN 'X'
			WHEN (select fieldName from @tableFields where fieldName = a.TheString) is not null
			THEN 'T'
			ELSE null
		END as src
	from dbo.SplitCSVStrings(@Fields) a

	--select * from @splitFields

	DECLARE @xFields nvarchar(max) 
	SELECT @xFields = COALESCE(@xFields + ', ', '') + fieldName
	FROM @splitFields
	WHERE src = 'X'
	
	DECLARE @tFields nvarchar(max) 
	SELECT @tFields = COALESCE(@tFields + ', ', '') + fieldName
	FROM @splitFields
	WHERE src = 'T'
if  len(@xFields) > 0
Begin
Set @cmd = '
	
	Select * From (
		select ' +  @tFields + '
		from vEnrollmentStudent
		where SessionID = ' + @Session + ' and Lname != '' and Fname != ''
	) es
	full outer join (
		Select *
		From (
			select 
				d.table_pk_id as PKID,
				t.c.value(''local-name(.)'', ''nvarchar(100)'') as tag,
				t.c.value(''(.)[1]'', ''nvarchar(100)'') as val
			From (
				select 
					table_pk_id,
					xml_fields
				from vxml_records 
				where table_name = ''vEnrollmentStudent''
			) d
			outer apply d.xml_fields.nodes(''/*'') t(c)
		) as sourceTable
		PIVOT
		(
			MIN(val)
			FOR tag in (' + @xFields + ')
		) as pt
	) xd
	on es.StudentID = xd.PKID
	where xd.PKID > 0 and es.Lname != '' and es.Fname != ''
	'
	EXEC sp_executesql @cmd
End
else
Begin
Set @cmd = '
	select ' + @Fields + '
    from vEnrollmentStudent where SessionID = ' + @Session + ' and Lname != '' and Fname != ''
    '
	EXEC sp_executesql @cmd
End
END

GO
