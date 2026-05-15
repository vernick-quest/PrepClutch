-- Seed achievement definitions
insert into achievement_definitions (key, label, description, icon_emoji, threshold) values
  ('first_blood', 'First Blood', 'Complete your first quiz', '🩸', 1),
  ('sharp_shooter', 'Sharp Shooter', 'Score 100% on any section', '🎯', 1),
  ('speed_demon', 'Speed Demon', 'Answer 5 questions in a row under 10 seconds', '⚡', 5),
  ('all_rounder', 'All-Rounder', 'Complete all 5 sections at least once', '🌟', 5),
  ('top_of_class', 'Top of the Class', 'Reach #1 on the leaderboard', '👑', 1),
  ('verbal_ace', 'Verbal Ace', 'Score 90%+ on Verbal Skills', '📚', 9),
  ('math_ace', 'Math Ace', 'Score 90%+ on Mathematics', '➕', 9),
  ('reading_ace', 'Reading Ace', 'Score 90%+ on Reading Comprehension', '📖', 9),
  ('quant_ace', 'Quant Ace', 'Score 90%+ on Quantitative Skills', '🔢', 9),
  ('language_ace', 'Language Ace', 'Score 90%+ on Language Skills', '✏️', 9);

-- =====================
-- VERBAL SKILLS (10 questions)
-- =====================
insert into questions (section, prompt, options, correct_index, difficulty, explanation) values

('verbal', 'Choose the word most similar in meaning to BENEVOLENT:',
 '["Malicious", "Hostile", "Charitable", "Greedy"]', 2, 1,
 'BENEVOLENT means well-meaning and kindly. CHARITABLE is the closest synonym, meaning generous and giving to those in need.'),

('verbal', 'Choose the word most OPPOSITE in meaning to INDOLENT:',
 '["Lazy", "Energetic", "Wealthy", "Proud"]', 1, 1,
 'INDOLENT means habitually lazy. Its antonym is ENERGETIC — full of activity and effort.'),

('verbal', 'Complete the analogy: AUTHOR is to BOOK as COMPOSER is to ___',
 '["Concert", "Symphony", "Orchestra", "Melody"]', 1, 2,
 'An AUTHOR creates a BOOK. A COMPOSER creates a SYMPHONY. The relationship is creator to creation.'),

('verbal', 'Which word does NOT belong with the others?',
 '["Crimson", "Azure", "Scarlet", "Maroon"]', 1, 1,
 'CRIMSON, SCARLET, and MAROON are all shades of red. AZURE is a shade of blue, so it does not belong.'),

('verbal', 'If all ROSES are FLOWERS, and some FLOWERS are RED, which conclusion is certain?',
 '["All roses are red", "Some roses are red", "No roses are red", "Some flowers are roses"]', 3, 2,
 'Since all roses are flowers, it follows logically that some flowers are roses. We cannot conclude anything certain about rose color.'),

('verbal', 'Choose the word most similar in meaning to VERBOSE:',
 '["Brief", "Wordy", "Quiet", "Angry"]', 1, 2,
 'VERBOSE means using more words than necessary. WORDY is the correct synonym.'),

('verbal', 'Complete the analogy: DOCTOR is to HOSPITAL as JUDGE is to ___',
 '["Law", "Courthouse", "Trial", "Lawyer"]', 1, 1,
 'A DOCTOR works in a HOSPITAL. A JUDGE works in a COURTHOUSE. The relationship is professional to workplace.'),

('verbal', 'Which word is most OPPOSITE in meaning to FRUGAL?',
 '["Careful", "Thrifty", "Extravagant", "Simple"]', 2, 2,
 'FRUGAL means economical with money. EXTRAVAGANT, meaning spending freely or excessively, is its antonym.'),

('verbal', 'Tom is taller than Sam. Sam is taller than Mike. Which statement must be true?',
 '["Mike is taller than Tom", "Tom is the tallest", "Sam is the tallest", "Mike is taller than Sam"]', 1, 2,
 'If Tom > Sam > Mike, then Tom is the tallest of the three.'),

