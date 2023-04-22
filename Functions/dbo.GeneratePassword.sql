SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[GeneratePassword]()
RETURNS nvarchar(10)
AS
BEGIN
	RETURN
	(
		Select
		isnull(SchoolAcronym,DB_NAME()) + '-' +
		convert(nvarchar(20),(convert(int,convert(varbinary(2),(Select [NewID] From GetNewID)))))
		From Settings
		Where
		SettingID = 1
	)
END


GO
