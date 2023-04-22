CREATE TABLE [dbo].[NewsTeacherPages]
(
[PostID] [int] NOT NULL IDENTITY(1, 1),
[PostType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[subPostType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isPublished] [bit] NOT NULL,
[PostCollectionID] [int] NULL,
[TeacherID] [int] NOT NULL,
[AuthorID] [int] NOT NULL,
[DisplayTitle] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClassID] [int] NOT NULL,
[DateAuthored] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateLastSaved] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DatePublished] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostContent] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PostTitle] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NewsTeacherPages] ADD CONSTRAINT [PK_NewsTeacherPages] PRIMARY KEY CLUSTERED ([PostID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