('verbal', 'Choose the word most similar in meaning to ARDUOUS:',
 '["Easy", "Strenuous", "Short", "Pleasant"]', 1, 2,
 'ARDUOUS means involving strenuous effort. STRENUOUS is its closest synonym, meaning requiring great effort.');

-- =====================
-- QUANTITATIVE SKILLS (10 questions)
-- =====================
insert into questions (section, prompt, options, correct_index, difficulty, explanation) values

('quantitative', 'What number comes next in the series? 2, 5, 8, 11, ___',
 '["12", "13", "14", "15"]', 2, 1,
 'Each number increases by 3. After 11, add 3 to get 14.'),

('quantitative', 'What number comes next in the series? 3, 6, 12, 24, ___',
 '["36", "40", "48", "52"]', 2, 1,
 'Each number is doubled. 24 × 2 = 48.'),

('quantitative', 'What number comes next in the series? 1, 4, 9, 16, ___',
 '["20", "25", "24", "36"]', 1, 2,
 'These are perfect squares: 1², 2², 3², 4², 5² = 25.'),

('quantitative', 'Which figure has the greatest area? All shapes use the same 12-unit perimeter.',
 '["Equilateral triangle", "Square", "Regular hexagon", "Circle"]', 3, 3,
 'For a fixed perimeter, the circle encloses the greatest area (isoperimetric inequality).'),

('quantitative', 'What number comes next in the series? 100, 81, 64, 49, ___',
 '["36", "40", "25", "16"]', 0, 2,
 'These are decreasing perfect squares: 10², 9², 8², 7², 6² = 36.'),

('quantitative', 'If ▲ = 3 and ○ = 5, what is ▲ + ▲ × ○?',
 '["18", "30", "21", "25"]', 0, 2,
 'Using order of operations: ▲ × ○ first = 3 × 5 = 15, then + ▲ = 15 + 3 = 18.'),

('quantitative', 'What number comes next in the series? 2, 3, 5, 8, 13, ___',
 '["18", "20", "21", "24"]', 2, 2,
 'This is the Fibonacci sequence — each number is the sum of the two before it: 8 + 13 = 21.'),

('quantitative', 'A rectangle has a length twice its width. If the perimeter is 36, what is the area?',
 '["72", "81", "108", "54"]', 0, 3,
 'Let width = w, length = 2w. Perimeter: 2(w + 2w) = 36 → 6w = 36 → w = 6, length = 12. Area = 6 × 12 = 72.'),

('quantitative', 'What number comes next in the series? 1, 2, 6, 24, ___',
 '["48", "100", "120", "96"]', 2, 3,
 'Each term is multiplied by an increasing factor: ×2, ×3, ×4, ×5. So 24 × 5 = 120.'),

('quantitative', 'Which is greater: 3/5 or 5/8?',
 '["3/5 is greater", "5/8 is greater", "They are equal", "Cannot determine"]', 1, 2,
 '3/5 = 0.60 and 5/8 = 0.625. Since 0.625 > 0.60, 5/8 is greater.');

-- =====================
-- READING COMPREHENSION (10 questions — 2 passages)
-- =====================
insert into questions (section, prompt, passage, options, correct_index, difficulty, explanation) values

('reading',
 'What is the main topic of this passage?',
 'The Amazon rainforest, often called the "lungs of the Earth," produces about 20% of the world''s oxygen through photosynthesis. Spanning over 5.5 million square kilometers across nine South American countries, it is home to an estimated 10% of all species on Earth. Scientists estimate that a single hectare of rainforest may contain over 750 tree species and 1,500 species of higher plants. Despite its importance, the Amazon faces serious threats from deforestation, primarily driven by agriculture, cattle ranching, and logging. Between 2000 and 2020, approximately 400,000 square kilometers of forest were lost — an area larger than Germany.',
 '["Climate change effects on South America", "The importance and threats facing the Amazon rainforest", "How photosynthesis works in tropical environments", "The economic benefits of cattle ranching"]',
 1, 1,
 'The passage introduces the Amazon''s importance (oxygen, biodiversity) and then discusses the threats it faces. This makes option B the most accurate summary of the main topic.'),

