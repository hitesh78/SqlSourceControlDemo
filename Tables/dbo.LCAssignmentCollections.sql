CREATE TABLE [dbo].[LCAssignmentCollections]
(
[LCACID] [int] NOT NULL IDENTITY(1, 1),
[LCID] [int] NOT NULL,
[ACID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LCAssignmentCollections] ADD CONSTRAINT [PK_LCAssignmentCollections] PRIMARY KEY CLUSTERED ([LCACID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LCAssignmentCollections] ADD CONSTRAINT [FK_LCAssignmentCollections_AssignmentCollections] FOREIGN KEY ([ACID]) REFERENCES [dbo].[AssignmentCollections] ([ACID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LCAssignmentCollections] ADD CONSTRAINT [FK_LCAssignmentCollections_LessonPlanCollections] FOREIGN KEY ([LCID]) REFERENCES [dbo].[LessonPlanCollections] ([LCID]) ON DELETE CASCADE
GO
