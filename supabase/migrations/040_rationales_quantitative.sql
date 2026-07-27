-- 040 — Rewrite quantitative explanations (250 rows)
--
-- Updates ONE column: explanation. Nothing else is assigned — not prompt,
-- not options, not correct_index, not difficulty — so no student score can
-- move. This file contains UPDATE statements only: nothing is added,
-- removed or restructured, and no history table is touched.
--
-- Prompts are NOT unique in this bank, so every WHERE clause pins the row
-- with section + prompt + the exact options array. Each statement therefore
-- targets exactly one row. Setting the same text twice is a no-op, so the
-- file is idempotent and safe to re-run.

UPDATE questions SET explanation = 'Each term is 2 more than the one before it: 2, 4, 6, 8 all step up by two, so the next term is 8 + 2 = 10. Watch the size of the step. Adding 1 would give 9, and jumping by 4 would give 12, but the gap here never changes.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  2, 4, 6, 8, ___' AND options = '["9", "10", "12", "11"]'::JSONB;

UPDATE questions SET explanation = 'Multiplying by 3 got you to 21, so divide by 3 to get back: 21 ÷ 3 = 7. Check it by multiplying forward: 7 × 3 = 21. Test the other choices the same way, since 6 × 3 is only 18 and 9 × 3 is 27, so neither one fits.'
  WHERE section = 'quantitative' AND prompt = 'A number multiplied by 3 gives 21. What is the number?' AND options = '["6", "9", "7", "8"]'::JSONB;

UPDATE questions SET explanation = 'Each term drops by the same amount: 100 to 90 to 80 to 70 is a fall of 10 every time, so the next is 70 − 10 = 60. If you halve the step and subtract 5 you land on 65, and subtracting twice, taking two steps at once, gives 50. One step of 10 is what the pattern asks for.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  100, 90, 80, 70, ___' AND options = '["55", "65", "60", "50"]'::JSONB;

UPDATE questions SET explanation = 'Each term is double the one before: 3, 6, 12, 24. So the next term is 24 × 2 = 48. A tempting mistake is to add instead of multiply. The last jump was +12, and repeating that gives 36, while adding the earlier gap of 6 gives 30. The gaps grow because the rule is doubling.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  3, 6, 12, 24, ___' AND options = '["36", "42", "48", "30"]'::JSONB;

UPDATE questions SET explanation = 'Give both fractions the same denominator, or turn them into decimals: 3/4 = 0.75 and 7/10 = 0.70. Since 0.75 is bigger, A is greater. Comparing only the top numbers makes 7/10 look larger and tempts you to say B is greater, but a fraction depends on both of its numbers, and these two are not equal.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 3/4  vs.  (B) 7/10. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Undo the steps backwards. The last thing done was adding 8, so subtract it: 12 − 8 = 4. Before that the number was divided by 5, so multiply: 4 × 5 = 20. Check any answer by running it forward: 25 ÷ 5 + 8 = 13, and 15 ÷ 5 + 8 = 11, so only 20 works.'
  WHERE section = 'quantitative' AND prompt = 'A number is divided by 5, then 8 is added, giving 12. What was the original number?' AND options = '["20", "25", "15", "30"]'::JSONB;

UPDATE questions SET explanation = 'These are the square numbers: 1 × 1, 2 × 2, 3 × 3, 4 × 4, so the next is 5 × 5 = 25. The gaps say the same thing: 3, 5, 7, growing by 2, so the next gap is 9 and 16 + 9 = 25. A gap of 5 gives 21 and a gap of 8 gives 24, but neither fits.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 4, 9, 16, ___' AND options = '["20", "25", "21", "24"]'::JSONB;

UPDATE questions SET explanation = 'Each term is the sum of the two before it: 2 + 3 = 5, 3 + 5 = 8, and 5 + 8 = 13. So the next is 8 + 13 = 21. Reading the gaps as +1, +2, +3, +4 gives 18, and guessing a gap of 7 gives 20. But that gap rule already breaks, since 8 to 13 is a jump of 5, not 4.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  2, 3, 5, 8, 13, ___' AND options = '["18", "19", "21", "20"]'::JSONB;

UPDATE questions SET explanation = 'Squaring and subtracting cannot be swapped around. A is 5² − 3² = 25 − 9 = 16, while B is (5 − 3)² = 2² = 4. So A is greater. Anyone who assumes those two expressions mean the same thing expects them to be equal, or thinks B is greater because it looks tidier, but 16 and 4 are far apart.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 5² − 3²  vs.  (B) (5−3)². Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'For evenly spaced numbers the average sits exactly in the middle, so 18 is the third of the five: 14, 16, 18, 20, 22. The largest is 22. If you treat 18 as the smallest and count up, you get 26, and stopping one step early gives 20. Two of the numbers must sit above 18 and two below.'
  WHERE section = 'quantitative' AND prompt = 'The average of five consecutive even numbers is 18. What is the largest?' AND options = '["20", "22", "24", "26"]'::JSONB;

UPDATE questions SET explanation = 'Every term is 5 more than the one before, so the next is 20 + 5 = 25. These are the counting-by-fives numbers. Adding 2 instead of 5 gives 22, and taking two steps at once, or doubling the step to 10, lands on 30. The step size stays the same all the way through the series.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  5, 10, 15, 20, ___' AND options = '["22", "24", "25", "30"]'::JSONB;

UPDATE questions SET explanation = 'Each term is 1 more than the one before: 1, 2, 3, 4. So the next is 4 + 1 = 5. Check the step between every pair before you answer. Adding 2 each time would give 6, and doubling the last term would give 8, but neither rule matches the steps you can already see.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 2, 3, 4, ___' AND options = '["5", "6", "7", "8"]'::JSONB;

UPDATE questions SET explanation = 'The terms fall by 5 each time: 50, 45, 40, 35. So the next is 35 − 5 = 30. Subtracting 3 instead would give 32, and subtracting 10, which is two steps at once, gives 25. Find the gap between two neighboring terms, name it in words, then take exactly one more step.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  50, 45, 40, 35, ___' AND options = '["25", "28", "32", "30"]'::JSONB;

UPDATE questions SET explanation = 'These are the multiples of 3, each one 3 more than the last, so the next is 12 + 3 = 15. Adding 6 would give 18 and adding 2 would give 14, but the step never changes here. Because 3 and 6 look like doubling at the start, check your rule on a later pair too: 6 to 9 is only +3.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  3, 6, 9, 12, ___' AND options = '["14", "15", "16", "18"]'::JSONB;

UPDATE questions SET explanation = 'Each term is 10 more than the one before, so the next is 40 + 10 = 50. Adding 5 instead would give 45, and jumping by 20, which is two steps at once, gives 60. When a series climbs by the same amount every time, take exactly one more step of that size from the last term shown.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  10, 20, 30, 40, ___' AND options = '["45", "48", "50", "60"]'::JSONB;

UPDATE questions SET explanation = 'The step is +5 every time: 0, 5, 10, 15. So the next term is 15 + 5 = 20. Counting on by 3 would give 18, and adding 10, which is two steps at once, gives 25. Check the gap between each neighboring pair first, then add that gap to the last term once.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  0, 5, 10, 15, ___' AND options = '["18", "20", "22", "25"]'::JSONB;

UPDATE questions SET explanation = 'Each term is double the one before: 2, 4, 8, 16. So the next is 16 × 2 = 32. Adding the last gap of 8 instead of doubling gives 24, and doubling twice gives 64, which is one term too far. The gaps grow here, so adding a fixed amount will never carry the pattern forward.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  2, 4, 8, 16, ___' AND options = '["18", "24", "32", "64"]'::JSONB;

UPDATE questions SET explanation = 'Each term is 2 less than the one before, so the next is 14 − 2 = 12. Subtracting 1 would give 13, and subtracting 4, which is two steps at once, gives 10. Every term in this series is even, which is a second quick check that odd answers such as 13 and 11 cannot be right.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  20, 18, 16, 14, ___' AND options = '["10", "11", "12", "13"]'::JSONB;

UPDATE questions SET explanation = 'These are the odd numbers, each 2 more than the last, so the next is 7 + 2 = 9. Adding 1 would give 8 and adding 4 would give 11, but the step never changes. Any even answer, such as 8 or 10, breaks the odd-number pattern right away and can be ruled out on sight.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 3, 5, 7, ___' AND options = '["8", "9", "10", "11"]'::JSONB;

UPDATE questions SET explanation = 'These are multiples of 4, going up by 4 each time, so the next is 16 + 4 = 20. Adding 2 gives 18, and adding 8, which is two steps at once, gives 24. It helps to name the rule in words first, ''add four,'' and then apply that rule exactly once to the last term.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  4, 8, 12, 16, ___' AND options = '["18", "20", "22", "24"]'::JSONB;

UPDATE questions SET explanation = 'The terms drop by 5 each time, so the next is 15 − 5 = 10. Subtracting 3 gives 12, and subtracting 10, which is two steps at once, gives 5. Reading the pattern as counting down by fives also tells you that 5 is the term after the one being asked for, not the answer itself.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  30, 25, 20, 15, ___' AND options = '["5", "8", "10", "12"]'::JSONB;

UPDATE questions SET explanation = 'These are the multiples of 7, each 7 more than the last, so the next is 28 + 7 = 35. Skipping ahead to 6 × 7 gives 42, which is one term too far, and adding 8 instead of 7 gives 36. Counting 7, 14, 21, 28, 35 out loud keeps the step size honest.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  7, 14, 21, 28, ___' AND options = '["32", "35", "36", "42"]'::JSONB;

UPDATE questions SET explanation = 'Each term is the sum of the two before it: 1 + 1 = 2, then 1 + 2 = 3. So the next is 2 + 3 = 5. Adding 1 each time would give 4, and doubling the last term gives 6, but neither of those rules explains the two 1s at the start of the series.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 1, 2, 3, ___' AND options = '["4", "5", "6", "7"]'::JSONB;

UPDATE questions SET explanation = 'These count up by 6: 6, 12, 18, 24, so the next is 24 + 6 = 30. Doubling 18 would give 36, which skips a term, and adding 4 instead of 6 gives 28. Name the step in words first, ''add six,'' then take exactly one more step from the last term shown.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  6, 12, 18, 24, ___' AND options = '["28", "30", "32", "36"]'::JSONB;

UPDATE questions SET explanation = 'Each term is 1 less than the one before: 9, 8, 7, 6. So the next is 6 − 1 = 5. Counting down two at a time would give 4, and repeating the last term gives 6. The rule is a single step down, and it stays exactly the same for the whole series.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  9, 8, 7, 6, ___' AND options = '["4", "5", "3", "6"]'::JSONB;

UPDATE questions SET explanation = 'These are the even numbers, rising by 2 each time, so the next is 6 + 2 = 8. Adding 1 gives 7, which is odd and breaks the pattern, and adding 4 gives 10, which skips a term. Say the rule out loud, add two, then apply it once to the last term shown.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  0, 2, 4, 6, ___' AND options = '["7", "8", "9", "10"]'::JSONB;

UPDATE questions SET explanation = 'Each term is 10 less than the one before, so the next is 10 − 10 = 0. Zero is a perfectly good answer in a series. Halving the last term gives 5 and subtracting 2 gives 8, but the pattern has fallen by 10 at every step so far, and nothing here says it should change.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  40, 30, 20, 10, ___' AND options = '["0", "5", "2", "8"]'::JSONB;

UPDATE questions SET explanation = 'These are the multiples of 11, each 11 more than the last, so the next is 44 + 11 = 55. Jumping ahead to 6 × 11 gives 66, which is one term too far, and adding 4 gives 48. Repeated-digit numbers like 55 are a handy signal that you are still counting by elevens.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  11, 22, 33, 44, ___' AND options = '["48", "50", "55", "66"]'::JSONB;

UPDATE questions SET explanation = 'Each term is 3 more than the one before: 1, 4, 7, 10. So the next is 10 + 3 = 13. Adding 1 gives 11 and adding 4 gives 14, so getting the step size right is the whole question. Check the gap between two different pairs before you commit to a rule.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 4, 7, 10, ___' AND options = '["11", "12", "13", "14"]'::JSONB;

UPDATE questions SET explanation = 'These are multiples of 8, climbing by 8 each time, so the next is 32 + 8 = 40. Adding 4 gives 36, and adding 16, which is two steps at once, gives 48. The first two terms, 8 and 16, look like doubling, but 16 to 24 is only +8, so doubling is not the rule.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  8, 16, 24, 32, ___' AND options = '["36", "38", "40", "48"]'::JSONB;

UPDATE questions SET explanation = 'Read it as arithmetic: something + 7 = 15. To undo an increase, subtract: 15 − 7 = 8. Check by going forward, since 8 + 7 = 15. Testing the others the same way rules them out fast, because 7 + 7 is only 14 and 9 + 7 is 16, so 8 is the number that lands on 15.'
  WHERE section = 'quantitative' AND prompt = 'A number is increased by 7 to give 15. What is the number?' AND options = '["6", "7", "8", "9"]'::JSONB;

UPDATE questions SET explanation = 'Read it in order: something ÷ 4 = 5. Division is undone by multiplication, so the number is 5 × 4 = 20. Check forward: 20 ÷ 4 = 5. If you divide a second time by mistake you might reach for 16 or 24, but 16 ÷ 4 = 4 and 24 ÷ 4 = 6, so neither one gives 5.'
  WHERE section = 'quantitative' AND prompt = 'A number is divided by 4 to give 5. What is the number?' AND options = '["16", "20", "24", "25"]'::JSONB;

UPDATE questions SET explanation = 'Doubling means multiplying by 2, so the sentence is something × 2 = 18. Undo it by dividing: 18 ÷ 2 = 9. Check forward, since 9 + 9 = 18. The nearby answers fail that same check, because 8 doubled is 16 and 10 doubled is 20. Halving is always the way back from doubling.'
  WHERE section = 'quantitative' AND prompt = 'A number is doubled to give 18. What is the number?' AND options = '["7", "8", "9", "10"]'::JSONB;

UPDATE questions SET explanation = 'Write the sentence as arithmetic in order: something − 12 = 8. To undo a subtraction, add: 8 + 12 = 20. Check forward, since 20 − 12 = 8. Subtracting when you should add is the usual slip here, and testing 18 or 22 shows they give 6 and 10, not the 8 you need.'
  WHERE section = 'quantitative' AND prompt = 'A number is reduced by 12 to give 8. What is the number?' AND options = '["18", "20", "22", "24"]'::JSONB;

UPDATE questions SET explanation = 'The sentence says something × 6 = 42, so divide to undo the multiplication: 42 ÷ 6 = 7. Check by multiplying back: 7 × 6 = 42. Your times tables settle the rest quickly, because 6 × 6 = 36 and 8 × 6 = 48, so neither 6 nor 8 can be the missing number.'
  WHERE section = 'quantitative' AND prompt = 'A number multiplied by 6 gives 42. What is the number?' AND options = '["5", "6", "7", "8"]'::JSONB;

