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
--
-- This inspects the catalog rather than CALLING the function. Calling it from
-- the SQL editor always fails: the editor runs as `postgres`, so auth.uid() is
-- NULL, no profile matches, and the admin check correctly raises — which then
-- rolls back the CREATE in the same script. (That is exactly what happened on
-- the first attempt at this migration.)
--
-- Expect one row: security_definer = true.

SELECT p.proname                                   AS function_name,
       p.prosecdef                                 AS security_definer,
       pg_get_function_result(p.oid)               AS returns,
       (SELECT COUNT(*) FROM auth.users)           AS accounts_in_project
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public'
  AND p.proname = 'get_admin_user_directory';

-- To confirm it actually works, sign in to the app as an admin and load
-- /admin — emails should appear under each display name. There is no way to
-- exercise the authenticated path from the SQL editor.
