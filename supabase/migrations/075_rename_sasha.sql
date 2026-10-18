-- 075 - Rename Sasha Gromyko to Sasha
--
-- Robert, 2026-10-17. One profile, matched by id AND its current name, so a
-- re-run (or a name already changed) updates nothing. Sign-in never rewrites
-- display_name (only onboarding sets it), so the change sticks.

UPDATE profiles
   SET display_name = 'Sasha'
 WHERE id = '2391fcf4-29d5-4df6-8f3b-1c31d3ff98d5'
   AND display_name = 'Sasha Gromyko';

-- Expected: one row, Sasha.
SELECT id, display_name FROM profiles WHERE id = '2391fcf4-29d5-4df6-8f3b-1c31d3ff98d5';
