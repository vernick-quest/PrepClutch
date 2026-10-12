-- 065 — Remember whether a student came for HSPT prep or Math Facts
--
-- New students now pick one at sign-up, and sign-in lands them there. Every
-- existing student defaults to 'hspt', which is where they land today, so
-- nothing changes for anyone until they choose.
--
-- Students can already update their own profile row (the existing update
-- policy), so no new policy is needed. Additive and re-runnable.

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS home_track TEXT NOT NULL DEFAULT 'hspt';

DO $$ BEGIN
  ALTER TABLE profiles
    ADD CONSTRAINT profiles_home_track_check CHECK (home_track IN ('hspt', 'math'));
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Expected: column_exists 1, everyone_hspt true (all existing students)
SELECT
  (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'home_track') AS column_exists,
  (SELECT COUNT(*) = COUNT(*) FILTER (WHERE home_track = 'hspt') FROM profiles) AS everyone_hspt;
