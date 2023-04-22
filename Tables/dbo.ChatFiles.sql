CREATE TABLE [dbo].[ChatFiles]
(
[FileName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ETagAWS] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
