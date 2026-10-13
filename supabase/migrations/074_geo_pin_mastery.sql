-- 074 - Geography: Pin the map masters cards
--
-- Needs 069-073. Every Geography game now feeds the same Explorer Points:
-- playing Pin the map masters cards, exactly as a quiz answer does. A
-- round's own score (stars, distance points, "better than X%", the per-map
-- best boards) stays what it was: round feedback, like a quiz round's
-- "7/10 correct".
--
--   geo_cards                 + 192 'find' cards ("Find Kenya on the map"),
--                             one per country Find the country asks (every
--                             UN member but IL), keyed 'find:ke'
--                             + 340 'pin' cards ("Pin Nairobi"), one per
--                             Pin the map place, keyed 'pin:' + the place key
--                             ('pin:cap:ke', 'pin:city:rio-de-janeiro').
--                             Both 15 Explorer Points, mastered within
--                             8 s. Inserted only: no other card is touched.
--                             The catalogue becomes 1819 cards and
--                             21725 Explorer Points (was 1287 and 13745).
--   geo_pin_grade             a pin's verdict as a grade, the same thresholds
--                             as lib/geo-pin.ts pinVerdict: 2 = Bullseye or
--                             Great (within 20% of the continent's
--                             zero radius), 1 = Close (within 40%),
--                             0 = the rest
--   geo_pin_master            writes a round's taps into geo_history with
--                             record_geo_answer's rules: a find, or a pin
--                             graded 2, within the card's target time (and
--                             at least 200 ms) masters it, fluent_at set
--                             once and never cleared. A slow find, or a
--                             Close pin, is right but not mastered. A miss,
--                             a give-up or an Off pin counts as wrong.
--                             Nothing is ever lowered. Not callable by clients.
--   record_geo_pin_round      073's functions: same signatures, same checks,
--   record_geo_country_round  same scoring and the same INT return, with two
--                             changes: the round row records mastery_at, and
--                             the same taps go through geo_pin_master in the
--                             same transaction.
--   geo_pin_rounds.mastery_at when a round's taps reached geo_history. NULL =
--                             not yet, which is how the backfill below finds
--                             the rounds saved before this migration (and why
--                             a second run changes nothing).
--   badges                    + Country Seeker (25 finds), Pathfinder (all
--                             192), Sharp Pin (25 pins), Grand Cartographer
--                             (all 340). World Turtle and the continent
--                             ladders count every card, so find and pin
--                             cards now count toward them: the half rungs
--                             and the full continent badges get new
--                             thresholds. Everything a student has already
--                             earned is awarded FIRST, under the rules it was
--                             earned by, and badges are never removed.
--   award_geo_badges_for      072's, with the find and pin rungs and the new
--                             half thresholds. Still revoked from students.
--
-- Explorer Points (geo_leaderboard_view) and every page's points and "N of M
-- cards mastered" add up geo_cards, so they include the new cards with no
-- other change.
--
-- Re-running is harmless: cards and badges upsert, functions are replaced
-- with the same text, the backfill only takes rounds with no mastery_at, and
-- awards ignore duplicates.
--
-- Generated: do not edit by hand. Change lib/geo.ts, lib/geo-meta.ts,
-- lib/geo-pin.ts or supabase/geography/074.template.sql, then run
--   node supabase/geography/pin-mastery.mts
-- The generator copies the round functions from 073 and the award function
-- from 072 (changing only what is listed above), and refuses to write if any
-- string literal contains a semicolon, a dollar sign or a double dash (the
-- Supabase editor misparses those), or if the file is not pure ASCII.


-- 1. Award what students have already earned, under the rules they earned it by
--
-- The next steps add cards to the every-card and continent badges. Anything
-- a student qualifies for today is awarded first, so it can never slip out
-- of reach. (On a re-run this is the new function: also harmless.)

DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN SELECT DISTINCT user_id FROM geo_history LOOP
    PERFORM award_geo_badges_for(r.user_id, FALSE);
  END LOOP;
END $$;


-- 2. The new cards
--
-- The WHERE below means a re-run can only ever update find and pin cards,
-- never an older card.