UPDATE questions SET explanation = 'Tripled means multiplied by 3, so the sentence is something × 3 = 27. Divide to undo it: 27 ÷ 3 = 9, and check forward with 9 × 3 = 27. Since 8 × 3 = 24 and 10 × 3 = 30, neither of those lands on 27. Naming the operation first keeps you from subtracting 3 by mistake.'
  WHERE section = 'quantitative' AND prompt = 'A number is tripled to give 27. What is the number?' AND options = '["7", "8", "9", "10"]'::JSONB;

UPDATE questions SET explanation = 'As arithmetic, the sentence is something + 15 = 30. Subtract to undo the addition: 30 − 15 = 15. It is fine that the answer matches a number in the problem, since half of 30 is 15. Checking the other choices is quick, because 14 + 15 = 29 and 13 + 15 = 28, so only 15 works.'
  WHERE section = 'quantitative' AND prompt = 'A number plus 15 equals 30. What is the number?' AND options = '["12", "13", "14", "15"]'::JSONB;

UPDATE questions SET explanation = 'In order, the sentence is something ÷ 9 = 3. Multiplication undoes division, so the number is 3 × 9 = 27. Check forward: 27 ÷ 9 = 3. The nearby answers do not even divide evenly by 9, since 24, 30 and 33 each leave a remainder, which is another sign that 27 is the one.'
  WHERE section = 'quantitative' AND prompt = 'A number divided by 9 gives 3. What is the number?' AND options = '["24", "27", "30", "33"]'::JSONB;

UPDATE questions SET explanation = 'The sentence is something × 4 = 36, so divide to undo it: 36 ÷ 4 = 9. Check by multiplying: 9 × 4 = 36. The near misses fail their own check, because 8 × 4 = 32 and 10 × 4 = 40. Deciding which operation undoes which is most of the work in questions like this.'
  WHERE section = 'quantitative' AND prompt = 'A number multiplied by 4 gives 36. What is the number?' AND options = '["7", "8", "9", "10"]'::JSONB;

UPDATE questions SET explanation = 'Written in order, the sentence is something − 5 = 11. Adding undoes subtracting, so the number is 11 + 5 = 16, and 16 − 5 = 11 checks out. Subtracting when you should add is the common slip, and testing 15 or 17 gives 10 and 12, so neither of those ends at 11.'
  WHERE section = 'quantitative' AND prompt = 'A number is decreased by 5 to give 11. What is the number?' AND options = '["14", "15", "16", "17"]'::JSONB;

UPDATE questions SET explanation = 'The sentence says something × 8 = 56. Divide to undo the multiplication: 56 ÷ 8 = 7, and 7 × 8 = 56 confirms it. The other choices are ruled out by the eight times table, because 6 × 8 = 48 and 8 × 8 = 64, and neither of those results is the 56 you were given.'
  WHERE section = 'quantitative' AND prompt = 'A number multiplied by 8 gives 56. What is the number?' AND options = '["5", "6", "7", "8"]'::JSONB;

UPDATE questions SET explanation = 'Cut in half means divided by 2, so the sentence is something ÷ 2 = 13. Doubling undoes halving: 13 × 2 = 26, and half of 26 is 13. Reaching for a rounder-looking number misses, because half of 24 is 12 and half of 28 is 14, so only 26 gives you 13.'
  WHERE section = 'quantitative' AND prompt = 'A number is cut in half to give 13. What is the number?' AND options = '["24", "25", "26", "28"]'::JSONB;

UPDATE questions SET explanation = 'As arithmetic, the sentence is something + 21 = 50, so subtract to undo it: 50 − 21 = 29. Check forward, since 29 + 21 = 50. Careless borrowing is what trips people here and produces 28 or 30, but 28 + 21 = 49 and 30 + 21 = 51, so 29 is the only fit.'
  WHERE section = 'quantitative' AND prompt = 'A number plus 21 equals 50. What is the number?' AND options = '["27", "28", "29", "30"]'::JSONB;

UPDATE questions SET explanation = 'The sentence is something × 7 = 49, so divide: 49 ÷ 7 = 7. Since 7 × 7 = 49, the number and the multiplier happen to match, which is fine. Check the neighbors with the seven times table, because 6 × 7 = 42 and 8 × 7 = 56, so neither of them reaches 49.'
  WHERE section = 'quantitative' AND prompt = 'A number multiplied by 7 gives 49. What is the number?' AND options = '["5", "6", "7", "8"]'::JSONB;

UPDATE questions SET explanation = 'When the top numbers match, the fraction with the bigger bottom number is the smaller one, because you are splitting into more pieces. One half is 0.5 and one third is about 0.33, so A is greater. Seeing 3 beat 2 tempts people to call B greater, but halves and thirds are not equal.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 1/2  vs.  (B) 1/3. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Work out both sides before deciding. A is 8 × 3 = 24 and B is 6 × 4 = 24, so neither one is greater and the two are equal. Both products are made of known numbers, so there is enough information to determine them exactly, and you never have to guess on a comparison you can compute.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 8 × 3  vs.  (B) 6 × 4. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Different operations can still land on the same value, so compute each side. A is 15 − 6 = 9 and B is 4 + 5 = 9. They match, so neither is greater. Because both expressions use plain numbers, you can determine each one exactly instead of judging by how large the pieces look.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 15 − 6  vs.  (B) 4 + 5. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Give the fractions a common denominator: 2/5 = 4/10, and B is already 3/10. Four tenths beats three tenths, so A is greater. Looking only at the bottom numbers can make B seem greater, but once both are written in tenths you can determine the order and see they are not equal.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 2/5  vs.  (B) 3/10. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Do each side first: A is 20 ÷ 4 = 5, and B is 3 × 2 = 6. Six is more than five, so B is greater. A quick glance at the big number 20 tempts you into saying A is greater, but the division cuts it down to 5, and 5 and 6 are close without being equal.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 20 ÷ 4  vs.  (B) 3 × 2. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Compute both sides: A is 7 + 4 = 11 and B is 3 × 4 = 12. Twelve is larger, so B is greater. The two sides are close, which is exactly why guessing from the look of the numbers is risky. Eleven and twelve are not equal, and the bigger starting number does not decide it.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 7 + 4  vs.  (B) 3 × 4. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Put both fractions in simplest form: 6/8 divides top and bottom by 2 to give 3/4, which is the same as A. So they are equal and neither is greater. Bigger-looking numbers do not mean a bigger fraction, and simplifying lets you determine that these are two names for one amount.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 3/4  vs.  (B) 6/8. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Area of a rectangle is length × width. A gives 6 × 4 = 24 and B gives 5 × 5 = 25, so B is greater. Notice that both shapes have the same perimeter, 20, which makes it tempting to call them equal. For a fixed perimeter, the squarer shape always holds more area.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a rectangle with length 6 and width 4. Shape B: a rectangle with length 5 and width 5. Which has the greater area?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Use area = length × width for both shapes. A gives 8 × 3 = 24 and B gives 6 × 4 = 24, so the areas are equal and neither is greater. The two look nothing alike, since one is long and thin, but different side lengths can multiply to the same area once you determine both.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a rectangle with length 8 and width 3. Shape B: a rectangle with length 6 and width 4. Which has the greater area?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Perimeter of a rectangle is 2 × (length + width). A gives 2 × (5 + 3) = 16 and B gives 2 × (4 + 4) = 16, so they are equal. Their areas differ, 15 against 16, so computing area by mistake would tell you B is greater. This question asks for perimeter, so add the sides.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a rectangle with length 5 and width 3. Shape B: a rectangle with length 4 and width 4. Which has the greater perimeter?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Area is length × width, so A is 10 × 2 = 20 and B is 7 × 3 = 21. B is greater by one square unit. The length 10 is the biggest number in the problem and makes A look greater at a glance, but a long thin rectangle can lose to a squarer one, and 20 and 21 are not equal.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a rectangle with length 10 and width 2. Shape B: a rectangle with length 7 and width 3. Which has the greater area?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Perimeter of a square is 4 × side, so A is 4 × 4 = 16. For a rectangle it is 2 × (length + width), so B is 2 × (6 + 3) = 18, which means B is greater. Be careful with the square, because its area is also 16, and that repeated number can make the shapes seem equal.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a square with side 4. Shape B: a rectangle with length 6 and width 3. Which has the greater perimeter?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Area is length × width. A gives 9 × 2 = 18 and B gives 3 × 6 = 18, so the areas are equal and neither is greater. Their perimeters are quite different, 22 against 18, so a shape that looks bigger on the page is not always bigger in area. Compute both and you can determine it.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a rectangle with length 9 and width 2. Shape B: a rectangle with length 3 and width 6. Which has the greater area?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Each term is 3 times the one before: 2 × 3 = 6, 6 × 3 = 18, and 18 × 3 = 54. So the next is 54 × 3 = 162. Doubling instead gives 108, and multiplying by 4 gives 216. Test a possible rule on every pair you can see, not only on the first two terms.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  2, 6, 18, 54, ___' AND options = '["108", "144", "162", "216"]'::JSONB;

UPDATE questions SET explanation = 'Look at the gaps: 1 to 2 is +1, then +2, then +3, then +4. The gaps grow by one, so the next gap is +5 and the term is 11 + 5 = 16. Repeating the last gap of +4 gives 15, and using +3 gives 14. Once the gaps form a pattern, continue the gaps rather than the terms.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 2, 4, 7, 11, ___' AND options = '["14", "15", "16", "18"]'::JSONB;

UPDATE questions SET explanation = 'Each term is 3 times the one before: 5, 15, 45, 135. So the next is 135 × 3 = 405. Doubling the last term instead gives 270, and rounding toward a tidy-looking 400 is another trap, since series answers rarely need rounding. Multiply in pieces: 300 + 90 + 15 = 405.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  5, 15, 45, 135, ___' AND options = '["270", "375", "400", "405"]'::JSONB;

UPDATE questions SET explanation = 'Take the differences: +3, +5, +7, +9. Those are the odd numbers, each 2 bigger than the last, so the next difference is +11 and the term is 26 + 11 = 37. Repeating +9 gives 35 and using +10 gives 36. Each term is also one more than a square, and 36 + 1 = 37.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  2, 5, 10, 17, 26, ___' AND options = '["35", "36", "37", "38"]'::JSONB;

UPDATE questions SET explanation = 'Each term is double the one before, plus 1: 15 × 2 + 1 = 31, so the next is 31 × 2 + 1 = 63. Doubling and forgetting the +1 gives 62. You can also follow the gaps, which double: 2, 4, 8, 16, then 32, and 31 + 32 = 63. Reusing a gap of 16 gives 47.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 3, 7, 15, 31, ___' AND options = '["47", "55", "62", "63"]'::JSONB;

UPDATE questions SET explanation = 'Each term is half the one before: 100, 50, 25, 12.5. So the next is 12.5 ÷ 2 = 6.25. Halving does not have to stop at whole numbers. Subtracting 5 from 12.5 gives 7.5, and rounding the half away gives 6, but the rule has been steady division by 2 the whole way down.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  100, 50, 25, 12.5, ___' AND options = '["5", "6", "6.25", "7.5"]'::JSONB;

UPDATE questions SET explanation = 'Each term is 3 times the one before, so these are the powers of 3 and the next is 81 × 3 = 243. Doubling gives 162 and multiplying by 4 gives 324. Working in pieces helps: 80 × 3 = 240, plus 1 × 3, gives 243. Naming the rule before you multiply keeps the step size right.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  3, 9, 27, 81, ___' AND options = '["162", "243", "270", "324"]'::JSONB;

UPDATE questions SET explanation = 'Each term is 4 more than the one before: 1, 5, 9, 13, 17. So the next is 17 + 4 = 21. Adding 2 would give 19 and adding 5 would give 22. Every term here is one more than a multiple of 4, and 21 fits that description too, which is a quick way to check your answer.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 5, 9, 13, 17, ___' AND options = '["19", "20", "21", "22"]'::JSONB;

UPDATE questions SET explanation = 'These are the prime numbers, 2, 3, 5, 7, 11, each divisible only by 1 and itself, so the next one is 13. Do not hunt for a gap rule, because the gaps here are 1, 2, 2, 4 and never settle. Also, 12, 14 and 15 all have smaller factors, so none of them can be prime.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  2, 3, 5, 7, 11, ___' AND options = '["12", "13", "14", "15"]'::JSONB;

UPDATE questions SET explanation = 'Each term is 3 less than the one before: 10, 7, 4, 1. So the next is 1 − 3 = −2. A series is allowed to cross zero and keep going. Stopping at 0 treats zero as a floor, and subtracting only 2 gives −1, but the step has been −3 at every point so far.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  10, 7, 4, 1, ___' AND options = '["−1", "−2", "0", "−3"]'::JSONB;

UPDATE questions SET explanation = 'Each term is double the one before, so these are the powers of 2 and the next is 16 × 2 = 32. Adding the last gap of 8 gives 24, and doubling twice lands on 64, which is the term after the one asked for. With doubling, the gaps grow, so a fixed addition will not work.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 2, 4, 8, 16, ___' AND options = '["24", "28", "32", "64"]'::JSONB;

UPDATE questions SET explanation = 'The differences are +1, +2, +3, +4, growing by one each time, so the next difference is +5 and the term is 15 + 5 = 20. Repeating the last difference of +4 gives 19, and using +3 gives 18. When terms grow unevenly, look at the gaps and continue the gap pattern instead.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  5, 6, 8, 11, 15, ___' AND options = '["18", "19", "20", "21"]'::JSONB;

UPDATE questions SET explanation = 'These are square numbers: 2², 3², 4², 5², 6², so the next is 7² = 49. The gaps tell the same story, since they run 5, 7, 9, 11, growing by 2, so the next gap is 13 and 36 + 13 = 49. Reusing a gap of 11 gives 47, and adding 6 gives 42, but both break the pattern.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  4, 9, 16, 25, 36, ___' AND options = '["42", "47", "49", "50"]'::JSONB;

UPDATE questions SET explanation = 'The differences are +4, +6, +8, +10, rising by 2, so the next is +12 and the term is 30 + 12 = 42. Repeating +10 gives 40 and using +8 gives 38. Another view: each term is a number times the next one, 1 × 2, 2 × 3, 3 × 4, 4 × 5, 5 × 6, so the next is 6 × 7 = 42.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  2, 6, 12, 20, 30, ___' AND options = '["38", "40", "42", "44"]'::JSONB;

UPDATE questions SET explanation = 'Each term is the one before divided by 3: 81, 27, 9, 3. So the next is 3 ÷ 3 = 1. Subtracting instead of dividing makes 0 or 2 look possible, and repeating the last term gives 3, but the rule has been steady division by 3, and dividing a positive number never reaches 0.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  81, 27, 9, 3, ___' AND options = '["1", "0", "2", "3"]'::JSONB;

UPDATE questions SET explanation = 'These are the cubes: 1 × 1 × 1, 2 × 2 × 2, 3 × 3 × 3, 4 × 4 × 4, so the next is 5 × 5 × 5 = 125. If you slip into squares you land on 100 or 121, which are 10² and 11². The jump from 27 to 64 was 37, so the next term has to clear 100 comfortably.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 8, 27, 64, ___' AND options = '["100", "108", "121", "125"]'::JSONB;

