CREATE TABLE [dbo].[PSStates]
(
[StateAbbreviation] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StateName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CountryCode] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSStates] ADD CONSTRAINT [PK_PSStates_StateAbbreviation] PRIMARY KEY CLUSTERED ([StateAbbreviation]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CountryCode] ON [dbo].[PSStates] ([CountryCode]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSStates] ADD CONSTRAINT [FK_PSStates_PSCountries] FOREIGN KEY ([CountryCode]) REFERENCES [dbo].[PSCountries] ([CountryCode])
GO
