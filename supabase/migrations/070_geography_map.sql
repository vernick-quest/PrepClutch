-- 070 — Geography map: Name that country cards, Pin the map
--
-- Phase 2 of Geography (069 is phase 1 and must be applied first). Additive:
-- nothing here changes or removes an existing card, history row or award.
--
--   geo_cards                 + 193 "Name that country" cards, kind
--                             'shape', one per UN member, 15 Explorer
--                             Points each, mastered within 8 s. Inserted
--                             only: the 069 cards are not touched.
--   badges                    + Shape Spotter (25 shapes) and Map Master (all 193)
--   award_geo_badges_for      069's function copied exactly, with the shapes
--                             rung added to its two card-type lists. Still
--                             revoked from students.
--   badge descriptions        World Turtle and the six continent badges count
--                             every card, so they now include shape cards:
--                             their descriptions and thresholds are updated
--                             to the new totals. Nobody loses a badge.
--   geo_pin_places            the 193 capitals Pin the map can ask, with
--                             their coordinates and level (read-only)
--   geo_pin_rounds            one row per Pin the map round. Written ONLY by
--                             record_geo_pin_round, which scores the taps
--                             itself from geo_pin_places
--   geo_pin_leaderboard_view  best score per student per continent and level
--
-- Pin the map never touches geo_history or Explorer Points.
-- Admins (profiles.is_admin) can read every student's pin rounds. Students
-- read only their own.
--
-- Re-running is harmless: catalogues and badge definitions upsert, the award
-- function is replaced with the same text, nothing is deleted.
-- Generated: do not edit by hand. Change lib/geo.ts, lib/geo-pin.ts or
-- supabase/geography/NNN.template.sql, then run
--   node supabase/geography/map-cards.mts [--number 070]
-- The generator refuses to write if any string literal contains a semicolon,
-- a dollar sign or a double dash (the Supabase editor misparses those).


-- ── 1. Name that country: the shape cards ────────────────────────────────────

