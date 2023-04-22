CREATE TABLE [dbo].[JobLog]
(
[title] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[runTime] [datetime] NOT NULL,
[success] [bit] NULL,
[resultText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
