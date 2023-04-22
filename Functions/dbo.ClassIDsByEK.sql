SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [dbo].[ClassIDsByEK](@EK decimal(15,15)) 
--
-- Get ClassID's associated with current Teacher login 
-- based on EK; or get all POPULATED class if EK is 
-- associated with an Admin login.  Could extend to include
-- Parent/Student/Family logins too if enough of the
-- business rules overlap????
--
returns @rv table (
	ClassID int 
)
as 
begin
	with StaffAssociatedWithEK as (
		select TeacherID,a.Access
		from teachers t
		inner join accounts a
		on t.AccountID = a.AccountID
		where EncKey=@EK
	),
	AllTeacherClasses as (
		select c.ClassID
		from Classes c
		inner join StaffAssociatedWithEK t
		on c.TeacherID = t.TeacherID
		or t.Access!='Teacher'
		union  
		select tc.ClassID
		from TeachersClasses tc
		inner join StaffAssociatedWithEK t
		on tc.TeacherID = t.TeacherID
	)
	insert into @rv
	select * 
	from AllTeacherClasses
	where 
		ClassID in ( select ClassID from ClassesStudents )
	return
end
GO
