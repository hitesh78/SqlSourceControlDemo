SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[glUpdateFamily2Accounts] (@error varchar(8000)=null OUTPUT)
as
begin

	DECLARE @errmsg varchar(MAX) = null
	DECLARE @errsev int
	DECLARE @errsta int
	DECLARE @errnum int
	DECLARE @errpro varchar(8000)
	DECLARE @errlin int

--	BEGIN TRANSACTION
	BEGIN TRY

		if (Select distinct 1
            From Students I
            where 
            isnull(I.Family2ID,-1) not in (select FamilyID from Families) 
            and
            (
                ltrim(rtrim(isnull(I.Family2Name1,''))) != '' 
                or
                ltrim(rtrim(isnull(I.Family2Name2,''))) != ''
            )
            and
            I.Lname<>'-'
        ) is not null
		begin
            -- 1. Populate table variable to be passed to sp PopulateAccountsAndFamilies
            Declare @FamilyInfo FamilyTableType

            insert into @FamilyInfo
            Select distinct		-- Add Family2ID if Family2 names are entered.
                I.Lname,
                I.Family2Name1,
                I.Family2Name2,
                isnull(I.Family2ID,
                    dbo.getFamily2ID(I.Lname, I.Family2Name1, I.Family2Name2, I.Street2, I.Email6, I.Email7, I.Family2Phone1, I.Family2Phone2))
            From Students I
            where 
            isnull(I.Family2ID,-1) not in (select FamilyID from Families) 
            and
            (
                ltrim(rtrim(isnull(I.Family2Name1,''))) != '' 
                or
                ltrim(rtrim(isnull(I.Family2Name2,''))) != ''
            )
            and
            I.Lname<>'-'

            IF (Select count(*) From @FamilyInfo) > 0
            begin
                -- 2. Call sp PopulateAccountsAndFamilies 
                EXEC PopulateAccountsAndFamilies @FamilyInfo

                -- 3. Update Students table
                Update I
                    Set Family2ID = F.FamilyID
                    from Students I
                    inner join
                    @FamilyInfo F
                        on	I.Lname = F.Lname
                            and
                            isnull(I.Family2Name1,'') = isnull(F.Father,'')
                            and
                            isnull(I.Family2Name2,'') = isnull(F.Mother,'')
                    where 
                    I.Lname<>'-' 
                    and 
                    I.Family2ID is null
            end

            -- Remove any orphaned family records...
            delete f
            from Families f 
            left join students s 
            on f.familyid = s.FamilyID
                or f.familyid = s.Family2ID
            where s.StudentID is null

            -- Remove orphaned family accounts (could be made more efficient)
            Delete from accounts
            Where 
            AccountID not in (Select distinct AccountID From Families)
            and 
            (Access='Family' or Access = 'Family2')
            and AccountID not in (
                select distinct AccountID from ServiceHours
            )

			set @error = 'Notice: Default Family 2 IDs needed to be created.'
		end

	END TRY
	BEGIN CATCH

--		IF @@TRANCOUNT > 0
--			ROLLBACK TRANSACTION

		SELECT @errmsg = ERROR_MESSAGE(), 
			@errsev = ERROR_SEVERITY(), 
			@errsta = ERROR_STATE(),
			@errnum = ERROR_NUMBER(),
			@errpro = ERROR_PROCEDURE(),
			@errlin = ERROR_LINE()
		IF @errsev <> 18
			SET @errmsg = @errmsg + '<br/>Error #:   ' + CAST(@errnum as varchar(20))
								  + '<br/>Procedure: ' + @errpro
								  + '<br/>Line #:    ' + CAST(@errlin as varchar(20))
        set @error = @errmsg

	END CATCH

--	IF @@TRANCOUNT > 0
--		COMMIT TRANSACTION
	
	return	
end
GO
