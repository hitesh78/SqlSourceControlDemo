SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[AddTeacher]
@TeacherID int,
@StaffType tinyint,
@StaffTitle nvarchar(30),
@Lname nvarchar(30),
@Fname nvarchar(30),
@Phone nvarchar(15),
@Email nvarchar(100),
@BCCteacherEmail bit,
@BCCProspectiveEmail bit,
@NotifyEnrollmeStarted bit,
@NotifyEnrollmeSubmitted bit,
@NotifyEnrollmeInprocess bit,
@NotifyEnrollmePending bit,
@NotifyEnrollmeCancelled bit,
@NotifyEnrollmeApproved bit,
@NotifyEnrollmeNotApproved bit,
@LockOut bit,
@LoginID nvarchar(20),
@LoginPswd nvarchar(20),
@StaffPermissions nvarchar(300)

AS

If @StaffType = 1
Begin
Insert into Accounts (AccountID, ThePassword, Access, LockOut)
Values(	rtrim(@LoginID),
		rtrim(@LoginPswd),
		'Teacher',
		@LockOut)
End
Else If @StaffType = 2
Begin
Insert into Accounts (AccountID, ThePassword, Access, LockOut)
Values(	rtrim(@LoginID),
		rtrim(@LoginPswd),
		'Admin',
		@LockOut)
End
Else
Begin
Insert into Accounts (AccountID, ThePassword, Access, LockOut)
Values(	rtrim(@LoginID),
		rtrim(@LoginPswd),
		'Principal',
		@LockOut)
End

If exists (Select TeacherID From Teachers Where TeacherID = @TeacherID)
Begin
Set @TeacherID = (Select MAX(TeacherID) + 1 From Teachers)
End


Insert into Teachers (	TeacherID, 
						StaffType, 
						AccountID, 
						StaffTitle, 
						Lname, 
						Fname, 
						Phone, 
						Email, 
						BCCteacherEmail, 
						BCCProspectiveEmail, 
						NotifyEnrollmeStarted,
						NotifyEnrollmeSubmitted,
						NotifyEnrollmeInprocess,
						NotifyEnrollmePending,
						NotifyEnrollmeCancelled,
						NotifyEnrollmeApproved,
						NotifyEnrollmeNotApproved,
						Permissions
					)
Values
(	
	@TeacherID,
	@StaffType,
	rtrim(@LoginID),
	rtrim(@StaffTitle),
	rtrim(@Lname),
	rtrim(@Fname),
	rtrim(@Phone),
	rtrim(@Email),
	@BCCteacherEmail,
	@BCCProspectiveEmail,
	@NotifyEnrollmeStarted,
	@NotifyEnrollmeSubmitted,
	@NotifyEnrollmeInprocess,
	@NotifyEnrollmePending,
	@NotifyEnrollmeCancelled,
	@NotifyEnrollmeApproved,
	@NotifyEnrollmeNotApproved,
	@StaffPermissions
)


-- Add Records to Teacher Terms
Insert into TeacherTerms (TeacherID, TermID)
Select
@TeacherID,
TermID
From 
Terms

GO