INSERT INTO geo_cards (card_key, iso, kind, continent, points, target_ms) VALUES
('find:dz', 'DZ', 'find', 'af', 15, 8000),
('find:ao', 'AO', 'find', 'af', 15, 8000),
('find:bj', 'BJ', 'find', 'af', 15, 8000),
('find:bw', 'BW', 'find', 'af', 15, 8000),
('find:bf', 'BF', 'find', 'af', 15, 8000),
('find:bi', 'BI', 'find', 'af', 15, 8000),
('find:cv', 'CV', 'find', 'af', 15, 8000),
('find:cm', 'CM', 'find', 'af', 15, 8000),
('find:cf', 'CF', 'find', 'af', 15, 8000),
('find:td', 'TD', 'find', 'af', 15, 8000),
('find:km', 'KM', 'find', 'af', 15, 8000),
('find:cg', 'CG', 'find', 'af', 15, 8000),
('find:cd', 'CD', 'find', 'af', 15, 8000),
('find:ci', 'CI', 'find', 'af', 15, 8000),
('find:dj', 'DJ', 'find', 'af', 15, 8000),
('find:eg', 'EG', 'find', 'af', 15, 8000),
('find:gq', 'GQ', 'find', 'af', 15, 8000),
('find:er', 'ER', 'find', 'af', 15, 8000),
('find:sz', 'SZ', 'find', 'af', 15, 8000),
('find:et', 'ET', 'find', 'af', 15, 8000),
('find:ga', 'GA', 'find', 'af', 15, 8000),
('find:gm', 'GM', 'find', 'af', 15, 8000),
('find:gh', 'GH', 'find', 'af', 15, 8000),
('find:gn', 'GN', 'find', 'af', 15, 8000),
('find:gw', 'GW', 'find', 'af', 15, 8000),
('find:ke', 'KE', 'find', 'af', 15, 8000),
('find:ls', 'LS', 'find', 'af', 15, 8000),
('find:lr', 'LR', 'find', 'af', 15, 8000),
('find:ly', 'LY', 'find', 'af', 15, 8000),
('find:mg', 'MG', 'find', 'af', 15, 8000),
('find:mw', 'MW', 'find', 'af', 15, 8000),
('find:ml', 'ML', 'find', 'af', 15, 8000),
('find:mr', 'MR', 'find', 'af', 15, 8000),
('find:mu', 'MU', 'find', 'af', 15, 8000),
('find:ma', 'MA', 'find', 'af', 15, 8000),
('find:mz', 'MZ', 'find', 'af', 15, 8000),
('find:na', 'NA', 'find', 'af', 15, 8000),
('find:ne', 'NE', 'find', 'af', 15, 8000),
('find:ng', 'NG', 'find', 'af', 15, 8000),
('find:rw', 'RW', 'find', 'af', 15, 8000),
('find:st', 'ST', 'find', 'af', 15, 8000),
('find:sn', 'SN', 'find', 'af', 15, 8000),
('find:sc', 'SC', 'find', 'af', 15, 8000),
('find:sl', 'SL', 'find', 'af', 15, 8000),
('find:so', 'SO', 'find', 'af', 15, 8000),
('find:za', 'ZA', 'find', 'af', 15, 8000),
('find:ss', 'SS', 'find', 'af', 15, 8000),
('find:sd', 'SD', 'find', 'af', 15, 8000),
('find:tz', 'TZ', 'find', 'af', 15, 8000),
('find:tg', 'TG', 'find', 'af', 15, 8000),
('find:tn', 'TN', 'find', 'af', 15, 8000),
('find:ug', 'UG', 'find', 'af', 15, 8000),
('find:zm', 'ZM', 'find', 'af', 15, 8000),
('find:zw', 'ZW', 'find', 'af', 15, 8000),
('find:af', 'AF', 'find', 'as', 15, 8000),
('find:am', 'AM', 'find', 'as', 15, 8000),
('find:az', 'AZ', 'find', 'as', 15, 8000),
('find:bh', 'BH', 'find', 'as', 15, 8000),
('find:bd', 'BD', 'find', 'as', 15, 8000),
('find:bt', 'BT', 'find', 'as', 15, 8000),
('find:bn', 'BN', 'find', 'as', 15, 8000),
('find:kh', 'KH', 'find', 'as', 15, 8000),
('find:cn', 'CN', 'find', 'as', 15, 8000),
('find:cy', 'CY', 'find', 'as', 15, 8000),
('find:ge', 'GE', 'find', 'as', 15, 8000),
('find:in', 'IN', 'find', 'as', 15, 8000),
('find:id', 'ID', 'find', 'as', 15, 8000),
('find:ir', 'IR', 'find', 'as', 15, 8000),
('find:iq', 'IQ', 'find', 'as', 15, 8000),
('find:jp', 'JP', 'find', 'as', 15, 8000),
('find:jo', 'JO', 'find', 'as', 15, 8000),
('find:kz', 'KZ', 'find', 'as', 15, 8000),
('find:kw', 'KW', 'find', 'as', 15, 8000),
('find:kg', 'KG', 'find', 'as', 15, 8000),
('find:la', 'LA', 'find', 'as', 15, 8000),
('find:lb', 'LB', 'find', 'as', 15, 8000),
('find:my', 'MY', 'find', 'as', 15, 8000),
('find:mv', 'MV', 'find', 'as', 15, 8000),
('find:mn', 'MN', 'find', 'as', 15, 8000),
('find:mm', 'MM', 'find', 'as', 15, 8000),
('find:np', 'NP', 'find', 'as', 15, 8000),
('find:kp', 'KP', 'find', 'as', 15, 8000),
('find:om', 'OM', 'find', 'as', 15, 8000),
('find:pk', 'PK', 'find', 'as', 15, 8000),
('find:ph', 'PH', 'find', 'as', 15, 8000),
('find:qa', 'QA', 'find', 'as', 15, 8000),
('find:sa', 'SA', 'find', 'as', 15, 8000),
('find:sg', 'SG', 'find', 'as', 15, 8000),
('find:kr', 'KR', 'find', 'as', 15, 8000),
('find:lk', 'LK', 'find', 'as', 15, 8000),
('find:sy', 'SY', 'find', 'as', 15, 8000),
('find:tj', 'TJ', 'find', 'as', 15, 8000),
('find:th', 'TH', 'find', 'as', 15, 8000),
('find:tl', 'TL', 'find', 'as', 15, 8000),
('find:tr', 'TR', 'find', 'as', 15, 8000),
('find:tm', 'TM', 'find', 'as', 15, 8000),
('find:ae', 'AE', 'find', 'as', 15, 8000),
('find:uz', 'UZ', 'find', 'as', 15, 8000),
('find:vn', 'VN', 'find', 'as', 15, 8000),
('find:ye', 'YE', 'find', 'as', 15, 8000),
('find:al', 'AL', 'find', 'eu', 15, 8000),
('find:ad', 'AD', 'find', 'eu', 15, 8000),
('find:at', 'AT', 'find', 'eu', 15, 8000),
('find:by', 'BY', 'find', 'eu', 15, 8000),
('find:be', 'BE', 'find', 'eu', 15, 8000),
('find:ba', 'BA', 'find', 'eu', 15, 8000),
('find:bg', 'BG', 'find', 'eu', 15, 8000),
('find:hr', 'HR', 'find', 'eu', 15, 8000),
('find:cz', 'CZ', 'find', 'eu', 15, 8000),
('find:dk', 'DK', 'find', 'eu', 15, 8000),
('find:ee', 'EE', 'find', 'eu', 15, 8000),
('find:fi', 'FI', 'find', 'eu', 15, 8000),
('find:fr', 'FR', 'find', 'eu', 15, 8000),
('find:de', 'DE', 'find', 'eu', 15, 8000),
('find:gr', 'GR', 'find', 'eu', 15, 8000),
('find:hu', 'HU', 'find', 'eu', 15, 8000),
('find:is', 'IS', 'find', 'eu', 15, 8000),
('find:ie', 'IE', 'find', 'eu', 15, 8000),
('find:it', 'IT', 'find', 'eu', 15, 8000),
('find:lv', 'LV', 'find', 'eu', 15, 8000),
('find:li', 'LI', 'find', 'eu', 15, 8000),
('find:lt', 'LT', 'find', 'eu', 15, 8000),
('find:lu', 'LU', 'find', 'eu', 15, 8000),
('find:mt', 'MT', 'find', 'eu', 15, 8000),
('find:md', 'MD', 'find', 'eu', 15, 8000),
('find:mc', 'MC', 'find', 'eu', 15, 8000),
('find:me', 'ME', 'find', 'eu', 15, 8000),
('find:nl', 'NL', 'find', 'eu', 15, 8000),
('find:mk', 'MK', 'find', 'eu', 15, 8000),
('find:no', 'NO', 'find', 'eu', 15, 8000),
('find:pl', 'PL', 'find', 'eu', 15, 8000),
('find:pt', 'PT', 'find', 'eu', 15, 8000),
('find:ro', 'RO', 'find', 'eu', 15, 8000),
('find:ru', 'RU', 'find', 'eu', 15, 8000),
('find:sm', 'SM', 'find', 'eu', 15, 8000),
('find:rs', 'RS', 'find', 'eu', 15, 8000),
('find:sk', 'SK', 'find', 'eu', 15, 8000),
('find:si', 'SI', 'find', 'eu', 15, 8000),
('find:es', 'ES', 'find', 'eu', 15, 8000),
('find:se', 'SE', 'find', 'eu', 15, 8000),
('find:ch', 'CH', 'find', 'eu', 15, 8000),
('find:ua', 'UA', 'find', 'eu', 15, 8000),
('find:gb', 'GB', 'find', 'eu', 15, 8000),
('find:ag', 'AG', 'find', 'na', 15, 8000),
('find:bs', 'BS', 'find', 'na', 15, 8000),
('find:bb', 'BB', 'find', 'na', 15, 8000),
('find:bz', 'BZ', 'find', 'na', 15, 8000),
('find:ca', 'CA', 'find', 'na', 15, 8000),
('find:cr', 'CR', 'find', 'na', 15, 8000),
('find:cu', 'CU', 'find', 'na', 15, 8000),
('find:dm', 'DM', 'find', 'na', 15, 8000),
('find:do', 'DO', 'find', 'na', 15, 8000),
('find:sv', 'SV', 'find', 'na', 15, 8000),
('find:gd', 'GD', 'find', 'na', 15, 8000),
('find:gt', 'GT', 'find', 'na', 15, 8000),
('find:ht', 'HT', 'find', 'na', 15, 8000),
('find:hn', 'HN', 'find', 'na', 15, 8000),
('find:jm', 'JM', 'find', 'na', 15, 8000),
('find:mx', 'MX', 'find', 'na', 15, 8000),
('find:ni', 'NI', 'find', 'na', 15, 8000),
('find:pa', 'PA', 'find', 'na', 15, 8000),
('find:kn', 'KN', 'find', 'na', 15, 8000),
('find:lc', 'LC', 'find', 'na', 15, 8000),
('find:vc', 'VC', 'find', 'na', 15, 8000),
('find:tt', 'TT', 'find', 'na', 15, 8000),
('find:us', 'US', 'find', 'na', 15, 8000),
('find:ar', 'AR', 'find', 'sa', 15, 8000),
('find:bo', 'BO', 'find', 'sa', 15, 8000),
('find:br', 'BR', 'find', 'sa', 15, 8000),
('find:cl', 'CL', 'find', 'sa', 15, 8000),
('find:co', 'CO', 'find', 'sa', 15, 8000),
('find:ec', 'EC', 'find', 'sa', 15, 8000),
('find:gy', 'GY', 'find', 'sa', 15, 8000),
('find:py', 'PY', 'find', 'sa', 15, 8000),
('find:pe', 'PE', 'find', 'sa', 15, 8000),
('find:sr', 'SR', 'find', 'sa', 15, 8000),
('find:uy', 'UY', 'find', 'sa', 15, 8000),
('find:ve', 'VE', 'find', 'sa', 15, 8000),
('find:au', 'AU', 'find', 'oc', 15, 8000),
('find:fj', 'FJ', 'find', 'oc', 15, 8000),
('find:ki', 'KI', 'find', 'oc', 15, 8000),
('find:mh', 'MH', 'find', 'oc', 15, 8000),
('find:fm', 'FM', 'find', 'oc', 15, 8000),
('find:nr', 'NR', 'find', 'oc', 15, 8000),
('find:nz', 'NZ', 'find', 'oc', 15, 8000),
('find:pw', 'PW', 'find', 'oc', 15, 8000),
('find:pg', 'PG', 'find', 'oc', 15, 8000),
('find:ws', 'WS', 'find', 'oc', 15, 8000),
('find:sb', 'SB', 'find', 'oc', 15, 8000),
('find:to', 'TO', 'find', 'oc', 15, 8000),
('find:tv', 'TV', 'find', 'oc', 15, 8000),
('find:vu', 'VU', 'find', 'oc', 15, 8000),
('pin:cap:dz', 'DZ', 'pin', 'af', 15, 8000),
('pin:cap:ao', 'AO', 'pin', 'af', 15, 8000),
('pin:cap:bj', 'BJ', 'pin', 'af', 15, 8000),
('pin:cap:bw', 'BW', 'pin', 'af', 15, 8000),
('pin:cap:bf', 'BF', 'pin', 'af', 15, 8000),
('pin:cap:bi', 'BI', 'pin', 'af', 15, 8000),
('pin:cap:cv', 'CV', 'pin', 'af', 15, 8000),
('pin:cap:cm', 'CM', 'pin', 'af', 15, 8000),
('pin:cap:cf', 'CF', 'pin', 'af', 15, 8000),
('pin:cap:td', 'TD', 'pin', 'af', 15, 8000),
('pin:cap:km', 'KM', 'pin', 'af', 15, 8000),
('pin:cap:cg', 'CG', 'pin', 'af', 15, 8000),
('pin:cap:cd', 'CD', 'pin', 'af', 15, 8000),
('pin:cap:ci', 'CI', 'pin', 'af', 15, 8000),
('pin:cap:dj', 'DJ', 'pin', 'af', 15, 8000),
('pin:cap:eg', 'EG', 'pin', 'af', 15, 8000),
('pin:cap:gq', 'GQ', 'pin', 'af', 15, 8000),
('pin:cap:er', 'ER', 'pin', 'af', 15, 8000),
('pin:cap:sz', 'SZ', 'pin', 'af', 15, 8000),
('pin:cap:et', 'ET', 'pin', 'af', 15, 8000),
('pin:cap:ga', 'GA', 'pin', 'af', 15, 8000),
('pin:cap:gm', 'GM', 'pin', 'af', 15, 8000),
('pin:cap:gh', 'GH', 'pin', 'af', 15, 8000),
('pin:cap:gn', 'GN', 'pin', 'af', 15, 8000),
('pin:cap:gw', 'GW', 'pin', 'af', 15, 8000),
('pin:cap:ke', 'KE', 'pin', 'af', 15, 8000),
('pin:cap:ls', 'LS', 'pin', 'af', 15, 8000),
('pin:cap:lr', 'LR', 'pin', 'af', 15, 8000),
('pin:cap:ly', 'LY', 'pin', 'af', 15, 8000),
('pin:cap:mg', 'MG', 'pin', 'af', 15, 8000),
('pin:cap:mw', 'MW', 'pin', 'af', 15, 8000),
('pin:cap:ml', 'ML', 'pin', 'af', 15, 8000),
('pin:cap:mr', 'MR', 'pin', 'af', 15, 8000),
('pin:cap:mu', 'MU', 'pin', 'af', 15, 8000),
('pin:cap:ma', 'MA', 'pin', 'af', 15, 8000),
('pin:cap:mz', 'MZ', 'pin', 'af', 15, 8000),
('pin:cap:na', 'NA', 'pin', 'af', 15, 8000),
('pin:cap:ne', 'NE', 'pin', 'af', 15, 8000),
('pin:cap:ng', 'NG', 'pin', 'af', 15, 8000),
('pin:cap:rw', 'RW', 'pin', 'af', 15, 8000),
('pin:cap:st', 'ST', 'pin', 'af', 15, 8000),
('pin:cap:sn', 'SN', 'pin', 'af', 15, 8000),
('pin:cap:sc', 'SC', 'pin', 'af', 15, 8000),
('pin:cap:sl', 'SL', 'pin', 'af', 15, 8000),
('pin:cap:so', 'SO', 'pin', 'af', 15, 8000),
('pin:cap:za', 'ZA', 'pin', 'af', 15, 8000),
('pin:cap:ss', 'SS', 'pin', 'af', 15, 8000),
('pin:cap:sd', 'SD', 'pin', 'af', 15, 8000),
('pin:cap:tz', 'TZ', 'pin', 'af', 15, 8000),
('pin:cap:tg', 'TG', 'pin', 'af', 15, 8000),
('pin:cap:tn', 'TN', 'pin', 'af', 15, 8000),
('pin:cap:ug', 'UG', 'pin', 'af', 15, 8000),
('pin:cap:zm', 'ZM', 'pin', 'af', 15, 8000),
('pin:cap:zw', 'ZW', 'pin', 'af', 15, 8000),
('pin:cap:af', 'AF', 'pin', 'as', 15, 8000),
('pin:cap:am', 'AM', 'pin', 'as', 15, 8000),
('pin:cap:az', 'AZ', 'pin', 'as', 15, 8000),
('pin:cap:bh', 'BH', 'pin', 'as', 15, 8000),
('pin:cap:bd', 'BD', 'pin', 'as', 15, 8000),
('pin:cap:bt', 'BT', 'pin', 'as', 15, 8000),
('pin:cap:bn', 'BN', 'pin', 'as', 15, 8000),
('pin:cap:kh', 'KH', 'pin', 'as', 15, 8000),
('pin:cap:cn', 'CN', 'pin', 'as', 15, 8000),
('pin:cap:cy', 'CY', 'pin', 'as', 15, 8000),
('pin:cap:ge', 'GE', 'pin', 'as', 15, 8000),
('pin:cap:in', 'IN', 'pin', 'as', 15, 8000),
('pin:cap:id', 'ID', 'pin', 'as', 15, 8000),
('pin:cap:ir', 'IR', 'pin', 'as', 15, 8000),
('pin:cap:iq', 'IQ', 'pin', 'as', 15, 8000),
('pin:cap:il', 'IL', 'pin', 'as', 15, 8000),
('pin:cap:jp', 'JP', 'pin', 'as', 15, 8000),
('pin:cap:jo', 'JO', 'pin', 'as', 15, 8000),
('pin:cap:kz', 'KZ', 'pin', 'as', 15, 8000),
('pin:cap:kw', 'KW', 'pin', 'as', 15, 8000),
('pin:cap:kg', 'KG', 'pin', 'as', 15, 8000),
('pin:cap:la', 'LA', 'pin', 'as', 15, 8000),
('pin:cap:lb', 'LB', 'pin', 'as', 15, 8000),
('pin:cap:my', 'MY', 'pin', 'as', 15, 8000),
('pin:cap:mv', 'MV', 'pin', 'as', 15, 8000),
('pin:cap:mn', 'MN', 'pin', 'as', 15, 8000),
('pin:cap:mm', 'MM', 'pin', 'as', 15, 8000),
('pin:cap:np', 'NP', 'pin', 'as', 15, 8000),
('pin:cap:kp', 'KP', 'pin', 'as', 15, 8000),
('pin:cap:om', 'OM', 'pin', 'as', 15, 8000),
('pin:cap:pk', 'PK', 'pin', 'as', 15, 8000),
('pin:cap:ph', 'PH', 'pin', 'as', 15, 8000),
('pin:cap:qa', 'QA', 'pin', 'as', 15, 8000),
('pin:cap:sa', 'SA', 'pin', 'as', 15, 8000),
('pin:cap:sg', 'SG', 'pin', 'as', 15, 8000),
('pin:cap:kr', 'KR', 'pin', 'as', 15, 8000),
('pin:cap:lk', 'LK', 'pin', 'as', 15, 8000),
('pin:cap:sy', 'SY', 'pin', 'as', 15, 8000),
('pin:cap:tj', 'TJ', 'pin', 'as', 15, 8000),
('pin:cap:th', 'TH', 'pin', 'as', 15, 8000),
('pin:cap:tl', 'TL', 'pin', 'as', 15, 8000),
('pin:cap:tr', 'TR', 'pin', 'as', 15, 8000),
('pin:cap:tm', 'TM', 'pin', 'as', 15, 8000),
('pin:cap:ae', 'AE', 'pin', 'as', 15, 8000),
('pin:cap:uz', 'UZ', 'pin', 'as', 15, 8000),
('pin:cap:vn', 'VN', 'pin', 'as', 15, 8000),
('pin:cap:ye', 'YE', 'pin', 'as', 15, 8000),
('pin:cap:al', 'AL', 'pin', 'eu', 15, 8000),
('pin:cap:ad', 'AD', 'pin', 'eu', 15, 8000),
('pin:cap:at', 'AT', 'pin', 'eu', 15, 8000),
('pin:cap:by', 'BY', 'pin', 'eu', 15, 8000),
('pin:cap:be', 'BE', 'pin', 'eu', 15, 8000),
('pin:cap:ba', 'BA', 'pin', 'eu', 15, 8000),
('pin:cap:bg', 'BG', 'pin', 'eu', 15, 8000),
('pin:cap:hr', 'HR', 'pin', 'eu', 15, 8000),
('pin:cap:cz', 'CZ', 'pin', 'eu', 15, 8000),
('pin:cap:dk', 'DK', 'pin', 'eu', 15, 8000),
('pin:cap:ee', 'EE', 'pin', 'eu', 15, 8000),
('pin:cap:fi', 'FI', 'pin', 'eu', 15, 8000),
('pin:cap:fr', 'FR', 'pin', 'eu', 15, 8000),
('pin:cap:de', 'DE', 'pin', 'eu', 15, 8000),
('pin:cap:gr', 'GR', 'pin', 'eu', 15, 8000),
('pin:cap:hu', 'HU', 'pin', 'eu', 15, 8000),
('pin:cap:is', 'IS', 'pin', 'eu', 15, 8000),
('pin:cap:ie', 'IE', 'pin', 'eu', 15, 8000),
('pin:cap:it', 'IT', 'pin', 'eu', 15, 8000),
('pin:cap:lv', 'LV', 'pin', 'eu', 15, 8000),
('pin:cap:li', 'LI', 'pin', 'eu', 15, 8000),
('pin:cap:lt', 'LT', 'pin', 'eu', 15, 8000),
('pin:cap:lu', 'LU', 'pin', 'eu', 15, 8000),
('pin:cap:mt', 'MT', 'pin', 'eu', 15, 8000),
('pin:cap:md', 'MD', 'pin', 'eu', 15, 8000),
('pin:cap:mc', 'MC', 'pin', 'eu', 15, 8000),
('pin:cap:me', 'ME', 'pin', 'eu', 15, 8000),
('pin:cap:nl', 'NL', 'pin', 'eu', 15, 8000),
('pin:cap:mk', 'MK', 'pin', 'eu', 15, 8000),
('pin:cap:no', 'NO', 'pin', 'eu', 15, 8000),
('pin:cap:pl', 'PL', 'pin', 'eu', 15, 8000),
('pin:cap:pt', 'PT', 'pin', 'eu', 15, 8000),
('pin:cap:ro', 'RO', 'pin', 'eu', 15, 8000),
('pin:cap:ru', 'RU', 'pin', 'eu', 15, 8000),
('pin:cap:sm', 'SM', 'pin', 'eu', 15, 8000),
('pin:cap:rs', 'RS', 'pin', 'eu', 15, 8000),
('pin:cap:sk', 'SK', 'pin', 'eu', 15, 8000),
('pin:cap:si', 'SI', 'pin', 'eu', 15, 8000),
('pin:cap:es', 'ES', 'pin', 'eu', 15, 8000),
('pin:cap:se', 'SE', 'pin', 'eu', 15, 8000),
('pin:cap:ch', 'CH', 'pin', 'eu', 15, 8000),
('pin:cap:ua', 'UA', 'pin', 'eu', 15, 8000),
('pin:cap:gb', 'GB', 'pin', 'eu', 15, 8000),
('pin:cap:ag', 'AG', 'pin', 'na', 15, 8000),
('pin:cap:bs', 'BS', 'pin', 'na', 15, 8000),
('pin:cap:bb', 'BB', 'pin', 'na', 15, 8000),
('pin:cap:bz', 'BZ', 'pin', 'na', 15, 8000),
('pin:cap:ca', 'CA', 'pin', 'na', 15, 8000),
('pin:cap:cr', 'CR', 'pin', 'na', 15, 8000),
('pin:cap:cu', 'CU', 'pin', 'na', 15, 8000),
('pin:cap:dm', 'DM', 'pin', 'na', 15, 8000),
('pin:cap:do', 'DO', 'pin', 'na', 15, 8000),
('pin:cap:sv', 'SV', 'pin', 'na', 15, 8000),
('pin:cap:gd', 'GD', 'pin', 'na', 15, 8000),
('pin:cap:gt', 'GT', 'pin', 'na', 15, 8000),
('pin:cap:ht', 'HT', 'pin', 'na', 15, 8000),
('pin:cap:hn', 'HN', 'pin', 'na', 15, 8000),
('pin:cap:jm', 'JM', 'pin', 'na', 15, 8000),
('pin:cap:mx', 'MX', 'pin', 'na', 15, 8000),
('pin:cap:ni', 'NI', 'pin', 'na', 15, 8000),
('pin:cap:pa', 'PA', 'pin', 'na', 15, 8000),
('pin:cap:kn', 'KN', 'pin', 'na', 15, 8000),
('pin:cap:lc', 'LC', 'pin', 'na', 15, 8000),
('pin:cap:vc', 'VC', 'pin', 'na', 15, 8000),
('pin:cap:tt', 'TT', 'pin', 'na', 15, 8000),
('pin:cap:us', 'US', 'pin', 'na', 15, 8000),
('pin:cap:ar', 'AR', 'pin', 'sa', 15, 8000),
('pin:cap:bo', 'BO', 'pin', 'sa', 15, 8000),
('pin:cap:br', 'BR', 'pin', 'sa', 15, 8000),
('pin:cap:cl', 'CL', 'pin', 'sa', 15, 8000),
('pin:cap:co', 'CO', 'pin', 'sa', 15, 8000),
('pin:cap:ec', 'EC', 'pin', 'sa', 15, 8000),
('pin:cap:gy', 'GY', 'pin', 'sa', 15, 8000),
('pin:cap:py', 'PY', 'pin', 'sa', 15, 8000),
('pin:cap:pe', 'PE', 'pin', 'sa', 15, 8000),
('pin:cap:sr', 'SR', 'pin', 'sa', 15, 8000),
('pin:cap:uy', 'UY', 'pin', 'sa', 15, 8000),
('pin:cap:ve', 'VE', 'pin', 'sa', 15, 8000),
('pin:cap:au', 'AU', 'pin', 'oc', 15, 8000),
('pin:cap:fj', 'FJ', 'pin', 'oc', 15, 8000),
('pin:cap:ki', 'KI', 'pin', 'oc', 15, 8000),
('pin:cap:mh', 'MH', 'pin', 'oc', 15, 8000),
('pin:cap:fm', 'FM', 'pin', 'oc', 15, 8000),
('pin:cap:nr', 'NR', 'pin', 'oc', 15, 8000),
('pin:cap:nz', 'NZ', 'pin', 'oc', 15, 8000),
('pin:cap:pw', 'PW', 'pin', 'oc', 15, 8000),
('pin:cap:pg', 'PG', 'pin', 'oc', 15, 8000),
('pin:cap:ws', 'WS', 'pin', 'oc', 15, 8000),
('pin:cap:sb', 'SB', 'pin', 'oc', 15, 8000),
('pin:cap:to', 'TO', 'pin', 'oc', 15, 8000),
('pin:cap:tv', 'TV', 'pin', 'oc', 15, 8000),
('pin:cap:vu', 'VU', 'pin', 'oc', 15, 8000),
('pin:city:new-york', 'US', 'pin', 'na', 15, 8000),
('pin:city:los-angeles', 'US', 'pin', 'na', 15, 8000),
('pin:city:chicago', 'US', 'pin', 'na', 15, 8000),
('pin:city:san-francisco', 'US', 'pin', 'na', 15, 8000),
('pin:city:miami', 'US', 'pin', 'na', 15, 8000),
('pin:city:las-vegas', 'US', 'pin', 'na', 15, 8000),
('pin:city:orlando', 'US', 'pin', 'na', 15, 8000),
('pin:city:boston', 'US', 'pin', 'na', 15, 8000),
('pin:city:seattle', 'US', 'pin', 'na', 15, 8000),
('pin:city:houston', 'US', 'pin', 'na', 15, 8000),
('pin:city:toronto', 'CA', 'pin', 'na', 15, 8000),
('pin:city:vancouver', 'CA', 'pin', 'na', 15, 8000),
('pin:city:philadelphia', 'US', 'pin', 'na', 15, 8000),
('pin:city:dallas', 'US', 'pin', 'na', 15, 8000),
('pin:city:denver', 'US', 'pin', 'na', 15, 8000),
('pin:city:atlanta', 'US', 'pin', 'na', 15, 8000),
('pin:city:detroit', 'US', 'pin', 'na', 15, 8000),
('pin:city:san-diego', 'US', 'pin', 'na', 15, 8000),
('pin:city:new-orleans', 'US', 'pin', 'na', 15, 8000),
('pin:city:phoenix', 'US', 'pin', 'na', 15, 8000),
('pin:city:nashville', 'US', 'pin', 'na', 15, 8000),
('pin:city:montreal', 'CA', 'pin', 'na', 15, 8000),
('pin:city:calgary', 'CA', 'pin', 'na', 15, 8000),
('pin:city:quebec-city', 'CA', 'pin', 'na', 15, 8000),
('pin:city:cancun', 'MX', 'pin', 'na', 15, 8000),
('pin:city:guadalajara', 'MX', 'pin', 'na', 15, 8000),
('pin:city:acapulco', 'MX', 'pin', 'na', 15, 8000),
('pin:city:monterrey', 'MX', 'pin', 'na', 15, 8000),
('pin:city:halifax', 'CA', 'pin', 'na', 15, 8000),
('pin:city:montego-bay', 'JM', 'pin', 'na', 15, 8000),
('pin:city:rio-de-janeiro', 'BR', 'pin', 'sa', 15, 8000),
('pin:city:sao-paulo', 'BR', 'pin', 'sa', 15, 8000),
('pin:city:salvador', 'BR', 'pin', 'sa', 15, 8000),
('pin:city:manaus', 'BR', 'pin', 'sa', 15, 8000),
('pin:city:cusco', 'PE', 'pin', 'sa', 15, 8000),
('pin:city:medellin', 'CO', 'pin', 'sa', 15, 8000),
('pin:city:cartagena', 'CO', 'pin', 'sa', 15, 8000),
('pin:city:ushuaia', 'AR', 'pin', 'sa', 15, 8000),
('pin:city:valparaiso', 'CL', 'pin', 'sa', 15, 8000),
('pin:city:guayaquil', 'EC', 'pin', 'sa', 15, 8000),
('pin:city:cordoba', 'AR', 'pin', 'sa', 15, 8000),
('pin:city:mendoza', 'AR', 'pin', 'sa', 15, 8000),
('pin:city:recife', 'BR', 'pin', 'sa', 15, 8000),
('pin:city:fortaleza', 'BR', 'pin', 'sa', 15, 8000),
('pin:city:cali', 'CO', 'pin', 'sa', 15, 8000),
('pin:city:arequipa', 'PE', 'pin', 'sa', 15, 8000),
('pin:city:punta-arenas', 'CL', 'pin', 'sa', 15, 8000),
('pin:city:maracaibo', 'VE', 'pin', 'sa', 15, 8000),
('pin:city:barcelona', 'ES', 'pin', 'eu', 15, 8000),
('pin:city:venice', 'IT', 'pin', 'eu', 15, 8000),
('pin:city:milan', 'IT', 'pin', 'eu', 15, 8000),
('pin:city:florence', 'IT', 'pin', 'eu', 15, 8000),
('pin:city:munich', 'DE', 'pin', 'eu', 15, 8000),
('pin:city:manchester', 'GB', 'pin', 'eu', 15, 8000),
('pin:city:liverpool', 'GB', 'pin', 'eu', 15, 8000),
('pin:city:saint-petersburg', 'RU', 'pin', 'eu', 15, 8000),
('pin:city:edinburgh', 'GB', 'pin', 'eu', 15, 8000),
('pin:city:oxford', 'GB', 'pin', 'eu', 15, 8000),
('pin:city:naples', 'IT', 'pin', 'eu', 15, 8000),
('pin:city:pisa', 'IT', 'pin', 'eu', 15, 8000),
('pin:city:hamburg', 'DE', 'pin', 'eu', 15, 8000),
('pin:city:frankfurt', 'DE', 'pin', 'eu', 15, 8000),
('pin:city:marseille', 'FR', 'pin', 'eu', 15, 8000),
('pin:city:nice', 'FR', 'pin', 'eu', 15, 8000),
('pin:city:geneva', 'CH', 'pin', 'eu', 15, 8000),
('pin:city:zurich', 'CH', 'pin', 'eu', 15, 8000),
('pin:city:salzburg', 'AT', 'pin', 'eu', 15, 8000),
('pin:city:seville', 'ES', 'pin', 'eu', 15, 8000),
('pin:city:valencia', 'ES', 'pin', 'eu', 15, 8000),
('pin:city:porto', 'PT', 'pin', 'eu', 15, 8000),
('pin:city:rotterdam', 'NL', 'pin', 'eu', 15, 8000),
('pin:city:krakow', 'PL', 'pin', 'eu', 15, 8000),
('pin:city:turin', 'IT', 'pin', 'eu', 15, 8000),
('pin:city:verona', 'IT', 'pin', 'eu', 15, 8000),
('pin:city:cologne', 'DE', 'pin', 'eu', 15, 8000),
('pin:city:lyon', 'FR', 'pin', 'eu', 15, 8000),
('pin:city:bordeaux', 'FR', 'pin', 'eu', 15, 8000),
('pin:city:antwerp', 'BE', 'pin', 'eu', 15, 8000),
('pin:city:gothenburg', 'SE', 'pin', 'eu', 15, 8000),
('pin:city:malaga', 'ES', 'pin', 'eu', 15, 8000),
('pin:city:birmingham', 'GB', 'pin', 'eu', 15, 8000),
('pin:city:glasgow', 'GB', 'pin', 'eu', 15, 8000),
('pin:city:thessaloniki', 'GR', 'pin', 'eu', 15, 8000),
('pin:city:odesa', 'UA', 'pin', 'eu', 15, 8000),
('pin:city:dubrovnik', 'HR', 'pin', 'eu', 15, 8000),
('pin:city:hong-kong', 'CN', 'pin', 'as', 15, 8000),
('pin:city:shanghai', 'CN', 'pin', 'as', 15, 8000),
('pin:city:dubai', 'AE', 'pin', 'as', 15, 8000),
('pin:city:mumbai', 'IN', 'pin', 'as', 15, 8000),
('pin:city:istanbul', 'TR', 'pin', 'as', 15, 8000),
('pin:city:osaka', 'JP', 'pin', 'as', 15, 8000),
('pin:city:kyoto', 'JP', 'pin', 'as', 15, 8000),
('pin:city:hiroshima', 'JP', 'pin', 'as', 15, 8000),
('pin:city:yokohama', 'JP', 'pin', 'as', 15, 8000),
('pin:city:busan', 'KR', 'pin', 'as', 15, 8000),
('pin:city:agra', 'IN', 'pin', 'as', 15, 8000),
('pin:city:kolkata', 'IN', 'pin', 'as', 15, 8000),
('pin:city:karachi', 'PK', 'pin', 'as', 15, 8000),
('pin:city:mecca', 'SA', 'pin', 'as', 15, 8000),
('pin:city:ho-chi-minh-city', 'VN', 'pin', 'as', 15, 8000),
('pin:city:tel-aviv', 'IL', 'pin', 'as', 15, 8000),
('pin:city:shenzhen', 'CN', 'pin', 'as', 15, 8000),
('pin:city:almaty', 'KZ', 'pin', 'as', 15, 8000),
('pin:city:samarkand', 'UZ', 'pin', 'as', 15, 8000),
('pin:city:chennai', 'IN', 'pin', 'as', 15, 8000),
('pin:city:jaipur', 'IN', 'pin', 'as', 15, 8000),
('pin:city:guangzhou', 'CN', 'pin', 'as', 15, 8000),
('pin:city:xi-an', 'CN', 'pin', 'as', 15, 8000),
('pin:city:chengdu', 'CN', 'pin', 'as', 15, 8000),
('pin:city:sapporo', 'JP', 'pin', 'as', 15, 8000),
('pin:city:lahore', 'PK', 'pin', 'as', 15, 8000),
('pin:city:chiang-mai', 'TH', 'pin', 'as', 15, 8000),
('pin:city:siem-reap', 'KH', 'pin', 'as', 15, 8000),
('pin:city:isfahan', 'IR', 'pin', 'as', 15, 8000),
('pin:city:mandalay', 'MM', 'pin', 'as', 15, 8000),
('pin:city:jeddah', 'SA', 'pin', 'as', 15, 8000),
('pin:city:marrakesh', 'MA', 'pin', 'af', 15, 8000),
('pin:city:casablanca', 'MA', 'pin', 'af', 15, 8000),
('pin:city:johannesburg', 'ZA', 'pin', 'af', 15, 8000),
('pin:city:alexandria', 'EG', 'pin', 'af', 15, 8000),
('pin:city:timbuktu', 'ML', 'pin', 'af', 15, 8000),
('pin:city:lagos', 'NG', 'pin', 'af', 15, 8000),
('pin:city:luxor', 'EG', 'pin', 'af', 15, 8000),
('pin:city:durban', 'ZA', 'pin', 'af', 15, 8000),
('pin:city:mombasa', 'KE', 'pin', 'af', 15, 8000),
('pin:city:zanzibar-city', 'TZ', 'pin', 'af', 15, 8000),
('pin:city:fez', 'MA', 'pin', 'af', 15, 8000),
('pin:city:tangier', 'MA', 'pin', 'af', 15, 8000),
('pin:city:aswan', 'EG', 'pin', 'af', 15, 8000),
('pin:city:kano', 'NG', 'pin', 'af', 15, 8000),
('pin:city:arusha', 'TZ', 'pin', 'af', 15, 8000),
('pin:city:douala', 'CM', 'pin', 'af', 15, 8000),
('pin:city:kumasi', 'GH', 'pin', 'af', 15, 8000),
('pin:city:bulawayo', 'ZW', 'pin', 'af', 15, 8000),
('pin:city:sydney', 'AU', 'pin', 'oc', 15, 8000),
('pin:city:melbourne', 'AU', 'pin', 'oc', 15, 8000),
('pin:city:brisbane', 'AU', 'pin', 'oc', 15, 8000),
('pin:city:perth', 'AU', 'pin', 'oc', 15, 8000),
('pin:city:auckland', 'NZ', 'pin', 'oc', 15, 8000),
('pin:city:adelaide', 'AU', 'pin', 'oc', 15, 8000),
('pin:city:gold-coast', 'AU', 'pin', 'oc', 15, 8000),
('pin:city:cairns', 'AU', 'pin', 'oc', 15, 8000),
('pin:city:darwin', 'AU', 'pin', 'oc', 15, 8000),
('pin:city:alice-springs', 'AU', 'pin', 'oc', 15, 8000),
('pin:city:hobart', 'AU', 'pin', 'oc', 15, 8000),
('pin:city:christchurch', 'NZ', 'pin', 'oc', 15, 8000),
('pin:city:queenstown', 'NZ', 'pin', 'oc', 15, 8000)
ON CONFLICT (card_key) DO UPDATE SET
  iso = EXCLUDED.iso, kind = EXCLUDED.kind, continent = EXCLUDED.continent,
  points = EXCLUDED.points, target_ms = EXCLUDED.target_ms
  WHERE geo_cards.kind IN ('find', 'pin');


