# Training content — math + language.
from fractions import Fraction as F

MATH = [
  # ── Easy ──
  dict(sort=1, diff=1, concept="Order of operations",
    prompt="What is 6 + 4 × 3?",
    options=[
      ("30", "30 adds first: (6 + 4) × 3. Without parentheses, multiplication comes before addition."),
      ("18", "Correct. Multiply first: 4 × 3 = 12. Then add: 6 + 12 = 18."),
      ("13", "13 adds all three numbers. The × sign means multiply."),
      ("22", "22 multiplies 6 × 3 and then adds 4 — the operations are attached to the wrong numbers."),
    ], answer="18", check=lambda: 6 + 4 * 3 == 18 and (6 + 4) * 3 == 30 and 6 * 3 + 4 == 22,
    explanation="Multiplication and division come before addition and subtraction, unless parentheses say otherwise. So 4 × 3 = 12 first, then 6 + 12 = 18. Reading left to right and adding 6 + 4 first is the single most common mistake on these."),

  dict(sort=2, diff=1, concept="Adding fractions",
    prompt="What is 1/2 + 1/4?",
    options=[
      ("2/6", "2/6 adds the tops and the bottoms separately. Fractions need a common denominator before you add."),
      ("1/8", "1/8 is 1/2 × 1/4 — that multiplies instead of adding."),
      ("3/4", "Correct. 1/2 is the same as 2/4, and 2/4 + 1/4 = 3/4."),
      ("2/4", "2/4 is just 1/2 rewritten. You still need to add the 1/4."),
    ], answer="3/4", check=lambda: F(1, 2) + F(1, 4) == F(3, 4) and F(1, 2) * F(1, 4) == F(1, 8),
    explanation="You can only add fractions whose bottoms (denominators) match. Rewrite 1/2 as 2/4, so both are in fourths. Then add the tops: 2/4 + 1/4 = 3/4. Never add the denominators — one fourth plus one fourth is two fourths, not two eighths."),

  dict(sort=3, diff=1, concept="Percents",
    prompt="What is 10% of 250?",
    options=[
      ("2.5", "2.5 is 1% of 250 — the decimal moved one place too far."),
      ("240", "240 subtracts 10 from 250. A percent means a part out of 100, not a number to subtract."),
      ("10", "10 is the percent itself, not 10% of 250."),
      ("25", "Correct. 10% means one tenth: 250 ÷ 10 = 25."),
    ], answer="25", check=lambda: 250 / 10 == 25 and 250 / 100 == 2.5,
    explanation="10% is one tenth, so divide by 10 — which just moves the decimal point one place left: 250 becomes 25.0. Knowing 10% instantly lets you build others: 20% is double (50), and 5% is half (12.5)."),

  dict(sort=4, diff=1, concept="Perimeter",
    prompt="A rectangle is 7 inches long and 3 inches wide. What is its perimeter?",
    options=[
      ("20 inches", "Correct. Perimeter is the distance all the way around: 7 + 3 + 7 + 3 = 20."),
      ("21 inches", "21 is 7 × 3, which is the AREA. Perimeter adds the sides; area multiplies them."),
      ("10 inches", "10 adds one length and one width — only halfway around."),
      ("17 inches", "17 counts only three sides: 7 + 7 + 3."),
    ], answer="20 inches", check=lambda: 2 * (7 + 3) == 20 and 7 * 3 == 21,
    explanation="Perimeter means the distance around the outside. A rectangle has two lengths and two widths: 7 + 7 + 3 + 3 = 20. The quick way is 2 × (7 + 3). If you multiplied 7 × 3, you found the area — a completely different measurement."),

  dict(sort=5, diff=1, concept="Word problems — multiplying",
    prompt="Notebooks cost $2.50 each. How much do 3 notebooks cost?",
    options=[
      ("$5.00", "$5.00 is the cost of 2 notebooks, not 3."),
      ("$5.50", "$5.50 adds $3 to $2.50 — it adds the count instead of multiplying by it."),
      ("$6.50", "$6.50 is a dollar short. Check by adding $2.50 three times: $2.50, $5.00, $7.50."),
      ("$7.50", "Correct. 3 × $2.50 = $7.50."),
    ], answer="$7.50", check=lambda: 3 * 2.5 == 7.5,
    explanation="The word 'each' signals multiplication: price per item times the number of items. For 3 × $2.50, split dollars from cents: 3 × 2 = 6 and 3 × 0.50 = 1.50, so 6 + 1.50 = $7.50. Splitting like this makes money math easy to do in your head."),

  # ── Medium ──
  dict(sort=6, diff=2, concept="Order of operations",
    prompt="What is (8 − 3)² − 4 × 2?",
    options=[
      ("42", "42 subtracts 4 from 25 before multiplying. The multiplication, 4 × 2, must come first."),
      ("47", "47 squares 8 and 3 separately (64 − 9 − 8). The exponent applies to the whole parentheses, which equal 5."),
      ("17", "Correct. Parentheses first: 8 − 3 = 5. Exponent: 5² = 25. Multiply: 4 × 2 = 8. Subtract: 25 − 8 = 17."),
      ("2", "2 treats the small 2 as × 2: 5 × 2 = 10, then 10 − 8. The ² means multiply 5 by ITSELF."),
    ], answer="17",
    check=lambda: (8 - 3) ** 2 - 4 * 2 == 17 and ((8 - 3) ** 2 - 4) * 2 == 42 and 8**2 - 3**2 - 8 == 47 and 5 * 2 - 8 == 2,
    explanation="The order is Parentheses, Exponents, Multiplication and Division, then Addition and Subtraction. (8 − 3) = 5; 5² = 25; 4 × 2 = 8; 25 − 8 = 17. The exponent sits outside the parentheses, so it squares the result, 5 — not the 8 and the 3 separately."),

  dict(sort=7, diff=2, concept="Fractions of a number",
    prompt="What is 2/3 of 45?",
    options=[
      ("15", "15 is one third of 45. Two thirds is twice that."),
      ("30", "Correct. One third of 45 is 15, so two thirds is 30."),
      ("22.5", "22.5 is one half of 45. Two thirds is more than a half."),
      ("67.5", "67.5 flips the fraction (45 × 3/2). Taking 2/3 of a number makes it smaller, not bigger."),
    ], answer="30", check=lambda: 45 * F(2, 3) == 30 and 45 * F(3, 2) == F(135, 2),
    explanation="'Of' means multiply. The easy way: divide by the bottom number, multiply by the top. 45 ÷ 3 = 15, then 15 × 2 = 30. A quick sanity check: 2/3 is less than 1, so the answer must be less than 45."),

  dict(sort=8, diff=2, concept="Solving equations",
    prompt="If 3x + 5 = 20, what is x?",
    options=[
      ("15", "15 is 3x — one step short. Divide by 3 to find x itself."),
      ("25/3", "25/3 comes from adding 5 instead of subtracting it. To undo + 5, subtract 5."),
      ("5", "Correct. Subtract 5 from both sides: 3x = 15. Divide by 3: x = 5. Check: 3 × 5 + 5 = 20."),
      ("45", "45 multiplies 15 by 3 instead of dividing."),
    ], answer="5", check=lambda: 3 * 5 + 5 == 20 and F(20 + 5, 3) == F(25, 3),
    explanation="Undo the operations in reverse order, doing the same thing to both sides. The + 5 happened last, so remove it first: 3x = 15. Then undo the × 3 by dividing: x = 5. Always plug your answer back in to check it."),

  dict(sort=9, diff=2, concept="Area",
    prompt="A triangle has a base of 10 cm and a height of 6 cm. What is its area?",
    options=[
      ("16 cm²", "16 adds the base and the height. Area multiplies them."),
      ("60 cm²", "60 is base × height — the area of a RECTANGLE. A triangle is half of that."),
      ("30 cm²", "Correct. Area = ½ × base × height = ½ × 10 × 6 = 30 cm²."),
      ("8 cm²", "8 halves the sum of base and height instead of their product."),
    ], answer="30 cm²", check=lambda: 0.5 * 10 * 6 == 30,
    explanation="A triangle is exactly half of a rectangle with the same base and height. So find base × height (10 × 6 = 60) and halve it: 30. The units are squared — cm² — because you multiplied two lengths together."),

  dict(sort=10, diff=2, concept="Percent discounts",
    prompt="A shirt costs $40. It is on sale for 25% off. What is the sale price?",
    options=[
      ("$30", "Correct. 25% of $40 is $10, and $40 − $10 = $30."),
      ("$10", "$10 is the amount you SAVE, 25% of $40. The sale price is what is left to pay."),
      ("$15", "$15 subtracts 25 dollars, treating the percent as if it were money."),
      ("$50", "$50 adds the discount. A sale lowers the price."),
    ], answer="$30", check=lambda: 40 - 0.25 * 40 == 30 and 0.75 * 40 == 30,
    explanation="Two steps: find the discount, then subtract it. 25% is one quarter, and a quarter of $40 is $10. The sale price is $40 − $10 = $30. Shortcut: 25% off means you pay 75%, and 75% of $40 is $30."),

  # ── Hard ──
  dict(sort=11, diff=3, concept="Ratios",
    prompt="The ratio of boys to girls in a class is 3 to 5. If there are 40 students in the class, how many are girls?",
    options=[
      ("15", "15 is the number of BOYS (3 parts of 5 students each). The question asks for girls."),
      ("25", "Correct. 3 + 5 = 8 equal parts, and 40 ÷ 8 = 5 students per part. Girls get 5 parts: 5 × 5 = 25."),
      ("24", "24 takes 3/5 of the whole class. But the ratio compares boys to girls, not boys to all 40 students."),
      ("5", "5 is the size of ONE part. The girls are five parts."),
    ], answer="25", check=lambda: 40 // 8 * 5 == 25 and 40 // 8 * 3 == 15 and 40 * F(3, 5) == 24,
    explanation="A ratio of 3 to 5 splits the class into 3 + 5 = 8 equal parts. Find one part: 40 ÷ 8 = 5 students. The girls are 5 parts, so 25. Check with the boys: 3 parts is 15, and 15 + 25 = 40."),

  dict(sort=12, diff=3, concept="Solving equations — x on both sides",
    prompt="If 2(x − 3) = x + 4, what is x?",
    options=[
      ("7", "7 forgets to multiply the 3 by 2. 2(x − 3) is 2x − 6, not 2x − 3."),
      ("−2", "−2 subtracts 6 when moving it across. To undo − 6, add 6."),
      ("10/3", "10/3 adds x to both sides, giving 3x = 10. To gather the x's on one side, subtract x."),
      ("10", "Correct. Distribute: 2x − 6 = x + 4. Subtract x from both sides: x − 6 = 4. Add 6: x = 10."),
    ], answer="10",
    check=lambda: 2 * (10 - 3) == 10 + 4 and (2 * 7 - 3 == 7 + 4) and (2 * -2 - 6 == -2 + 4 - 12),
    explanation="First clear the parentheses by multiplying the 2 by BOTH terms inside: 2x − 6. Then gather the x's on one side by subtracting x from both sides: x − 6 = 4. Undo the − 6 by adding 6: x = 10. Check in the original: 2(10 − 3) = 14, and 10 + 4 = 14."),

  dict(sort=13, diff=3, concept="Circles",
    prompt="A circle has a diameter of 10 inches. What is its area? (Use π ≈ 3.14)",
    options=[
      ("314 square inches", "314 uses the diameter as the radius: 3.14 × 10². The radius is half the diameter."),
      ("78.5 square inches", "Correct. The radius is 10 ÷ 2 = 5. Area = π × r² = 3.14 × 25 = 78.5 square inches."),
      ("31.4 square inches", "31.4 is the CIRCUMFERENCE (π × diameter) — the distance around, not the space inside."),
      ("15.7 square inches", "15.7 is π × 5. It multiplies by the radius once instead of squaring it."),
    ], answer="78.5 square inches",
    check=lambda: abs(3.14 * 5 ** 2 - 78.5) < 1e-9 and abs(3.14 * 10 - 31.4) < 1e-9 and abs(3.14 * 5 - 15.7) < 1e-9,
    explanation="Area of a circle = π × r², where r is the radius. The problem gives the diameter, so halve it first: r = 5. Then 5² = 25, and 3.14 × 25 = 78.5. The two classic traps are using the diameter instead of the radius, and confusing area with circumference, which is π × d."),

  dict(sort=14, diff=3, concept="Averages — finding a missing score",
    prompt="Jada's first three test scores are 80, 85, and 90. What score does she need on the fourth test to have an average of 86?",
    options=[
      ("85", "85 is her CURRENT average (255 ÷ 3). The question asks what she needs next."),
      ("86", "Scoring exactly 86 would only lift her average to 85.25, because her first three tests average below 86."),
      ("91", "91 overshoots: (255 + 91) ÷ 4 = 86.5."),
      ("89", "Correct. An average of 86 over 4 tests needs a total of 4 × 86 = 344. She has 80 + 85 + 90 = 255, so she needs 344 − 255 = 89."),
    ], answer="89",
    check=lambda: 4 * 86 - (80 + 85 + 90) == 89 and (255 + 86) / 4 == 85.25 and (255 + 91) / 4 == 86.5,
    explanation="Work with totals, not averages. To average 86 over 4 tests, the four scores must add up to 4 × 86 = 344. She already has 255. The difference is what she needs: 344 − 255 = 89. Check: (80 + 85 + 90 + 89) ÷ 4 = 344 ÷ 4 = 86."),

  dict(sort=15, diff=3, concept="Rates",
    prompt="A car travels 180 miles in 3 hours. At the same rate, how far will it travel in 5 hours?",
    options=[
      ("300 miles", "Correct. 180 ÷ 3 = 60 miles per hour, and 60 × 5 = 300 miles."),
      ("108 miles", "108 flips the rate (180 × 3 ÷ 5). A longer trip at the same speed must cover MORE distance, not less."),
      ("900 miles", "900 multiplies the whole 3-hour distance by 5, as if every hour covered 180 miles."),
      ("360 miles", "360 doubles the distance, which would take 6 hours, not 5."),
    ], answer="300 miles", check=lambda: 180 / 3 * 5 == 300 and 180 * 3 / 5 == 108,
    explanation="Find the unit rate first — miles in ONE hour: 180 ÷ 3 = 60. Then scale up: 60 × 5 = 300. Sanity check: 5 hours is longer than 3, so the answer must be more than 180, and less than 360, since 5 hours is less than double 3."),
]

