SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[EnrollmeImportRaceCodes]
(
    @StudentID int,
	@RaceCodes nvarchar(2000)
)
AS
BEGIN
	SET NOCOUNT ON;

	if (select distinct 1 from Race where CHARINDEX(';'+Name+';',';'+@RaceCodes+';')=0)=1
		insert into Race (Name)
			select TheString 
				from dbo.SplitCSVStringsDelimiter(@RaceCodes,';')
					where TheString not in (select Name from Race)
	
	insert into StudentRace (StudentID,RaceID)
		select @StudentID,r.RaceID
			from Race r
				where CHARINDEX(';'+r.Name+';',';'+@RaceCodes+';')<>0
					and @StudentID not in (select StudentID from StudentRace where RaceID=r.RaceID)

	if (CHARINDEX('Decline to respond',@RaceCodes)=0)
		-- don't remove any existnig race codes if "Decline to respond" selected
		-- because Federal guidlines allow schools to make their own judgement calls in these cases...
		delete from StudentRace 
			where StudentID = @StudentID 
				and RaceID in
					(Select RaceID 
						from Race
							where CHARINDEX(';'+Name+';',';'+@RaceCodes+';')=0)

	return
END

GO
