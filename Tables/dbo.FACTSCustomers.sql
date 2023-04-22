CREATE TABLE [dbo].[FACTSCustomers]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FamilyID] [int] NULL,
[Username] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FACTSCustomers] ADD CONSTRAINT [FK_FACTSCustomers_Families] FOREIGN KEY ([FamilyID]) REFERENCES [dbo].[Families] ([FamilyID]) ON DELETE CASCADE
GO