('reading',
 'According to the passage, approximately what fraction of Earth''s species live in the Amazon?',
 'The Amazon rainforest, often called the "lungs of the Earth," produces about 20% of the world''s oxygen through photosynthesis. Spanning over 5.5 million square kilometers across nine South American countries, it is home to an estimated 10% of all species on Earth. Scientists estimate that a single hectare of rainforest may contain over 750 tree species and 1,500 species of higher plants. Despite its importance, the Amazon faces serious threats from deforestation, primarily driven by agriculture, cattle ranching, and logging. Between 2000 and 2020, approximately 400,000 square kilometers of forest were lost — an area larger than Germany.',
 '["1/4", "1/5", "1/10", "1/2"]',
 2, 1,
 'The passage states the Amazon is home to "an estimated 10% of all species on Earth." 10% = 1/10.'),

('reading',
 'What does the author most likely mean by calling the Amazon the "lungs of the Earth"?',
 'The Amazon rainforest, often called the "lungs of the Earth," produces about 20% of the world''s oxygen through photosynthesis. Spanning over 5.5 million square kilometers across nine South American countries, it is home to an estimated 10% of all species on Earth. Scientists estimate that a single hectare of rainforest may contain over 750 tree species and 1,500 species of higher plants. Despite its importance, the Amazon faces serious threats from deforestation, primarily driven by agriculture, cattle ranching, and logging. Between 2000 and 2020, approximately 400,000 square kilometers of forest were lost — an area larger than Germany.',
 '["The Amazon is shaped like a pair of lungs", "The Amazon produces a large share of Earth''s oxygen", "People breathe better in rainforests", "The Amazon absorbs carbon monoxide"]',
 1, 2,
 'The metaphor "lungs of the Earth" refers to the Amazon''s role in producing oxygen — just as lungs provide oxygen to the body.'),

('reading',
 'Which primary cause of Amazon deforestation is NOT mentioned in the passage?',
 'The Amazon rainforest, often called the "lungs of the Earth," produces about 20% of the world''s oxygen through photosynthesis. Spanning over 5.5 million square kilometers across nine South American countries, it is home to an estimated 10% of all species on Earth. Scientists estimate that a single hectare of rainforest may contain over 750 tree species and 1,500 species of higher plants. Despite its importance, the Amazon faces serious threats from deforestation, primarily driven by agriculture, cattle ranching, and logging. Between 2000 and 2020, approximately 400,000 square kilometers of forest were lost — an area larger than Germany.',
 '["Cattle ranching", "Logging", "Mining", "Agriculture"]',
 2, 2,
 'The passage lists agriculture, cattle ranching, and logging as causes of deforestation. Mining is not mentioned.'),

('reading',
 'Based on the passage, which statement best describes the scale of deforestation from 2000 to 2020?',
 'The Amazon rainforest, often called the "lungs of the Earth," produces about 20% of the world''s oxygen through photosynthesis. Spanning over 5.5 million square kilometers across nine South American countries, it is home to an estimated 10% of all species on Earth. Scientists estimate that a single hectare of rainforest may contain over 750 tree species and 1,500 species of higher plants. Despite its importance, the Amazon faces serious threats from deforestation, primarily driven by agriculture, cattle ranching, and logging. Between 2000 and 2020, approximately 400,000 square kilometers of forest were lost — an area larger than Germany.',
 '["An area smaller than Texas was lost", "An area larger than Germany was lost", "Half of the Amazon was destroyed", "About 1 million square kilometers were lost"]',
 1, 1,
 'The passage directly states "approximately 400,000 square kilometers of forest were lost — an area larger than Germany."'),