-- 3. When a round reached geo_history

ALTER TABLE geo_pin_rounds ADD COLUMN IF NOT EXISTS mastery_at TIMESTAMPTZ;


-- 4. Judging and writing
--
-- A place pin's grade: 2 for Bullseye or Great, 1 for Close, 0 for Off, Way
-- off, a give-up (NULL km) or an unknown continent. lib/geo-pin.ts
-- pinVerdict, same thresholds, same double arithmetic. Keep them in step.

CREATE OR REPLACE FUNCTION geo_pin_grade(p_cont TEXT, p_km DOUBLE PRECISION)
RETURNS INT
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT COALESCE((
    SELECT CASE
             WHEN p_km IS NULL THEN 0
             WHEN p_km <= v.bull OR p_km <= v.zero * 0.2::DOUBLE PRECISION THEN 2
             WHEN p_km <= v.zero * 0.4::DOUBLE PRECISION THEN 1
             ELSE 0
           END
      FROM (VALUES ('af', 110::DOUBLE PRECISION, 1400::DOUBLE PRECISION), ('as', 120::DOUBLE PRECISION, 1500::DOUBLE PRECISION), ('eu', 50::DOUBLE PRECISION, 650::DOUBLE PRECISION), ('na', 80::DOUBLE PRECISION, 1000::DOUBLE PRECISION), ('sa', 80::DOUBLE PRECISION, 1000::DOUBLE PRECISION), ('oc', 90::DOUBLE PRECISION, 1200::DOUBLE PRECISION)) AS v(cont, bull, zero)
     WHERE v.cont = p_cont
  ), 0)
