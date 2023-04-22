CREATE TYPE [dbo].[StaffImportTableType] AS TABLE
(
[TeacherID] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StaffTitle] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobTitle] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolEmail] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PersonalEmail] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
