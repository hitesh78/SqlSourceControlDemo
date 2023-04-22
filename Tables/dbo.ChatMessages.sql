CREATE TABLE [dbo].[ChatMessages]
(
[ChannelID] [int] NULL,
[AccountID] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Date_created] [datetime] NULL,
[Date_updated] [datetime] NULL,
[Was_edited] [bit] NOT NULL,
[Body] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MessageID] [int] NOT NULL IDENTITY(1, 1),
[MessageType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChatMessages] ADD CONSTRAINT [PK__ChatMess__4808B8732C0B0D4C] PRIMARY KEY CLUSTERED ([MessageID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChatMessages] ADD CONSTRAINT [FK__ChatMessa__chann__1CC8C9BC] FOREIGN KEY ([ChannelID]) REFERENCES [dbo].[ChatChannels] ([channelID])
GO
