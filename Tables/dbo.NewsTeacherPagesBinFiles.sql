CREATE TABLE [dbo].[NewsTeacherPagesBinFiles]
(
[NTPBID] [int] NOT NULL IDENTITY(1, 1),
[PostID] [int] NOT NULL,
[FileID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NewsTeacherPagesBinFiles] ADD CONSTRAINT [PK_NewsTeacherPagesBinFiles] PRIMARY KEY CLUSTERED ([NTPBID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NewsTeacherPagesBinFiles] ADD CONSTRAINT [FK_NewsTeacherPagesBinFiles_BinFiles] FOREIGN KEY ([FileID]) REFERENCES [dbo].[BinFiles] ([FileID])
GO
ALTER TABLE [dbo].[NewsTeacherPagesBinFiles] ADD CONSTRAINT [FK_NewsTeacherPagesBinFiles_NewsTeacherPages] FOREIGN KEY ([PostID]) REFERENCES [dbo].[NewsTeacherPages] ([PostID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[NewsTeacherPagesBinFiles] ADD CONSTRAINT [FK_NewsTeacherPagesBinFiles_NewsTeacherPagesBinFiles] FOREIGN KEY ([NTPBID]) REFERENCES [dbo].[NewsTeacherPagesBinFiles] ([NTPBID])
GO
