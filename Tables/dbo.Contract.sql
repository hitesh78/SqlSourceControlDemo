CREATE TABLE [dbo].[Contract]
(
[ContractID] [int] NOT NULL IDENTITY(1, 1),
[SessionID] [int] NOT NULL,
[PaymentPlanID] [int] NULL,
[StudentID] [int] NOT NULL,
[ContractDate] [date] NOT NULL CONSTRAINT [DF_Contract_ContractDate] DEFAULT (getdate()),
[TransactionTypeID] [int] NOT NULL,
[Status] [nvarchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Contract_StatusX] DEFAULT (''),
[Notes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Date1] [date] NULL,
[Desc1] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount1] [money] NULL,
[Date2] [date] NULL,
[Desc2] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount2] [money] NULL,
[Date3] [date] NULL,
[Desc3] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount3] [money] NULL,
[Date4] [date] NULL,
[Desc4] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount4] [money] NULL,
[Date5] [date] NULL,
[Desc5] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount5] [money] NULL,
[Date6] [date] NULL,
[Desc6] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount6] [money] NULL,
[Date7] [date] NULL,
[Desc7] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount7] [money] NULL,
[Date8] [date] NULL,
[Desc8] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount8] [money] NULL,
[Date9] [date] NULL,
[Desc9] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount9] [money] NULL,
[Date10] [date] NULL,
[Desc10] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount10] [money] NULL,
[Date11] [date] NULL,
[Desc11] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount11] [money] NULL,
[Date12] [date] NULL,
[Desc12] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount12] [money] NULL,
[TotalAmount] [money] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[ContractComputeTotalAmount]
 on [dbo].[Contract]
 After Update
As
begin
	declare @cnt int = null
	
	update c set c.TotalAmount = 
		isnull(c.Amount1,0) + isnull(c.Amount2,0) + isnull(c.Amount3,0)
		+ isnull(c.Amount4,0) + isnull(c.Amount5,0) + isnull(c.Amount6,0)
		+ isnull(c.Amount7,0) + isnull(c.Amount8,0) + isnull(c.Amount9,0)
		+ isnull(c.Amount10,0) + isnull(c.Amount11,0) + isnull(c.Amount12,0)
	from Contract c inner join inserted on inserted.ContractID = c.ContractID

	select @cnt = COUNT(*) from ContractNormalized 
		where ContractID in (select ContractID from inserted)
		group by ContractID,date
		having COUNT(*)>1
	if @cnt is not null
	begin
		RAISERROR ('Every installment in a contract or payment plan must have a unique date.',15,1);
		rollback;
		return;
	end
	
end

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[ContractDefaultPaymentPlanFields]
 on [dbo].[Contract]
 After Insert
As
begin
--create table messages (message nvarchar(1024))
	declare @TotalAmount money = 0.00;
	declare @Amount1 money;
	declare @Amount2 money;
	declare @Amount3 money;
	declare @Amount4 money;
	declare @Amount5 money;
	declare @Amount6 money;
	declare @Amount7 money;
	declare @Amount8 money;
	declare @Amount9 money;
	declare @Amount10 money;
	declare @Amount11 money;
	declare @Amount12 money;
	declare @Denominator money = 0.00;
	declare @RoundingError money;
	
	if Update(TotalAmount)
	begin
		set @TotalAmount = isnull((select TotalAmount from inserted),0)
	end
	
	if @TotalAmount=0 and Update(TransactionTypeID)
	begin
		set @TotalAmount = 
			(select Amount from TransactionTypes
			where TransactionTypeID=(Select TransactionTypeID from inserted))
	end

----insert into messages (message) select 'Total Amount = ' + cast(@TotalAmount as nvarchar(20))

	If Update(PaymentPlanID) 
	begin

		select
			@Amount1 = isnull(pp.Amount1,0.00),
			@Amount2 = isnull(pp.Amount2,0.00),
			@Amount3 = isnull(pp.Amount3,0.00),
			@Amount4 = isnull(pp.Amount4,0.00),
			@Amount5 = isnull(pp.Amount5,0.00),
			@Amount6 = isnull(pp.Amount6,0.00),
			@Amount7 = isnull(pp.Amount7,0.00),
			@Amount8 = isnull(pp.Amount8,0.00),
			@Amount9 = isnull(pp.Amount9,0.00),
			@Amount10 = isnull(pp.Amount10,0.00),
			@Amount11 = isnull(pp.Amount11,0.00),
			@Amount12 = isnull(pp.Amount12,0.00)
		from Inserted i 
		inner join PaymentPlans pp on i.PaymentPlanID = pp.PaymentPlanID

		set @Denominator = 
			isnull(@Amount1,0)+
			isnull(@Amount2,0)+
			isnull(@Amount3,0)+
			isnull(@Amount4,0)+
			isnull(@Amount5,0)+
			isnull(@Amount6,0)+
			isnull(@Amount7,0)+
			isnull(@Amount8,0)+
			isnull(@Amount9,0)+
			isnull(@Amount10,0)+
			isnull(@Amount11,0)+
			isnull(@Amount12,0)
