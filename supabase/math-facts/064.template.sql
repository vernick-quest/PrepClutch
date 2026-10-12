-- 064 — Math Facts card catalogue as a table, plus two new topics
--
-- Until now math_fact_cards was a view that generated the 864 times-table
-- cards in SQL, kept identical to lib/math-facts.ts by hand. That does not
-- scale to fractions and decimals, so the catalogue becomes a TABLE,
-- math_cards, loaded from lib/math-facts.ts by supabase/math-facts/cards.mts.
-- math_fact_cards stays, now reading from that table, so record_fact_answer,
-- the leaderboard and the badges keep working unchanged.
--
-- New topics (all whole-number or decimal answers, no new keypad needed
-- beyond the decimal point):
--
--   equiv  equivalent fractions, building up and simplifying   304 cards
--   fdp    fraction / decimal / percent benchmarks              90 cards
--
-- Every times-table card keeps its exact key, points and target, so every
-- answer already saved still counts for exactly what it did. The
-- verification checks that no saved answer has lost its card.
--
-- Also: four badges for the new topics, and "Calcupede Infinite" now means
-- all 864 times-table cards, as its description always said, rather than 864
-- cards from any topic.
--
-- Additive. Re-running is harmless.
-- Generated: do not edit by hand. Change lib/math-facts.ts or this template,
-- then run: node supabase/math-facts/cards.mts


-- ── 1. The catalogue ─────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS math_cards (
  fact_key  TEXT PRIMARY KEY,
  topic     TEXT NOT NULL,
  op        TEXT,
  a         INT,
  b         INT,
  form      TEXT,
  points    INT  NOT NULL,
  target_ms INT  NOT NULL
);

ALTER TABLE math_cards ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "math_cards_readable" ON math_cards;
CREATE POLICY "math_cards_readable" ON math_cards FOR SELECT USING (TRUE);

INSERT INTO math_cards (fact_key, topic, op, a, b, form, points, target_ms) VALUES
__ROWS__
ON CONFLICT (fact_key) DO UPDATE SET
  topic = EXCLUDED.topic, op = EXCLUDED.op, a = EXCLUDED.a, b = EXCLUDED.b,
  form = EXCLUDED.form, points = EXCLUDED.points, target_ms = EXCLUDED.target_ms;

-- Same columns, same order, same types as the 062 view, with topic added at
-- the end, so CREATE OR REPLACE is allowed and nothing depending on it breaks.
CREATE OR REPLACE VIEW math_fact_cards AS
SELECT fact_key, op, a, b, form, points, target_ms, topic
FROM math_cards;


-- ── 2. Badges for the new topics ─────────────────────────────────────────────

INSERT INTO achievement_definitions (key, label, icon_emoji, description, rarity, creature, category, lore, threshold) VALUES

('facts_equiv_25', 'Pizza Slicer', '🍕', '25 equivalent-fraction cards mastered.', 'Uncommon', 'Pizza Slicer', 'Math Facts',
 'Cut it in halves, cut it in eighths, it is the same pizza. The Slicer knows this in its bones and has stopped arguing with people who want more slices.', 25),

('facts_equiv_all', 'Fraction Phantom', '🍕👑', 'All 304 equivalent-fraction cards mastered.', 'Legendary', 'Fraction Phantom', 'Math Facts',
 'It sees six eighths and three quarters as the same ghost wearing different sheets. Every fraction, built up and boiled down. Nothing slips past it.', 304),

('facts_fdp_25', 'Percent Pup', '💯', '25 fraction, decimal and percent cards mastered.', 'Uncommon', 'Percent Pup', 'Math Facts',
 'A small dog who knows a quarter is twenty-five percent and will fetch it as point two five if you ask nicely.', 25),

('facts_fdp_all', 'Benchmark Baron', '⚖️', 'All 90 fraction, decimal and percent cards mastered.', 'Epic', 'Benchmark Baron', 'Math Facts',
 'Three eighths, point three seven five, thirty-seven and a half percent. The Baron hears all three as one note and is mildly offended that anyone ever needed a calculator for it.', 90)

ON CONFLICT (key) DO UPDATE SET
  label = EXCLUDED.label, icon_emoji = EXCLUDED.icon_emoji,
  description = EXCLUDED.description, rarity = EXCLUDED.rarity,
  creature = EXCLUDED.creature, category = EXCLUDED.category,
  lore = EXCLUDED.lore, threshold = EXCLUDED.threshold;