INSERT INTO geo_cards (card_key, iso, kind, continent, points, target_ms) VALUES
('shape:dz', 'DZ', 'shape', 'af', 15, 8000),
('shape:ao', 'AO', 'shape', 'af', 15, 8000),
('shape:bj', 'BJ', 'shape', 'af', 15, 8000),
('shape:bw', 'BW', 'shape', 'af', 15, 8000),
('shape:bf', 'BF', 'shape', 'af', 15, 8000),
('shape:bi', 'BI', 'shape', 'af', 15, 8000),
('shape:cv', 'CV', 'shape', 'af', 15, 8000),
('shape:cm', 'CM', 'shape', 'af', 15, 8000),
('shape:cf', 'CF', 'shape', 'af', 15, 8000),
('shape:td', 'TD', 'shape', 'af', 15, 8000),
('shape:km', 'KM', 'shape', 'af', 15, 8000),
('shape:cg', 'CG', 'shape', 'af', 15, 8000),
('shape:cd', 'CD', 'shape', 'af', 15, 8000),
('shape:ci', 'CI', 'shape', 'af', 15, 8000),
('shape:dj', 'DJ', 'shape', 'af', 15, 8000),
('shape:eg', 'EG', 'shape', 'af', 15, 8000),
('shape:gq', 'GQ', 'shape', 'af', 15, 8000),
('shape:er', 'ER', 'shape', 'af', 15, 8000),
('shape:sz', 'SZ', 'shape', 'af', 15, 8000),
('shape:et', 'ET', 'shape', 'af', 15, 8000),
('shape:ga', 'GA', 'shape', 'af', 15, 8000),
('shape:gm', 'GM', 'shape', 'af', 15, 8000),
('shape:gh', 'GH', 'shape', 'af', 15, 8000),
('shape:gn', 'GN', 'shape', 'af', 15, 8000),
('shape:gw', 'GW', 'shape', 'af', 15, 8000),
('shape:ke', 'KE', 'shape', 'af', 15, 8000),
('shape:ls', 'LS', 'shape', 'af', 15, 8000),
('shape:lr', 'LR', 'shape', 'af', 15, 8000),
('shape:ly', 'LY', 'shape', 'af', 15, 8000),
('shape:mg', 'MG', 'shape', 'af', 15, 8000),
('shape:mw', 'MW', 'shape', 'af', 15, 8000),
('shape:ml', 'ML', 'shape', 'af', 15, 8000),
('shape:mr', 'MR', 'shape', 'af', 15, 8000),
('shape:mu', 'MU', 'shape', 'af', 15, 8000),
('shape:ma', 'MA', 'shape', 'af', 15, 8000),
('shape:mz', 'MZ', 'shape', 'af', 15, 8000),
('shape:na', 'NA', 'shape', 'af', 15, 8000),
('shape:ne', 'NE', 'shape', 'af', 15, 8000),
('shape:ng', 'NG', 'shape', 'af', 15, 8000),
('shape:rw', 'RW', 'shape', 'af', 15, 8000),
('shape:st', 'ST', 'shape', 'af', 15, 8000),
('shape:sn', 'SN', 'shape', 'af', 15, 8000),
('shape:sc', 'SC', 'shape', 'af', 15, 8000),
('shape:sl', 'SL', 'shape', 'af', 15, 8000),
('shape:so', 'SO', 'shape', 'af', 15, 8000),
('shape:za', 'ZA', 'shape', 'af', 15, 8000),
('shape:ss', 'SS', 'shape', 'af', 15, 8000),
('shape:sd', 'SD', 'shape', 'af', 15, 8000),
('shape:tz', 'TZ', 'shape', 'af', 15, 8000),
('shape:tg', 'TG', 'shape', 'af', 15, 8000),
('shape:tn', 'TN', 'shape', 'af', 15, 8000),
('shape:ug', 'UG', 'shape', 'af', 15, 8000),
('shape:zm', 'ZM', 'shape', 'af', 15, 8000),
('shape:zw', 'ZW', 'shape', 'af', 15, 8000),
('shape:af', 'AF', 'shape', 'as', 15, 8000),
('shape:am', 'AM', 'shape', 'as', 15, 8000),
('shape:az', 'AZ', 'shape', 'as', 15, 8000),
('shape:bh', 'BH', 'shape', 'as', 15, 8000),
('shape:bd', 'BD', 'shape', 'as', 15, 8000),
('shape:bt', 'BT', 'shape', 'as', 15, 8000),
('shape:bn', 'BN', 'shape', 'as', 15, 8000),
('shape:kh', 'KH', 'shape', 'as', 15, 8000),
('shape:cn', 'CN', 'shape', 'as', 15, 8000),
('shape:cy', 'CY', 'shape', 'as', 15, 8000),
('shape:ge', 'GE', 'shape', 'as', 15, 8000),
('shape:in', 'IN', 'shape', 'as', 15, 8000),
('shape:id', 'ID', 'shape', 'as', 15, 8000),
('shape:ir', 'IR', 'shape', 'as', 15, 8000),
('shape:iq', 'IQ', 'shape', 'as', 15, 8000),
('shape:il', 'IL', 'shape', 'as', 15, 8000),
('shape:jp', 'JP', 'shape', 'as', 15, 8000),
('shape:jo', 'JO', 'shape', 'as', 15, 8000),
('shape:kz', 'KZ', 'shape', 'as', 15, 8000),
('shape:kw', 'KW', 'shape', 'as', 15, 8000),
('shape:kg', 'KG', 'shape', 'as', 15, 8000),
('shape:la', 'LA', 'shape', 'as', 15, 8000),
('shape:lb', 'LB', 'shape', 'as', 15, 8000),
('shape:my', 'MY', 'shape', 'as', 15, 8000),
('shape:mv', 'MV', 'shape', 'as', 15, 8000),
('shape:mn', 'MN', 'shape', 'as', 15, 8000),
('shape:mm', 'MM', 'shape', 'as', 15, 8000),
('shape:np', 'NP', 'shape', 'as', 15, 8000),
('shape:kp', 'KP', 'shape', 'as', 15, 8000),
('shape:om', 'OM', 'shape', 'as', 15, 8000),
('shape:pk', 'PK', 'shape', 'as', 15, 8000),
('shape:ph', 'PH', 'shape', 'as', 15, 8000),
('shape:qa', 'QA', 'shape', 'as', 15, 8000),
('shape:sa', 'SA', 'shape', 'as', 15, 8000),
('shape:sg', 'SG', 'shape', 'as', 15, 8000),
('shape:kr', 'KR', 'shape', 'as', 15, 8000),
('shape:lk', 'LK', 'shape', 'as', 15, 8000),
('shape:sy', 'SY', 'shape', 'as', 15, 8000),
('shape:tj', 'TJ', 'shape', 'as', 15, 8000),
('shape:th', 'TH', 'shape', 'as', 15, 8000),
('shape:tl', 'TL', 'shape', 'as', 15, 8000),
('shape:tr', 'TR', 'shape', 'as', 15, 8000),
('shape:tm', 'TM', 'shape', 'as', 15, 8000),
('shape:ae', 'AE', 'shape', 'as', 15, 8000),
('shape:uz', 'UZ', 'shape', 'as', 15, 8000),
('shape:vn', 'VN', 'shape', 'as', 15, 8000),
('shape:ye', 'YE', 'shape', 'as', 15, 8000),
('shape:al', 'AL', 'shape', 'eu', 15, 8000),
('shape:ad', 'AD', 'shape', 'eu', 15, 8000),
('shape:at', 'AT', 'shape', 'eu', 15, 8000),
('shape:by', 'BY', 'shape', 'eu', 15, 8000),
('shape:be', 'BE', 'shape', 'eu', 15, 8000),
('shape:ba', 'BA', 'shape', 'eu', 15, 8000),
('shape:bg', 'BG', 'shape', 'eu', 15, 8000),
('shape:hr', 'HR', 'shape', 'eu', 15, 8000),
('shape:cz', 'CZ', 'shape', 'eu', 15, 8000),
('shape:dk', 'DK', 'shape', 'eu', 15, 8000),
('shape:ee', 'EE', 'shape', 'eu', 15, 8000),
('shape:fi', 'FI', 'shape', 'eu', 15, 8000),
('shape:fr', 'FR', 'shape', 'eu', 15, 8000),
('shape:de', 'DE', 'shape', 'eu', 15, 8000),
('shape:gr', 'GR', 'shape', 'eu', 15, 8000),
('shape:hu', 'HU', 'shape', 'eu', 15, 8000),
('shape:is', 'IS', 'shape', 'eu', 15, 8000),
('shape:ie', 'IE', 'shape', 'eu', 15, 8000),
('shape:it', 'IT', 'shape', 'eu', 15, 8000),
('shape:lv', 'LV', 'shape', 'eu', 15, 8000),
('shape:li', 'LI', 'shape', 'eu', 15, 8000),
('shape:lt', 'LT', 'shape', 'eu', 15, 8000),
('shape:lu', 'LU', 'shape', 'eu', 15, 8000),
('shape:mt', 'MT', 'shape', 'eu', 15, 8000),
('shape:md', 'MD', 'shape', 'eu', 15, 8000),
('shape:mc', 'MC', 'shape', 'eu', 15, 8000),
('shape:me', 'ME', 'shape', 'eu', 15, 8000),
('shape:nl', 'NL', 'shape', 'eu', 15, 8000),
('shape:mk', 'MK', 'shape', 'eu', 15, 8000),
('shape:no', 'NO', 'shape', 'eu', 15, 8000),
('shape:pl', 'PL', 'shape', 'eu', 15, 8000),
('shape:pt', 'PT', 'shape', 'eu', 15, 8000),
('shape:ro', 'RO', 'shape', 'eu', 15, 8000),
('shape:ru', 'RU', 'shape', 'eu', 15, 8000),
('shape:sm', 'SM', 'shape', 'eu', 15, 8000),
('shape:rs', 'RS', 'shape', 'eu', 15, 8000),
('shape:sk', 'SK', 'shape', 'eu', 15, 8000),
('shape:si', 'SI', 'shape', 'eu', 15, 8000),
('shape:es', 'ES', 'shape', 'eu', 15, 8000),
('shape:se', 'SE', 'shape', 'eu', 15, 8000),
('shape:ch', 'CH', 'shape', 'eu', 15, 8000),
('shape:ua', 'UA', 'shape', 'eu', 15, 8000),
('shape:gb', 'GB', 'shape', 'eu', 15, 8000),
('shape:ag', 'AG', 'shape', 'na', 15, 8000),
('shape:bs', 'BS', 'shape', 'na', 15, 8000),
('shape:bb', 'BB', 'shape', 'na', 15, 8000),
('shape:bz', 'BZ', 'shape', 'na', 15, 8000),
('shape:ca', 'CA', 'shape', 'na', 15, 8000),
('shape:cr', 'CR', 'shape', 'na', 15, 8000),
('shape:cu', 'CU', 'shape', 'na', 15, 8000),
('shape:dm', 'DM', 'shape', 'na', 15, 8000),
('shape:do', 'DO', 'shape', 'na', 15, 8000),
('shape:sv', 'SV', 'shape', 'na', 15, 8000),
('shape:gd', 'GD', 'shape', 'na', 15, 8000),
('shape:gt', 'GT', 'shape', 'na', 15, 8000),
('shape:ht', 'HT', 'shape', 'na', 15, 8000),
('shape:hn', 'HN', 'shape', 'na', 15, 8000),
('shape:jm', 'JM', 'shape', 'na', 15, 8000),
('shape:mx', 'MX', 'shape', 'na', 15, 8000),
('shape:ni', 'NI', 'shape', 'na', 15, 8000),
('shape:pa', 'PA', 'shape', 'na', 15, 8000),
('shape:kn', 'KN', 'shape', 'na', 15, 8000),
('shape:lc', 'LC', 'shape', 'na', 15, 8000),
('shape:vc', 'VC', 'shape', 'na', 15, 8000),
('shape:tt', 'TT', 'shape', 'na', 15, 8000),
('shape:us', 'US', 'shape', 'na', 15, 8000),
('shape:ar', 'AR', 'shape', 'sa', 15, 8000),
('shape:bo', 'BO', 'shape', 'sa', 15, 8000),
('shape:br', 'BR', 'shape', 'sa', 15, 8000),
('shape:cl', 'CL', 'shape', 'sa', 15, 8000),
('shape:co', 'CO', 'shape', 'sa', 15, 8000),
('shape:ec', 'EC', 'shape', 'sa', 15, 8000),
('shape:gy', 'GY', 'shape', 'sa', 15, 8000),
('shape:py', 'PY', 'shape', 'sa', 15, 8000),
('shape:pe', 'PE', 'shape', 'sa', 15, 8000),
('shape:sr', 'SR', 'shape', 'sa', 15, 8000),
('shape:uy', 'UY', 'shape', 'sa', 15, 8000),
('shape:ve', 'VE', 'shape', 'sa', 15, 8000),
('shape:au', 'AU', 'shape', 'oc', 15, 8000),
('shape:fj', 'FJ', 'shape', 'oc', 15, 8000),
('shape:ki', 'KI', 'shape', 'oc', 15, 8000),
('shape:mh', 'MH', 'shape', 'oc', 15, 8000),
('shape:fm', 'FM', 'shape', 'oc', 15, 8000),
('shape:nr', 'NR', 'shape', 'oc', 15, 8000),
('shape:nz', 'NZ', 'shape', 'oc', 15, 8000),
('shape:pw', 'PW', 'shape', 'oc', 15, 8000),
('shape:pg', 'PG', 'shape', 'oc', 15, 8000),
('shape:ws', 'WS', 'shape', 'oc', 15, 8000),
('shape:sb', 'SB', 'shape', 'oc', 15, 8000),
('shape:to', 'TO', 'shape', 'oc', 15, 8000),
('shape:tv', 'TV', 'shape', 'oc', 15, 8000),
('shape:vu', 'VU', 'shape', 'oc', 15, 8000)
ON CONFLICT (card_key) DO UPDATE SET
  iso = EXCLUDED.iso, kind = EXCLUDED.kind, continent = EXCLUDED.continent,
  points = EXCLUDED.points, target_ms = EXCLUDED.target_ms
  WHERE geo_cards.kind = 'shape';