UPDATE questions SET explanation = 'The differences are +3, +4, +5, +6, each one bigger than the last, so the next is +7 and the term is 25 + 7 = 32. Repeating +6 gives 31 and using +5 gives 30. The terms themselves follow no tidy rule, but the gaps do, and that is what makes this series solvable.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  7, 10, 14, 19, 25, ___' AND options = '["30", "31", "32", "33"]'::JSONB;

UPDATE questions SET explanation = 'Each term is 2 more than the one before, so these are the even numbers and the next is 10 + 2 = 12. Any odd answer, such as 11 or 13, breaks the pattern immediately. Adding 4 gives 14, which skips a term. Say the rule first, add two, then take exactly one step.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  2, 4, 6, 8, 10, ___' AND options = '["11", "12", "13", "14"]'::JSONB;

UPDATE questions SET explanation = 'Each term is 5 more than the one before: 1, 6, 11, 16, 21. So the next is 21 + 5 = 26. Adding 4 gives 25 and adding 6 gives 27. Every term ends in 1 or 6, which is a fast way to check an answer, and 26 ends in 6, so it fits the pattern.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 6, 11, 16, 21, ___' AND options = '["24", "25", "26", "27"]'::JSONB;

UPDATE questions SET explanation = 'Each term is double the one before, plus 1: 31 × 2 + 1 = 63, so the next is 63 × 2 + 1 = 127. Every term here sits one below a power of 2, which is why 128 looks so tempting, but 128 is the power itself, not the term. Reusing a gap of 32 instead of 64 gives 95.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  3, 7, 15, 31, 63, ___' AND options = '["95", "121", "127", "128"]'::JSONB;

UPDATE questions SET explanation = 'The differences are +1, +2, +3, +4, so the next is +5 and the term is 10 + 5 = 15. These are the triangular numbers, the running totals of 1, 2, 3, 4 and 5. Repeating +4 gives 14 and using +3 gives 13, but the gaps clearly grow by one at every step.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  0, 1, 3, 6, 10, ___' AND options = '["13", "14", "15", "16"]'::JSONB;

UPDATE questions SET explanation = 'The series alternates two moves: double, then subtract 1. Check it, since 3 doubles to 6, 6 minus 1 is 5, 5 doubles to 10, 10 minus 1 is 9, and 9 doubles to 18. A double has just happened, so a subtraction is due: 18 − 1 = 17. Doubling again gives 36, adding 1 gives 19, and subtracting 2 gives 16.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  3, 6, 5, 10, 9, 18, ___' AND options = '["16", "17", "19", "36"]'::JSONB;

UPDATE questions SET explanation = 'Each term is the one before multiplied by a growing number: 1 × 2 = 2, 2 × 3 = 6, 6 × 4 = 24, so the next is 24 × 5 = 120. These are the factorials. Multiplying by 4 again gives 96 and multiplying by 6 gives 144, so the key is noticing that the multiplier itself climbs by one.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 2, 6, 24, ___' AND options = '["96", "100", "120", "144"]'::JSONB;

UPDATE questions SET explanation = 'Undo the steps in reverse order. The last move was subtracting 5, so add it back: 19 + 5 = 24. Before that the number was multiplied by 3, so divide: 24 ÷ 3 = 8. Check forward, since 8 × 3 = 24 and 24 − 5 = 19. Testing 7 gives 16 and 9 gives 22, so neither fits.'
  WHERE section = 'quantitative' AND prompt = 'A number is multiplied by 3, then 5 is subtracted, giving 19. What was the original number?' AND options = '["6", "7", "8", "9"]'::JSONB;

UPDATE questions SET explanation = 'Work backwards through the steps. Doubling came last, so halve: 22 ÷ 2 = 11. Then undo the increase of 4: 11 − 4 = 7. Check forward, since 7 + 4 = 11 and 11 doubled is 22. Stopping halfway leaves 11, and undoing in the wrong order, subtracting 4 first and then halving, gives 9.'
  WHERE section = 'quantitative' AND prompt = 'A number is increased by 4, then doubled, giving 22. What was the original number?' AND options = '["7", "8", "9", "11"]'::JSONB;

UPDATE questions SET explanation = 'Undo the last step first: 6 was added, so 14 − 6 = 8. Before that the number was halved, so double: 8 × 2 = 16. Check forward, since half of 16 is 8 and 8 + 6 = 14. Testing the others settles it, because half of 18 plus 6 is 15 and half of 20 plus 6 is 16.'
  WHERE section = 'quantitative' AND prompt = 'A number is halved, then 6 is added, giving 14. What was the original number?' AND options = '["14", "16", "18", "20"]'::JSONB;

UPDATE questions SET explanation = 'Undo the steps in reverse. The last move was dividing by 2, so multiply: 10 × 2 = 20. Before that came multiplying by 4, so divide: 20 ÷ 4 = 5. Check forward, since 5 × 4 = 20 and half of 20 is 10. The two steps together only double a number, so 6 would give 12 and 4 would give 8.'
  WHERE section = 'quantitative' AND prompt = 'A number is multiplied by 4, then divided by 2, giving 10. What was the original number?' AND options = '["3", "4", "5", "6"]'::JSONB;

UPDATE questions SET explanation = 'Reverse the steps, last one first. Multiplying by 3 came last, so divide: 21 ÷ 3 = 7. Before that 8 was subtracted, so add it back: 7 + 8 = 15. Check forward, since 15 − 8 = 7 and 7 × 3 = 21. Order matters, because subtracting 8 from 21 first would push you toward 13 instead.'
  WHERE section = 'quantitative' AND prompt = 'A number is decreased by 8, then multiplied by 3, giving 21. What was the original number?' AND options = '["13", "14", "15", "16"]'::JSONB;

UPDATE questions SET explanation = 'Undo the last step first: 4 was added, so 9 − 4 = 5. Before that the number was divided by 6, so multiply: 5 × 6 = 30. Check forward, since 30 ÷ 6 = 5 and 5 + 4 = 9. Testing the others rules them out, because 24 gives 8 and 36 gives 10, not the 9 you need.'
  WHERE section = 'quantitative' AND prompt = 'A number is divided by 6, then 4 is added, giving 9. What was the original number?' AND options = '["24", "30", "36", "42"]'::JSONB;

UPDATE questions SET explanation = 'Work backwards. Subtracting 10 came last, so add it back: 40 + 10 = 50. Then undo the multiplication by 5: 50 ÷ 5 = 10. Check forward, since 10 × 5 = 50 and 50 − 10 = 40. Forgetting to restore the 10 first gives 40 ÷ 5 = 8, which is exactly why 8 is offered as a choice.'
  WHERE section = 'quantitative' AND prompt = 'A number is multiplied by 5, then 10 is subtracted, giving 40. What was the original number?' AND options = '["8", "9", "10", "11"]'::JSONB;

UPDATE questions SET explanation = 'Undo the steps in reverse order. Adding 7 came last, so 29 − 7 = 22. The number had been doubled, so halve: 22 ÷ 2 = 11. Check forward, since 11 doubled is 22 and 22 + 7 = 29. Halving before subtracting gives 14.5, and testing 12 gives 31 while 10 gives 27.'
  WHERE section = 'quantitative' AND prompt = 'A number is doubled, then 7 is added, giving 29. What was the original number?' AND options = '["10", "11", "12", "13"]'::JSONB;

UPDATE questions SET explanation = 'Reverse the steps. Dividing by 4 came last, so multiply: 6 × 4 = 24. Before that 9 was added, so subtract: 24 − 9 = 15. Check forward, since 15 + 9 = 24 and 24 ÷ 4 = 6. Testing the others rules them out, because 16 gives 25 ÷ 4 and 13 gives 22 ÷ 4, neither of which is 6.'
  WHERE section = 'quantitative' AND prompt = 'A number is increased by 9, then divided by 4, giving 6. What was the original number?' AND options = '["13", "14", "15", "16"]'::JSONB;

UPDATE questions SET explanation = 'Undo the last step first: the number was multiplied by 5, so divide: 25 ÷ 5 = 5. Before that it was divided by 3, so multiply: 5 × 3 = 15. Check forward, since 15 ÷ 3 = 5 and 5 × 5 = 25. Testing the others settles it, because 12 leads to 20 and 18 leads to 30.'
  WHERE section = 'quantitative' AND prompt = 'A number is divided by 3, then multiplied by 5, giving 25. What was the original number?' AND options = '["12", "13", "15", "18"]'::JSONB;

UPDATE questions SET explanation = 'Work backwards. Subtracting 12 came last, so add it back: 24 + 12 = 36. Tripling came first, so divide: 36 ÷ 3 = 12. Check forward, since 12 × 3 = 36 and 36 − 12 = 24. Dividing before restoring the 12 gives only 8, and testing 11 gives 21 while 13 gives 27.'
  WHERE section = 'quantitative' AND prompt = 'A number is tripled, then 12 is subtracted, giving 24. What was the original number?' AND options = '["10", "11", "12", "13"]'::JSONB;

UPDATE questions SET explanation = 'Reverse the steps, starting with the last. Multiplying by 7 came last, so divide: 35 ÷ 7 = 5. Then undo the decrease of 3: 5 + 3 = 8. Check forward, since 8 − 3 = 5 and 5 × 7 = 35. Stopping after the division leaves 5, while testing 7 gives 28 and 10 gives 49.'
  WHERE section = 'quantitative' AND prompt = 'A number is decreased by 3, then multiplied by 7, giving 35. What was the original number?' AND options = '["7", "8", "9", "10"]'::JSONB;

UPDATE questions SET explanation = 'Undo the last step first: dividing by 8 came last, so multiply: 3 × 8 = 24. Before that the number was doubled, so halve: 24 ÷ 2 = 12. Check forward, since 12 × 2 = 24 and 24 ÷ 8 = 3. The two steps together divide by 4, and 10 or 13 do not divide by 4 evenly.'
  WHERE section = 'quantitative' AND prompt = 'A number is multiplied by 2, then divided by 8, giving 3. What was the original number?' AND options = '["10", "11", "12", "13"]'::JSONB;

UPDATE questions SET explanation = 'Reverse the steps. Halving came last, so double: 11 × 2 = 22. Then undo the increase of 6: 22 − 6 = 16. Check forward, since 16 + 6 = 22 and half of 22 is 11. Testing the others rules them out, because 14 gives 10 and 17 gives 11.5, not the 11 you were given.'
  WHERE section = 'quantitative' AND prompt = 'A number is increased by 6, then halved, giving 11. What was the original number?' AND options = '["14", "15", "16", "17"]'::JSONB;

UPDATE questions SET explanation = 'Undo the last step first: 6 was added, so 42 − 6 = 36. The number had been multiplied by 6, so divide: 36 ÷ 6 = 6. Check forward, since 6 × 6 = 36 and 36 + 6 = 42. Dividing 42 by 6 before removing the added 6 gives 7, which is exactly the trap this question sets.'
  WHERE section = 'quantitative' AND prompt = 'A number is multiplied by 6, then 6 is added, giving 42. What was the original number?' AND options = '["5", "6", "7", "8"]'::JSONB;

UPDATE questions SET explanation = 'Work backwards. Subtracting 9 came last, so add it back: 1 + 9 = 10. Before that the number was divided by 4, so multiply: 10 × 4 = 40. Check forward, since 40 ÷ 4 = 10 and 10 − 9 = 1. Testing the others, 36 gives 9 − 9 = 0 and 48 gives 12 − 9 = 3, so only 40 lands on 1.'
  WHERE section = 'quantitative' AND prompt = 'A number is divided by 4, then 9 is subtracted, giving 1. What was the original number?' AND options = '["36", "40", "44", "48"]'::JSONB;

UPDATE questions SET explanation = 'Undo the last step first: dividing by 3 came last, so multiply: 21 × 3 = 63. Then undo the multiplication by 9: 63 ÷ 9 = 7. Check forward, since 7 × 9 = 63 and 63 ÷ 3 = 21. The two steps together triple a number, so 6 would give 18 and 8 would give 24, not 21.'
  WHERE section = 'quantitative' AND prompt = 'A number is multiplied by 9, then divided by 3, giving 21. What was the original number?' AND options = '["5", "6", "7", "8"]'::JSONB;

UPDATE questions SET explanation = 'Reverse the steps. Tripling came last, so divide: 48 ÷ 3 = 16. Then undo the increase of 11: 16 − 11 = 5. Check forward, since 5 + 11 = 16 and 16 tripled is 48. Undoing in the wrong order, subtracting 11 from 48 first, gives 37, and testing 6 leads to 51 instead.'
  WHERE section = 'quantitative' AND prompt = 'A number is increased by 11, then tripled, giving 48. What was the original number?' AND options = '["4", "5", "6", "7"]'::JSONB;

UPDATE questions SET explanation = 'Undo the last step first: 3 was subtracted, so add it back: 7 + 3 = 10. Before that the number was halved, so double: 10 × 2 = 20. Check forward, since half of 20 is 10 and 10 − 3 = 7. Testing the others, half of 18 minus 3 is 6 and half of 22 minus 3 is 8.'
  WHERE section = 'quantitative' AND prompt = 'A number is halved, then 3 is subtracted, giving 7. What was the original number?' AND options = '["18", "19", "20", "22"]'::JSONB;

