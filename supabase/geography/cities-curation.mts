// The curated list of famous world cities (not capitals) for Geography:
// "Which country is Rio de Janeiro in?" cards and Pin the map places.
//
// Robert asked for "famous cities of the world that are NOT necessarily
// capitals, like Rio, NYC". Chosen for kids of roughly 8 to 14 in the US:
// cities they have heard of from films, sport, holidays, history lessons
// and the news. Every one is checked by validate-cities.mts: it joins to a
// UN member in lib/geo-data.ts, is NOT any capital there, and its Wikidata
// coordinates lie inside its own country on the Natural Earth map.
//
// Each row: [name, country ISO alpha-2, fame tier, Wikidata QID, notWrong?]
//
//   name     the plain English name kids would read: Mumbai not Bombay,
//            Saint Petersburg spelled out, accents where English keeps them
//            (São Paulo, Cancún, Kraków)
//   tier     1 = everyone has heard of it, 2 = most kids have heard of it,
//            3 = famous, but a stretch (Timbuktu, Samarkand, Alice Springs).
//            Assigned by hand, not from population: Timbuktu is tiny and
//            famous, Guangzhou is huge and mostly not (to a 10-year-old).
//   QID      the city's Wikidata item, pinned so a refetch can never drift to
//            a namesake (the New York label is also the state's). Population
//            (P1082) and coordinates (P625) come from that item.
//   notWrong countries never offered as a WRONG answer on this city's card,
//            because a place of the same name is genuinely there.
//
// Hard cases, decided once:
//   Hong Kong      Not a UN member: a special administrative region of
//                  China, which is what Wikidata (P17) says too. Its card
//                  answers China. Macau is left out (few kids know it).
//   Istanbul       Mostly on the European side of the Bosphorus, but Turkey
//                  is an Asian country in this track (UN M49), so it is an
//                  Asia place, like Ankara. The Asia map view includes it.
//   Capitals       Left out wherever lib/geo-data.ts lists them as ANY of a
//                  country's capitals: Cape Town (South Africa), Dar es
//                  Salaam (Tanzania), Abidjan (Ivory Coast), Cotonou (Benin),
//                  The Hague (Netherlands), La Paz (Bolivia). Edinburgh is
//                  in: it is Scotland's capital but not a UN member's.
//   Disputed       Jerusalem (a capital anyway), Bethlehem and Gaza
//                  (Palestine is not a UN member) and Taipei are left out.
//   Off the map    Anchorage and Honolulu are left out: Alaska and Hawaii
//                  fall outside the North America view of Pin the map, as
//                  Siberian Russia falls outside Europe's.
//   Border         Tijuana is left out: its centre is a kilometre or two from
//                  the US border, and on the 1:50m map it lands in the USA,
//                  so Pin the map would show it in the wrong country.
//   Same city      Giza is left out: it is part of Greater Cairo, so pinning
//                  it would be pinning the capital.
//   Same names     Cities whose name is shared with another same-continent
//                  place are left out (Santa Cruz, Concepción, Granada,
//                  León, Tripoli, Hyderabad: India AND Pakistan, Victoria
//                  Falls: Zimbabwe AND Zambia, Bergen, Rosario) or carry a
//                  notWrong: Córdoba (Colombia has a Córdoba department),
//                  Cartagena (a Chilean beach town), Queenstown (a
//                  Tasmanian town, so never Australia for New Zealand's).
//   Confusions     A famous mix-up that is genuinely wrong IS a fair wrong
//                  answer and is kept: Geneva is not in France, Salzburg is
//                  not in Germany, Dubai is not in Saudi Arabia, Nice is not
//                  in Monaco. Those cards teach exactly that.

export type Tier = 1 | 2 | 3
export type CityRow = [name: string, iso: string, tier: Tier, qid: string, notWrong?: string[]]