('reading',
 'What is the author''s main purpose in the second passage?',
 'Marie Curie was born Maria Sklodowska in Warsaw, Poland, in 1867. Growing up under Russian rule, she was barred from attending university in Poland because of her gender. Determined to pursue her education, she made an agreement with her sister: each would work to support the other''s studies abroad. Marie worked as a governess to fund her sister''s medical degree in Paris. When her sister graduated, Marie traveled to Paris and enrolled at the Sorbonne, where she earned degrees in both physics and mathematics. She later became the first woman to win a Nobel Prize — and the only person to win Nobel Prizes in two different scientific fields: Physics (1903) and Chemistry (1911). Her work on radioactivity fundamentally changed our understanding of atomic structure.',
 '["To argue that women should be allowed to attend university", "To describe the life and achievements of Marie Curie", "To explain how radioactivity was discovered", "To compare Polish and French educational systems"]',
 1, 1,
 'The passage is a biographical account covering Curie''s background, struggles, and scientific accomplishments. Its main purpose is to inform the reader about her life and achievements.'),

('reading',
 'Why did Marie Curie initially work as a governess?',
 'Marie Curie was born Maria Sklodowska in Warsaw, Poland, in 1867. Growing up under Russian rule, she was barred from attending university in Poland because of her gender. Determined to pursue her education, she made an agreement with her sister: each would work to support the other''s studies abroad. Marie worked as a governess to fund her sister''s medical degree in Paris. When her sister graduated, Marie traveled to Paris and enrolled at the Sorbonne, where she earned degrees in both physics and mathematics. She later became the first woman to win a Nobel Prize — and the only person to win Nobel Prizes in two different scientific fields: Physics (1903) and Chemistry (1911). Her work on radioactivity fundamentally changed our understanding of atomic structure.',
 '["She enjoyed working with children", "She wanted to earn money for herself", "To fund her sister''s education", "She was not accepted to university yet"]',
 2, 1,
 'The passage states she "worked as a governess to fund her sister''s medical degree in Paris" as part of an agreement between the sisters.'),

('reading',
 'Which word best describes Marie Curie''s character as portrayed in the passage?',
 'Marie Curie was born Maria Sklodowska in Warsaw, Poland, in 1867. Growing up under Russian rule, she was barred from attending university in Poland because of her gender. Determined to pursue her education, she made an agreement with her sister: each would work to support the other''s studies abroad. Marie worked as a governess to fund her sister''s medical degree in Paris. When her sister graduated, Marie traveled to Paris and enrolled at the Sorbonne, where she earned degrees in both physics and mathematics. She later became the first woman to win a Nobel Prize — and the only person to win Nobel Prizes in two different scientific fields: Physics (1903) and Chemistry (1911). Her work on radioactivity fundamentally changed our understanding of atomic structure.',
 '["Timid", "Determined", "Reckless", "Indifferent"]',
 1, 2,
 'The passage describes Curie as "determined to pursue her education" despite serious obstacles — gender discrimination and financial hardship.'),

('reading',
 'What made Marie Curie unique in Nobel Prize history?',
 'Marie Curie was born Maria Sklodowska in Warsaw, Poland, in 1867. Growing up under Russian rule, she was barred from attending university in Poland because of her gender. Determined to pursue her education, she made an agreement with her sister: each would work to support the other''s studies abroad. Marie worked as a governess to fund her sister''s medical degree in Paris. When her sister graduated, Marie traveled to Paris and enrolled at the Sorbonne, where she earned degrees in both physics and mathematics. She later became the first woman to win a Nobel Prize — and the only person to win Nobel Prizes in two different scientific fields: Physics (1903) and Chemistry (1911). Her work on radioactivity fundamentally changed our understanding of atomic structure.',
 '["She was the youngest Nobel laureate", "She won Nobel Prizes in two different fields", "She shared a prize with her sister", "She declined her first Nobel Prize"]',
 1, 1,
 'The passage states she is "the only person to win Nobel Prizes in two different scientific fields."'),

