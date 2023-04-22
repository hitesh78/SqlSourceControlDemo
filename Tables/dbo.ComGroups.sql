CREATE TABLE [dbo].[ComGroups]
(
[GroupID] [int] NOT NULL IDENTITY(1, 1),
[TeacherID] [int] NULL,
[GroupName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GroupType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
