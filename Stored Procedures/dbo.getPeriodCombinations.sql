SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create procedure [dbo].[getPeriodCombinations](@Periods OneColumnIntegersTableType READONLY, @NumberOfSections int) 
/*
Author: Don Puls
Date: 5/16/2019
Description: 
Given a set of Periods (passed in as a table varable @Periods) 
this will return all combinations of the size @NumberOfSections
these numbers with the first column being the CombinationID.
Example: 
@Periods = 1,2,3
@NumberOfSections = 2 
It would return the following combinations:
1,2
1,3
2,3
*/
as 
begin
	create table #Periods(PeriodID int);
	insert into #Periods select * From @Periods;
	Declare @SQLString nvarchar(1000) = 'Select ROW_NUMBER() OVER(Order by p1.PeriodID) as CombNum, '
	Declare @SectionNumber int = 1
	while @SectionNumber <= @NumberOfSections
	begin	-- Write the Select Part of Query
		if (@SectionNumber = @NumberOfSections)
			set @SQLString += 'convert(varchar(2),p' + convert(varchar(2),@SectionNumber) + '.PeriodID) as csvPeriods From '
		else
			--set @SQLString += 'p' + convert(varchar(2),@SectionNumber) + '.PeriodID, ';
			set @SQLString += 'convert(varchar(2),p' + convert(varchar(2),@SectionNumber) + '.PeriodID) + '','' + ';
		
		set @SectionNumber = @SectionNumber + 1;
	end
	set @SectionNumber = 1
	while @SectionNumber <= @NumberOfSections
	begin	-- Write the From Part of Query
		if (@NumberOfSections = 1)
			set @SQLString += '#Periods p' + convert(varchar(2),@SectionNumber)
		else if (@SectionNumber = @NumberOfSections)
			set @SQLString += '#Periods p' + convert(varchar(2),@SectionNumber) + ' Where '
		else
			set @SQLString += '#Periods p' + convert(varchar(2),@SectionNumber) + ' cross join ';
		set @SectionNumber = @SectionNumber + 1;
	end
	set @SectionNumber = 1
	while @SectionNumber < @NumberOfSections
	begin	-- Write the Where Part of Query
		if (@SectionNumber = (@NumberOfSections - 1))
			set @SQLString += 'p' + convert(varchar(2),@SectionNumber) + '.PeriodID < p' + convert(varchar(2),@SectionNumber+ 1) + '.PeriodID';
		else
			set @SQLString += 'p' + convert(varchar(2),@SectionNumber) + '.PeriodID < p' + convert(varchar(2),@SectionNumber+ 1) + '.PeriodID' + ' and ';
		set @SectionNumber = @SectionNumber + 1;
	end

	exec sp_executesql @SQLString;

end


GO
