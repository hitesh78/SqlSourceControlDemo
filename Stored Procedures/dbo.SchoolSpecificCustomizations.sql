SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[SchoolSpecificCustomizations] as

if (select schoolid from Settings)='761'
begin

-- begin try

declare @NI_Line int
declare @TermID int
declare @StudentID int
declare @ClassCode nvarchar(20)

declare @NeedsImprovement table(ID int identity(1,1), NI_Line int, StudentID int, TermID int, ClassCode nvarchar(20))

declare @NI_Collated table(NI_Line int, StudentID int, TermID int, ClassCodes nvarchar(500) )

--drop table rcdata
--select * into rcdata from #ReportCardData


insert into @NeedsImprovement
select TheString,studentid,termid, case when location='' then '*' else location end as location
from dbo.SplitCSVStrings( '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30' ) SubclassLine	 
inner join 
(
	select rc.studentid studentid,rc.termid,
		(select location 
			from classes 
			where classid = rc.classid) location, 
		rc.classcomments 
	from #ReportCardData rc 
		where rc.classcomments>'' 
) ClassCodes
on charindex(','+SubclassLine.TheString+',',','+replace(ClassCodes.classcomments,' ','')+',')>0 

Declare @NumLines int = @@RowCount
Declare @LineNumber int = 1

While @LineNumber <= @NumLines
Begin
    select	@NI_Line=NI_Line, 
			@StudentID=StudentID, 
			@TermID=TermID, 
			@ClassCode=ClassCode 
		from @NeedsImprovement where ID = @LineNumber
		
	update @NI_Collated set ClassCodes = ClassCodes +','+ @ClassCode
		where NI_Line=@NI_Line and StudentID=@StudentID and TermID=@TermID
	if @@ROWCOUNT = 0
		insert into @NI_Collated (NI_Line, StudentID, TermID, ClassCodes)
			values (@NI_Line, @StudentID, @TermID, @ClassCode)

	Set @LineNumber = @LineNumber + 1
End


update #ReportCardData 
	set CustomFieldGrade = ni.ClassCodes
from (
	select 
		studentid, customFieldName, classid,
--		replace(left(customfieldname,CHARINDEX('<',customfieldname)),'<','') customField, 
--		replace(substring(customfieldname,CHARINDEX('<',customfieldname)+1,999),'>','') as commentNumber
		indent  as commentNumber
	from #ReportCardData where classid is not null and indent<>0 --  CHARINDEX('<',customfieldname) > 0
) rc1
inner join #ReportCardData 
	on	rc1.studentid=#ReportCardData.studentid 
		and #ReportCardData.CustomFieldName=rc1.CustomFieldName
inner join @NI_Collated ni 
	on rc1.StudentID = ni.StudentID 
		and rc1.commentNumber = ni.NI_Line
where	#ReportCardData.classid is not null 
	and #ReportCardData.indent>0 -- CHARINDEX('<',#ReportCardData.customfieldname) > 0
	and #ReportCardData.TermID = ni.TermID
/*
update #ReportCardData
	set CustomFieldGrade = '0.00'
where 	#ReportCardData.classid is not null 
	and #ReportCardData.indent=0 -- CHARINDEX('<',#ReportCardData.customfieldname) > 0
*/

-- Convert 0-4 pts grades from percentage back to 0-4 values...
update rc
   set PercentageGrade = PercentageGrade/25.0
from #ReportCardData rc
where TermTitle+TermReportTitle not like '%AV%'
  and ClassTitle like '%4)%'
  and AlternativeGrade is null

-- Average class grades as a percentage to 2 decimal precision
update rc
	set AlternativeGrade 
		= cast(cast(round(
			(Select AVG(PercentageGrade) 
			from #ReportCardData rc1 
			where rc1.StudentID=rc.StudentID
				and rc1.ClassTitle=rc.ClassTitle
				and rc1.TermID<>rc.TermID
				and rc1.PercentageGrade is not null)
			,2) as numeric(7,2)) as nvarchar(7)) -- +'%'
from #ReportCardData rc
where TermTitle+TermReportTitle like '%AV%'
  and ClassTitle like '%0%'
  and AlternativeGrade is null

-- Present all class term grades as a percentage rounded to 1 decimal precision
update #ReportCardData
	set AlternativeGrade 
		= cast(cast(round(PercentageGrade,1) as numeric(7,1)) as nvarchar(7)) -- +'%'
--from #ReportCardData rc
where TermTitle+TermReportTitle not like '%AV%'
  and ClassTitle like '%0%'
  and AlternativeGrade is null

-- Average numeric subgrades that are on a 0 to 4 scale to 1 digit precision
update rc_replace
	set LetterGrade = rc_sum.grdavg
--select * 
from #ReportCardData rc_replace,
(
	select 
		StudentID,
		ClassTitle,
		CustomFieldName,
		ClassTypeID,
		cast(cast(avg(cast(LetterGrade as float)) as numeric(7,2)) as nvarchar(7)) grdavg
	from #ReportCardData 
	where 
		ISNUMERIC(LetterGrade)=1
	and TermTitle+TermReportTitle not like '%AV%'
	and CustomFieldName like '%0%'
	group by StudentID,ClassTitle,CustomFieldName, ClassTypeID
) rc_sum
where 
	rc_replace.ClassTitle = rc_sum.ClassTitle
