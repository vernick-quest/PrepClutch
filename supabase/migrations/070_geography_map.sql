-- 070 — Geography map: Name that country, famous cities, Pin the map
--
-- Phase 2 of Geography (069 is phase 1 and must be applied first). Additive:
-- nothing here changes or removes an existing card, history row or award.
--
--   geo_cards                 + 175 "Name that country" cards, kind
--                             'shape', one per UN member, 15 Explorer
--                             Points each, mastered within 8 s
--                             + 147 "Which country is Rio de Janeiro in?"
--                             cards, kind 'city', one per famous city (not
--                             capitals, lib/geo-cities.ts), 10 points,
--                             mastered within 7 s. Inserted only: the
--                             069 cards are not touched.
--   badges                    + Shape Spotter (25 shapes), Map Master (all
--                             175), City Hopper (25 cities), Globetrotter
--                             (all 147)
--   award_geo_badges_for      069's function copied exactly, with the shapes
--                             and cities rungs added to its two card-type
--                             lists. Still revoked from students.
--   badge descriptions        World Turtle and the six continent badges count
--                             every card, so they now include shape and city
--                             cards: their descriptions and thresholds are
--                             updated to the new totals. Nobody loses a badge.
--   geo_pin_places            the 340 places Pin the map can ask (193
--                             capitals, 147 cities), keyed 'cap:ke' or
--                             'city:rio-de-janeiro', with their coordinates and
--                             level (read-only)
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


