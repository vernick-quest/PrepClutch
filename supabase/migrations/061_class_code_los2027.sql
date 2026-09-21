-- 061 — Rename class 36602 to LOS2027, and move students into it
--
-- classes.code was CHAR(5), sized for the auto-generated 5-digit codes. A
-- named code needs room, so it widens to TEXT first. Nothing references
-- classes.code by foreign key and no view reads it, so the type change is safe.
-- CHAR to TEXT drops trailing pad spaces, and every existing code is exactly 5
-- digits, so no stored code changes.
--
-- Then the class row and its students move together. profiles.class_code is
-- plain text with no foreign key, so the two UPDATEs are what keep the class
-- and its 15 students joined. Points, history and badges are keyed on user id,
-- not class, so nobody's score moves.
--
-- Guarded: it refuses to run unless 36602 exists and LOS2027 is free, and a
-- second run after success is a harmless no-op.

ALTER TABLE classes ALTER COLUMN code TYPE TEXT;

DO $$
DECLARE
  old_exists BOOLEAN;
  new_exists BOOLEAN;
BEGIN
  SELECT EXISTS (SELECT 1 FROM classes WHERE code = '36602') INTO old_exists;
  SELECT EXISTS (SELECT 1 FROM classes WHERE code = 'LOS2027') INTO new_exists;

  IF NOT old_exists AND new_exists THEN
    RAISE NOTICE '061 already applied, nothing to do';
    RETURN;
  END IF;
  IF NOT old_exists THEN
    RAISE EXCEPTION '061 stopped: class 36602 not found';
  END IF;
  IF new_exists THEN
    RAISE EXCEPTION '061 stopped: LOS2027 is already taken';
  END IF;

  UPDATE classes  SET code       = 'LOS2027' WHERE code       = '36602';
  UPDATE profiles SET class_code = 'LOS2027' WHERE class_code = '36602';
END $$;

-- ── Student moves ────────────────────────────────────────────────────────────
--
-- Matched by account id, never by name: there are two Heike accounts in TEST
-- and only the one with 1,785 points moves. Each move also requires the
-- student to be in their expected old class (or already moved), so this cannot
-- sweep up someone whose class changed since these ids were looked up.
--
--   Heike     TEST    -> LOS2027   (the 1,785-point account)
--   Jamieson  DRAFT0  -> LOS2027
--   Kaylin    3662    -> LOS2027
--   Rik          36602 -> no class  \
--   MasterClass  36602 -> no class   > removed from the class only, accounts kept
--   Robert       36602 -> no class  /  (admin; still the class's creator)
--
-- Clutch Points, history and badges are keyed on the account, so every
-- student keeps every point.

DO $$
DECLARE
  n INT;
BEGIN
  UPDATE profiles SET class_code = 'LOS2027'
   WHERE id = '2b30bfb3-5e85-4181-ade1-9d2ca76ec95b' AND class_code IN ('TEST', 'LOS2027');
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 1 THEN RAISE EXCEPTION '061 stopped: Heike (1,785 pts) not found in TEST'; END IF;

  UPDATE profiles SET class_code = 'LOS2027'
   WHERE id = 'e4ce57e9-94e1-4a8a-808d-67e7fd8b8bea' AND class_code IN ('DRAFT0', 'LOS2027');
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 1 THEN RAISE EXCEPTION '061 stopped: Jamieson not found in DRAFT0'; END IF;

  UPDATE profiles SET class_code = 'LOS2027'
   WHERE id = '12fa7dc9-2125-4c78-beff-b9a10eac25cf' AND class_code IN ('3662', 'LOS2027');
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 1 THEN RAISE EXCEPTION '061 stopped: Kaylin not found in 3662'; END IF;

  UPDATE profiles SET class_code = ''
   WHERE id = '649bc177-087b-46ed-83f9-050de34ab845' AND class_code IN ('36602', 'LOS2027', '');
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 1 THEN RAISE EXCEPTION '061 stopped: Rik not found in the class'; END IF;

  UPDATE profiles SET class_code = ''
   WHERE id = '4e52247e-2b70-4eb3-8c30-fd614db886c3' AND class_code IN ('36602', 'LOS2027', '');
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 1 THEN RAISE EXCEPTION '061 stopped: MasterClass not found in the class'; END IF;

  UPDATE profiles SET class_code = ''
   WHERE id = 'bdc1e910-df08-407b-8109-b5f58f10da72' AND class_code IN ('36602', 'LOS2027', '');
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 1 THEN RAISE EXCEPTION '061 stopped: Robert not found in the class'; END IF;
END $$;

-- Expected: old_class 0, new_class 1, class_name LOS 2027,
--           students_left_on_36602 0, students_on_los2027 15,
--           heike_other_still_in_test 1, removed_now_classless 3
SELECT
  (SELECT COUNT(*) FROM classes  WHERE code = '36602')         AS old_class,
  (SELECT COUNT(*) FROM classes  WHERE code = 'LOS2027')       AS new_class,
  (SELECT name     FROM classes  WHERE code = 'LOS2027')       AS class_name,
  (SELECT COUNT(*) FROM profiles WHERE class_code = '36602')   AS students_left_on_36602,
  (SELECT COUNT(*) FROM profiles WHERE class_code = 'LOS2027') AS students_on_los2027,
  (SELECT COUNT(*) FROM profiles
    WHERE id = '5b1f15d2-e99b-4bfb-86ad-ce31ded6c745' AND class_code = 'TEST') AS heike_other_still_in_test,
  (SELECT COUNT(*) FROM profiles WHERE class_code = '' AND id IN (
    '649bc177-087b-46ed-83f9-050de34ab845',
    '4e52247e-2b70-4eb3-8c30-fd614db886c3',
    'bdc1e910-df08-407b-8109-b5f58f10da72'))                          AS removed_now_classless;
