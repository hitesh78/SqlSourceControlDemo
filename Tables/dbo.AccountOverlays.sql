CREATE TABLE [dbo].[AccountOverlays]
(
[AOID] [int] NOT NULL IDENTITY(1, 1),
[AccountID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OverlayID] [int] NOT NULL,
[DontRemindMe] [bit] NOT NULL CONSTRAINT [DF_AccountOverlays_DontRemindMe] DEFAULT ((0)),
[LastAccess] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AccountOverlays] ADD CONSTRAINT [PK_AccountOverlays] PRIMARY KEY CLUSTERED ([AOID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AccountOverlays] ADD CONSTRAINT [FK_AccountOverlays_Accounts] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Accounts] ([AccountID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[AccountOverlays] ADD CONSTRAINT [FK_AccountOverlays_Overlays] FOREIGN KEY ([OverlayID]) REFERENCES [dbo].[Overlays] ([OverlayID]) ON DELETE CASCADE
GO
