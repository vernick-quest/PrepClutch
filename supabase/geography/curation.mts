// The hand-curated layer of the Geography data: kid-friendly names, which
// capital/language/currency we ASK about, and the decisions Wikidata cannot
// make for us. build-data.mts checks every value here against the Wikidata
// snapshot (CC0) and refuses to build when a value disagrees with Wikidata
// and has no entry in REASONS below. So every fact either comes from Wikidata
// or carries a written reason for differing.
//
// Row: [iso2, name, continent, capitals, official, recognised, currencies]
//
//   capitals    first = the one we ask about (the commonly taught one). The
//               rest are other official or seat-of-government capitals.
//   official    languages with national official status. First = the one we
//               ask about. Any of them is a right answer.
//   recognised  languages that are official somewhere in the country
//               (a region, a province), constitutionally recognised, or close
//               enough to an official one that offering it as a WRONG answer
//               would be unfair (Malay for Indonesia). Never shown as a wrong
//               choice. Wikidata's official-language list is added to this
//               automatically by the build, as a safety net.
//   currencies  [ISO 4217 code, short name shown on the button, full name].
//               First = the one we ask about. Every other one is legal tender
//               or in everyday use there, and is never shown as a wrong choice.
//
// Continents: the UN M49 geoscheme (the UN's own regions, a fitting rule for
// a list of UN members), with the Americas split into North America (which
// includes Central America and the Caribbean) and South America. So Russia
// is Europe, and Turkey, Cyprus, Georgia, Armenia, Azerbaijan and Kazakhstan
// are Asia. Countries that span two continents list the other one in
// ALSO_CONTINENT, and it is never offered as a wrong answer.

export type Continent = 'af' | 'as' | 'eu' | 'na' | 'sa' | 'oc'
export type Cur = [code: string, short: string, full: string]
export type Row = [
  iso: string, name: string, continent: Continent,
  capitals: string[], official: string[], recognised: string[], currencies: Cur[],
]

const EUR: Cur = ['EUR', 'Euro', 'euro']
const USD: Cur = ['USD', 'Dollar', 'US dollar']
const XCD: Cur = ['XCD', 'Dollar', 'East Caribbean dollar']
const XOF: Cur = ['XOF', 'CFA franc', 'West African CFA franc']
const XAF: Cur = ['XAF', 'CFA franc', 'Central African CFA franc']
const AUD: Cur = ['AUD', 'Dollar', 'Australian dollar']
const ZAR: Cur = ['ZAR', 'Rand', 'South African rand']

