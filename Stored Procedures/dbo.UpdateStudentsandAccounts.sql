SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[UpdateStudentsandAccounts]
@LoginID nvarchar(20),
@OriginalLoginID nvarchar(20),
@LoginPswd nvarchar(20),
@Activebit bit,
@LockOut bit,
@StudentID int,
@xStudentID nvarchar(20),
@Lname nvarchar(30),
@Mname nvarchar(30),
@Fname nvarchar(30),
@GradeLevel nvarchar(20),
@BirthDate smalldatetime,
@Sex nvarchar(12),
@Ethnicity nvarchar(50),
@Father nvarchar(50),
@Mother nvarchar(50),
@Phone1 nvarchar(50),
@Phone2 nvarchar(50),
@Phone3 nvarchar(50),
@LockerNumber nvarchar(20),
@LockerCode nvarchar(20)


As

ALTER TABLE Students NOCHECK CONSTRAINT FK_Students_Accounts

Declare @OrigLockout int
Set @OrigLockout = (Select Lockout From Accounts where AccountID = @OriginalLoginID)


IF @OrigLockout = 1 and @Lockout = 0
Begin
	Update Accounts
	Set AccountID = rtrim(ltrim(@LoginID)),
		ThePassword = rtrim(ltrim(@LoginPswd)),
		Access = 'Student',
		MissedPasswords = 0,
		Lockout = @Lockout
	Where AccountID = @OriginalLoginID
End
Else
Begin
	Update Accounts
	Set AccountID = rtrim(ltrim(@LoginID)),
		ThePassword = rtrim(ltrim(@LoginPswd)),
		Access = 'Student',
		Lockout = @Lockout
	Where AccountID = @OriginalLoginID
End

Declare @CurrentFname nvarchar(50)
Declare @CurrentLname nvarchar(50)
Declare @CurrentMname nvarchar(50)

Set @CurrentFname = (Select Fname From Students where StudentID = @StudentID)
Set @CurrentLname = (Select Lname From Students where StudentID = @StudentID)
Set @CurrentMname = (Select Mname From Students where StudentID = @StudentID)


If (rtrim(ltrim(@Fname)) != @CurrentFname) or (rtrim(ltrim(@Lname)) != @CurrentLname) or (rtrim(ltrim(@Mname)) != @CurrentMname)
Begin
Update Transcript
Set Fname = rtrim(ltrim(@Fname)),
	Lname = rtrim(ltrim(@Lname)),
	Mname = rtrim(ltrim(@Mname))
Where StudentID = @StudentID
End



	Update Students
	Set StudentID = @StudentID,
		xStudentID = @xStudentID,
		AccountID = rtrim(ltrim(@LoginID)),
		Active = @Activebit,
		Lname = rtrim(ltrim(@Lname)),
		Mname = rtrim(ltrim(@Mname)),
		Fname = rtrim(ltrim(@Fname)),
		GradeLevel = @GradeLevel,
		BirthDate = @BirthDate,
		Sex = @Sex,
		Ethnicity = rtrim(ltrim(@Ethnicity)),
		Father = rtrim(ltrim(@Father)),
		Mother = rtrim(ltrim(@Mother)),
		Phone1 = rtrim(ltrim(@Phone1)),
		Phone2 = rtrim(ltrim(@Phone2)),
		Phone3 = rtrim(ltrim(@Phone3)),
		LockerNumber = rtrim(ltrim(@LockerNumber)),
		LockerCode = rtrim(ltrim(@LockerCode))		
	Where StudentID = @StudentID

ALTER TABLE Students CHECK CONSTRAINT FK_Students_Accounts
GO
