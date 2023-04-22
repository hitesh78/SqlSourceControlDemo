CREATE TABLE [dbo].[OnlineReports]
(
[ERID] [int] NOT NULL IDENTITY(1, 1),
[ReportName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StudentID] [int] NOT NULL,
[URL] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PublishedTimeStamp] [datetime] NULL CONSTRAINT [DF_OnlineReports_PublishedTimeStamp] DEFAULT (NULL),
[ViewedTimeStamp] [datetime] NULL CONSTRAINT [DF_OnlineReports_ViewedTimeStamp] DEFAULT (NULL),
[ViewedAck] [bit] NOT NULL CONSTRAINT [DF_Table_1_ViewAck] DEFAULT ((0)),
[ParentComment] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__OnlineRep__Paren__4007E458] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OnlineReports] ADD CONSTRAINT [PK_OnlineReports] PRIMARY KEY CLUSTERED ([ERID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StudentID] ON [dbo].[OnlineReports] ([StudentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OnlineReports] ADD CONSTRAINT [FK_OnlineReports_Students] FOREIGN KEY ([StudentID]) REFERENCES [dbo].[Students] ([StudentID]) ON DELETE CASCADE
GO
