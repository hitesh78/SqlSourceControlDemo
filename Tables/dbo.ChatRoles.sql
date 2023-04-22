CREATE TABLE [dbo].[ChatRoles]
(
[roleID] [int] NOT NULL IDENTITY(100, 1),
[friendly_name] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[createChannel] [bit] NULL CONSTRAINT [DF_ChatRoles_createChannel] DEFAULT ((0)),
[joinChannel] [bit] NULL CONSTRAINT [DF_ChatRoles_joinChannel] DEFAULT ((0)),
[destroyChannel] [bit] NULL CONSTRAINT [DF_ChatRoles_destroyChannel] DEFAULT ((0)),
[inviteMember] [bit] NULL CONSTRAINT [DF_ChatRoles_inviteMember] DEFAULT ((0)),
[removeMember] [bit] NULL CONSTRAINT [DF_ChatRoles_removeMember] DEFAULT ((0)),
[editChannelName] [bit] NULL CONSTRAINT [DF_ChatRoles_editChannelName] DEFAULT ((0)),
[addMember] [bit] NULL CONSTRAINT [DF_ChatRoles_addMember] DEFAULT ((0)),
[editOwnMessage] [bit] NULL CONSTRAINT [DF_ChatRoles_editOwnMessage] DEFAULT ((0)),
[editAnyMessage] [bit] NULL CONSTRAINT [DF_ChatRoles_editAnyMessage] DEFAULT ((0)),
[deleteAnyMessage] [bit] NULL CONSTRAINT [DF_ChatRoles_deleteAnyMessage] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChatRoles] ADD CONSTRAINT [PK__ChatRole__CD98460AF4EBC76E] PRIMARY KEY CLUSTERED ([roleID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