export const ROWS: Row[] = [
  // ── Africa (54) ──
  ['DZ', 'Algeria', 'af', ['Algiers'], ['Arabic', 'Berber'], ['French'], [['DZD', 'Dinar', 'Algerian dinar']]],
  ['AO', 'Angola', 'af', ['Luanda'], ['Portuguese'], ['Umbundu', 'Kimbundu', 'Kikongo'], [['AOA', 'Kwanza', 'Angolan kwanza']]],
  ['BJ', 'Benin', 'af', ['Porto-Novo', 'Cotonou'], ['French'], ['Fon', 'Yoruba'], [XOF]],
  ['BW', 'Botswana', 'af', ['Gaborone'], ['English', 'Tswana'], [], [['BWP', 'Pula', 'Botswana pula']]],
  ['BF', 'Burkina Faso', 'af', ['Ouagadougou'], ['Mooré', 'Dioula', 'Fula'], ['French', 'Bissa'], [XOF]],
  ['BI', 'Burundi', 'af', ['Gitega', 'Bujumbura'], ['Kirundi', 'French', 'English'], ['Swahili'], [['BIF', 'Franc', 'Burundian franc']]],
  ['CV', 'Cape Verde', 'af', ['Praia'], ['Portuguese'], ['Cape Verdean Creole'], [['CVE', 'Escudo', 'Cape Verdean escudo']]],
  ['CM', 'Cameroon', 'af', ['Yaoundé'], ['French', 'English'], [], [XAF]],
  ['CF', 'Central African Republic', 'af', ['Bangui'], ['French', 'Sango'], [], [XAF]],
  ['TD', 'Chad', 'af', ["N'Djamena"], ['French', 'Arabic'], [], [XAF]],
  ['KM', 'Comoros', 'af', ['Moroni'], ['Comorian', 'Arabic', 'French'], [], [['KMF', 'Franc', 'Comorian franc']]],
  ['CG', 'Republic of the Congo', 'af', ['Brazzaville'], ['French'], ['Lingala', 'Kituba'], [XAF]],
  ['CD', 'Democratic Republic of the Congo', 'af', ['Kinshasa'], ['French'], ['Lingala', 'Swahili', 'Kikongo', 'Tshiluba'], [['CDF', 'Franc', 'Congolese franc']]],
  ['CI', 'Ivory Coast', 'af', ['Yamoussoukro', 'Abidjan'], ['French'], [], [XOF]],
  ['DJ', 'Djibouti', 'af', ['Djibouti'], ['French', 'Arabic'], ['Somali', 'Afar'], [['DJF', 'Franc', 'Djiboutian franc']]],
  ['EG', 'Egypt', 'af', ['Cairo'], ['Arabic'], [], [['EGP', 'Pound', 'Egyptian pound']]],
  ['GQ', 'Equatorial Guinea', 'af', ['Ciudad de la Paz'], ['Spanish', 'French', 'Portuguese'], [], [XAF]],
  ['ER', 'Eritrea', 'af', ['Asmara'], ['Tigrinya', 'Arabic', 'English'], [], [['ERN', 'Nakfa', 'Eritrean nakfa']]],
  ['SZ', 'Eswatini', 'af', ['Mbabane', 'Lobamba'], ['Swazi', 'English'], [], [['SZL', 'Lilangeni', 'Swazi lilangeni'], ZAR]],
  ['ET', 'Ethiopia', 'af', ['Addis Ababa'], ['Amharic'], ['Oromo', 'Somali', 'Tigrinya', 'Afar'], [['ETB', 'Birr', 'Ethiopian birr']]],
  ['GA', 'Gabon', 'af', ['Libreville'], ['French'], [], [XAF]],
  ['GM', 'Gambia', 'af', ['Banjul'], ['English'], [], [['GMD', 'Dalasi', 'Gambian dalasi']]],
  ['GH', 'Ghana', 'af', ['Accra'], ['English'], [], [['GHS', 'Cedi', 'Ghanaian cedi']]],
  ['GN', 'Guinea', 'af', ['Conakry'], ['French'], [], [['GNF', 'Franc', 'Guinean franc']]],
  ['GW', 'Guinea-Bissau', 'af', ['Bissau'], ['Portuguese'], [], [XOF]],
  ['KE', 'Kenya', 'af', ['Nairobi'], ['Swahili', 'English'], [], [['KES', 'Shilling', 'Kenyan shilling']]],
  ['LS', 'Lesotho', 'af', ['Maseru'], ['Sesotho', 'English'], [], [['LSL', 'Loti', 'Lesotho loti'], ZAR]],
  ['LR', 'Liberia', 'af', ['Monrovia'], ['English'], [], [['LRD', 'Dollar', 'Liberian dollar'], USD]],
  ['LY', 'Libya', 'af', ['Tripoli'], ['Arabic'], ['Berber'], [['LYD', 'Dinar', 'Libyan dinar']]],
  ['MG', 'Madagascar', 'af', ['Antananarivo'], ['Malagasy', 'French'], [], [['MGA', 'Ariary', 'Malagasy ariary']]],
  ['MW', 'Malawi', 'af', ['Lilongwe'], ['English', 'Chichewa'], ['Tumbuka'], [['MWK', 'Kwacha', 'Malawian kwacha']]],
  ['ML', 'Mali', 'af', ['Bamako'], ['Bambara', 'Fula', 'Songhay', 'Soninke'], ['French', 'Arabic'], [XOF]],
  ['MR', 'Mauritania', 'af', ['Nouakchott'], ['Arabic'], ['French', 'Fula', 'Soninke', 'Wolof'], [['MRU', 'Ouguiya', 'Mauritanian ouguiya']]],
  ['MU', 'Mauritius', 'af', ['Port Louis'], ['English', 'French'], ['Mauritian Creole'], [['MUR', 'Rupee', 'Mauritian rupee']]],
  ['MA', 'Morocco', 'af', ['Rabat'], ['Arabic', 'Berber'], ['French'], [['MAD', 'Dirham', 'Moroccan dirham']]],
  ['MZ', 'Mozambique', 'af', ['Maputo'], ['Portuguese'], [], [['MZN', 'Metical', 'Mozambican metical']]],
  ['NA', 'Namibia', 'af', ['Windhoek'], ['English'], ['Afrikaans', 'German', 'Oshiwambo'], [['NAD', 'Dollar', 'Namibian dollar'], ZAR]],
  ['NE', 'Niger', 'af', ['Niamey'], ['Hausa'], ['French', 'Zarma', 'Fula', 'Arabic', 'Kanuri', 'Tamasheq'], [XOF]],
  ['NG', 'Nigeria', 'af', ['Abuja'], ['English'], ['Hausa', 'Yoruba', 'Igbo'], [['NGN', 'Naira', 'Nigerian naira']]],
  ['RW', 'Rwanda', 'af', ['Kigali'], ['Kinyarwanda', 'English', 'French', 'Swahili'], [], [['RWF', 'Franc', 'Rwandan franc']]],
  ['ST', 'São Tomé and Príncipe', 'af', ['São Tomé'], ['Portuguese'], [], [['STN', 'Dobra', 'São Tomé and Príncipe dobra']]],
  ['SN', 'Senegal', 'af', ['Dakar'], ['French'], ['Wolof'], [XOF]],
  ['SC', 'Seychelles', 'af', ['Victoria'], ['Seychellois Creole', 'English', 'French'], [], [['SCR', 'Rupee', 'Seychellois rupee']]],
  ['SL', 'Sierra Leone', 'af', ['Freetown'], ['English'], ['Krio'], [['SLE', 'Leone', 'Sierra Leonean leone']]],
  ['SO', 'Somalia', 'af', ['Mogadishu'], ['Somali', 'Arabic'], [], [['SOS', 'Shilling', 'Somali shilling']]],
  ['ZA', 'South Africa', 'af', ['Pretoria', 'Cape Town', 'Bloemfontein'],
    ['Zulu', 'English', 'Xhosa', 'Afrikaans', 'Northern Sotho', 'Tswana', 'Sesotho', 'Tsonga', 'Swazi', 'Venda', 'Southern Ndebele'],
    ['South African Sign Language'], [ZAR]],
  ['SS', 'South Sudan', 'af', ['Juba'], ['English'], ['Arabic'], [['SSP', 'Pound', 'South Sudanese pound']]],
  ['SD', 'Sudan', 'af', ['Khartoum', 'Port Sudan'], ['Arabic', 'English'], [], [['SDG', 'Pound', 'Sudanese pound']]],
  ['TZ', 'Tanzania', 'af', ['Dodoma', 'Dar es Salaam'], ['Swahili', 'English'], [], [['TZS', 'Shilling', 'Tanzanian shilling']]],
  ['TG', 'Togo', 'af', ['Lomé'], ['French'], ['Ewe', 'Kabiye'], [XOF]],
  ['TN', 'Tunisia', 'af', ['Tunis'], ['Arabic'], ['French'], [['TND', 'Dinar', 'Tunisian dinar']]],
  ['UG', 'Uganda', 'af', ['Kampala'], ['English', 'Swahili'], [], [['UGX', 'Shilling', 'Ugandan shilling']]],
  ['ZM', 'Zambia', 'af', ['Lusaka'], ['English'], ['Bemba', 'Chichewa', 'Tonga', 'Lozi'], [['ZMW', 'Kwacha', 'Zambian kwacha']]],
  ['ZW', 'Zimbabwe', 'af', ['Harare'], ['Shona', 'English', 'Northern Ndebele', 'Chichewa', 'Tswana', 'Sesotho', 'Xhosa', 'Venda', 'Tsonga', 'Tonga'],
    [], [['ZWG', 'Zimbabwe Gold', 'Zimbabwe Gold (ZiG)'], USD, ZAR]],

  // ── Asia (47) ──
  ['AF', 'Afghanistan', 'as', ['Kabul'], ['Pashto', 'Dari'], ['Persian', 'Tajik', 'Uzbek', 'Turkmen', 'Balochi', 'Arabic'], [['AFN', 'Afghani', 'Afghan afghani']]],
  ['AM', 'Armenia', 'as', ['Yerevan'], ['Armenian'], ['Russian'], [['AMD', 'Dram', 'Armenian dram']]],
  ['AZ', 'Azerbaijan', 'as', ['Baku'], ['Azerbaijani'], ['Russian'], [['AZN', 'Manat', 'Azerbaijani manat']]],
  ['BH', 'Bahrain', 'as', ['Manama'], ['Arabic'], [], [['BHD', 'Dinar', 'Bahraini dinar']]],
  ['BD', 'Bangladesh', 'as', ['Dhaka'], ['Bengali'], [], [['BDT', 'Taka', 'Bangladeshi taka']]],
  ['BT', 'Bhutan', 'as', ['Thimphu'], ['Dzongkha'], ['English', 'Nepali'], [['BTN', 'Ngultrum', 'Bhutanese ngultrum'], ['INR', 'Rupee', 'Indian rupee']]],
  ['BN', 'Brunei', 'as', ['Bandar Seri Begawan'], ['Malay'], ['English', 'Indonesian', 'Chinese'], [['BND', 'Dollar', 'Brunei dollar'], ['SGD', 'Dollar', 'Singapore dollar']]],
  ['KH', 'Cambodia', 'as', ['Phnom Penh'], ['Khmer'], [], [['KHR', 'Riel', 'Cambodian riel'], USD]],
  ['CN', 'China', 'as', ['Beijing'], ['Chinese'], ['Mongolian', 'Tibetan', 'Uyghur', 'Zhuang', 'Korean', 'Kazakh', 'English', 'Portuguese'], [['CNY', 'Yuan', 'Chinese yuan (renminbi)']]],
  ['CY', 'Cyprus', 'as', ['Nicosia'], ['Greek', 'Turkish'], ['English', 'Armenian'], [EUR]],
  ['GE', 'Georgia', 'as', ['Tbilisi'], ['Georgian'], ['Abkhaz', 'Russian'], [['GEL', 'Lari', 'Georgian lari']]],
  ['IN', 'India', 'as', ['New Delhi'], ['Hindi', 'English'],
    ['Assamese', 'Bengali', 'Bodo', 'Dogri', 'Gujarati', 'Kannada', 'Kashmiri', 'Konkani', 'Maithili', 'Malayalam', 'Manipuri',
     'Marathi', 'Nepali', 'Odia', 'Punjabi', 'Sanskrit', 'Santali', 'Sindhi', 'Tamil', 'Telugu', 'Urdu'],
    [['INR', 'Rupee', 'Indian rupee']]],
  ['ID', 'Indonesia', 'as', ['Jakarta'], ['Indonesian'], ['Malay'], [['IDR', 'Rupiah', 'Indonesian rupiah']]],
  ['IR', 'Iran', 'as', ['Tehran'], ['Persian'], ['Dari', 'Tajik', 'Arabic', 'Azerbaijani', 'Kurdish'], [['IRR', 'Rial', 'Iranian rial']]],
  ['IQ', 'Iraq', 'as', ['Baghdad'], ['Arabic', 'Kurdish'], ['Turkmen', 'Syriac'], [['IQD', 'Dinar', 'Iraqi dinar']]],
  ['IL', 'Israel', 'as', ['Jerusalem'], ['Hebrew'], ['Arabic'], [['ILS', 'Shekel', 'Israeli new shekel']]],
  ['JP', 'Japan', 'as', ['Tokyo'], ['Japanese'], [], [['JPY', 'Yen', 'Japanese yen']]],
  ['JO', 'Jordan', 'as', ['Amman'], ['Arabic'], [], [['JOD', 'Dinar', 'Jordanian dinar']]],
  ['KZ', 'Kazakhstan', 'as', ['Astana'], ['Kazakh', 'Russian'], [], [['KZT', 'Tenge', 'Kazakhstani tenge']]],
  ['KW', 'Kuwait', 'as', ['Kuwait City'], ['Arabic'], [], [['KWD', 'Dinar', 'Kuwaiti dinar']]],
  ['KG', 'Kyrgyzstan', 'as', ['Bishkek'], ['Kyrgyz', 'Russian'], [], [['KGS', 'Som', 'Kyrgyzstani som']]],
  ['LA', 'Laos', 'as', ['Vientiane'], ['Lao'], [], [['LAK', 'Kip', 'Lao kip']]],
  ['LB', 'Lebanon', 'as', ['Beirut'], ['Arabic'], ['French', 'Armenian'], [['LBP', 'Pound', 'Lebanese pound']]],
  ['MY', 'Malaysia', 'as', ['Kuala Lumpur', 'Putrajaya'], ['Malay'], ['English', 'Indonesian', 'Chinese', 'Tamil'], [['MYR', 'Ringgit', 'Malaysian ringgit']]],
  ['MV', 'Maldives', 'as', ['Malé'], ['Dhivehi'], ['English'], [['MVR', 'Rufiyaa', 'Maldivian rufiyaa']]],
  ['MN', 'Mongolia', 'as', ['Ulaanbaatar'], ['Mongolian'], ['Kazakh'], [['MNT', 'Tugrik', 'Mongolian tugrik']]],
  ['MM', 'Myanmar', 'as', ['Naypyidaw'], ['Burmese'], [], [['MMK', 'Kyat', 'Myanmar kyat']]],
  ['NP', 'Nepal', 'as', ['Kathmandu'], ['Nepali'], ['Maithili', 'Bhojpuri', 'Hindi', 'Tharu', 'Newar'], [['NPR', 'Rupee', 'Nepalese rupee']]],
  ['KP', 'North Korea', 'as', ['Pyongyang'], ['Korean'], [], [['KPW', 'Won', 'North Korean won']]],
  ['OM', 'Oman', 'as', ['Muscat'], ['Arabic'], [], [['OMR', 'Rial', 'Omani rial']]],
  ['PK', 'Pakistan', 'as', ['Islamabad'], ['Urdu', 'English'], ['Punjabi', 'Sindhi', 'Pashto', 'Balochi', 'Saraiki'], [['PKR', 'Rupee', 'Pakistani rupee']]],
  ['PH', 'Philippines', 'as', ['Manila'], ['Filipino', 'English'], ['Spanish', 'Arabic'], [['PHP', 'Peso', 'Philippine peso']]],
  ['QA', 'Qatar', 'as', ['Doha'], ['Arabic'], [], [['QAR', 'Riyal', 'Qatari riyal']]],
  ['SA', 'Saudi Arabia', 'as', ['Riyadh'], ['Arabic'], [], [['SAR', 'Riyal', 'Saudi riyal']]],
  ['SG', 'Singapore', 'as', ['Singapore'], ['English', 'Malay', 'Chinese', 'Tamil'], [], [['SGD', 'Dollar', 'Singapore dollar'], ['BND', 'Dollar', 'Brunei dollar']]],
  ['KR', 'South Korea', 'as', ['Seoul'], ['Korean'], [], [['KRW', 'Won', 'South Korean won']]],
  ['LK', 'Sri Lanka', 'as', ['Colombo', 'Sri Jayawardenepura Kotte'], ['Sinhala', 'Tamil'], ['English'], [['LKR', 'Rupee', 'Sri Lankan rupee']]],
  ['SY', 'Syria', 'as', ['Damascus'], ['Arabic'], ['Kurdish'], [['SYP', 'Pound', 'Syrian pound']]],
  ['TJ', 'Tajikistan', 'as', ['Dushanbe'], ['Tajik'], ['Russian', 'Persian'], [['TJS', 'Somoni', 'Tajikistani somoni']]],
  ['TH', 'Thailand', 'as', ['Bangkok'], ['Thai'], [], [['THB', 'Baht', 'Thai baht']]],
  ['TL', 'Timor-Leste', 'as', ['Dili'], ['Tetum', 'Portuguese'], ['Indonesian', 'English'], [USD]],
  ['TR', 'Turkey', 'as', ['Ankara'], ['Turkish'], ['Kurdish'], [['TRY', 'Lira', 'Turkish lira']]],
  ['TM', 'Turkmenistan', 'as', ['Ashgabat'], ['Turkmen'], ['Russian'], [['TMT', 'Manat', 'Turkmenistan manat']]],
  ['AE', 'United Arab Emirates', 'as', ['Abu Dhabi'], ['Arabic'], ['English'], [['AED', 'Dirham', 'UAE dirham']]],
  ['UZ', 'Uzbekistan', 'as', ['Tashkent'], ['Uzbek'], ['Karakalpak', 'Russian', 'Tajik'], [['UZS', 'Som', 'Uzbekistani som']]],
  ['VN', 'Vietnam', 'as', ['Hanoi'], ['Vietnamese'], [], [['VND', 'Dong', 'Vietnamese dong']]],
  ['YE', 'Yemen', 'as', ['Sanaa', 'Aden'], ['Arabic'], [], [['YER', 'Rial', 'Yemeni rial']]],

  // ── Europe (43) ──
  ['AL', 'Albania', 'eu', ['Tirana'], ['Albanian'], ['Greek', 'Macedonian'], [['ALL', 'Lek', 'Albanian lek']]],
  ['AD', 'Andorra', 'eu', ['Andorra la Vella'], ['Catalan'], ['Spanish', 'French'], [EUR]],
  ['AT', 'Austria', 'eu', ['Vienna'], ['German'], ['Slovene', 'Croatian', 'Hungarian'], [EUR]],
  ['BY', 'Belarus', 'eu', ['Minsk'], ['Belarusian', 'Russian'], [], [['BYN', 'Ruble', 'Belarusian ruble']]],
  ['BE', 'Belgium', 'eu', ['Brussels'], ['Dutch', 'French', 'German'], [], [EUR]],
  ['BA', 'Bosnia and Herzegovina', 'eu', ['Sarajevo'], ['Bosnian', 'Croatian', 'Serbian'], [], [['BAM', 'Convertible mark', 'Bosnia and Herzegovina convertible mark']]],
  ['BG', 'Bulgaria', 'eu', ['Sofia'], ['Bulgarian'], ['Turkish'], [EUR, ['BGN', 'Lev', 'Bulgarian lev (replaced by the euro in 2026)']]],
  ['HR', 'Croatia', 'eu', ['Zagreb'], ['Croatian'], ['Serbian', 'Italian', 'Hungarian', 'Czech', 'Slovak'], [EUR]],
  ['CZ', 'Czech Republic', 'eu', ['Prague'], ['Czech'], ['Slovak'], [['CZK', 'Koruna', 'Czech koruna']]],
  ['DK', 'Denmark', 'eu', ['Copenhagen'], ['Danish'], ['German', 'Faroese', 'Greenlandic'], [['DKK', 'Krone', 'Danish krone']]],
  ['EE', 'Estonia', 'eu', ['Tallinn'], ['Estonian'], [], [EUR]],
  ['FI', 'Finland', 'eu', ['Helsinki'], ['Finnish', 'Swedish'], ['Sámi'], [EUR]],
  ['FR', 'France', 'eu', ['Paris'], ['French'], [], [EUR]],
  ['DE', 'Germany', 'eu', ['Berlin'], ['German'], ['Danish', 'Sorbian', 'Frisian', 'Low German', 'Romani'], [EUR]],
  ['GR', 'Greece', 'eu', ['Athens'], ['Greek'], [], [EUR]],
  ['HU', 'Hungary', 'eu', ['Budapest'], ['Hungarian'], [], [['HUF', 'Forint', 'Hungarian forint']]],
  ['IS', 'Iceland', 'eu', ['Reykjavík'], ['Icelandic'], [], [['ISK', 'Króna', 'Icelandic króna']]],
  ['IE', 'Ireland', 'eu', ['Dublin'], ['Irish', 'English'], [], [EUR]],
  ['IT', 'Italy', 'eu', ['Rome'], ['Italian'], ['German', 'French', 'Slovene', 'Ladin', 'Sardinian'], [EUR]],
  ['LV', 'Latvia', 'eu', ['Riga'], ['Latvian'], ['Latgalian', 'Livonian'], [EUR]],
  ['LI', 'Liechtenstein', 'eu', ['Vaduz'], ['German'], [], [['CHF', 'Franc', 'Swiss franc']]],
  ['LT', 'Lithuania', 'eu', ['Vilnius'], ['Lithuanian'], [], [EUR]],
  ['LU', 'Luxembourg', 'eu', ['Luxembourg'], ['Luxembourgish', 'French', 'German'], [], [EUR]],
  ['MT', 'Malta', 'eu', ['Valletta'], ['Maltese', 'English'], [], [EUR]],
  ['MD', 'Moldova', 'eu', ['Chișinău'], ['Romanian'], ['Russian', 'Gagauz', 'Ukrainian'], [['MDL', 'Leu', 'Moldovan leu']]],
  ['MC', 'Monaco', 'eu', ['Monaco'], ['French'], ['Italian', 'Monégasque'], [EUR]],
  ['ME', 'Montenegro', 'eu', ['Podgorica'], ['Montenegrin'], ['Serbian', 'Bosnian', 'Albanian', 'Croatian'], [EUR]],
  ['NL', 'Netherlands', 'eu', ['Amsterdam', 'The Hague'], ['Dutch'], ['Frisian', 'Papiamento', 'English'], [EUR, USD]],
  ['MK', 'North Macedonia', 'eu', ['Skopje'], ['Macedonian', 'Albanian'], [], [['MKD', 'Denar', 'Macedonian denar']]],
  ['NO', 'Norway', 'eu', ['Oslo'], ['Norwegian', 'Sámi'], ['Kven'], [['NOK', 'Krone', 'Norwegian krone']]],
  ['PL', 'Poland', 'eu', ['Warsaw'], ['Polish'], ['Kashubian', 'German', 'Belarusian', 'Lithuanian', 'Silesian'], [['PLN', 'Złoty', 'Polish złoty']]],
  ['PT', 'Portugal', 'eu', ['Lisbon'], ['Portuguese'], ['Mirandese'], [EUR]],
  ['RO', 'Romania', 'eu', ['Bucharest'], ['Romanian'], ['Hungarian'], [['RON', 'Leu', 'Romanian leu']]],
  ['RU', 'Russia', 'eu', ['Moscow'], ['Russian'], ['Tatar', 'Bashkir', 'Chechen', 'Ukrainian', 'Azerbaijani', 'Kazakh'], [['RUB', 'Ruble', 'Russian ruble']]],
  ['SM', 'San Marino', 'eu', ['San Marino'], ['Italian'], [], [EUR]],
  ['RS', 'Serbia', 'eu', ['Belgrade'], ['Serbian'], ['Hungarian', 'Croatian', 'Bosnian', 'Albanian', 'Romanian', 'Slovak', 'Rusyn'], [['RSD', 'Dinar', 'Serbian dinar']]],
  ['SK', 'Slovakia', 'eu', ['Bratislava'], ['Slovak'], ['Hungarian', 'Czech', 'Rusyn'], [EUR]],
  ['SI', 'Slovenia', 'eu', ['Ljubljana'], ['Slovene'], ['Italian', 'Hungarian'], [EUR]],
  ['ES', 'Spain', 'eu', ['Madrid'], ['Spanish'], ['Catalan', 'Basque', 'Galician', 'Occitan'], [EUR]],
  ['SE', 'Sweden', 'eu', ['Stockholm'], ['Swedish'], ['Finnish', 'Meänkieli', 'Sámi', 'Romani', 'Yiddish'], [['SEK', 'Krona', 'Swedish krona']]],
  ['CH', 'Switzerland', 'eu', ['Bern'], ['German', 'French', 'Italian', 'Romansh'], [], [['CHF', 'Franc', 'Swiss franc']]],
  ['UA', 'Ukraine', 'eu', ['Kyiv'], ['Ukrainian'], ['Crimean Tatar'], [['UAH', 'Hryvnia', 'Ukrainian hryvnia']]],
  ['GB', 'United Kingdom', 'eu', ['London'], ['English'], ['Welsh', 'Irish', 'Scottish Gaelic', 'Scots', 'Cornish', 'Ulster Scots'], [['GBP', 'Pound', 'pound sterling']]],

  // ── North America (23), Central America and the Caribbean included ──
  ['AG', 'Antigua and Barbuda', 'na', ["St. John's"], ['English'], [], [XCD]],
  ['BS', 'Bahamas', 'na', ['Nassau'], ['English'], [], [['BSD', 'Dollar', 'Bahamian dollar'], USD]],
  ['BB', 'Barbados', 'na', ['Bridgetown'], ['English'], [], [['BBD', 'Dollar', 'Barbadian dollar']]],
  ['BZ', 'Belize', 'na', ['Belmopan'], ['English'], ['Spanish', 'Kriol'], [['BZD', 'Dollar', 'Belize dollar']]],
  ['CA', 'Canada', 'na', ['Ottawa'], ['English', 'French'], [], [['CAD', 'Dollar', 'Canadian dollar']]],
  ['CR', 'Costa Rica', 'na', ['San José'], ['Spanish'], [], [['CRC', 'Colón', 'Costa Rican colón']]],
  ['CU', 'Cuba', 'na', ['Havana'], ['Spanish'], [], [['CUP', 'Peso', 'Cuban peso']]],
  ['DM', 'Dominica', 'na', ['Roseau'], ['English'], [], [XCD]],
  ['DO', 'Dominican Republic', 'na', ['Santo Domingo'], ['Spanish'], [], [['DOP', 'Peso', 'Dominican peso']]],
  ['SV', 'El Salvador', 'na', ['San Salvador'], ['Spanish'], [], [USD]],
  ['GD', 'Grenada', 'na', ["St. George's"], ['English'], [], [XCD]],
  ['GT', 'Guatemala', 'na', ['Guatemala City'], ['Spanish'], [], [['GTQ', 'Quetzal', 'Guatemalan quetzal']]],
  ['HT', 'Haiti', 'na', ['Port-au-Prince'], ['Haitian Creole', 'French'], [], [['HTG', 'Gourde', 'Haitian gourde']]],
  ['HN', 'Honduras', 'na', ['Tegucigalpa'], ['Spanish'], [], [['HNL', 'Lempira', 'Honduran lempira']]],
  ['JM', 'Jamaica', 'na', ['Kingston'], ['English'], ['Jamaican Patois'], [['JMD', 'Dollar', 'Jamaican dollar']]],
  ['MX', 'Mexico', 'na', ['Mexico City'], ['Spanish'], ['Nahuatl', 'Yucatec Maya'], [['MXN', 'Peso', 'Mexican peso']]],
  ['NI', 'Nicaragua', 'na', ['Managua'], ['Spanish'], ['Miskito', 'English'], [['NIO', 'Córdoba', 'Nicaraguan córdoba']]],
  ['PA', 'Panama', 'na', ['Panama City'], ['Spanish'], [], [['PAB', 'Balboa', 'Panamanian balboa'], USD]],
  ['KN', 'Saint Kitts and Nevis', 'na', ['Basseterre'], ['English'], [], [XCD]],
  ['LC', 'Saint Lucia', 'na', ['Castries'], ['English'], ['French'], [XCD]],
  ['VC', 'Saint Vincent and the Grenadines', 'na', ['Kingstown'], ['English'], [], [XCD]],
  ['TT', 'Trinidad and Tobago', 'na', ['Port of Spain'], ['English'], [], [['TTD', 'Dollar', 'Trinidad and Tobago dollar']]],
  ['US', 'United States', 'na', ['Washington, D.C.'], ['English'], ['Spanish', 'Hawaiian', 'Samoan', 'Chamorro', 'Carolinian'], [USD]],

  // ── South America (12) ──
  ['AR', 'Argentina', 'sa', ['Buenos Aires'], ['Spanish'], ['Guarani'], [['ARS', 'Peso', 'Argentine peso']]],
  ['BO', 'Bolivia', 'sa', ['Sucre', 'La Paz'], ['Spanish', 'Quechua', 'Aymara', 'Guarani'], [], [['BOB', 'Boliviano', 'Bolivian boliviano']]],
  ['BR', 'Brazil', 'sa', ['Brasília'], ['Portuguese'], [], [['BRL', 'Real', 'Brazilian real']]],
  ['CL', 'Chile', 'sa', ['Santiago'], ['Spanish'], [], [['CLP', 'Peso', 'Chilean peso']]],
  ['CO', 'Colombia', 'sa', ['Bogotá'], ['Spanish'], [], [['COP', 'Peso', 'Colombian peso']]],
  ['EC', 'Ecuador', 'sa', ['Quito'], ['Spanish'], ['Kichwa', 'Shuar'], [USD]],
  ['GY', 'Guyana', 'sa', ['Georgetown'], ['English'], [], [['GYD', 'Dollar', 'Guyanese dollar']]],
  ['PY', 'Paraguay', 'sa', ['Asunción'], ['Spanish', 'Guarani'], [], [['PYG', 'Guaraní', 'Paraguayan guaraní']]],
  ['PE', 'Peru', 'sa', ['Lima'], ['Spanish', 'Quechua', 'Aymara'], [], [['PEN', 'Sol', 'Peruvian sol']]],
  ['SR', 'Suriname', 'sa', ['Paramaribo'], ['Dutch'], ['Sranan Tongo'], [['SRD', 'Dollar', 'Surinamese dollar']]],
  ['UY', 'Uruguay', 'sa', ['Montevideo'], ['Spanish'], [], [['UYU', 'Peso', 'Uruguayan peso']]],
  ['VE', 'Venezuela', 'sa', ['Caracas'], ['Spanish'], [], [['VES', 'Bolívar', 'Venezuelan bolívar']]],

  // ── Oceania (14) ──
  ['AU', 'Australia', 'oc', ['Canberra'], ['English'], [], [AUD]],
  ['FJ', 'Fiji', 'oc', ['Suva'], ['English', 'Fijian', 'Fiji Hindi'], ['Hindi'], [['FJD', 'Dollar', 'Fijian dollar']]],
  ['KI', 'Kiribati', 'oc', ['South Tarawa'], ['English', 'Gilbertese'], [], [AUD]],
  ['MH', 'Marshall Islands', 'oc', ['Majuro'], ['Marshallese', 'English'], [], [USD]],
  ['FM', 'Micronesia', 'oc', ['Palikir'], ['English'], [], [USD]],
  ['NR', 'Nauru', 'oc', ['Yaren'], ['Nauruan', 'English'], [], [AUD]],
  ['NZ', 'New Zealand', 'oc', ['Wellington'], ['English', 'Māori'], [], [['NZD', 'Dollar', 'New Zealand dollar']]],
  ['PW', 'Palau', 'oc', ['Ngerulmud'], ['Palauan', 'English'], ['Japanese'], [USD]],
  ['PG', 'Papua New Guinea', 'oc', ['Port Moresby'], ['English', 'Tok Pisin', 'Hiri Motu'], [], [['PGK', 'Kina', 'Papua New Guinean kina']]],
  ['WS', 'Samoa', 'oc', ['Apia'], ['Samoan', 'English'], [], [['WST', 'Tala', 'Samoan tala']]],
  ['SB', 'Solomon Islands', 'oc', ['Honiara'], ['English'], ['Pijin'], [['SBD', 'Dollar', 'Solomon Islands dollar']]],
  ['TO', 'Tonga', 'oc', ["Nuku'alofa"], ['Tongan', 'English'], [], [['TOP', "Pa'anga", "Tongan pa'anga"]]],
  ['TV', 'Tuvalu', 'oc', ['Funafuti'], ['Tuvaluan', 'English'], [], [AUD]],
  ['VU', 'Vanuatu', 'oc', ['Port Vila'], ['Bislama', 'English', 'French'], [], [['VUV', 'Vatu', 'Vanuatu vatu']]],
]

