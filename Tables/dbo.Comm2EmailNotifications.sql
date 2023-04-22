CREATE TABLE [dbo].[Comm2EmailNotifications]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[EmailID] [int] NOT NULL,
[NotificationType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NotificationSubType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TopicArn] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ImapUID] [int] NOT NULL,
[Status] [char] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Comm2EmailNotifications] ADD CONSTRAINT [PK_Comm2EmailNotifications_ID] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EmailID] ON [dbo].[Comm2EmailNotifications] ([EmailID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Comm2EmailNotifications_IMAPUID] ON [dbo].[Comm2EmailNotifications] ([ImapUID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Comm2EmailNotifications] ADD CONSTRAINT [FK_Comm2EmailNotifications_Comm2EmailLog] FOREIGN KEY ([EmailID]) REFERENCES [dbo].[Comm2EmailLog] ([EmailID]) ON DELETE CASCADE
GO
