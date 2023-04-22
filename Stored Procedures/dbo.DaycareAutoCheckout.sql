SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 12/1/2021
-- Description:	Adds Checkout Records for each record that has a checkin record and its past its autocheckout date/time and this 
--				Checkout record has not yet been added. 
-- =============================================
CREATE PROCEDURE [dbo].[DaycareAutoCheckout]
AS
BEGIN
	SET NOCOUNT ON;

	insert into DayCare
	(
		StudentID,
		ContactName,
		ContactID,
		ClassID,
		DateTime,
		ContactInitials,
		CheckInOrOut
	)
	Select
	CI.StudentID,
	'Auto Checkout' as Contact,
	0 as ContactID,
	CI.ClassID,
	CONVERT(nvarchar(255),CI.theDate,1) + ' ' + convert(varchar(20),CI.PSAutoCheckoutTime) as AutoCheckout,
	'N/A' as ContactInitials,
	'CHECK OUT' as Action
	From
	(
	select distinct
	StudentID,
	d.ClassID,
	convert(date, d.DateTime) as theDate,
	c.PSAutoCheckoutTime,
	cast(convert(date,d.DateTime) as smalldatetime) + cast(c.PSAutoCheckoutTime as smalldatetime) as theDateTimeCheckout
	from 
	DayCare d
		inner join
	Classes c
		on c.ClassID = d.ClassID 
	where
	c.ClassTypeID = 9
	and
	d.CheckInOrOut = 'CHECK IN'
	) CI
		left join
	(
	select distinct
	StudentID,
	d.ClassID,
	convert(date, d.DateTime) as theDate
	from 
	DayCare d
		inner join
	Classes c
		on c.ClassID = d.ClassID 
	where
	c.ClassTypeID = 9
	and
	d.CheckInOrOut = 'CHECK OUT'
	) CO
		on	CI.StudentID = CO.StudentID
			and
			CI.ClassID = CO.ClassID
			and
			CI.theDate = CO.theDate
	Where
	CO.ClassID is null	-- Only add check out records where they don't exits in CO table
	and
	CI.theDateTimeCheckout < dbo.glgetdatetime()	-- and the theDateTimeCheckout is before the currrent gldatetime 
	Order By CI.theDate, ClassID

END
GO
