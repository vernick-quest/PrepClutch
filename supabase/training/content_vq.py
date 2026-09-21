# Training content — verbal + quantitative. Answer stored as TEXT; the index is
# derived, so a question cannot be mis-keyed. `check` recomputes the answer.

NEITHER = ("Neither", "The real HSPT gives only three verdicts on these — true, false, or uncertain. Neither is never the answer; it is only here to fill the fourth slot.")
HSPT_LOGIC = "\nIf the first two statements are true, the third statement is:"

VERBAL = [
  # ── Easy ──
  dict(sort=1, diff=1, concept="Synonyms",
    prompt="ABUNDANT most nearly means:",
    options=[
      ("plentiful", "Correct. Plentiful and abundant both mean there is a large supply of something."),
      ("costly", "Costly is about PRICE, not amount. Something abundant is often cheap precisely because there is so much of it — the opposite pull."),
      ("hidden", "Hidden is about whether you can SEE something. An abundant thing is usually the easiest thing to find."),
      ("recent", "Recent is about TIME. A harvest can be recent and tiny, or abundant and years old. Different measure entirely."),
    ], answer="plentiful",
    explanation="Abundant describes having a great deal of something — more than enough. Think of an abundant harvest: the barns are full. The word is about quantity, so the answer has to be a quantity word."),

  dict(sort=2, diff=1, concept="Antonyms",
    prompt="FRAGILE is the opposite of:",
    options=[
      ("delicate", "Delicate is a SYNONYM of fragile — both mean easily damaged. Opposite questions almost always plant the word's twin as a trap."),
      ("broken", "Broken is what can happen to something fragile, not its opposite. Watch for choices that are merely related."),
      ("sturdy", "Correct. Sturdy means strong and hard to break — exactly the reverse of fragile."),
      ("small", "Size has nothing to do with it. A glass sculpture can be enormous and still fragile."),
    ], answer="sturdy",
    explanation="Fragile means easily broken. For an opposite, first put the word in your own words, then flip it: easily broken becomes hard to break. Only then look at the choices — the test nearly always includes a synonym to catch readers who forget they want the opposite."),

  dict(sort=3, diff=1, concept="Analogies — part to whole",
    prompt="Petal is to flower as page is to:",
    options=[
      ("ink", "Ink is printed ON a page — it is not what a page belongs to. It flips the relationship."),
      ("book", "Correct. A petal is one part of a flower; a page is one part of a book. Same part-to-whole link."),
      ("writer", "A writer creates a book, but a page is not part of a writer. Creator is a different relationship from whole."),
      ("library", "A library holds books, so it is two steps away from a page. The pattern needs the thing a page is directly part of."),
    ], answer="book",
    explanation="Turn the first pair into a sentence: a petal is one part of a flower. Now swap in the second word: a page is one part of a ___. Only book fits the same sentence. Building the sentence first stops you from picking a word that is merely connected."),

  dict(sort=4, diff=1, concept="Classification — which does not belong",
    prompt="Which word does NOT belong with the others?",
    options=[
      ("carrot", "Carrots grow underground, like turnips and potatoes, so they belong to the group."),
      ("turnip", "Turnips grow underground too — part of the group."),
      ("apple", "Correct. Apples grow on trees above the ground; the other three grow in the soil. They are also the only fruit here, so two different rules point to the same answer."),
      ("potato", "Potatoes grow underground as well, so they fit. The shared rule is where they grow, not their shape or color."),
    ], answer="apple",
    explanation="Find a rule that fits three words and breaks for exactly one. Three of these are dug out of the ground; one is picked from a tree. When you can name a rule that includes three and excludes one — and a second rule agrees — you can be confident."),

  dict(sort=5, diff=1, concept="Logic — putting things in order",
    prompt="Maria is taller than Jon.\nJon is taller than Lee.\nMaria is taller than Lee." + HSPT_LOGIC,
    options=[
      ("True", "Correct. Maria is above Jon and Jon is above Lee, so Maria must be above Lee. The order passes straight down the chain."),
      ("False", "False would mean Lee is at least as tall as Maria — impossible when Maria outranks Jon and Jon outranks Lee."),
      ("Uncertain", "Uncertain is for when the facts allow more than one outcome. Here the chain leaves only one, so nothing is uncertain."),
      NEITHER,
    ], answer="True",
    explanation="Line them up with the tallest on the left: Maria, then Jon, then Lee. Once the first two statements are placed on one line, you can read the third straight off it. Ordering questions almost always come down to drawing that line."),

  # ── Medium ──
  dict(sort=6, diff=2, concept="Synonyms",
    prompt="CANDID most nearly means:",
    options=[
      ("secretive", "Secretive is close to the OPPOSITE — a candid person hides nothing."),
      ("frank", "Correct. Frank and candid both mean honest and direct, even when the truth is uncomfortable."),
      ("sweet", "Sweet is the trap for anyone thinking of candy. Similar spelling, unrelated meaning."),
      ("careful", "Careful describes caution. A candid remark is often the opposite of careful — it says the blunt thing."),
    ], answer="frank",
    explanation="Candid means honest and straightforward. A candid photo is taken without posing — it shows things as they really are. When a word looks like one you know (candid, candy), check that the MEANING actually connects before trusting the resemblance."),

  dict(sort=7, diff=2, concept="Analogies — tool and what it measures",
    prompt="Thermometer is to temperature as scale is to:",
    options=[
      ("weight", "Correct. A thermometer measures temperature; a scale measures weight."),
      ("kitchen", "A kitchen is where you might find a scale. Location is a different relationship from what it measures."),
      ("number", "A scale shows a number, but so does a thermometer. The pattern asks WHAT is measured, and number is too general."),
      ("heat", "Heat belongs with the thermometer, not the scale. It borrows from the first pair to catch a rushed reader."),
    ], answer="weight",
    explanation="Say the relationship aloud: a thermometer is used to measure temperature. Then test it: a scale is used to measure ___. Weight is the only fit. Analogy traps often reuse a word from the first pair, like heat here, so be wary of a choice that feels familiar only because you just read it."),

  dict(sort=8, diff=2, concept="Antonyms",
    prompt="DILIGENT is the opposite of:",
    options=[
      ("hardworking", "Hardworking is a SYNONYM of diligent. On an opposite question, the synonym is the most common trap."),
      ("clever", "Clever is about intelligence, not effort. A clever person can be lazy or diligent."),
      ("honest", "Honest is about truthfulness — a different quality entirely."),
      ("lazy", "Correct. Diligent means putting in steady, careful effort; lazy means avoiding effort."),
    ], answer="lazy",
    explanation="Diligent describes someone who works steadily and carefully. Flip that — avoids effort — and lazy is the match. Notice two other choices are also positive traits: an opposite must be opposite in the SAME quality, not just something different."),

  dict(sort=9, diff=2, concept="Analogies — degree",
    prompt="Warm is to hot as cool is to:",
    options=[
      ("breezy", "Breezy describes wind, not how cold something is."),
      ("cold", "Correct. Hot is a stronger version of warm; cold is a stronger version of cool. The same step up in intensity."),
      ("mild", "Mild is WEAKER than cool, not stronger — it moves in the wrong direction."),
      ("damp", "Damp is about moisture, a different scale entirely."),
    ], answer="cold",
    explanation="This is a degree analogy: the second word is a more intense version of the first. Warm to hot turns the heat up; cool to cold turns the chill up. When two words differ only in strength, find the choice that makes the same jump in the same direction."),

  dict(sort=10, diff=2, concept="Logic — putting things in order",
    prompt="Box A weighs more than Box B.\nBox C weighs less than Box B.\nBox C weighs more than Box A." + HSPT_LOGIC,
    options=[
      ("True", "True would put C above A. But A is heavier than B, and B is heavier than C, so C is at the bottom."),
      ("False", "Correct. From heaviest to lightest the order is A, then B, then C. C cannot outweigh A."),
      ("Uncertain", "Uncertain applies when the facts leave room for either answer. Here they fix the order completely."),
      NEITHER,
    ], answer="False",
    explanation="Place all three on one line, heaviest first. A is heavier than B: A, B. C is lighter than B: A, B, C. The third statement claims C beats A, and the line shows the reverse. Tip: rewrite any 'less than' sentence so every comparison points the same direction before you compare."),

  # ── Hard ──
  dict(sort=11, diff=3, concept="Synonyms",
    prompt="EPHEMERAL most nearly means:",
    options=[
      ("mysterious", "Ephemeral things can seem mysterious, but the word is about how LONG something lasts, not how puzzling it is."),
      ("ancient", "Ancient means very old — close to the opposite of something that barely lasts."),
      ("fleeting", "Correct. Ephemeral means lasting a very short time, just as fleeting does."),
      ("beautiful", "The word is often used about beautiful things, like a sunset, which makes this tempting. But it means short-lived, not beautiful."),
    ], answer="fleeting",
    explanation="Ephemeral means lasting only a very short time — a soap bubble, a rainbow, a fad. If you do not know a hard word, think about what it usually describes. Then be careful: a choice that describes the KIND of thing the word is used about is not the same as what the word means."),

  dict(sort=12, diff=3, concept="Analogies — word parts",
    prompt="Illegible is to read as inaudible is to:",
    options=[
      ("speak", "Speaking PRODUCES sound, but inaudible is about receiving it. The pattern is about what cannot be done TO the thing."),
      ("see", "Seeing pairs with invisible, not inaudible. Close, but the wrong sense."),
      ("write", "Write is borrowed from the reading side of the analogy. It matches illegible's topic, not inaudible's."),
      ("hear", "Correct. Illegible writing cannot be read; an inaudible sound cannot be heard."),
    ], answer="hear",
    explanation="Both words are built the same way: il- or in- means NOT, and -ible means able to be. Illegible is not able to be read; inaudible is not able to be heard. When the words in an analogy share a prefix and suffix, take them apart — the pattern is usually hiding in the pieces."),

  dict(sort=13, diff=3, concept="Logic — overlapping groups",
    prompt="All violinists are musicians.\nSome musicians are composers.\nSome violinists are composers." + HSPT_LOGIC,
    options=[
      ("True", "True would require the composers to definitely include some violinists. Nothing says they do — the composers could all be drummers."),
      ("False", "False would require the composers to include NO violinists. Nothing says that either. True and False both claim to know something the statements never give you."),
      ("Uncertain", "Correct. The first two statements allow the third but do not force it, and that gap is exactly what uncertain means."),
      NEITHER,
    ], answer="Uncertain",
    explanation="Draw two circles. Violinists sit entirely inside musicians. Composers overlap musicians somewhere — but nothing tells you where. The overlap could include violinists, or it could land entirely on pianists and drummers. When the statements allow the conclusion but do not force it, the answer is uncertain."),

  dict(sort=14, diff=3, concept="Antonyms",
    prompt="VERBOSE is the opposite of:",
    options=[
      ("concise", "Correct. Verbose means using more words than needed; concise means saying it in as few as possible."),
      ("loud", "Loud is about volume. A verbose speaker can whisper."),
      ("truthful", "Truthful is about honesty. Wordiness says nothing about whether the words are true."),
      ("rapid", "Rapid is about speed. Someone can be verbose slowly or quickly."),
    ], answer="concise",
    explanation="Verbose comes from the Latin verbum, meaning word — a verbose person uses too many words. The opposite must also be about the NUMBER of words: concise. When a hard word contains a root you recognize, the root often tells you which quality is being measured."),

  dict(sort=15, diff=3, concept="Classification — which does not belong",
    prompt="Which word does NOT belong with the others?",
    options=[
      ("rejoice", "Rejoice means to feel or show great joy, so it fits the group."),
      ("exult", "Exult means to show triumphant joy. It is the least familiar word here, which makes it tempting — but it belongs."),
      ("celebrate", "Celebrate fits: it is a joyful action."),
      ("lament", "Correct. Lament means to express sorrow; the other three all express joy."),
    ], answer="lament",
    explanation="Three of these mean showing happiness; one means showing grief. The trap is the unfamiliar word — students often pick exult just because they do not know it. Before choosing the strangest-looking word, check whether your rule actually excludes it."),
]

