CREATE TABLE [dbo].[NotificationLog]
(
[AlertID] [int] NOT NULL IDENTITY(1, 1),
[TeacherID] [int] NULL,
[AlertType] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Teacher] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AlertDescription] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AlertDate] [datetime] NULL,
[SchoolID] AS (db_name()),
[LanguageType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[ProcessNotifications]
 on [dbo].[NotificationLog]
 After Insert
As
		Insert into LKG.dbo.MainAlertLog 
            (CSID, AlertType, Student, Email, AlertDescription, AlertDate, SchoolID, LanguageType)
		Select 
			null, 
			AlertType, 
			Teacher, 
			Email, 
			AlertDescription, 
			dbo.toDBDate(AlertDate), 
			SchoolID,
			LanguageType
		From Inserted
		where
		ISNUMERIC((Select top 1 SchoolID From Inserted)) = 1  -- Only Send Alerts if it is for a real SchoolID(123) as opposed to 123b

	Delete From NotificationLog
	Where DateDiff(day, AlertDate, dbo.GLgetdatetime()) > 30
GO
