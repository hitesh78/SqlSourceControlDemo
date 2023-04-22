CREATE TABLE [dbo].[BinFilesToAdd]
(
[FileID] [int] NOT NULL IDENTITY(1, 1),
[FileSessionID] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileSize] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileData] [varbinary] (max) NOT NULL,
[FileSource] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileDescription] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileTimestamp] [datetime] NOT NULL,
[FileTags] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollSessionID] [int] NULL,
[StudentID] [bigint] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 11/12/2021
-- Description:	Delete BinfilesToAdd records older than 3 days
-- =============================================
CREATE   TRIGGER [dbo].[RemoveRecordsOlderThan3Days]
   ON  [dbo].[BinFilesToAdd]
   AFTER INSERT
AS 
BEGIN

	SET NOCOUNT ON;

	Delete From BinFilesToAdd
	Where
	FileTimestamp < DATEADD(day, -3, GETDATE());

END
GO
ALTER TABLE [dbo].[BinFilesToAdd] ADD CONSTRAINT [PK_BinFilesToAdd] PRIMARY KEY CLUSTERED ([FileID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
