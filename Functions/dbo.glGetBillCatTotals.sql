SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[glGetBillCatTotals]
(
	@StudentID int, @SessionID int
)
RETURNS nvarchar(4000)
AS
BEGIN
	declare @xml_var xml

	declare @SchoolID nvarchar(32) = (select SchoolID from Settings);

	set @xml_var = 
	(
		select 
			x.ReceivableCategory, 
			cast(Amount as decimal(12,2)) Amount
		from (
			select 
				case when BillCat.notes is not null then BillCat.notes else tt.ReceivableCategory end 
					as ReceivableCategory,
				sum(vr.SignedAmount) as Amount 
			from vReceivables vr
				inner join TransactionTypes tt
					on vr.TransactionTypeID = tt.TransactionTypeID
				left join (select title,SUBSTRING(cast(notes as nvarchar(4000)),2,9999) notes 
					from selectOptions where SelectListID=21 and left(cast(notes as nvarchar(4000)),1)='*') BillCat
					on BillCat.title = tt.ReceivableCategory
			where 
				vr.StudentID = @StudentID
				and vr.SessionID = @SessionID
			group by 
				case when BillCat.notes is not null then BillCat.notes else tt.ReceivableCategory end 
		) x
		for xml auto
	)

	RETURN
		'['+
		replace(
		replace(
		replace(
		replace(
		replace(
		cast(@xml_var as nvarchar(4000))
		,'="',':"')
		,'<x ','{')
		,'" Amount:','",Amount:')
		,'/>','}')
		,'}{','},{')
		+']'
END

GO
