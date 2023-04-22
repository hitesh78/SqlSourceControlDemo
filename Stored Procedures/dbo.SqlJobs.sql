SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[SqlJobs]
As
begin

	DECLARE @error nvarchar(4000) = null;
	DECLARE @lunchLastRunTime datetime;
	DECLARE @contractLastRunTime datetime;
	DECLARE @lastRunTime datetime;
	DECLARE @currentRunTime datetime = getdate();
	DECLARE @JobTitle nvarchar(100);

	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
	
	-- Refresh lunch charges from attendance if lunch billing and current activity are turned on and attendance
	-- has been updated since last lunch charges posting and it has been at least one hour
	-- since the last auto post....
	IF (select 1 from Settings where AutoPost=1 and EnableLunchBilling=1) is not NULL
	BEGIN
		SET @JobTitle = 'Attendance Lunch Charges'
		SET @lunchLastRunTime = isnull(
			(select max(runTime) from joblog where title = @JobTitle), 
			cast('2000-01-01' as datetime));
		IF datediff(mi,@lunchLastRunTime,getdate()) >= 120
		-- AND (dbo.tableLastUpdated('Attendance') > @lunchLastRunTime) -- kills server?
		BEGIN
			insert into JobLog (title, runTime)
				values (@JobTitle, @currentRunTime)

			exec glRefreshLunchCharges '', null, @error = @error output

			update JobLog 
				set success=case when @error is null then 1 else 0 end, resultText = @error 
			where runTime = @currentRunTime
				and title=@JobTitle
		END
	END

	-- Refresh installment charges if it has been at least one half calendar day since the last posting 
	IF (select 1 from Settings where AutoPost=1 and EnableInstallmentBilling=1) is not NULL
	BEGIN
		SET @JobTitle = 'Contract Installments'
		SET @contractLastRunTime = isnull(
			(select max(runTime) from joblog where title = @JobTitle),
			 cast('2000-01-01' as datetime));

		IF (datediff(mi,@contractLastRunTime,getdate()) >= 720 )
		BEGIN
			insert into JobLog (title, runTime)
				values (@JobTitle, @currentRunTime)

			exec glPostInstallments '', null, @error = @error output

			update JobLog 
				set success=case when @error is null then 1 else 0 end, resultText = @error 
			where runTime = @currentRunTime
				and title=@JobTitle
		END
	END

	-- Update Family ID in receivables if it has been at least one half calendar day since the last scan/refresh 
	IF (select top 1 1 from Receivables) is not NULL
	BEGIN
		SET @JobTitle = 'Receivables Family ID Refresh'
		SET @lastRunTime = isnull(
			(select max(runTime) from joblog where title = @JobTitle), 
			cast('2000-01-01' as datetime));

		IF (datediff(mi,@lastRunTime,getdate()) >= 60 ) -- FD 111833 / DS-195 update every 1hr instead of 12hr
		BEGIN
			insert into JobLog (title, runTime)
				values (@JobTitle, @currentRunTime)

			exec [glRefreshReceivablesFamilyID] '', null, @error = @error output

			update JobLog 
				set success=case when @error is null then 1 else 0 end, resultText = @error 
			where runTime = @currentRunTime
				and title=@JobTitle
		END
	END

	-- Create Family 2 IDs by default if Family 2 contact info is entered...
	SET @JobTitle = 'Create Default Family 2 IDs'

	-- Fast running, just run each time...
	exec [glUpdateFamily2Accounts] @error = @error output
	-- But to avoid lots of status rows, only log errors...
	if @error is not null
	begin
		insert into JobLog (title, runTime, success, resultText)
			values (@JobTitle, @currentRunTime, 0, @error)
	end

	-- Create Family 2 IDs by default if Family 2 contact info is entered...
	SET @JobTitle = 'Create Default Family 2 IDs'

	-- Fast running, just run each time...
	exec [glUpdateFamily2Accounts] @error = @error output
	-- But to avoid lots of status rows, only log errors...
	if @error is not null
	begin
		insert into JobLog (title, runTime, success, resultText)
			values (@JobTitle, @currentRunTime, 0, @error)
	end

	-- For easy testing, run job to queue uncompleted attendance notices
	-- 8/21/2019 - NOTE: Following might no longer be needed!!!!
	SET @JobTitle = 'Uncompleted Attendance Notices'
	exec [glUncompletedAttendanceNotices] @error = @error output
	-- But to avoid lots of status rows, only log errors...
	if @error is not null
	begin
		insert into JobLog (title, runTime, success, resultText)
			values (@JobTitle, @currentRunTime, 0, @error)
	end

	SET @JobTitle = 'Fixup Family 2 Account'
	exec [glFixupFamily2Accounts] @error = @error output
	-- But to avoid lots of status rows, only log errors...
	if @error is not null
	begin
		insert into JobLog (title, runTime, success, resultText)
			values (@JobTitle, @currentRunTime, 0, @error)
	end

END
GO
