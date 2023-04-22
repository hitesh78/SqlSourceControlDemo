CREATE TABLE [dbo].[GradReqCategoryHistory]
(
[CHistoryID] [int] NOT NULL IDENTITY(1, 1),
[CDate] [date] NOT NULL,
[CXML] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GradReqCategoryHistory] ADD CONSTRAINT [PK_GradReqCategoryHistory] PRIMARY KEY CLUSTERED ([CHistoryID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
