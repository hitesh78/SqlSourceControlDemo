SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- modified 2021-08-05 ~JG
-- use [1320b]
-- SQL MERGE-PURGE ALGORITHM...
--
-- I use a simplistic "merge" strategy. First of all I download
-- the pay simple API data to its own set of files and do not comingle
-- the fields within our other SQL tables.  Next I download everything
-- to these tables from a given API call to take advantage of the 
-- simplicity of Bulk Copy from ADO.NET. In other words, I don't handle
-- any merge-purge of matches/duplicates a the middle teir level.
-- Then, finally, after downloading all activity for a recent date range, 
-- I delete whatever we already had on file (i.e. "duplicates").  
--
-- In the case of payments and payment failure
-- data, these rows do not have unique IDs. The payment ID is unique but
-- there may be multiple records for a single payment to reflect changes
-- in the status of the processing for that payment.  For example in the
-- case of a refund another record, documenting the processing of the 
-- refund is written using the same payment ID.  But the rows in this
-- pay simple download table are assigned our own UniqueID values
-- using an identity column.
--
-- The download option will filter for any transactions since a date that
-- is on or after the last rows were downloaded.  At present there is no
-- protection (RI) that a row is never deleted but the "purge" delete queries
-- below are believed to be properly coded and tested and should never 
-- lose any data.  It is also believed that the pay simple APIs will be
-- stable with no data structure changes unless we call a URI for a new
-- PS API verions which will require a code change on our side along with
-- whatever changes are indicated to these queries...
--
-- Experience has shown that the PS API can fail when requesting many rows.
-- For example, we've had requests for payment downloads fail at requests
-- that would results in between 1,000 and 2,000 rows.  I don't put a limit
-- on these queries.  We will make an effort to run them frequently enough
-- that over 1,000 payments will be unlikely to occur with any particuar 
-- download.  However, if there is a a failure it will be an event that we
-- can detect and remediate on a case by case basis as needed.  Thus, this
-- "pay simple" sync process should have instrumentation to log results and
-- send emails of failures.  Version 1.0 may not have this, but if not the
-- project should be flagged for a near-term update to add error notification.
--
-- Regarding PS API field layouts.  I have code to automatically create table
-- structures based on the JSON returned from PS.  This code will only be active
-- when running in development environment (e.g. localhost for now).  Once
-- the code creates a compatible SQL table structure, we can add additional fields
-- and push out a final structure to all schools that will be compatible with 
-- the strucure computed (that should work with Bulk Copy) as well as any addition
-- field requirements that we may have.  Such as the identity field to help
-- with the merge-purge process.  We rely on the order of these columns with 
-- bulk copy and have not gone to the added work of listing all field name
-- mappings in the bulk copy.  Therefore any additional fields we add to these 
-- PS API tables MUST be placed at the end of the row.  Additional fields
-- at the end of rows do not seem to interfere with bulk copy.
--

--
-- RETURN VALUE: # of new rows added; e.g, if 0 caller could stop scanning older history...
--

