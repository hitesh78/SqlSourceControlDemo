CREATE TABLE [dbo].[DiscussionMessages]
(
[DiscussionID] [int] NOT NULL,
[MessageID] [int] NOT NULL IDENTITY(1, 1),
[DateSubmitted] [datetime] NOT NULL,
[CreatedBy] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Message] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
