SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[Logout]
@EK decimal(15,15),
@SQLjobLogout bit,
@ClientIPaddress nvarchar(20),
@ClientDeviceType nvarchar(20),
@ClientUserAgent nvarchar(500),
@ClientDNSname nvarchar(300)

AS

Update ClassesStudents
Set InUseBy = null
Where
InUseBy =
(
	Select top 1
	glname as TeacherName
	From
	Teachers T
		inner join
	Accounts A
		on T.AccountID = A.AccountID
	Where
	A.EncKey = @EK
)	
	
 DECLARE @AccountID nvarchar(20)
 SET @AccountID = LOWER((SELECT AccountID FROM Accounts WHERE EncKey = @EK))
 DECLARE @Access nvarchar(10)
 SET @Access = (SELECT Access FROM Accounts WHERE EncKey = @EK)	
	
 DECLARE @NewEK decimal(15,15) = 0
 DECLARE @sessionIncrement int = 1  --defaults to 1 instance (for the non-SQLjobLogout actions)
 DECLARE @sessionCount int
 
 IF (@SQLjobLogout = 1)
	SET @sessionIncrement = ISNULL((SELECT TOP(1) LoginSessionCount FROM Accounts WHERE EncKey = @EK), 1)  --Adds all sessions to be counted

 SET @sessionCount = ISNULL((SELECT TOP(1) LoginSessionCount FROM Accounts WHERE EncKey = @EK), 1) - 1

 IF (@sessionCount < 0)
  SET @sessionCount = 0

 IF (@sessionCount = 0)
    SET @NewEK = -.1
 ELSE
	SET @NewEK = @EK

DECLARE @currentGLdatetime nvarchar(30)
SET @currentGLdatetime = CONVERT(nvarchar(30), dbo.GLgetdatetime(), 9)

IF @SQLjobLogout = 1
BEGIN
	UPDATE Accounts
	SET 
		EncKey = -.1,
		LastLogOutTime = CONVERT(nvarchar(30), dateadd(hour, datediff(hour, 0, @currentGLdatetime), 0)),   --round to nearest hour to help identify auto logouts
		LoginSessionCount = 0
	WHERE EncKey = @EK
END
ELSE
BEGIN
	UPDATE Accounts
	SET 
		EncKey = @NewEK,
		LastLogOutTime = @currentGLdatetime,
		LoginSessionCount = @sessionCount
	WHERE EncKey = @EK
END

    DECLARE @currentGLdate nvarchar(30)
	SET @currentGLdate = convert(nvarchar(30), dbo.GLgetdate())
	
	DECLARE @currentGLhour nvarchar(5)
	SET @currentGLhour = (SELECT DATEPART(HOUR, dbo.GLgetdatetime()))
	
	DECLARE @currentHour nvarchar(5)
	SET @currentHour = (SELECT DATEPART(HOUR, GETDATE()))
	
	DECLARE @currentDate nvarchar(15)
	SET @currentDate = (SELECT CONVERT(varchar,getdate(),1))

	IF NOT EXISTS (SELECT Date, Hour FROM [LKG].dbo.UserAnalytics WHERE Date = @currentDate and Hour = @currentHour)
	BEGIN
		INSERT INTO [LKG].dbo.UserAnalytics ( Date, Hour ) VALUES ( @currentDate, @currentHour )		
	END
	
	IF NOT EXISTS (SELECT Date, Hour FROM UserAnalytics WHERE Date = @currentGLdate and Hour = @currentGLhour)
	BEGIN
		INSERT INTO UserAnalytics ( Date, Hour ) VALUES ( @currentGLdate, @currentGLhour )		
	END

IF @AccountID != 'glinit'
BEGIN
	UPDATE [LKG].dbo.UserAnalytics SET TotalCustomerLogoutCount = ISNULL((SELECT TotalCustomerLogoutCount FROM [LKG].dbo.UserAnalytics WHERE Date = @currentDate and Hour = @currentHour), 0) + @sessionIncrement
	WHERE Date = @currentDate and Hour = @currentHour
	
	UPDATE UserAnalytics SET TotalCustomerLogoutCount = ISNULL((SELECT TotalCustomerLogoutCount FROM UserAnalytics WHERE Date = @currentGLdate and Hour = @currentGLhour), 0) + @sessionIncrement
	WHERE Date = @currentGLdate and Hour = @currentGLhour
END