CREATE   PROCEDURE [dbo].[PS_API_Payments_Merge_Purge] @PS_API_Method varchar(20)
AS
BEGIN

	DECLARE @NumRowsAdded int = 0;
	DECLARE @LastUpdateTime datetime;

	IF @PS_API_Method = 'payment'
	BEGIN
		SET @LastUpdateTime = (SELECT MAX(UpdateTime) FROM PS_API_Payments);

		---- Merge-purge for Payment data
		--DELETE x --select x.* 
		--from PS_API_Payments as x
		--inner join (
		--	select 
		--		Id, dateadd(SECOND,ascii(Status),LastModified) LastModified,
		--		min(UniqueID) UniqueID
		--	from 
		--		PS_API_Payments
		--	where
		--		UpdateTime <> @LastUpdateTime
		--	group by 
		--		id,dateadd(SECOND,ascii(Status),LastModified)
		--) noDup
		--on x.Id = noDup.Id
		---- Comment following line out to ensure past dups are cleaned up too 
		---- (TODO: review? errors may have caused them to be skipped? but this is probably preferred as most fault tolerant)
		----
		----   AND UpdateTime = @LastUpdateTime 
		----
		--and dateadd(SECOND,ascii(Status),x.LastModified) = noDup.LastModified
		--and x.UniqueID <> noDup.UniqueID

		--
		-- Create matching rows in PSPayments (table includes GL specific fields)
		-- if matching PSPayments rows do not already exist (as they would when using QuickPay)
		-- but if matching PSCustomers rows DO exist (as they would when using AutoPay).
		-- The GL specific data is needed for complete reporting and includes:
		-- GLPaymentContext - the payment context (e.g. TuitionAutoPay = "Online Billing AutoPay),
		-- GLCreatingUserID, and GLXrefID (which we set to StudentID)
		-- (Fill in all fields available that could be used though...)
		--
		-- NOTE: Unlike PS_API_Payments, PSPayments does not contain an audit trail of 
		-- past updates to a payment, so it just takes a snapshot of whatever version is 
		-- available now.  The only fields that we really rely on though are the ones
		-- not replicated to PS_API_PAYMENTS (i.e. the three document in the paragraph above.
		--
		insert into PSPayments (
			PSPaymentID, PSCustomerID, PSAccountID,
			PSAmount, PSIsDebit, PSStatus,
			PSRecurringScheduleID, PSPaymentType, PSPaymentSubtype,
			PSProviderAuthCode, PSTraceNumber,
			PSPaymentDate, PSReturnDate,
			PSEstimatedSettleDate, PSActualSettledDate, PSCanVoidUntil,
			PSDescription, PSLastModified, PSCreatedOn,
			--PSCVV,
			GLPaymentContext, GLCreatingUserID, GLXrefID
		)
		select 
			Id, MAX(CustomerID), MAX(AccountID),
			MAX(Amount), MAX(IsDebit), MAX(Status),
			MAX(RecurringScheduleID), MAX(PaymentType), MAX(PaymentSubtype),
			MAX(ProviderAuthCode), MAX(TraceNumber),
			MAX(PaymentDate), MAX(ReturnDate),
			MAX(EstimatedSettleDate), MAX(ActualSettledDate), MAX(CanVoidUntil),
			MAX(Description), MAX(LastModified), MAX(CreatedOn),
			-- MAX(PSCVV), DO NOT STORE PII!!! 
			-- If we detect our GL AutoPay in the description, then set that context, otherwise assume Pay Simple Recurring Payment...
			MAX(case when Description like '%You authorize%' then 'TuitionAutoPay' else 'PSRecurringPay' end), 
			MAX(c.GLCreatingUserID), MAX(c.StudentID)
		from PS_API_Payments p
		inner join PSCustomers c
			on p.CustomerId = c.PSCustomerID
		where RecurringScheduleId is not null and RecurringScheduleId>0
			and p.Id not in (select PSPaymentID from PSPayments)
		group by Id	-- avoid issue of multiple historical records for PSPayment ID
								-- NOTE: max() is fine - we don't really care which version of
								--       these fields we get - most don't change...

		-- Link up failure data to a permanent PaymentID
		-- Note: Must be done after each and every bulk load
		-- to work correctly since PS_API_Payments_Id values
		-- are transient and link up only within the scope of
		-- the last download...
		update x
		set PaymentID = y.id
		from PS_API_Payments_FailureData x
		inner join PS_API_Payments y
		on x.PS_API_Payments_Id = y.PS_API_Payments_Id
		where x.PaymentID is null -- important: PS_API_Payments may only link to latest download

		-- Any failure data not linked indictes some type of error, so
		-- throw an exception...
		if (select count(*) from PS_API_Payments_FailureData where PaymentID is null) > 0
		begin
			RAISERROR ('PS API download failure data exception.',15,1);
			return;
		end

		-- Merge-purge for failure data
		DELETE x --select x.* 
		from PS_API_Payments_FailureData x
		inner join (
			select 
				PaymentID,
				-- rest prob not needed unless there are multiple failure data per payment
				Code,Description,MerchantActionText,isDecline,
				min(UniqueID) UniqueID
			from 
				PS_API_Payments_FailureData
			group by 
				PaymentID,
				-- rest prob not needed unless there are multiple failure data per payment
				Code,Description,MerchantActionText,isDecline
		) noDup
		on x.PaymentID = noDup.PaymentID
		-- rest prob not needed unless there are multiple failure data per payment
		and x.Code = noDup.Code
		and x.Description = noDup.Description
		and x.MerchantActionText = noDup.MerchantActionText
		and x.isDecline = noDup.isDecline
		and x.UniqueID <> noDup.UniqueID


		SET @NumRowsAdded = (SELECT COUNT(*) FROM PS_API_Payments WHERE UpdateTime = @LastUpdateTime);
	END

	--***************************************************************************

	IF @PS_API_Method = 'customer'
	BEGIN
		SET @LastUpdateTime = (SELECT MAX(UpdateTime) FROM PS_API_Customers);

		-- Merge-purge for PS customer data
		DELETE x --select x.* 
		from PS_API_Customers x
		inner join (
			select 
				Id, LastModified,
				min(UniqueID) UniqueID
			from 
				PS_API_Customers
			where
				UpdateTime <> @LastUpdateTime
			group by 
				id,LastModified
		) noDup
		on x.Id = noDup.Id
		and UpdateTime = @LastUpdateTime
		and x.LastModified = noDup.LastModified
		and x.UniqueID <> noDup.UniqueID

		-------------------------------------------------------------------------

		-- No need to retain null addresses
		delete PS_API_Customers_BillingAddress
		where
			StreetAddress1 is null
			and StreetAddress2 is null
			and City is null
			and StateCode is null
			and ZipCode is null
			and Country is null

		-- Link up Billing Address data to a permanent CustomerID
		-- Note: Must be done after each and every bulk load
		-- to work correctly since values
		-- are transient and link up only within the scope of
		-- the last download...
		update x
		set CustomerId = y.id
		from PS_API_Customers_BillingAddress x
		inner join PS_API_Customers y
		on x.PS_API_Customers_Id = y.PS_API_Customers_Id
		where x.CustomerId is null -- important: may only link to latest download

		-- Any failure data not linked indictes some type of error, so
		-- throw an exception...
		if (select count(*) from PS_API_Customers_BillingAddress where CustomerId is null) > 0
		begin
			RAISERROR ('PS API download Billing Addresses exception.',15,1);
			return;
		end

		-- Merge-purge for Billing Address
		DELETE x --select x.* 
		from PS_API_Customers_BillingAddress x
		inner join (
			select 
				CustomerId, -- assumes up to one address per customer
				min(UniqueID) UniqueID
			from 
				PS_API_Customers_BillingAddress
			group by 
				CustomerId -- assumes up to one address per customer
		) noDup
		on x.CustomerId = noDup.CustomerId  -- assumes up to one address per customer
		and x.UniqueID <> noDup.UniqueID

		-------------------------------------------------------------------------

		-- No need to retain null addresses
		delete PS_API_Customers_ShippingAddress
		where
			StreetAddress1 is null
			and StreetAddress2 is null
			and City is null
			and StateCode is null
			and ZipCode is null
			and Country is null

		-- Link up Shipping Address data to a permanent CustomerID
		-- Note: Must be done after each and every bulk load
		-- to work correctly since values
		-- are transient and link up only within the scope of
		-- the last download...
		update x
		set CustomerId = y.id
		from PS_API_Customers_ShippingAddress x
		inner join PS_API_Customers y
		on x.PS_API_Customers_Id = y.PS_API_Customers_Id
		where x.CustomerId is null -- important: may only link to latest download

		-- Any failure data not linked indictes some type of error, so
		-- throw an exception...
		if (select count(*) from PS_API_Customers_ShippingAddress where CustomerId is null) > 0
		begin
			RAISERROR ('PS API download Shipping Addresses exception.',15,1);
			return;
		end

		-- Merge-purge for Shipping Address
		DELETE x --select x.* 
		from PS_API_Customers_ShippingAddress x
		inner join (
			select 
				CustomerId, -- assumes up to one address per customer
				min(UniqueID) UniqueID
			from 
				PS_API_Customers_ShippingAddress
			group by 
				CustomerId -- assumes up to one address per customer
		) noDup
		on x.CustomerId = noDup.CustomerId  -- assumes up to one address per customer
		and x.UniqueID <> noDup.UniqueID

		SET @NumRowsAdded = (SELECT COUNT(*) FROM PS_API_Customers WHERE UpdateTime = @LastUpdateTime);
	END

	RETURN @NumRowsAdded;
END

GO