-- ── 1. The new cards: Name that country (shape) and famous cities (city) ─────
--
-- City cards are keyed by the city ('city:rio-de-janeiro'); iso and
-- continent are its country's. The WHERE below means a re-run can only ever
-- update cards of the new kinds, never a 069 card.

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
('shape:mz', 'MZ', 'shape', 'af', 15, 8000),
('shape:na', 'NA', 'shape', 'af', 15, 8000),
('shape:ne', 'NE', 'shape', 'af', 15, 8000),
('shape:ng', 'NG', 'shape', 'af', 15, 8000),
('shape:rw', 'RW', 'shape', 'af', 15, 8000),
('shape:st', 'ST', 'shape', 'af', 15, 8000),
('shape:sn', 'SN', 'shape', 'af', 15, 8000),
('shape:sc', 'SC', 'shape', 'af', 15, 8000),
('shape:sl', 'SL', 'shape', 'af', 15, 8000),
('shape:za', 'ZA', 'shape', 'af', 15, 8000),
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
('shape:id', 'ID', 'shape', 'as', 15, 8000),
('shape:ir', 'IR', 'shape', 'as', 15, 8000),
('shape:iq', 'IQ', 'shape', 'as', 15, 8000),
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
('shape:mc', 'MC', 'shape', 'eu', 15, 8000),
('shape:me', 'ME', 'shape', 'eu', 15, 8000),
('shape:nl', 'NL', 'shape', 'eu', 15, 8000),
('shape:mk', 'MK', 'shape', 'eu', 15, 8000),
('shape:no', 'NO', 'shape', 'eu', 15, 8000),
('shape:pl', 'PL', 'shape', 'eu', 15, 8000),
('shape:pt', 'PT', 'shape', 'eu', 15, 8000),
('shape:ro', 'RO', 'shape', 'eu', 15, 8000),
('shape:sm', 'SM', 'shape', 'eu', 15, 8000),
('shape:sk', 'SK', 'shape', 'eu', 15, 8000),
('shape:si', 'SI', 'shape', 'eu', 15, 8000),
('shape:es', 'ES', 'shape', 'eu', 15, 8000),
('shape:se', 'SE', 'shape', 'eu', 15, 8000),
('shape:ch', 'CH', 'shape', 'eu', 15, 8000),
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
('shape:py', 'PY', 'shape', 'sa', 15, 8000),
('shape:pe', 'PE', 'shape', 'sa', 15, 8000),
('shape:sr', 'SR', 'shape', 'sa', 15, 8000),
('shape:uy', 'UY', 'shape', 'sa', 15, 8000),
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
('shape:vu', 'VU', 'shape', 'oc', 15, 8000),
('city:new-york', 'US', 'city', 'na', 10, 7000),
('city:los-angeles', 'US', 'city', 'na', 10, 7000),
('city:chicago', 'US', 'city', 'na', 10, 7000),
('city:san-francisco', 'US', 'city', 'na', 10, 7000),
('city:miami', 'US', 'city', 'na', 10, 7000),
('city:las-vegas', 'US', 'city', 'na', 10, 7000),
('city:orlando', 'US', 'city', 'na', 10, 7000),
('city:boston', 'US', 'city', 'na', 10, 7000),
('city:seattle', 'US', 'city', 'na', 10, 7000),
('city:houston', 'US', 'city', 'na', 10, 7000),
('city:toronto', 'CA', 'city', 'na', 10, 7000),
('city:vancouver', 'CA', 'city', 'na', 10, 7000),
('city:philadelphia', 'US', 'city', 'na', 10, 7000),
('city:dallas', 'US', 'city', 'na', 10, 7000),
('city:denver', 'US', 'city', 'na', 10, 7000),
('city:atlanta', 'US', 'city', 'na', 10, 7000),
('city:detroit', 'US', 'city', 'na', 10, 7000),
('city:san-diego', 'US', 'city', 'na', 10, 7000),
('city:new-orleans', 'US', 'city', 'na', 10, 7000),
('city:phoenix', 'US', 'city', 'na', 10, 7000),
('city:nashville', 'US', 'city', 'na', 10, 7000),
('city:montreal', 'CA', 'city', 'na', 10, 7000),
('city:calgary', 'CA', 'city', 'na', 10, 7000),
('city:quebec-city', 'CA', 'city', 'na', 10, 7000),
('city:cancun', 'MX', 'city', 'na', 10, 7000),
('city:guadalajara', 'MX', 'city', 'na', 10, 7000),
('city:acapulco', 'MX', 'city', 'na', 10, 7000),
('city:monterrey', 'MX', 'city', 'na', 10, 7000),
('city:halifax', 'CA', 'city', 'na', 10, 7000),
('city:montego-bay', 'JM', 'city', 'na', 10, 7000),
('city:rio-de-janeiro', 'BR', 'city', 'sa', 10, 7000),
('city:sao-paulo', 'BR', 'city', 'sa', 10, 7000),
('city:salvador', 'BR', 'city', 'sa', 10, 7000),
('city:manaus', 'BR', 'city', 'sa', 10, 7000),
('city:cusco', 'PE', 'city', 'sa', 10, 7000),
('city:medellin', 'CO', 'city', 'sa', 10, 7000),
('city:cartagena', 'CO', 'city', 'sa', 10, 7000),
('city:ushuaia', 'AR', 'city', 'sa', 10, 7000),
('city:valparaiso', 'CL', 'city', 'sa', 10, 7000),
('city:guayaquil', 'EC', 'city', 'sa', 10, 7000),
('city:cordoba', 'AR', 'city', 'sa', 10, 7000),
('city:mendoza', 'AR', 'city', 'sa', 10, 7000),
('city:recife', 'BR', 'city', 'sa', 10, 7000),
('city:fortaleza', 'BR', 'city', 'sa', 10, 7000),
('city:cali', 'CO', 'city', 'sa', 10, 7000),
('city:arequipa', 'PE', 'city', 'sa', 10, 7000),
('city:punta-arenas', 'CL', 'city', 'sa', 10, 7000),
('city:maracaibo', 'VE', 'city', 'sa', 10, 7000),
('city:barcelona', 'ES', 'city', 'eu', 10, 7000),
('city:venice', 'IT', 'city', 'eu', 10, 7000),
('city:milan', 'IT', 'city', 'eu', 10, 7000),
('city:florence', 'IT', 'city', 'eu', 10, 7000),
('city:munich', 'DE', 'city', 'eu', 10, 7000),
('city:manchester', 'GB', 'city', 'eu', 10, 7000),
('city:liverpool', 'GB', 'city', 'eu', 10, 7000),
('city:saint-petersburg', 'RU', 'city', 'eu', 10, 7000),
('city:edinburgh', 'GB', 'city', 'eu', 10, 7000),
('city:oxford', 'GB', 'city', 'eu', 10, 7000),
('city:naples', 'IT', 'city', 'eu', 10, 7000),
('city:pisa', 'IT', 'city', 'eu', 10, 7000),
('city:hamburg', 'DE', 'city', 'eu', 10, 7000),
('city:frankfurt', 'DE', 'city', 'eu', 10, 7000),
('city:marseille', 'FR', 'city', 'eu', 10, 7000),
('city:nice', 'FR', 'city', 'eu', 10, 7000),
('city:geneva', 'CH', 'city', 'eu', 10, 7000),
('city:zurich', 'CH', 'city', 'eu', 10, 7000),
('city:salzburg', 'AT', 'city', 'eu', 10, 7000),
('city:seville', 'ES', 'city', 'eu', 10, 7000),
('city:valencia', 'ES', 'city', 'eu', 10, 7000),
('city:porto', 'PT', 'city', 'eu', 10, 7000),
('city:rotterdam', 'NL', 'city', 'eu', 10, 7000),
('city:krakow', 'PL', 'city', 'eu', 10, 7000),
('city:turin', 'IT', 'city', 'eu', 10, 7000),
('city:verona', 'IT', 'city', 'eu', 10, 7000),
('city:cologne', 'DE', 'city', 'eu', 10, 7000),
('city:lyon', 'FR', 'city', 'eu', 10, 7000),
('city:bordeaux', 'FR', 'city', 'eu', 10, 7000),
('city:antwerp', 'BE', 'city', 'eu', 10, 7000),
('city:gothenburg', 'SE', 'city', 'eu', 10, 7000),
('city:malaga', 'ES', 'city', 'eu', 10, 7000),
('city:birmingham', 'GB', 'city', 'eu', 10, 7000),
('city:glasgow', 'GB', 'city', 'eu', 10, 7000),
('city:thessaloniki', 'GR', 'city', 'eu', 10, 7000),
('city:odesa', 'UA', 'city', 'eu', 10, 7000),
('city:dubrovnik', 'HR', 'city', 'eu', 10, 7000),
('city:hong-kong', 'CN', 'city', 'as', 10, 7000),
('city:shanghai', 'CN', 'city', 'as', 10, 7000),
('city:dubai', 'AE', 'city', 'as', 10, 7000),
('city:mumbai', 'IN', 'city', 'as', 10, 7000),
('city:istanbul', 'TR', 'city', 'as', 10, 7000),
('city:osaka', 'JP', 'city', 'as', 10, 7000),
('city:kyoto', 'JP', 'city', 'as', 10, 7000),
('city:hiroshima', 'JP', 'city', 'as', 10, 7000),
('city:yokohama', 'JP', 'city', 'as', 10, 7000),
('city:busan', 'KR', 'city', 'as', 10, 7000),
('city:agra', 'IN', 'city', 'as', 10, 7000),
('city:kolkata', 'IN', 'city', 'as', 10, 7000),
('city:karachi', 'PK', 'city', 'as', 10, 7000),
('city:mecca', 'SA', 'city', 'as', 10, 7000),
('city:ho-chi-minh-city', 'VN', 'city', 'as', 10, 7000),
('city:tel-aviv', 'IL', 'city', 'as', 10, 7000),
('city:shenzhen', 'CN', 'city', 'as', 10, 7000),
('city:almaty', 'KZ', 'city', 'as', 10, 7000),
('city:samarkand', 'UZ', 'city', 'as', 10, 7000),
('city:chennai', 'IN', 'city', 'as', 10, 7000),
('city:jaipur', 'IN', 'city', 'as', 10, 7000),
('city:guangzhou', 'CN', 'city', 'as', 10, 7000),
('city:xi-an', 'CN', 'city', 'as', 10, 7000),
('city:chengdu', 'CN', 'city', 'as', 10, 7000),
('city:sapporo', 'JP', 'city', 'as', 10, 7000),
('city:lahore', 'PK', 'city', 'as', 10, 7000),
('city:chiang-mai', 'TH', 'city', 'as', 10, 7000),
('city:siem-reap', 'KH', 'city', 'as', 10, 7000),
('city:isfahan', 'IR', 'city', 'as', 10, 7000),
('city:mandalay', 'MM', 'city', 'as', 10, 7000),
('city:jeddah', 'SA', 'city', 'as', 10, 7000),
('city:marrakesh', 'MA', 'city', 'af', 10, 7000),
('city:casablanca', 'MA', 'city', 'af', 10, 7000),
('city:johannesburg', 'ZA', 'city', 'af', 10, 7000),
('city:alexandria', 'EG', 'city', 'af', 10, 7000),
('city:timbuktu', 'ML', 'city', 'af', 10, 7000),
('city:lagos', 'NG', 'city', 'af', 10, 7000),
('city:luxor', 'EG', 'city', 'af', 10, 7000),
('city:durban', 'ZA', 'city', 'af', 10, 7000),
('city:mombasa', 'KE', 'city', 'af', 10, 7000),
('city:zanzibar-city', 'TZ', 'city', 'af', 10, 7000),
('city:fez', 'MA', 'city', 'af', 10, 7000),
('city:tangier', 'MA', 'city', 'af', 10, 7000),
('city:aswan', 'EG', 'city', 'af', 10, 7000),
('city:kano', 'NG', 'city', 'af', 10, 7000),
('city:arusha', 'TZ', 'city', 'af', 10, 7000),
('city:douala', 'CM', 'city', 'af', 10, 7000),
('city:kumasi', 'GH', 'city', 'af', 10, 7000),
('city:bulawayo', 'ZW', 'city', 'af', 10, 7000),
('city:sydney', 'AU', 'city', 'oc', 10, 7000),
('city:melbourne', 'AU', 'city', 'oc', 10, 7000),
('city:brisbane', 'AU', 'city', 'oc', 10, 7000),
('city:perth', 'AU', 'city', 'oc', 10, 7000),
('city:auckland', 'NZ', 'city', 'oc', 10, 7000),
('city:adelaide', 'AU', 'city', 'oc', 10, 7000),
('city:gold-coast', 'AU', 'city', 'oc', 10, 7000),
('city:cairns', 'AU', 'city', 'oc', 10, 7000),
('city:darwin', 'AU', 'city', 'oc', 10, 7000),
('city:alice-springs', 'AU', 'city', 'oc', 10, 7000),
('city:hobart', 'AU', 'city', 'oc', 10, 7000),
('city:christchurch', 'NZ', 'city', 'oc', 10, 7000),
('city:queenstown', 'NZ', 'city', 'oc', 10, 7000)
ON CONFLICT (card_key) DO UPDATE SET
  iso = EXCLUDED.iso, kind = EXCLUDED.kind, continent = EXCLUDED.continent,
  points = EXCLUDED.points, target_ms = EXCLUDED.target_ms
  WHERE geo_cards.kind IN ('shape', 'city');


-- ── 2. Badge definitions ─────────────────────────────────────────────────────