('reading',
 'According to the passage, what barrier did Marie Curie face in Poland?',
 'Marie Curie was born Maria Sklodowska in Warsaw, Poland, in 1867. Growing up under Russian rule, she was barred from attending university in Poland because of her gender. Determined to pursue her education, she made an agreement with her sister: each would work to support the other''s studies abroad. Marie worked as a governess to fund her sister''s medical degree in Paris. When her sister graduated, Marie traveled to Paris and enrolled at the Sorbonne, where she earned degrees in both physics and mathematics. She later became the first woman to win a Nobel Prize — and the only person to win Nobel Prizes in two different scientific fields: Physics (1903) and Chemistry (1911). Her work on radioactivity fundamentally changed our understanding of atomic structure.',
 '["Poverty prevented her from paying tuition", "She was barred from university because of her gender", "Russian authorities expelled her", "She lacked the required entrance scores"]',
 1, 1,
 'The passage clearly states she "was barred from attending university in Poland because of her gender."');

-- =====================
-- MATHEMATICS (10 questions)
-- =====================
insert into questions (section, prompt, options, correct_index, difficulty, explanation) values

('math', 'What is 15% of 240?',
 '["36", "30", "24", "42"]', 0, 1,
 '15% of 240 = 0.15 × 240 = 36.'),

('math', 'Solve for x: 3x + 7 = 22',
 '["x = 3", "x = 5", "x = 7", "x = 4"]', 1, 1,
 '3x + 7 = 22 → 3x = 15 → x = 5.'),

('math', 'A store sells a jacket for $80 after applying a 20% discount. What was the original price?',
 '["$96", "$100", "$104", "$90"]', 1, 2,
 'If the discounted price is 80% of the original: original × 0.8 = $80 → original = $80 ÷ 0.8 = $100.'),

('math', 'What is the area of a triangle with base 12 cm and height 9 cm?',
 '["108 cm²", "54 cm²", "36 cm²", "72 cm²"]', 1, 1,
 'Area of triangle = ½ × base × height = ½ × 12 × 9 = 54 cm².'),

('math', 'If a car travels 240 miles in 4 hours, how many miles will it travel in 7 hours at the same speed?',
 '["360 miles", "400 miles", "420 miles", "480 miles"]', 2, 1,
 'Speed = 240 ÷ 4 = 60 mph. In 7 hours: 60 × 7 = 420 miles.'),

('math', 'What is 2/3 + 3/4?',
 '["5/7", "17/12", "5/12", "7/12"]', 1, 2,
 'Find common denominator (12): 8/12 + 9/12 = 17/12.'),

('math', 'A rectangle has a perimeter of 54 cm. Its length is 5 more than its width. What is the width?',
 '["11 cm", "16 cm", "10 cm", "8 cm"]', 0, 2,
 'Let width = w, length = w + 5. Perimeter: 2(w + w + 5) = 54 → 2(2w + 5) = 54 → 4w + 10 = 54 → 4w = 44 → w = 11.'),

('math', 'What is the value of 4³ − 5²?',
 '["39", "41", "35", "43"]', 1, 2,
 '4³ = 64, 5² = 25. 64 − 25 = 39. Wait — that''s 39, which is option A. Let me recheck: 4³=64, 5²=25, 64-25=39. Answer is A (index 0).'),

('math', 'Maria has $45. She spends 1/3 on lunch and 2/5 on books. How much does she have left?',
 '["$12", "$15", "$18", "$10"]', 0, 2,
 'Lunch: 1/3 × 45 = $15. Books: 2/5 × 45 = $18. Spent: $33. Left: $45 − $33 = $12.'),