/** Transcontinental countries: the other continent is never a wrong choice. */
export const ALSO_CONTINENT: Record<string, Continent[]> = {
  RU: ['as'], TR: ['eu'], KZ: ['eu'], AZ: ['eu'], GE: ['eu'], AM: ['eu'], CY: ['eu'],
  EG: ['as'], ID: ['oc'], TL: ['oc'], PA: ['sa'],
}

/** Flags so alike that putting them side by side is a trick, not a test. */
export const LOOKALIKE_FLAGS: [string, string][] = [
  ['ID', 'MC'], ['TD', 'RO'], ['IE', 'CI'], ['NL', 'LU'], ['AU', 'NZ'], ['ML', 'GN'], ['SN', 'ML'], ['SI', 'SK'],
]

/** Wikidata names that mean the same language as a curated name. Used so
 *  Wikidata's lists exclude the right distractors. */
export const LANGUAGE_ALIASES: Record<string, string> = {
  'Bangla': 'Bengali', 'Modern Greek': 'Greek', 'Standard Chinese': 'Chinese', 'Putonghua': 'Chinese',
  'Mandarin Chinese': 'Chinese', 'Modern Standard Arabic': 'Arabic', 'Kurdish language': 'Kurdish',
  'Australian English': 'English', 'British English': 'English', 'American English': 'English',
  'Maldivian': 'Dhivehi', 'Chewa': 'Chichewa', 'Bokmål': 'Norwegian', 'Nynorsk': 'Norwegian',
  'Standard Algerian Berber': 'Berber', 'Standard Moroccan Tamazight': 'Berber', 'Tamazight': 'Berber',
  'Northern Quichua': 'Kichwa', 'Hassaniya Arabic': 'Arabic', 'North Korean standard language': 'Korean',
  'Taglish': 'Filipino', 'Fula': 'Fula', 'Mooré': 'Mooré', 'Swazi': 'Swazi', 'Sesotho': 'Sesotho',
}

