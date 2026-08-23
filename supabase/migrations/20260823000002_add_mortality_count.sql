alter table if exists public.chicken_batches
  add column if not exists mortality_count integer not null default 0
  check (mortality_count >= 0);