CREATE TABLE [dbo].[AssignmentBinFiles]
(
[ABID] [int] NOT NULL IDENTITY(1, 1),
[AssignmentID] [int] NOT NULL,
[FileID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AssignmentBinFiles] ADD CONSTRAINT [PK_AssignmentBinFiles] PRIMARY KEY CLUSTERED ([ABID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AssignmentID] ON [dbo].[AssignmentBinFiles] ([AssignmentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FileID] ON [dbo].[AssignmentBinFiles] ([FileID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AssignmentBinFiles] ADD CONSTRAINT [FK_AssignmentBinFiles_Assignments] FOREIGN KEY ([AssignmentID]) REFERENCES [dbo].[Assignments] ([AssignmentID])
GO
ALTER TABLE [dbo].[AssignmentBinFiles] ADD CONSTRAINT [FK_AssignmentBinFiles_BinFiles] FOREIGN KEY ([FileID]) REFERENCES [dbo].[BinFiles] ([FileID])
GO
