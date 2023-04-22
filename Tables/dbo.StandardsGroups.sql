CREATE TABLE [dbo].[StandardsGroups]
(
[SGID] [int] NOT NULL IDENTITY(1, 1),
[GroupName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StandardsGroups] ADD CONSTRAINT [PK_StandardGroups] PRIMARY KEY CLUSTERED ([SGID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO