SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [dbo].[SIS_UpdateLogin_view] as
select s.StudentID,s.xStudentID,a.AccountID,a.ThePassword,a.Lockout 
from Accounts a
inner join Students s on a.AccountID = s.AccountID
union
select 
	-1 as StudentID,
	isnull(dbo.MaxNumericStudentAndAccountID(),1000)+1 as xStudentID,
	CAST(isnull(dbo.MaxNumericStudentAndAccountID(),1000)+1 AS nvarchar(20))as AccountID,
	dbo.GeneratePassword() as ThePassword, CAST(0 as bit) as Lockout




GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[CreateAccountRecord] 
   ON  [dbo].[SIS_UpdateLogin_view] 
   INSTEAD OF INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	
	declare @dups int = (SELECT COUNT(*) FROM Inserted i inner join Accounts a on i.AccountID=a.AccountID);

	IF @dups > 0
	BEGIN
		-- No transaction tracking, so clean up (delete) any students being added that duplicate existing Account IDs
		RAISERROR ('User name is already in use, please choose a new user name.',15,1);
	END
	ELSE
	BEGIN
		INSERT INTO Accounts (AccountID, ThePassword, Access, Lockout)
			SELECT	AccountID,ThePassword,'Student',Lockout FROM Inserted
		INSERT INTO Students (StudentID, AccountID, xStudentID, Lname, Fname, GradeLevel)
			SELECT	isnull((SELECT MAX(StudentID) FROM STUDENTS)+1,1) ,AccountID,xStudentID,'-','-','30'/*any valid grade*/ FROM Inserted
	END
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateAccountRecord] 
   ON  [dbo].[SIS_UpdateLogin_view] 
   INSTEAD OF UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	declare @dups int = 
		( SELECT COUNT(*) 
			FROM Inserted new 
			INNER JOIN Accounts a ON new.AccountID=a.AccountID 
			INNER JOIN Deleted old on old.StudentID = new.StudentID
			WHERE old.AccountID != new.AccountID 
		);

	IF @dups > 0
	BEGIN
		RAISERROR ('User name is already in use, please cancel this change or choose a new user name.',15,1);
	END
	ELSE
	BEGIN
	
		SET @dups = 
			( SELECT COUNT(*) 
				FROM Inserted new 
				INNER JOIN Students s ON new.xStudentID = s.xStudentID 
				INNER JOIN Deleted old on old.StudentID = new.StudentID
				WHERE old.xStudentID != new.xStudentID 
			);
	
		IF @dups > 0
		BEGIN
			RAISERROR ('Student ID is already in use, please cancel this change or choose a new ID.',15,1);
		END
		ELSE
		BEGIN
			-- Update case when Account ID is unchanged
			UPDATE Accounts set ThePassword = new.ThePassword, Lockout = new.Lockout
				FROM Accounts a
				INNER JOIN Deleted old on a.AccountID = old.AccountID
				INNER JOIN Inserted new on old.StudentID = new.StudentID
				WHERE old.AccountID = new.AccountID 
					AND (a.ThePassword != new.ThePassword 
					OR isnull(a.Lockout,0) != isnull(new.Lockout,0))

			-- Update case when xStudentID is unchanged
			UPDATE Students set xStudentID = new.xStudentID
				FROM Students s
				INNER JOIN Deleted old on s.xStudentID = old.xStudentID
				INNER JOIN Inserted new on old.StudentID = new.StudentID
				WHERE old.xStudentID != new.xStudentID 
				
			-- UPDATE CASE WHEN Account ID IS CHANGED 
			-- (need to create new Account ID record, then change Account ID in student (RI ok now),
			--  then delete old Account ID record)
				
			INSERT INTO Accounts (AccountID, ThePassword, Access, Lockout)
				SELECT	new.AccountID,new.ThePassword,'Student',new.Lockout 
				FROM Accounts a
				INNER JOIN Deleted old on a.AccountID = old.AccountID
				INNER JOIN Inserted new on old.StudentID = new.StudentID
				WHERE old.AccountID != new.AccountID
				
			UPDATE Students SET AccountID = new.AccountID 
				FROM Students s 
				INNER JOIN Deleted old on s.AccountID = old.AccountID
				INNER JOIN Inserted new on old.StudentID = new.StudentID
				WHERE old.AccountID != new.AccountID

			/*
			 * Additions on 08/20/2014 by Andy Skupen.
			 * The tables pertaining to the calendar also need to have 
			 * their AccountID references updated.
			 */

			 UPDATE CalendarSelection SET AccountId = New.AccountID
				FROM CalendarSelection AS CS
				INNER JOIN Deleted AS Old On CS.AccountId = Old.AccountID
				INNER JOIN Inserted AS New On Old.StudentID = New.StudentID
				WHERE Old.AccountID != New.AccountID;

			 UPDATE Calendar SET CreatedById = New.AccountID
				FROM Calendar AS C
				INNER JOIN Deleted AS Old On C.CreatedById = Old.AccountID
				INNER JOIN Inserted AS New On Old.StudentID = New.StudentID
				WHERE Old.AccountID != New.AccountID;

			 UPDATE Calendar SET LastEditedById = New.AccountID
				FROM Calendar AS C
				INNER JOIN Deleted AS Old On C.LastEditedById = Old.AccountID
				INNER JOIN Inserted AS New On Old.StudentID = New.StudentID
				WHERE Old.AccountID != New.AccountID;

			 /*
			  * End of Additions on 08/20/2014 by Andy Skupen.
			  */

			DELETE Accounts 
				FROM Accounts a
				INNER JOIN Deleted old on a.AccountID = old.AccountID
				INNER JOIN Inserted new on old.StudentID = new.StudentID
				WHERE old.AccountID != new.AccountID
		END
	END
END





GO
