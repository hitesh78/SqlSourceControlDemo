CREATE TABLE [dbo].[BatchTransactions]
(
[BTID] [int] NOT NULL IDENTITY(1, 1),
[TransDate] [date] NOT NULL,
[SessionID] [int] NOT NULL,
[TransactionTypeID] [int] NOT NULL,
[ReferenceNumber] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BatchTransactions_ReferenceNumber] DEFAULT (''),
[Memo] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount] [money] NOT NULL,
[BTtype] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[csvStudentIDs] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TeacherID] [int] NOT NULL,
[BTdateCreated] [datetime] NOT NULL CONSTRAINT [DF_Table_1_BTDateCreated] DEFAULT ([dbo].[GLgetdatetime]()),
[BTparentID] [int] NOT NULL CONSTRAINT [DF_BatchTransactions_BTparentID] DEFAULT ((0)),
[BTDeleted] [bit] NOT NULL CONSTRAINT [DF_BatchTransactions_BTDeleted] DEFAULT ((0)),
[BTDeletedDateTime] [datetime] NULL,
[BTDeletedTeacherID] [int] NULL,
[csvExcludedStudentIDs] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StatusFilter] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GradeLevelsFilter] [nvarchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DivisionsFilter] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TagsFilter] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csvClassIDsFilter] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BatchTransactions] ADD CONSTRAINT [PK_BatchTransactions] PRIMARY KEY CLUSTERED ([BTID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BatchTransactions] ADD CONSTRAINT [FK_BatchTransactions_Session] FOREIGN KEY ([SessionID]) REFERENCES [dbo].[Session] ([SessionID])
GO
ALTER TABLE [dbo].[BatchTransactions] ADD CONSTRAINT [FK_BatchTransactions_Teachers] FOREIGN KEY ([TeacherID]) REFERENCES [dbo].[Teachers] ([TeacherID])
GO
ALTER TABLE [dbo].[BatchTransactions] ADD CONSTRAINT [FK_BatchTransactions_TransactionTypes] FOREIGN KEY ([TransactionTypeID]) REFERENCES [dbo].[TransactionTypes] ([TransactionTypeID])
GO
