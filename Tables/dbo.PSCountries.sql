CREATE TABLE [dbo].[PSCountries]
(
[CountryCode] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CountryName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSCountries] ADD CONSTRAINT [PK_PSCountries_CountryCode] PRIMARY KEY CLUSTERED ([CountryCode]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
