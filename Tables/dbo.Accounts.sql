CREATE TABLE [dbo].[Accounts]
(
[AccountID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ThePassword] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Access] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Accounts_Access] DEFAULT ((-0.1)),
[EncKey] [decimal] (15, 15) NULL,
[MissedPasswords] [tinyint] NULL CONSTRAINT [DF_Accounts_MissedPasswords] DEFAULT ((0)),
[Lockout] [bit] NULL CONSTRAINT [DF_Accounts_Lockout] DEFAULT ((0)),
[LanguageType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Accounts_LanguageType] DEFAULT ('English'),
[LastLoginTime] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastClickTime] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastLogOutTime] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoginSessionCount] [int] NULL,
[LastLoginIPaddress] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PasswordHash] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PassResetExpiry] [datetime] NULL,
[EmailAck] [datetime] NULL,
[SessionID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SessionIDExpiry] [datetime] NULL,
[PSTdateTimeOffset] [int] NULL,
[LastAccessOfDisciplineTab] [datetime] NULL,
[EmailSignature] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SendDisciplineEmails] [bit] NOT NULL CONSTRAINT [DF_Accounts_SendDisciplineEmails] DEFAULT ((0)),
[language_id] [int] NOT NULL CONSTRAINT [DF_Accounts_language_id] DEFAULT ((0)),
[LastClientDNSname] [nvarchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastClientDeviceType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastClientUserAgent] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShowArchivedChats] [bit] NOT NULL CONSTRAINT [DF_Accounts_ShowArchivedChats] DEFAULT ((0)),
[ChatSounds] [bit] NOT NULL CONSTRAINT [DF_Accounts_ChatSounds] DEFAULT ((0)),
[MuteAllChannels] [bit] NOT NULL CONSTRAINT [DF_Accounts_MuteAllChannels] DEFAULT ((0)),
[AlertSounds] [bit] NOT NULL CONSTRAINT [DF_Accounts_AlertSounds] DEFAULT ((0)),
[LastChangePswdTime] [datetime] NULL,
[ChangePswdCount] [int] NULL CONSTRAINT [DF_Accounts_ChangePswd_Count] DEFAULT ((0)),
[GoogleUserId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GoogleRefreshToken] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GoogleMailID] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GoogleIdToken] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GooglePicture] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GoogleHostedDomain] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GoogleUserInfo] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoginStatusModeID] [int] NOT NULL CONSTRAINT [DF_Accounts_LoginStatusModeID] DEFAULT ((0)),
[LoginStatusLastUpdated] [datetime] NULL,
[PasswordSalt] [uniqueidentifier] NOT NULL CONSTRAINT [DF__Accounts__Passwo__0547113D] DEFAULT (newid()),
[BackupPswd] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Otp] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtpUtc] [datetime2] NULL,
[OtpCount] [int] NULL,
[MfaValidUntilUtc] [datetime2] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   Trigger [dbo].[AccountUpdate]
 on [dbo].[Accounts]
 After Insert, Update
As
begin
	
	-- reset password count after they unlock an account
	If Update(Lockout)
	begin
		update a set MissedPasswords = 0
		from Accounts a with (UPDLOCK)
		inner join inserted i
		on a.AccountID = i.AccountID
		inner join deleted d
		on a.AccountID = d.AccountID
		where i.Lockout=0 and d.Lockout=1;
	end

	--Hash & Truncate Password and copy clear password to BackupPswd column
	update a 
	set 
		BackupPswd = i.ThePassword,
		ThePassword = SUBSTRING(master.dbo.fn_varbintohexstr(HashBytes('SHA2_256', CONCAT(i.ThePassword,a.PasswordSalt))), 3, 8)
	from 
	Accounts a with (UPDLOCK)
		inner join 
	inserted i
		on a.AccountID = i.AccountID
        left join
    deleted d
        on a.AccountID = d.AccountID
	where 
	not exists (select 1 from deleted)	-- Do hash when just inserting
	or
	i.ThePassword != d.ThePassword;		-- Do hash when updating and the password is different

	-- Swap Right Apostrophe with straight : GMA-1571
	update Accounts with (UPDLOCK)
	set AccountID = replace(AccountID, char(146), char(39)) 
	Where
	AccountID like '%' + char(146) + '%';

	-- Populate AccountOverlays table
	Insert into AccountOverlays (AccountID, OverlayID)
	Select
	replace(I.AccountID, char(146), char(39)),
	O.OverlayID
	From
	Inserted I
		cross join
	Overlays O
	Where 
	not exists (Select * From AccountOverlays Where AccountID = replace(I.AccountID, char(146), char(39)) and OverlayID = O.OverlayID);


end
GO
ALTER TABLE [dbo].[Accounts] ADD CONSTRAINT [PK_Accounts_AccountID] PRIMARY KEY CLUSTERED ([AccountID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Accounts] ADD CONSTRAINT [FK_Accounts_LoginStatusModes] FOREIGN KEY ([LoginStatusModeID]) REFERENCES [dbo].[LoginStatusModes] ([LoginStatusModeID])
GO
