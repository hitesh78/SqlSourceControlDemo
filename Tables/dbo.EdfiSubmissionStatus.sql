CREATE TABLE [dbo].[EdfiSubmissionStatus]
(
[PostID] [int] NOT NULL IDENTITY(1, 1),
[JobID] [uniqueidentifier] NOT NULL,
[PostStartDateUTC] [datetime] NOT NULL,
[PostEndDateUTC] [datetime] NULL,
[PostUser] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CalendarYear] [int] NULL,
[edfiResource] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edfiResourceOrder] [int] NULL,
[PostStatus] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResourceTitle] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostRequest] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostResults] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dataSnapshot] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dataDeleted] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EdfiSubmissionStatus] ADD CONSTRAINT [PK_EdfiSubmissionStatus] PRIMARY KEY CLUSTERED ([PostID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EdfiSubmissionStatus] ON [dbo].[EdfiSubmissionStatus] ([CalendarYear], [edfiResource], [PostStartDateUTC], [JobID]) ON [PRIMARY]
GO
