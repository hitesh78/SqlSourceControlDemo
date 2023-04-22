SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[CreateStudent]
@StudentID int,
@xStudentID nvarchar(50),
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
@LockerCode nvarchar(20),
@LockOut bit,
@LoginID nvarchar(20),
@LoginPswd nvarchar(20)

AS

Declare @TheStudentID int

If @StudentID in (Select StudentID From Students)
Begin
	Set @TheStudentID = (Select Max(StudentID) + 1 From Students)
	
	If @StudentID = @LoginID
	Begin
	  Set @LoginID = @TheStudentID
	End
End
Else
Begin
	Set @TheStudentID = @StudentID
End

Insert into Accounts (AccountID, ThePassword, Access, LockOut)
Values
(
rtrim(ltrim(@LoginID)),
rtrim(ltrim(@LoginPswd)),
'Student',
@LockOut
)


Insert into Students 
(
StudentID, 
xStudentID, 
AccountID, 
Lname, 
Mname, 
Fname, 
GradeLevel, 
BirthDate, 
Sex, 
Ethnicity,
Father, 
Mother, 
Phone1, 
Phone2, 
Phone3,
LockerNumber,
LockerCode
)
Values
(	
@TheStudentID,
@xStudentID,
@LoginID,
rtrim(ltrim(@Lname)),
rtrim(ltrim(@Mname)),
rtrim(ltrim(@Fname)),
@GradeLevel,
@BirthDate,
@Sex,
rtrim(ltrim(@Ethnicity)),
rtrim(ltrim(@Father)),
rtrim(ltrim(@Mother)),
rtrim(ltrim(@Phone1)),
rtrim(ltrim(@Phone2)),
rtrim(ltrim(@Phone3)),
rtrim(ltrim(@LockerNumber)),
rtrim(ltrim(@LockerCode))
)











GO
