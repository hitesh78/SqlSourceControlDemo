CREATE TABLE [dbo].[IEP_Report]
(
[IEP_Report_ID] [int] NOT NULL IDENTITY(1, 1),
[StudentID] [int] NOT NULL,
[Date] [date] NOT NULL,
[GradeLevel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TeacherID] [int] NULL,
[Comments] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EdFiIEPObjectives] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IEP_Report] ADD CONSTRAINT [PK_IEP_Report] PRIMARY KEY CLUSTERED ([IEP_Report_ID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StudentID] ON [dbo].[IEP_Report] ([StudentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TeacherID] ON [dbo].[IEP_Report] ([TeacherID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IEP_Report] ADD CONSTRAINT [FK_IEP_Report_Students] FOREIGN KEY ([StudentID]) REFERENCES [dbo].[Students] ([StudentID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[IEP_Report] ADD CONSTRAINT [FK_IEP_Report_Teachers] FOREIGN KEY ([TeacherID]) REFERENCES [dbo].[Teachers] ([TeacherID])
GO
