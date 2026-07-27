-- 026 — Let admins see which email belongs to which display name
--
-- Emails live in auth.users, which the browser client cannot read. Display
-- names are not unique either — two accounts were both called "not baron",
-- and telling them apart required a hand-written SQL query.
--
-- This exposes the mapping to admins only.
--
-- SECURITY NOTE: the function is SECURITY DEFINER, so it runs with the
-- privileges of its owner and bypasses RLS. That means it MUST check the
-- caller itself — a UI-side `is_admin` check is worthless here, because any
-- authenticated user can call an RPC directly against the REST API. The
-- authorisation check below is the only thing standing between a student and
-- every user's email address, so it is done first and it raises rather than
-- returning an empty set (silent empties hide misconfiguration).
--
-- Run this as a new query in the Supabase SQL editor.

CREATE OR REPLACE FUNCTION get_admin_user_directory()
RETURNS TABLE (
  user_id      UUID,
  display_name TEXT,
  email        TEXT,
  class_code   TEXT,
  is_admin     BOOLEAN,
  joined_at    TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM profiles p
    WHERE p.id = auth.uid() AND p.is_admin IS TRUE
  ) THEN
    RAISE EXCEPTION 'get_admin_user_directory: admin privileges required';
  END IF;

  RETURN QUERY
  SELECT p.id, p.display_name, u.email::TEXT, p.class_code, p.is_admin, u.created_at
  FROM profiles p
  JOIN auth.users u ON u.id = p.id
  ORDER BY p.display_name;
END $$;

-- anon must never reach this. `authenticated` may call it, but the body above
-- rejects any caller who is not an admin.
REVOKE ALL ON FUNCTION get_admin_user_directory() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION get_admin_user_directory() TO authenticated;


-- ── Verification ─────────────────────────────────────────────────────────────
-- Run as yourself (an admin) — expect one row per profile, with emails.
-- A non-admin calling this should get:
--   ERROR: get_admin_user_directory: admin privileges required
--
--   SELECT user_id, display_name, email, class_code FROM get_admin_user_directory();

SELECT 'accounts visible to admin directory' AS check, COUNT(*)::TEXT AS value
FROM get_admin_user_directory()
UNION ALL
SELECT 'duplicate display names',
       COALESCE(string_agg(display_name || ' ×' || n, ', '), 'none')
FROM (
  SELECT display_name, COUNT(*) AS n
  FROM get_admin_user_directory()
  GROUP BY display_name HAVING COUNT(*) > 1
) d;
