SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[LunchCharges] as
select * from dbo.funcLunchCharges(DEFAULT)
/*
select x.* from (

		select 
			MIN(tt.SessionID) SessionID,
			MIN(ip.InvoicePeriodID) InvoicePeriodID,
			cs.StudentID,
			ClassDate Date,
			MIN(tt.transactiontypeid) as TransactionTypeID,
			min(tt.amount) Amount
		from (
			select 'Att1' as ID, Att1 as Att, ClassDate, CSID
			from Attendance union all
			select 'Att2' as ID, Att2 as Att, ClassDate, CSID
			from Attendance union all
			select 'Att3' as ID, Att3 as Att, ClassDate, CSID
			from Attendance union all
			select 'Att4' as ID, Att4 as Att, ClassDate, CSID
			from Attendance union all
			select 'Att5' as ID, Att5 as Att, ClassDate, CSID
			from Attendance union all
			select 'Att6' as ID, Att6 as Att, ClassDate, CSID
			from Attendance union all
			select 'Att7' as ID, Att7 as Att, ClassDate, CSID
			from Attendance union all
			select 'Att8' as ID, Att8 as Att, ClassDate, CSID
			from Attendance union all
			select 'Att9' as ID, Att9 as Att, ClassDate, CSID
			from Attendance union all
			select 'Att10' as ID, Att10 as Att, ClassDate, CSID
			from Attendance union all
			select 'Att11' as ID, Att11 as Att, ClassDate, CSID
			from Attendance union all
			select 'Att12' as ID, Att12 as Att, ClassDate, CSID
			from Attendance union all
			select 'Att13' as ID, Att13 as Att, ClassDate, CSID
			from Attendance union all
			select 'Att14' as ID, Att14 as Att, ClassDate, CSID
			from Attendance union all
			select 'Att15' as ID, Att15 as Att, ClassDate, CSID
			from Attendance 
		) x
		inner join AttendanceSettings aset 
		on x.ID = aset.ID and aset.Title>'' and Att>0
		inner join ClassesStudents cs on cs.csid=x.csid
		inner join Students s on cs.StudentID = s.StudentID
		left join StudentMiscFields sm on s.StudentID = sm.StudentID
		inner join TransactionTypes tt on tt.AttendanceCode = aset.id
			 and (tt.FinAid is null or tt.FinAid='' or charindex(tt.FinAid,sm.FinAid)>0)
		inner join InvoicePeriods ip
			on ClassDate between ip.FromDate and ip.ThruDate
			and ip.SessionID=tt.SessionID
		group by tt.SessionID,lname,mname,fname,xStudentID,ClassDate,cs.StudentID,aset.title

) x
-- Filter out pending lunch charges if these charges have already been posted
-- to another Session....
left join 
( Select distinct r.StudentID,tt.SessionID,r.Date 
	from
	Receivables r
	inner join TransactionTypes tt
	on r.TransactionTypeID = tt.TransactionTypeID
	and tt.AttendanceCode is not null
) xx
on x.StudentID=xx.StudentID and x.Date = xx.Date
where xx.StudentID is null -- nothing posted or
or x.SessionID = xx.SessionID -- what's posted is for same SessionID
*/
GO
