CREATE TABLE [dbo].[EdfiAttendanceEvents]
(
[edfiAttendanceEventID] [int] NOT NULL IDENTITY(1, 1),
[edfiAttendanceEvent] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EdfiAttendanceEvents] ADD CONSTRAINT [PK_EdfiAttendanceValues] PRIMARY KEY CLUSTERED ([edfiAttendanceEventID]) ON [PRIMARY]
GO
