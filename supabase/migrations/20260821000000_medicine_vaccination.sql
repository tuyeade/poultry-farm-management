create table if not exists public.medicines (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  farm_id uuid references public.farms(id) on delete cascade,
  medicine_name text not null,
  quantity integer not null default 0 check (quantity >= 0),
  purchase_cost numeric(12,2) not null default 0 check (purchase_cost >= 0),
  expiry_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.vaccinations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  farm_id uuid references public.farms(id) on delete cascade,
  batch_id uuid,
  medicine_id uuid references public.medicines(id) on delete set null,
  vaccination_date date not null default current_date,
  next_due_date date,
  notes text,
  created_at timestamptz not null default now()
);

create index if not exists medicines_farm_idx on public.medicines(farm_id);
create index if not exists vaccinations_farm_date_idx
  on public.vaccinations(farm_id, vaccination_date desc);

alter table public.medicines enable row level security;
alter table public.vaccinations enable row level security;

drop policy if exists medicines_select_own on public.medicines;
drop policy if exists medicines_insert_own on public.medicines;
drop policy if exists medicines_update_own on public.medicines;
drop policy if exists medicines_delete_own on public.medicines;
create policy medicines_select_own on public.medicines for select
  using (user_id = auth.uid());
create policy medicines_insert_own on public.medicines for insert
  with check (user_id = auth.uid());
create policy medicines_update_own on public.medicines for update
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy medicines_delete_own on public.medicines for delete
  using (user_id = auth.uid());

drop policy if exists vaccinations_select_own on public.vaccinations;
drop policy if exists vaccinations_insert_own on public.vaccinations;
drop policy if exists vaccinations_update_own on public.vaccinations;
drop policy if exists vaccinations_delete_own on public.vaccinations;
create policy vaccinations_select_own on public.vaccinations for select
  using (user_id = auth.uid());
create policy vaccinations_insert_own on public.vaccinations for insert
  with check (user_id = auth.uid());
create policy vaccinations_update_own on public.vaccinations for update
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy vaccinations_delete_own on public.vaccinations for delete
  using (user_id = auth.uid());