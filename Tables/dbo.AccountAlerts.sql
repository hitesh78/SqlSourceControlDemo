CREATE TABLE [dbo].[AccountAlerts]
(
[AAID] [int] NOT NULL IDENTITY(1, 1),
[CSID] [int] NOT NULL,
[AccountID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LowClassGradeAlert] [tinyint] NOT NULL CONSTRAINT [DF_AccountAlerts_LowClassGradeAlert] DEFAULT ((0)),
[LowClassGradeAlertSent] [bit] NOT NULL CONSTRAINT [DF_AccountAlerts_LowClassGradeAlertSent] DEFAULT ((0)),
[HighClassGradeAlert] [tinyint] NOT NULL CONSTRAINT [DF_AccountAlerts_HighClassGradeAlert] DEFAULT ((0)),
[HighClassGradeAlertSent] [bit] NOT NULL CONSTRAINT [DF_AccountAlerts_HighClassGradeAlertSent] DEFAULT ((0)),
[HighGradeAlert] [tinyint] NOT NULL CONSTRAINT [DF_AccountAlerts_HighGradeAlert] DEFAULT ((0)),
[LowGradeAlert] [tinyint] NOT NULL CONSTRAINT [DF_AccountAlerts_LowGradeAlert] DEFAULT ((0)),
[HighConductAlert] [tinyint] NOT NULL CONSTRAINT [DF_AccountAlerts_HighConductAlert] DEFAULT ((0)),
[LowConductAlert] [tinyint] NOT NULL CONSTRAINT [DF_AccountAlerts_LowConductAlert] DEFAULT ((0)),
[Att2Alert] [bit] NOT NULL CONSTRAINT [DF_AccountAlerts_Att2Alert] DEFAULT ((0)),
[Att3Alert] [bit] NOT NULL CONSTRAINT [DF_AccountAlerts_Att3Alert] DEFAULT ((0)),
[Att4Alert] [bit] NOT NULL CONSTRAINT [DF_AccountAlerts_Att4Alert] DEFAULT ((0)),
[Att5Alert] [bit] NOT NULL CONSTRAINT [DF_AccountAlerts_Att5Alert] DEFAULT ((0)),
[Att6Alert] [bit] NOT NULL CONSTRAINT [DF_AccountAlerts_Att6Alert] DEFAULT ((0)),
[Att7Alert] [bit] NOT NULL CONSTRAINT [DF_AccountAlerts_Att7Alert] DEFAULT ((0)),
[Att8Alert] [bit] NOT NULL CONSTRAINT [DF_AccountAlerts_Att8Alert] DEFAULT ((0)),
[Att9Alert] [bit] NOT NULL CONSTRAINT [DF_AccountAlerts_Att9Alert] DEFAULT ((0)),
[Att10Alert] [bit] NOT NULL CONSTRAINT [DF_AccountAlerts_Att10Alert] DEFAULT ((0)),
[Att11Alert] [bit] NOT NULL CONSTRAINT [DF_AccountAlerts_Att11Alert] DEFAULT ((0)),
[Att12Alert] [bit] NOT NULL CONSTRAINT [DF_AccountAlerts_Att12Alert] DEFAULT ((0)),
[Att13Alert] [bit] NOT NULL CONSTRAINT [DF_AccountAlerts_Att13Alert] DEFAULT ((0)),
[Att14Alert] [bit] NOT NULL CONSTRAINT [DF_AccountAlerts_Att14Alert] DEFAULT ((0)),
[Att15Alert] [bit] NOT NULL CONSTRAINT [DF_AccountAlerts_Att15Alert] DEFAULT ((0)),
[NeedToSendClassGradeAlert] [bit] NOT NULL CONSTRAINT [DF_AccountAlerts_NeedToSendClassGradeAlert] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AccountAlerts] ADD CONSTRAINT [PK_AccountAlerts] PRIMARY KEY CLUSTERED ([AAID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AccountID] ON [dbo].[AccountAlerts] ([AccountID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CSID] ON [dbo].[AccountAlerts] ([CSID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AccountAlerts] ADD CONSTRAINT [FK_AccountAlerts_Accounts] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Accounts] ([AccountID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[AccountAlerts] ADD CONSTRAINT [FK_AccountAlerts_ClassesStudents] FOREIGN KEY ([CSID]) REFERENCES [dbo].[ClassesStudents] ([CSID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
