CREATE TABLE [dbo].[Comm2EmailLog]
(
[EmailID] [int] NOT NULL IDENTITY(1, 1),
[AccountID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SenderAddress] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromAddress] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateTime] [datetime] NULL,
[RecipientGroupIDs] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecipientGroupNames] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExcludedStudentAccountIDs] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExcludedParentAccountIDs] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExcludedStaffAccountIDs] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExcludedAccountNames] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuickAddFamilyAccountIDs] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuickAddStaffAccountIDs] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuickAddAccountNames] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraEmailAddresses] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalIDsTargeted] [int] NULL,
[SuccessfulEmailAddressCount] [int] NULL,
[FailEmailAddressCount] [int] NULL,
[Subject] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MessageBody] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileList] [nvarchar] (800) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileSessionID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AttachmentFileIDs] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScheduledDateTime] [datetime] NULL,
[MessageStatus] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuickAddParentAccountIDs] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolGroupIDs] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolGroupNames] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StatusDescription] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 4/29/2021
-- Description:	Update any record that has been stuck in Sending for more than an hour to Failed
--				This trigger will run on record insert
-- =============================================
CREATE TRIGGER [dbo].[UpdateEmailMessageStatusToFailed]
   ON  [dbo].[Comm2EmailLog]
   AFTER INSERT
AS 
BEGIN

	SET NOCOUNT ON;

	if exists(
			select * 
			From Comm2EmailLog 
			Where
			DateTime < DATEADD(hour, -1, dbo.glgetdatetime())
			and
			MessageStatus = 'Sending'
		)
	Begin

		-- Update Status
		Update Comm2EmailLog
		Set 
		MessageStatus = 'Failed'
		Where
		DateTime < DATEADD(hour, -1, dbo.glgetdatetime())
		and
		MessageStatus = 'Sending';

		-- Add Record to glErrorLog
		INSERT INTO LKG.dbo.glErrorLog
		(
		[Context]
		,[ServerTime]
		,[ExceptionMsg]
		,[DatabaseID]
		,[Source]
		,[URL]
		,[SQL_CPU]
		,[SQL_MemPercentInUse]
		)
			 VALUES

		(
			'SQL Server'
			,getdate()
			,'Error: Failed to finish Sending Email Message within 1 Hour - MessageStatus set to Failed'
			, DB_NAME ()
			,'SQL Server - Comm2EmailLog Trigger'
			,'https://secure.gradelink.com:443/SmartSend/api/749/Communicate/SendScheduledEmail'
			,
			(
			SELECT TOP 1
				100 - r.SystemIdle as CPU
			FROM (
				SELECT
					rx.record.value('(./Record/@id)[1]', 'int') AS record_id,
					rx.record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS SystemIdle
				FROM (
					SELECT CONVERT(XML, record) AS record
					FROM sys.dm_os_ring_buffers
					WHERE
						ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' AND
						record LIKE '%<SystemHealth>%') AS rx
				) AS r
			ORDER BY r.record_id DESC
			)
			,
			(
				SELECT
					convert(int,
					(((m.total_physical_memory_kb - m.available_physical_memory_kb) /
						  convert(float, m.total_physical_memory_kb)) *
						 100)) as Mem
				FROM sys.dm_os_sys_memory m
			)
		);
	End;

END;
GO
ALTER TABLE [dbo].[Comm2EmailLog] ADD CONSTRAINT [PK_Comm2EmailLog] PRIMARY KEY CLUSTERED ([EmailID]) ON [PRIMARY]
GO
