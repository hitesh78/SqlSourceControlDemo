SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[ChangeLoginKey]

as

    -- create LoginKey
    Declare @DecLoginKey Decimal(28,19)
    Declare @IntLoginKey Int
    Set @DecLoginKey = Convert(dec(19,19),Rand())
    Set @IntLoginKey = convert(int, @DecLoginKey*1000000000)

    --Update LoginKey Table
    Declare @OldLoginKey int
    Set @OldLoginKey = (Select Code from LoginKey where CodeId = 1)

    Update LoginKey
    Set Code = @OldLoginKey
    Where CodeID = 2

    Update LoginKey
    Set Code = @IntLoginKey
    Where CodeID = 1

GO