UPDATE questions SET explanation = 'Powers are not the same as multiplying the two numbers together. A is 2³ = 2 × 2 × 2 = 8, and B is 3² = 3 × 3 = 9, so B is greater. Reading both as 2 × 3 makes them look equal, and the larger exponent in A can make A seem greater, but the base matters just as much.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 2³  vs.  (B) 3². Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Multiply each side out: A is 5 × 7 = 35 and B is 4 × 9 = 36, so B is greater by one. The pairs are close, and A holds the larger single number, 7, which makes A look greater at a glance. Both products are exact, so you can determine them and compare instead of estimating.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 5 × 7  vs.  (B) 4 × 9. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Compare with a common denominator: 2/3 = 16/24 and 5/8 = 15/24, so A is greater. As decimals that is about 0.67 against 0.625. The bigger numbers in 5/8 make B look greater, and the two sit close enough to seem equal, but sixteen twenty-fourths beats fifteen twenty-fourths.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 2/3  vs.  (B) 5/8. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Work through each side in order. A is 7² − 4² = 49 − 16 = 33. For B, do the bracket first: (7 − 4)² = 3² = 9, then 9 × 5 = 45. So B is greater. Treating 7² − 4² as though it equals (7 − 4)² gives 9, but the real value, 33, is still not equal to 45.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 7² − 4²  vs.  (B) (7−4)² × 5. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'A square root asks what number times itself gives 64, and that number is 8. B is 2³ = 2 × 2 × 2 = 8 as well, so the two are equal and neither is greater. Halving 64, or reading 2³ as 2 × 3, leads somewhere else. Work each side out fully and you can determine that both are 8.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) √64  vs.  (B) 2³. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Add the fractions using a common denominator: 3/5 = 12/20 and 1/4 = 5/20, so A is 17/20, or 0.85. B is 9/10 = 0.90, so B is greater. Adding tops and bottoms straight across would give 4/9, which is far too small. The two sides are close here, but they are not equal.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 3/5 + 1/4  vs.  (B) 9/10. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Percent of a number means multiply. A is 0.40 × 80 = 32 and B is 0.30 × 100 = 30, so A is greater. The round 100 in B makes it look like the bigger quantity, but a larger percent of a smaller number can win. Both are exact, so you can determine them and see they are not equal.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 40% of 80  vs.  (B) 30% of 100. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Write each power out in full. A is 6² = 6 × 6 = 36, and B is 4³ = 4 × 4 × 4 = 64, so B is greater. The bigger base in A makes it tempting to say A is greater, but the third power multiplies one extra time, which more than makes up for it. The values are not equal.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 6²  vs.  (B) 4³. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Turn each percent into a multiplication. A is 0.25 × 60 = 15, a quarter of 60. B is 0.20 × 75 = 15, a fifth of 75. They match, so neither is greater. A bigger percent of a smaller number can tie a smaller percent of a bigger one, so compute both and you can determine the result.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 25% of 60  vs.  (B) 20% of 75. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Use a common denominator of 84: 4/7 = 48/84 and 7/12 = 49/84, so B is greater by a single eighty-fourth. Both sit a little above one half, which makes them look equal, and the larger numerator in A can make A seem greater. Rewriting them as equivalent fractions settles it.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 4/7  vs.  (B) 7/12. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Compute each one. A is half of 50, which is 25, and B is a quarter of 100, also 25. They are equal, so neither is greater. Percent questions reward doing the arithmetic rather than trusting how the numbers look, and since both values are exact you can determine them and compare.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 50% of 50  vs.  (B) 25% of 100. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Take each square root separately: √36 = 6 and √16 = 4, so A is 6 + 4 = 10. B is √100 = 10, so the two are equal and neither is greater. Treat this as a coincidence, not a rule. Since 36 + 16 = 52, adding under one root would have given √52, which is a different number.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) √36 + √16  vs.  (B) √100. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Multiply each side: A is 8 × 9 = 72 and B is 6 × 12 = 72, so they are equal and neither is greater. Different pairs of factors can share a product, and the fact that 12 is the largest number in sight does not decide it. Both are exact products you can determine and compare.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 8 × 9  vs.  (B) 6 × 12. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Give them a common denominator of 40: 3/8 = 15/40 and 2/5 = 16/40, so B is greater. The larger numbers in 3/8 make A look greater, and the two are close enough to feel equal, but fifteen fortieths falls a shade under sixteen. Decimals work too, since 0.375 is below 0.400.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 3/8  vs.  (B) 2/5. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Handle the power first: 10² = 100, then 100 ÷ 4 = 25. B is 5 × 5 = 25, so the two are equal and neither is greater. Dividing before squaring would mean (10 ÷ 4)², a completely different value. Order of operations decides this one, and both sides can be determined exactly.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 10² ÷ 4  vs.  (B) 5 × 5. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Area of a triangle is base × height ÷ 2, and in a right triangle the two legs act as base and height. A is 6 × 8 ÷ 2 = 24, and B is 5 × 4 = 20, so A is greater. Forgetting to halve gives 48, while assuming a triangle must be smaller makes B look greater. The two are not equal.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a right triangle with legs 6 and 8. Shape B: a rectangle with length 5 and width 4. Which has the greater area?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Triangle area is base × height ÷ 2, so A is 10 × 6 ÷ 2 = 30. Rectangle area is length × width, so B is 4 × 8 = 32, which means B is greater. Skipping the halving step gives 60 and makes A look greater, and that is the most common slip. The real values are close but not equal.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a triangle with base 10 and height 6. Shape B: a rectangle with length 4 and width 8. Which has the greater area?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Use the right formula for each shape. A is length × width = 7 × 6 = 42, and B is base × height ÷ 2 = 12 × 8 ÷ 2 = 48, so B is greater. A triangle with bigger measurements can still win even after halving. Every length is given, so you can determine both areas exactly and see that they are not equal.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a rectangle with length 7 and width 6. Shape B: a triangle with base 12 and height 8. Which has the greater area?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Square area is side × side, so A is 6 × 6 = 36. Triangle area is base × height ÷ 2, so B is 9 × 8 ÷ 2 = 36. They are equal, so neither is greater. Forgetting to halve the triangle gives 72 and makes B look greater. Each shape has its own formula, and using both properly shows the tie.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a square with side 6. Shape B: a triangle with base 9 and height 8. Which has the greater area?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Perimeter of a rectangle is 2 × (length + width). A gives 2 × (9 + 4) = 26 and B gives 2 × (6 + 6) = 24, so A is greater. Watch what is being asked, because both shapes have an area of 36, and anyone who multiplies instead of adding will call them equal. Perimeter adds the sides.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a rectangle with length 9 and width 4. Shape B: a rectangle with length 6 and width 6. Which has the greater perimeter?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Area of a rectangle is length × width, so A is 12 × 3 = 36. Area of a square is side × side, so B is 5 × 5 = 25, which makes A greater. Squares hold the most area only when the perimeter is fixed, and these perimeters differ, so that idea does not apply here. Both areas can be determined exactly, and they are nowhere near equal.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a rectangle with length 12 and width 3. Shape B: a square with side 5. Which has the greater area?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Triangle area is base × height ÷ 2, so A is 14 × 6 ÷ 2 = 42. Square area is side × side, so B is 6 × 6 = 36, which makes A greater. Forgetting to halve gives 84, and comparing only the height 6 against the side 6 can make the two shapes seem equal. The long base pushes A ahead.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a triangle with base 14 and height 6. Shape B: a square with side 6. Which has the greater area?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Rectangle area is length × width, so A is 8 × 5 = 40. Triangle area is base × height ÷ 2, so B is 16 × 5 ÷ 2 = 40. They are equal, so neither is greater. This is a classic pairing, since a triangle with double the base and the same height matches the rectangle. Skip the halving and you get 80.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a rectangle with length 8 and width 5. Shape B: a triangle with base 16 and height 5. Which has the greater area?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'In a right triangle the two legs serve as base and height, so the area is 5 × 12 ÷ 2 = 30. The rectangle is 4 × 7 = 28, so A is greater. Forgetting to halve gives 60, and assuming a triangle must be smaller than a rectangle makes B look greater. The areas are close but not equal.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a right triangle with legs 5 and 12. Shape B: a rectangle with length 4 and width 7. Which has the greater area?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Perimeter of a square is 4 × side, so A is 4 × 7 = 28. Perimeter of a rectangle is 2 × (length + width), so B is 2 × (11 + 4) = 30, which means B is greater. Areas would flip the verdict, 49 against 44, so read carefully. Perimeter adds the sides, and once you determine both you see they are not equal.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a square with side 7. Shape B: a rectangle with length 11 and width 4. Which has the greater perimeter?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Rectangle area is length × width, so A is 10 × 6 = 60. Triangle area is base × height ÷ 2, so B is 20 × 6 ÷ 2 = 60. They are equal, so neither is greater. Doubling the base and then halving cancel each other out, which is why these match. Forgetting to halve gives 120 and makes B look greater.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a rectangle with length 10 and width 6. Shape B: a triangle with base 20 and height 6. Which has the greater area?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Area of a square is side times side; area of a rectangle is length times width. A: 8 x 8 = 64. B: 10 x 6 = 60. So A is greater. B tempts you because it has the longest single side, 10, but it is also narrow, and a long thin shape loses area. Both numbers are exact, so they are not equal.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a square with side 8. Shape B: a rectangle with length 10 and width 6. Which has the greater area?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'For a triangle, area is base times height divided by two. A: 10 x 10 = 100, then halved gives 50. B: 4 x 12 = 48. So A is greater, by only 2. The margin is thin enough that guessing equal, or that you cannot determine it, feels safe, but both areas work out exactly and 50 beats 48.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a triangle with base 10 and height 10. Shape B: a rectangle with length 4 and width 12. Which has the greater area?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Perimeter is the distance all the way around. A rectangle: 2 x (15 + 2) = 34. A square: 4 x 5 = 20. So A is greater. Watch that this asks about perimeter, not area, where the answer would flip: the rectangle covers 30 and the square 25, a much closer call. They are far from equal here.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a rectangle with length 15 and width 2. Shape B: a square with side 5. Which has the greater perimeter?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Each term is the sum of the two before it: 3 + 5 = 8, and 5 + 8 = 13. So 8 + 13 = 21. Repeating the last gap of 5 gives 18, and reading the gaps as 1, 2, 3 and continuing 4, 5, 6 gives 19. The gaps really run 1, 2, 3, 5, 8, growing the same way the terms do.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 1, 2, 3, 5, 8, 13, ___' AND options = '["18", "19", "20", "21"]'::JSONB;

UPDATE questions SET explanation = 'Each term is the sum of the two before it: 2 + 1 = 3, 3 + 4 = 7, 4 + 7 = 11. So 7 + 11 = 18. Working from gaps instead is risky: they run 2, 1, 3, 4, so guessing a next gap of 4 gives 15 and guessing 6 gives 17. The gaps follow the same adding rule.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  2, 1, 3, 4, 7, 11, ___' AND options = '["14", "15", "17", "18"]'::JSONB;

UPDATE questions SET explanation = 'These are the triangular numbers, where you add one more each time. The gaps are 2, 3, 4, 5, 6, so the next gap is 7: 21 + 7 = 28. Holding the gap at 6 gives 27, which looks close and reasonable, but the gap has grown at every single step so far, so there is no reason for it to stop growing now.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 3, 6, 10, 15, 21, ___' AND options = '["25", "27", "28", "30"]'::JSONB;

UPDATE questions SET explanation = 'Each term is double the one before, plus 1: 2 x 2 + 1 = 5, 5 x 2 + 1 = 11, 23 x 2 + 1 = 47. So 47 x 2 + 1 = 95. Doubling and adding 2 gives 96, and doubling and subtracting 1 gives 93. Test those at the start: only the plus 1 turns 2 into 5.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  2, 5, 11, 23, 47, ___' AND options = '["89", "93", "95", "96"]'::JSONB;

UPDATE questions SET explanation = 'Each term is double the one before, minus 1: 3 x 2 - 1 = 5, 5 x 2 - 1 = 9, 17 x 2 - 1 = 33. So 33 x 2 - 1 = 65. Plain doubling gives 66, but that fails right away, since 3 doubled is 6, not 5. The gaps 2, 4, 8, 16, then 32, confirm 33 + 32 = 65.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  3, 5, 9, 17, 33, ___' AND options = '["55", "60", "65", "66"]'::JSONB;

UPDATE questions SET explanation = 'Look at what happens between terms: each one is three times the term before it, minus 1. Check it: 5 x 3 - 1 = 14, and 14 x 3 - 1 = 41. So the next term is 41 x 3 - 1 = 122. Tripling without subtracting gives 123, and simply doubling gives 82 - both miss the small correction that makes the pattern hold at every step.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 2, 5, 14, 41, ___' AND options = '["82", "122", "123", "132"]'::JSONB;

UPDATE questions SET explanation = 'Each term is double the one before, minus 1: 4 x 2 - 1 = 7, 13 x 2 - 1 = 25, 25 x 2 - 1 = 49. So 49 x 2 - 1 = 97. Doubling and adding 2 gives 100, a rounder looking answer, but check that at the start: 4 x 2 + 2 = 10, not the 7 that follows.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  4, 7, 13, 25, 49, ___' AND options = '["82", "90", "97", "100"]'::JSONB;

UPDATE questions SET explanation = 'Each term is the one before multiplied by the next counting number: 1 x 2 = 2, 2 x 3 = 6, 6 x 4 = 24, 24 x 5 = 120. The next step multiplies by 6: 120 x 6 = 720. Multiplying by 5 again gives 600, and jumping to 7 gives 840. The multiplier climbs by exactly one at each step.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 2, 6, 24, 120, ___' AND options = '["480", "600", "720", "840"]'::JSONB;

UPDATE questions SET explanation = 'Each term is a counting number multiplied by itself: 0, 1, 4, 9, 16, 25 are 0 x 0 through 5 x 5. Next comes 6 x 6 = 36. Jumping to 49 uses 7 x 7 and skips a step. The gaps are 1, 3, 5, 7, 9, all odd, so the next is 11 and 25 + 11 = 36; an even gap of 10 would give 35.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  0, 1, 4, 9, 16, 25, ___' AND options = '["30", "35", "36", "49"]'::JSONB;

UPDATE questions SET explanation = 'Add the next square each time. The gaps are 4, 9, 16, 25, which are the squares of 2, 3, 4, and 5. So the next gap is 6 x 6 = 36, giving 55 + 36 = 91. If you assume the gap grows by a steady amount and add 29, you land on 84. The gaps jump by larger and larger amounts because they are squares.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 5, 14, 30, 55, ___' AND options = '["77", "84", "91", "95"]'::JSONB;

UPDATE questions SET explanation = 'Each term is twice a square: 2 x 1, 2 x 4, 2 x 9, 2 x 16, 2 x 25. The next square is 36, so the term is 2 x 36 = 72. The gaps are 6, 10, 14, 18, each 4 more than the last, so the next gap is 22. Holding the gap at 18 gives 68, and growing it by only 2 gives 70.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  2, 8, 18, 32, 50, ___' AND options = '["68", "70", "72", "74"]'::JSONB;

UPDATE questions SET explanation = 'Each term is the one before multiplied by 3, then plus 1: 1 x 3 + 1 = 4, 4 x 3 + 1 = 13, 40 x 3 + 1 = 121. So 121 x 3 + 1 = 364. Tripling alone gives 363, and rounder answers like 300 or 400 come from estimating the size of the jump instead of applying the rule.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 4, 13, 40, 121, ___' AND options = '["200", "300", "364", "400"]'::JSONB;

UPDATE questions SET explanation = 'Each term is the sum of the two before it: 6 + 10 = 16, 10 + 16 = 26, and 16 + 26 = 42. So 26 + 42 = 68. Repeating the last gap of 16 gives 58, and adding a rounder 20 gives 62. The gaps are 4, 6, 10, 16 and follow the same adding rule, so the next gap is 26.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  6, 10, 16, 26, 42, ___' AND options = '["58", "62", "68", "74"]'::JSONB;

UPDATE questions SET explanation = 'The multiplier goes up by one each step: times 3, then 4, then 5, then 6. So the next step is times 7: 360 x 7 = 2520. Multiplying by 6 again gives 2160, and multiplying by 4 gives 1440, but the multiplier has increased at every step so far, so it moves on to 7 instead of repeating an earlier one.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 3, 12, 60, 360, ___' AND options = '["720", "1440", "2160", "2520"]'::JSONB;

UPDATE questions SET explanation = 'From the third term on, each number is the sum of the two before it: 1 + 2 = 3, 3 + 5 = 8, and so on. So 21 + 34 = 55. Rounding to a tidy 50 or 60 is tempting when the numbers get large, but the gaps themselves are 1, 1, 2, 3, 5, 8, 13, and the next gap is exactly 21.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 2, 3, 5, 8, 13, 21, 34, ___' AND options = '["45", "50", "55", "60"]'::JSONB;

