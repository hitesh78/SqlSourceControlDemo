CREATE TABLE [dbo].[TeacherBinFiles]
(
[TBID] [int] NOT NULL IDENTITY(1, 1),
[TeacherID] [int] NOT NULL,
[FileID] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[TeacherBinFiles_Delete_Trigger]
 on [dbo].[TeacherBinFiles]
 After Delete
As

 Delete from BinFiles 
	Where FileID in 
		( select FileID from deleted )


GO
ALTER TABLE [dbo].[TeacherBinFiles] ADD CONSTRAINT [PK_TeacherBinFiles] PRIMARY KEY CLUSTERED ([TBID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FileID] ON [dbo].[TeacherBinFiles] ([FileID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TeacherID] ON [dbo].[TeacherBinFiles] ([TeacherID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TeacherBinFiles] ADD CONSTRAINT [FK_TeacherBinFiles_BinFiles] FOREIGN KEY ([FileID]) REFERENCES [dbo].[BinFiles] ([FileID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[TeacherBinFiles] ADD CONSTRAINT [FK_TeacherBinFiles_Teachers] FOREIGN KEY ([TeacherID]) REFERENCES [dbo].[Teachers] ([TeacherID]) ON DELETE CASCADE
GO
