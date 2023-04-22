CREATE TYPE [dbo].[GradeScaleImportTableType] AS TABLE
(
[GradeScaleID] [int] NULL,
[GradeSymbol] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GradeOrder] [int] NULL,
[GradeDescription] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