UPDATE questions SET explanation = 'Each term is double the one before, plus 2: 5 x 2 + 2 = 12, 12 x 2 + 2 = 26, 54 x 2 + 2 = 110. So 110 x 2 + 2 = 222. Doubling alone gives 220, which sits close enough to feel right, but that rule already breaks at the start, since 5 doubled is 10, not 12.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  5, 12, 26, 54, 110, ___' AND options = '["185", "220", "222", "230"]'::JSONB;

UPDATE questions SET explanation = 'Look at the gaps between the later terms: 4, 6, 8, 10, growing by 2 each time. The next gap is 12, so 31 + 12 = 43. Holding the gap at 10 gives 41, and stretching it to 14 gives 45. The gaps have widened by exactly 2 at every step, so the series speeds up in a steady, predictable way.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 3, 7, 13, 21, 31, ___' AND options = '["40", "41", "43", "45"]'::JSONB;

UPDATE questions SET explanation = 'Each term is the one before multiplied by 3: 1, 3, 9, 27, 81, 243. So 243 x 3 = 729. Doubling instead gives 486 and multiplying by 4 gives 972, but neither fits the earlier steps, since 1 doubled is 2, not 3. These are the powers of 3, and 729 is 3 multiplied by itself six times.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 3, 9, 27, 81, 243, ___' AND options = '["486", "729", "810", "972"]'::JSONB;

UPDATE questions SET explanation = 'Each term is a counting number times the next one up: 1 x 2, 2 x 3, 3 x 4, 4 x 5, 5 x 6, 6 x 7. Next is 7 x 8 = 56. The gaps are 4, 6, 8, 10, 12, so the next is 14 and 42 + 14 = 56. Holding the gap at 12 gives 54, and at 10 gives 52.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  2, 6, 12, 20, 30, 42, ___' AND options = '["52", "54", "56", "60"]'::JSONB;

UPDATE questions SET explanation = 'Each term is the sum of the two before it: 1 + 3 = 4, 3 + 4 = 7, 4 + 7 = 11, and 7 + 11 = 18. So 11 + 18 = 29. Repeating the last gap of 7 gives 25, and reading the gaps as steadily growing and adding 10 gives 28. The adding rule fits every term in the list.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  1, 3, 4, 7, 11, 18, ___' AND options = '["25", "28", "29", "30"]'::JSONB;

UPDATE questions SET explanation = 'Each term is a counting number multiplied by itself three times: 0, 1, 8, 27, 64, 125 are 0 x 0 x 0 up to 5 x 5 x 5. Next is 6 x 6 x 6 = 216. The answer 196 is 14 x 14, a square rather than a cube, the usual mix-up here, while the round-looking 200 is a guess at size.'
  WHERE section = 'quantitative' AND prompt = 'What number comes next?  0, 1, 8, 27, 64, 125, ___' AND options = '["196", "200", "210", "216"]'::JSONB;

UPDATE questions SET explanation = 'Work backwards, undoing each step in reverse order. The last step divided by 2, so multiply: 10 x 2 = 20. Before that 8 was subtracted, so add it back: 20 + 8 = 28. First the number was multiplied by 4, so divide: 28 / 4 = 7. Test 8 forward and you end at 12; test 6 and you end at 8.'
  WHERE section = 'quantitative' AND prompt = 'A number is multiplied by 4, then 8 is subtracted, then the result is divided by 2, giving 10. What was the original number?' AND options = '["5", "6", "7", "8"]'::JSONB;

UPDATE questions SET explanation = 'Undo the steps in reverse. The last step multiplied by 3, so divide: 21 / 3 = 7. Before that 9 was subtracted, so add it back: 7 + 9 = 16. The number had been doubled, so halve: 16 / 2 = 8. Test 7 forward and you get 14, then 5, then 15, which is not the 21 the question requires.'
  WHERE section = 'quantitative' AND prompt = 'A number is doubled, then 9 is subtracted, then the result is multiplied by 3, giving 21. What was the original number?' AND options = '["6", "7", "8", "9"]'::JSONB;

UPDATE questions SET explanation = 'Undo each step in reverse order. The last step divided by 6, so multiply: 7 x 6 = 42. Before that came a times 3, so divide: 42 / 3 = 14. First 4 was added, so subtract: 14 - 4 = 10. The answer 14 is the value partway through the undoing, not the original, and 16 tested forward ends at 10.'
  WHERE section = 'quantitative' AND prompt = 'A number is increased by 4, then multiplied by 3, then divided by 6, giving 7. What was the original number?' AND options = '["10", "12", "14", "16"]'::JSONB;

UPDATE questions SET explanation = 'Undo the steps backwards. Last, 4 was added, so subtract: 30 - 4 = 26. Before that the number was doubled, so halve: 26 / 2 = 13. First 5 was subtracted, so add it back: 13 + 5 = 18. Test 16 forward: 11, then 22, then 26, which lands short of 30, so 16 is not the starting number.'
  WHERE section = 'quantitative' AND prompt = 'A number is decreased by 5, then doubled, then increased by 4, giving 30. What was the original number?' AND options = '["16", "18", "20", "22"]'::JSONB;

UPDATE questions SET explanation = 'Undo the steps in reverse. Last, 10 was subtracted, so add: 15 + 10 = 25. Before that came a times 5, so divide: 25 / 5 = 5. First the number was divided by 4, so multiply: 5 x 4 = 20. Test 24 forward and you end at 20; test 16 and you end at 10. Neither gives the 15 required.'
  WHERE section = 'quantitative' AND prompt = 'A number is divided by 4, then multiplied by 5, then reduced by 10, giving 15. What was the original number?' AND options = '["16", "18", "20", "24"]'::JSONB;

UPDATE questions SET explanation = 'Work backwards through the steps. The last one divided by 3, so multiply: 5 x 3 = 15. Before that 7 was subtracted, so add: 15 + 7 = 22. First the number was doubled, so halve: 22 / 2 = 11. Both 13 and 10 fail a quick test: they leave 19 and 13, neither of which divides evenly by 3.'
  WHERE section = 'quantitative' AND prompt = 'A number is multiplied by 2, then 7 is subtracted, then the result is divided by 3, giving 5. What was the original number?' AND options = '["10", "11", "12", "13"]'::JSONB;

UPDATE questions SET explanation = 'Undo each step in reverse. The last step halved, so double: 15 x 2 = 30. Before that 6 was added, so subtract: 30 - 6 = 24. First the number was tripled, so divide by 3: 24 / 3 = 8. Test 9 forward and you get 27, then 33, then 16.5, which is not the whole number 15 the question states.'
  WHERE section = 'quantitative' AND prompt = 'A number is tripled, then 6 is added, then the result is halved, giving 15. What was the original number?' AND options = '["6", "7", "8", "9"]'::JSONB;

UPDATE questions SET explanation = 'Undo the steps backwards. Last, 8 was added, so subtract: 32 - 8 = 24. Before that came a times 4, so divide: 24 / 4 = 6. First the number was divided by 5, so multiply: 6 x 5 = 30. Test 25 forward and you end at 28; test 40 and you end at 40. Only 30 reaches 32.'
  WHERE section = 'quantitative' AND prompt = 'A number is divided by 5, then multiplied by 4, then 8 is added, giving 32. What was the original number?' AND options = '["25", "30", "35", "40"]'::JSONB;

UPDATE questions SET explanation = 'Undo the steps in reverse. The last step multiplied by 2, so divide: 20 / 2 = 10. Before that came a division by 3, so multiply: 10 x 3 = 30. First 10 was added, so subtract: 30 - 10 = 20. Starting and ending on 20 feels wrong but checks out. Test 18 or 24 and the division by 3 is not even whole.'
  WHERE section = 'quantitative' AND prompt = 'A number is increased by 10, then divided by 3, then multiplied by 2, giving 20. What was the original number?' AND options = '["18", "20", "22", "24"]'::JSONB;

UPDATE questions SET explanation = 'Read the steps in order: halve the number, add 6, then triple. Now undo them backwards. Divide by 3: 45 / 3 = 15. Subtract 6: 15 - 6 = 9. That 9 is half the number, so double it to get 18. Test 14 forward and you end at 39; test 20 and you end at 48. Neither hits 45.'
  WHERE section = 'quantitative' AND prompt = 'Half of a number is increased by 6, then the result is tripled, giving 45. What was the original number?' AND options = '["14", "16", "18", "20"]'::JSONB;

UPDATE questions SET explanation = 'Undo each step in reverse. The last step divided by 3, so multiply: 8 x 3 = 24. Before that 18 was subtracted, so add it back: 24 + 18 = 42. First the number was multiplied by 6, so divide: 42 / 6 = 7. Test 8 forward and you get 48, then 30, then 10, which is more than the 8 required.'
  WHERE section = 'quantitative' AND prompt = 'A number is multiplied by 6, then 18 is subtracted, then the result is divided by 3, giving 8. What was the original number?' AND options = '["5", "6", "7", "8"]'::JSONB;

UPDATE questions SET explanation = 'Undo backwards, and take care with the squaring. Last, 5 was subtracted, so add: 59 + 5 = 64. The number had been squared, so take the square root: 64 gives 8. First 3 was added, so subtract: 8 - 3 = 5. The answer 8 is that middle value, the number after 3 was added, and 6 tested forward gives 76.'
  WHERE section = 'quantitative' AND prompt = 'A number is increased by 3, then squared, then 5 is subtracted, giving 59. What was the original number?' AND options = '["5", "6", "7", "8"]'::JSONB;

UPDATE questions SET explanation = 'Powers are not symmetric, so swapping the base and the exponent changes the value. A: 3 x 3 x 3 x 3 = 81. B: 4 x 4 x 4 = 64. So A is greater. Because both expressions use a 3 and a 4, they can look equal at a glance, but the extra factor in A outweighs its smaller base. Both are exact values.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 3⁴  vs.  (B) 4³. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'A square root does not split across addition. A: the square root of 144 is 12 and the square root of 25 is 5, so A is 17. B: 144 + 25 = 169, and the square root of 169 is 13. So A is greater. Believing these are equal is the classic error, because the root of a sum is almost never the sum of the roots.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) √144 + √25  vs.  (B) √(144 + 25). Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Work each side out before comparing. A: 2 x 2 x 2 x 2 x 2 = 32, plus 3 x 3 = 9, so A is 41. B: 36 - 4 = 32. So A is greater, and the two are nowhere near equal. Reading the exponent as a multiplier and computing 2 x 5 = 10 drops A to 19 and makes B look greater.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 2⁵ + 3²  vs.  (B) 6² − 2². Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Change each percent to a decimal and multiply. A: 0.75 x 120 = 90. B: 0.80 x 110 = 88. So A is greater. B tempts because 80 is the bigger percent, but it is taken of a smaller number, so the percent alone does not decide it. The gap is only 2, yet both values are exact, so they are not equal.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 75% of 120  vs.  (B) 80% of 110. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Squaring a fraction means squaring the top and the bottom: (2/3) squared is 4/9, about 0.44. In B, 2/3 times 3/2 equals 1 because they are reciprocals, and 1 - 1/2 = 0.5. So B is greater; the two are close but not equal. Reading the square as a doubling gives 4/3 and makes A look larger, yet squaring a fraction below 1 shrinks it.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) (2/3)²  vs.  (B) 2/3 × 3/2 − 1/2. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'A factorial multiplies every whole number down to 1, so most of it cancels in a division. A: 5! / 4! leaves 5. B: 6! / 5! leaves 6, and 6 - 1 = 5. Both sides come to 5, so they are equal, and there is no need to say you cannot determine it. Expecting B to be greater because 6! is huge is the trap.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) 5! ÷ 4!  vs.  (B) 6! ÷ 5! − 1. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'A number outside a square root can move inside by squaring it, so 3 times the root of 20 equals the root of 9 x 20, which is the root of 180. Since 200 is greater than 180, A is greater, not equal. As decimals, A is about 14.1 and B about 13.4. The visible 3 in B makes it look larger, but it multiplies only about 4.47.'
  WHERE section = 'quantitative' AND prompt = 'Examine: (A) √200  vs.  (B) 3√20. Which is greater?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Circle area is pi times the radius times the radius. A: 3.14 x 5 x 5 = 78.5. B: 9 x 9 = 81. So B is greater, by about 2.5, close but not equal. Forgetting to square and computing 3.14 x 5 = 15.7, or using the circumference 2 x 3.14 x 5 = 31.4, makes A look far too small.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a circle with radius 5. Shape B: a square with side 9. Which has the greater area? (Use π ≈ 3.14)' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Circle area is pi times the radius squared: 3.14 x 16 = 50.24. Rectangle: 12 x 4 = 48. So A is greater, but by only about 2, which is why it pays to compute instead of eyeballing. Forgetting to square the radius gives 12.56 and points to B. Every measurement is given, so there is no need to say you cannot determine it.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a circle with radius 4. Shape B: a rectangle with length 12 and width 4. Which has the greater area? (Use π ≈ 3.14)' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Area of a circle is pi times radius times radius: 3.14 x 6 x 6 = 113.04. Square: 10 x 10 = 100. So A is greater, and not equal. The square looks wider at 10 across while the circle measures 12 across, and that extra width is what wins. A circle of diameter 10 would have been the smaller shape, at about 78.5.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a circle with radius 6. Shape B: a square with side 10. Which has the greater area? (Use π ≈ 3.14)' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Substitute k = 6 first. A: length 2k = 12 and width k = 6, so the area is 12 x 6 = 72. B: side 6 + 3 = 9, so the area is 9 x 9 = 81. So B is greater, not equal. Squaring before adding, treating the side as 36 + 3 = 39, is a common slip. Add inside the parentheses first, then square.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a rectangle with length 2k and width k. Shape B: a square with side k+3 (assume k = 6). Which has the greater area?' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'The diameter is 10, so the radius is 5, half of that. Circle: 3.14 x 5 x 5 = 78.5. Right triangle: the legs multiply and halve, so (13 x 12) / 2 = 78. A is greater by half a unit, close but not equal. Using 10 as the radius gives 314, and skipping the halving gives 156, which points to B.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a circle with diameter 10. Shape B: a right triangle with legs 13 and 12. Which has the greater area? (Use π ≈ 3.14)' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Circle area is pi times the radius squared: 3.14 x 49 = 153.86. Rectangle: 16 x 9 = 144. So A is greater, not equal. The radius must be squared before multiplying by 3.14; stopping at 3.14 x 7 = 21.98 makes the circle look tiny and sends you to B. Comparing the radius of 7 against sides of 16 and 9 does the same.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a circle with radius 7. Shape B: a rectangle with length 16 and width 9. Which has the greater area? (Use π ≈ 3.14)' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Circle area is pi times the radius squared: 3.14 x 4 x 4 = 50.24. Square: 7 x 7 = 49. So A is greater, by a little over one unit. The circle measures 8 across against the square''s 7, which makes this closer than it looks. Calling them equal would be a rounding guess rather than a calculation.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a circle with radius 4. Shape B: a square with side 7. Which has the greater area? (Use π ≈ 3.14)' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Circle area is pi times the radius squared: 3.14 x 3 x 3 = 28.26. Rectangle: 9 x 3 = 27. So A is greater, by about 1.3. The rectangle stretches three times as long, which makes B look like the bigger shape, but it is also thin. Both areas come out exactly, so there is no need to say you cannot determine it.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a circle with radius 3. Shape B: a rectangle with length 9 and width 3. Which has the greater area? (Use π ≈ 3.14)' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Circle area is pi times the radius squared: 3.14 x 5 x 5 = 78.5. Rectangle: 10 x 8 = 80. So B is greater, by 1.5. The circle is 10 across, matching the rectangle''s length, so the two can seem equal. The difference is that the rectangle keeps its full width of 8 everywhere, while the circle narrows toward its top and bottom.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a circle with radius 5. Shape B: a rectangle with length 10 and width 8. Which has the greater area? (Use π ≈ 3.14)' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Circle area is pi times the radius squared: 3.14 x 2 x 2 = 12.56. Rectangle: 6 x 2 = 12. So A is greater, by about half a unit, and they are not equal. The rectangle stretches 6 long against the circle''s 4 across, so B looks bigger at a glance. The circle makes that up by keeping its width all the way around.'
  WHERE section = 'quantitative' AND prompt = 'Shape A: a circle with radius 2. Shape B: a rectangle with length 6 and width 2. Which has the greater area? (Use π ≈ 3.14)' AND options = '["A is greater", "B is greater", "Equal", "Cannot determine"]'::JSONB;

