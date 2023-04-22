CREATE TABLE [dbo].[DayCare]
(
[DayCareID] [int] NOT NULL IDENTITY(1, 1),
[DateTime] [smalldatetime] NOT NULL,
[StudentID] [int] NOT NULL,
[ContactID] [int] NOT NULL,
[ContactInitials] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CheckInOrOut] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdminName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Comments] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClassID] [int] NULL
) ON [PRIMARY]
GO
