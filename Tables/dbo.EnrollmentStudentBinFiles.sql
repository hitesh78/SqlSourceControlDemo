CREATE TABLE [dbo].[EnrollmentStudentBinFiles]
(
[ESBID] [int] NOT NULL IDENTITY(1, 1),
[StudentID] [bigint] NOT NULL,
[FileID] [int] NOT NULL,
[EnrollSessionID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EnrollmentStudentBinFiles] ADD CONSTRAINT [PK_EnrollmentStudentBinFiles] PRIMARY KEY CLUSTERED ([ESBID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FileID] ON [dbo].[EnrollmentStudentBinFiles] ([FileID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EnrollmentStudentBinFiles] ADD CONSTRAINT [FK_EnrollmentStudentBinFiles_BinFiles] FOREIGN KEY ([FileID]) REFERENCES [dbo].[BinFiles] ([FileID]) ON DELETE CASCADE
GO
