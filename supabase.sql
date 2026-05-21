create extension if not exists pgcrypto;

create table if not exists public.employee_daily_plans (
  id uuid primary key default gen_random_uuid(),
  employee_name text not null,
  employee_index integer not null,
  plan_date date not null,
  locs jsonb not null default '[]'::jsonb,
  tasks jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint employee_daily_plans_employee_date_key unique (employee_name, plan_date)
);

create index if not exists employee_daily_plans_plan_date_idx
  on public.employee_daily_plans (plan_date desc);

create index if not exists employee_daily_plans_employee_name_idx
  on public.employee_daily_plans (employee_name);

create or replace function public.set_employee_daily_plans_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists trg_employee_daily_plans_updated_at on public.employee_daily_plans;

create trigger trg_employee_daily_plans_updated_at
before update on public.employee_daily_plans
for each row
execute function public.set_employee_daily_plans_updated_at();

alter table public.employee_daily_plans enable row level security;

drop policy if exists "anon can read employee daily plans" on public.employee_daily_plans;
create policy "anon can read employee daily plans"
on public.employee_daily_plans
for select
to anon
using (true);

drop policy if exists "anon can insert employee daily plans" on public.employee_daily_plans;
create policy "anon can insert employee daily plans"
on public.employee_daily_plans
for insert
to anon
with check (true);

drop policy if exists "anon can update employee daily plans" on public.employee_daily_plans;
create policy "anon can update employee daily plans"
on public.employee_daily_plans
for update
to anon
using (true)
with check (true);