-- ── 2. Badge definitions ─────────────────────────────────────────────────────

INSERT INTO achievement_definitions (key, label, icon_emoji, description, rarity, creature, category, lore, threshold) VALUES

('geo_shapes_25', 'Shape Spotter', '🧩', '25 Name that country cards mastered.', 'Uncommon', 'Shape Spotter', 'Geography',
 'Twenty-five countries named from their outline alone. The Spotter sees a boot and says Italy, sees a long thin ribbon and says Chile, and is now looking suspiciously at clouds.', 25),

('geo_shapes_all', 'Map Master', '🗺️👑', 'All 193 Name that country cards mastered.', 'Legendary', 'Map Master', 'Geography',
 'Every country on Earth, named from its shape on the map, from Russia down to Tuvalu. The Map Master could draw the world from memory and would only argue a little about the borders.', 193)

ON CONFLICT (key) DO UPDATE SET
  label = EXCLUDED.label, icon_emoji = EXCLUDED.icon_emoji,
  description = EXCLUDED.description, rarity = EXCLUDED.rarity,
  creature = EXCLUDED.creature, category = EXCLUDED.category,
  lore = EXCLUDED.lore, threshold = EXCLUDED.threshold;

-- Every-card badges now count the shape cards too.
UPDATE achievement_definitions SET description = 'Every one of the 1158 Geography cards mastered.', threshold = 1158 WHERE key = 'geo_mastered_all';
UPDATE achievement_definitions SET description = 'All 324 Africa cards mastered.', threshold = 324 WHERE key = 'geo_continent_af';
UPDATE achievement_definitions SET description = 'All 282 Asia cards mastered.', threshold = 282 WHERE key = 'geo_continent_as';
UPDATE achievement_definitions SET description = 'All 258 Europe cards mastered.', threshold = 258 WHERE key = 'geo_continent_eu';
UPDATE achievement_definitions SET description = 'All 138 North America cards mastered.', threshold = 138 WHERE key = 'geo_continent_na';
UPDATE achievement_definitions SET description = 'All 72 South America cards mastered.', threshold = 72 WHERE key = 'geo_continent_sa';
UPDATE achievement_definitions SET description = 'All 84 Oceania cards mastered.', threshold = 84 WHERE key = 'geo_continent_oc';


