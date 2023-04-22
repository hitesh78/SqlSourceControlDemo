CREATE TABLE [dbo].[PhoneNumbers]
(
[PhoneNumberID] [int] NOT NULL IDENTITY(1, 1),
[ContactID] [int] NULL,
[TeacherID] [int] NULL,
[StudentID] [int] NULL,
[Type] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Extension] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TextAlertCapable] [bit] NULL,
[TextOptOut] [bit] NULL,
[TextAllowed] [bit] NOT NULL CONSTRAINT [DF_PhoneNumbers_TextAllowed] DEFAULT ((0)),
[VoiceAllowed] [bit] NOT NULL CONSTRAINT [DF_PhoneNumbers_VoiceAllowed] DEFAULT ((0)),
[Preferred] [bit] NULL,
[PhoneNumberValid] [bit] NULL,
[VerifiedOn] [datetime] NULL,
[LineType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PhoneNumbers] ADD CONSTRAINT [PK_PhoneNumbers] PRIMARY KEY CLUSTERED ([PhoneNumberID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