--insert into messages (message) select 'Amount1='+cast(@Amount1 as nvarchar(20))
----insert into messages (message) select 'Denominator='+cast(@Denominator as nvarchar(20))
			
		if (@Denominator>0 AND @TotalAmount>0)
		begin
			set @Amount1 = round((@Amount1 * @TotalAmount)/@Denominator,2);
			set @Amount2 = round((@Amount2 * @TotalAmount)/@Denominator,2);
			set @Amount3 = round((@Amount3 * @TotalAmount)/@Denominator,2);
			set @Amount4 = round((@Amount4 * @TotalAmount)/@Denominator,2);
			set @Amount5 = round((@Amount5 * @TotalAmount)/@Denominator,2);
			set @Amount6 = round((@Amount6 * @TotalAmount)/@Denominator,2);
			set @Amount7 = round((@Amount7 * @TotalAmount)/@Denominator,2);
			set @Amount8 = round((@Amount8 * @TotalAmount)/@Denominator,2);
			set @Amount9 = round((@Amount9 * @TotalAmount)/@Denominator,2);
			set @Amount10 = round((@Amount10 * @TotalAmount)/@Denominator,2);
			set @Amount11 = round((@Amount11 * @TotalAmount)/@Denominator,2);
			set @Amount12 = round((@Amount12 * @TotalAmount)/@Denominator,2);
			set @RoundingError = @TotalAmount - @Amount1 - @Amount2 - @Amount3
					- @Amount4 - @Amount5 - @Amount6 - @Amount7 - @Amount8
					- @Amount9 - @Amount10 - @Amount11 - @Amount12;
--insert into messages (message) select 'Calc Amount12='+cast(@Amount12 as nvarchar(20))

----insert into messages (message) select cast(@RoundingError as nvarchar(20))

			if @RoundingError<>0
			begin
				if (@Amount12<>0)
					set @Amount12 = @Amount12 + @RoundingError;
				else if (@Amount11<>0)
					set @Amount11 = @Amount11 + @RoundingError;
				else if (@Amount10<>0)
					set @Amount10 = @Amount10 + @RoundingError;
				else if (@Amount9 <>0)
					set @Amount9  = @Amount9  + @RoundingError;
				else if (@Amount8 <>0)
					set @Amount8  = @Amount8  + @RoundingError;
				else if (@Amount7 <>0)
					set @Amount7  = @Amount7  + @RoundingError;
				else if (@Amount6 <>0)
					set @Amount6  = @Amount6  + @RoundingError;
				else if (@Amount5 <>0)
					set @Amount5  = @Amount5  + @RoundingError;
				else if (@Amount4 <>0)
					set @Amount4  = @Amount4  + @RoundingError;
				else if (@Amount3 <>0)
					set @Amount3  = @Amount3  + @RoundingError;
				else if (@Amount2 <>0)
					set @Amount2  = @Amount2  + @RoundingError;
				else if (@Amount1 <>0)
					set @Amount1  = @Amount1  + @RoundingError;
			end
		end
		else if (@Denominator<101.0)
		begin
			-- No sense in defaulting amounts if they appear to be percentages only...
			set @Amount1 = 0.00;
			set @Amount2 = 0.00;
			set @Amount3 = 0.00;
			set @Amount4 = 0.00;
			set @Amount5 = 0.00;
			set @Amount6 = 0.00;
			set @Amount7 = 0.00;
			set @Amount8 = 0.00;
			set @Amount9 = 0.00;
			set @Amount10 = 0.00;
			set @Amount11 = 0.00;
			set @Amount12 = 0.00;
		end
		
		update Contract set 
			Date1 = pp.Date1,
			Date2 = pp.Date2,
			Date3 = pp.Date3,
			Date4 = pp.Date4,
			Date5 = pp.Date5,
			Date6 = pp.Date6,
			Date7 = pp.Date7,
			Date8 = pp.Date8,
			Date9 = pp.Date9,
			Date10 = pp.Date10,
			Date11 = pp.Date11,
			Date12 = pp.Date12,
			Amount1 = @Amount1,
			Amount2 = @Amount2,
			Amount3 = @Amount3,
			Amount4 = @Amount4,
			Amount5 = @Amount5,
			Amount6 = @Amount6,
			Amount7 = @Amount7,
			Amount8 = @Amount8,
			Amount9 = @Amount9,
			Amount10 = @Amount10,
			Amount11 = @Amount11,
			Amount12 = @Amount12,
			TotalAmount = @TotalAmount,
			Desc1 = pp.DescPrefix1,
			Desc2 = pp.DescPrefix2,
			Desc3 = pp.DescPrefix3,
			Desc4 = pp.DescPrefix4,
			Desc5 = pp.DescPrefix5,
			Desc6 = pp.DescPrefix6,
			Desc7 = pp.DescPrefix7,
			Desc8 = pp.DescPrefix8,
			Desc9 = pp.DescPrefix9,
			Desc10 = pp.DescPrefix10,
			Desc11 = pp.DescPrefix11,
			Desc12 = pp.DescPrefix12
		from Contract ct
			inner join Inserted i on ct.ContractID = i. ContractID
			inner join PaymentPlans pp on i.PaymentPlanID = pp.PaymentPlanID
	end
end
GO
ALTER TABLE [dbo].[Contract] ADD CONSTRAINT [PK_Contract] PRIMARY KEY CLUSTERED ([ContractID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PaymentPlanID] ON [dbo].[Contract] ([PaymentPlanID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SessionID] ON [dbo].[Contract] ([SessionID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TransactionTypeID] ON [dbo].[Contract] ([TransactionTypeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Contract] ADD CONSTRAINT [FK_Contract_PaymentPlans] FOREIGN KEY ([PaymentPlanID]) REFERENCES [dbo].[PaymentPlans] ([PaymentPlanID]) ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Contract] ADD CONSTRAINT [FK_Contract_Session1] FOREIGN KEY ([SessionID]) REFERENCES [dbo].[Session] ([SessionID])
GO
ALTER TABLE [dbo].[Contract] ADD CONSTRAINT [FK_Contract_Students] FOREIGN KEY ([StudentID]) REFERENCES [dbo].[Students] ([StudentID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Contract] ADD CONSTRAINT [FK_Contract_TransactionTypes] FOREIGN KEY ([TransactionTypeID]) REFERENCES [dbo].[TransactionTypes] ([TransactionTypeID])
GO
