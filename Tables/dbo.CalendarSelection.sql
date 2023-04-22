CREATE TABLE [dbo].[CalendarSelection]
(
[CalendarSelectionId] [int] NOT NULL IDENTITY(1, 1),
[CalendarSelectionTypeId] [int] NOT NULL,
[AccountId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordId] [int] NOT NULL,
[ActiveInd] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CalendarSelection] ADD CONSTRAINT [PK_CalendarSelection] PRIMARY KEY CLUSTERED ([CalendarSelectionId]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AccountId] ON [dbo].[CalendarSelection] ([AccountId]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CalendarSelection] ADD CONSTRAINT [FK_CalendarSelection_Accounts] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Accounts] ([AccountID]) ON UPDATE CASCADE
GO
