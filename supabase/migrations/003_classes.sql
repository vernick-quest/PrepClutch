-- Add avatar_url and is_admin to profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_admin BOOLEAN NOT NULL DEFAULT FALSE;

-- Mark admin user
UPDATE profiles
SET is_admin = TRUE
WHERE id IN (SELECT id FROM auth.users WHERE email = 'vernick@gmail.com');

-- Classes table: 5-digit unique codes
CREATE TABLE IF NOT EXISTS classes (
  code CHAR(5) PRIMARY KEY,
  created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE classes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Classes publicly readable"
  ON classes FOR SELECT USING (TRUE);

CREATE POLICY "Authenticated users can create classes"
  ON classes FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Auto-generate unique 5-digit code
CREATE OR REPLACE FUNCTION generate_class_code()
RETURNS CHAR(5)
LANGUAGE plpgsql
AS $$
DECLARE
  new_code CHAR(5);
  taken BOOLEAN;
BEGIN
  LOOP
    new_code := LPAD((FLOOR(RANDOM() * 90000) + 10000)::INT::TEXT, 5, '0');
    SELECT EXISTS(SELECT 1 FROM classes WHERE code = new_code) INTO taken;
    EXIT WHEN NOT taken;
  END LOOP;
  RETURN new_code;
END;
$$;

-- Update RLS so admins can read all quiz attempts and achievements
DROP POLICY IF EXISTS "Users can view own attempts" ON quiz_attempts;
CREATE POLICY "Users can view own attempts"
  ON quiz_attempts FOR SELECT
  USING (
    auth.uid() = user_id
    OR (SELECT is_admin FROM profiles WHERE id = auth.uid())
  );

DROP POLICY IF EXISTS "Users can view own achievements" ON user_achievements;
CREATE POLICY "Users can view own achievements"
  ON user_achievements FOR SELECT
  USING (
    auth.uid() = user_id
    OR (SELECT is_admin FROM profiles WHERE id = auth.uid())
  );