INSERT INTO achievement_definitions (key, label, icon_emoji, description, rarity, creature, category, lore, threshold) VALUES

('geo_shapes_25', 'Shape Spotter', '🧩', '25 Name that country cards mastered.', 'Uncommon', 'Shape Spotter', 'Geography',
 'Twenty-five countries named from their outline alone. The Spotter sees a boot and says Italy, sees a long thin ribbon and says Chile, and is now looking suspiciously at clouds.', 25),

('geo_shapes_all', 'Map Master', '🗺️👑', 'All 175 Name that country cards mastered.', 'Legendary', 'Map Master', 'Geography',
 'Every country on Earth, named from its shape on the map, from Russia down to Tuvalu. The Map Master could draw the world from memory and would only argue a little about the borders.', 175),

('geo_cities_25', 'City Hopper', '🏙️', '25 city cards mastered.', 'Uncommon', 'City Hopper', 'Geography',
 'Twenty-five famous cities, each put in the right country. The Hopper has ridden a gondola in Venice, a tram in Melbourne and a cable car in San Francisco, all before lunch.', 25),

('geo_cities_all', 'Globetrotter', '🏙️👑', 'All 147 city cards mastered.', 'Epic', 'Globetrotter', 'Geography',
 'Every famous city on the list, from New York to Timbuktu, put in the right country. The Globetrotter has a suitcase covered in stickers and still wants to visit them all again.', 147)

ON CONFLICT (key) DO UPDATE SET
  label = EXCLUDED.label, icon_emoji = EXCLUDED.icon_emoji,
  description = EXCLUDED.description, rarity = EXCLUDED.rarity,
  creature = EXCLUDED.creature, category = EXCLUDED.category,
  lore = EXCLUDED.lore, threshold = EXCLUDED.threshold;

-- Every-card badges now count the shape and city cards too.
UPDATE achievement_definitions SET description = 'Every one of the 1287 Geography cards mastered.', threshold = 1287 WHERE key = 'geo_mastered_all';
UPDATE achievement_definitions SET description = 'All 337 Africa cards mastered.', threshold = 337 WHERE key = 'geo_continent_af';
UPDATE achievement_definitions SET description = 'All 306 Asia cards mastered.', threshold = 306 WHERE key = 'geo_continent_as';
UPDATE achievement_definitions SET description = 'All 291 Europe cards mastered.', threshold = 291 WHERE key = 'geo_continent_eu';
UPDATE achievement_definitions SET description = 'All 168 North America cards mastered.', threshold = 168 WHERE key = 'geo_continent_na';
UPDATE achievement_definitions SET description = 'All 88 South America cards mastered.', threshold = 88 WHERE key = 'geo_continent_sa';
UPDATE achievement_definitions SET description = 'All 97 Oceania cards mastered.', threshold = 97 WHERE key = 'geo_continent_oc';


-- ── 3. Awarding: 069's function, plus the shapes and cities rungs ────────────

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
      FROM (VALUES ('capitals', ARRAY['cap', 'capr'], 25), ('flags', ARRAY['flag', 'flagr'], 25), ('money', ARRAY['cur'], 25), ('languages', ARRAY['lang'], 25), ('continents', ARRAY['cont'], 25), ('shapes', ARRAY['shape'], 25), ('cities', ARRAY['city'], 25)) AS r(grp, kinds, t)
     WHERE (SELECT COUNT(*) FROM g WHERE kind = ANY (r.kinds) AND fluent) >= r.t
    UNION ALL
    SELECT 'geo_' || r.grp || '_all'
      FROM (VALUES ('capitals', ARRAY['cap', 'capr']), ('flags', ARRAY['flag', 'flagr']), ('money', ARRAY['cur']), ('languages', ARRAY['lang']), ('continents', ARRAY['cont']), ('shapes', ARRAY['shape']), ('cities', ARRAY['city'])) AS r(grp, kinds)
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

-- A capital ('cap:ke', the asked capital of Kenya) or a famous city
-- ('city:rio-de-janeiro'). iso and continent are the country's. tier is the
-- Pin the map level the place belongs to (lib/geo.ts pinPlaces).

CREATE TABLE IF NOT EXISTS geo_pin_places (
  place_key TEXT PRIMARY KEY,
  kind      TEXT NOT NULL CHECK (kind IN ('capital', 'city')),
  name      TEXT NOT NULL,
  iso       TEXT NOT NULL,
  continent TEXT NOT NULL,
  tier      INT  NOT NULL CHECK (tier BETWEEN 1 AND 3),
  lat       DOUBLE PRECISION NOT NULL CHECK (lat BETWEEN -90 AND 90),
  lon       DOUBLE PRECISION NOT NULL CHECK (lon BETWEEN -180 AND 180)
);

ALTER TABLE geo_pin_places ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "geo_pin_places_readable" ON geo_pin_places;
CREATE POLICY "geo_pin_places_readable" ON geo_pin_places FOR SELECT USING (TRUE);
REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON geo_pin_places FROM anon, authenticated;
GRANT SELECT ON geo_pin_places TO anon, authenticated;

