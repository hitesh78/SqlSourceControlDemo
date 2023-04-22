SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[funcLunchCharges](@InvoicePeriodID int=null)
RETURNS @retTable TABLE 
(
	SessionID int,
	InvoicePeriodID int,
	StudentID int,
	[Date] date,
	TransactionTypeID int,
	Amount money
)
AS 
BEGIN
	declare @from date
	declare @thru date
	declare @SessionID int = null

	if @InvoicePeriodID is null
		select @from=min(fromdate), @thru=max(thrudate) 
		from InvoicePeriods
	else
		select @from=fromdate, @thru=thrudate, @SessionID=SessionID 
		from InvoicePeriods 
		where InvoicePeriodID=@InvoicePeriodID

	--
	-- FD 114602 / DS-251 Use following prequery to optimize this function
	--
	declare @alreadyPosted table (StudentID int,SessionID int,Date date);
	insert into @alreadyPosted
	Select distinct r.StudentID,tt.SessionID,r.Date 
		from Receivables r
		inner join TransactionTypes tt
		on r.TransactionTypeID = tt.TransactionTypeID
		and tt.AttendanceCode is not null
		where date between @from and @thru

	;with
	attend as (
		select 
			A.ClassDate as Date,
			A.CSID,
			Att1,Att2,Att3,Att4,Att5,Att6,Att7,Att8,Att9,Att10,Att11,Att12,Att13,Att14,Att15 
		from 
		Attendance A
			inner join 
		ClassesStudents CS
			on A.CSID = CS.CSID
			inner join
		Classes C
			on C.ClassID = CS.ClassID
		where 
		C.ClassTypeID = 5
		and
		A.ClassDate between @from and @thru
	)
	insert into @retTable
	select 
		x.SessionID, x.InvoicePeriodID, x.StudentID, x.Date, 
		ABS(x.TransactionTypeID) TransactionTypeID, 
		ABS(x.Amount) Amount
		from (
			select 
				MIN(tt.SessionID) SessionID,
				MIN(ip.InvoicePeriodID) InvoicePeriodID,
				cs.StudentID,
				[Date],
				MIN(
					-- trick to favor free or reduced charges...  pairs with abs() above...
					case when charindex(tt.FinAid,sm.FinAid)>0 then -1 else 1 end * tt.transactiontypeid
				) as TransactionTypeID,
				MIN(
					-- Wrike #178636349:
					-- trick to favor free or reduced charges...  pairs with abs() above...
					case when charindex(tt.FinAid,sm.FinAid)>0 then -1 else 1 end * tt.amount
				) as amount
			from (
				select 'Att1' as ID, Att1 as Att, [Date], CSID
				from attend 
				where Att1=1 --and 'Att1' in (select AttendanceCode from tt)
				union all
				select 'Att2' as ID, Att2 as Att, [Date], CSID
				from attend 
				where Att2=1 --and 'Att2' in (select AttendanceCode from tt)
				union all
				select 'Att3' as ID, Att3 as Att, [Date], CSID
				from attend 
				where Att3=1 --and 'Att3' in (select AttendanceCode from tt)
				union all
				select 'Att4' as ID, Att4 as Att, [Date], CSID
				from attend 
				where Att4=1 --and 'Att4' in (select AttendanceCode from tt)
				union all
				select 'Att5' as ID, Att5 as Att, [Date], CSID
				from attend 
				where Att5=1 --and 'Att5' in (select AttendanceCode from tt)
				union all
				select 'Att6' as ID, Att6 as Att, [Date], CSID
				from attend 
				where Att6=1 --and 'Att6' in (select AttendanceCode from tt)
				union all
				select 'Att7' as ID, Att7 as Att, [Date], CSID
				from attend 
				where Att7=1 --and 'Att7' in (select AttendanceCode from tt)
				union all
				select 'Att8' as ID, Att8 as Att, [Date], CSID
				from attend 
				where Att8=1 --and 'Att8' in (select AttendanceCode from tt)
				union all
				select 'Att9' as ID, Att9 as Att, [Date], CSID
				from attend 
				where Att9=1 --and 'Att9' in (select AttendanceCode from tt)
				union all
				select 'Att10' as ID, Att10 as Att, [Date], CSID
				from attend 
				where Att10=1 --and 'Att10' in (select AttendanceCode from tt)
				union all
				select 'Att11' as ID, Att11 as Att, [Date], CSID
				from attend 
				where Att11=1 --and 'Att11' in (select AttendanceCode from tt)
				union all
				select 'Att12' as ID, Att12 as Att, [Date], CSID
				from attend 
				where Att12=1 --and 'Att12' in (select AttendanceCode from tt)
				union all
				select 'Att13' as ID, Att13 as Att, [Date], CSID
				from attend 
				where Att13=1 --and 'Att13' in (select AttendanceCode from tt)
				union all
				select 'Att14' as ID, Att14 as Att, [Date], CSID
				from attend 
				where Att14=1 --and 'Att14' in (select AttendanceCode from tt)
				union all
				select 'Att15' as ID, Att15 as Att, [Date], CSID
				from attend 
				where Att15=1 --and 'Att15' in (select AttendanceCode from tt)
			) x
			inner join AttendanceSettings aset 
			on x.ID = aset.ID and aset.Title>'' and Att>0
			inner join ClassesStudents cs on cs.csid=x.csid
			inner join Students s on cs.StudentID = s.StudentID
			left join StudentMiscFields sm on cs.StudentID = sm.StudentID
			inner join TransactionTypes tt on tt.AttendanceCode = aset.id
				 and (tt.FinAid is null or tt.FinAid='' or charindex(tt.FinAid,sm.FinAid)>0)
			inner join InvoicePeriods ip
				on [Date] between ip.FromDate and ip.ThruDate and ip.SessionID=tt.SessionID 
				and (@InvoicePeriodID is null or ip.InvoicePeriodID = @InvoicePeriodID)
			group by tt.SessionID,lname,mname,fname,xStudentID,[Date],cs.StudentID,aset.title

	) x

	-- Filter out pending lunch charges if these charges have already been posted
	-- to another Session....
	left join @alreadyPosted xx
	on x.StudentID=xx.StudentID and x.Date = xx.Date
	where xx.StudentID is null -- nothing posted or
	or x.SessionID = xx.SessionID -- what's posted is for same SessionID

	RETURN
END
GO
