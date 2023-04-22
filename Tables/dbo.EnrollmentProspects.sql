CREATE TABLE [dbo].[EnrollmentProspects]
(
[ProspectID] [int] NOT NULL IDENTITY(1, 1),
[Address] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BirthDate] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GradeEnteringSchool] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NamePreviousSchool] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HowHearAboutSchool] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GuardianName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StudentName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcessingNotes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tags] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogDate] [datetime] NULL CONSTRAINT [DF_EnrollmentProspects_LogDate] DEFAULT (getdate()),
[FollowupDate] [date] NULL,
[NextActionNote] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CloseDate] [date] NULL,
[CloseDisposition] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE trigger [dbo].[EnrollmentProspectsValidate]
on [dbo].[EnrollmentProspects]
for insert,update
as
begin
	if (select count(*) from inserted where GuardianName is null and StudentName is null and email is null and phone is null)>0
	begin
		RAISERROR ('Prospect record not saved because at least one contact field of name, email or phone is required.',16,1);
		rollback;
		return;
	end
end
GO
ALTER TABLE [dbo].[EnrollmentProspects] ADD CONSTRAINT [pk_ProspectID] PRIMARY KEY CLUSTERED ([ProspectID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
