CREATE TABLE [dbo].[AlertLog]
(
[AlertID] [int] NOT NULL IDENTITY(1, 1),
[CSID] [int] NULL,
[AlertType] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Student] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE  Trigger [dbo].[ProcessAlerts]
 on [dbo].[AlertLog]
 After Insert
As
		Insert into LKG.dbo.MainAlertLog (CSID, AlertType, Student, Email, AlertDescription, AlertDate, LanguageType, SchoolID)
		Select 
			CSID, 
			AlertType, 
			Student, 
			Email, 
			AlertDescription, 
			dbo.toDBDate(AlertDate) as AlertDate, 
			LanguageType,
			SchoolID
		From Inserted
		where
		ISNUMERIC((Select top 1 SchoolID From Inserted)) = 1  -- Only Send Alerts if it is for a real SchoolID(123) as opposed to 123b

	Delete From AlertLog
	Where DateDiff(day, AlertDate, dbo.GLgetdatetime()) > 30
GO
