SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   Procedure [dbo].[PromoteStudents]
	@studentlist nvarchar(max), @removeDivision bit 
	
as
BEGIN TRANSACTION [Tran1]
	BEGIN TRY
		Update Students
		Set GradeLevel =
		case GradeLevel
		  when 'PS' then 'PK'
		  when 'PK' then 'K'
		  when 'K' then '1'
		  else convert(nvarchar(5), (convert(int, GradeLevel) + 1))
		end
		from Students where Status <> 'New Enrollment' AND
		xStudentID NOT IN (
			SELECT * FROM dbo.SplitCSVIntegers(@studentlist)
		) AND
		  Active=1 -- FD 135755 / DS-839

	-- Make new enrollments active now...
	update Students set active = 1 where Status = 'New Enrollment' -- trigger will also convert status to 'Active'...

	--Clear Students classes divisions for the new Term
	if(@removeDivision = 1) 
		begin
			update Students
			set Class = ''
			where Active = 1
		end

	-- Make reenrollments 'active' status now (even though re-enrollment is a form of active)...
	-- (This covers non-enrollme users, and partially covers enrollme users.  Note that EnrollMe
	-- users will also need to perform EnrollMe session "close" in order to see "reenrollments"
	-- presented as merely "active"... - Duke 6/26/2014
	update Students set Status='Active' where active=1 and Status<>'Active'
	update Settings set PromotedDate = GetDate();
	-- Per WISE people (Jada) they want the EnglishFluency cleared out for all wise students 
	-- Where EnglishFluency is not 6 or 7 (Native) upon promting students
	Update StudentMiscFields
	Set 
	EnglishFluency = ''
	From 
	StudentMiscFields SM
		inner join
	Students S
		on S.StudentID = SM.StudentID
	Where	
	isnull(S.WISEid, '') != ''
	and 
	left(ltrim(rtrim(EnglishFluency)),1) != '6'
	and
	left(ltrim(rtrim(EnglishFluency)),1) != '7'
	and
	ltrim(rtrim(EnglishFluency)) not like '%Native%' -- old value used
	COMMIT TRANSACTION [Tran1]
	END TRY
BEGIN CATCH
      ROLLBACK TRANSACTION [Tran1]
END CATCH  
GO