$$;

-- One round's taps into geo_history, with record_geo_answer's rules (069):
-- right = a find, or a pin graded 1 or 2. Fast = a find or a grade-2 pin,
-- in at least 200 ms (under that is not a person) and within the card's
-- target_ms. times_correct or times_wrong goes up by one, best_ms only
-- improves, fluent_at is set the first time a card is fast and never
-- cleared. p_mode is 'country' (answers {i: iso, h: hit, ms}) or 'place'
-- (answers {i: place key, km, ms}), as the round functions store them.
-- p_at is when (now() for a new round, the round's own time in the
-- backfill). Taps on a card the catalogue lacks are skipped. Returns how
-- many cards this round mastered for the first time.

CREATE OR REPLACE FUNCTION geo_pin_master(p_user UUID, p_cont TEXT, p_mode TEXT, p_answers JSONB, p_at TIMESTAMPTZ)
RETURNS INT
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE
  n INT;
BEGIN
  IF p_user IS NULL OR p_mode IS NULL OR p_mode NOT IN ('country', 'place')
     OR jsonb_typeof(p_answers) IS DISTINCT FROM 'array' THEN
    RETURN 0;
  END IF;

  WITH a AS (
    SELECT DISTINCT ON (k.card_key) k.card_key, k.grade, k.ms
      FROM (
        SELECT e.ord,
               CASE WHEN p_mode = 'country' THEN 'find:' || lower(e.v ->> 'i') ELSE 'pin:' || lower(e.v ->> 'i') END AS card_key,
               CASE WHEN p_mode = 'country'
                    THEN CASE WHEN COALESCE((e.v ->> 'h')::BOOLEAN, FALSE) THEN 2 ELSE 0 END
                    ELSE geo_pin_grade(p_cont, (e.v ->> 'km')::DOUBLE PRECISION)
               END AS grade,
               (e.v ->> 'ms')::INT AS ms
          FROM jsonb_array_elements(p_answers) WITH ORDINALITY AS e(v, ord)
      ) k
     ORDER BY k.card_key, k.ord
  ),
  j AS (
    SELECT a.card_key, a.ms, a.grade > 0 AS correct,
           COALESCE(a.grade = 2 AND a.ms BETWEEN 200 AND c.target_ms, FALSE) AS fast
      FROM a
      JOIN geo_cards c ON c.card_key = a.card_key
                      AND c.kind = CASE WHEN p_mode = 'country' THEN 'find' ELSE 'pin' END
  ),
  up AS (
    INSERT INTO geo_history AS h
      (user_id, card_key, times_correct, times_wrong, best_ms, last_ms, fluent_at, last_answered_at)
    SELECT p_user, j.card_key,
           CASE WHEN j.correct THEN 1 ELSE 0 END,
           CASE WHEN j.correct THEN 0 ELSE 1 END,
           CASE WHEN j.correct AND j.ms >= 200 THEN j.ms END,
           j.ms,
           CASE WHEN j.fast THEN p_at END,
           p_at
      FROM j
    ON CONFLICT (user_id, card_key) DO UPDATE SET
      times_correct    = h.times_correct + EXCLUDED.times_correct,
      times_wrong      = h.times_wrong   + EXCLUDED.times_wrong,
      best_ms          = CASE WHEN EXCLUDED.best_ms IS NOT NULL
                           THEN LEAST(COALESCE(h.best_ms, EXCLUDED.best_ms), EXCLUDED.best_ms) ELSE h.best_ms END,
      last_ms          = EXCLUDED.last_ms,
      fluent_at        = COALESCE(h.fluent_at, EXCLUDED.fluent_at),
      last_answered_at = GREATEST(h.last_answered_at, EXCLUDED.last_answered_at)
    RETURNING h.card_key
  )
  -- Every part of one statement sees the table as it was before it, so this
  -- counts cards that were not mastered until this round.
  SELECT COUNT(*) INTO n
    FROM j
   WHERE j.fast
     AND NOT EXISTS (SELECT 1 FROM geo_history g
                      WHERE g.user_id = p_user AND g.card_key = j.card_key AND g.fluent_at IS NOT NULL);
  RETURN n;
