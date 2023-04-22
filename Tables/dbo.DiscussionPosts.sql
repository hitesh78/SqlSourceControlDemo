CREATE TABLE [dbo].[DiscussionPosts]
(
[DiscussionID] [int] NOT NULL,
[ClassID] [int] NOT NULL,
[DateCreated] [datetime] NOT NULL,
[CreatedBy] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Title] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
