SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[ChangeID]
	@TheString nvarchar(200)
as

Update Test

Set theString = @TheString
where AssignmentID = 8

GO
