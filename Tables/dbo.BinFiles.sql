CREATE TABLE [dbo].[BinFiles]
(
[FileID] [int] NOT NULL IDENTITY(1, 1),
[FileName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileSize] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileData] [varbinary] (max) NOT NULL,
[FileSource] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileDescription] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileTimestamp] [datetime] NOT NULL,
[EnrollSessionID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BinFiles] ADD CONSTRAINT [PK_BinFiles] PRIMARY KEY CLUSTERED ([FileID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