and rc_replace.CustomFieldName = rc_sum.CustomFieldName
and rc_replace.StudentID = rc_sum.StudentID
and rc_replace.TermTitle+TermReportTitle like '%AV%'
and rc_replace.ClassTypeID=1
and rc_replace.CustomFieldName like '%0%'


-- Pull absent attendance tally into class placeholder
update rc1
	set AlternativeGrade = cast(cast(rc2.SchoolAtt2 as numeric(7,1) ) as nvarchar(7))
from #ReportCardData rc1
inner join #ReportCardData rc2
on rc1.StudentID=rc2.StudentID
	and rc1.TermID=rc2.TermID
	and rc2.ClassTypeID=5
where rc1.ClassTitle='Days Absent'
	and rc1.TermTitle+rc1.TermReportTitle not like '%AV%'

/* THIS MORE COMPLEX VARIATION PROB NOT NEEDED:
update rc
	set AlternativeGrade = xx.tot
from #ReportCardData rc
inner join 
(select	rc1.StudentID, rc1.ClassTitle, rc1.TermID,
	cast(cast(sum(rc2.SchoolAtt2) as numeric(7,1)) as nvarchar(7)) tot
from rcdata rc1
inner join rcdata rc2
on rc1.StudentID=rc2.StudentID
	and rc2.ClassTypeID=5
where rc1.ClassTitle='Days Absent'
	--and rc1.TermTitle+rc1.TermReportTitle not like '%AV%'
	and rc2.ClassTitle is not null
	and rc2.TermID=rc1.termid
group by rc1.StudentID,rc1.ClassTitle,rc1.TermID
) xx on rc.ClassTitle=xx.ClassTitle and xx.StudentID=rc.studentid and xx.TermID=rc.TermID
where rc.ClassTitle='Days Absent'
	and rc.TermTitle+rc.TermReportTitle not like '%AV%'
*/

-- Compute total absent attendance tally into class placeholder
update rc
	set AlternativeGrade = xx.tot
from #ReportCardData rc
inner join 
(select	rc1.StudentID, rc1.ClassTitle,
	cast(cast(sum(rc2.SchoolAtt2) as numeric(7,1)) as nvarchar(7)) tot
from #ReportCardData rc1
inner join #ReportCardData rc2
on rc1.StudentID=rc2.StudentID
	and rc2.ClassTypeID=5
where rc1.ClassTitle='Days Absent'
	and rc1.TermTitle+rc1.TermReportTitle like '%AV%'
	and rc2.ClassTitle is not null
group by rc1.StudentID,rc1.ClassTitle
) xx on rc.ClassTitle=xx.ClassTitle and xx.StudentID=rc.studentid
where rc.ClassTitle='Days Absent'
	and rc.TermTitle+rc.TermReportTitle like '%AV%'

-- Pull tardy attendance tally into class placeholder
update rc1
	set AlternativeGrade = cast(cast(rc2.SchoolAtt3 as numeric(7,0)) as nvarchar(7))
from #ReportCardData rc1
inner join #ReportCardData rc2
on rc1.StudentID=rc2.StudentID
	and rc1.TermID=rc2.TermID
	and rc2.ClassTypeID=5
where rc1.ClassTitle='Days Tardy'
	and rc1.TermTitle+rc1.TermReportTitle not like '%AV%'

-- Compute total number of tardies into class placeholder
update rc
	set AlternativeGrade = xx.tot
from #ReportCardData rc
inner join 
(select	rc1.StudentID, rc1.ClassTitle,
	cast(cast(sum(rc2.SchoolAtt3) as numeric(7,0)) as nvarchar(7)) tot
from #ReportCardData rc1
inner join #ReportCardData rc2
on rc1.StudentID=rc2.StudentID
	and rc2.ClassTypeID=5
where rc1.ClassTitle='Days Tardy'
	and rc1.TermTitle+rc1.TermReportTitle like '%AV%'
	and rc2.ClassTitle is not null
group by rc1.StudentID,rc1.ClassTitle
) xx on rc.ClassTitle=xx.ClassTitle and xx.StudentID=rc.studentid
where rc.ClassTitle='Days Tardy'
	and rc.TermTitle+rc.TermReportTitle like '%AV%'


--drop table rcdata
--select * into rcdata from #ReportCardData



-- Average attendance figures and present as a whole number
/*  DEPRECATE FOR NEW AVERAGE ATTENDANCE CODE ABOVE...
update #ReportCardData
	set AlternativeGrade 
		= cast(cast(round(
			(Select AVG(CAST(rc1.AlternativeGrade as float)) 
			from #ReportCardData rc1 
			where rc1.StudentID=rc.StudentID
				and rc1.ClassTitle=rc.ClassTitle
				and rc1.TermID<>rc.TermID
				and rc1.AlternativeGrade is not null
				and isnumeric(rc1.AlternativeGrade)=1
			    and rc1.ClassTitle like 'Days %'
			    and isnumeric(rc1.AlternativeGrade)=1)
			,0) as numeric(7,0)) as nvarchar(7))
from #ReportCardData rc
where TermTitle+TermReportTitle like '%AV%'
  and ClassTitle like 'Days %'
*/

