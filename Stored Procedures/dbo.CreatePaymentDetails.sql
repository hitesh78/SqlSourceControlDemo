SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Joey
-- Create date: 07/20/2022
-- Modified dt: 11/22/2022
-- Description:	Inserts Payment Transactions into PaymentDetails
-- Rev Notes:	Added PostID to fix column error (even though this is deprecated)
-- =============================================
CREATE   PROCEDURE [dbo].[CreatePaymentDetails]
@StudentID int,
@PaymentID bigint,
@AccountID nvarchar(50),
@PostID int
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ShowFamilyStatements bit;
	DECLARE @EnablCurrentActivityStatements bit;

	SELECT
		@ShowFamilyStatements = ShowFamilyStatements,
		@EnablCurrentActivityStatements = EnablCurrentActivityStatements
	FROM Settings
	WHERE SettingID = 1;

	DECLARE @FamilyOrTempID int = (
		SELECT ISNULL(FamilyID, -StudentID)
		FROM Students ss
		WHERE ss.StudentID = @StudentID);

	DECLARE @sessionIds table (SessionID int);

	INSERT INTO @sessionIds
	SELECT SessionID
	FROM (
		SELECT
			z.SessionID,
			CASE
				WHEN (z.tranCount > 0 AND @EnablCurrentActivityStatements = 1) OR 
					((z.tranCount > 0 OR ISNULL(z.balance, 0) > 0) AND z.[Status] = 'Closed') 
				THEN 1
				ELSE 0
			END as ActivityPresent,
			z.[Status]
		FROM (
			SELECT
				vip.SessionID,
				CASE
					WHEN @ShowFamilyStatements = 0 
					THEN (
						SELECT COUNT(*)
						FROM Receivables r
						INNER JOIN TransactionTypes tt
							ON r.TransactionTypeID = tt.TransactionTypeID
						WHERE tt.SessionID = vip.SessionID
							AND r.[Date] BETWEEN vip.FromDate AND vip.ThruDate
							AND StudentID = @StudentID)
					ELSE (
						SELECT COUNT(*)
						FROM ReceivablesFamily r
						INNER JOIN TransactionTypes tt
							ON r.TransactionTypeID = tt.TransactionTypeID
						WHERE tt.SessionID = vip.SessionID
							AND r.[Date] BETWEEN vip.FromDate AND vip.ThruDate
							AND FamilyOrTempID = @FamilyOrTempID)
				END AS tranCount,
				CASE 
					WHEN @ShowFamilyStatements = 0 
					THEN (
						Select SUM(SignedAmount)
						From vReceivables vr
						Where vr.SessionID = vip.SessionID
						AND vr.[Date] <= vip.ThruDate
						AND StudentID = @StudentID)
					ELSE (
						SELECT SUM(SignedAmount)
						From vReceivablesFamily vrf
						Where vrf.SessionID = vip.SessionID
						AND vrf.[Date] <= vip.ThruDate 
						AND FamilyOrTempID = @FamilyOrTempID) 
				END AS balance,
				vip.[Status]
			FROM vInvoicePeriods vip
				inner join [Session] se 
					on se.SessionID = vip.SessionID
			WHERE ISNULL(se.SuppressOnlineStatements, 0) = 0
		) z
	) zz
	WHERE ActivityPresent = 1
		AND ([Status] = 'Closed' or [Status] = 'Open');

	IF @ShowFamilyStatements = 1 
	BEGIN
		insert into PaymentDetails (PSPaymentID, TransactionTypeID, TransactionTypeBalance,	PaymentDateTime, AccountID, StudentID, PostID)
		select 
			@PaymentID as PSPaymentID,
			a.TransactionTypeID,
			a.Amount as TransactionTypeBalance,
			dbo.GLgetdatetime() as PaymentDateTime,
			@AccountID as AccountID,
			@StudentID as StudentID,
			@PostID as PostID
		from (
			select 
				vr.SessionID,
				tt.ReceivableCategory,
				(
					select TOP 1 TransactionTypeID
					from TransactionTypes 
					where ReceivableCategory = tt.ReceivableCategory
						and SessionID = vr.SessionID
						and DB_CR_Code LIKE 'Charge%'
				) as TransactionTypeID,
				SUM(vr.SignedAmount) as Amount				 
			from vReceivablesFamily vr
				inner join @sessionIds x
					on x.SessionID = vr.SessionID
				inner join TransactionTypes tt
					on vr.TransactionTypeID = tt.TransactionTypeID
			where vr.FamilyOrTempID = @FamilyOrTempID
			group by vr.SessionID, tt.ReceivableCategory
		) a
		where a.Amount <> 0
	END
	ELSE
	BEGIN
		insert into PaymentDetails (PSPaymentID, TransactionTypeID, TransactionTypeBalance,	PaymentDateTime, AccountID, StudentID, PostID)
		select 
			@PaymentID as PSPaymentID,
			a.TransactionTypeID,
			a.Amount as TransactionTypeBalance,
			dbo.GLgetdatetime() as PaymentDateTime,
			@AccountID as AccountID,
			@StudentID as StudentID,
			@PostID as PostID
		from (
			select 
				vr.SessionID,
				tt.ReceivableCategory,
				(
					select TOP 1 TransactionTypeID
					from TransactionTypes 
					where ReceivableCategory = tt.ReceivableCategory
						and SessionID = vr.SessionID
						and DB_CR_Code LIKE 'Charge%'
				) as TransactionTypeID,
				SUM(vr.SignedAmount) as Amount				 
			from vReceivables vr
				inner join @sessionIds x
					on x.SessionID = vr.SessionID
				inner join TransactionTypes tt
					on vr.TransactionTypeID = tt.TransactionTypeID
			where vr.StudentID = @StudentID
			group by vr.SessionID, tt.ReceivableCategory
		) a
		where a.Amount <> 0
	END;

END
GO
