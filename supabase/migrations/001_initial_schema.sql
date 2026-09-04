-- ============================================================================
-- Schema for the Payment & Treasury Reconciliation app
-- Paste this whole file into Supabase -> SQL Editor -> New query -> Run
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TABLE: payments
-- Stores BOTH registered payments and internal transfers between Gabriel and
-- Jefferson (mirrors the in-memory "paymentRecords" array in the HTML app),
-- distinguished by the "type" column.
--
-- Columns used only by payments (type = 'payment'): client, destination, custodian
-- Columns used only by transfers (type = 'transfer'): sender, receiver, account, notes
-- ----------------------------------------------------------------------------
create table if not exists payments (
    id           bigint generated always as identity primary key,
    type         text not null check (type in ('payment', 'transfer')),
    date         date not null,
    method       text not null,

    -- Payment-only fields
    client       text,
    destination  text,
    custodian    text,

    -- Internal transfer-only fields
    sender       text,
    receiver     text,
    account      text,
    notes        text,

    -- Amounts (shared)
    usd          numeric(14,2) not null default 0,
    ves          numeric(14,2) not null default 0,

    -- Receipt uploaded to the "receipts" bucket (we only store the URL)
    receipt_url  text,

    created_at   timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- TABLE: initial_balances
-- One or more rows per custodian, mirroring the
-- initialBalances = { Gabriel: [...], Jefferson: [...] } object in the HTML.
-- ----------------------------------------------------------------------------
create table if not exists initial_balances (
    id           bigint generated always as identity primary key,
    custodian    text not null check (custodian in ('Gabriel', 'Jefferson')),
    method       text not null,
    destination  text not null,
    amount       numeric(14,2) not null default 0,
    created_at   timestamptz not null default now()
);

-- ============================================================================
-- ROW LEVEL SECURITY
-- Enabled from the start. For now we leave a PERMISSIVE policy so the
-- "anon key" (the one embedded in the public HTML on GitHub Pages) can
-- read and write freely — this matches how the app behaves today with
-- in-memory data, just persistent now.
--
-- This means anyone with your GitHub Pages URL could, in theory, read or
-- modify records (not just the two of you). That's acceptable as a first
-- step while the link isn't shared around, but if later you want ONLY
-- Gabriel and Jefferson to be able to write, the natural next step is to
-- enable Supabase Auth (email/password login) and change these policies to
-- require "authenticated" instead of "anon". Leaving that as a future
-- improvement — it doesn't block anything you have today.
-- ============================================================================

alter table payments enable row level security;
alter table initial_balances enable row level security;

create policy "Allow anon read payments" on payments
    for select using (true);
create policy "Allow anon insert payments" on payments
    for insert with check (true);
create policy "Allow anon update payments" on payments
    for update using (true);
create policy "Allow anon delete payments" on payments
    for delete using (true);

create policy "Allow anon read initial_balances" on initial_balances
    for select using (true);
create policy "Allow anon insert initial_balances" on initial_balances
    for insert with check (true);
create policy "Allow anon update initial_balances" on initial_balances
    for update using (true);
create policy "Allow anon delete initial_balances" on initial_balances
    for delete using (true);

-- ============================================================================
-- STORAGE: policies for the "receipts" bucket (already created, private)
-- Without this, even though the bucket exists, no one can upload or view
-- receipts.
-- ============================================================================

create policy "Allow anon upload receipts" on storage.objects
    for insert with check (bucket_id = 'receipts');

create policy "Allow anon read receipts" on storage.objects
    for select using (bucket_id = 'receipts');
