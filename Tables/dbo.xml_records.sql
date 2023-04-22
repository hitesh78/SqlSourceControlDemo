CREATE TABLE [dbo].[xml_records]
(
[xml_pk_id] [int] NOT NULL IDENTITY(1, 1),
[table_name] [nchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[entityName] [nchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[table_pk_id] [bigint] NULL,
[xml_fields] [xml] NOT NULL,
[records_version] [int] NULL,
[deprecated] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[xml_records] ADD CONSTRAINT [PK_xml_records] PRIMARY KEY CLUSTERED ([xml_pk_id]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