IF @Access = 'Principal'
BEGIN
	IF @AccountID = 'glinit'
	BEGIN
		UPDATE [LKG].dbo.UserAnalytics SET GradelinkLogoutCount = ISNULL((SELECT GradelinkLogoutCount FROM [LKG].dbo.UserAnalytics WHERE Date = @currentDate and Hour = @currentHour), 0) + @sessionIncrement
		WHERE Date = @currentDate and Hour = @currentHour
		
		UPDATE UserAnalytics SET GradelinkLogoutCount = ISNULL((SELECT GradelinkLogoutCount FROM UserAnalytics WHERE Date = @currentGLdate and Hour = @currentGLhour), 0) + @sessionIncrement
		WHERE Date = @currentGLdate and Hour = @currentGLhour
	END
	ELSE
	BEGIN
		UPDATE [LKG].dbo.UserAnalytics SET AdministratorLogoutCount = ISNULL((SELECT AdministratorLogoutCount FROM [LKG].dbo.UserAnalytics WHERE Date = @currentDate and Hour = @currentHour), 0) + @sessionIncrement
		WHERE Date = @currentDate and Hour = @currentHour
		
		UPDATE UserAnalytics SET AdministratorLogoutCount = ISNULL((SELECT AdministratorLogoutCount FROM UserAnalytics WHERE Date = @currentGLdate and Hour = @currentGLhour), 0) + @sessionIncrement
		WHERE Date = @currentGLdate and Hour = @currentGLhour
	END
END
ELSE IF @Access = 'Teacher'
BEGIN
	UPDATE [LKG].dbo.UserAnalytics SET TeacherLogoutCount = ISNULL((SELECT TeacherLogoutCount FROM [LKG].dbo.UserAnalytics WHERE Date = @currentDate and Hour = @currentHour), 0) + @sessionIncrement
	WHERE Date = @currentDate and Hour = @currentHour
	
	UPDATE UserAnalytics SET TeacherLogoutCount = ISNULL((SELECT TeacherLogoutCount FROM UserAnalytics WHERE Date = @currentGLdate and Hour = @currentGLhour), 0) + @sessionIncrement
	WHERE Date = @currentGLdate and Hour = @currentGLhour
END
ELSE IF @Access = 'Student'
BEGIN
    UPDATE [LKG].dbo.UserAnalytics SET StudentLogoutCount = ISNULL((SELECT StudentLogoutCount FROM [LKG].dbo.UserAnalytics WHERE Date = @currentDate and Hour = @currentHour), 0) + @sessionIncrement
	WHERE Date = @currentDate and Hour = @currentHour
	
	UPDATE UserAnalytics SET StudentLogoutCount = ISNULL((SELECT StudentLogoutCount FROM UserAnalytics WHERE Date = @currentGLdate and Hour = @currentGLhour), 0) + @sessionIncrement
	WHERE Date = @currentGLdate and Hour = @currentGLhour
END
ELSE IF @Access = 'Admin'
BEGIN
	UPDATE [LKG].dbo.UserAnalytics SET AdminLimitedLogoutCount = ISNULL((SELECT AdminLimitedLogoutCount FROM [LKG].dbo.UserAnalytics WHERE Date = @currentDate and Hour = @currentHour), 0) + @sessionIncrement
	WHERE Date = @currentDate and Hour = @currentHour
	
	UPDATE UserAnalytics SET AdminLimitedLogoutCount = ISNULL((SELECT AdminLimitedLogoutCount FROM UserAnalytics WHERE Date = @currentGLdate and Hour = @currentGLhour), 0) + @sessionIncrement
	WHERE Date = @currentGLdate and Hour = @currentGLhour
END

IF @SQLjobLogout = 1
BEGIN
	IF @AccountID != ''
	BEGIN
		INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, SQLjobLogout, ClientUserAgent, ClientDNSname)
		VALUES (@AccountID, @Access, 'LOGOUT', 'SUCCESS', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @NewEK, 0, 1, @ClientUserAgent, @ClientDNSname)
	END
	
	UPDATE UserAnalytics SET SQLjobLogout = ISNULL((SELECT SQLjobLogout FROM UserAnalytics WHERE Date = @currentGLdate and Hour = @currentGLhour), 0) + @sessionIncrement
	WHERE Date = @currentGLdate and Hour = @currentGLhour
	
	UPDATE [LKG].dbo.UserAnalytics SET SQLjobLogout = ISNULL((SELECT SQLjobLogout FROM [LKG].dbo.UserAnalytics WHERE Date = @currentDate and Hour = @currentHour), 0) + @sessionIncrement
	WHERE Date = @currentDate and Hour = @currentHour
END
ELSE
BEGIN
	IF @AccountID != ''
	BEGIN
		INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, SQLjobLogout, ClientUserAgent, ClientDNSname)
		VALUES (@AccountID, @Access, 'LOGOUT', 'SUCCESS', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @NewEK, @sessionCount, 0, @ClientUserAgent, @ClientDNSname)
	END
END

GO