UPDATE questions SET explanation = 'Each term is 3 more than the one before: 4 to 7, 7 to 10, 10 to 13. So the next is 13 + 3 = 16. Answering 15 would mean a step of 2, and 17 would mean a step of 4, but the step has been exactly 3 every time. Checking two or three gaps before you answer catches this kind of slip.'
  WHERE section = 'quantitative' AND prompt = 'Look at this series: 4, 7, 10, 13, ... What number should come next?' AND options = '["15", "16", "17", "19"]'::JSONB;

UPDATE questions SET explanation = 'The terms count up by 12, which is the same as listing the multiples of 12: 12, 24, 36, 48. The next is 12 x 5 = 60. The answer 72 skips ahead to 12 x 6, and 54 comes from adding 6 rather than 12. Confirm the step by subtracting neighbors: 24 - 12 = 12 and 48 - 36 = 12.'
  WHERE section = 'quantitative' AND prompt = 'Look at this series: 12, 24, 36, 48, ... What number should come next?' AND options = '["54", "56", "60", "72"]'::JSONB;

UPDATE questions SET explanation = 'Each term is 5 less than the one before, so the series counts down by 5. From 85, subtract 5 to reach 80. The answer 75 subtracts 5 twice and lands a step too far, while 84 subtracts only 1. Subtracting a pair of terms confirms the step: 100 - 95 = 5 and 90 - 85 = 5.'
  WHERE section = 'quantitative' AND prompt = 'Look at this series: 100, 95, 90, 85, ... What number should come next?' AND options = '["75", "80", "82", "84"]'::JSONB;

UPDATE questions SET explanation = 'The terms are the multiples of 15: 15, 30, 45, 60. The next is 15 x 5 = 75, which is also 60 + 15. The answer 90 is 15 x 6 and skips a term, while 70 comes from adding 10 instead of 15. Check by subtracting neighbors, and you find every gap in the list is exactly 15.'
  WHERE section = 'quantitative' AND prompt = 'Look at this series: 15, 30, 45, 60, ... What number should come next?' AND options = '["65", "70", "75", "90"]'::JSONB;

UPDATE questions SET explanation = 'Each term is half the one before: 64, 32, 16, 8. Half of 8 is 4. The answer 2 halves twice and lands one step too far, and 6 comes from subtracting 2, but the steps here are drops of 32, 16, and 8, which are not equal subtractions. Halving keeps working forever, so this series never reaches 0.'
  WHERE section = 'quantitative' AND prompt = 'Look at this series: 64, 32, 16, 8, ... What number should come next?' AND options = '["0", "2", "4", "6"]'::JSONB;

UPDATE questions SET explanation = 'These are the multiples of 9: 9 x 1, 9 x 2, 9 x 3, 9 x 4. The next is 9 x 5 = 45, which is also 36 + 9. The answer 54 is 9 x 6 and skips a step, while 40 comes from rounding to a familiar number instead of adding 9. Every gap in the list is exactly 9.'
  WHERE section = 'quantitative' AND prompt = 'Look at this series: 9, 18, 27, 36, ... What number should come next?' AND options = '["40", "42", "45", "54"]'::JSONB;

UPDATE questions SET explanation = 'The step alternates: add 1, then add 2, then add 1, then add 2. From 1 to 2 is a step of 1, from 2 to 4 is a step of 2, and the pattern repeats. The step before 10 was 2, so the next is 1, giving 11. A steady step of 2 gives 12 and a steady 3 gives 13, but neither would have produced 5 and 8.'
  WHERE section = 'quantitative' AND prompt = 'Look at this series: 1, 2, 4, 5, 7, 8, 10, ... What number should come next?' AND options = '["11", "12", "13", "14"]'::JSONB;

UPDATE questions SET explanation = 'The gaps grow by one each time: 1, 2, 3, 4, 5. The next gap is 6, so 18 + 6 = 24. Holding the gap at 5 gives 23, and jumping it to 8 gives 26. The gaps have increased by exactly one at every step, so the series widens steadily. Check the gaps first whenever a series climbs unevenly.'
  WHERE section = 'quantitative' AND prompt = 'Look at this series: 3, 4, 6, 9, 13, 18, ... What number should come next?' AND options = '["22", "23", "24", "26"]'::JSONB;

UPDATE questions SET explanation = 'Each term is half the one before: 96, 48, 24, 12. Half of 12 is 6. The answer 4 comes from dividing by 3 and 8 from subtracting 4, but neither fits the earlier terms, since 96 divided by 3 is 32, not 48, and 96 - 4 is 92. Halving is the one rule that works on every pair in the list.'
  WHERE section = 'quantitative' AND prompt = 'Look at this series: 96, 48, 24, 12, ... What number should come next?' AND options = '["4", "6", "8", "10"]'::JSONB;

UPDATE questions SET explanation = 'Each term is double the one before, plus 1: 5 x 2 + 1 = 11, 11 x 2 + 1 = 23, and 23 x 2 + 1 = 47. So 47 x 2 + 1 = 95. Doubling alone gives 94, and doubling then adding 2 gives 96. Test those on the first pair: 5 doubled is 10, and only adding 1 reaches the 11 that follows.'
  WHERE section = 'quantitative' AND prompt = 'Look at this series: 5, 11, 23, 47, ... What number should come next?' AND options = '["94", "95", "96", "99"]'::JSONB;

UPDATE questions SET explanation = 'Each term is double the one before, minus 1: 6 x 2 - 1 = 11, 11 x 2 - 1 = 21, and 21 x 2 - 1 = 41. So 41 x 2 - 1 = 81. Plain doubling gives 82, and doubling then subtracting 2 gives 80. Only subtracting 1 fits the earlier steps, since 6 doubled is 12 and 12 - 1 = 11.'
  WHERE section = 'quantitative' AND prompt = 'Look at this series: 6, 11, 21, 41, ... What number should come next?' AND options = '["61", "80", "81", "82"]'::JSONB;

UPDATE questions SET explanation = 'The amount subtracted grows each time: 1, then 2, then 3, then 4. The next subtraction is 5, so 10 - 5 = 5. Answering 6 keeps the step at 4, and answering 4 jumps the step to 6. Since the steps have grown by exactly one each time, the next one is 5, and 5 is what remains.'
  WHERE section = 'quantitative' AND prompt = 'Look at this series: 20, 19, 17, 14, 10, ... What number should come next?' AND options = '["3", "4", "5", "6"]'::JSONB;

UPDATE questions SET explanation = 'The gaps are the square numbers: 1, 4, 9, 16, which are 1 x 1, 2 x 2, 3 x 3, and 4 x 4. The next gap is 5 x 5 = 25, so 31 + 25 = 56. Doubling 31 gives 62, which looks plausible because the terms roughly double each time, but the gaps here are exact squares and the next one is 25.'
  WHERE section = 'quantitative' AND prompt = 'Look at this series: 1, 2, 6, 15, 31, ... What number should come next?' AND options = '["46", "52", "56", "62"]'::JSONB;

UPDATE questions SET explanation = 'Each term is double the one before, plus 2: 2 x 2 + 2 = 6, 6 x 2 + 2 = 14, 14 x 2 + 2 = 30, and 30 x 2 + 2 = 62. So 62 x 2 + 2 = 126. Plain doubling gives 124, a very close miss. Check that rule at the start, where 2 doubled is 4, not the 6 that follows.'
  WHERE section = 'quantitative' AND prompt = 'Look at this series: 2, 6, 14, 30, 62, ... What number should come next?' AND options = '["94", "118", "124", "126"]'::JSONB;

UPDATE questions SET explanation = 'Each term is one less than a square: take 4, 9, 16, 25, 36 and subtract 1 from each. The next square is 49, so the term is 48. Adding 1 to that square instead of subtracting gives 50. The gaps agree: they run 5, 7, 9, 11, so the next is 13, and holding the gap at 11 gives 46.'
  WHERE section = 'quantitative' AND prompt = 'Look at this series: 3, 8, 15, 24, 35, ... What number should come next?' AND options = '["44", "46", "48", "50"]'::JSONB;

UPDATE questions SET explanation = 'The steps alternate: halve, then multiply by 1.5. From 128, halving gives 64; 64 x 1.5 = 96; halving gives 48; 48 x 1.5 = 72; halving gives 36. The last step was a halving, so the next one multiplies: 36 x 1.5 = 54. Halving again would give 18, which is the trap if you miss the alternation.'
  WHERE section = 'quantitative' AND prompt = 'Look at this series: 128, 64, 96, 48, 72, 36, ... What number should come next?' AND options = '["18", "48", "54", "72"]'::JSONB;

UPDATE questions SET explanation = 'Two series are woven together here. The terms in the odd slots count 1, 2, 3, 4, and the terms in the even slots are 4, 8, 12, the multiples of 4. The next slot is an even one, so it takes 16, the next multiple of 4. Answering 5 continues the counting series one turn too early, and 20 skips ahead a multiple.'
  WHERE section = 'quantitative' AND prompt = 'Look at this series: 1, 4, 2, 8, 3, 12, 4, ... What number should come next?' AND options = '["5", "13", "16", "20"]'::JSONB;

UPDATE questions SET explanation = 'Each term is the product of the two before it: 2 x 3 = 6, 3 x 6 = 18, and 6 x 18 = 108. So 18 x 108 = 1944. Multiplying 108 by 2 gives 216, and by 6 gives 648, but both use only one earlier term. This rule needs both neighbors, and the numbers grow fast once they do.'
  WHERE section = 'quantitative' AND prompt = 'Look at this series: 2, 3, 6, 18, 108, ... What number should come next?' AND options = '["216", "648", "1296", "1944"]'::JSONB;

UPDATE questions SET explanation = 'Work out both measures before choosing. A: area 5 x 5 = 25 and perimeter 4 x 5 = 20. B: area 4 x 6 = 24 and perimeter 2 x (4 + 6) = 20. The perimeters tie exactly, so any claim that one figure has the greater perimeter fails. On area, 25 beats 24: for a fixed perimeter, the square holds the most.'
  WHERE section = 'quantitative' AND prompt = 'Examine the figures described and find the best answer. Figure A is a square with side 5. Figure B is a rectangle 4 by 6.' AND options = '["Figure A has the greater area.", "Figure B has the greater perimeter.", "Figure A has the greater perimeter.", "Figure B has the greater area."]'::JSONB;

UPDATE questions SET explanation = 'Triangle area is base times height divided by two: (10 x 6) / 2 = 30. Rectangle: 5 x 6 = 30. So the two areas are equal. Skipping the halving step gives 60 for the triangle and makes it look like twice the rectangle, which is exactly the wrong answer waiting here. Halving is what brings 60 down to 30.'
  WHERE section = 'quantitative' AND prompt = 'Examine the figures described and find the best answer. Figure A is a triangle with base 10 and height 6. Figure B is a rectangle 5 by 6.' AND options = '["Figure A has the greater area.", "The two areas are equal.", "Figure B has the greater area.", "The area of A is twice the area of B."]'::JSONB;

UPDATE questions SET explanation = 'Watch the wording: A gives a radius, B gives a diameter. B''s radius is 8 / 2 = 4. The areas are pi x 3 x 3 = 9 pi and pi x 4 x 4 = 16 pi, so B has the greater area. Comparing 3 against 8 directly, or treating 8 as a radius, exaggerates the difference; the honest ratio is 16 to 9.'
  WHERE section = 'quantitative' AND prompt = 'Examine the figures described and find the best answer. Figure A is a circle with radius 3. Figure B is a circle with diameter 8.' AND options = '["Figure A has the greater area.", "The areas are equal.", "Figure B has the greater area.", "The area of A is twice the area of B."]'::JSONB;

UPDATE questions SET explanation = 'First find A''s side: perimeter 24 divided by 4 gives 6, so A''s area is 6 x 6 = 36. B: perimeter 2 x (4 + 8) = 24, the same, and area 4 x 8 = 32. So the perimeters are equal but A has the greater area. Equal perimeters do not mean equal areas: the closer a rectangle is to a square, the more it holds.'
  WHERE section = 'quantitative' AND prompt = 'Examine the figures described and find the best answer. Figure A is a square with perimeter 24. Figure B is a rectangle 4 by 8.' AND options = '["A and B have equal perimeters, but B has the greater area.", "A and B have equal perimeters and equal areas.", "A has the greater perimeter.", "A and B have equal perimeters, but A has the greater area."]'::JSONB;

UPDATE questions SET explanation = 'Find the missing side using the 3-4-5 right triangle: the hypotenuse is 5. So A has perimeter 3 + 4 + 5 = 12 and area (3 x 4) / 2 = 6. The square has perimeter 4 x 3 = 12 and area 3 x 3 = 9. The perimeters are equal, and B has the greater area. Leaving out the hypotenuse makes A''s perimeter look like 7.'
  WHERE section = 'quantitative' AND prompt = 'Examine the figures described and find the best answer. Figure A is a right triangle with legs 3 and 4. Figure B is a square with side 3.' AND options = '["The perimeters are equal, and B has the greater area.", "Figure B has the greater perimeter.", "Figure A has the greater perimeter.", "The perimeters are equal, and A has the greater area."]'::JSONB;

UPDATE questions SET explanation = 'Complementary angles add to 90 and supplementary angles add to 180. So angle B is 90 - 55 = 35, and angle C is 180 - 145 = 35. Angle B equals angle C. Both are smaller than angle A, which is 45, so angle C is not the greater one and the three are not all equal. Swapping the rules gives 125 for angle B, and nothing lines up.'
  WHERE section = 'quantitative' AND prompt = 'Examine (A), (B), and (C) and find the best answer. Angle A measures 45 degrees. Angle B is the complement of a 55-degree angle. Angle C is the supplement of a 145-degree angle.' AND options = '["Angle A equals angle B.", "Angle B equals angle C.", "Angle C is greater than angle A.", "All three angles are equal."]'::JSONB;

