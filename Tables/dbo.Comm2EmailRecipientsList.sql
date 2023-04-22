CREATE TABLE [dbo].[Comm2EmailRecipientsList]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[NotificationID] [int] NOT NULL,
[Email] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Reason] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Comm2EmailRecipientsList] ADD CONSTRAINT [PK_Comm2EmailRecipientsList_ID] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_NotificationID] ON [dbo].[Comm2EmailRecipientsList] ([NotificationID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Comm2EmailRecipientsList] ADD CONSTRAINT [FK_Comm2EmailRecipientsList_Comm2EmailNotifications] FOREIGN KEY ([NotificationID]) REFERENCES [dbo].[Comm2EmailNotifications] ([ID]) ON DELETE CASCADE
GO
