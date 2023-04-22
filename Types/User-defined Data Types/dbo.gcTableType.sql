CREATE TYPE [dbo].[gcTableType] AS TABLE
(
[ClassID] [int] NULL,
[gcCourseWorkID] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[glUserID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PointsEarned] [real] NULL,
[Completed] [bit] NULL
)
GO
