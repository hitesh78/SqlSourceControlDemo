CREATE TABLE [dbo].[DayCareNotes]
(
[DayCareNotesID] [int] NOT NULL IDENTITY(1, 1),
[StudentID] [int] NOT NULL,
[StartDate] [date] NOT NULL,
[EndDate] [date] NOT NULL,
[NoteType] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactName] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
