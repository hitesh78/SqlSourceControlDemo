CREATE TABLE [dbo].[AccountsActivityLog]
(
[AccountActivityID] [int] NOT NULL IDENTITY(1, 1),
[AccountID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AccessType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Activity] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Response] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateTime] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IPaddress] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeviceType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EncKey] [decimal] (15, 15) NULL,
[LoginSessionCount] [int] NULL,
[SQLjobLogout] [bit] NULL CONSTRAINT [DF_AccountsActivityLog_ForcedSQLJobLogout] DEFAULT ((0)),
[ClientUserAgent] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientDNSname] [nvarchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AccountsActivityLog] ADD CONSTRAINT [PK_AccountsActivityLog] PRIMARY KEY CLUSTERED ([AccountActivityID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
