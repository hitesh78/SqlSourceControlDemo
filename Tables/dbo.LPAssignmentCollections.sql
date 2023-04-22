CREATE TABLE [dbo].[LPAssignmentCollections]
(
[LPACID] [int] NOT NULL IDENTITY(1, 1),
[LPID] [int] NOT NULL,
[ACID] [int] NOT NULL,
[AssignmentID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LPAssignmentCollections] ADD CONSTRAINT [PK_LPAssignmentCollections] PRIMARY KEY CLUSTERED ([LPACID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LPAssignmentCollections] ADD CONSTRAINT [FK_LPAssignmentCollections_AssignmentCollections] FOREIGN KEY ([ACID]) REFERENCES [dbo].[AssignmentCollections] ([ACID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LPAssignmentCollections] ADD CONSTRAINT [FK_LPAssignmentCollections_Assignments] FOREIGN KEY ([AssignmentID]) REFERENCES [dbo].[Assignments] ([AssignmentID])
GO
ALTER TABLE [dbo].[LPAssignmentCollections] ADD CONSTRAINT [FK_LPAssignmentCollections_LessonPlans] FOREIGN KEY ([LPID]) REFERENCES [dbo].[LessonPlans] ([LPID]) ON DELETE CASCADE
GO