-- ── 3. Awarding: 069's function, plus the shapes rungs ───────────────────────

CREATE OR REPLACE FUNCTION award_geo_badges_for(p_user UUID, p_perfect_round BOOLEAN DEFAULT FALSE)
RETURNS SETOF TEXT
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  WITH g AS (
    SELECT c.kind, c.continent, (h.fluent_at IS NOT NULL) AS fluent
    FROM geo_cards c
    LEFT JOIN geo_history h ON h.card_key = c.card_key AND h.user_id = p_user
  ),
  earned(key) AS (
    SELECT 'geo_mastered_' || t FROM unnest(ARRAY[10, 50, 100, 250, 500]) AS t
     WHERE (SELECT COUNT(*) FROM g WHERE fluent) >= t
    UNION ALL
    SELECT 'geo_mastered_all'
     WHERE NOT EXISTS (SELECT 1 FROM g WHERE NOT fluent)
    UNION ALL
    SELECT 'geo_continent_' || ct FROM unnest(ARRAY['af', 'as', 'eu', 'na', 'sa', 'oc']) AS ct
     WHERE NOT EXISTS (SELECT 1 FROM g WHERE continent = ct AND NOT fluent)
    UNION ALL
    SELECT 'geo_' || r.grp || '_' || r.t
      FROM (VALUES ('capitals', ARRAY['cap', 'capr'], 25), ('flags', ARRAY['flag', 'flagr'], 25), ('money', ARRAY['cur'], 25), ('languages', ARRAY['lang'], 25), ('continents', ARRAY['cont'], 25), ('shapes', ARRAY['shape'], 25)) AS r(grp, kinds, t)
     WHERE (SELECT COUNT(*) FROM g WHERE kind = ANY (r.kinds) AND fluent) >= r.t
    UNION ALL
    SELECT 'geo_' || r.grp || '_all'
      FROM (VALUES ('capitals', ARRAY['cap', 'capr']), ('flags', ARRAY['flag', 'flagr']), ('money', ARRAY['cur']), ('languages', ARRAY['lang']), ('continents', ARRAY['cont']), ('shapes', ARRAY['shape'])) AS r(grp, kinds)
     WHERE NOT EXISTS (SELECT 1 FROM g WHERE kind = ANY (r.kinds) AND NOT fluent)
    UNION ALL
    SELECT 'geo_perfect_round' WHERE p_perfect_round
  )
  INSERT INTO user_achievements (user_id, achievement_key)
  SELECT p_user, e.key
    FROM earned e
    JOIN achievement_definitions d ON d.key = e.key
   WHERE EXISTS (SELECT 1 FROM profiles p WHERE p.id = p_user)
  ON CONFLICT (user_id, achievement_key) DO NOTHING
  RETURNING achievement_key;
