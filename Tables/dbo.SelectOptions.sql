CREATE TABLE [dbo].[SelectOptions]
(
[SelectOptionID] [int] NOT NULL IDENTITY(1, 1),
[SelectListID] [int] NOT NULL,
[Title] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Notes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Code] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReadonlySystemItem] [bit] NULL CONSTRAINT [DF_SelectOptions_ReadonlySystemItem] DEFAULT ((0)),
[SampleDataItem] [bit] NULL CONSTRAINT [DF_SelectOptions_SampleDataItem] DEFAULT ((0)),
[PaymentPriority] [int] NOT NULL CONSTRAINT [DF_SelectOptions_PaymentPriority] DEFAULT ((5))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SelectOptions] ADD CONSTRAINT [PK_SelectOptions] PRIMARY KEY CLUSTERED ([SelectOptionID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UniqueSelectOptions] ON [dbo].[SelectOptions] ([SelectListID], [Title]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
