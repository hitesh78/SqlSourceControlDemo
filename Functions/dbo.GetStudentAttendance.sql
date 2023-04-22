SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetStudentAttendance](@CSID int)
RETURNS nvarchar(max)
AS
Begin


Declare @HTMLTable table(HTMLData nVARCHAR(200))


	Declare @ValidAttendance table (ID nvarchar(5), Title nvarchar(50))

	insert into @ValidAttendance
	Select ID, Title
	From AttendanceSettings
	Where
	ISNULL(Title,'') != ''


	Insert into @HTMLTable
	Select Column1 Column2
	From
	(
	Select
	case 
		when exists (Select * from @ValidAttendance Where ID = 'Att1') 
		then 
		'<tr><td>' +
		(Select Title From @ValidAttendance Where ID = 'Att1') + ':&#160;' 
		+ 
		'</td><td>'
		+
		convert(nvarchar(10), SUM(Att1))
		+
		'</td></tr>'
		else '-1'
	end as Att1,
	case 
		when exists (Select * from @ValidAttendance Where ID = 'Att2') 
		then 
		'<tr><td>' +
		(Select Title From @ValidAttendance Where ID = 'Att2') + ':&#160;' 
		+ 
		'</td><td>'
		+
		convert(nvarchar(10), SUM(Att2))
		+
		'</td></tr>'
		else '-1'
	end as Att2,
	case 
		when exists (Select * from @ValidAttendance Where ID = 'Att3') 
		then 
		'<tr><td>' +
		(Select Title From @ValidAttendance Where ID = 'Att3') + ':&#160;' 
		+ 
		'</td><td>'
		+
		convert(nvarchar(10), SUM(Att3))
		+
		'</td></tr>'
		else '-1'
	end as Att3,
	case 
		when exists (Select * from @ValidAttendance Where ID = 'Att4') 
		then 
		'<tr><td>' +
		(Select Title From @ValidAttendance Where ID = 'Att4') + ':&#160;' 
		+ 
		'</td><td>'
		+
		convert(nvarchar(10), SUM(Att4))
		+
		'</td></tr>'
		else '-1'
	end as Att4,
	case 
		when exists (Select * from @ValidAttendance Where ID = 'Att5') 
		then 
		'<tr><td>' +
		(Select Title From @ValidAttendance Where ID = 'Att5') + ':&#160;' 
		+ 
		'</td><td>'
		+
		convert(nvarchar(10), SUM(Att5))
		+
		'</td></tr>'
		else '-1'
	end as Att5,
	case 
		when exists (Select * from @ValidAttendance Where ID = 'Att6') 
		then 
		'<tr><td>' +
		(Select Title From @ValidAttendance Where ID = 'Att6') + ':&#160;' 
		+ 
		'</td><td>'
		+
		convert(nvarchar(10), SUM(Att6))
		+
		'</td></tr>'
		else '-1'
	end as Att6,
	case 
		when exists (Select * from @ValidAttendance Where ID = 'Att7') 
		then 
		'<tr><td>' +
		(Select Title From @ValidAttendance Where ID = 'Att7') + ':&#160;' 
		+ 
		'</td><td>'
		+
		convert(nvarchar(10), SUM(Att7))
		+
		'</td></tr>'
		else '-1'
	end as Att7,
	case 
		when exists (Select * from @ValidAttendance Where ID = 'Att8') 
		then 
		'<tr><td>' +
		(Select Title From @ValidAttendance Where ID = 'Att8') + ':&#160;' 
		+ 
		'</td><td>'
		+
		convert(nvarchar(10), SUM(Att8))
		+
		'</td></tr>'
		else '-1'
	end as Att8,
	case 
		when exists (Select * from @ValidAttendance Where ID = 'Att9') 
		then 
		'<tr><td>' +
		(Select Title From @ValidAttendance Where ID = 'Att9') + ':&#160;' 
		+ 
		'</td><td>'
		+
		convert(nvarchar(10), SUM(Att9))
		+
		'</td></tr>'
		else '-1'
	end as Att9,
	case 
		when exists (Select * from @ValidAttendance Where ID = 'Att10') 
		then 
		'<tr><td>' +
		(Select Title From @ValidAttendance Where ID = 'Att10') + ':&#160;' 
		+ 
		'</td><td>'
		+
		convert(nvarchar(10), SUM(Att10))
		+
		'</td></tr>'
		else '-1'
	end as Att10,
	case 
		when exists (Select * from @ValidAttendance Where ID = 'Att11') 
		then 
		'<tr><td>' +
		(Select Title From @ValidAttendance Where ID = 'Att11') + ':&#160;' 
		+ 
		'</td><td>'
		+
		convert(nvarchar(10), SUM(Att11))
		+
		'</td></tr>'
		else '-1'
	end as Att11,
	case 
		when exists (Select * from @ValidAttendance Where ID = 'Att12') 
		then 
		'<tr><td>' +
		(Select Title From @ValidAttendance Where ID = 'Att12') + ':&#160;' 
		+ 
		'</td><td>'
		+
		convert(nvarchar(10), SUM(Att12))
		+
		'</td></tr>'
		else '-1'
	end as Att12,
	case 
		when exists (Select * from @ValidAttendance Where ID = 'Att13') 
		then 
		'<tr><td>' +
		(Select Title From @ValidAttendance Where ID = 'Att13') + ':&#160;' 
		+ 
		'</td><td>'
		+
		convert(nvarchar(10), SUM(Att13))
		+
		'</td></tr>'
		else '-1'
	end as Att13,
	case 
		when exists (Select * from @ValidAttendance Where ID = 'Att14') 
		then 
		'<tr><td>' +
		(Select Title From @ValidAttendance Where ID = 'Att14') + ':&#160;' 
		+ 
		'</td><td>'
		+
		convert(nvarchar(10), SUM(Att14))
		+
		'</td></tr>'
		else '-1'
	end as Att14,
	case 
		when exists (Select * from @ValidAttendance Where ID = 'Att15') 
		then 
		'<tr><td>' +
		(Select Title From @ValidAttendance Where ID = 'Att15') + ':&#160;' 
		+ 
		'</td><td>'
		+
		convert(nvarchar(10), SUM(Att15))
		+
		'</td></tr>'
		else '-1'
	end as Att15
	From Attendance
	Where
	CSID = @CSID
	) AttendanceData
	Unpivot
	(Column1 for Column2 in ([Att1],[Att2],[Att3],[Att4],[Att5],[Att6],[Att7],[Att8],[Att9],[Att10],[Att11],[Att12],[Att13],[Att14],[Att15]))as Tp
	Where 
	Column2 != '-1'



	Delete From @HTMLTable
	Where
	HTMLData = '-1'
	

	DECLARE @HTMLString nVARCHAR(max) 
	SELECT @HTMLString = COALESCE(@HTMLString, '') + HTMLData From @HTMLTable
	
	return @HTMLString





















	--	Declare @CommentOutput nVARCHAR(max)

	--	SELECT 
	--	@CommentOutput =
	--	case
	--		when rtrim(StaffTitle) = '' or StaffTitle is null 
	--		then isnull(@CommentOutput,'') + '<div style="font-weight:bold">' + (Select ClassTitle) + ' ('+ (Select TFname + ' ' + TLname) + ')</div>' + '<div>' + TermComment + '</div><br style="line-height:.5"/>'
	--		else isnull(@CommentOutput,'') + '<div style="font-weight:bold">' + (Select ClassTitle) + ' ('+ (Select StaffTitle + ' ' + TLname) + ')</div>' + '<div>' + TermComment + '</div><br style="line-height:.5"/>'
	--	end
	--	FROM Transcript
	--	Where
	--	TermID = @TermID
	--	and
	--	StudentID = @StudentID
	--	and
	--	ClassTypeID = 3
	--	and
	--	TermComment is not null
	--	and
	--	TermComment != ''
	--	and
	--	TermComment != '<P>&nbsp;</P>'
	--	and
	--	TermComment != '<P><BR></P>'
	--	and
	--	TermComment != '<p><br mce_bogus="1"></p>'
	--	and
	--	TermComment != '<P> </P>'
		

	--Insert into @Comments 
	--Select REPLACE(REPLACE(REPLACE(Replace(@CommentOutput, '> </p>', '><br/></p>') , '''' , '\''' ) , CHAR(13) , '' ) , CHAR(10) , '' )

	--Return 

End
GO
