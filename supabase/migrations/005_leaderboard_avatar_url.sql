drop view if exists leaderboard_view;

create view leaderboard_view as
select
  p.id as user_id,
  p.display_name,
  p.avatar_color,
  p.avatar_url,
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
group by p.id, p.display_name, p.avatar_color, p.avatar_url, p.class_code;