$$;

REVOKE ALL ON FUNCTION award_geo_badges_for(UUID, BOOLEAN) FROM PUBLIC, anon, authenticated;


-- ── 4. Pin the map: the places ───────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS geo_pin_places (
  iso       TEXT PRIMARY KEY,
  continent TEXT NOT NULL,
  tier      INT  NOT NULL,
  lat       DOUBLE PRECISION NOT NULL,
  lon       DOUBLE PRECISION NOT NULL
);

ALTER TABLE geo_pin_places ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "geo_pin_places_readable" ON geo_pin_places;
CREATE POLICY "geo_pin_places_readable" ON geo_pin_places FOR SELECT USING (TRUE);
REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON geo_pin_places FROM anon, authenticated;
GRANT SELECT ON geo_pin_places TO anon, authenticated;

INSERT INTO geo_pin_places (iso, continent, tier, lat, lon) VALUES
('DZ', 'af', 1, 36.78, 3.06),
('AO', 'af', 1, -8.84, 13.23),
('BJ', 'af', 2, 6.48, 2.62),
('BW', 'af', 3, -24.66, 25.91),
('BF', 'af', 2, 12.37, -1.53),
('BI', 'af', 2, -3.43, 29.93),
('CV', 'af', 3, 14.92, -23.51),
('CM', 'af', 1, 3.86, 11.52),
('CF', 'af', 3, 4.37, 18.56),
('TD', 'af', 2, 12.11, 15.05),
('KM', 'af', 3, -11.7, 43.25),
('CG', 'af', 3, -4.27, 15.27),
('CD', 'af', 1, -4.32, 15.31),
('CI', 'af', 1, 6.82, -5.27),
('DJ', 'af', 3, 11.6, 43.15),
('EG', 'af', 1, 30.04, 31.24),
('GQ', 'af', 3, 1.59, 10.82),
('ER', 'af', 2, 15.33, 38.92),
('SZ', 'af', 3, -26.32, 31.13),
('ET', 'af', 1, 9.04, 38.75),
('GA', 'af', 3, 0.41, 9.44),
('GM', 'af', 3, 13.45, -16.58),
('GH', 'af', 1, 5.56, -0.2),
('GN', 'af', 2, 9.51, -13.71),
('GW', 'af', 3, 11.86, -15.58),
('KE', 'af', 1, -1.29, 36.82),
('LS', 'af', 3, -29.31, 27.48),
('LR', 'af', 3, 6.31, -10.8),
('LY', 'af', 2, 32.89, 13.19),
('MG', 'af', 1, -18.91, 47.53),
('MW', 'af', 2, -13.99, 33.77),
('ML', 'af', 2, 12.65, -7.99),
('MR', 'af', 3, 18.09, -15.98),
('MU', 'af', 3, -20.16, 57.5),
('MA', 'af', 1, 34.02, -6.84),
('MZ', 'af', 1, -25.97, 32.57),
('NA', 'af', 3, -22.57, 17.08),
('NE', 'af', 1, 13.52, 2.12),
('NG', 'af', 1, 9.06, 7.49),
('RW', 'af', 2, -1.95, 30.12),
('ST', 'af', 3, 0.34, 6.73),
('SN', 'af', 2, 14.67, -17.43),
('SC', 'af', 3, -4.62, 55.45),
('SL', 'af', 2, 8.49, -13.24),
('SO', 'af', 2, 2.04, 45.34),
('ZA', 'af', 1, -25.75, 28.19),
('SS', 'af', 2, 4.85, 31.58),
('SD', 'af', 1, 15.6, 32.53),
('TZ', 'af', 1, -6.18, 35.75),
('TG', 'af', 2, 6.13, 1.22),
('TN', 'af', 2, 36.8, 10.18),
('UG', 'af', 1, 0.31, 32.58),
('ZM', 'af', 2, -15.42, 28.28),
('ZW', 'af', 2, -17.83, 31.05),
('AF', 'as', 1, 34.53, 69.17),
('AM', 'as', 3, 40.18, 44.51),
('AZ', 'as', 2, 40.37, 49.84),
('BH', 'as', 3, 26.22, 50.58),
('BD', 'as', 1, 23.73, 90.39),
('BT', 'as', 3, 27.47, 89.63),
('BN', 'as', 3, 4.92, 114.92),
('KH', 'as', 2, 11.57, 104.92),
('CN', 'as', 1, 39.9, 116.41),
('CY', 'as', 3, 35.17, 33.37),
('GE', 'as', 3, 41.72, 44.79),
('IN', 'as', 1, 28.61, 77.21),
('ID', 'as', 1, -6.18, 106.83),
('IR', 'as', 1, 35.69, 51.39),
('IQ', 'as', 1, 33.32, 44.37),
('IL', 'as', 2, 31.78, 35.23),
('JP', 'as', 1, 35.69, 139.69),
('JO', 'as', 2, 31.93, 35.93),
('KZ', 'as', 2, 51.13, 71.43),
('KW', 'as', 3, 29.38, 47.98),
('KG', 'as', 3, 42.87, 74.57),
('LA', 'as', 2, 17.98, 102.63),
('LB', 'as', 2, 33.89, 35.51),
('MY', 'as', 2, 3.15, 101.7),
('MV', 'as', 3, 4.18, 73.51),
('MN', 'as', 3, 47.92, 106.91),
('MM', 'as', 1, 19.75, 96.12),
('NP', 'as', 2, 27.71, 85.32),
('KP', 'as', 2, 39.02, 125.75),
('OM', 'as', 3, 23.61, 58.59),
('PK', 'as', 1, 33.7, 73.04),
('PH', 'as', 1, 14.6, 120.98),
('QA', 'as', 3, 25.29, 51.53),
('SA', 'as', 1, 24.65, 46.71),
('SG', 'as', 3, 1.3, 103.8),
('KR', 'as', 1, 37.56, 126.99),
('LK', 'as', 2, 6.93, 79.86),
('SY', 'as', 2, 33.51, 36.29),
('TJ', 'as', 2, 38.57, 68.79),
('TH', 'as', 1, 13.75, 100.52),
('TL', 'as', 3, -8.55, 125.58),
('TR', 'as', 1, 39.94, 32.84),
('TM', 'as', 3, 37.95, 58.38),
('AE', 'as', 2, 24.45, 54.4),
('UZ', 'as', 2, 41.31, 69.28),
('VN', 'as', 1, 21.02, 105.84),
('YE', 'as', 2, 15.35, 44.2),
('AL', 'eu', 2, 41.33, 19.82),
('AD', 'eu', 3, 42.51, 1.52),
('AT', 'eu', 2, 48.21, 16.37),
('BY', 'eu', 2, 53.9, 27.56),
('BE', 'eu', 1, 50.85, 4.35),
('BA', 'eu', 2, 43.86, 18.41),
('BG', 'eu', 2, 42.7, 23.32),
('HR', 'eu', 2, 45.81, 15.98),
('CZ', 'eu', 1, 50.09, 14.42),
('DK', 'eu', 2, 55.68, 12.57),
('EE', 'eu', 3, 59.44, 24.75),
('FI', 'eu', 2, 60.17, 24.94),
('FR', 'eu', 1, 48.86, 2.35),
('DE', 'eu', 1, 52.52, 13.38),
('GR', 'eu', 1, 37.98, 23.73),
('HU', 'eu', 2, 47.5, 19.04),
('IS', 'eu', 3, 64.15, -21.93),
('IE', 'eu', 2, 53.35, -6.26),
('IT', 'eu', 1, 41.89, 12.48),
('LV', 'eu', 3, 56.95, 24.11),
('LI', 'eu', 3, 47.14, 9.52),
('LT', 'eu', 3, 54.69, 25.28),
('LU', 'eu', 3, 49.61, 6.13),
('MT', 'eu', 3, 35.9, 14.51),
('MD', 'eu', 3, 47.02, 28.84),
('MC', 'eu', 3, 43.73, 7.42),
('ME', 'eu', 3, 42.44, 19.26),
('NL', 'eu', 1, 52.37, 4.88),
('MK', 'eu', 3, 42, 21.43),
('NO', 'eu', 2, 59.91, 10.74),
('PL', 'eu', 1, 52.23, 21.01),
('PT', 'eu', 1, 38.71, -9.14),
('RO', 'eu', 1, 44.41, 26.1),
('RU', 'eu', 1, 55.75, 37.62),
('SM', 'eu', 3, 43.93, 12.45),
('RS', 'eu', 2, 44.82, 20.46),
('SK', 'eu', 2, 48.15, 17.11),
('SI', 'eu', 3, 46.05, 14.51),
('ES', 'eu', 1, 40.42, -3.7),
('SE', 'eu', 1, 59.33, 18.07),
('CH', 'eu', 2, 46.95, 7.45),
('UA', 'eu', 1, 50.45, 30.52),
('GB', 'eu', 1, 51.51, -0.13),
('AG', 'na', 3, 17.12, -61.84),
('BS', 'na', 2, 25.08, -77.34),
('BB', 'na', 3, 13.1, -59.62),
('BZ', 'na', 2, 17.25, -88.77),
('CA', 'na', 1, 45.42, -75.69),
('CR', 'na', 2, 9.93, -84.08),
('CU', 'na', 1, 23.14, -82.36),
('DM', 'na', 3, 15.3, -61.38),
('DO', 'na', 1, 18.46, -69.94),
('SV', 'na', 2, 13.7, -89.19),
('GD', 'na', 3, 12.05, -61.75),
('GT', 'na', 1, 14.64, -90.51),
('HT', 'na', 1, 18.55, -72.34),
('HN', 'na', 1, 14.11, -87.2),
('JM', 'na', 2, 17.97, -76.79),
('MX', 'na', 1, 19.35, -99.14),
('NI', 'na', 2, 12.15, -86.27),
('PA', 'na', 2, 8.97, -79.53),
('KN', 'na', 3, 17.3, -62.73),
('LC', 'na', 3, 14.01, -60.99),
('VC', 'na', 3, 13.16, -61.23),
('TT', 'na', 2, 10.67, -61.52),
('US', 'na', 1, 38.9, -77.04),
('AR', 'sa', 1, -34.6, -58.38),
('BO', 'sa', 2, -19.05, -65.26),
('BR', 'sa', 1, -15.79, -47.88),
('CL', 'sa', 2, -33.44, -70.65),
('CO', 'sa', 1, 4.61, -74.08),
('EC', 'sa', 2, -0.22, -78.51),
('GY', 'sa', 3, 6.81, -58.15),
('PY', 'sa', 3, -25.28, -57.63),
('PE', 'sa', 1, -12.06, -77.04),
('SR', 'sa', 3, 5.87, -55.17),
('UY', 'sa', 3, -34.91, -56.19),
('VE', 'sa', 2, 10.51, -66.91),
('AU', 'oc', 1, -35.29, 149.13),
('FJ', 'oc', 1, -18.13, 178.43),
('KI', 'oc', 2, 1.33, 172.97),
('MH', 'oc', 3, 7.09, 171.38),
('FM', 'oc', 2, 6.92, 158.19),
('NR', 'oc', 3, -0.55, 166.92),
('NZ', 'oc', 1, -41.29, 174.78),
('PW', 'oc', 3, 7.5, 134.62),
('PG', 'oc', 1, -9.48, 147.15),
('WS', 'oc', 2, -13.83, -171.83),
('SB', 'oc', 1, -9.43, 159.95),
('TO', 'oc', 2, -21.13, -175.2),
('TV', 'oc', 3, -8.5, 179.12),
('VU', 'oc', 2, -17.73, 168.32)
ON CONFLICT (iso) DO UPDATE SET
  continent = EXCLUDED.continent, tier = EXCLUDED.tier, lat = EXCLUDED.lat, lon = EXCLUDED.lon;


