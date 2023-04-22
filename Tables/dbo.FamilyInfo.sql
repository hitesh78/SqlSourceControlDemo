CREATE TABLE [dbo].[FamilyInfo]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[familyOrTempID] [int] NOT NULL,
[BillingNotes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FamilyInfo] ADD CONSTRAINT [PK_FamilyInfo] PRIMARY KEY CLUSTERED ([ID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