INSERT INTO geo_pin_places (place_key, kind, name, iso, continent, tier, lat, lon) VALUES
('cap:dz', 'capital', 'Algiers', 'DZ', 'af', 1, 36.78, 3.06),
('cap:ao', 'capital', 'Luanda', 'AO', 'af', 1, -8.84, 13.23),
('cap:bj', 'capital', 'Porto-Novo', 'BJ', 'af', 2, 6.48, 2.62),
('cap:bw', 'capital', 'Gaborone', 'BW', 'af', 3, -24.66, 25.91),
('cap:bf', 'capital', 'Ouagadougou', 'BF', 'af', 2, 12.37, -1.53),
('cap:bi', 'capital', 'Gitega', 'BI', 'af', 2, -3.43, 29.93),
('cap:cv', 'capital', 'Praia', 'CV', 'af', 3, 14.92, -23.51),
('cap:cm', 'capital', 'Yaoundé', 'CM', 'af', 1, 3.86, 11.52),
('cap:cf', 'capital', 'Bangui', 'CF', 'af', 3, 4.37, 18.56),
('cap:td', 'capital', 'N''Djamena', 'TD', 'af', 2, 12.11, 15.05),
('cap:km', 'capital', 'Moroni', 'KM', 'af', 3, -11.7, 43.25),
('cap:cg', 'capital', 'Brazzaville', 'CG', 'af', 3, -4.27, 15.27),
('cap:cd', 'capital', 'Kinshasa', 'CD', 'af', 1, -4.32, 15.31),
('cap:ci', 'capital', 'Yamoussoukro', 'CI', 'af', 1, 6.82, -5.27),
('cap:dj', 'capital', 'Djibouti', 'DJ', 'af', 3, 11.6, 43.15),
('cap:eg', 'capital', 'Cairo', 'EG', 'af', 1, 30.04, 31.24),
('cap:gq', 'capital', 'Ciudad de la Paz', 'GQ', 'af', 3, 1.59, 10.82),
('cap:er', 'capital', 'Asmara', 'ER', 'af', 2, 15.33, 38.92),
('cap:sz', 'capital', 'Mbabane', 'SZ', 'af', 3, -26.32, 31.13),
('cap:et', 'capital', 'Addis Ababa', 'ET', 'af', 1, 9.04, 38.75),
('cap:ga', 'capital', 'Libreville', 'GA', 'af', 3, 0.41, 9.44),
('cap:gm', 'capital', 'Banjul', 'GM', 'af', 3, 13.45, -16.58),
('cap:gh', 'capital', 'Accra', 'GH', 'af', 1, 5.56, -0.2),
('cap:gn', 'capital', 'Conakry', 'GN', 'af', 2, 9.51, -13.71),
('cap:gw', 'capital', 'Bissau', 'GW', 'af', 3, 11.86, -15.58),
('cap:ke', 'capital', 'Nairobi', 'KE', 'af', 1, -1.29, 36.82),
('cap:ls', 'capital', 'Maseru', 'LS', 'af', 3, -29.31, 27.48),
('cap:lr', 'capital', 'Monrovia', 'LR', 'af', 3, 6.31, -10.8),
('cap:ly', 'capital', 'Tripoli', 'LY', 'af', 2, 32.89, 13.19),
('cap:mg', 'capital', 'Antananarivo', 'MG', 'af', 1, -18.91, 47.53),
('cap:mw', 'capital', 'Lilongwe', 'MW', 'af', 2, -13.99, 33.77),
('cap:ml', 'capital', 'Bamako', 'ML', 'af', 2, 12.65, -7.99),
('cap:mr', 'capital', 'Nouakchott', 'MR', 'af', 3, 18.09, -15.98),
('cap:mu', 'capital', 'Port Louis', 'MU', 'af', 3, -20.16, 57.5),
('cap:ma', 'capital', 'Rabat', 'MA', 'af', 1, 34.02, -6.84),
('cap:mz', 'capital', 'Maputo', 'MZ', 'af', 1, -25.97, 32.57),
('cap:na', 'capital', 'Windhoek', 'NA', 'af', 3, -22.57, 17.08),
('cap:ne', 'capital', 'Niamey', 'NE', 'af', 1, 13.52, 2.12),
('cap:ng', 'capital', 'Abuja', 'NG', 'af', 1, 9.06, 7.49),
('cap:rw', 'capital', 'Kigali', 'RW', 'af', 2, -1.95, 30.12),
('cap:st', 'capital', 'São Tomé', 'ST', 'af', 3, 0.34, 6.73),
('cap:sn', 'capital', 'Dakar', 'SN', 'af', 2, 14.67, -17.43),
('cap:sc', 'capital', 'Victoria', 'SC', 'af', 3, -4.62, 55.45),
('cap:sl', 'capital', 'Freetown', 'SL', 'af', 2, 8.49, -13.24),
('cap:so', 'capital', 'Mogadishu', 'SO', 'af', 2, 2.04, 45.34),
('cap:za', 'capital', 'Pretoria', 'ZA', 'af', 1, -25.75, 28.19),
('cap:ss', 'capital', 'Juba', 'SS', 'af', 2, 4.85, 31.58),
('cap:sd', 'capital', 'Khartoum', 'SD', 'af', 1, 15.6, 32.53),
('cap:tz', 'capital', 'Dodoma', 'TZ', 'af', 1, -6.18, 35.75),
('cap:tg', 'capital', 'Lomé', 'TG', 'af', 2, 6.13, 1.22),
('cap:tn', 'capital', 'Tunis', 'TN', 'af', 2, 36.8, 10.18),
('cap:ug', 'capital', 'Kampala', 'UG', 'af', 1, 0.31, 32.58),
('cap:zm', 'capital', 'Lusaka', 'ZM', 'af', 2, -15.42, 28.28),
('cap:zw', 'capital', 'Harare', 'ZW', 'af', 2, -17.83, 31.05),
('cap:af', 'capital', 'Kabul', 'AF', 'as', 1, 34.53, 69.17),
('cap:am', 'capital', 'Yerevan', 'AM', 'as', 3, 40.18, 44.51),
('cap:az', 'capital', 'Baku', 'AZ', 'as', 2, 40.37, 49.84),
('cap:bh', 'capital', 'Manama', 'BH', 'as', 3, 26.22, 50.58),
('cap:bd', 'capital', 'Dhaka', 'BD', 'as', 1, 23.73, 90.39),
('cap:bt', 'capital', 'Thimphu', 'BT', 'as', 3, 27.47, 89.63),
('cap:bn', 'capital', 'Bandar Seri Begawan', 'BN', 'as', 3, 4.92, 114.92),
('cap:kh', 'capital', 'Phnom Penh', 'KH', 'as', 2, 11.57, 104.92),
('cap:cn', 'capital', 'Beijing', 'CN', 'as', 1, 39.9, 116.41),
('cap:cy', 'capital', 'Nicosia', 'CY', 'as', 3, 35.17, 33.37),
('cap:ge', 'capital', 'Tbilisi', 'GE', 'as', 3, 41.72, 44.79),
('cap:in', 'capital', 'New Delhi', 'IN', 'as', 1, 28.61, 77.21),
('cap:id', 'capital', 'Jakarta', 'ID', 'as', 1, -6.18, 106.83),
('cap:ir', 'capital', 'Tehran', 'IR', 'as', 1, 35.69, 51.39),
('cap:iq', 'capital', 'Baghdad', 'IQ', 'as', 1, 33.32, 44.37),
('cap:il', 'capital', 'Jerusalem', 'IL', 'as', 2, 31.78, 35.23),
('cap:jp', 'capital', 'Tokyo', 'JP', 'as', 1, 35.69, 139.69),
('cap:jo', 'capital', 'Amman', 'JO', 'as', 2, 31.93, 35.93),
('cap:kz', 'capital', 'Astana', 'KZ', 'as', 2, 51.13, 71.43),
('cap:kw', 'capital', 'Kuwait City', 'KW', 'as', 3, 29.38, 47.98),
('cap:kg', 'capital', 'Bishkek', 'KG', 'as', 3, 42.87, 74.57),
('cap:la', 'capital', 'Vientiane', 'LA', 'as', 2, 17.98, 102.63),
('cap:lb', 'capital', 'Beirut', 'LB', 'as', 2, 33.89, 35.51),
('cap:my', 'capital', 'Kuala Lumpur', 'MY', 'as', 2, 3.15, 101.7),
('cap:mv', 'capital', 'Malé', 'MV', 'as', 3, 4.18, 73.51),
('cap:mn', 'capital', 'Ulaanbaatar', 'MN', 'as', 3, 47.92, 106.91),
('cap:mm', 'capital', 'Naypyidaw', 'MM', 'as', 1, 19.75, 96.12),
('cap:np', 'capital', 'Kathmandu', 'NP', 'as', 2, 27.71, 85.32),
('cap:kp', 'capital', 'Pyongyang', 'KP', 'as', 2, 39.02, 125.75),
('cap:om', 'capital', 'Muscat', 'OM', 'as', 3, 23.61, 58.59),
('cap:pk', 'capital', 'Islamabad', 'PK', 'as', 1, 33.7, 73.04),
('cap:ph', 'capital', 'Manila', 'PH', 'as', 1, 14.6, 120.98),
('cap:qa', 'capital', 'Doha', 'QA', 'as', 3, 25.29, 51.53),
('cap:sa', 'capital', 'Riyadh', 'SA', 'as', 1, 24.65, 46.71),
('cap:sg', 'capital', 'Singapore', 'SG', 'as', 3, 1.3, 103.8),
('cap:kr', 'capital', 'Seoul', 'KR', 'as', 1, 37.56, 126.99),
('cap:lk', 'capital', 'Colombo', 'LK', 'as', 2, 6.93, 79.86),
('cap:sy', 'capital', 'Damascus', 'SY', 'as', 2, 33.51, 36.29),
('cap:tj', 'capital', 'Dushanbe', 'TJ', 'as', 2, 38.57, 68.79),
('cap:th', 'capital', 'Bangkok', 'TH', 'as', 1, 13.75, 100.52),
('cap:tl', 'capital', 'Dili', 'TL', 'as', 3, -8.55, 125.58),
('cap:tr', 'capital', 'Ankara', 'TR', 'as', 1, 39.94, 32.84),
('cap:tm', 'capital', 'Ashgabat', 'TM', 'as', 3, 37.95, 58.38),
('cap:ae', 'capital', 'Abu Dhabi', 'AE', 'as', 2, 24.45, 54.4),
('cap:uz', 'capital', 'Tashkent', 'UZ', 'as', 2, 41.31, 69.28),
('cap:vn', 'capital', 'Hanoi', 'VN', 'as', 1, 21.02, 105.84),
('cap:ye', 'capital', 'Sanaa', 'YE', 'as', 2, 15.35, 44.2),
('cap:al', 'capital', 'Tirana', 'AL', 'eu', 2, 41.33, 19.82),
('cap:ad', 'capital', 'Andorra la Vella', 'AD', 'eu', 3, 42.51, 1.52),
('cap:at', 'capital', 'Vienna', 'AT', 'eu', 2, 48.21, 16.37),
('cap:by', 'capital', 'Minsk', 'BY', 'eu', 2, 53.9, 27.56),
('cap:be', 'capital', 'Brussels', 'BE', 'eu', 1, 50.85, 4.35),
('cap:ba', 'capital', 'Sarajevo', 'BA', 'eu', 2, 43.86, 18.41),
('cap:bg', 'capital', 'Sofia', 'BG', 'eu', 2, 42.7, 23.32),
('cap:hr', 'capital', 'Zagreb', 'HR', 'eu', 2, 45.81, 15.98),
('cap:cz', 'capital', 'Prague', 'CZ', 'eu', 1, 50.09, 14.42),
('cap:dk', 'capital', 'Copenhagen', 'DK', 'eu', 2, 55.68, 12.57),
('cap:ee', 'capital', 'Tallinn', 'EE', 'eu', 3, 59.44, 24.75),
('cap:fi', 'capital', 'Helsinki', 'FI', 'eu', 2, 60.17, 24.94),
('cap:fr', 'capital', 'Paris', 'FR', 'eu', 1, 48.86, 2.35),
('cap:de', 'capital', 'Berlin', 'DE', 'eu', 1, 52.52, 13.38),
('cap:gr', 'capital', 'Athens', 'GR', 'eu', 1, 37.98, 23.73),
('cap:hu', 'capital', 'Budapest', 'HU', 'eu', 2, 47.5, 19.04),
('cap:is', 'capital', 'Reykjavík', 'IS', 'eu', 3, 64.15, -21.93),
('cap:ie', 'capital', 'Dublin', 'IE', 'eu', 2, 53.35, -6.26),
('cap:it', 'capital', 'Rome', 'IT', 'eu', 1, 41.89, 12.48),
('cap:lv', 'capital', 'Riga', 'LV', 'eu', 3, 56.95, 24.11),
('cap:li', 'capital', 'Vaduz', 'LI', 'eu', 3, 47.14, 9.52),
('cap:lt', 'capital', 'Vilnius', 'LT', 'eu', 3, 54.69, 25.28),
('cap:lu', 'capital', 'Luxembourg', 'LU', 'eu', 3, 49.61, 6.13),
('cap:mt', 'capital', 'Valletta', 'MT', 'eu', 3, 35.9, 14.51),
('cap:md', 'capital', 'Chișinău', 'MD', 'eu', 3, 47.02, 28.84),
('cap:mc', 'capital', 'Monaco', 'MC', 'eu', 3, 43.73, 7.42),
('cap:me', 'capital', 'Podgorica', 'ME', 'eu', 3, 42.44, 19.26),
('cap:nl', 'capital', 'Amsterdam', 'NL', 'eu', 1, 52.37, 4.88),
('cap:mk', 'capital', 'Skopje', 'MK', 'eu', 3, 42, 21.43),
('cap:no', 'capital', 'Oslo', 'NO', 'eu', 2, 59.91, 10.74),
('cap:pl', 'capital', 'Warsaw', 'PL', 'eu', 1, 52.23, 21.01),
('cap:pt', 'capital', 'Lisbon', 'PT', 'eu', 1, 38.71, -9.14),
('cap:ro', 'capital', 'Bucharest', 'RO', 'eu', 1, 44.41, 26.1),
('cap:ru', 'capital', 'Moscow', 'RU', 'eu', 1, 55.75, 37.62),
('cap:sm', 'capital', 'San Marino', 'SM', 'eu', 3, 43.93, 12.45),
('cap:rs', 'capital', 'Belgrade', 'RS', 'eu', 2, 44.82, 20.46),
('cap:sk', 'capital', 'Bratislava', 'SK', 'eu', 2, 48.15, 17.11),
('cap:si', 'capital', 'Ljubljana', 'SI', 'eu', 3, 46.05, 14.51),
('cap:es', 'capital', 'Madrid', 'ES', 'eu', 1, 40.42, -3.7),
('cap:se', 'capital', 'Stockholm', 'SE', 'eu', 1, 59.33, 18.07),
('cap:ch', 'capital', 'Bern', 'CH', 'eu', 2, 46.95, 7.45),
('cap:ua', 'capital', 'Kyiv', 'UA', 'eu', 1, 50.45, 30.52),
('cap:gb', 'capital', 'London', 'GB', 'eu', 1, 51.51, -0.13),
('cap:ag', 'capital', 'St. John''s', 'AG', 'na', 3, 17.12, -61.84),
('cap:bs', 'capital', 'Nassau', 'BS', 'na', 2, 25.08, -77.34),
('cap:bb', 'capital', 'Bridgetown', 'BB', 'na', 3, 13.1, -59.62),
('cap:bz', 'capital', 'Belmopan', 'BZ', 'na', 2, 17.25, -88.77),
('cap:ca', 'capital', 'Ottawa', 'CA', 'na', 1, 45.42, -75.69),
('cap:cr', 'capital', 'San José', 'CR', 'na', 2, 9.93, -84.08),
('cap:cu', 'capital', 'Havana', 'CU', 'na', 1, 23.14, -82.36),
('cap:dm', 'capital', 'Roseau', 'DM', 'na', 3, 15.3, -61.38),
('cap:do', 'capital', 'Santo Domingo', 'DO', 'na', 1, 18.46, -69.94),
('cap:sv', 'capital', 'San Salvador', 'SV', 'na', 2, 13.7, -89.19),
('cap:gd', 'capital', 'St. George''s', 'GD', 'na', 3, 12.05, -61.75),
('cap:gt', 'capital', 'Guatemala City', 'GT', 'na', 1, 14.64, -90.51),
('cap:ht', 'capital', 'Port-au-Prince', 'HT', 'na', 1, 18.55, -72.34),
('cap:hn', 'capital', 'Tegucigalpa', 'HN', 'na', 1, 14.11, -87.2),
('cap:jm', 'capital', 'Kingston', 'JM', 'na', 2, 17.97, -76.79),
('cap:mx', 'capital', 'Mexico City', 'MX', 'na', 1, 19.35, -99.14),
('cap:ni', 'capital', 'Managua', 'NI', 'na', 2, 12.15, -86.27),
('cap:pa', 'capital', 'Panama City', 'PA', 'na', 2, 8.97, -79.53),
('cap:kn', 'capital', 'Basseterre', 'KN', 'na', 3, 17.3, -62.73),
('cap:lc', 'capital', 'Castries', 'LC', 'na', 3, 14.01, -60.99),
('cap:vc', 'capital', 'Kingstown', 'VC', 'na', 3, 13.16, -61.23),
('cap:tt', 'capital', 'Port of Spain', 'TT', 'na', 2, 10.67, -61.52),
('cap:us', 'capital', 'Washington, D.C.', 'US', 'na', 1, 38.9, -77.04),
('cap:ar', 'capital', 'Buenos Aires', 'AR', 'sa', 1, -34.6, -58.38),
('cap:bo', 'capital', 'Sucre', 'BO', 'sa', 2, -19.05, -65.26),
('cap:br', 'capital', 'Brasília', 'BR', 'sa', 1, -15.79, -47.88),
('cap:cl', 'capital', 'Santiago', 'CL', 'sa', 2, -33.44, -70.65),
('cap:co', 'capital', 'Bogotá', 'CO', 'sa', 1, 4.61, -74.08),
('cap:ec', 'capital', 'Quito', 'EC', 'sa', 2, -0.22, -78.51),
('cap:gy', 'capital', 'Georgetown', 'GY', 'sa', 3, 6.81, -58.15),
('cap:py', 'capital', 'Asunción', 'PY', 'sa', 3, -25.28, -57.63),
('cap:pe', 'capital', 'Lima', 'PE', 'sa', 1, -12.06, -77.04),
('cap:sr', 'capital', 'Paramaribo', 'SR', 'sa', 3, 5.87, -55.17),
('cap:uy', 'capital', 'Montevideo', 'UY', 'sa', 3, -34.91, -56.19),
('cap:ve', 'capital', 'Caracas', 'VE', 'sa', 2, 10.51, -66.91),
('cap:au', 'capital', 'Canberra', 'AU', 'oc', 1, -35.29, 149.13),
('cap:fj', 'capital', 'Suva', 'FJ', 'oc', 1, -18.13, 178.43),
('cap:ki', 'capital', 'South Tarawa', 'KI', 'oc', 2, 1.33, 172.97),
('cap:mh', 'capital', 'Majuro', 'MH', 'oc', 3, 7.09, 171.38),
('cap:fm', 'capital', 'Palikir', 'FM', 'oc', 2, 6.92, 158.19),
('cap:nr', 'capital', 'Yaren', 'NR', 'oc', 3, -0.55, 166.92),
('cap:nz', 'capital', 'Wellington', 'NZ', 'oc', 1, -41.29, 174.78),
('cap:pw', 'capital', 'Ngerulmud', 'PW', 'oc', 3, 7.5, 134.62),
('cap:pg', 'capital', 'Port Moresby', 'PG', 'oc', 1, -9.48, 147.15),
('cap:ws', 'capital', 'Apia', 'WS', 'oc', 2, -13.83, -171.83),
('cap:sb', 'capital', 'Honiara', 'SB', 'oc', 1, -9.43, 159.95),
('cap:to', 'capital', 'Nuku''alofa', 'TO', 'oc', 2, -21.13, -175.2),
('cap:tv', 'capital', 'Funafuti', 'TV', 'oc', 3, -8.5, 179.12),
('cap:vu', 'capital', 'Port Vila', 'VU', 'oc', 2, -17.73, 168.32),
('city:new-york', 'city', 'New York', 'US', 'na', 1, 40.71, -74.01),
('city:los-angeles', 'city', 'Los Angeles', 'US', 'na', 1, 34.05, -118.24),
('city:chicago', 'city', 'Chicago', 'US', 'na', 1, 41.88, -87.63),
('city:san-francisco', 'city', 'San Francisco', 'US', 'na', 1, 37.78, -122.42),
('city:miami', 'city', 'Miami', 'US', 'na', 1, 25.77, -80.19),
('city:las-vegas', 'city', 'Las Vegas', 'US', 'na', 1, 36.17, -115.15),
('city:orlando', 'city', 'Orlando', 'US', 'na', 1, 28.53, -81.39),
('city:boston', 'city', 'Boston', 'US', 'na', 1, 42.36, -71.06),
('city:seattle', 'city', 'Seattle', 'US', 'na', 1, 47.61, -122.33),
('city:houston', 'city', 'Houston', 'US', 'na', 1, 29.76, -95.38),
('city:toronto', 'city', 'Toronto', 'CA', 'na', 1, 43.67, -79.39),
('city:vancouver', 'city', 'Vancouver', 'CA', 'na', 1, 49.26, -123.11),
('city:philadelphia', 'city', 'Philadelphia', 'US', 'na', 2, 39.95, -75.16),
('city:dallas', 'city', 'Dallas', 'US', 'na', 2, 32.78, -96.81),
('city:denver', 'city', 'Denver', 'US', 'na', 2, 39.74, -104.98),
('city:atlanta', 'city', 'Atlanta', 'US', 'na', 2, 33.75, -84.39),
('city:detroit', 'city', 'Detroit', 'US', 'na', 2, 42.33, -83.05),
('city:san-diego', 'city', 'San Diego', 'US', 'na', 2, 32.72, -117.16),
('city:new-orleans', 'city', 'New Orleans', 'US', 'na', 2, 29.98, -90.08),
('city:phoenix', 'city', 'Phoenix', 'US', 'na', 2, 33.45, -112.07),
('city:nashville', 'city', 'Nashville', 'US', 'na', 2, 36.16, -86.77),
('city:montreal', 'city', 'Montreal', 'CA', 'na', 2, 45.5, -73.59),
('city:calgary', 'city', 'Calgary', 'CA', 'na', 2, 51.05, -114.06),
('city:quebec-city', 'city', 'Quebec City', 'CA', 'na', 2, 46.82, -71.22),
('city:cancun', 'city', 'Cancún', 'MX', 'na', 2, 21.16, -86.82),
('city:guadalajara', 'city', 'Guadalajara', 'MX', 'na', 2, 20.68, -103.34),
('city:acapulco', 'city', 'Acapulco', 'MX', 'na', 3, 16.86, -99.89),
('city:monterrey', 'city', 'Monterrey', 'MX', 'na', 3, 25.68, -100.32),
('city:halifax', 'city', 'Halifax', 'CA', 'na', 3, 44.65, -63.57),
('city:montego-bay', 'city', 'Montego Bay', 'JM', 'na', 3, 18.47, -77.92),
('city:rio-de-janeiro', 'city', 'Rio de Janeiro', 'BR', 'sa', 1, -22.91, -43.21),
('city:sao-paulo', 'city', 'São Paulo', 'BR', 'sa', 1, -23.55, -46.63),
('city:salvador', 'city', 'Salvador', 'BR', 'sa', 2, -12.98, -38.49),
('city:manaus', 'city', 'Manaus', 'BR', 'sa', 2, -3.12, -60.02),
('city:cusco', 'city', 'Cusco', 'PE', 'sa', 2, -13.52, -71.98),
('city:medellin', 'city', 'Medellín', 'CO', 'sa', 2, 6.25, -75.57),
('city:cartagena', 'city', 'Cartagena', 'CO', 'sa', 2, 10.42, -75.53),
('city:ushuaia', 'city', 'Ushuaia', 'AR', 'sa', 2, -54.81, -68.31),
('city:valparaiso', 'city', 'Valparaíso', 'CL', 'sa', 2, -33.05, -71.62),
('city:guayaquil', 'city', 'Guayaquil', 'EC', 'sa', 2, -2.19, -79.89),
('city:cordoba', 'city', 'Córdoba', 'AR', 'sa', 3, -31.42, -64.18),
('city:mendoza', 'city', 'Mendoza', 'AR', 'sa', 3, -32.89, -68.84),
('city:recife', 'city', 'Recife', 'BR', 'sa', 3, -8.05, -34.88),
('city:fortaleza', 'city', 'Fortaleza', 'BR', 'sa', 3, -3.73, -38.53),
('city:cali', 'city', 'Cali', 'CO', 'sa', 3, 3.44, -76.52),
('city:arequipa', 'city', 'Arequipa', 'PE', 'sa', 3, -16.4, -71.54),
('city:punta-arenas', 'city', 'Punta Arenas', 'CL', 'sa', 3, -53.16, -70.91),
('city:maracaibo', 'city', 'Maracaibo', 'VE', 'sa', 3, 10.63, -71.63),
('city:barcelona', 'city', 'Barcelona', 'ES', 'eu', 1, 41.38, 2.18),
('city:venice', 'city', 'Venice', 'IT', 'eu', 1, 45.44, 12.33),
('city:milan', 'city', 'Milan', 'IT', 'eu', 1, 45.47, 9.19),
('city:florence', 'city', 'Florence', 'IT', 'eu', 1, 43.77, 11.25),
('city:munich', 'city', 'Munich', 'DE', 'eu', 1, 48.14, 11.58),
('city:manchester', 'city', 'Manchester', 'GB', 'eu', 1, 53.48, -2.25),
('city:liverpool', 'city', 'Liverpool', 'GB', 'eu', 1, 53.41, -2.99),
('city:saint-petersburg', 'city', 'Saint Petersburg', 'RU', 'eu', 2, 59.95, 30.32),
('city:edinburgh', 'city', 'Edinburgh', 'GB', 'eu', 2, 55.95, -3.19),
('city:oxford', 'city', 'Oxford', 'GB', 'eu', 2, 51.75, -1.26),
('city:naples', 'city', 'Naples', 'IT', 'eu', 2, 40.84, 14.25),
('city:pisa', 'city', 'Pisa', 'IT', 'eu', 2, 43.72, 10.4),
('city:hamburg', 'city', 'Hamburg', 'DE', 'eu', 2, 53.55, 10),
('city:frankfurt', 'city', 'Frankfurt', 'DE', 'eu', 2, 50.11, 8.68),
('city:marseille', 'city', 'Marseille', 'FR', 'eu', 2, 43.3, 5.38),
('city:nice', 'city', 'Nice', 'FR', 'eu', 2, 43.7, 7.27),
('city:geneva', 'city', 'Geneva', 'CH', 'eu', 2, 46.2, 6.15),
('city:zurich', 'city', 'Zurich', 'CH', 'eu', 2, 47.37, 8.54),
('city:salzburg', 'city', 'Salzburg', 'AT', 'eu', 2, 47.8, 13.05),
('city:seville', 'city', 'Seville', 'ES', 'eu', 2, 37.39, -5.99),
('city:valencia', 'city', 'Valencia', 'ES', 'eu', 2, 39.47, -0.38),
('city:porto', 'city', 'Porto', 'PT', 'eu', 2, 41.15, -8.61),
('city:rotterdam', 'city', 'Rotterdam', 'NL', 'eu', 2, 51.92, 4.48),
('city:krakow', 'city', 'Kraków', 'PL', 'eu', 2, 50.06, 19.94),
('city:turin', 'city', 'Turin', 'IT', 'eu', 3, 45.08, 7.68),
('city:verona', 'city', 'Verona', 'IT', 'eu', 3, 45.44, 10.99),
('city:cologne', 'city', 'Cologne', 'DE', 'eu', 3, 50.94, 6.96),
('city:lyon', 'city', 'Lyon', 'FR', 'eu', 3, 45.77, 4.84),
('city:bordeaux', 'city', 'Bordeaux', 'FR', 'eu', 3, 44.84, -0.58),
('city:antwerp', 'city', 'Antwerp', 'BE', 'eu', 3, 51.22, 4.4),
('city:gothenburg', 'city', 'Gothenburg', 'SE', 'eu', 3, 57.71, 11.97),
('city:malaga', 'city', 'Málaga', 'ES', 'eu', 3, 36.72, -4.42),
('city:birmingham', 'city', 'Birmingham', 'GB', 'eu', 3, 52.48, -1.9),
('city:glasgow', 'city', 'Glasgow', 'GB', 'eu', 3, 55.86, -4.25),
('city:thessaloniki', 'city', 'Thessaloniki', 'GR', 'eu', 3, 40.64, 22.94),
('city:odesa', 'city', 'Odesa', 'UA', 'eu', 3, 46.48, 30.73),
('city:dubrovnik', 'city', 'Dubrovnik', 'HR', 'eu', 3, 42.64, 18.11),
('city:hong-kong', 'city', 'Hong Kong', 'CN', 'as', 1, 22.28, 114.16),
('city:shanghai', 'city', 'Shanghai', 'CN', 'as', 1, 31.23, 121.47),
('city:dubai', 'city', 'Dubai', 'AE', 'as', 1, 25.27, 55.31),
('city:mumbai', 'city', 'Mumbai', 'IN', 'as', 1, 19.08, 72.88),
('city:istanbul', 'city', 'Istanbul', 'TR', 'as', 1, 41.01, 28.96),
('city:osaka', 'city', 'Osaka', 'JP', 'as', 2, 34.69, 135.5),
('city:kyoto', 'city', 'Kyoto', 'JP', 'as', 2, 35.01, 135.77),
('city:hiroshima', 'city', 'Hiroshima', 'JP', 'as', 2, 34.39, 132.46),
('city:yokohama', 'city', 'Yokohama', 'JP', 'as', 2, 35.45, 139.63),
('city:busan', 'city', 'Busan', 'KR', 'as', 2, 35.18, 129.07),
('city:agra', 'city', 'Agra', 'IN', 'as', 2, 27.18, 78.02),
('city:kolkata', 'city', 'Kolkata', 'IN', 'as', 2, 22.57, 88.37),
('city:karachi', 'city', 'Karachi', 'PK', 'as', 2, 24.86, 67.01),
('city:mecca', 'city', 'Mecca', 'SA', 'as', 2, 21.42, 39.83),
('city:ho-chi-minh-city', 'city', 'Ho Chi Minh City', 'VN', 'as', 2, 10.78, 106.7),
('city:tel-aviv', 'city', 'Tel Aviv', 'IL', 'as', 2, 32.08, 34.78),
('city:shenzhen', 'city', 'Shenzhen', 'CN', 'as', 2, 22.55, 114.05),
('city:almaty', 'city', 'Almaty', 'KZ', 'as', 2, 43.24, 76.92),
('city:samarkand', 'city', 'Samarkand', 'UZ', 'as', 3, 39.65, 66.98),
('city:chennai', 'city', 'Chennai', 'IN', 'as', 3, 13.08, 80.28),
('city:jaipur', 'city', 'Jaipur', 'IN', 'as', 3, 26.92, 75.82),
('city:guangzhou', 'city', 'Guangzhou', 'CN', 'as', 3, 23.13, 113.26),
('city:xi-an', 'city', 'Xi''an', 'CN', 'as', 3, 34.26, 108.94),
('city:chengdu', 'city', 'Chengdu', 'CN', 'as', 3, 30.66, 104.06),
('city:sapporo', 'city', 'Sapporo', 'JP', 'as', 3, 43.06, 141.35),
('city:lahore', 'city', 'Lahore', 'PK', 'as', 3, 31.55, 74.34),
('city:chiang-mai', 'city', 'Chiang Mai', 'TH', 'as', 3, 18.79, 98.98),
('city:siem-reap', 'city', 'Siem Reap', 'KH', 'as', 3, 13.36, 103.86),
('city:isfahan', 'city', 'Isfahan', 'IR', 'as', 3, 32.65, 51.67),
('city:mandalay', 'city', 'Mandalay', 'MM', 'as', 3, 21.97, 96.08),
('city:jeddah', 'city', 'Jeddah', 'SA', 'as', 3, 21.53, 39.16),
('city:marrakesh', 'city', 'Marrakesh', 'MA', 'af', 2, 31.63, -7.98),
('city:casablanca', 'city', 'Casablanca', 'MA', 'af', 2, 33.6, -7.62),
('city:johannesburg', 'city', 'Johannesburg', 'ZA', 'af', 2, -26.2, 28.04),
('city:alexandria', 'city', 'Alexandria', 'EG', 'af', 2, 31.2, 29.89),
('city:timbuktu', 'city', 'Timbuktu', 'ML', 'af', 2, 16.77, -3),
('city:lagos', 'city', 'Lagos', 'NG', 'af', 2, 6.46, 3.39),
('city:luxor', 'city', 'Luxor', 'EG', 'af', 2, 25.7, 32.64),
('city:durban', 'city', 'Durban', 'ZA', 'af', 3, -29.86, 31.03),
('city:mombasa', 'city', 'Mombasa', 'KE', 'af', 3, -4.05, 39.67),
('city:zanzibar-city', 'city', 'Zanzibar City', 'TZ', 'af', 3, -6.17, 39.2),
('city:fez', 'city', 'Fez', 'MA', 'af', 3, 34.04, -5),
('city:tangier', 'city', 'Tangier', 'MA', 'af', 3, 35.77, -5.8),
('city:aswan', 'city', 'Aswan', 'EG', 'af', 3, 24.09, 32.9),
('city:kano', 'city', 'Kano', 'NG', 'af', 3, 12, 8.52),
('city:arusha', 'city', 'Arusha', 'TZ', 'af', 3, -3.37, 36.68),
('city:douala', 'city', 'Douala', 'CM', 'af', 3, 4.05, 9.7),
('city:kumasi', 'city', 'Kumasi', 'GH', 'af', 3, 6.7, -1.62),
('city:bulawayo', 'city', 'Bulawayo', 'ZW', 'af', 3, -20.17, 28.57),
('city:sydney', 'city', 'Sydney', 'AU', 'oc', 1, -33.87, 151.21),
('city:melbourne', 'city', 'Melbourne', 'AU', 'oc', 1, -37.81, 144.96),
('city:brisbane', 'city', 'Brisbane', 'AU', 'oc', 2, -27.47, 153.03),
('city:perth', 'city', 'Perth', 'AU', 'oc', 2, -31.96, 115.86),
('city:auckland', 'city', 'Auckland', 'NZ', 'oc', 2, -36.85, 174.77),
('city:adelaide', 'city', 'Adelaide', 'AU', 'oc', 3, -34.93, 138.6),
('city:gold-coast', 'city', 'Gold Coast', 'AU', 'oc', 3, -28.02, 153.4),
('city:cairns', 'city', 'Cairns', 'AU', 'oc', 3, -16.93, 145.78),
('city:darwin', 'city', 'Darwin', 'AU', 'oc', 3, -12.44, 130.84),
('city:alice-springs', 'city', 'Alice Springs', 'AU', 'oc', 3, -23.7, 133.87),
('city:hobart', 'city', 'Hobart', 'AU', 'oc', 3, -42.88, 147.32),
('city:christchurch', 'city', 'Christchurch', 'NZ', 'oc', 3, -43.53, 172.64),
('city:queenstown', 'city', 'Queenstown', 'NZ', 'oc', 3, -45.03, 168.66)
ON CONFLICT (place_key) DO UPDATE SET
  kind = EXCLUDED.kind, name = EXCLUDED.name, iso = EXCLUDED.iso, continent = EXCLUDED.continent,
  tier = EXCLUDED.tier, lat = EXCLUDED.lat, lon = EXCLUDED.lon;


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
-- p_pins: exactly 10 objects {i, lat, lon, ms}, one per DIFFERENT place of
-- the deck's continent: i is its place_key ('cap:ke', 'city:mombasa'). lat
-- and lon are where the student tapped (null if they gave up), ms how long
-- they took. Distance is great-circle km to the place in geo_pin_places,
-- scored by the rings of lib/geo-pin.ts:
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
  ringed AS (
    SELECT d.*, CASE WHEN km <= 100 THEN 100 WHEN km <= 300 THEN 70 WHEN km <= 600 THEN 40 WHEN km <= 1000 THEN 20 WHEN km <= 1500 THEN 10 ELSE 0 END AS ring FROM dist d
  ),
  pts AS (
    SELECT r.*, r.ring + CASE WHEN r.ring > 0 THEN (CASE WHEN r.ms BETWEEN 0 AND 3000 THEN 10 WHEN r.ms BETWEEN 0 AND 6000 THEN 5 ELSE 0 END) ELSE 0 END AS points FROM ringed r
  )
  SELECT COUNT(DISTINCT place), COUNT(*) FILTER (WHERE out_of_range), COALESCE(SUM(points), 0),
         jsonb_agg(jsonb_build_object('i', place, 'km', round(km::NUMERIC), 'ms', ms, 'p', points) ORDER BY ord)
    INTO places, bad, total, scored
    FROM pts;

  IF places <> 10 THEN
    RAISE EXCEPTION 'a pin round needs 10 different places of its continent';
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
-- Expected: cards 1287, shape_cards 175, city_cards 147,
--           phase1_cards 965, phase1_points 9650, max_points 13745,
--           orphan_history 0, geo_badges 23, pin_places 340,
--           pin_cities 147, pin_rounds_table 1,
--           helper_callable_by_students false,
--           pin_record_callable_by_anon false, pin_insert_by_students false.

