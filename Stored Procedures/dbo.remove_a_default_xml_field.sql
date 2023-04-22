SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[remove_a_default_xml_field] @tag_to_clear nvarchar(100)
as
        declare @t1 nvarchar(102) = '<'+@tag_to_clear+'>'

        declare @t2 nvarchar(103) = '</'+@tag_to_clear+'>'

        ; with xml_defaults_for_reenrolls_not_yet_started as (
                select *, 
                        cast(xml_fields as nvarchar(max)) xml_fields_varchar,
                        charindex(@t1,cast(xml_fields as nvarchar(MAX))) from_pos,
                        charindex(@t2,cast(xml_fields as nvarchar(MAX))) + LEN(@t2)  thru_pos
                from xml_records x
                where table_pk_id not in (
                        select StudentID 
                        from EnrollmentStudent 
                        where SessionID = 
                                (select SessionID
                                        from vEnrollmentFormSettings)
                )
                and table_pk_id between 0 and 999999999
                and cast(xml_fields as nvarchar(max)) like '%<'+@tag_to_clear+'>%'
        ),
        xml_records_staged_to_remove_a_default as (
                select 
                        *,
                        substring(xml_fields_varchar, 1, from_pos-1) before_field,
                        substring(xml_fields_varchar, thru_pos, LEN(xml_fields_varchar)-thru_pos+1) after_field
                from xml_defaults_for_reenrolls_not_yet_started
        )
        /*
        select * 
        from xml_records_staged_to_remove_a_default
        */
        update x
        set xml_fields = cast(before_field + after_field as xml)
        from xml_records x
        inner join xml_records_staged_to_remove_a_default x2
        on x.xml_pk_id = x2.xml_pk_id
GO