END;
$$;

REVOKE ALL ON FUNCTION geo_pin_grade(TEXT, DOUBLE PRECISION) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION geo_pin_master(UUID, TEXT, TEXT, JSONB, TIMESTAMPTZ) FROM PUBLIC, anon, authenticated;


-- 5. The round functions: 073's, plus mastery
--
-- Copied from 073 by the generator. The only change in each is the line that
-- saves the round, which now also records mastery_at, and the call to
-- geo_pin_master after it. The score and the INT returned are as before.

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
           e.v ->> 'i'                AS place,
           (e.v ->> 'lat')::DOUBLE PRECISION AS lat,
           (e.v ->> 'lon')::DOUBLE PRECISION AS lon,
           (e.v ->> 'ms')::INT        AS ms
      FROM jsonb_array_elements(p_pins) WITH ORDINALITY AS e(v, ord)
  ),
  dist AS (
    SELECT p.ord, p.place, p.ms,
           CASE WHEN p.lat IS NULL OR p.lon IS NULL THEN NULL
                ELSE 2 * 6371 * asin(least(1, sqrt(
                       power(sin(radians(p.lat - g.lat) / 2), 2)
                       + cos(radians(g.lat)) * cos(radians(p.lat)) * power(sin(radians(p.lon - g.lon) / 2), 2))))
           END AS km,
           (p.lat IS NOT NULL AND NOT p.lat BETWEEN -90 AND 90)
             OR (p.lon IS NOT NULL AND NOT p.lon BETWEEN -180 AND 180)
             OR ((p.lat IS NULL) <> (p.lon IS NULL)) AS out_of_range
      FROM pins p
      JOIN geo_pin_places g ON g.place_key = p.place AND g.continent = cont
  ),
  pts AS (
    SELECT d.*, geo_pin_points(cont, d.km, d.ms) AS points FROM dist d
  )
  SELECT COUNT(DISTINCT place), COUNT(*) FILTER (WHERE out_of_range), COALESCE(SUM(points), 0),
         jsonb_agg(jsonb_build_object('i', place, 'km', km, 'ms', ms, 'p', points) ORDER BY ord)
    INTO places, bad, total, scored
    FROM pts;

  IF places <> 10 THEN
    RAISE EXCEPTION 'a pin round needs 10 different places of its continent';
  END IF;
  IF bad > 0 THEN
    RAISE EXCEPTION 'pin outside the map';
  END IF;

  INSERT INTO geo_pin_rounds (user_id, deck, score, answers, mastery_at) VALUES (uid, p_deck, total, scored, now());
  PERFORM geo_pin_master(uid, cont, 'place', scored, now());
  RETURN total;
