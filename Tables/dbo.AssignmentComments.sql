CREATE TABLE [dbo].[AssignmentComments]
(
[AssignmentCommentID] [int] NOT NULL IDENTITY(1, 1),
[TeacherID] [int] NOT NULL,
[CommentOrder] [tinyint] NOT NULL,
[CommentText] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AssignmentComments] ADD CONSTRAINT [PK_AssignmentComments] PRIMARY KEY CLUSTERED ([AssignmentCommentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AssignmentCommentID] ON [dbo].[AssignmentComments] ([AssignmentCommentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AssignmentComments] ADD CONSTRAINT [FK_AssignmentComments_AssignmentComments] FOREIGN KEY ([AssignmentCommentID]) REFERENCES [dbo].[AssignmentComments] ([AssignmentCommentID])
GO
