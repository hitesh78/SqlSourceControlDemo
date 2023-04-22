CREATE TYPE [dbo].[ClassImportTableType] AS TABLE
(
[ClassTitle] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportTitle] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TeacherID] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SecondaryTeacherID] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClassTypeID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportOrder] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Period] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Location] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GradeScale] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Units] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
