CREATE TABLE [dbo].[ClassesStudentsCF]
(
[CSCFID] [int] NOT NULL IDENTITY(1, 1),
[CSID] [int] NOT NULL,
[CustomFieldID] [int] NOT NULL,
[CFGrade] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CFComments] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClassesStudentsCF] ADD CONSTRAINT [PK_ClassesStudentsCF] PRIMARY KEY CLUSTERED ([CSCFID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CSID] ON [dbo].[ClassesStudentsCF] ([CSID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CustomFieldID] ON [dbo].[ClassesStudentsCF] ([CustomFieldID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClassesStudentsCF] ADD CONSTRAINT [FK_ClassesStudentsCF_ClassesStudents] FOREIGN KEY ([CSID]) REFERENCES [dbo].[ClassesStudents] ([CSID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ClassesStudentsCF] ADD CONSTRAINT [FK_ClassesStudentsCF_CustomFields] FOREIGN KEY ([CustomFieldID]) REFERENCES [dbo].[CustomFields] ([CustomFieldID]) ON DELETE CASCADE
GO
