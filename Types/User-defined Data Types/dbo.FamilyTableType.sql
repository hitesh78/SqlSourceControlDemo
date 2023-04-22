CREATE TYPE [dbo].[FamilyTableType] AS TABLE
(
[Lname] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Father] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mother] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FamilyID] [int] NULL
)
GO