('math', 'The ratio of boys to girls in a class is 3:4. If there are 28 students total, how many are boys?',
 '["16", "12", "14", "10"]', 1, 2,
 'Total parts = 3 + 4 = 7. Boys = (3/7) × 28 = 12.');

-- Fix the math question with wrong answer annotation
update questions set correct_index = 0
where section = 'math' and prompt like '%4³ − 5²%';

-- =====================
-- LANGUAGE SKILLS (10 questions)
-- =====================
insert into questions (section, prompt, options, correct_index, difficulty, explanation) values

('language', 'Choose the sentence with correct punctuation:',
 '["The team won their game but, they had to work hard.", "The team won their game, but they had to work hard.", "The team won their game but they had to work hard.", "The team won, their game but they had to work hard."]',
 1, 1,
 'When two independent clauses are joined by a coordinating conjunction (but), a comma should precede the conjunction.'),

('language', 'Which sentence is grammatically correct?',
 '["Her and I went to the store.", "She and me went to the store.", "She and I went to the store.", "Her and me went to the store."]',
 2, 1,
 '"She and I" is correct because both pronouns are subjects of the verb "went." Use subject pronouns (I, she) not object pronouns (me, her) as subjects.'),

('language', 'Which word is spelled correctly?',
 '["Occured", "Occurred", "Ocurred", "Occurrd"]',
 1, 1,
 'The correct spelling is OCCURRED — double c and double r.'),

('language', 'Choose the sentence that uses capitalization correctly:',
 '["We visited mount rushmore last Summer.", "We visited Mount Rushmore last summer.", "We visited mount Rushmore last summer.", "we visited Mount rushmore last summer."]',
 1, 1,
 '"Mount Rushmore" is a proper noun and requires capitalization. "Summer" is a common noun and should not be capitalized.'),

('language', 'Which sentence shows the best way to combine these two ideas: "The dog was wet. The dog came inside."',
 '["The wet dog, it came inside.", "The dog was wet and the dog came inside.", "The wet dog came inside.", "The dog came inside, it was wet."]',
 2, 2,
 'The most concise and grammatically sound combination is "The wet dog came inside," which eliminates repetition by using an adjective.'),

('language', 'Identify the error in this sentence: "The students turned in their homework, and the teacher graded it quick."',
 '["The comma after homework", "''quick'' should be ''quickly''", "''their'' should be ''there''", "No error"]',
 1, 1,
 'The adverb QUICKLY should modify the verb "graded," not the adjective form QUICK.'),

('language', 'Which sentence is written most clearly and correctly?',
 '["Running to the bus, her backpack fell open.", "While running to the bus, her backpack fell open.", "Her backpack fell open, running to the bus.", "Running to the bus she her backpack fell open."]',
 1, 2,
 'Option B is correct. Option A has a dangling modifier — "Running to the bus" seems to modify "backpack." Adding "While" clarifies the subject.'),

('language', 'Choose the correctly punctuated sentence with a list:',
 '["I need eggs milk, bread, and butter.", "I need eggs, milk bread, and butter.", "I need eggs, milk, bread, and butter.", "I need, eggs, milk, bread and butter."]',
 2, 1,
 'Items in a series should be separated by commas. A comma before "and" in a list (Oxford comma) is standard in formal writing.'),

('language', 'Which sentence uses an apostrophe correctly?',
 '["The dogs' bone was buried in the yard. (one dog)", "The dog''s bone was buried in the yard.", "The dogs bone was buried in the yard.", "The dog''s' bone was buried in the yard."]',
 1, 1,
 'To show possession for a singular noun, add apostrophe + s. "The dog''s bone" is correct.'),

('language', 'Identify the type of error: "Their going to the park after school."',
 '["Spelling error", "Capitalization error", "Wrong word (their/they''re)", "Punctuation error"]',
 2, 1,
 '"Their" shows possession. The sentence needs "They''re" (they are). This is a wrong-word error involving a homophone.');
