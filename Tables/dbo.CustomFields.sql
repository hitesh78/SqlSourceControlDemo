CREATE TABLE [dbo].[CustomFields]
(
[CustomFieldID] [int] NOT NULL IDENTITY(1, 1),
[ClassTypeID] [int] NOT NULL,
[CustomFieldName] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomFieldSpanishName] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomFieldOrder] [int] NOT NULL,
[FieldBolded] [bit] NOT NULL CONSTRAINT [DF_CustomFields_FieldBolded] DEFAULT ((0)),
[FieldNotGraded] [bit] NOT NULL CONSTRAINT [DF_CustomFields_FieldNotGraded] DEFAULT ((0)),
[Indent] [tinyint] NOT NULL CONSTRAINT [DF_CustomFields_Indent] DEFAULT ((0)),
[Bullet] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CustomFields_Bullet] DEFAULT ('none')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[AddCustomField]
 on [dbo].[CustomFields]
 After Insert
As

	Insert into ClassesStudentsCF (CSID, CustomFieldID)
	Select CSID, CustomFieldID
	From Inserted
		inner join Classes C
			on Inserted.ClassTypeID = C.ClassTypeID
		inner join ClassesStudents CS
			on CS.ClassID = C.ClassID
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[DeleteCustomField]
 on [dbo].[CustomFields]
 After Delete
As

		Delete From ClassesStudentsCF
		Where CustomFieldID in (Select CustomFieldID From Deleted)
GO
ALTER TABLE [dbo].[CustomFields] ADD CONSTRAINT [PK_CustomFields] PRIMARY KEY CLUSTERED ([CustomFieldID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ClassTypeID] ON [dbo].[CustomFields] ([ClassTypeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomFields] ADD CONSTRAINT [FK_CustomFields_ClassType] FOREIGN KEY ([ClassTypeID]) REFERENCES [dbo].[ClassType] ([ClassTypeID])
GO
