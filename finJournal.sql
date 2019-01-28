select 
	rtrim(DistrictAbbrev) 
from tblDistrict

select 
	je.Id as JournalID,
	je.ReferenceKey as JournalEntryReferenceKey,
	je.FiscalYearId as FiscalYear,
	(select DistrictID from tblDistrict) as OrgId,
	(select DistrictAbbrev from tblDistrict) as DistrictAbbrev,
	(select DistrictTitle from tblDistrict) as DistrictTitle,  
	null as DeptId,
	null as BatchId,
	CONVERT(VARCHAR(10), je.Date, 110) as DateEffective,
	CONVERT(VARCHAR(10), je.Date, 110) as DateApplied,
	CONVERT(VARCHAR(10), je.Dcreated, 110) as DateCreated,
	jed.AccountId as Account,
	acct.AccountString,
	jet.Id as JETypeId,
	jet.[Description] as JournalEntryType,
	jed.Amount as Amount,
	(
		case
			when
			( 
				(jed.amount > 0 and gl.accountcategorygroupid = -1) or -- R
				(jed.amount < 0 and gl.accountcategorygroupid = -2) or -- E
				(jed.amount < 0 and gl.accountcategorygroupid = -3) or -- A
				(jed.amount > 0 and gl.accountcategorygroupid = -4) or -- L
				(jed.amount > 0 and gl.accountcategorygroupid = -5) -- F
			)
			then
				jed.Amount
			else
				null
		end
	) as AmtCR,
	(
		case
			when	(
						(jed.amount < 0 and gl.accountcategorygroupid = -1) or 	-- R
						(jed.amount > 0 and gl.accountcategorygroupid = -2) or	-- E
						(jed.amount > 0 and gl.accountcategorygroupid = -3) or	-- A
						(jed.amount < 0 and gl.accountcategorygroupid = -4) or	-- L
						(jed.amount < 0 and gl.accountcategorygroupid = -5)		-- F
					)		
					then 
						jed.Amount 
					else
						null
					
				end
		)as AmtDR,
	(
		case	
			when je.BudgetId = 1 then 'Actual'
			when je.BudgetId = 2 then 'Encumbered'
			when je.BudgetId = 3 then 'Pre-Encumbered'
			when je.BudgetId = 4 then 'Budget'
		end
	) as Transactiontype,
	(
		case
			when gl.AccountCategoryGroupId = -1 then 'Revenue'
			when gl.AccountCategoryGroupId = -2 then 'Expense'
			when gl.AccountCategoryGroupId = -3 then 'Asset'
			when gl.AccountCategoryGroupId = -4 then 'Liability'
			when gl.AccountCategoryGroupId = -5 then 'Fund Balance'
		end
	) as AccountType,
	(
		case
			when jed.amount < 0 and gl.accountcategorygroupid = -1 then 'Debit'		-- R
			when jed.amount > 0 and gl.accountcategorygroupid = -1 then 'Credit'	-- R
			when jed.amount > 0 and gl.accountcategorygroupid = -2 then 'Debit'		-- E
			when jed.amount < 0 and gl.accountcategorygroupid = -2 then 'Credit'	-- E
			when jed.amount > 0 and gl.accountcategorygroupid = -3 then 'Debit'		-- A
			when jed.amount < 0 and gl.accountcategorygroupid = -3 then 'Credit'	-- A
			when jed.amount < 0 and gl.accountcategorygroupid = -4 then 'Debit'		-- L
			when jed.amount > 0 and gl.accountcategorygroupid = -4 then 'Credit'	-- L
			when jed.amount < 0 and gl.accountcategorygroupid = -5 then 'Debit'		-- F
			when jed.amount > 0 and gl.accountcategorygroupid = -5 then 'Credit'	-- F
		end
	) as DebitOrCredit,
	jed.Note as Comment
from JournalEntry je
inner join
	JournalEntryDetail jed
	on je.Id = jed.JournalEntryId
inner join
	DS_Global..JournalEntryType jet
	on je.JournalEntryTypeId = jet.Id
inner join
	tblAccount acct
	on acct.AccountID = jed.AccountId
inner join
	GeneralLedger gl
	on gl.AccountId = jed.AccountId
	and je.FiscalYearId = gl.FiscalYearId
where
	je.FiscalYearId = 2018