export const CITY_ROWS: CityRow[] = [
  // ── North America ──────────────────────────────────────────────────────────
  ['New York', 'US', 1, 'Q60'],
  ['Los Angeles', 'US', 1, 'Q65'],
  ['Chicago', 'US', 1, 'Q1297'],
  ['San Francisco', 'US', 1, 'Q62'],
  ['Miami', 'US', 1, 'Q8652'],
  ['Las Vegas', 'US', 1, 'Q23768'],
  ['Orlando', 'US', 1, 'Q49233'],
  ['Boston', 'US', 1, 'Q100'],
  ['Seattle', 'US', 1, 'Q5083'],
  ['Houston', 'US', 1, 'Q16555'],
  ['Toronto', 'CA', 1, 'Q172'],
  ['Vancouver', 'CA', 1, 'Q24639'],
  ['Philadelphia', 'US', 2, 'Q1345'],
  ['Dallas', 'US', 2, 'Q16557'],
  ['Denver', 'US', 2, 'Q16554'],
  ['Atlanta', 'US', 2, 'Q23556'],
  ['Detroit', 'US', 2, 'Q12439'],
  ['San Diego', 'US', 2, 'Q16552'],
  ['New Orleans', 'US', 2, 'Q34404'],
  ['Phoenix', 'US', 2, 'Q16556'],
  ['Nashville', 'US', 2, 'Q23197'],
  ['Montreal', 'CA', 2, 'Q340'],
  ['Calgary', 'CA', 2, 'Q36312'],
  ['Quebec City', 'CA', 2, 'Q2145'],
  ['Cancún', 'MX', 2, 'Q8969'],
  ['Guadalajara', 'MX', 2, 'Q9022'],
  ['Acapulco', 'MX', 3, 'Q81398'],
  ['Monterrey', 'MX', 3, 'Q81033'],
  ['Halifax', 'CA', 3, 'Q2141'],
  ['Montego Bay', 'JM', 3, 'Q637555'],

  // ── South America ──────────────────────────────────────────────────────────
  ['Rio de Janeiro', 'BR', 1, 'Q8678'],
  ['São Paulo', 'BR', 1, 'Q174'],
  ['Salvador', 'BR', 2, 'Q36947'],
  ['Manaus', 'BR', 2, 'Q40236'],
  ['Cusco', 'PE', 2, 'Q5582862'],
  ['Medellín', 'CO', 2, 'Q48278'],
  ['Cartagena', 'CO', 2, 'Q657461', ['CL']],
  ['Ushuaia', 'AR', 2, 'Q44254'],
  ['Valparaíso', 'CL', 2, 'Q33986'],
  ['Guayaquil', 'EC', 2, 'Q43509'],
  ['Córdoba', 'AR', 3, 'Q44210', ['CO']],
  ['Mendoza', 'AR', 3, 'Q44237'],
  ['Recife', 'BR', 3, 'Q48344'],
  ['Fortaleza', 'BR', 3, 'Q43463'],
  ['Cali', 'CO', 3, 'Q51103'],
  ['Arequipa', 'PE', 3, 'Q159273'],
  ['Punta Arenas', 'CL', 3, 'Q51599'],
  ['Maracaibo', 'VE', 3, 'Q171632'],

  // ── Europe ─────────────────────────────────────────────────────────────────
  ['Barcelona', 'ES', 1, 'Q1492'],
  ['Venice', 'IT', 1, 'Q641'],
  ['Milan', 'IT', 1, 'Q490'],
  ['Florence', 'IT', 1, 'Q2044'],
  ['Munich', 'DE', 1, 'Q1726'],
  ['Manchester', 'GB', 1, 'Q18125'],
  ['Liverpool', 'GB', 1, 'Q24826'],
  ['Saint Petersburg', 'RU', 2, 'Q656'],
  ['Edinburgh', 'GB', 2, 'Q23436'],
  ['Oxford', 'GB', 2, 'Q34217'],
  ['Naples', 'IT', 2, 'Q2634'],
  ['Pisa', 'IT', 2, 'Q13375'],
  ['Hamburg', 'DE', 2, 'Q1055'],
  ['Frankfurt', 'DE', 2, 'Q1794'],
  ['Marseille', 'FR', 2, 'Q23482'],
  ['Nice', 'FR', 2, 'Q33959'],
  ['Geneva', 'CH', 2, 'Q71'],
  ['Zurich', 'CH', 2, 'Q72'],
  ['Salzburg', 'AT', 2, 'Q34713'],
  ['Seville', 'ES', 2, 'Q8717'],
  ['Valencia', 'ES', 2, 'Q8818'],
  ['Porto', 'PT', 2, 'Q36433'],
  ['Rotterdam', 'NL', 2, 'Q34370'],
  ['Kraków', 'PL', 2, 'Q31487'],
  ['Turin', 'IT', 3, 'Q495'],
  ['Verona', 'IT', 3, 'Q2028'],
  ['Cologne', 'DE', 3, 'Q365'],
  ['Lyon', 'FR', 3, 'Q456'],
  ['Bordeaux', 'FR', 3, 'Q1479'],
  ['Antwerp', 'BE', 3, 'Q12892'],
  ['Gothenburg', 'SE', 3, 'Q25287'],
  ['Málaga', 'ES', 3, 'Q8851'],
  ['Birmingham', 'GB', 3, 'Q2256'],
  ['Glasgow', 'GB', 3, 'Q4093'],
  ['Thessaloniki', 'GR', 3, 'Q17151'],
  ['Odesa', 'UA', 3, 'Q1874'],
  ['Dubrovnik', 'HR', 3, 'Q1722'],

  // ── Asia ───────────────────────────────────────────────────────────────────
  ['Hong Kong', 'CN', 1, 'Q8646'],
  ['Shanghai', 'CN', 1, 'Q8686'],
  ['Dubai', 'AE', 1, 'Q612'],
  ['Mumbai', 'IN', 1, 'Q1156'],
  ['Istanbul', 'TR', 1, 'Q406'],
  ['Osaka', 'JP', 2, 'Q35765'],
  ['Kyoto', 'JP', 2, 'Q34600'],
  ['Hiroshima', 'JP', 2, 'Q34664'],
  ['Yokohama', 'JP', 2, 'Q38283'],
  ['Busan', 'KR', 2, 'Q16520'],
  ['Agra', 'IN', 2, 'Q42941'],
  ['Kolkata', 'IN', 2, 'Q1348'],
  ['Karachi', 'PK', 2, 'Q8660'],
  ['Mecca', 'SA', 2, 'Q5806'],
  ['Ho Chi Minh City', 'VN', 2, 'Q1854'],
  ['Tel Aviv', 'IL', 2, 'Q33935'],
  ['Shenzhen', 'CN', 2, 'Q15174'],
  ['Almaty', 'KZ', 2, 'Q35493'],
  ['Samarkand', 'UZ', 3, 'Q5753'],
  ['Chennai', 'IN', 3, 'Q1352'],
  ['Jaipur', 'IN', 3, 'Q66485'],
  ['Guangzhou', 'CN', 3, 'Q16572'],
  ["Xi'an", 'CN', 3, 'Q5826'],
  ['Chengdu', 'CN', 3, 'Q30002'],
  ['Sapporo', 'JP', 3, 'Q37951'],
  ['Lahore', 'PK', 3, 'Q11739'],
  ['Chiang Mai', 'TH', 3, 'Q52028'],
  ['Siem Reap', 'KH', 3, 'Q11711'],
  ['Isfahan', 'IR', 3, 'Q42053'],
  ['Mandalay', 'MM', 3, 'Q185518'],
  ['Jeddah', 'SA', 3, 'Q374365'],

  // ── Africa ─────────────────────────────────────────────────────────────────
  ['Marrakesh', 'MA', 2, 'Q101625'],
  ['Casablanca', 'MA', 2, 'Q7903'],
  ['Johannesburg', 'ZA', 2, 'Q34647'],
  ['Alexandria', 'EG', 2, 'Q87'],
  ['Timbuktu', 'ML', 2, 'Q9427'],
  ['Lagos', 'NG', 2, 'Q8673'],
  ['Luxor', 'EG', 2, 'Q130514'],
  ['Durban', 'ZA', 3, 'Q5468'],
  ['Mombasa', 'KE', 3, 'Q225641'],
  ['Zanzibar City', 'TZ', 3, 'Q2222874'],
  ['Fez', 'MA', 3, 'Q80985'],
  ['Tangier', 'MA', 3, 'Q126148'],
  ['Aswan', 'EG', 3, 'Q29888'],
  ['Kano', 'NG', 3, 'Q182984'],
  ['Arusha', 'TZ', 3, 'Q4301'],
  ['Douala', 'CM', 3, 'Q132830'],
  ['Kumasi', 'GH', 3, 'Q182059'],
  ['Bulawayo', 'ZW', 3, 'Q193250'],

  // ── Oceania ────────────────────────────────────────────────────────────────
  ['Sydney', 'AU', 1, 'Q3130'],
  ['Melbourne', 'AU', 1, 'Q3141'],
  ['Brisbane', 'AU', 2, 'Q34932'],
  ['Perth', 'AU', 2, 'Q3183'],
  ['Auckland', 'NZ', 2, 'Q37100'],
  ['Adelaide', 'AU', 3, 'Q5112'],
  ['Gold Coast', 'AU', 3, 'Q140075'],
  ['Cairns', 'AU', 3, 'Q189133'],
  ['Darwin', 'AU', 3, 'Q11568'],
  ['Alice Springs', 'AU', 3, 'Q17872'],
  ['Hobart', 'AU', 3, 'Q40191'],
  ['Christchurch', 'NZ', 3, 'Q79990'],
  ['Queenstown', 'NZ', 3, 'Q613602', ['AU']],
]

/** Every place the curated data differs from Wikidata, with the reason.
 *  build-cities.mts refuses to write a difference without one, and refuses
 *  a reason that no longer explains anything. Keys: `QID:name` (our name
 *  is not Wikidata's English label) or `QID:P17:ISO` (Wikidata also gives
 *  another UN member as a current country). */
export const CITY_REASONS: Record<string, string> = {
  'Q60:name': 'Kids say New York. The item is the city (Q60), labelled New York City, never the state.',
  'Q81398:name': 'Acapulco de Juárez is the official name. Everyone, atlases included, says Acapulco.',
  'Q101625:name': 'Marrakesh is the usual English spelling (and English Wikipedia\'s). Wikidata labels it Marrakech.',
  'Q11739:P17:IN': 'Wikidata also lists India as a country of Lahore with no end date, a leftover from before 1947. Lahore is in Pakistan.',
}

/** UN members whose cities Wikidata files under a different item than the
 *  member's own (lib/geo-data.ts `wikidata`). The Netherlands' UN seat is
 *  the Kingdom of the Netherlands (Q29999). Its European country, where
 *  Rotterdam is, is Q55. */
export const COUNTRY_ITEMS: Record<string, string[]> = {
  NL: ['Q55'],
}