SELECT
  (SELECT COUNT(*) FROM geo_cards)                                        AS cards,
  (SELECT COUNT(*) FROM geo_cards WHERE kind = 'shape')                   AS shape_cards,
  (SELECT COUNT(*) FROM geo_cards WHERE kind = 'city')                    AS city_cards,
  (SELECT COUNT(*) FROM geo_cards WHERE kind NOT IN ('shape', 'city'))      AS phase1_cards,
  (SELECT SUM(points) FROM geo_cards WHERE kind NOT IN ('shape', 'city'))   AS phase1_points,
  (SELECT SUM(points) FROM geo_cards)                                     AS max_points,
  (SELECT COUNT(*) FROM geo_history h
    WHERE NOT EXISTS (SELECT 1 FROM geo_cards c WHERE c.card_key = h.card_key)) AS orphan_history,
  (SELECT COUNT(*) FROM achievement_definitions WHERE category = 'Geography') AS geo_badges,
  (SELECT COUNT(*) FROM geo_pin_places)                                   AS pin_places,
  (SELECT COUNT(*) FROM geo_pin_places WHERE kind = 'city')               AS pin_cities,
  (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'geo_pin_rounds') AS pin_rounds_table,
  has_function_privilege('authenticated', 'award_geo_badges_for(uuid, boolean)', 'EXECUTE')
                                                                           AS helper_callable_by_students,
  has_function_privilege('anon', 'record_geo_pin_round(text, jsonb)', 'EXECUTE')
                                                                           AS pin_record_callable_by_anon,
  has_table_privilege('authenticated', 'geo_pin_rounds', 'INSERT')        AS pin_insert_by_students;