-- ── 5. Pin the map: rounds ───────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS geo_pin_rounds (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  deck         TEXT        NOT NULL,
  score        INT         NOT NULL CHECK (score BETWEEN 0 AND 1100),
  answers      JSONB       NOT NULL,
  completed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS geo_pin_rounds_user_time_idx ON geo_pin_rounds (user_id, completed_at DESC);
CREATE INDEX IF NOT EXISTS geo_pin_rounds_deck_score_idx ON geo_pin_rounds (deck, score DESC);

ALTER TABLE geo_pin_rounds ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "geo_pin_rounds_select" ON geo_pin_rounds;
CREATE POLICY "geo_pin_rounds_select" ON geo_pin_rounds FOR SELECT
  USING (
    auth.uid() = user_id
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_admin)
  );

-- No insert policy and no insert grant: a round is written only by
-- record_geo_pin_round, which works out the score itself.
REVOKE ALL ON geo_pin_rounds FROM anon;
REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON geo_pin_rounds FROM authenticated;
GRANT SELECT ON geo_pin_rounds TO authenticated;


-- ── 6. Recording a round ─────────────────────────────────────────────────────
--
-- p_pins: exactly 10 objects {i, lat, lon, ms}, one per DIFFERENT capital
-- of the deck's continent. lat and lon are where the student tapped (null if
-- they gave up), ms how long they took. Distance is great-circle km to the
-- capital in geo_pin_places, scored by the rings of lib/geo-pin.ts:
-- 100 within 100 km, 70 within 300 km, 40 within 600 km, 20 within 1000 km, 10 within 1500 km, plus 10 for 3 s or 5 for 6 s
-- on any scoring pin. Returns the round's score.