COMPARE = "Examine (a), (b), and (c) and find the best answer."
SERIES = lambda s: f"Look at this series: {s}, ... What number should come next?"

QUANT = [
  # ── Easy ──
  dict(sort=1, diff=1, concept="Number series — adding",
    prompt=SERIES("3, 6, 9, 12"),
    options=[
      ("13", "13 adds only 1. The series adds 3 every time."),
      ("14", "14 adds 2. Check the gap between each pair — it is always 3."),
      ("15", "Correct. Each number is 3 more than the one before: 12 + 3 = 15."),
      ("18", "18 adds 6, doubling the step. The step never changes in this series."),
    ], answer="15", check=lambda: 12 + 3 == 15,
    explanation="Find the gap between neighbors: 6 − 3 = 3, 9 − 6 = 3, 12 − 9 = 3. When every gap is the same, keep adding it: 12 + 3 = 15. Always check at least two gaps before trusting a pattern."),

  dict(sort=2, diff=1, concept="Number series — subtracting",
    prompt=SERIES("20, 17, 14, 11"),
    options=[
      ("8", "Correct. Each number is 3 less than the one before: 11 − 3 = 8."),
      ("9", "9 subtracts only 2. The series drops by 3 each time."),
      ("7", "7 subtracts 4 — one more than the real step."),
      ("10", "10 subtracts just 1."),
    ], answer="8", check=lambda: 11 - 3 == 8,
    explanation="The numbers go down, so find how much they drop: 20 − 17 = 3, 17 − 14 = 3, 14 − 11 = 3. Keep subtracting 3: 11 − 3 = 8. A falling series works exactly like a rising one — you just subtract the gap."),

  dict(sort=3, diff=1, concept="Number series — multiplying",
    prompt=SERIES("2, 4, 8, 16"),
    options=[
      ("18", "18 adds 2. But the gaps here keep growing — 2, 4, 8 — so adding a fixed amount cannot work."),
      ("20", "20 adds 4, repeating an earlier gap. The gaps double each time, so the next one is 16."),
      ("24", "24 adds 8, repeating the previous gap. The gaps themselves are growing."),
      ("32", "Correct. Each number is twice the one before: 16 × 2 = 32."),
    ], answer="32", check=lambda: 16 * 2 == 32,
    explanation="The gaps are 2, 4, 8 — not constant, so this is not an adding series. Try dividing instead: 4 ÷ 2 = 2, 8 ÷ 4 = 2, 16 ÷ 8 = 2. Each term is double the last, so 16 × 2 = 32. When the gaps grow fast, test multiplication."),

  dict(sort=4, diff=1, concept="Number manipulation",
    prompt="What number is 4 less than 3 × 5?",
    options=[
      ("3", "3 comes from subtracting first: 3 × (5 − 4). But '4 less than 3 × 5' means find 3 × 5 before anything else."),
      ("11", "Correct. 3 × 5 = 15, and 4 less than 15 is 11."),
      ("19", "19 adds 4 instead of subtracting it. 'Less than' means take away."),
      ("15", "15 is 3 × 5 — the right starting point, but you still need to take away 4."),
    ], answer="11", check=lambda: 3 * 5 - 4 == 11,
    explanation="Work from the inside out. The phrase '4 less than 3 × 5' is built on 3 × 5, so find that first: 15. Then '4 less than' means subtract 4: 11. The words 'less than' tell you to take away from the number that comes after them."),

  dict(sort=5, diff=1, concept="Comparisons — are they equal?",
    prompt=COMPARE + "\n(a) 1/2 of 10\n(b) 5\n(c) 10 ÷ 2",
    options=[
      ("(a) is greater than (b)", "Half of 10 is 5, the same as (b). Neither is greater."),
      ("(a), (b), and (c) are equal", "Correct. Half of 10 is 5, (b) is 5, and 10 ÷ 2 is 5. All three are the same value."),
      ("(c) is greater than (a)", "10 ÷ 2 and half of 10 are two ways of writing the same thing — both equal 5."),
      ("(b) is less than (c)", "(b) is 5 and (c) is 5, so neither is less."),
    ], answer="(a), (b), and (c) are equal", check=lambda: 10 / 2 == 5 == 0.5 * 10,
    explanation="Turn every item into a plain number before comparing: (a) half of 10 is 5, (b) is 5, (c) 10 ÷ 2 is 5. Only then read the choices. Comparison questions look complicated but reward one habit: compute everything first, compare second."),

  # ── Medium ──
  dict(sort=6, diff=2, concept="Number series — square numbers",
    prompt=SERIES("1, 4, 9, 16, 25"),
    options=[
      ("30", "30 adds 5, but the gaps are growing: 3, 5, 7, 9. The next gap is 11."),
      ("34", "34 adds 9, repeating the last gap. The gaps grow by 2 every time."),
      ("36", "Correct. These are square numbers — 1², 2², 3², 4², 5² — so the next is 6² = 36."),
      ("49", "49 is 7². It skips over 6²."),
    ], answer="36", check=lambda: 6 ** 2 == 36 == 25 + 11,
    explanation="The gaps are 3, 5, 7, 9 — growing by 2 each step — so the next gap is 11: 25 + 11 = 36. Or spot the shortcut: each term is a number times itself, 1², 2², 3², 4², 5², so the sixth is 6² = 36. Recognizing square numbers on sight saves real time."),

  dict(sort=7, diff=2, concept="Number series — two steps taking turns",
    prompt=SERIES("5, 10, 8, 16, 14"),
    options=[
      ("12", "12 subtracts 2. But the steps alternate — the last step subtracted, so this one multiplies."),
      ("28", "Correct. The pattern alternates × 2 then − 2. The last step was − 2 (16 to 14), so now multiply: 14 × 2 = 28."),
      ("16", "16 adds 2. Neither step in this pattern adds."),
      ("20", "20 adds 6. Look at the steps, not just the size of the numbers."),
    ], answer="28", check=lambda: 14 * 2 == 28,
    explanation="The numbers go up, down, up, down — a sign that two steps are taking turns. Write each one: 5 to 10 is × 2, 10 to 8 is − 2, 8 to 16 is × 2, 16 to 14 is − 2. The next step is × 2: 14 × 2 = 28."),

  dict(sort=8, diff=2, concept="Number manipulation",
    prompt="What number is 5 more than 1/3 of 27?",
    options=[
      ("22", "22 is 27 − 5. It skips the 'one third of' step and subtracts instead of adding."),
      ("9", "9 is one third of 27 — the right first step — but you still need 5 more."),
      ("32", "32 adds 5 to 27 and never takes a third."),
      ("14", "Correct. One third of 27 is 9, and 5 more than 9 is 14."),
    ], answer="14", check=lambda: 27 / 3 + 5 == 14,
    explanation="Break the sentence at the word 'than': '5 more than' ... '1/3 of 27'. Do the second part first, because the first part depends on it: 27 ÷ 3 = 9. Then add 5: 14. Most mistakes come from using the whole 27 instead of the third."),

  dict(sort=9, diff=2, concept="Comparisons — percents, fractions, decimals",
    prompt=COMPARE + "\n(a) 25% of 80\n(b) 1/5 of 100\n(c) 0.3 × 60",
    options=[
      ("(a) and (b) are equal, and both are greater than (c)", "Correct. (a) 25% of 80 = 20, (b) 1/5 of 100 = 20, (c) 0.3 × 60 = 18. The first two tie, and both beat 18."),
      ("(a), (b), and (c) are equal", "(c) is 18, not 20 — close enough to fool a quick estimate, but not equal."),
      ("(c) is greater than (a)", "(c) is 18 and (a) is 20, so (c) is smaller."),
      ("(b) is greater than (a)", "(a) and (b) are both exactly 20."),
    ], answer="(a) and (b) are equal, and both are greater than (c)",
    check=lambda: 0.25 * 80 == 20 and 100 / 5 == 20 and abs(0.3 * 60 - 18) < 1e-9,
    explanation="Convert each to a plain number. 25% is one quarter, and a quarter of 80 is 20. One fifth of 100 is 20. For 0.3 × 60, find 3 × 60 = 180, then move the decimal one place: 18. With everything as a plain number, the comparison is easy."),

  dict(sort=10, diff=2, concept="Comparisons — exponents and roots",
    prompt=COMPARE + "\n(a) 3²\n(b) 2³\n(c) √64",
    options=[
      ("(a), (b), and (c) are equal", "3² is 9, not 8. Many students mix up 3² and 2³ because the same digits appear."),
      ("(a) is less than (c)", "(a) is 9 and (c) is 8, so (a) is the larger one."),
      ("(b) is greater than (c)", "2³ = 8 and √64 = 8 — they are equal."),
      ("(b) and (c) are equal, and both are less than (a)", "Correct. 3² = 3 × 3 = 9, 2³ = 2 × 2 × 2 = 8, and √64 = 8, since 8 × 8 = 64."),
    ], answer="(b) and (c) are equal, and both are less than (a)",
    check=lambda: 3 ** 2 == 9 and 2 ** 3 == 8 and 8 * 8 == 64,
    explanation="The small raised number tells you how many times to multiply the base by itself: 3² = 3 × 3 = 9, but 2³ = 2 × 2 × 2 = 8. The √ sign asks which number times itself makes 64: 8. Write the multiplication out rather than guessing — 3² and 2³ look alike but are not equal."),

  # ── Hard ──
  dict(sort=11, diff=3, concept="Number series — growing gaps",
    prompt=SERIES("2, 3, 5, 8, 12, 17"),
    options=[
      ("22", "22 adds 5, repeating the last gap. The gaps are increasing by 1 each time."),
      ("23", "Correct. The gaps are 1, 2, 3, 4, 5, so the next gap is 6: 17 + 6 = 23."),
      ("24", "24 adds 7 — one step too far."),
      ("25", "25 adds the two previous numbers (8 + 17). That rule breaks earlier in the series: 5 + 8 = 13, not 12."),
    ], answer="23", check=lambda: 17 + 6 == 23 and 5 + 8 == 13,
    explanation="The start — 2, 3, 5, 8 — looks as if each term is the sum of the two before it. But 5 + 8 = 13, not 12, so that rule breaks. Check the gaps instead: 1, 2, 3, 4, 5. They grow by one each time, so the next gap is 6: 17 + 6 = 23. Always test a pattern against every term, not just the first few."),

  dict(sort=12, diff=3, concept="Number series — two operations",
    prompt=SERIES("3, 5, 9, 17, 33"),
    options=[
      ("49", "49 adds 16, repeating the last gap. The gaps double — 2, 4, 8, 16 — so the next is 32."),
      ("64", "64 is one short. Doubling 33 gives 66, and the rule subtracts 1, not 2."),
      ("65", "Correct. Each term is double the one before, minus 1: 33 × 2 − 1 = 65."),
      ("66", "66 doubles 33 but forgets to subtract 1."),
    ], answer="65", check=lambda: 33 * 2 - 1 == 65 == 33 + 32,
    explanation="The gaps are 2, 4, 8, 16 — they double, so the next gap is 32: 33 + 32 = 65. The same pattern written as a rule: double the term and subtract 1 (5 × 2 − 1 = 9, 9 × 2 − 1 = 17). When the gaps themselves form a pattern, follow the gaps."),

  dict(sort=13, diff=3, concept="Number series — two steps taking turns",
    prompt=SERIES("80, 40, 44, 22, 26"),
    options=[
      ("13", "Correct. The steps alternate ÷ 2 then + 4. The last step was + 4 (22 to 26), so now halve: 26 ÷ 2 = 13."),
      ("30", "30 adds 4 again, but the steps take turns — after + 4 comes ÷ 2."),
      ("52", "52 doubles 26. This pattern halves; it never doubles."),
      ("11", "11 is 22 ÷ 2 — the right operation on the wrong number. Apply the next step to the LAST term, 26."),
    ], answer="13", check=lambda: 26 / 2 == 13,
    explanation="The series falls and rises, so two steps are alternating. Label them: 80 to 40 is ÷ 2, 40 to 44 is + 4, 44 to 22 is ÷ 2, 22 to 26 is + 4. The next step is ÷ 2, applied to the last term: 26 ÷ 2 = 13."),

  dict(sort=14, diff=3, concept="Number manipulation — working backward",
    prompt="When a number is doubled and then decreased by 7, the result is 15. What is the number?",
    options=[
      ("11", "Correct. Undo each step in reverse: 15 + 7 = 22, then 22 ÷ 2 = 11. Check: 11 × 2 − 7 = 15."),
      ("4", "4 comes from subtracting 7 instead of adding it back. To undo 'decreased by 7', you add 7."),
      ("22", "22 undoes the subtraction but not the doubling. Divide by 2 to finish."),
      ("37", "37 runs the operations forward on 15 (15 × 2 + 7) instead of undoing them."),
    ], answer="11", check=lambda: 11 * 2 - 7 == 15,
    explanation="Work backward, undoing the LAST step first. The last thing done was 'decreased by 7', so add 7: 15 + 7 = 22. Before that it was doubled, so halve: 22 ÷ 2 = 11. Always check by running it forward: 11 × 2 = 22, and 22 − 7 = 15."),

  dict(sort=15, diff=3, concept="Comparisons — ordering three values",
    prompt=COMPARE + "\n(a) 2/3\n(b) 0.6\n(c) 65%",
    options=[
      ("(c) is greater than (a)", "65% is 0.65, but 2/3 is about 0.667 — just barely larger."),
      ("(a) and (c) are equal", "They are close but not equal: about 0.667 versus 0.65."),
      ("(a) is greater than (c), and (c) is greater than (b)", "Correct. As decimals: (a) 2/3 ≈ 0.667, (c) 65% = 0.65, (b) 0.6. The order is a, then c, then b."),
      ("(b) is greater than (c)", "0.6 is less than 0.65 — write it as 0.60 to see it."),
    ], answer="(a) is greater than (c), and (c) is greater than (b)",
    check=lambda: 2 / 3 > 0.65 > 0.6,
    explanation="Put all three in the same form; decimals are easiest. 2/3 = 0.666..., 65% = 0.65, and 0.6 = 0.60. Writing 0.60 with two places makes it obvious that it sits below 0.65. When values are close, add zeros so the decimals have the same length before you compare."),
]
