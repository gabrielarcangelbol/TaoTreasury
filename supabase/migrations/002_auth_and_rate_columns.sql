-- ============================================================================
-- Migration: add rate/currency columns, and switch access from open "anon"
-- to authenticated-only, with delete disabled on the payments ledger.
-- Paste into Supabase -> SQL Editor -> New query -> Run.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- New columns on payments: the manual exchange rate used (VES methods only)
-- and which currency that rate was quoted against. Purely informational —
-- it does not change how the USD amount is calculated.
-- ----------------------------------------------------------------------------
alter table payments add column if not exists rate numeric(10,4);
alter table payments add column if not exists rate_currency text check (rate_currency in ('USD', 'EUR'));

-- ============================================================================
-- DROP the old permissive "anon" policies from the first migration — the app
-- now requires a login, so these are no longer needed.
-- ============================================================================
drop policy if exists "Allow anon read payments" on payments;
drop policy if exists "Allow anon insert payments" on payments;
drop policy if exists "Allow anon update payments" on payments;
drop policy if exists "Allow anon delete payments" on payments;

drop policy if exists "Allow anon read initial_balances" on initial_balances;
drop policy if exists "Allow anon insert initial_balances" on initial_balances;
drop policy if exists "Allow anon update initial_balances" on initial_balances;
drop policy if exists "Allow anon delete initial_balances" on initial_balances;

drop policy if exists "Allow anon upload receipts" on storage.objects;
drop policy if exists "Allow anon read receipts" on storage.objects;

-- ============================================================================
-- NEW policies: authenticated users only (Gabriel and Jefferson, once you
-- create their accounts in Authentication -> Users).
--
-- payments: read + insert only. No update, no delete policy at all — so even
-- a logged-in user cannot delete or edit a payment record once saved. This
-- keeps the transaction ledger as an audit trail, per your request.
--
-- initial_balances: read + insert + update + delete. This table represents
-- starting balances/settings rather than transaction history, and the "Save
-- Initial Balances" flow needs to replace old rows when you edit that form —
-- so it keeps full access. Let me know if you'd rather lock this down too.
-- ============================================================================

create policy "Authenticated read payments" on payments
    for select to authenticated using (true);
create policy "Authenticated insert payments" on payments
    for insert to authenticated with check (true);

create policy "Authenticated read initial_balances" on initial_balances
    for select to authenticated using (true);
create policy "Authenticated insert initial_balances" on initial_balances
    for insert to authenticated with check (true);
create policy "Authenticated update initial_balances" on initial_balances
    for update to authenticated using (true);
create policy "Authenticated delete initial_balances" on initial_balances
    for delete to authenticated using (true);

create policy "Authenticated upload receipts" on storage.objects
    for insert to authenticated with check (bucket_id = 'receipts');
create policy "Authenticated read receipts" on storage.objects
    for select to authenticated using (bucket_id = 'receipts');
