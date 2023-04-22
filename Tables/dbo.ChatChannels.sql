CREATE TABLE [dbo].[ChatChannels]
(
[channelID] [int] NOT NULL IDENTITY(1, 1),
[friendly_name] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[visibilityType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[date_created] [datetime] NULL,
[date_updated] [datetime] NULL,
[created_by] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChatChannels] ADD CONSTRAINT [PK__ChatChan__14D60D7032ACD88A] PRIMARY KEY CLUSTERED ([channelID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
