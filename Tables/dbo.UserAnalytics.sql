CREATE TABLE [dbo].[UserAnalytics]
(
[OrderID] [int] NOT NULL IDENTITY(1, 1),
[Date] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Hour] [int] NULL,
[TotalCustomerLoginCount] [int] NULL CONSTRAINT [DF_UserAnalytics_TotalCustomerLoginCount] DEFAULT ((0)),
[TotalCustomerLogoutCount] [int] NULL CONSTRAINT [DF_UserAnalytics_TotalCustomerLogoutCount] DEFAULT ((0)),
[AdministratorLoginCount] [int] NULL CONSTRAINT [DF_UserAnalytics_AdministratorLoginCount] DEFAULT ((0)),
[AdministratorLogoutCount] [int] NULL CONSTRAINT [DF_UserAnalytics_AdministratorLogoutCount] DEFAULT ((0)),
[AdminLimitedLoginCount] [int] NULL CONSTRAINT [DF_UserAnalytics_AdminLimitedLoginCount] DEFAULT ((0)),
[AdminLimitedLogoutCount] [int] NULL CONSTRAINT [DF_UserAnalytics_AdminLimitedLogoutCount] DEFAULT ((0)),
[TeacherLoginCount] [int] NULL CONSTRAINT [DF_UserAnalytics_TeacherLoginCount] DEFAULT ((0)),
[TeacherLogoutCount] [int] NULL CONSTRAINT [DF_UserAnalytics_TeacherLogoutCount] DEFAULT ((0)),
[StudentLoginCount] [int] NULL CONSTRAINT [DF_UserAnalytics_StudentLoginCount] DEFAULT ((0)),
[StudentLogoutCount] [int] NULL CONSTRAINT [DF_UserAnalytics_StudentLogoutCount] DEFAULT ((0)),
[GradelinkLoginCount] [int] NULL CONSTRAINT [DF_UserAnalytics_GradelinkLoginCount] DEFAULT ((0)),
[GradelinkLogoutCount] [int] NULL CONSTRAINT [DF_UserAnalytics_GradelinkLogoutCount] DEFAULT ((0)),
[SQLjobLogout] [int] NULL CONSTRAINT [DF_UserAnalytics_SQLjobLogout] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserAnalytics] ADD CONSTRAINT [PK_UserAnalytics] PRIMARY KEY CLUSTERED ([OrderID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserAnalytics] ADD CONSTRAINT [Date_Hour] UNIQUE NONCLUSTERED ([Date], [Hour]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
