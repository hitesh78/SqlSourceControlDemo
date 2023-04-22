CREATE TABLE [dbo].[CommEmailLog]
(
[AccountID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SenderAddress] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromAddress] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateTime] [datetime] NULL,
[RecipientGroups] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GradeLevelTitles] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClassroomTitles] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExcludedAccountNames] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncludedAccountNames] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalIDsTargeted] [int] NULL,
[SuccessfulEmailAddressCount] [int] NULL,
[FailEmailAddressCount] [int] NULL,
[Subject] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MessageBody] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileList] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
