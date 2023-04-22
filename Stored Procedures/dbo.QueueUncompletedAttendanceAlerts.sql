SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[QueueUncompletedAttendanceAlerts]
AS
BEGIN

	DECLARE @EnableAttendanceNotices bit;
	DECLARE @EnableTeacherDailyAttendanceNotices bit;
	DECLARE @EnableTeacherClassAttendanceNotices bit;
	SELECT 
		@EnableAttendanceNotices = EnableAttendanceNotices,
		@EnableTeacherDailyAttendanceNotices = EnableTeacherDailyAttendanceNotices,
		@EnableTeacherClassAttendanceNotices = EnableTeacherClassAttendanceNotices
	FROM SETTINGS

	Declare @SchoolDate date = dbo.glgetdatetime();
	If 
	(		 -- Only Run if Needed
	exists (Select * From Teachers Where Active = 1 and NotifyAttendance = 1)
	or	-- Added below three lines as #2123 had no Admins being alerted but they still wanted teachers to get them
	@EnableTeacherDailyAttendanceNotices = 1
	or
	@EnableTeacherClassAttendanceNotices = 1
	)
	and
	(		-- Run this sp if school meets on this weekday - dp
		select -- FD 132136 / DS-722
			case datename(dw,@SchoolDate)
			when 'Sunday' then AttSunday
			when 'Monday' then AttMonday
			when 'Tuesday' then AttTuesday
			when 'Wednesday' then AttWednesday
			when 'Thursday' then AttThursday
			when 'Friday' then AttFriday
			when 'Saturday' then AttSaturday
			end
		from Settings
	) = 1
	and	-- Run sp if this date is not defined as a non-school day - dp
	@SchoolDate not in (select * From [dbo].[getNonSchoolDates]())
	Begin

		declare	@DailyAttendanceNotificationMode int;	
		declare @DailyAttendanceNotificationTime time(0);	
		declare @DailyAttendanceNotificationMinutes int;	
		declare @ClassAttendanceNotificationMinutes int;
		declare @ClassSendTime24 char(5); 
		declare @DailySendTime24 char(5);

		select 
			@DailyAttendanceNotificationMode = DailyAttendanceNotificationMode,	
			@DailyAttendanceNotificationTime = DailyAttendanceNotificationTime,	
			@DailyAttendanceNotificationMinutes = DailyAttendanceNotificationMinutes,	
			@ClassAttendanceNotificationMinutes = ClassAttendanceNotificationMinutes
		from
			Settings

		set @ClassSendTime24 -- FIXES...
			= case when DATEDIFF(MINUTE, DATEADD(DAY, DATEDIFF(DAY, 0, dbo.glgetdatetime()), 0), dbo.glgetdatetime()) 
				> @ClassAttendanceNotificationMinutes  
			then left(convert(varchar(30),dateadd(minute,-@ClassAttendanceNotificationMinutes,dbo.glgetdatetime()),14),5)
			else left(convert(varchar(30),dbo.glgetdatetime(),14),5)
			end

		declare @DailySendTime time(0);
		if @DailyAttendanceNotificationMode = 2
		BEGIN
			SET @DailySendTime24  -- FIXES...
			= case when DATEDIFF(MINUTE, DATEADD(DAY, DATEDIFF(DAY, 0, dbo.glgetdatetime()), 0), dbo.glgetdatetime()) 
				> @DailyAttendanceNotificationMinutes  
			then left(convert(varchar(30),dateadd(minute,-@DailyAttendanceNotificationMinutes,dbo.glgetdatetime()),14),5)
			else left(convert(varchar(30),dbo.glgetdatetime(),14),5)
			end
		END
		ELSE
		BEGIN
			SET @DailySendTime24 = left(convert(varchar(30),dbo.glgetdatetime(),14),5);
		END



		IF @EnableAttendanceNotices=1 
			and (@EnableTeacherClassAttendanceNotices = 1 
				or @EnableTeacherDailyAttendanceNotices = 1)
		BEGIN
			with UncompletedAttendance as (
				select *,
					isnull((select LanguageType from Accounts where AccountID 
						= (select AccountID from Teachers where TeacherID = ua.TeacherID)), 
							(select TeacherDefaultLanguage from settings)) as LanguageType
				from dbo.tfUncompletedAttendance(dbo.glgetdatetime(),-1) ua
				where
					(  (ClassTypeID=5 and @EnableTeacherDailyAttendanceNotices=1)
					or (ClassTypeID<>5 and @EnableTeacherClassAttendanceNotices=1))
					and
					case when ClassTypeID = 5 and @DailyAttendanceNotificationMode = 1
					then @DailyAttendanceNotificationTime
					else PeriodStartTime end
					< 
					case when ClassTypeID = 5 
					then @DailySendTime24
					else @ClassSendTime24
					end
			),
			UncompletedAttendance_Teachers as (
				select
					ua.TeacherID, 
					max(isnull(ua.LanguageType,'English')) as LanguageType,
					'Uncompleted Attendance Notification' as AlertType,
					max(t.glName) as Teacher,
					max(t.email) as Email,
					'Attendance has not yet been completed for these classes:'
					+REPLACE(REPLACE((
						SELECT char(10)
							+ '~' + ClassTitle
							+ case when PeriodStartTime > '00:00:00'
								then ' (Period '+Period+' @ '
									+ dbo.formatTime(PeriodStartTime) + ')'
								end
						FROM UncompletedAttendance 
						where TeacherID = ua.TeacherID
						ORDER BY PeriodStartTime,ClassTitle
						FOR XML PATH('')
					),char(10),'<br/>'),'~','&nbsp;&nbsp;&nbsp;&nbsp;') AS AlertDescription,
					dbo.glgetdatetime() as AlertDate
				from UncompletedAttendance ua
				inner join Teachers t
				on ua.TeacherID = t.TeacherID
				where t.active = 1 and isnull(email,11)>'' -- Only notify "active" teachers
				group by ua.TeacherID
			)
			insert into NotificationLog
			(TeacherID,AlertType,Teacher,Email,AlertDescription,AlertDate,LanguageType)
			select 
				UAT.TeacherID,
				UAT.AlertType,
				UAT.Teacher,
				UAT.Email,
				UAT.AlertDescription,
				UAT.AlertDate,
				UAT.LanguageType			
			from UncompletedAttendance_Teachers UAT
			--do not send duplicate messages...
			left join NotificationLog NL
			on UAT.TeacherID=NL.TeacherID
			and UAT.Email=NL.Email
			and UAT.AlertDescription=NL.AlertDescription
			and cast(UAT.AlertDate as date) = cast(NL.AlertDate as date)
			where NL.AlertDate is null
		END

		IF @EnableAttendanceNotices=1
		BEGIN
			;with UncompletedAttendance as (
				select *
				from dbo.tfUncompletedAttendance(dbo.glgetdatetime(),-1)
				where
					case when ClassTypeID = 5 and @DailyAttendanceNotificationMode = 1
					then @DailyAttendanceNotificationTime
					else PeriodStartTime end
					< 
					case when ClassTypeID = 5 
					then @DailySendTime24
					else @ClassSendTime24
					end
			), UncompletedAttendance_Admins as (
				select 
					AdminToNotify.TeacherID, 
					max(AdminToNotify.AccountID) as AccountID,
					'Uncompleted Attendance Notification' as AlertType,
					max(AdminToNotify.glName) as Teacher,
					max(AdminToNotify.email) as Email,
					'Attendance has not yet been completed for these classes:'
					+REPLACE(REPLACE((
						SELECT char(10)
							+ '~' + ClassTitle
							+ ' ('+ Teacher
							+ case when PeriodStartTime > '00:00:00'
								then '; Period '+Period+' @ '
									+ dbo.formatTime(PeriodStartTime) + ')'
								else ')' end
						FROM UncompletedAttendance ua
						ORDER BY PeriodStartTime,ClassTitle
						FOR XML PATH('')
					),char(10),'<br/>'),'~','&nbsp;&nbsp;&nbsp;&nbsp;') AS AlertDescription,
					dbo.glgetdatetime() as AlertDate
				from Teachers AdminToNotify
				cross join UncompletedAttendance ua
				where  AdminToNotify.NotifyAttendance = 1 
					and isnull(AdminToNotify.email,11)>'' -- Only notify admins that subscribe
				group by AdminToNotify.TeacherID
			)
			insert into NotificationLog
				(TeacherID,AlertType,Teacher,Email,AlertDescription,AlertDate,LanguageType)
			select 
				UAA.TeacherID,
				UAA.AlertType,
				UAA.Teacher,
				UAA.Email,
				UAA.AlertDescription,
				UAA.AlertDate,
				isnull((select LanguageType from Accounts where AccountID = UAA.AccountID), 
					(select AdminDefaultLanguage from settings)) as LanguageType		 
			from UncompletedAttendance_Admins UAA
			--do not send duplicate messages...
			left join NotificationLog NL
			on UAA.TeacherID=NL.TeacherID
			and UAA.Email=NL.Email
			and UAA.AlertDescription=NL.AlertDescription
			and cast(UAA.AlertDate as date) = cast(NL.AlertDate as date)
			where NL.AlertDate is null
		END

	End
	Else
	Begin
		Select 'Never Ran' as Msg
	End


END



/*
--TURN FEATURE ON...
update settings set
	EnableAttendanceNotices = 1

--See 30 day history of notices
SELECT * FROM NOTIFICATIONLOG

delete from Notificationlog

--SEE CURRENT NOTICES IN LKG ALERT QUEUE...
select *
from LKG.dbo.MainAlertLog
where AlertType like '%Noti%'
*/
GO
