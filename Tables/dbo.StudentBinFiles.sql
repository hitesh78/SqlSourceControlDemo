CREATE TABLE [dbo].[StudentBinFiles]
(
[SBID] [int] NOT NULL IDENTITY(1, 1),
[StudentID] [int] NOT NULL,
[FileID] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[StudentBinFiles_Delete_Trigger]
 on [dbo].[StudentBinFiles]
 After Delete
As

 Delete from BinFiles 
	Where FileID in 
		( select FileID from deleted )

GO
ALTER TABLE [dbo].[StudentBinFiles] ADD CONSTRAINT [PK_StudentBinFiles] PRIMARY KEY CLUSTERED ([SBID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FileID] ON [dbo].[StudentBinFiles] ([FileID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StudentID] ON [dbo].[StudentBinFiles] ([StudentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StudentBinFiles] ADD CONSTRAINT [FK_StudentBinFiles_BinFiles] FOREIGN KEY ([FileID]) REFERENCES [dbo].[BinFiles] ([FileID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[StudentBinFiles] ADD CONSTRAINT [FK_StudentBinFiles_Students] FOREIGN KEY ([StudentID]) REFERENCES [dbo].[Students] ([StudentID]) ON DELETE CASCADE
GO
