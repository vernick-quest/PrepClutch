-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Section enum
create type section_type as enum ('verbal', 'quantitative', 'reading', 'math', 'language');

-- Profiles table
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  class_code text not null default '',
  avatar_color text not null default '#f59e0b',
  created_at timestamptz not null default now()
);

alter table profiles enable row level security;

create policy "Users can view profiles in same class"
  on profiles for select
  using (true);

create policy "Users can insert their own profile"
  on profiles for insert
  with check (auth.uid() = id);

create policy "Users can update their own profile"
  on profiles for update
  using (auth.uid() = id);

-- Questions table
create table questions (
  id uuid primary key default uuid_generate_v4(),
  section section_type not null,
  prompt text not null,
  passage text,
  options jsonb not null,
  correct_index int not null check (correct_index between 0 and 3),
  difficulty int not null check (difficulty between 1 and 3),
  explanation text,
  created_at timestamptz not null default now()
);

alter table questions enable row level security;

create policy "Questions are publicly readable"
  on questions for select
  using (true);

-- Quiz attempts table
create table quiz_attempts (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  section text not null,
  score int not null default 0,
  total_questions int not null default 0,
  answers jsonb,
  total_xp int not null default 0
);

alter table quiz_attempts enable row level security;

create policy "Users can view own attempts"
  on quiz_attempts for select
  using (auth.uid() = user_id);

create policy "Users can insert own attempts"
  on quiz_attempts for insert
  with check (auth.uid() = user_id);

create policy "Users can update own attempts"
  on quiz_attempts for update
  using (auth.uid() = user_id);

-- Achievement definitions
create table achievement_definitions (
  id uuid primary key default uuid_generate_v4(),
  key text unique not null,
  label text not null,
  description text not null,
  icon_emoji text not null,
  threshold int not null default 1
);

alter table achievement_definitions enable row level security;

create policy "Achievements publicly readable"
  on achievement_definitions for select
  using (true);

-- User achievements
create table user_achievements (
  user_id uuid not null references profiles(id) on delete cascade,
  achievement_key text not null references achievement_definitions(key) on delete cascade,
  earned_at timestamptz not null default now(),
  primary key (user_id, achievement_key)
);

alter table user_achievements enable row level security;

create policy "Users can view own achievements"
  on user_achievements for select
  using (auth.uid() = user_id);

create policy "Users can insert own achievements"
  on user_achievements for insert
  with check (auth.uid() = user_id);

-- Leaderboard view (per class)
create or replace view leaderboard_view as
select
  p.id as user_id,
  p.display_name,
  p.avatar_color,
  p.class_code,
  coalesce(
    round(
      (
        coalesce(max(case when qa.section = 'verbal' then (qa.score::float / nullif(qa.total_questions,0)) * 100 end), 0) +
        coalesce(max(case when qa.section = 'quantitative' then (qa.score::float / nullif(qa.total_questions,0)) * 100 end), 0) +
        coalesce(max(case when qa.section = 'reading' then (qa.score::float / nullif(qa.total_questions,0)) * 100 end), 0) +
        coalesce(max(case when qa.section = 'math' then (qa.score::float / nullif(qa.total_questions,0)) * 100 end), 0) +
        coalesce(max(case when qa.section = 'language' then (qa.score::float / nullif(qa.total_questions,0)) * 100 end), 0)
      ) / 5
    )::int
  , 0) as aggregate_score,
  coalesce(max(case when qa.section = 'verbal' then round((qa.score::float / nullif(qa.total_questions,0)) * 100)::int end), 0) as verbal_score,
  coalesce(max(case when qa.section = 'quantitative' then round((qa.score::float / nullif(qa.total_questions,0)) * 100)::int end), 0) as quantitative_score,
  coalesce(max(case when qa.section = 'reading' then round((qa.score::float / nullif(qa.total_questions,0)) * 100)::int end), 0) as reading_score,
  coalesce(max(case when qa.section = 'math' then round((qa.score::float / nullif(qa.total_questions,0)) * 100)::int end), 0) as math_score,
  coalesce(max(case when qa.section = 'language' then round((qa.score::float / nullif(qa.total_questions,0)) * 100)::int end), 0) as language_score,
  coalesce(sum(qa.total_xp), 0) as total_xp
from profiles p
left join quiz_attempts qa on qa.user_id = p.id and qa.completed_at is not null
group by p.id, p.display_name, p.avatar_color, p.class_code;
