CREATE TABLE [dbo].[Donations]
(
[DonationID] [int] NOT NULL IDENTITY(1, 1),
[StudentID] [int] NOT NULL,
[Date] [smalldatetime] NOT NULL,
[Payer] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Donations_Payer] DEFAULT (''),
[Amount] [money] NOT NULL,
[PayMethod] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Donations_PayMethod] DEFAULT (''),
[FundraisingCodes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Donations_FundraisingCodes] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Donations] ADD CONSTRAINT [PK_Donations] PRIMARY KEY CLUSTERED ([DonationID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StudentID] ON [dbo].[Donations] ([StudentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Donations] ADD CONSTRAINT [FK_Donations_Students] FOREIGN KEY ([StudentID]) REFERENCES [dbo].[Students] ([StudentID])
GO