-- Compute weighted average for overall work habits and behavior grades,
-- drawing from corresponding subgrades in key subjects.
update rc
  set CustomFieldGrade = CAST(cast(round(gradepoints/points,2) as numeric(7,2)) as nvarchar(7))
--select rc0.CustomFieldName,gradepoints,points,CAST(round(gradepoints/points,2) as nvarchar(7))
from #ReportCardData rc
inner join 
(select 
	StudentID,TermID,ClassID,CustomFieldName,
	(Select sum(CAST(rc1.LetterGrade as float)*cast(rc1.indent as float))
	 from #ReportCardData rc1 
	 where rc1.TermID=rc2.TermID
	   and rc1.StudentID=rc2.StudentID
	   and rc1.LetterGrade is not null
	   and rc1.Indent > 0
	   and rc1.ClassTypeID=1
	   and ISNUMERIC(rc1.LetterGrade)=1
	   and CHARINDEX(rc2.CustomFieldName,rc1.CustomFieldName)>0
	) as gradepoints,
	(Select sum(rc1.indent)
	 from #ReportCardData rc1 
	 where rc1.TermID=rc2.TermID
	   and rc1.StudentID=rc2.StudentID
	   and rc1.LetterGrade is not null
	   and ISNUMERIC(rc1.LetterGrade)=1
	   and rc1.Indent > 0 
	   and rc1.ClassTypeID=1
	   and CHARINDEX(rc2.CustomFieldName,rc1.CustomFieldName)>0
	) as points
from #ReportCardData rc2
where Indent=99) rc0
on rc.StudentID=rc0.StudentID 
and rc.ClassID=rc0.ClassID 
and rc.CustomFieldName=rc0.CustomFieldName

--end try

--begin catch
--	SELECT
--		ERROR_NUMBER() AS ErrorNumber
--		,ERROR_SEVERITY() AS ErrorSeverity
--		,ERROR_STATE() AS ErrorState
--		,ERROR_PROCEDURE() AS ErrorProcedure
--		,ERROR_LINE() AS ErrorLine
--		,ERROR_MESSAGE() AS ErrorMessage
--	into ErrorFile
--end catch


end
/*
else if (select schoolid from Settings) in (755) 
begin
--select * into rcdata from #ReportCardData


    update #ReportCardData
		set lname = lname+', '+fname + ' (' +CAST(studentid as nvarchar(10))+ ')', fname = '', mname=''
		
	update #ReportCardData 
		set gradelevel = '~', lname = lname + ':', mname = ''
		--studentid = studentid + 1000000
	where (reportorder>=10 or classtypeid<>1)
	
    update #ReportCardData set LetterGrade = null
		where ParentClassID =0 

end

else if (select schoolid from Settings) = '752'
begin
    update rc
		set lname = rc.lname+', '+rc.fname + ' (' +CAST(rc.studentid as nvarchar(10))+ ')', rc.fname = '', rc.mname=''
	from #ReportCardData rc
	inner join Students s on rc.StudentID = s.StudentID
	--where s.GradeLevel not like '%PK%' and s.GradeLevel not like '%PS%'
		
	update rc
		set gradelevel = '~ZX', rc.lname = rc.lname + ':', rc.mname = ''
		--studentid = studentid + 1000000
	from #ReportCardData rc
	inner join Students s on rc.StudentID = s.StudentID
	where (reportorder>=10 or classtypeid<>1)
	   -- and s.GradeLevel not like '%PK%' and s.GradeLevel not like '%PS%'

   update rc set LetterGrade = null
	from #ReportCardData rc
	inner join Students s on rc.StudentID = s.StudentID
	where ParentClassID =0 and s.GradeLevel not in ('4','5','6','7','8') 
	
end

else if (select schoolid from Settings) in (281)
begin
    update rc
		set lname = rc.lname+', '+rc.fname + ' (' +CAST(rc.studentid as nvarchar(10))+ ')', rc.fname = '', rc.mname=''
	from #ReportCardData rc
	inner join Students s on rc.StudentID = s.StudentID
	--where s.GradeLevel not like '%PK%' and s.GradeLevel not like '%PS%'
		
	update rc
		set gradelevel = '~ZX', rc.lname = rc.lname + ':', rc.mname = ''
		--studentid = studentid + 1000000
	from #ReportCardData rc
	inner join Students s on rc.StudentID = s.StudentID
	where (reportorder>=10 or classtypeid<>1)
	   -- and s.GradeLevel not like '%PK%' and s.GradeLevel not like '%PS%'

   update rc set LetterGrade = null
	from #ReportCardData rc
	inner join Students s on rc.StudentID = s.StudentID
	where ParentClassID =0 --and s.GradeLevel not in ('4','5','6','7','8') 
	
end
*/

GO
