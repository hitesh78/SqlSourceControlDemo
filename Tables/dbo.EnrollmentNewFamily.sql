CREATE TABLE [dbo].[EnrollmentNewFamily]
(
[EnrollID] [int] NOT NULL IDENTITY(1, 1),
[EnrollFamilyID] [int] NULL,
[PassHash] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PassResetExpiry] [datetime] NULL,
[Email] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmailAck] [datetime] NULL,
[SessionID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SessionIDExpiry] [datetime] NULL,
[Lastlogin] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormLanguage] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Enrollmen__FormL__3B432F3B] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EnrollmentNewFamily] ADD CONSTRAINT [PK_Enrollment] PRIMARY KEY CLUSTERED ([EnrollID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