UPDATE achievement_definitions SET
  description = 'All 864 times-table cards mastered, every multiplication and division card.',
  lore = 'Every times table, both ways, every missing number. The Calcupede has grown so many legs it has lost count, which, for a Calcupede, is the highest honour.'
WHERE key = 'facts_mastered_864';


-- ── 3. Awarding, now topic-aware ─────────────────────────────────────────────
--
-- Same function as 063 with three changes: every times-table badge is pinned
-- to topic 'times' (a fraction card has no op or form and must never count as
-- a missing-number card), facts_mastered_864 means all 864 times-table cards,
-- and the four new badges. Badges already held are never removed.

CREATE OR REPLACE FUNCTION award_fact_badges_for(p_user UUID, p_perfect_round BOOLEAN DEFAULT FALSE)
RETURNS SETOF TEXT
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  WITH f AS (
    SELECT c.topic, c.op, c.a, c.b, c.form, (h.fluent_at IS NOT NULL) AS fluent
    FROM math_fact_cards c
    LEFT JOIN fact_history h ON h.fact_key = c.fact_key AND h.user_id = p_user
  ),
  earned(key) AS (
    SELECT 'facts_mastered_' || t FROM unnest(ARRAY[10, 50, 100, 250, 500]) AS t
     WHERE (SELECT COUNT(*) FROM f WHERE fluent) >= t
    UNION ALL
    SELECT 'facts_mastered_864'
     WHERE NOT EXISTS (SELECT 1 FROM f WHERE topic = 'times' AND NOT fluent)
    UNION ALL
    SELECT 'facts_table_' || n FROM generate_series(1, 12) AS n
     WHERE NOT EXISTS (SELECT 1 FROM f WHERE topic = 'times' AND op = 'mul' AND (a = n OR b = n) AND NOT fluent)
    UNION ALL
    SELECT 'facts_all_' || o FROM unnest(ARRAY['mul', 'div']) AS o
     WHERE NOT EXISTS (SELECT 1 FROM f WHERE topic = 'times' AND op = o AND NOT fluent)
    UNION ALL
    SELECT 'facts_missing_' || t FROM unnest(ARRAY[25, 100]) AS t
     WHERE (SELECT COUNT(*) FROM f WHERE topic = 'times' AND fluent AND form <> 'c') >= t
    UNION ALL
    SELECT 'facts_' || tp || '_25' FROM unnest(ARRAY['equiv', 'fdp']) AS tp
     WHERE (SELECT COUNT(*) FROM f WHERE topic = tp AND fluent) >= 25
    UNION ALL
    SELECT 'facts_' || tp || '_all' FROM unnest(ARRAY['equiv', 'fdp']) AS tp
     WHERE NOT EXISTS (SELECT 1 FROM f WHERE topic = tp AND NOT fluent)
    UNION ALL
    SELECT 'facts_perfect_round' WHERE p_perfect_round
  )
  INSERT INTO user_achievements (user_id, achievement_key)
  SELECT p_user, e.key
    FROM earned e
    JOIN achievement_definitions d ON d.key = e.key
   WHERE EXISTS (SELECT 1 FROM profiles p WHERE p.id = p_user)
  ON CONFLICT (user_id, achievement_key) DO NOTHING
  RETURNING achievement_key;
$$;

REVOKE ALL ON FUNCTION award_fact_badges_for(UUID, BOOLEAN) FROM PUBLIC, anon, authenticated;


-- ── Verification ─────────────────────────────────────────────────────────────
--
-- Expected: times 864, equiv 304, fdp 90, max_points __MAXPTS__,
--           orphan_history 0 (every saved answer still has its card),
--           math_badges __BADGES__, helper_callable_by_students false.

SELECT
  (SELECT COUNT(*) FROM math_fact_cards WHERE topic = 'times')            AS times,
  (SELECT COUNT(*) FROM math_fact_cards WHERE topic = 'equiv')            AS equiv,
  (SELECT COUNT(*) FROM math_fact_cards WHERE topic = 'fdp')              AS fdp,
  (SELECT SUM(points) FROM math_fact_cards)                               AS max_points,
  (SELECT COUNT(*) FROM fact_history h
    WHERE NOT EXISTS (SELECT 1 FROM math_cards c WHERE c.fact_key = h.fact_key)) AS orphan_history,
  (SELECT COUNT(*) FROM achievement_definitions WHERE category = 'Math Facts') AS math_badges,
  has_function_privilege('authenticated', 'award_fact_badges_for(uuid, boolean)', 'EXECUTE')
                                                                           AS helper_callable_by_students;
