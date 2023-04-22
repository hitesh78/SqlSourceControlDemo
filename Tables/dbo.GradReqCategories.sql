CREATE TABLE [dbo].[GradReqCategories]
(
[CategoryID] [int] NOT NULL IDENTITY(1, 1),
[CategoryName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CategoryDescription] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RequiredUnits] [decimal] (5, 2) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GradReqCategories] ADD CONSTRAINT [PK_GradReqCategories] PRIMARY KEY CLUSTERED ([CategoryID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