CREATE OR REPLACE FUNCTION record_geo_pin_round(p_deck TEXT, p_pins JSONB)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid    UUID := auth.uid();
  cont   TEXT;
  places INT;
  bad    INT;
  total  INT;
  scored JSONB;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'record_geo_pin_round requires a signed-in user';
  END IF;
  IF p_deck IS NULL OR p_deck NOT IN (
    SELECT c || ':' || l FROM unnest(ARRAY['af', 'as', 'eu', 'na', 'sa', 'oc']) AS c, unnest(ARRAY['1', '2', '3']) AS l
  ) THEN
    RAISE EXCEPTION 'unknown pin deck %', p_deck;
  END IF;
  cont := split_part(p_deck, ':', 1);
  IF jsonb_typeof(p_pins) IS DISTINCT FROM 'array' OR jsonb_array_length(p_pins) <> 10 THEN
    RAISE EXCEPTION 'a pin round has 10 places';
  END IF;

  WITH pins AS (
    SELECT e.ord,
           e.v ->> 'i'                AS iso,
           (e.v ->> 'lat')::DOUBLE PRECISION AS lat,
           (e.v ->> 'lon')::DOUBLE PRECISION AS lon,
           (e.v ->> 'ms')::INT        AS ms
      FROM jsonb_array_elements(p_pins) WITH ORDINALITY AS e(v, ord)
  ),
  dist AS (
    SELECT p.ord, p.iso, p.ms,
           CASE WHEN p.lat IS NULL OR p.lon IS NULL THEN NULL
                ELSE 2 * 6371 * asin(least(1, sqrt(
                       power(sin(radians(p.lat - g.lat) / 2), 2)
                       + cos(radians(g.lat)) * cos(radians(p.lat)) * power(sin(radians(p.lon - g.lon) / 2), 2))))
           END AS km,
           (p.lat IS NOT NULL AND NOT p.lat BETWEEN -90 AND 90)
             OR (p.lon IS NOT NULL AND NOT p.lon BETWEEN -180 AND 180)
             OR ((p.lat IS NULL) <> (p.lon IS NULL)) AS out_of_range
      FROM pins p
      JOIN geo_pin_places g ON g.iso = p.iso AND g.continent = cont
  ),
  ringed AS (
    SELECT d.*, CASE WHEN km <= 100 THEN 100 WHEN km <= 300 THEN 70 WHEN km <= 600 THEN 40 WHEN km <= 1000 THEN 20 WHEN km <= 1500 THEN 10 ELSE 0 END AS ring FROM dist d
  ),
  pts AS (
    SELECT r.*, r.ring + CASE WHEN r.ring > 0 THEN (CASE WHEN r.ms BETWEEN 0 AND 3000 THEN 10 WHEN r.ms BETWEEN 0 AND 6000 THEN 5 ELSE 0 END) ELSE 0 END AS points FROM ringed r
  )
  SELECT COUNT(DISTINCT iso), COUNT(*) FILTER (WHERE out_of_range), COALESCE(SUM(points), 0),
         jsonb_agg(jsonb_build_object('i', iso, 'km', round(km::NUMERIC), 'ms', ms, 'p', points) ORDER BY ord)
    INTO places, bad, total, scored
    FROM pts;

  IF places <> 10 THEN
    RAISE EXCEPTION 'a pin round needs 10 different capitals of its continent';
  END IF;
  IF bad > 0 THEN
    RAISE EXCEPTION 'pin outside the map';
  END IF;

  INSERT INTO geo_pin_rounds (user_id, deck, score, answers) VALUES (uid, p_deck, total, scored);
  RETURN total;