FIND = "Look for errors in {kind}. Choose the sentence that has an error, or choose No mistakes."
NO = "No mistakes"

LANGUAGE = [
  # ── Easy ──
  dict(sort=1, diff=1, concept="Capitalization — starting a sentence",
    prompt=FIND.format(kind="capitalization"),
    options=[
      ("My cousin lives in Denver.", "Denver is a city, so it is capitalized correctly."),
      ("we visited the museum on Saturday.", "Correct. The first word of every sentence needs a capital letter: We visited the museum."),
      ("The Pacific Ocean is very deep.", "Pacific Ocean is the name of a specific ocean, so both words are capitalized correctly."),
      (NO, "The museum sentence starts with a lowercase letter, so there is a mistake."),
    ], answer="we visited the museum on Saturday.",
    explanation="Check every sentence against the two basic rules: capitalize the first word of a sentence, and capitalize the names of specific people, places, and things. The museum sentence starts with a lowercase 'we.' Check the first letter of each sentence first — it is the easiest error to miss, because your eyes jump to the middle."),

  dict(sort=2, diff=1, concept="Commas in a list",
    prompt=FIND.format(kind="punctuation"),
    options=[
      ("I bought apples bananas, and grapes.", "Correct. Items in a list need commas between them: apples, bananas, and grapes. Here there is no comma between the first two."),
      ("Our team won the game.", "A complete statement that ends with a period — correct."),
      ("Where did you put the keys?", "A question that ends with a question mark — correct."),
      (NO, "The fruit sentence is missing a comma, so there is a mistake."),
    ], answer="I bought apples bananas, and grapes.",
    explanation="When three or more items are listed, separate each one with a comma. 'Apples bananas' runs two items together with nothing between them. Read lists slowly and check that every item is separated from the next."),

  dict(sort=3, diff=1, concept="Subject–verb agreement",
    prompt=FIND.format(kind="usage"),
    options=[
      ("She walks to school every day.", "'She' is one person, and 'walks' is the singular verb, so they agree."),
      ("They are going to the park.", "'They' is plural, and 'are' is the plural verb, so they agree."),
      ("The dogs barks at the mail carrier.", "Correct. 'Dogs' is plural, so the verb must be 'bark,' not 'barks.'"),
      (NO, "The sentence about the dogs has an agreement error."),
    ], answer="The dogs barks at the mail carrier.",
    explanation="A singular subject takes a singular verb, and a plural subject takes a plural verb. The confusing part: in English the singular VERB is the one ending in -s (she walks), while the plural NOUN ends in -s (dogs). So it is 'the dogs bark' but 'the dog barks.' Find the subject, decide whether it is one or many, then check the verb."),

  dict(sort=4, diff=1, concept="Spelling — ie or ei",
    prompt=FIND.format(kind="spelling"),
    options=[
      ("I will recieve the package tomorrow.", "Correct. The word is spelled 'receive' — after c, it is e before i."),
      ("My neighbor has a vegetable garden.", "'Neighbor' is spelled correctly. It is one of the words where e comes before i because it sounds like 'ay.'"),
      ("I believe you.", "'Believe' is correct: i before e."),
      (NO, "The package sentence has a misspelling."),
    ], answer="I will recieve the package tomorrow.",
    explanation="The rhyme 'i before e, except after c' covers receive: right after the c, it is e-i. Words like neighbor and weigh follow a different pattern — when the sound is 'ay,' it is e-i. Slow down on any word with ie or ei and say it to yourself."),

  dict(sort=5, diff=1, concept="When there is no mistake",
    prompt="Look for errors in capitalization, punctuation, or usage. Choose the sentence that has an error, or choose No mistakes.",
    options=[
      ("My sister plays the violin.", "Capital first letter, a verb that agrees, and a period at the end — no error."),
      ("Is the library open on Sunday?", "A question that correctly ends with a question mark, with Sunday capitalized as a day of the week."),
      ("We ate lunch at noon.", "Nothing is wrong here. 'Noon' is not capitalized because it is not a name."),
      (NO, "Correct. All three sentences are written properly. Sometimes there really is no mistake."),
    ], answer=NO,
    explanation="'No mistakes' is a real answer, and it will be right on some questions. Do not force an error that is not there. Check each sentence against the rules you know — capitals, end marks, agreement — and if all three pass, trust your work."),

  # ── Medium ──
  dict(sort=6, diff=2, concept="Apostrophes — its or it's",
    prompt=FIND.format(kind="punctuation"),
    options=[
      ("It's going to rain today.", "'It's' means 'it is,' and 'It is going to rain today' makes sense. Correct."),
      ("The cat licked it's paw.", "Correct. 'It's' means 'it is,' and 'the cat licked it is paw' makes no sense. The possessive is 'its,' with no apostrophe."),
      ("The company changed its name.", "'Its name' shows ownership, and the possessive 'its' has no apostrophe. Correct."),
      (NO, "The sentence about the cat misuses 'it's.'"),
    ], answer="The cat licked it's paw.",
    explanation="Test every 'it's' by expanding it to 'it is.' If the sentence still makes sense, the apostrophe is right. If it does not, you need 'its.' This is one of the few words where the possessive has NO apostrophe — just like his and hers."),

  dict(sort=7, diff=2, concept="Pronouns — I or me",
    prompt=FIND.format(kind="usage"),
    options=[
      ("The coach gave the award to Sara and me.", "'Gave the award to me' sounds right, so 'to Sara and me' is correct."),
      ("Sara and I finished the project.", "'I finished the project' works, so 'Sara and I' is correct."),
      ("Me and Sara went to the store.", "Correct. Take away 'and Sara': 'Me went to the store' is wrong. The subject form is 'I': Sara and I went to the store."),
      (NO, "The store sentence uses 'me' where 'I' is needed."),
    ], answer="Me and Sara went to the store.",
    explanation="Cover up the other person and read the sentence with just the pronoun. 'Me went' is wrong, so the store sentence needs 'I.' 'Gave the award to me' is right, so the award sentence keeps 'me.' Many students think 'Sara and I' is always the more correct choice. It is not — it depends on where the words sit in the sentence."),

  dict(sort=8, diff=2, concept="Commas — joining two sentences",
    prompt=FIND.format(kind="punctuation"),
    options=[
      ("After dinner, we played a game.", "A comma after an introductory phrase like 'After dinner' is correct."),
      ("I wanted to go to the beach, but it was raining.", "Two complete sentences joined by a comma plus 'but' — correct."),
      ("I finished my homework, I went outside.", "Correct. Two complete sentences are joined by only a comma, which is called a comma splice. Add a joining word ('and then') or use a period."),
      (NO, "The homework sentence is a comma splice."),
    ], answer="I finished my homework, I went outside.",
    explanation="A comma alone cannot join two complete sentences. Test it: can each side stand on its own? 'I finished my homework' and 'I went outside' both can, so they need a period, a semicolon, or a comma PLUS a joining word like and, but, or so. The beach sentence has 'but'; the homework sentence does not."),

  dict(sort=9, diff=2, concept="Capitalization — names and titles",
    prompt=FIND.format(kind="capitalization"),
    options=[
      ("We read about the Declaration of independence.", "Correct. Every important word in the name of a document is capitalized: Declaration of Independence."),
      ("My uncle is a doctor.", "'Doctor' is a job, not a name, so it stays lowercase. Correct as written."),
      ("Grandma made pancakes this morning.", "'Grandma' is used as her name here, so it is capitalized. Correct."),
      (NO, "The Declaration sentence has a capitalization error."),
    ], answer="We read about the Declaration of independence.",
    explanation="The names of specific things — documents, holidays, events — capitalize every important word, while small words like 'of' stay lowercase. Job titles and family words stay lowercase unless they are used AS a name: 'my grandma made pancakes,' but 'Grandma made pancakes.'"),

  dict(sort=10, diff=2, concept="Composition — transition words",
    prompt="Choose the word or phrase that best completes the second sentence.\nMaya studied every night for two weeks.\n______, she earned the highest score in her class.",
    options=[
      ("However", "'However' signals a contrast, but the high score is the expected payoff of studying, not a surprise."),
      ("For example", "'For example' introduces an illustration of a general point. The second sentence is an outcome, not an example."),
      ("Meanwhile", "'Meanwhile' means at the same time, but the score came AFTER the studying."),
      ("As a result", "Correct. The high score happened because she studied — a cause and its effect."),
    ], answer="As a result",
    explanation="Transition words show how two ideas connect. Ask what the second sentence is to the first: a contrast, an example, a result, or something happening at the same time? Studying led to the high score, so the link is cause and effect: As a result."),

  # ── Hard ──
  dict(sort=11, diff=3, concept="Verb tense",
    prompt=FIND.format(kind="usage"),
    options=[
      ("Tomorrow she will visit her aunt.", "'Tomorrow' with 'will visit' — the future tense matches."),
      ("Yesterday we walk to the park and saw a parade.", "Correct. 'Yesterday' puts the sentence in the past, and 'saw' is past tense, so 'walk' must be 'walked.'"),
      ("Every morning he runs two miles.", "'Every morning' describes a habit, and 'runs' is the present tense used for habits. Correct."),
      (NO, "The parade sentence switches tense partway through."),
    ], answer="Yesterday we walk to the park and saw a parade.",
    explanation="Look for time clues — yesterday, tomorrow, every day — and make every verb agree with them. In the parade sentence, 'yesterday' and 'saw' are both past, but 'walk' is present. Tense errors hide in sentences with two verbs, where one is right and the other quietly is not."),

  dict(sort=12, diff=3, concept="Pronouns — who or whom",
    prompt=FIND.format(kind="usage"),
    options=[
      ("To who did you give the book?", "Correct. After a word like 'to,' use 'whom': To whom did you give the book?"),
      ("Whom should I invite to the party?", "Answer it: 'I should invite HIM.' Him ends in m, so 'whom' is correct."),
      ("Who is knocking at the door?", "Answer it: 'HE is knocking.' He does not end in m, so 'who' is correct."),
      (NO, "The book sentence uses 'who' where 'whom' is needed."),
    ], answer="To who did you give the book?",
    explanation="Answer the question with he or him. If the answer uses HE, choose who; if it uses HIM, choose whom — him and whom both end in m. 'You gave the book to HIM,' so it is 'to whom.' Words like to, for, and with are a strong clue that whom is coming."),

  dict(sort=13, diff=3, concept="Semicolons",
    prompt=FIND.format(kind="punctuation"),
    options=[
      ("I love to read; my brother prefers sports.", "Both sides are complete sentences, so the semicolon joins them correctly."),
      ("The storm was fierce; however, no one was hurt.", "A semicolon before 'however' joins two complete sentences, with a comma after it. Correct."),
      ("Because it was late; we went home.", "Correct. 'Because it was late' cannot stand alone as a sentence, so it cannot sit before a semicolon. Use a comma: Because it was late, we went home."),
      (NO, "The sentence about it being late misuses a semicolon."),
    ], answer="Because it was late; we went home.",
    explanation="A semicolon works like a soft period: both sides must be complete sentences. Test each side on its own. 'My brother prefers sports' stands alone; 'Because it was late' does not — it leaves you waiting for the rest. Clauses that start with because, when, or although need a comma, not a semicolon."),

  dict(sort=14, diff=3, concept="Composition — topic sentences",
    prompt="Which sentence would best begin a paragraph about the benefits of learning a second language?",
    options=[
      ("Many people around the world speak more than one language.", "True, but it states a fact without saying why learning a language helps. It does not point toward benefits."),
      ("Spanish is spoken in many different countries.", "This is a detail about one language — too narrow to introduce the whole topic."),
      ("My friend is learning French this year.", "A personal example works in the middle of a paragraph, not as the sentence that sets up the main idea."),
      ("Learning a second language can open doors in school, travel, and work.", "Correct. It names the topic and previews the benefits the paragraph will explain."),
    ], answer="Learning a second language can open doors in school, travel, and work.",
    explanation="A topic sentence tells the reader what the whole paragraph will be about. It should be broad enough to cover every sentence that follows, yet specific enough to make a point. Facts and personal examples are supporting details — they belong later in the paragraph."),

  dict(sort=15, diff=3, concept="Spelling — double letters",
    prompt=FIND.format(kind="spelling"),
    options=[
      ("The hotel can accommodate a large group.", "'Accommodate' is correct — it has a double c AND a double m."),
      ("It is neccessary to bring a pencil.", "Correct. 'Necessary' has one c and two s's. The misspelling doubles the wrong letter."),
      ("We celebrate on special occasions.", "'Occasions' is correct: double c, single s."),
      (NO, "The pencil sentence has a misspelling."),
    ], answer="It is neccessary to bring a pencil.",
    explanation="Words with double letters are among the most misspelled on the test. Memory tricks help: necessary has one Collar and two Sleeves — one c, two s's. Accommodate is big enough to hold two c's and two m's. When a word looks almost right, check which letter is doubled."),
]
