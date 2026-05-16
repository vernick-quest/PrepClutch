-- Add name to classes table
ALTER TABLE classes ADD COLUMN IF NOT EXISTS name TEXT NOT NULL DEFAULT '';

-- Allow admins to update class names
DROP POLICY IF EXISTS "Admins can update classes" ON classes;
CREATE POLICY "Admins can update classes"
  ON classes FOR UPDATE
  USING ((SELECT is_admin FROM profiles WHERE id = auth.uid()));

-- Allow admins to update any profile (for changing class codes)
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
CREATE POLICY "Users can update own profile or admin can update any"
  ON profiles FOR UPDATE
  USING (
    auth.uid() = id
    OR (SELECT is_admin FROM profiles WHERE id = auth.uid())
  );
