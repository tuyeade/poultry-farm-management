alter table if exists public.chicken_batches
  add column if not exists age_weeks integer not null default 0
  check (age_weeks >= 0);