UPDATE questions SET explanation = 'The circle''s diameter is 6, so its radius is 3, half of that. Square: 6 x 6 = 36. Circle: 3.14 x 3 x 3 = 28.26. So figure A has the greater area. Using 6 as the radius gives about 113 and makes B look more than twice A, which is the trap here. A circle that fits inside a square always covers less than the square.'
  WHERE section = 'quantitative' AND prompt = 'Examine the figures described and find the best answer. Figure A is a square with side 6. Figure B is a circle with diameter 6. Use pi = 3.14.' AND options = '["The areas are equal.", "The area of B is more than twice the area of A.", "Figure A has the greater area.", "Figure B has the greater area."]'::JSONB;

UPDATE questions SET explanation = 'Find the shaded part by subtracting. The big square is 8 x 8 = 64 and the cut-out corner is 4 x 4 = 16, leaving 64 - 16 = 48. Rectangle B is 6 x 8 = 48, so the shaded part equals B. Cutting away half the side length does not cut away half the area: the corner removes only 16 of the 64.'
  WHERE section = 'quantitative' AND prompt = 'Examine the figures described and find the best answer. Figure A is a square of side 8 with a square of side 4 cut away from one corner; the part that remains is shaded. Figure B is a rectangle 6 by 8.' AND options = '["The shaded part of A is three-fourths of B.", "The shaded part of A is larger than B.", "B is larger than the shaded part of A.", "The shaded part of A equals B."]'::JSONB;

UPDATE questions SET explanation = 'Areas first: 12 x 3 = 36 and 9 x 4 = 36, so the areas are equal. Perimeters: 2 x (12 + 3) = 30 and 2 x (9 + 4) = 26, so A has the greater perimeter. Equal areas do not force equal perimeters. The longer, thinner rectangle needs more edge to fence in the same 36 square units.'
  WHERE section = 'quantitative' AND prompt = 'Examine the figures described and find the best answer. Figure A is a rectangle 12 by 3. Figure B is a rectangle 9 by 4.' AND options = '["The areas are equal, but A has the greater perimeter.", "The areas are equal, but B has the greater perimeter.", "Figure A has the greater area.", "The areas are equal and the perimeters are equal."]'::JSONB;

UPDATE questions SET explanation = 'Volume is length times width times height. A: 2 x 3 x 4 = 24. B: 3 x 3 x 3 = 27. So figure B has the greater volume. A looks bigger because it owns the longest single edge, 4, but its short edge of 2 costs more than that gains. The volumes are not equal, and A is nowhere near twice B.'
  WHERE section = 'quantitative' AND prompt = 'Examine the figures described and find the best answer. Figure A is a rectangular box 2 by 3 by 4. Figure B is a cube with edge 3.' AND options = '["Figure A has the greater volume.", "Figure B has the greater volume.", "The volumes are equal.", "The volume of A is twice the volume of B."]'::JSONB;

UPDATE questions SET explanation = 'A: perimeter 5 + 5 + 6 = 16, and area from the base 6 and the height 4, so (6 x 4) / 2 = 12. Square B: perimeter 4 x 4 = 16 and area 4 x 4 = 16. So the perimeters are equal and B has the greater area. Using a slanted side of 5 as the height would give 15, still short of the square.'
  WHERE section = 'quantitative' AND prompt = 'Examine the figures described and find the best answer. Figure A is a triangle with sides 5, 5, and 6, and a height of 4 drawn to the side of length 6. Figure B is a square with side 4.' AND options = '["Figure A has the greater perimeter.", "The perimeters are equal, and A has the greater area.", "The perimeters are equal, and B has the greater area.", "Figure B has the greater perimeter."]'::JSONB;

UPDATE questions SET explanation = 'Circumference is 2 times pi times the radius, so doubling the radius doubles it: 10 pi becomes 20 pi. Area is pi times the radius squared, so doubling the radius multiplies the area by 2 x 2 = 4: 25 pi becomes 100 pi. B''s circumference is twice A''s and its area is four times A''s. The area does not merely double, because the radius gets squared.'
  WHERE section = 'quantitative' AND prompt = 'Examine the figures described and find the best answer. Figure A is a circle with radius 5. Figure B is a circle with radius 10.' AND options = '["B''s circumference is four times A''s, and B''s area is twice A''s.", "B''s circumference and area are both four times A''s.", "B''s circumference is twice A''s, and B''s area is twice A''s.", "B''s circumference is twice A''s, and B''s area is four times A''s."]'::JSONB;

UPDATE questions SET explanation = 'Take the quarter circle out of the square. Square: 4 x 4 = 16. A full circle of radius 4 is 3.14 x 16 = 50.24, and a quarter of that is 12.56. Shaded: 16 - 12.56 = 3.44, which falls between 3 and 4. Using a radius of 2 instead of 4 gives a quarter circle of 3.14 and an answer between 12 and 13.'
  WHERE section = 'quantitative' AND prompt = 'Examine the figures described and find the best answer. A square with side 4 has a quarter circle of radius 4 removed from one corner. The part of the square that remains is shaded. Use pi = 3.14.' AND options = '["The shaded area is between 3 and 4.", "The shaded area is between 4 and 5.", "The shaded area is between 8 and 9.", "The shaded area is between 12 and 13."]'::JSONB;

UPDATE questions SET explanation = 'Compare one measure at a time. The triangle has perimeter 3 x 6 = 18 and the square 4 x 5 = 20, so B has the greater perimeter. For area, the triangle''s height is about 5.2, giving (6 x 5.2) / 2, roughly 15.6, against 5 x 5 = 25, so B has the greater area as well. The triangle''s longer sides make people expect otherwise.'
  WHERE section = 'quantitative' AND prompt = 'Examine the figures described and find the best answer. Figure A is an equilateral triangle with side 6. Figure B is a square with side 5.' AND options = '["A has the greater perimeter and the greater area.", "A has the greater perimeter, but B has the greater area.", "B has the greater perimeter, but A has the greater area.", "B has the greater perimeter and the greater area."]'::JSONB;

UPDATE questions SET explanation = 'Use the Pythagorean rule for the diagonal: 8 x 8 + 6 x 6 = 64 + 36 = 100, and the square root of 100 is 10. The perimeter is 2 x (8 + 6) = 28, so one fourth of it is 7. Since 10 is more than 7, the diagonal is greater. Half the perimeter would be 14, so the diagonal does not equal that either.'
  WHERE section = 'quantitative' AND prompt = 'Examine the figures described and find the best answer. Figure A is a rectangle 8 by 6. Compare its diagonal with one fourth of its perimeter.' AND options = '["The diagonal is less than one fourth of the perimeter.", "The diagonal equals one fourth of the perimeter.", "The diagonal is greater than one fourth of the perimeter.", "The diagonal equals half of the perimeter."]'::JSONB;

UPDATE questions SET explanation = 'Trapezoid area is the average of the two parallel sides times the height: (6 + 10) / 2 = 8, then 8 x 4 = 32. Parallelogram area is base times height: 8 x 4 = 32. So the areas are equal, because the trapezoid''s average width is also 8. Skipping the averaging and using the longer side of 10 makes A look greater than it is.'
  WHERE section = 'quantitative' AND prompt = 'Examine the figures described and find the best answer. Figure A is a trapezoid with parallel sides 6 and 10 and height 4. Figure B is a parallelogram with base 8 and height 4.' AND options = '["Figure A has the greater area.", "Figure B has the greater area.", "The area of A is twice the area of B.", "The areas are equal."]'::JSONB;

UPDATE questions SET explanation = 'Each small square is 3 x 3 = 9, so the two shaded ones total 18. That is half of the big square, which is 6 x 6 = 36. Rectangle B is 3 x 6 = 18, so the shaded region equals B. Two pieces out of four sounds like it should beat a single rectangle, but B is exactly half the big square as well.'
  WHERE section = 'quantitative' AND prompt = 'Examine the figures described and find the best answer. A square 6 by 6 is divided into four equal squares of side 3. The two small squares that meet only at the center corner are shaded. Figure B is a rectangle 3 by 6.' AND options = '["The shaded region equals B.", "B is larger than the shaded region.", "The shaded region is twice B.", "The shaded region is larger than B."]'::JSONB;

UPDATE questions SET explanation = 'Volumes: 4 x 4 x 4 = 64 and 2 x 4 x 8 = 64, so they are equal. Surface areas: the cube has 6 faces of 16, giving 96, while the box has face pairs of 8, 32, and 16, giving 2 x (8 + 32 + 16) = 112. So B has the greater surface area. For a fixed volume the cube is most compact.'
  WHERE section = 'quantitative' AND prompt = 'Examine the figures described and find the best answer. Figure A is a cube with edge 4. Figure B is a rectangular box 2 by 4 by 8.' AND options = '["The volumes and the surface areas are equal.", "The volumes are equal, but B has the greater surface area.", "Figure A has the greater volume.", "The volumes are equal, but A has the greater surface area."]'::JSONB;

UPDATE questions SET explanation = 'These are three ways of writing the same amount. Divide 1 by 2 to get 0.5, and a percent means out of a hundred, so 50% is 50/100, which is also 0.5. All three are equal. A percent sign can make a number look larger than a plain fraction, but 50% is not greater than 1/2, and 0.5 is not greater than 50%.'
  WHERE section = 'quantitative' AND prompt = 'Examine (a), (b), and (c) and find the best answer. (a) 1/2   (b) 0.5   (c) 50%' AND options = '["(a) is greater than (b).", "(c) is greater than (a).", "(a), (b), and (c) are all equal.", "(b) is greater than (c)."]'::JSONB;

UPDATE questions SET explanation = 'Turn everything into decimals. 3 divided by 5 is 0.6, so (a) equals (b). And 65% means 0.65, which is more than 0.6. So (a) equals (b), and both are less than (c). It is tempting to rank the fraction highest because a fraction feels weightier than a percent, but 0.60 is less than 0.65.'
  WHERE section = 'quantitative' AND prompt = 'Examine (a), (b), and (c) and find the best answer. (a) 3/5   (b) 0.6   (c) 65%' AND options = '["(a) equals (b), and both are greater than (c).", "(a) is greater than (b).", "(c) is less than (b).", "(a) equals (b), and both are less than (c)."]'::JSONB;

UPDATE questions SET explanation = 'Do multiplication before addition unless parentheses tell you otherwise. Then (a) is 2 + 12 = 14, (b) is 5 x 4 = 20, and (c) is 6 + 4 = 10. So (b) is the greatest. Working (a) from left to right gives 20 too and makes (a) and (b) look equal, but the parentheses in (b) are what earn that 20.'
  WHERE section = 'quantitative' AND prompt = 'Examine (a), (b), and (c) and find the best answer. (a) 2 + 3 x 4   (b) (2 + 3) x 4   (c) 2 x 3 + 4' AND options = '["(b) is the greatest.", "(c) is the greatest.", "(a) and (c) are equal.", "(a) is the greatest."]'::JSONB;

UPDATE questions SET explanation = 'Write all three as decimals: 1/4 = 0.25, (b) = 0.30, and 20% = 0.20. In order, 0.30 is greater than 0.25, which is greater than 0.20. So (b) is greater than (a), and (a) is greater than (c). It is easy to rank 1/4 first because a quarter sounds large, but 0.25 is less than 0.30.'
  WHERE section = 'quantitative' AND prompt = 'Examine (a), (b), and (c) and find the best answer. (a) 1/4   (b) 0.3   (c) 20%' AND options = '["(a) is greater than (b).", "(b) is greater than (a), and (a) is greater than (c).", "(c) is greater than (a).", "(a), (b), and (c) are all equal."]'::JSONB;

UPDATE questions SET explanation = 'Compute each one. 10% of 50 is 5. 50% of 10 is 5. And 25% of 20 is 5. All three are equal. Swapping the percent and the number does not change the result, which is why (a) and (b) match; and 25% of 20 happens to land on 5 as well, so none of them is greater than another.'
  WHERE section = 'quantitative' AND prompt = 'Examine (a), (b), and (c) and find the best answer. (a) 10% of 50   (b) 50% of 10   (c) 25% of 20' AND options = '["(b) is greater than (c).", "(c) is less than (a).", "(a), (b), and (c) are all equal.", "(a) is greater than (b)."]'::JSONB;

UPDATE questions SET explanation = 'Squared means a number multiplied by itself; cubed means used three times. So (a) is 3 x 3 = 9, (b) is 2 x 2 x 2 = 8, and (c) is 4 x 4 = 16, then 16 / 2 = 8. That makes (a) greater than both (b) and (c), while (b) equals (c). Reading 2 cubed as 2 x 3 = 6 would break the comparison.'
  WHERE section = 'quantitative' AND prompt = 'Examine (a), (b), and (c) and find the best answer. (a) 3 squared   (b) 2 cubed   (c) 4 squared divided by 2' AND options = '["(b) is greater than (a).", "(c) is greater than (a).", "(a), (b), and (c) are all equal.", "(a) is greater than both (b) and (c), and (b) equals (c)."]'::JSONB;

UPDATE questions SET explanation = 'Convert everything to decimals: 5 divided by 8 is 0.625, (b) is 0.600, and 63% is 0.630. In order, 0.630 is greatest, then 0.625, then 0.600. So (c) is greater than (a), and (a) is greater than (b). The close pair is (a) and (c), and comparing only the first decimal place hides that difference.'
  WHERE section = 'quantitative' AND prompt = 'Examine (a), (b), and (c) and find the best answer. (a) 5/8   (b) 0.6   (c) 63%' AND options = '["(c) is greater than (a), and (a) is greater than (b).", "(b) is greater than (a), and (a) is greater than (c).", "(a) equals (c).", "(a) is greater than (c), and (c) is greater than (b)."]'::JSONB;

UPDATE questions SET explanation = 'To compare fractions with different denominators, divide the top by the bottom. Then 2/3 is 0.667, 5/7 is 0.714, and 7/10 is 0.700. So (b) is the greatest. The tidy-looking 7/10 tempts because tenths feel familiar, but 5/7 is a slightly larger share. And (a) equals neither of the others: 0.667 is not 0.700.'
  WHERE section = 'quantitative' AND prompt = 'Examine (a), (b), and (c) and find the best answer. (a) 2/3   (b) 5/7   (c) 7/10' AND options = '["(c) is the greatest.", "(b) is the greatest.", "(a) equals (c).", "(a) is the greatest."]'::JSONB;

UPDATE questions SET explanation = 'Work each one out. 0.25 x 80 = 20. Dividing by 4 is the same as taking a quarter, so 80 / 4 = 20 as well. And 1/5 of 80 = 16. So (a) equals (b), and both are greater than (c). One fifth sounds close to one fourth, but a fifth cuts the number into more pieces, so each piece is smaller.'
  WHERE section = 'quantitative' AND prompt = 'Examine (a), (b), and (c) and find the best answer. (a) 0.25 x 80   (b) 80 divided by 4   (c) 1/5 of 80' AND options = '["All three are equal.", "(c) is the greatest.", "(a) equals (b), and both are greater than (c).", "(a) equals (c), and both are less than (b)."]'::JSONB;

