CREATE TABLE [dbo].[ComGroupIncludes]
(
[IncludeID] [int] NOT NULL IDENTITY(1, 1),
[GroupID] [int] NOT NULL,
[PersonType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Grade] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Division] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Class] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tags] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
