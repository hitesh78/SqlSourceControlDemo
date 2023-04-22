CREATE TABLE [dbo].[EnrollStudentStatusDates]
(
[EnrollStudentStatusDateID] [int] NOT NULL IDENTITY(1, 1),
[EnrollmentStudentID] [int] NOT NULL,
[FormStatus] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_EnrollStudentStatusDates_date] DEFAULT (getdate()),
[AutoImportNotes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AutoImportCode] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AutoImportYN] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ImportStudentID] [int] NULL,
[ImportStatusUpdateDate] [datetime] NULL,
[UpdateDateTime] AS (CONVERT([varchar],[updatedate],(120))),
[AutoImportExclusions] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AutoImportErrors] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SessionID] [int] NULL,
[AccountID_stamp] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Trigger [dbo].[DefaultUpdateDate]
   ON  [dbo].[EnrollStudentStatusDates] 
   AFTER INSERT
AS 
BEGIN	
	Update essd
		Set UpdateDate = dbo.glgetdatetime()
	from EnrollStudentStatusDates essd
	inner join inserted i 
	on essd.EnrollStudentStatusDateID = i.EnrollStudentStatusDateID;
END

GO
ALTER TABLE [dbo].[EnrollStudentStatusDates] ADD CONSTRAINT [PK_EnrollStudentStatusDates] PRIMARY KEY CLUSTERED ([EnrollStudentStatusDateID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EnrollmentStudentID] ON [dbo].[EnrollStudentStatusDates] ([EnrollmentStudentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EnrollStudentStatusDates] ADD CONSTRAINT [FK_EnrollStudentStatusDates_EnrollmentStudent] FOREIGN KEY ([EnrollmentStudentID]) REFERENCES [dbo].[EnrollmentStudent] ([EnrollmentStudentID]) ON DELETE CASCADE
GO
