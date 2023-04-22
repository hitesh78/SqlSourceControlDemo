SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 8/4/2015
-- Description:	Determines if an overlay should show
-- =============================================
CREATE FUNCTION [dbo].[SetShowOverlay]
(
@OverlayID nvarchar(100),
@EK decimal(15,15)
)
RETURNS bit
AS
BEGIN

	Declare @ShowOverlay bit
	if exists
	(
		Select * 
		From
		Overlays O
			inner join 
		AccountOverlays AO
			on O.OverlayID = AO.OverlayID
			inner join
		Accounts A
			on AO.AccountID = A.AccountID
		Where
		A.EncKey = @EK
		and
		O.OverlayID = @OverlayID
		and
		O.Active = 1   
		and 
		(
		DateDiff(hour, AO.LastAccess, getDate()) > O.RemindCycleInHours
		or
		AO.LastAccess is null
		)
		and
		AO.DontRemindMe = 0
	)
	Begin
		Set @ShowOverlay = 1
	End
	Else
	Begin
		Set @ShowOverlay = 0
	End 
	
	return @ShowOverlay

END



GO