UPDATE questions SET explanation = '3/4 of 60 is 45. Decreasing 60 by 25% means keeping 75%, which is the same as 3/4, so that is 60 - 15 = 45 too. And 0.7 x 60 = 42. So (a) equals (b), and both are greater than (c). The wording of (b) tempts you to subtract a flat 25 and get 35; a percent must be taken of the number first.'
  WHERE section = 'quantitative' AND prompt = 'Examine (a), (b), and (c) and find the best answer. (a) 3/4 of 60   (b) 60 decreased by 25%   (c) 0.7 x 60' AND options = '["All three are equal.", "(a) is greater than (b).", "(c) is the greatest.", "(a) equals (b), and both are greater than (c)."]'::JSONB;

UPDATE questions SET explanation = 'A square root asks what number times itself gives the total. So (a) is 8, because 8 x 8 = 64. And (b) is 2 x 2 x 2 = 8. And (c) is 9, because 9 x 9 = 81. That makes (a) equal to (b), with (c) greater than both. Reading 2 cubed as 2 x 3 = 6 would wrongly make (a) greater than (b).'
  WHERE section = 'quantitative' AND prompt = 'Examine (a), (b), and (c) and find the best answer. (a) the square root of 64   (b) 2 cubed   (c) the square root of 81' AND options = '["(a) equals (b), and (c) is greater than both.", "(a) is greater than (c).", "(b) is the greatest.", "All three are equal."]'::JSONB;

UPDATE questions SET explanation = 'Change each percent to a decimal and multiply. 0.15 x 200 = 30. 0.20 x 150 = 30. 0.30 x 90 = 27. So (a) equals (b), and both are greater than (c). The largest percent does not win here, because 30% is taken of the smallest number. The percent and the amount it acts on always matter together.'
  WHERE section = 'quantitative' AND prompt = 'Examine (a), (b), and (c) and find the best answer. (a) 15% of 200   (b) 20% of 150   (c) 30% of 90' AND options = '["(a) is greater than (b).", "(a) equals (b), and both are greater than (c).", "(b) is less than (c).", "(c) is the greatest."]'::JSONB;

UPDATE questions SET explanation = 'Squaring 0.5 means 0.5 x 0.5 = 0.25. A square root asks what number times itself gives 0.25, and that is 0.5. And 1/2 is 0.5. So (b) equals (c), and both are greater than (a). Squaring a number between 0 and 1 makes it smaller, which is why (a) is not the greatest even though squaring usually grows things.'
  WHERE section = 'quantitative' AND prompt = 'Examine (a), (b), and (c) and find the best answer. (a) 0.5 squared   (b) the square root of 0.25   (c) 1/2' AND options = '["All three are equal.", "(a) is the greatest.", "(b) equals (c), and both are greater than (a).", "(a) equals (b)."]'::JSONB;

UPDATE questions SET explanation = 'Compute each one. 0.3 x 0.3 = 0.09. 0.3 + 0.3 = 0.6. And 0.3 divided by 0.3 is 1, since any number divided by itself gives 1. So (c) is greater than (b), and (b) is greater than (a). Multiplying by a decimal below 1 shrinks a number, so (a) is far from the greatest and equals nothing else here.'
  WHERE section = 'quantitative' AND prompt = 'Examine (a), (b), and (c) and find the best answer. (a) 0.3 x 0.3   (b) 0.3 + 0.3   (c) 0.3 divided by 0.3' AND options = '["(a) equals (c).", "(a) is the greatest.", "(b) is the greatest.", "(c) is greater than (b), and (b) is greater than (a)."]'::JSONB;

UPDATE questions SET explanation = 'Each operation behaves differently. For (a) use a common denominator: 3/6 + 2/6 = 5/6. For (b) multiply straight across: 1/6. For (c) divide by flipping the second fraction: 1/2 x 3/1 = 3/2. So (c) is greater than (a), and (a) is greater than (b). Note that (a) equals nothing here and is not the greatest; dividing by a fraction below 1 makes the result larger.'
  WHERE section = 'quantitative' AND prompt = 'Examine (a), (b), and (c) and find the best answer. (a) 1/2 + 1/3   (b) 1/2 x 1/3   (c) 1/2 divided by 1/3' AND options = '["(c) is greater than (a), and (a) is greater than (b).", "(a) equals (c).", "(a) is the greatest.", "(b) is the greatest."]'::JSONB;

UPDATE questions SET explanation = 'Convert to decimals and line the digits up. 7 divided by 12 is 0.5833, (b) is 0.580, and 57.5% is 0.575. So (a) is greater than (b), and (b) is greater than (c). All three start with 0.5, so the decision happens in the later places; rounding the fraction to 0.58 makes (a) and (b) look equal when they are not.'
  WHERE section = 'quantitative' AND prompt = 'Examine (a), (b), and (c) and find the best answer. (a) 7/12   (b) 0.58   (c) 57.5%' AND options = '["(c) is greater than (a).", "(a) is greater than (b), and (b) is greater than (c).", "(b) is the greatest.", "(a) equals (b)."]'::JSONB;

UPDATE questions SET explanation = 'An average is the total divided by how many numbers there are. So (a) is 14 / 2 = 7, (b) is 21 / 3 = 7, and (c) is 32 / 4 = 8. That makes (a) equal to (b), with (c) greater than both. Having more numbers in a list does not make an average bigger by itself; here the values in (c) are spread higher.'
  WHERE section = 'quantitative' AND prompt = 'Examine (a), (b), and (c) and find the best answer. (a) the average of 4 and 10   (b) the average of 5, 7, and 9   (c) the average of 2, 6, 10, and 14' AND options = '["All three are equal.", "(a) is greater than (b).", "(a) equals (b), and (c) is greater than both.", "(c) is the smallest."]'::JSONB;

UPDATE questions SET explanation = 'Take them one at a time. 2/5 of 45 is 18. Decreasing 45 by 60% leaves 40% of it, so 45 - 27 = 18. And 45 divided by 2.5 is 18. All three are equal, so none is the greatest, none is the smallest, and none is greater than another. Dividing by 2.5 feels like it should leave more, yet each route lands on the same 18.'
  WHERE section = 'quantitative' AND prompt = 'Examine (a), (b), and (c) and find the best answer. (a) 2/5 of 45   (b) 45 decreased by 60%   (c) 45 divided by 2.5' AND options = '["(c) is greater than (a).", "(a) is the greatest.", "(b) is the smallest.", "(a), (b), and (c) are all equal."]'::JSONB;

UPDATE questions SET explanation = 'Read the sentence from the inside out: first take one third of 27, then add 4. One third of 27 is 9, and 9 + 4 = 13. Stopping after the fraction leaves 9, which is the most common miss here. Adding 4 to 27 first and then dividing would give about 10.3. The phrase more than means the adding happens last.'
  WHERE section = 'quantitative' AND prompt = 'What number is 4 more than 1/3 of 27?' AND options = '["9", "12", "13", "15"]'::JSONB;

UPDATE questions SET explanation = 'Rebuild the sentence as arithmetic in order. Twice 10 is 20, and 6 less than 20 is 20 - 6 = 14. Adding by mistake gives 26, and adding 6 to 10 gives 16, while subtracting before doubling, 2 x (10 - 6), gives 8. The words less than mean take away from the amount described right before them, and that amount is 20.'
  WHERE section = 'quantitative' AND prompt = 'What number is 6 less than twice 10?' AND options = '["4", "14", "16", "26"]'::JSONB;

UPDATE questions SET explanation = 'Work from the inner phrase outward: 3/4 of 40 is 30, and half of 30 is 15. Stopping after the first step leaves 30, and halving 40 by itself gives 20. Either way, taking half first and then three fourths would still reach 15, because the order in which you multiply does not change the result.'
  WHERE section = 'quantitative' AND prompt = 'What number is 1/2 of 3/4 of 40?' AND options = '["10", "15", "20", "30"]'::JSONB;

UPDATE questions SET explanation = 'Take the percent first, then add. A percent means out of a hundred, so 20% is 20/100, or one fifth, and one fifth of 50 is 10. Then 10 + 5 = 15. Stopping after the percent step leaves 10, the most common miss, and mistaking 20% for half of 50 pushes you toward 25. The words more than put the addition last.'
  WHERE section = 'quantitative' AND prompt = 'What number is 5 more than 20% of 50?' AND options = '["10", "12", "15", "25"]'::JSONB;

UPDATE questions SET explanation = 'The word sum tells you to add before multiplying: 4 + 5 = 9, and then 3 x 9 = 27. Multiplying first and adding afterward gives 3 x 4 + 5 = 17, and multiplying by 4 alone gives 12; both are traps here. Picture the sum inside parentheses, 3 x (4 + 5), so the addition clearly happens first.'
  WHERE section = 'quantitative' AND prompt = 'What number is 3 times the sum of 4 and 5?' AND options = '["12", "17", "20", "27"]'::JSONB;

UPDATE questions SET explanation = 'Go in the order written. First one fourth of 60, which is 15, then decrease that by 5: 15 - 5 = 10. Stopping after the fraction leaves 15, the most common miss, and adding 5 instead of subtracting gives 20. The phrase decreased by acts on the quantity named right before it, which is the 15, not the 60.'
  WHERE section = 'quantitative' AND prompt = 'What number is 1/4 of 60 decreased by 5?' AND options = '["10", "11", "15", "20"]'::JSONB;

UPDATE questions SET explanation = 'The square of 5 means 5 x 5 = 25, and 8 less than that is 25 - 8 = 17. Adding instead of subtracting gives 33, and reading the square of 5 as 5 x 2 = 10 would leave 2. The words less than tell you to take 8 away from the finished square, so square first and subtract second.'
  WHERE section = 'quantitative' AND prompt = 'What number is 8 less than the square of 5?' AND options = '["12", "15", "17", "33"]'::JSONB;

UPDATE questions SET explanation = 'Name the unknown x. One fifth of x is 12 means x / 5 = 12, so undo the division by multiplying: x = 12 x 5 = 60. Multiplying by 6 instead gives 72, and the answer 17 comes from adding 5, which does not match the wording. When a fraction of an unknown is given, multiply to recover the whole.'
  WHERE section = 'quantitative' AND prompt = 'One fifth of what number is 12?' AND options = '["17", "36", "60", "72"]'::JSONB;

UPDATE questions SET explanation = 'Half of 18 is 9, and the question asks what must be added to 9 to reach 30, so 30 - 9 = 21. The answer 9 is the half itself rather than the amount added, and 39 comes from adding 9 to 30 instead of subtracting. Check it forward: 9 + 21 = 30, exactly as required.'
  WHERE section = 'quantitative' AND prompt = 'What number must be added to 1/2 of 18 to give 30?' AND options = '["9", "12", "21", "39"]'::JSONB;

UPDATE questions SET explanation = 'Work from the inside out. 3/5 of 100 is 60, and 25% of 60 is a fourth of 60, which is 15. Taking 25% of 100 first leaves 25, and stopping there is the common miss; continuing gives 3/5 of 25, which is also 15. The order in which you multiply does not matter, but stopping halfway does.'
  WHERE section = 'quantitative' AND prompt = 'What number is 25% of 3/5 of 100?' AND options = '["12", "15", "20", "25"]'::JSONB;

UPDATE questions SET explanation = 'Translate each half of the sentence. Three more than 45 is 48. The product of 6 and the unknown means 6 times it, so 6 times the number is 48 and the number is 48 / 6 = 8. Reading it as 3 less than 45 gives 42 and points to 7, and dividing 48 by 4 instead of 6 gives 12. Check: 6 x 8 = 48.'
  WHERE section = 'quantitative' AND prompt = 'The product of 6 and what number is 3 more than 45?' AND options = '["7", "8", "9", "12"]'::JSONB;

UPDATE questions SET explanation = 'Handle each piece before subtracting. 2/3 of 90 is 60, and 1/4 of 40 is 10, so 60 - 10 = 50. Stopping at 60 is the common miss here. Subtracting 40 from 90 first and then taking fractions changes the meaning entirely, because the word minus separates two amounts that are each finished first.'
  WHERE section = 'quantitative' AND prompt = 'What number is 2/3 of 90 minus 1/4 of 40?' AND options = '["40", "45", "50", "60"]'::JSONB;

UPDATE questions SET explanation = 'Take the fraction first, then add: one sixth of 72 is 12, and 12 + 3 = 15. Subtracting instead of adding gives 9, and using one third rather than one sixth gives 24. Adding 3 before dividing would mean 75 / 6, which does not even come out whole. The words more than put the addition last.'
  WHERE section = 'quantitative' AND prompt = 'What number is 3 more than 1/6 of 72?' AND options = '["9", "15", "18", "24"]'::JSONB;

UPDATE questions SET explanation = 'Two steps, in order. First, 4 less than 20 is 16. Then half of the unknown equals 16, so double to recover the whole: 16 x 2 = 32. The answer 16 stops at that halfway point, and 8 comes from halving 16 instead of doubling it. Whenever half of something is known, doubling gets you back.'
  WHERE section = 'quantitative' AND prompt = 'Half of what number is 4 less than 20?' AND options = '["8", "16", "24", "32"]'::JSONB;

UPDATE questions SET explanation = 'The word difference means subtract: 50 - 2 = 48. Then take one third of that: 48 / 3 = 16. Taking a third of 50 first and subtracting 2 afterward gives about 14.7, and the answer 24 comes from halving 48 instead of taking a third. Finish the difference before applying the fraction.'
  WHERE section = 'quantitative' AND prompt = 'What number is 1/3 of the difference between 50 and 2?' AND options = '["12", "16", "18", "24"]'::JSONB;

UPDATE questions SET explanation = 'Do the known side first: half of 36 is 18. Now 40% of the unknown equals 18, so 0.40 times the number is 18 and the number is 18 / 0.4 = 45. Since 40% is only a part, the whole has to be larger than 18, which rules out 18 itself. Taking 40% of 18 gives 7.2, the reverse of what is asked.'
  WHERE section = 'quantitative' AND prompt = '40% of what number is 1/2 of 36?' AND options = '["18", "36", "45", "72"]'::JSONB;

UPDATE questions SET explanation = 'An average of 15 across three numbers means the total is 3 x 15 = 45. The two known numbers add to 12 + 18 = 30, so the missing one is 45 - 30 = 15. Answering 16 comes from assuming the third number must pull the average up, but 12 and 18 already average 15, so the third must be 15 to leave it unchanged.'
  WHERE section = 'quantitative' AND prompt = 'The average of 12, 18, and one other number is 15. What is the other number?' AND options = '["12", "14", "15", "16"]'::JSONB;

UPDATE questions SET explanation = 'Unpack the sentence from the inside. The product of 4 and 8 is 32, three fourths of 32 is 24, and 2 more than that is 26. Stopping at 24 is the common miss, and skipping the fraction to give 32 + 2 = 34 is the other one. The word product means multiply, and more than puts the addition last.'
  WHERE section = 'quantitative' AND prompt = 'What number is 2 more than 3/4 of the product of 4 and 8?' AND options = '["18", "24", "26", "34"]'::JSONB;

-- Verification: expect 250 quantitative rows carrying a long (rewritten) explanation.
SELECT
  'quantitative' AS section,
  COUNT(*) AS total_rows,
  COUNT(*) FILTER (WHERE LENGTH(explanation) > 150) AS long_explanations,
  250 AS expected_long_explanations
FROM questions
WHERE section = 'quantitative';