END;
$$;

REVOKE ALL ON FUNCTION record_geo_pin_round(TEXT, JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION record_geo_pin_round(TEXT, JSONB) TO authenticated;


-- ── 7. Pin the map leaderboard ───────────────────────────────────────────────
--
-- Best score per profile per deck ("eu:1" is Europe, level 1). Aggregates
-- only, no individual pins.

CREATE OR REPLACE VIEW geo_pin_leaderboard_view AS
SELECT
  p.id AS user_id,
  p.display_name,
  p.avatar_color,
  p.avatar_url,
  p.class_code,
  r.deck,
  MAX(r.score)::INT AS best,
  COUNT(*)::INT     AS rounds
FROM geo_pin_rounds r
JOIN profiles p ON p.id = r.user_id
GROUP BY p.id, p.display_name, p.avatar_color, p.avatar_url, p.class_code, r.deck;

REVOKE ALL ON geo_pin_leaderboard_view FROM anon;
GRANT SELECT ON geo_pin_leaderboard_view TO authenticated;


-- ── Verification ─────────────────────────────────────────────────────────────
--
-- Expected: cards 1158, shape_cards 193, phase1_cards 965,
--           phase1_points 9650, max_points 12545, orphan_history 0,
--           geo_badges 21, pin_places 193, pin_rounds_table 1,
--           helper_callable_by_students false,
--           pin_record_callable_by_anon false, pin_insert_by_students false.

SELECT
  (SELECT COUNT(*) FROM geo_cards)                                        AS cards,
  (SELECT COUNT(*) FROM geo_cards WHERE kind = 'shape')                   AS shape_cards,
  (SELECT COUNT(*) FROM geo_cards WHERE kind <> 'shape')                  AS phase1_cards,
  (SELECT SUM(points) FROM geo_cards WHERE kind <> 'shape')               AS phase1_points,
  (SELECT SUM(points) FROM geo_cards)                                     AS max_points,
  (SELECT COUNT(*) FROM geo_history h
    WHERE NOT EXISTS (SELECT 1 FROM geo_cards c WHERE c.card_key = h.card_key)) AS orphan_history,
  (SELECT COUNT(*) FROM achievement_definitions WHERE category = 'Geography') AS geo_badges,
  (SELECT COUNT(*) FROM geo_pin_places)                                   AS pin_places,
  (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'geo_pin_rounds') AS pin_rounds_table,
  has_function_privilege('authenticated', 'award_geo_badges_for(uuid, boolean)', 'EXECUTE')
                                                                           AS helper_callable_by_students,
  has_function_privilege('anon', 'record_geo_pin_round(text, jsonb)', 'EXECUTE')
                                                                           AS pin_record_callable_by_anon,
  has_table_privilege('authenticated', 'geo_pin_rounds', 'INSERT')        AS pin_insert_by_students;