/**
 * Every place a curated value differs from Wikidata, and why. The build fails
 * on any difference missing from here, so this list is complete by
 * construction. Keys: `${iso}:capital:${name}`, `${iso}:language:${name}`,
 * `${iso}:currency:${code}`.
 */
export const REASONS: Record<string, string> = {
  'AG:capital:St. John\'s': 'Wikidata has no current capital statement for Antigua and Barbuda. St. John\'s is its capital, pinned to Wikidata item Q36262 (CAPITAL_ITEMS).',
  'SD:capital:Port Sudan': 'The government has worked from Port Sudan since 2023. Khartoum is still the capital in law.',
  'CI:capital:Abidjan': 'Former capital (Wikidata end date 1983) and still the seat of most government work, so never a wrong answer.',
  'TZ:capital:Dar es Salaam': 'Former capital (Wikidata end date 1996) where much of the government still sits, so never a wrong answer.',
  'BI:capital:Bujumbura': 'Former capital (Wikidata end date 2019) and still the economic capital, so never a wrong answer.',
  'BW:language:Tswana': 'Setswana is the national language of Botswana (constitution), Wikidata lists only English.',
  'BF:language:Fula': 'One of the national languages made official by the 2023 constitution, Wikidata lists three of them.',
  'US:language:English': 'English became the official language of the United States by executive order in March 2025. Wikidata still lists only territory languages.',
  'UY:language:Spanish': 'Wikidata has no official-language statement for Uruguay. Spanish is the national language by law.',
  // Currencies
  'AD:currency:EUR': 'Wikidata has no current currency statement for most euro countries. The euro is their currency.',
  'AT:currency:EUR': 'Euro area member.', 'BE:currency:EUR': 'Euro area member.', 'HR:currency:EUR': 'Euro area member since 2023.',
  'CY:currency:EUR': 'Euro area member.', 'EE:currency:EUR': 'Euro area member.', 'FI:currency:EUR': 'Euro area member.',
  'FR:currency:EUR': 'Euro area member.', 'DE:currency:EUR': 'Euro area member.', 'GR:currency:EUR': 'Euro area member.',
  'IE:currency:EUR': 'Euro area member.', 'IT:currency:EUR': 'Euro area member.', 'LV:currency:EUR': 'Euro area member.',
  'LT:currency:EUR': 'Euro area member since 2015, Wikidata wrongly shows the talonas of the 1990s.',
  'LU:currency:EUR': 'Euro area member.', 'MT:currency:EUR': 'Euro area member.', 'NL:currency:EUR': 'Euro area member.',
  'PT:currency:EUR': 'Euro area member.', 'SK:currency:EUR': 'Euro area member.', 'SI:currency:EUR': 'Euro area member.',
  'ES:currency:EUR': 'Euro area member.', 'MC:currency:EUR': 'Uses the euro by agreement with the EU.',
  'SM:currency:EUR': 'Uses the euro by agreement with the EU.', 'ME:currency:EUR': 'Uses the euro without an agreement.',
  'BG:currency:EUR': 'Bulgaria joined the euro area on 1 January 2026.',
  'BG:currency:BGN': 'The lev, replaced by the euro in 2026. Kept so it is never offered as a wrong answer.',
  'SZ:currency:ZAR': 'The rand is legal tender in Eswatini alongside the lilangeni.',
  'BS:currency:USD': 'Accepted everywhere at par with the Bahamian dollar.',
  'BT:currency:INR': 'The Indian rupee circulates at par with the ngultrum.',
  'BN:currency:SGD': 'Brunei and Singapore dollars are interchangeable at par.',
  'SG:currency:BND': 'Brunei and Singapore dollars are interchangeable at par.',
  'KH:currency:USD': 'US dollars are used everyday alongside the riel.',
  // Continents and capitals
  'CY:continent': 'UN M49 puts Cyprus in Western Asia. Kids often learn it as Europe, so Europe is never offered as a wrong answer.',
  'GE:continent': 'UN M49 puts Georgia in Western Asia. Europe is never offered as a wrong answer.',
  'NL:capital:The Hague': 'Amsterdam is the capital in the constitution, The Hague is the seat of government. Never a wrong answer.',
}

/** Curated capital name → the Wikidata label of the same place, where the
 *  name kids learn differs. */
export const CAPITAL_ALIASES: Record<string, string> = {
  'NR:Yaren': 'Yaren District',
}

/** Capitals Wikidata does not link to their country at all, pinned to their
 *  Wikidata item by hand (checked: Q36262 is described as the capital and
 *  largest city of Antigua and Barbuda). */
export const CAPITAL_ITEMS: Record<string, string> = {
  "AG:St. John's": 'Q36262',
}
