-- Dover Invitational: run once in Supabase (SQL Editor > New query > Run).
-- Adds two new tables for the golf weekend. It doesn't touch your FDOU tables.
-- Anyone with the site link can read and enter scores, but only for this event,
-- only valid holes and stroke counts, and nobody can delete anything.

create table if not exists dover_scores (
  event text not null check (event = 'dover2026'),
  card text not null check (card ~ '^((fri|sun)-[a-z]+|sat-m[0-2]-[ab])$'),
  hole int not null check (hole between 1 and 18),
  strokes int check (strokes between 1 and 19),
  updated_at timestamptz not null default now(),
  primary key (event, card, hole)
);

create table if not exists dover_config (
  event text primary key check (event = 'dover2026'),
  data jsonb not null check (
    jsonb_typeof(data) = 'object'
    and (data - array['idx','tees','capOne','fri','sat','sun','matchPts']) = '{}'::jsonb
    and pg_column_size(data) < 20000
  ),
  updated_at timestamptz not null default now()
);

alter table dover_scores enable row level security;
alter table dover_config enable row level security;

drop policy if exists "dover read scores" on dover_scores;
drop policy if exists "dover add scores" on dover_scores;
drop policy if exists "dover edit scores" on dover_scores;
create policy "dover read scores" on dover_scores for select using (event = 'dover2026');
create policy "dover add scores" on dover_scores for insert with check (event = 'dover2026');
create policy "dover edit scores" on dover_scores for update using (event = 'dover2026') with check (event = 'dover2026');

drop policy if exists "dover read config" on dover_config;
drop policy if exists "dover add config" on dover_config;
drop policy if exists "dover edit config" on dover_config;
create policy "dover read config" on dover_config for select using (event = 'dover2026');
create policy "dover add config" on dover_config for insert with check (event = 'dover2026');
create policy "dover edit config" on dover_config for update using (event = 'dover2026') with check (event = 'dover2026');

grant select, insert, update on dover_scores, dover_config to anon, authenticated;

-- Live updates on every phone.
do $$ begin
  alter publication supabase_realtime add table dover_scores, dover_config;
exception when duplicate_object then null;
end $$;
