SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[udf_CorrectCasing] 
 (
     @String nVARCHAR(MAX)
 )
 RETURNS nVARCHAR(MAX)
 BEGIN
     DECLARE @Length INT, @Increment INT, @NewString nVARCHAR(MAX)
     DECLARE @CurrentCharacter nCHAR(1), @PreviousCharacter nCHAR(1)     

     SET @Length = LEN(LTRIM(RTRIM(@string)))
     SET @Increment = @Length - 1
     SET @NewString = ''
     SET @PreviousCharacter = ''
     SET @String = LOWER(@String)   

     WHILE @Increment >= 0
     BEGIN
         SET @CurrentCharacter = SUBSTRING(@String, (@Length-@Increment), 1)
         SET @NewString = @NewString + CASE WHEN @PreviousCharacter = '' THEN 
                  UPPER(@CurrentCharacter) ELSE @CurrentCharacter END
         SET @PreviousCharacter = @CurrentCharacter
         SET @Increment = @Increment - 1
     END
     RETURN(@NewString)
   
 END





--UPDATE Students
-- SET 
--	lname = dbo.udf_CorrectCasing(lname),
--	fname = dbo.udf_CorrectCasing(fname)
--
--Update Transcript
--	lname = dbo.udf_CorrectCasing(lname),
--	fname = dbo.udf_CorrectCasing(fname)


GO