END;
$$;

REVOKE ALL ON FUNCTION record_geo_pin_round(TEXT, JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION record_geo_pin_round(TEXT, JSONB) TO authenticated;

CREATE OR REPLACE FUNCTION record_geo_country_round(p_deck TEXT, p_pins JSONB)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid    UUID := auth.uid();
  cont   TEXT;
  n_iso  INT;
  bad    INT;
  total  INT;
  scored JSONB;
  tiny   TEXT[] := geo_pin_tiny_isos();
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'record_geo_country_round requires a signed-in user';
  END IF;
  IF p_deck IS NULL OR p_deck NOT IN (
    SELECT c || ':' || l || ':country' FROM unnest(ARRAY['af', 'as', 'eu', 'na', 'sa', 'oc']) AS c, unnest(ARRAY['1', '2', '3']) AS l
  ) THEN
    RAISE EXCEPTION 'unknown pin deck %', p_deck;
  END IF;
  cont := split_part(p_deck, ':', 1);
  IF jsonb_typeof(p_pins) IS DISTINCT FROM 'array' OR jsonb_array_length(p_pins) <> 10 THEN
    RAISE EXCEPTION 'a country round has 10 countries';
  END IF;

  WITH pins AS (
    SELECT e.ord,
           e.v ->> 'iso'              AS iso,
           e.v ->> 'tap'              AS tap,
           (e.v ->> 'lat')::DOUBLE PRECISION AS lat,
           (e.v ->> 'lon')::DOUBLE PRECISION AS lon,
           (e.v ->> 'ms')::INT        AS ms
      FROM jsonb_array_elements(p_pins) WITH ORDINALITY AS e(v, ord)
  ),
  judged AS (
    SELECT p.*,
           CASE WHEN p.lat IS NULL OR p.lon IS NULL THEN NULL
                ELSE 2 * 6371 * asin(least(1, sqrt(
                       power(sin(radians(p.lat - g.lat) / 2), 2)
                       + cos(radians(g.lat)) * cos(radians(p.lat)) * power(sin(radians(p.lon - g.lon) / 2), 2))))
           END AS km,
           (p.lat IS NOT NULL AND NOT p.lat BETWEEN -90 AND 90)
             OR (p.lon IS NOT NULL AND NOT p.lon BETWEEN -180 AND 180)
             OR ((p.lat IS NULL) <> (p.lon IS NULL))
             OR (p.tap IS NOT NULL AND p.lat IS NULL)
             OR (p.tap IS NOT NULL AND (length(p.tap) NOT BETWEEN 2 AND 3 OR p.tap ~ '[^A-Z]')) AS out_of_range
      FROM pins p
      JOIN geo_pin_places g ON g.kind = 'capital' AND g.iso = p.iso AND g.continent = cont
  ),
  hits AS (
    SELECT j.*,
           COALESCE(j.lat IS NOT NULL AND (
             j.tap = j.iso
             OR (j.iso = ANY (tiny) AND (j.tap IS NULL OR NOT (j.tap = ANY (tiny))) AND j.km <= 75)
             OR EXISTS (SELECT 1 FROM geo_disputed_areas a
                         WHERE a.drawn = j.tap AND j.iso = ANY (a.claimants)
                           AND (a.ring IS NULL OR geo_in_ring(j.lon, j.lat, a.ring)))
           ), FALSE) AS hit
      FROM judged j
  ),
  pts AS (
    SELECT h.*, CASE WHEN h.hit THEN 100 + geo_pin_speed(h.ms) ELSE 0 END AS points FROM hits h
  )
  SELECT COUNT(DISTINCT iso), COUNT(*) FILTER (WHERE out_of_range), COALESCE(SUM(points), 0),
         jsonb_agg(jsonb_build_object('i', iso, 't', tap, 'h', hit, 'ms', ms, 'p', points) ORDER BY ord)
    INTO n_iso, bad, total, scored
    FROM pts;

  IF n_iso <> 10 THEN
    RAISE EXCEPTION 'a country round needs 10 different countries of its continent';
  END IF;
  IF bad > 0 THEN
    RAISE EXCEPTION 'tap outside the map';
  END IF;

  INSERT INTO geo_pin_rounds (user_id, deck, score, answers, mastery_at) VALUES (uid, p_deck, total, scored, now());
  PERFORM geo_pin_master(uid, cont, 'country', scored, now());
  RETURN total;
END;
$$;

REVOKE ALL ON FUNCTION record_geo_country_round(TEXT, JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION record_geo_country_round(TEXT, JSONB) TO authenticated;


-- 6. Badges

INSERT INTO achievement_definitions (key, label, icon_emoji, description, rarity, creature, category, lore, threshold) VALUES

('geo_find_25', 'Country Seeker', convert_from(decode('8J+Ujg==', 'base64'), 'UTF8'), '25 Find the country cards mastered.', 'Uncommon', 'Country Seeker', 'Geography',
 'Twenty-five countries found on a map with no names on it. The Seeker squints, taps once and is right, and has started covering up the labels on every map it meets.', 25),

('geo_find_all', 'Pathfinder', convert_from(decode('8J+UjvCfkZE=', 'base64'), 'UTF8'), 'All 192 Find the country cards mastered.', 'Legendary', 'Pathfinder', 'Geography',
 'Every country Find the country asks, each found with one quick tap, from Russia down to Tuvalu. The Pathfinder could find Liechtenstein in the dark and once did, to win a bet.', 192),

('geo_pin_25', 'Sharp Pin', convert_from(decode('8J+TjQ==', 'base64'), 'UTF8'), '25 Pin the map places mastered.', 'Uncommon', 'Sharp Pin', 'Geography',
 'Twenty-five capitals and cities pinned so close the map barely noticed. The Sharp Pin keeps a tiny flag in its pocket for each one.', 25),

('geo_pin_all', 'Grand Cartographer', convert_from(decode('8J+TjfCfkZE=', 'base64'), 'UTF8'), 'All 340 Pin the map places mastered.', 'Legendary', 'Grand Cartographer', 'Geography',
 'Every capital and every famous city on the list, pinned Great or better without a single label to help. The Grand Cartographer draws maps for fun, and they are better than most.', 340)

ON CONFLICT (key) DO UPDATE SET
  label = EXCLUDED.label, icon_emoji = EXCLUDED.icon_emoji,
  description = EXCLUDED.description, rarity = EXCLUDED.rarity,
  creature = EXCLUDED.creature, category = EXCLUDED.category,
  lore = EXCLUDED.lore, threshold = EXCLUDED.threshold;

-- The every-card and continent badges count the new cards too.
UPDATE achievement_definitions SET description = 'Every one of the 1819 Geography cards mastered.', threshold = 1819 WHERE key = 'geo_mastered_all';
UPDATE achievement_definitions SET description = '204 Africa cards mastered, half of them.', threshold = 204 WHERE key = 'geo_continent_af_half';
UPDATE achievement_definitions SET description = 'All 409 Africa cards mastered: capitals, flags, shapes, cities, countries found and places pinned.', threshold = 409 WHERE key = 'geo_continent_af';
UPDATE achievement_definitions SET description = '191 Asia cards mastered, half of them.', threshold = 191 WHERE key = 'geo_continent_as_half';
UPDATE achievement_definitions SET description = 'All 383 Asia cards mastered: capitals, flags, shapes, cities, countries found and places pinned.', threshold = 383 WHERE key = 'geo_continent_as';
UPDATE achievement_definitions SET description = '185 Europe cards mastered, half of them.', threshold = 185 WHERE key = 'geo_continent_eu_half';
UPDATE achievement_definitions SET description = 'All 371 Europe cards mastered: capitals, flags, shapes, cities, countries found and places pinned.', threshold = 371 WHERE key = 'geo_continent_eu';
UPDATE achievement_definitions SET description = '110 North America cards mastered, half of them.', threshold = 110 WHERE key = 'geo_continent_na_half';
UPDATE achievement_definitions SET description = 'All 221 North America cards mastered: capitals, flags, shapes, cities, countries found and places pinned.', threshold = 221 WHERE key = 'geo_continent_na';
UPDATE achievement_definitions SET description = '59 South America cards mastered, half of them.', threshold = 59 WHERE key = 'geo_continent_sa_half';
UPDATE achievement_definitions SET description = 'All 118 South America cards mastered: capitals, flags, shapes, cities, countries found and places pinned.', threshold = 118 WHERE key = 'geo_continent_sa';
UPDATE achievement_definitions SET description = '62 Oceania cards mastered, half of them.', threshold = 62 WHERE key = 'geo_continent_oc_half';
UPDATE achievement_definitions SET description = 'All 124 Oceania cards mastered: capitals, flags, shapes, cities, countries found and places pinned.', threshold = 124 WHERE key = 'geo_continent_oc';


-- 7. Awarding: 072's function, plus the find and pin rungs and the new halves

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
     WHERE NOT EXISTS (SELECT 1 FROM g WHERE continent = ct AND kind <> 'cont' AND NOT fluent)
    UNION ALL
    SELECT 'geo_continent_' || r.ct || '_' || r.step
      FROM (VALUES ('af', '25', 25), ('af', 'half', 204),
                   ('as', '25', 25), ('as', 'half', 191),
                   ('eu', '25', 25), ('eu', 'half', 185),
                   ('na', '25', 25), ('na', 'half', 110),
                   ('sa', '25', 25), ('sa', 'half', 59),
                   ('oc', '25', 25), ('oc', 'half', 62)) AS r(ct, step, t)
     WHERE (SELECT COUNT(*) FROM g WHERE continent = r.ct AND kind <> 'cont' AND fluent) >= r.t
    UNION ALL
    SELECT 'geo_' || r.grp || '_' || r.t
      FROM (VALUES ('capitals', ARRAY['cap', 'capr'], 25), ('flags', ARRAY['flag', 'flagr'], 25), ('money', ARRAY['cur'], 25), ('languages', ARRAY['lang'], 25), ('continents', ARRAY['cont'], 25), ('shapes', ARRAY['shape'], 25), ('cities', ARRAY['city'], 25), ('find', ARRAY['find'], 25), ('pin', ARRAY['pin'], 25)) AS r(grp, kinds, t)
     WHERE (SELECT COUNT(*) FROM g WHERE kind = ANY (r.kinds) AND fluent) >= r.t
    UNION ALL
    SELECT 'geo_' || r.grp || '_all'
      FROM (VALUES ('capitals', ARRAY['cap', 'capr']), ('flags', ARRAY['flag', 'flagr']), ('money', ARRAY['cur']), ('languages', ARRAY['lang']), ('continents', ARRAY['cont']), ('shapes', ARRAY['shape']), ('cities', ARRAY['city']), ('find', ARRAY['find']), ('pin', ARRAY['pin'])) AS r(grp, kinds)
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


-- 8. Backfill: every round saved before this migration masters its cards
--
-- Oldest first, each at its own time, through the same geo_pin_master the
-- round functions use, so a backfilled card is exactly what playing that
-- round today would have given. Places rounds saved before 073 stored whole
-- km, so a pin within half a km of a verdict line may be graded as the
-- other side of it. Only rounds with no mastery_at are taken, and each is
-- marked as it goes: a second run finds none.

DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT id, user_id, deck, answers, completed_at FROM geo_pin_rounds
     WHERE mastery_at IS NULL
     ORDER BY completed_at, id
  LOOP
    IF r.deck IN (SELECT c || ':' || l || ':country' FROM unnest(ARRAY['af', 'as', 'eu', 'na', 'sa', 'oc']) AS c, unnest(ARRAY['1', '2', '3']) AS l) THEN
      PERFORM geo_pin_master(r.user_id, split_part(r.deck, ':', 1), 'country', r.answers, r.completed_at);
    ELSIF r.deck IN (SELECT c || ':' || l FROM unnest(ARRAY['af', 'as', 'eu', 'na', 'sa', 'oc']) AS c, unnest(ARRAY['1', '2', '3']) AS l) THEN
      PERFORM geo_pin_master(r.user_id, split_part(r.deck, ':', 1), 'place', r.answers, r.completed_at);
    END IF;
    UPDATE geo_pin_rounds SET mastery_at = now() WHERE id = r.id;
  END LOOP;
END $$;


-- 9. Award what the backfill earned

DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN SELECT DISTINCT user_id FROM geo_history LOOP
    PERFORM award_geo_badges_for(r.user_id, FALSE);
  END LOOP;
END $$;


-- Verification
--
-- Expected: find_cards 192, pin_cards 340, cards 1819, max_points 21725,
--           pin_cards_without_place 0, places_without_pin_card 0,
--           orphan_history 0, geo_badges 39, unfed_rounds 0,
--           find_pin_history (any number: one row per student per find or
--           pin card ever played), find_pin_mastered (any number, at most
--           find_pin_history),
--           helpers_callable_by_students false, master_callable_by_anon false,
--           rounds_callable_by_anon false, rounds_callable_by_students true,
--           history_insert_by_students false.

SELECT
  (SELECT COUNT(*) FROM geo_cards WHERE kind = 'find')                    AS find_cards,
  (SELECT COUNT(*) FROM geo_cards WHERE kind = 'pin')                     AS pin_cards,
  (SELECT COUNT(*) FROM geo_cards)                                        AS cards,
  (SELECT SUM(points) FROM geo_cards)                                     AS max_points,
  (SELECT COUNT(*) FROM geo_cards c WHERE c.kind = 'pin'
    AND NOT EXISTS (SELECT 1 FROM geo_pin_places p WHERE 'pin:' || p.place_key = c.card_key)) AS pin_cards_without_place,
  (SELECT COUNT(*) FROM geo_pin_places p
    WHERE NOT EXISTS (SELECT 1 FROM geo_cards c WHERE c.card_key = 'pin:' || p.place_key)) AS places_without_pin_card,
  (SELECT COUNT(*) FROM geo_history h
    WHERE NOT EXISTS (SELECT 1 FROM geo_cards c WHERE c.card_key = h.card_key)) AS orphan_history,
  (SELECT COUNT(*) FROM achievement_definitions WHERE category = 'Geography') AS geo_badges,
  (SELECT COUNT(*) FROM geo_pin_rounds WHERE mastery_at IS NULL)          AS unfed_rounds,
  (SELECT COUNT(*) FROM geo_history h JOIN geo_cards c ON c.card_key = h.card_key
    WHERE c.kind IN ('find', 'pin'))                                      AS find_pin_history,
  (SELECT COUNT(*) FROM geo_history h JOIN geo_cards c ON c.card_key = h.card_key
    WHERE c.kind IN ('find', 'pin') AND h.fluent_at IS NOT NULL)          AS find_pin_mastered,
  has_function_privilege('authenticated', 'geo_pin_master(uuid, text, text, jsonb, timestamp with time zone)', 'EXECUTE')
    OR has_function_privilege('authenticated', 'geo_pin_grade(text, double precision)', 'EXECUTE')
    OR has_function_privilege('authenticated', 'award_geo_badges_for(uuid, boolean)', 'EXECUTE') AS helpers_callable_by_students,
  has_function_privilege('anon', 'geo_pin_master(uuid, text, text, jsonb, timestamp with time zone)', 'EXECUTE')
    OR has_function_privilege('anon', 'geo_pin_grade(text, double precision)', 'EXECUTE') AS master_callable_by_anon,
  has_function_privilege('anon', 'record_geo_pin_round(text, jsonb)', 'EXECUTE')
    OR has_function_privilege('anon', 'record_geo_country_round(text, jsonb)', 'EXECUTE') AS rounds_callable_by_anon,
  has_function_privilege('authenticated', 'record_geo_pin_round(text, jsonb)', 'EXECUTE')
    AND has_function_privilege('authenticated', 'record_geo_country_round(text, jsonb)', 'EXECUTE') AS rounds_callable_by_students,
  has_table_privilege('authenticated', 'geo_history', 'INSERT')
    OR has_table_privilege('authenticated', 'geo_history', 'UPDATE')      AS history_insert_by_students;
