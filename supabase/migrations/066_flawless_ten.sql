-- 066 — Math Facts rounds are now 10 cards: rename Flawless Twenty
--
-- A round dropped from 20 cards to 10, so the perfect-round badge now means a
-- perfect 10-card round. Same key (facts_perfect_round), so anyone who has
-- already earned it keeps it. Re-runnable.

UPDATE achievement_definitions SET
  label       = 'Flawless Ten',
  description = 'A 10-card round with every card right, and every one fast enough to master.',
  lore        = 'Ten cards. Ten right answers. Not one of them slow. It is not luck if it happens ten times in a row.',
  threshold   = 10
WHERE key = 'facts_perfect_round';

-- Expected: Flawless Ten, 10
SELECT label, threshold FROM achievement_definitions WHERE key = 'facts_perfect_round';
