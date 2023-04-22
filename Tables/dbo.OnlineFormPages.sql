CREATE TABLE [dbo].[OnlineFormPages]
(
[OnlineFormPageID] [int] NOT NULL IDENTITY(1, 1),
[EnrollmentProgramID] [int] NULL,
[FormName] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WizardPage] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SessionID] [int] NULL,
[GradeLevelFrom] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GradeLevelThru] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormStatus] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PageHtml] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GradeLevelOptionID] [int] NULL,
[ShowOrHidePage] [nchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Grades] AS (case  when [GradeLevelOptionID] IS NULL then (isnull([GradeLevelFrom],'')+case  when [GradeLevelFrom] IS NOT NULL AND [GradeLevelThru] IS NOT NULL then '...' else '' end)+isnull([GradeLevelThru],'') else '' end)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OnlineFormPages] ADD CONSTRAINT [PK_OnlineFormPages] PRIMARY KEY CLUSTERED ([OnlineFormPageID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EnrollmentProgramID] ON [dbo].[OnlineFormPages] ([EnrollmentProgramID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GradeLevelOptionID] ON [dbo].[OnlineFormPages] ([GradeLevelOptionID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SessionID] ON [dbo].[OnlineFormPages] ([SessionID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OnlineFormPages] ADD CONSTRAINT [FK_OnlineFormPages_EnrollmentPrograms] FOREIGN KEY ([EnrollmentProgramID]) REFERENCES [dbo].[EnrollmentPrograms] ([EnrollmentProgramID])
GO
ALTER TABLE [dbo].[OnlineFormPages] ADD CONSTRAINT [FK_OnlineFormPages_GradeLevelOptions] FOREIGN KEY ([GradeLevelOptionID]) REFERENCES [dbo].[GradeLevelOptions] ([GradeLevelOptionID])
GO
ALTER TABLE [dbo].[OnlineFormPages] ADD CONSTRAINT [FK_OnlineFormPages_Session] FOREIGN KEY ([SessionID]) REFERENCES [dbo].[Session] ([SessionID])
GO
