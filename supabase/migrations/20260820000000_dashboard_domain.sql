create extension if not exists pgcrypto;

create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  email text not null,
  phone text,
  role text not null default 'Worker',
  language text not null default 'en',
  created_at timestamptz not null default now()
);

create table if not exists public.farms (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  location text,
  manager text,
  capacity integer not null default 0 check (capacity >= 0),
  status text not null default 'Active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.batches (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  farm_id uuid references public.farms(id) on delete set null,
  batch_name text not null,
  breed text not null,
  bird_count integer not null check (bird_count >= 0),
  initial_bird_count integer not null default 0 check (initial_bird_count >= 0),
  mortality_count integer not null default 0 check (mortality_count >= 0),
  age_weeks integer not null default 0 check (age_weeks >= 0),
  status text not null default 'Active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.egg_productions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  farm_id uuid references public.farms(id) on delete set null,
  batch_id uuid references public.batches(id) on delete set null,
  production_date date not null default current_date,
  quantity integer not null check (quantity >= 0),
  broken_quantity integer not null default 0 check (broken_quantity >= 0),
  notes text,
  created_at timestamptz not null default now(),
  check (broken_quantity <= quantity)
);

create table if not exists public.feed_inventory (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  supplier_id uuid,
  feed_type text not null,
  quantity numeric(12,2) not null default 0 check (quantity >= 0),
  unit text not null default 'kg',
  low_stock_threshold numeric(12,2) not null default 0 check (low_stock_threshold >= 0),
  unit_cost numeric(12,2) not null default 0 check (unit_cost >= 0),
  updated_at timestamptz not null default now()
);

create table if not exists public.suppliers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  phone text,
  email text,
  address text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.customers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  phone text,
  email text,
  address text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.sales (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  customer_id uuid references public.customers(id) on delete set null,
  product text not null default 'Eggs',
  quantity numeric(12,2) not null check (quantity > 0),
  unit_price numeric(12,2) not null check (unit_price >= 0),
  sale_date date not null default current_date,
  payment_status text not null default 'Pending',
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.expenses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  farm_id uuid references public.farms(id) on delete set null,
  supplier_id uuid references public.suppliers(id) on delete set null,
  category text not null,
  amount numeric(12,2) not null check (amount > 0),
  expense_date date not null default current_date,
  description text,
  created_at timestamptz not null default now()
);

create table if not exists public.health_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  batch_id uuid references public.batches(id) on delete set null,
  record_type text not null,
  medicine text,
  record_date date not null default current_date,
  status text not null default 'Completed',
  notes text,
  created_at timestamptz not null default now()
);

alter table public.batches add column if not exists initial_bird_count integer not null default 0;
alter table public.batches add column if not exists mortality_count integer not null default 0;
alter table public.batches add column if not exists farm_id uuid references public.farms(id) on delete set null;

create index if not exists batches_user_created_idx on public.batches(user_id, created_at desc);
create index if not exists eggs_user_date_idx on public.egg_productions(user_id, production_date desc);
create index if not exists sales_user_date_idx on public.sales(user_id, sale_date desc);
create index if not exists expenses_user_date_idx on public.expenses(user_id, expense_date desc);

alter table public.users enable row level security;
alter table public.farms enable row level security;
alter table public.batches enable row level security;
alter table public.egg_productions enable row level security;
alter table public.feed_inventory enable row level security;
alter table public.suppliers enable row level security;
alter table public.customers enable row level security;
alter table public.sales enable row level security;
alter table public.expenses enable row level security;
alter table public.health_records enable row level security;

drop policy if exists users_select_own on public.users;
drop policy if exists users_insert_own on public.users;
drop policy if exists users_update_own on public.users;
drop policy if exists users_delete_own on public.users;
create policy users_select_own on public.users for select using (id = auth.uid());
create policy users_insert_own on public.users for insert with check (id = auth.uid());
create policy users_update_own on public.users for update using (id = auth.uid()) with check (id = auth.uid());
create policy users_delete_own on public.users for delete using (id = auth.uid());

do $$
declare
  table_name text;
begin
  foreach table_name in array array['farms','batches','egg_productions','feed_inventory','suppliers','customers','sales','expenses','health_records'] loop
    execute format('drop policy if exists %I on public.%I', table_name || '_select_own', table_name);
    execute format('drop policy if exists %I on public.%I', table_name || '_insert_own', table_name);
    execute format('drop policy if exists %I on public.%I', table_name || '_update_own', table_name);
    execute format('drop policy if exists %I on public.%I', table_name || '_delete_own', table_name);
    execute format('create policy %I on public.%I for select using (user_id = auth.uid() or id = auth.uid())', table_name || '_select_own', table_name);
    execute format('create policy %I on public.%I for insert with check (user_id = auth.uid() or id = auth.uid())', table_name || '_insert_own', table_name);
    execute format('create policy %I on public.%I for update using (user_id = auth.uid() or id = auth.uid()) with check (user_id = auth.uid() or id = auth.uid())', table_name || '_update_own', table_name);
    execute format('create policy %I on public.%I for delete using (user_id = auth.uid() or id = auth.uid())', table_name || '_delete_own', table_name);
  end loop;
end $$;
