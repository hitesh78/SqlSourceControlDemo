CREATE TABLE [dbo].[Families]
(
[FamilyID] [int] NOT NULL,
[AccountID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email1] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email2] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email3] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email4] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllowEnrollMeAccess] [bit] NOT NULL CONSTRAINT [DF_Families_AllowEnrollMeAccess] DEFAULT ((0)),
[AllowBillingAccess] [bit] NOT NULL CONSTRAINT [DF_Families_AllowBillingAccess] DEFAULT ((0)),
[SubmitMyAddressToDPI] [bit] NOT NULL CONSTRAINT [DF_Families_SubmitMyAddressToDPI] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Families] ADD CONSTRAINT [PK__Families__41D82F4B503D80CA] PRIMARY KEY CLUSTERED ([FamilyID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AccountID] ON [dbo].[Families] ([AccountID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Families] ADD CONSTRAINT [FK_Families_Accounts] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Accounts] ([AccountID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
