CREATE TABLE [dbo].[ChatChannelMembers]
(
[ChannelID] [int] NOT NULL,
[AccountID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RoleID] [int] NULL,
[UnreadMessages] [int] NULL CONSTRAINT [DF_ChatChannelMembers_UnreadMessages] DEFAULT ((0)),
[MuteChannel] [bit] NOT NULL CONSTRAINT [DF_ChatChannelMembers_muteChannel] DEFAULT ((0)),
[Archived] [bit] NOT NULL CONSTRAINT [DF_ChatChannelMembers_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChatChannelMembers] ADD CONSTRAINT [FK__ChatChann__chann__33AC2F14] FOREIGN KEY ([ChannelID]) REFERENCES [dbo].[ChatChannels] ([channelID])
GO
ALTER TABLE [dbo].[ChatChannelMembers] ADD CONSTRAINT [FK__ChatChann__roleI__35947786] FOREIGN KEY ([RoleID]) REFERENCES [dbo].[ChatRoles] ([roleID])
GO
ALTER TABLE [dbo].[ChatChannelMembers] ADD CONSTRAINT [FK_ChatChannelMembers_Accounts] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Accounts] ([AccountID])
GO
