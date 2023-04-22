SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[DisciplineIncidenceCodes](@uniqueValues bit)
RETURNS @retTable TABLE 
(
	ID int,
	VAL nvarchar(MAX)
)
AS 
BEGIN
	
	Declare @temp table(line int identity(1,1), id int, val nvarchar(MAX))

	Insert into @temp
		select DisciplineID, IncidentCodes from Discipline
	
	Declare @NumLines int = @@RowCount
	Declare @LineNumber int = 1

	While @LineNumber <= @NumLines
	Begin

		Declare @id int = (select id from @temp Where line = @LineNumber) 
		Declare @codes nVarchar(MAX) = (select val from @temp Where line = @LineNumber) + '; '

		Declare @pos int
		Declare @priorPos int = -1;
		
		Set @pos = Charindex('; ', @codes, @priorPos + 2)
		while (@pos>0)
		begin
			Declare @val nvarchar(MAX) = Substring(@codes, @priorPos + 2, @pos - @priorPos - 2)
			if (@uniqueValues=0 or (select count(*) from @retTable where VAL=@val) = 0)
			begin
				insert into @retTable (id,val) values (@id,@val)
			end
			Set @priorPos = @pos
			Set @pos = Charindex('; ', @codes, @priorPos + 2)
		end
		

		Set @LineNumber = @LineNumber + 1

	End

	return
END

GO
