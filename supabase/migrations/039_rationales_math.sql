-- 039 — Rewrite math explanations (250 rows)
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

UPDATE questions SET explanation = 'Percent means per hundred. 15% of 100 is 15, and 200 is two hundreds, so you need 15 twice: 15 + 15 = 30. In decimal form, 0.15 × 200 = 30. If you landed on 40, you probably found 20% instead, and 25 would be 12.5% of 200.'
  WHERE section = 'math' AND prompt = 'What is 15% of 200?' AND options = '["25", "30", "35", "40"]'::JSONB;

UPDATE questions SET explanation = 'An exponent means multiply the number by itself, not by 2. So 3² = 9 and 4² = 16, and 9 + 16 = 25. The answer 49 comes from adding first and then squaring, since 3 + 4 = 7 and 7² = 49, but squares happen before addition. Doubling instead of squaring gives 14.'
  WHERE section = 'math' AND prompt = 'What is 3² + 4²?' AND options = '["25", "49", "14", "7"]'::JSONB;

UPDATE questions SET explanation = 'A remainder is what is left after you pull out as many whole groups as you can. Since 6 × 7 = 42 and 47 − 42 = 5, the remainder is 5. A remainder of 6 is impossible here, because another whole group of 6 would fit inside. If you got 4, recheck the subtraction: 47 − 42, not 46 − 42.'
  WHERE section = 'math' AND prompt = 'What is the remainder when 47 is divided by 6?' AND options = '["4", "5", "6", "3"]'::JSONB;

UPDATE questions SET explanation = 'Undo the operations in reverse order. The 5 was subtracted last, so add it back first: 4x = 24. Then undo the multiplication: x = 24 ÷ 4 = 6. Test the answer by putting it back in: 4 × 6 − 5 = 24 − 5 = 19. Trying x = 5 gives 4 × 5 − 5 = 15, which falls short of 19.'
  WHERE section = 'math' AND prompt = 'If 4x − 5 = 19, what is x?' AND options = '["5", "6", "7", "8"]'::JSONB;

UPDATE questions SET explanation = 'Area counts the squares that fit inside, so multiply the two sides: 12 × 7 = 84 square units. The value 38 is the perimeter, the distance around the outside, and 19 is the two sides added once. Perimeter is a length, while area is a length times a length, so the two can never match.'
  WHERE section = 'math' AND prompt = 'A rectangle has length 12 and width 7. What is the area?' AND options = '["38", "74", "84", "19"]'::JSONB;

UPDATE questions SET explanation = 'Time equals distance divided by speed. At 60 miles per hour, 180 miles takes 3 hours, and the extra 30 miles adds half an hour, so 210 ÷ 60 = 3.5 hours. Choosing 3 hours only covers 180 miles, and 4 hours would carry her 240 miles, well past where she is going.'
  WHERE section = 'math' AND prompt = 'Maria drives 60 mph. How long to drive 210 miles?' AND options = '["3 hours", "3.5 hours", "4 hours", "2.5 hours"]'::JSONB;

UPDATE questions SET explanation = 'A 25% discount means you still pay 75% of the price. One quarter of 120 is 30, so the sale price is 120 − 30 = $90. You can also go straight there with 0.75 × 120 = 90. Answers like $95 or $85 come from taking off a flat $25 or a rounded amount instead of a quarter.'
  WHERE section = 'math' AND prompt = 'A $120 jacket is 25% off. What is the sale price?' AND options = '["$85", "$90", "$95", "$80"]'::JSONB;

UPDATE questions SET explanation = 'Two consecutive integers are nearly the same size, so each sits near half of 85, which is 42.5. Call them n and n + 1, so 2n + 1 = 85 and n = 42, making the larger one 43. The value 42 is the smaller of the pair, so reread what the question asks for. Check: 42 + 43 = 85.'
  WHERE section = 'math' AND prompt = 'The sum of two consecutive integers is 85. What is the larger integer?' AND options = '["41", "42", "43", "44"]'::JSONB;

UPDATE questions SET explanation = 'The Pythagorean rule says the two legs squared add up to the hypotenuse squared. So 5² + 12² = 25 + 144 = 169, and √169 = 13. Adding the legs gives 17, which is too long, because a straight path can never be longer than going around. The hypotenuse must land between 12 and 17.'
  WHERE section = 'math' AND prompt = 'A right triangle has legs 5 and 12. What is the hypotenuse?' AND options = '["11", "13", "15", "17"]'::JSONB;

UPDATE questions SET explanation = 'Rates add; times do not. In one hour Pump A fills 1/6 of the pool and Pump B fills 1/4, so together they fill 1/6 + 1/4 = 5/12 of it each hour. One whole pool takes 12/5 = 2.4 hours. Averaging the two times to get 5 hours is backwards, since two pumps must beat the faster pump''s 4 hours.'
  WHERE section = 'math' AND prompt = 'Pump A fills a pool in 6 hours; Pump B in 4 hours. Together, how long?' AND options = '["2 hours", "2.4 hours", "3 hours", "5 hours"]'::JSONB;

UPDATE questions SET explanation = 'Break the multiplication into friendly pieces: 8 × 7 is 8 × 5 plus 8 × 2, which is 40 + 16 = 56. The answer 64 is 8 × 8, one group of eight too many, and 54 is 6 × 9. Because 8 × 7 has to sit between 8 × 6 = 48 and 8 × 8 = 64, only 56 fits the gap.'
  WHERE section = 'math' AND prompt = 'What is 8 × 7?' AND options = '["54", "56", "58", "64"]'::JSONB;

UPDATE questions SET explanation = 'Absolute value asks how far a number sits from zero on the number line, and distance is never negative. The point −15 is 15 units away from zero, so |−15| = 15. Choosing −15 keeps the sign, but the bars strip it off, and 150 would come from multiplying by ten rather than measuring a distance.'
  WHERE section = 'math' AND prompt = 'What is the value of |−15|?' AND options = '["−15", "0", "15", "150"]'::JSONB;

UPDATE questions SET explanation = 'The greatest common factor is the largest number dividing both, so do not stop at the first one you spot. Yes, 6 divides 24 and 36, but so does 12, since 24 = 12 × 2 and 36 = 12 × 3. Because 12 is bigger, 6 is common but not greatest. The value 8 divides 24 and not 36.'
  WHERE section = 'math' AND prompt = 'What is the GCF of 24 and 36?' AND options = '["6", "8", "9", "12"]'::JSONB;

UPDATE questions SET explanation = 'The least common multiple is the first number both of them count to. Fours: 4, 8, 12. Sixes: 6, 12. They meet at 12. Multiplying 4 × 6 = 24 does give a common multiple, but not the smallest one, and 10 is a multiple of neither number. Check: 12 = 4 × 3 = 6 × 2.'
  WHERE section = 'math' AND prompt = 'What is the LCM of 4 and 6?' AND options = '["10", "12", "18", "24"]'::JSONB;

UPDATE questions SET explanation = 'Multiplication comes before addition and subtraction, no matter where the symbols sit. So 4 × 2 = 8 first, and then 3 + 8 − 1 = 10. Working strictly left to right gives 3 + 4 = 7, then 7 × 2 = 14, then 13, which is the trap this question sets. The multiplication cannot wait its turn.'
  WHERE section = 'math' AND prompt = 'Evaluate: 3 + 4 × 2 − 1' AND options = '["10", "12", "13", "14"]'::JSONB;

UPDATE questions SET explanation = 'An exponent counts how many times the base is multiplied by itself, so 2⁵ means 2 × 2 × 2 × 2 × 2. Doubling step by step gives 2, 4, 8, 16, 32. The answer 10 comes from multiplying 2 × 5, and 25 comes from swapping the base and the exponent, which would be 5². Powers of 2 grow fast.'
  WHERE section = 'math' AND prompt = 'What is 2⁵?' AND options = '["10", "16", "25", "32"]'::JSONB;

UPDATE questions SET explanation = 'Pull out as many whole eights as fit: 8 × 6 = 48, and 50 − 48 = 2, so the remainder is 2. If you got 4, check that 8 × 7 = 56 has already passed 50, so seven groups do not fit. A remainder always stays smaller than the number you are dividing by, which here is 8.'
  WHERE section = 'math' AND prompt = 'What is the remainder when 50 is divided by 8?' AND options = '["1", "2", "3", "4"]'::JSONB;

UPDATE questions SET explanation = 'Take each absolute value first, then add. Since −8 sits 8 units from zero, |−8| = 8, and |3| = 3, so the total is 8 + 3 = 11. The answer 5 comes from keeping the minus sign and computing −8 + 3, but the bars remove the sign before any adding happens.'
  WHERE section = 'math' AND prompt = 'What is |−8| + |3|?' AND options = '["−5", "5", "11", "−11"]'::JSONB;

UPDATE questions SET explanation = 'List what divides both numbers: 18 and 30 share 1, 2, 3, and 6, and the largest of those is 6. Choosing 9 stops on the wrong list, since 9 divides 18 but not 30, and 12 divides neither. Check the factoring: 18 = 6 × 3 and 30 = 6 × 5, and 3 and 5 share nothing more.'
  WHERE section = 'math' AND prompt = 'What is the GCF of 18 and 30?' AND options = '["3", "6", "9", "12"]'::JSONB;

UPDATE questions SET explanation = 'Parentheses first, then multiplication, then subtraction. So 6 + 2 = 8, then 8 × 3 = 24, then 24 − 4 = 20. Subtracting inside first, as 3 − 4, gives −8, and answers like 18 or 22 come from mixing up the last two steps. The parentheses are printed there to change the usual order.'
  WHERE section = 'math' AND prompt = 'Evaluate: (6 + 2) × 3 − 4' AND options = '["14", "18", "20", "22"]'::JSONB;

UPDATE questions SET explanation = 'The exponent 3 tells you to use 4 as a factor three times: 4 × 4 × 4. Work in pairs, so 4 × 4 = 16 and then 16 × 4 = 64. The answer 12 comes from multiplying 4 × 3, and 16 stops after only two fours. An exponent means repeated multiplication, not multiplying by the exponent.'
  WHERE section = 'math' AND prompt = 'What is 4³?' AND options = '["12", "16", "48", "64"]'::JSONB;

UPDATE questions SET explanation = 'The least common multiple is the first number that both 6 and 9 divide into. Sixes: 6, 12, 18. Nines: 9, 18. They first meet at 18. The answer 3 is the greatest common factor, which is the opposite idea, and 54 is 6 × 9, a common multiple but far from the smallest one.'
  WHERE section = 'math' AND prompt = 'What is the LCM of 6 and 9?' AND options = '["3", "18", "27", "54"]'::JSONB;

UPDATE questions SET explanation = 'Nine divides 63 exactly, since 9 × 7 = 63 with nothing left over, so the remainder is 0. A remainder of 9 is impossible, because a leftover that big is one more whole group. If you chose 3 or 6, walk the nine times table again: 54, 63, and 63 lands right on the number.'
  WHERE section = 'math' AND prompt = 'What is the remainder when 63 is divided by 9?' AND options = '["0", "3", "6", "9"]'::JSONB;

UPDATE questions SET explanation = 'Handle the exponent first, then the multiplication, then add and subtract from left to right. Since 5² = 25 and 3 × 4 = 12, you get 25 − 12 + 2 = 15. The answer 27 comes from adding 25 + 2 and forgetting to subtract at all. Note that 5² means 5 × 5, not 5 × 2.'
  WHERE section = 'math' AND prompt = 'Evaluate: 5² − 3 × 4 + 2' AND options = '["12", "15", "17", "27"]'::JSONB;

UPDATE questions SET explanation = 'A square root asks which number times itself gives 81. Test a couple: 8 × 8 = 64, too small, and 9 × 9 = 81, exactly right, so √81 = 9. The answer 11 overshoots badly, since 11 × 11 = 121. A square root is not half of the number, so 81 ÷ 2 will not help here.'
  WHERE section = 'math' AND prompt = 'What is √81?' AND options = '["7", "8", "9", "11"]'::JSONB;

UPDATE questions SET explanation = 'Break both numbers into factors of 2. Here 32 = 2 × 2 × 2 × 2 × 2 and 48 = 2 × 2 × 2 × 2 × 3, so they share four 2s, which multiply to 16. The value 8 divides both but is not the greatest, and 12 divides 48 only. Check: 32 = 16 × 2 and 48 = 16 × 3.'
  WHERE section = 'math' AND prompt = 'What is the GCF of 32 and 48?' AND options = '["8", "12", "16", "24"]'::JSONB;

UPDATE questions SET explanation = 'Fractions add only when the pieces are the same size, so rewrite 1/2 as 2/4. Then 2/4 + 1/4 = 3/4. The answer 2/6 comes from adding tops and bottoms separately, which lands below 1/2 even though you added something on. Adding to a half has to push the total past a half.'
  WHERE section = 'math' AND prompt = 'What is 1/2 + 1/4?' AND options = '["1/6", "2/6", "3/4", "1/3"]'::JSONB;

UPDATE questions SET explanation = 'Read the decimal by place value: 0.75 is 75 hundredths, or 75/100. Dividing top and bottom by 25 gives 3/4. The form 15/20 has the same value but is not in lowest terms, which the question asks for, and 75/10 misplaces the decimal, since that fraction equals 7.5.'
  WHERE section = 'math' AND prompt = 'What is 0.75 expressed as a fraction in lowest terms?' AND options = '["7/10", "3/4", "75/10", "4/5"]'::JSONB;

UPDATE questions SET explanation = 'Twenty percent is one fifth, so split 80 into five equal parts of 16. As a decimal, 0.20 × 80 = 16. The answer 20 repeats the percent number instead of the amount, and 12 would be 15% of 80. Quick check: 10% of 80 is 8, so 20% is double that, which is 16.'
  WHERE section = 'math' AND prompt = 'What is 20% of 80?' AND options = '["12", "14", "16", "20"]'::JSONB;

UPDATE questions SET explanation = 'Turn each fraction into a decimal so they sit on one scale: 1/2 = 0.5, 2/5 = 0.4, and 3/7 is about 0.429. The largest is 1/2. It is tempting to pick 3/7 because it has the biggest numbers, but bigger numerators and denominators do not make a bigger fraction. Both 2/5 and 3/7 stay under a half.'
  WHERE section = 'math' AND prompt = 'Which fraction is largest: 1/2, 2/5, 3/7?' AND options = '["1/2", "2/5", "3/7", "All equal"]'::JSONB;

UPDATE questions SET explanation = 'The word of means multiply. One fourth of 60 is 15, so three fourths is 3 × 15 = 45. Picking 40 treats the fraction as two thirds, and 48 comes from 60 − 12. Sanity check: three quarters is most of 60 but not all of it, so the answer belongs between 30 and 60.'
  WHERE section = 'math' AND prompt = 'What is 3/4 of 60?' AND options = '["40", "42", "45", "48"]'::JSONB;

UPDATE questions SET explanation = 'Line up the decimal points and fill in a zero: 0.30 + 0.45 = 0.75. The answer 0.48 comes from lining the digits up on the right instead, which treats 0.3 as 0.03. Check the size: 0.3 is a bit under a third and 0.45 is nearly a half, so a total near three quarters makes sense.'
  WHERE section = 'math' AND prompt = 'What is 0.3 + 0.45?' AND options = '["0.48", "0.75", "0.73", "0.78"]'::JSONB;

UPDATE questions SET explanation = 'Percent means out of a hundred, so compare 10 to 50 first: 10/50 = 1/5. One fifth is 20 out of 100, so the answer is 20%. Choosing 10% repeats the number 10 from the question instead of comparing it to 50, and 5% would mean 10 is one twentieth of 50. Check: 20% of 50 = 10.'
  WHERE section = 'math' AND prompt = 'What percent of 50 is 10?' AND options = '["5%", "10%", "15%", "20%"]'::JSONB;

UPDATE questions SET explanation = 'Multiply straight across: the tops give 2 × 3 = 6 and the bottoms give 3 × 4 = 12, so the product is 6/12. Divide both parts by 6 to reduce it to 1/2. The forms 6/12 and 2/4 name the same amount but are not in lowest terms, which a final answer should be. You can also cancel the 3s before multiplying.'
  WHERE section = 'math' AND prompt = 'What is 2/3 × 3/4?' AND options = '["5/7", "1/3", "1/2", "2/3"]'::JSONB;

UPDATE questions SET explanation = 'A 50% markup adds half the original price on top. Half of 40 is 20, so the new price is 40 + 20 = $60. The answer $50 adds only 25%, and $55 adds even less. A 50% markup always makes the new price 1.5 times the old one, and 1.5 × 40 = 60, which confirms it.'
  WHERE section = 'math' AND prompt = 'A store marks a $40 item up by 50%. What is the new price?' AND options = '["$50", "$55", "$60", "$65"]'::JSONB;

UPDATE questions SET explanation = 'A fraction bar means divide, so 1 ÷ 5 = 0.2. You can also scale to tenths, since 1/5 = 2/10 = 0.2. The answer 0.1 is 1/10, which cuts the whole into ten parts rather than five, and 0.25 is 1/4. Check it: five copies of 0.2 add up to exactly 1.'
  WHERE section = 'math' AND prompt = 'What is 1/5 as a decimal?' AND options = '["0.1", "0.15", "0.2", "0.25"]'::JSONB;

UPDATE questions SET explanation = 'Subtraction needs matching denominators, so rewrite 1/4 as 2/8. Then 5/8 − 2/8 = 3/8. Answers like 1/8 or 4/8 come from mixing the tops and bottoms together instead of converting first. Once the denominators match, only the numerators change, and the 8 on the bottom stays put.'
  WHERE section = 'math' AND prompt = 'What is 5/8 − 1/4?' AND options = '["3/8", "4/8", "1/8", "2/8"]'::JSONB;

UPDATE questions SET explanation = 'The mean evens the numbers out: add them all, then share the total equally. Here 4 + 8 + 6 + 10 + 2 = 30, and 30 ÷ 5 = 6. Choosing 5 averages only the smallest and largest, and 8 picks a value from the list rather than the balance point. Some values sit above 6, some below.'
  WHERE section = 'math' AND prompt = 'Find the mean of: 4, 8, 6, 10, 2.' AND options = '["5", "6", "7", "8"]'::JSONB;

UPDATE questions SET explanation = 'The median is the middle value once the list is in order, so sort it first: 2, 3, 5, 7, 9. With five numbers, the third one is the middle, which is 5. Choosing 7 grabs the middle of the list as it was written, before sorting, and 3 or 9 sit off toward the edges. Sorting is the skipped step.'
  WHERE section = 'math' AND prompt = 'Find the median of: 3, 7, 2, 9, 5.' AND options = '["5", "7", "3", "9"]'::JSONB;

UPDATE questions SET explanation = 'The mode is the value that shows up most often, not the largest and not the middle. Counting through, 4 appears three times while every other number appears once, so the mode is 4. Picking 7 takes the biggest value, and 5 sits near the center; neither pays attention to repeats.'
  WHERE section = 'math' AND prompt = 'Find the mode of: 2, 4, 4, 5, 6, 4, 7.' AND options = '["2", "4", "5", "7"]'::JSONB;

UPDATE questions SET explanation = 'Range measures how spread out the data is: largest minus smallest, so 15 − 3 = 12. Picking 15 gives the largest value itself rather than the spread, and 9 comes from using 15 − 6 instead of the true minimum. Scan the entire list for both the biggest and smallest before subtracting.'
  WHERE section = 'math' AND prompt = 'Find the range of: 10, 3, 7, 15, 6.' AND options = '["9", "10", "12", "15"]'::JSONB;

UPDATE questions SET explanation = 'Add everything, then divide by how many numbers there are. Here 12 + 16 + 20 + 8 = 56, and 56 ÷ 4 = 14. Choosing 16 or 12 picks a value straight from the list instead of computing. The mean has to land between the smallest, 8, and the largest, 20, and 14 sits comfortably in that band.'
  WHERE section = 'math' AND prompt = 'Find the mean of: 12, 16, 20, 8.' AND options = '["12", "14", "15", "16"]'::JSONB;

UPDATE questions SET explanation = 'Perimeter is the distance all the way around, and a square has four equal sides, so 4 × 9 = 36. The answer 81 is the area, 9 × 9, which measures the surface inside rather than the border, and 18 only walks two sides. Perimeter adds sides; it never multiplies two of them together.'
  WHERE section = 'math' AND prompt = 'What is the perimeter of a square with side 9?' AND options = '["18", "27", "36", "81"]'::JSONB;

UPDATE questions SET explanation = 'A triangle covers half of the rectangle built on the same base and height. That rectangle is 10 × 6 = 60, so the triangle is half of it, 30. The answer 60 forgets the one half, and 16 adds the base and height instead of multiplying them. Multiply first, then halve.'
  WHERE section = 'math' AND prompt = 'What is the area of a triangle with base 10 and height 6?' AND options = '["16", "30", "60", "48"]'::JSONB;

UPDATE questions SET explanation = 'Area uses the radius squared: A = π × r² = 3.14 × 3² = 3.14 × 9 = 28.26. The value 18.84 is the circumference, 2 × 3.14 × 3, which measures the rim rather than the space inside, and 9.42 skips the squaring entirely. Square the radius first, then multiply by pi.'
  WHERE section = 'math' AND prompt = 'What is the area of a circle with radius 3? (Use π ≈ 3.14)' AND options = '["9.42", "18.84", "28.26", "37.68"]'::JSONB;

UPDATE questions SET explanation = 'A perimeter counts each side twice, so 2(length + width) = 30, which means length + width = 15 and the length is 15 − 6 = 9. The answer 12 comes from doing 30 − 6 − 6 without halving, and 5 comes from 30 ÷ 6. Check the sides: 9 + 6 + 9 + 6 = 30.'
  WHERE section = 'math' AND prompt = 'A rectangle has perimeter 30. Its width is 6. What is its length?' AND options = '["5", "7", "9", "12"]'::JSONB;

UPDATE questions SET explanation = 'The three angles of any triangle add to 180°. Two of them use 50 + 70 = 120°, so the third must be 180 − 120 = 60°. Choosing 70° or 50° repeats an angle already given, and 80° would push the total to 200°, more than a triangle can hold. Check: 50 + 70 + 60 = 180.'
  WHERE section = 'math' AND prompt = 'Two angles of a triangle are 50° and 70°. What is the third angle?' AND options = '["50°", "60°", "70°", "80°"]'::JSONB;

UPDATE questions SET explanation = 'Circumference is pi times the diameter: 3.14 × 10 = 31.4. The value 15.7 uses the radius, 5, in place of the diameter, and 78.5 is the area, π × 5², which measures the space inside. Since the diameter is 10, the trip around should be a little more than three times that.'
  WHERE section = 'math' AND prompt = 'What is the circumference of a circle with diameter 10? (Use π ≈ 3.14)' AND options = '["15.7", "31.4", "62.8", "78.5"]'::JSONB;

UPDATE questions SET explanation = 'Area of a rectangle is length times width: 8 × 5 = 40 square feet. The value 26 is the perimeter, the distance around the walls, and 13 is 8 + 5. Picture 8 rows of 5 floor tiles; counting them gives 40, which is more than the distance around the room.'
  WHERE section = 'math' AND prompt = 'A rectangular room is 8 feet long and 5 feet wide. What is its area?' AND options = '["13", "26", "35", "40"]'::JSONB;

UPDATE questions SET explanation = 'A right angle is the square corner you see in a book or a window frame, and it measures exactly 90°. An acute angle is smaller than 90°, an obtuse angle is larger than 90° but under 180°, and a straight angle is a flat line at 180°. Only right names the exact square corner.'
  WHERE section = 'math' AND prompt = 'What type of angle measures exactly 90°?' AND options = '["Acute", "Obtuse", "Right", "Straight"]'::JSONB;

UPDATE questions SET explanation = 'Undo the operations in reverse. The 7 was added last, so subtract it first: 3x = 15. Then divide by 3 to get x = 5. Check by substituting: 3 × 5 + 7 = 15 + 7 = 22. Choosing 7 grabs a number straight out of the equation, and x = 6 would give 25, which overshoots.'
  WHERE section = 'math' AND prompt = 'If 3x + 7 = 22, what is x?' AND options = '["4", "5", "6", "7"]'::JSONB;

UPDATE questions SET explanation = 'Work backwards through the operations. Add the 3 back first: 2x = 12. Then divide by 2 to get x = 6. Test it: 2 × 6 − 3 = 12 − 3 = 9. Trying x = 4 gives 5, and x = 3 gives 3, so neither reaches 9. Add before you divide, or the steps unravel.'
  WHERE section = 'math' AND prompt = 'If 2x − 3 = 9, what is x?' AND options = '["3", "4", "5", "6"]'::JSONB;

UPDATE questions SET explanation = 'When x appears on both sides, gather the x terms first. Subtract 3x from each side to get 2x + 2 = 10, then subtract 2 for 2x = 8, so x = 4. Check both sides: 5 × 4 + 2 = 22 and 3 × 4 + 10 = 22, which match. Trying x = 3 gives 17 and 19, sides that disagree.'
  WHERE section = 'math' AND prompt = 'If 5x + 2 = 3x + 10, what is x?' AND options = '["2", "3", "4", "5"]'::JSONB;

UPDATE questions SET explanation = 'Even numbers step by 2, so call them n, n + 2, and n + 4. Their total is 3n + 6 = 60, giving n = 18, so the numbers are 18, 20, and 22 and the largest is 22. The value 20 is the middle one and 18 is the smallest, so check which one the question wants.'
  WHERE section = 'math' AND prompt = 'The sum of three consecutive even integers is 60. What is the largest?' AND options = '["18", "20", "22", "24"]'::JSONB;

UPDATE questions SET explanation = 'Division by 4 is undone by multiplication by 4, so x = 9 × 4 = 36. Choosing 13 adds 9 + 4 and 27 uses 9 × 3, but neither reverses a division. Test the answer: 36 ÷ 4 = 9, which matches. Since x was cut into fourths to make 9, x must be much larger than 9.'
  WHERE section = 'math' AND prompt = 'If x/4 = 9, what is x?' AND options = '["13", "27", "36", "40"]'::JSONB;

UPDATE questions SET explanation = 'The x term is being subtracted, so move it out of the way: add 2x to both sides, giving 7 = 1 + 2x. Then 2x = 6 and x = 3. Check: 7 − 2 × 3 = 7 − 6 = 1. Trying x = 2 leaves 3, and x = 4 leaves −1, so only 3 lands on 1.'
  WHERE section = 'math' AND prompt = 'If 7 − 2x = 1, what is x?' AND options = '["2", "3", "4", "5"]'::JSONB;

UPDATE questions SET explanation = 'Divide both sides by 3 to get x > 4. Greater than is strict, so 4 itself does not count: 3 × 4 = 12 is not more than 12. Smaller values fall even shorter, since x = 2 gives 6 and x = 3 gives 9. Only x = 5 works, because 3 × 5 = 15, which is greater than 12.'
  WHERE section = 'math' AND prompt = 'Which value of x satisfies: 3x > 12?' AND options = '["x = 2", "x = 4", "x = 5", "x = 3"]'::JSONB;

UPDATE questions SET explanation = 'The whole parenthesis is multiplied by 2, so divide both sides by 2 first: x + 3 = 7, which gives x = 4. Choosing 7 stops at that middle step and forgets to subtract the 3. You can also distribute: 2x + 6 = 14, so 2x = 8. Check: 2(4 + 3) = 2 × 7 = 14.'
  WHERE section = 'math' AND prompt = 'If 2(x + 3) = 14, what is x?' AND options = '["4", "5", "6", "7"]'::JSONB;

UPDATE questions SET explanation = 'Odd numbers jump by 2, so write the pair as n and n + 2. Then 2n + 2 = 36, so n = 17 and the two numbers are 17 and 19. The question asks for the smaller, so 19 is the partner, not the answer. Check: 17 + 19 = 36, and both numbers are odd.'
  WHERE section = 'math' AND prompt = 'The sum of two consecutive odd integers is 36. What is the smaller integer?' AND options = '["15", "17", "19", "21"]'::JSONB;

UPDATE questions SET explanation = 'Collect the x terms on one side: subtract 5x to get 4x − 4 = 8. Add 4 for 4x = 12, so x = 3. Check both sides: 9 × 3 − 4 = 23 and 5 × 3 + 8 = 23, which agree. Trying x = 2 gives 14 and 18, sides that do not balance, so keep gathering before dividing.'
  WHERE section = 'math' AND prompt = 'If 9x − 4 = 5x + 8, what is x?' AND options = '["2", "3", "4", "5"]'::JSONB;

UPDATE questions SET explanation = 'Adding the two equations cancels y, because +y and −y undo each other: 2x = 14, so x = 7 and then y = 3. Choosing 5 splits 10 evenly and ignores the second equation, which says x is 4 more than y. Check both: 7 + 3 = 10 and 7 − 3 = 4, so the pair works.'
  WHERE section = 'math' AND prompt = 'If x + y = 10 and x − y = 4, what is x?' AND options = '["3", "5", "7", "9"]'::JSONB;

UPDATE questions SET explanation = 'Substitute the value you already have. With x = 3, the equation becomes 2 × 3 + y = 11, so 6 + y = 11 and y = 5. Choosing 3 reuses the value of x rather than solving for y, and y = 6 would make the left side 12, one too many. Check: 6 + 5 = 11.'
  WHERE section = 'math' AND prompt = 'If 2x + y = 11 and x = 3, what is y?' AND options = '["3", "4", "5", "6"]'::JSONB;

UPDATE questions SET explanation = 'Add 1 to both sides, then divide by 4: 4x ≤ 12, so x ≤ 3. This symbol allows equality, so x = 3 counts, since 4 × 3 − 1 = 11 is allowed. Larger values fail, because x = 4 gives 15 and x = 5 gives 19, both above 11. Of the choices, only x = 3 satisfies it.'
  WHERE section = 'math' AND prompt = 'Which value satisfies 4x − 1 ≤ 11?' AND options = '["x = 4", "x = 3", "x = 5", "x = 6"]'::JSONB;

UPDATE questions SET explanation = 'Put the known value in first. With y = 2, the term 2y becomes 4, so 3x + 4 = 16. Subtract to get 3x = 12, then x = 4. Choosing 6 comes from dividing 16 + 2 by 3, and x = 3 would give 9 + 4 = 13, short of 16. Check: 12 + 4 = 16.'
  WHERE section = 'math' AND prompt = 'If 3x + 2y = 16 and y = 2, what is x?' AND options = '["3", "4", "5", "6"]'::JSONB;

UPDATE questions SET explanation = 'Consecutive integers sit right next to each other, so both should be near the square root of 56, which is a little over 7. Testing gives 7 × 8 = 56, exactly right. The pair 6 and 7 makes 42, and 8 and 9 makes 72, so they bracket the target without hitting it.'
  WHERE section = 'math' AND prompt = 'The product of two consecutive integers is 56. What are the integers?' AND options = '["6 and 7", "7 and 8", "8 and 9", "5 and 6"]'::JSONB;

UPDATE questions SET explanation = 'Peel the operations off in reverse order. Subtract the 2 first, leaving x/3 = 5. Then undo the division by multiplying by 3, so x = 15. Choosing 9 comes from 3 × 3, and 18 comes from adding before dividing. Check the answer: 15 ÷ 3 = 5, and 5 + 2 = 7.'
  WHERE section = 'math' AND prompt = 'If x/3 + 2 = 7, what is x?' AND options = '["9", "12", "15", "18"]'::JSONB;

UPDATE questions SET explanation = 'Move the x terms to one side and the numbers to the other. Add x to both sides for 6 = 3x − 3, then add 3 to get 9 = 3x, so x = 3. Check both sides: 6 − 3 = 3 and 2 × 3 − 3 = 3, which agree. Trying x = 2 gives 4 and 1, sides that do not match.'
  WHERE section = 'math' AND prompt = 'Solve for x: 6 − x = 2x − 3.' AND options = '["2", "3", "4", "5"]'::JSONB;

UPDATE questions SET explanation = 'Divide both sides by 5 first: x − 2 = 3, so x = 5. Choosing 3 stops at that middle step and forgets to add the 2 back. Distributing works too: 5x − 10 = 15, so 5x = 25. Check the answer: 5(5 − 2) = 5 × 3 = 15, which matches the equation.'
  WHERE section = 'math' AND prompt = 'If 5(x − 2) = 15, what is x?' AND options = '["3", "4", "5", "7"]'::JSONB;

UPDATE questions SET explanation = 'Let the smaller number be x, so the larger is 3x. Together, x + 3x = 4x = 48, giving x = 12 and a larger number of 3 × 12 = 36. The value 12 is the smaller number, and 24 is half of 48, which would be right only if the two numbers were equal. Check: 12 + 36 = 48.'
  WHERE section = 'math' AND prompt = 'The sum of two numbers is 48. One number is 3 times the other. What is the larger number?' AND options = '["12", "24", "32", "36"]'::JSONB;

UPDATE questions SET explanation = 'Substitute what you know: 2 × 3 = 6, so 6 + 3y = 18. Subtract to get 3y = 12, then y = 4. Choosing 3 repeats the value of x instead of solving for y, and y = 6 would make the left side 24, too big. Check: 6 + 3 × 4 = 6 + 12 = 18.'
  WHERE section = 'math' AND prompt = 'If 2x + 3y = 18 and x = 3, what is y?' AND options = '["3", "4", "5", "6"]'::JSONB;

UPDATE questions SET explanation = 'Clear the fraction first by multiplying both sides by 4, giving 3x = 36. Then divide by 3, so x = 12. Doing only one of those two steps leaves you at 36 or at 3, neither of which is x, and answers like 8 or 10 come from guessing between them. Check: 3 × 12 ÷ 4 = 9.'
  WHERE section = 'math' AND prompt = 'Solve for x: 3x/4 = 9.' AND options = '["8", "10", "12", "15"]'::JSONB;

UPDATE questions SET explanation = 'Add 8 to both sides to get n > 13. Greater than does not include 13 itself, so n = 13 fails, since 13 − 8 = 5 is not more than 5. Smaller values like 12 or 10 fall further short. Only n = 14 works, because 14 − 8 = 6, which is greater than 5.'
  WHERE section = 'math' AND prompt = 'If n − 8 > 5, which value of n is a solution?' AND options = '["12", "13", "14", "10"]'::JSONB;

UPDATE questions SET explanation = 'Two consecutive integers each sit near half of 99, which is 49.5. Writing them as n and n + 1 gives 2n + 1 = 99, so n = 49 and the larger is 50. The value 49 is the smaller of the pair, so read the question carefully. Check: 49 + 50 = 99, while 51 would need 48 as its partner.'
  WHERE section = 'math' AND prompt = 'The sum of two consecutive integers is 99. What is the larger?' AND options = '["48", "49", "50", "51"]'::JSONB;

UPDATE questions SET explanation = 'Add the two equations so the y terms cancel: 2x = 10, so x = 5, and then y = 8 − 5 = 3. Subtracting the equations instead gives 2y = 6, the same answer. Choosing 5 reports the value of x rather than y, which is the usual slip. Check: 5 + 3 = 8 and 5 − 3 = 2.'
  WHERE section = 'math' AND prompt = 'Solve the system: x + y = 8 and x − y = 2. What is y?' AND options = '["2", "3", "4", "5"]'::JSONB;

UPDATE questions SET explanation = 'Divide both sides by 4 first: 2x − 1 = 7, then 2x = 8, so x = 4. Distributing works as well: 8x − 4 = 28, so 8x = 32. Trying x = 3 gives 4(6 − 1) = 20, short of 28, and x = 5 gives 36. Check: 4(8 − 1) = 4 × 7 = 28.'
  WHERE section = 'math' AND prompt = 'If 4(2x − 1) = 28, what is x?' AND options = '["3", "4", "5", "6"]'::JSONB;

UPDATE questions SET explanation = 'Translate the sentence in order: multiplied by 6 then decreased by 5 becomes 6x − 5 = 31. Add 5 to both sides for 6x = 36, so x = 6. Check: 6 × 6 = 36, and 36 − 5 = 31. Trying 5 gives 25 and trying 7 gives 37, so only 6 lands exactly on 31.'
  WHERE section = 'math' AND prompt = 'A number multiplied by 6 then decreased by 5 equals 31. What is the number?' AND options = '["5", "6", "7", "8"]'::JSONB;

UPDATE questions SET explanation = 'A square root asks what number times itself makes 49, and 7 × 7 = 49. Trying 8 gives 64 and trying 6 gives 36, so both miss the mark. Note that −7 also squares to 49, though only the positive value appears among these choices. Squaring and taking a root undo each other.'
  WHERE section = 'math' AND prompt = 'Solve for x: x² = 49.' AND options = '["6", "7", "8", "9"]'::JSONB;

UPDATE questions SET explanation = 'Subtract 5 from both sides, then divide by 2: 2x > 8, so x > 4. Since 4 is not included, x = 4 fails, because 2 × 4 + 5 = 13 is not greater than 13. Values like 3 or 2 fall further short. Only x = 5 works, giving 2 × 5 + 5 = 15.'
  WHERE section = 'math' AND prompt = 'If 2x + 5 > 13, which value of x satisfies the inequality?' AND options = '["3", "4", "5", "2"]'::JSONB;

UPDATE questions SET explanation = 'Twice its value means 2x, so the sentence becomes x + 2x = 27, which is 3x = 27 and x = 9. Trying 7 or 8 gives totals of 21 and 24, both short of 27, and 10 would overshoot to 30. Check the answer: 9 + 18 = 27, exactly the total described.'
  WHERE section = 'math' AND prompt = 'The sum of a number and twice its value is 27. What is the number?' AND options = '["7", "8", "9", "10"]'::JSONB;

UPDATE questions SET explanation = 'A ratio splits the total into equal parts. Here 1 + 2 + 3 = 6 parts share 180°, so each part is 30°. The angles are 30°, 60°, and 90°, and the largest is 90°. Choosing 60° takes the middle angle rather than the largest, and 100° would push the total past 180°.'
  WHERE section = 'math' AND prompt = 'A triangle has angles in ratio 1:2:3. What is the largest angle?' AND options = '["60°", "80°", "90°", "100°"]'::JSONB;

UPDATE questions SET explanation = 'Area is pi times the radius squared, so square the radius before multiplying: 5² = 25, and 3.14 × 25 = 78.5. The value 31.4 is the circumference, 2 × 3.14 × 5, which measures the rim, and 157 is double the area. Squaring first is the step that gets skipped.'
  WHERE section = 'math' AND prompt = 'What is the area of a circle with radius 5? (Use π ≈ 3.14)' AND options = '["31.4", "62.8", "78.5", "157"]'::JSONB;

UPDATE questions SET explanation = 'Volume fills the whole box, so multiply all three dimensions: 5 × 4 × 3 = 60 cubic units. Picture 3 layers, each a 5 by 4 slab holding 20 cubes, which totals 60. The value 40 stops after only two dimensions, and 47 comes from adding rather than multiplying somewhere along the way.'
  WHERE section = 'math' AND prompt = 'A rectangular prism has length 5, width 4, and height 3. What is its volume?' AND options = '["40", "47", "60", "72"]'::JSONB;

UPDATE questions SET explanation = 'Supplementary angles add to 180°. Split that into 2 + 3 = 5 equal parts of 36°, so the angles are 72° and 108° and the larger is 108°. Choosing 72° names the smaller one. Check: 72 + 108 = 180, while 90° and 120° would not fit a 2 to 3 ratio.'
  WHERE section = 'math' AND prompt = 'Two supplementary angles are in ratio 2:3. What is the measure of the larger angle?' AND options = '["72°", "90°", "108°", "120°"]'::JSONB;

UPDATE questions SET explanation = 'The hypotenuse is the longest side, so square it and take away the known leg squared: 10² − 6² = 100 − 36 = 64, and the missing leg is 8. Subtracting the sides directly, 10 − 6, gives 4, which is the trap here. Check: 6, 8, 10 works, since 36 + 64 = 100.'
  WHERE section = 'math' AND prompt = 'A right triangle has hypotenuse 10 and one leg 6. What is the other leg?' AND options = '["4", "6", "8", "9"]'::JSONB;

UPDATE questions SET explanation = 'Perimeter is the total distance around, so add every side: 7 + 11 + 13 = 31. Grouping helps, since 7 + 13 = 20 and 20 + 11 = 31. Answers like 28 or 30 usually mean a side got left out or miscounted, so recount by pairing first. Nothing is multiplied, because perimeter is a length.'
  WHERE section = 'math' AND prompt = 'What is the perimeter of a triangle with sides 7, 11, and 13?' AND options = '["28", "30", "31", "33"]'::JSONB;

UPDATE questions SET explanation = 'Work backwards from the area to the side: a square with area 64 has side √64 = 8. Then the perimeter is 4 × 8 = 32. Choosing 16 doubles the side instead of using all four, and 24 counts only three sides. The side length is the bridge between area and perimeter.'
  WHERE section = 'math' AND prompt = 'A square has an area of 64. What is its perimeter?' AND options = '["16", "24", "32", "36"]'::JSONB;

UPDATE questions SET explanation = 'Circumference is 2 × π × r, so undo it: 62.8 ÷ 3.14 = 20, and that 20 is the diameter, which makes the radius half of it, 10. Stopping at 20 reports the diameter instead, and that is the most common slip here. Check: 2 × 3.14 × 10 = 62.8.'
  WHERE section = 'math' AND prompt = 'The circumference of a circle is 62.8. What is the radius? (Use π ≈ 3.14)' AND options = '["5", "10", "15", "20"]'::JSONB;

UPDATE questions SET explanation = 'Complementary angles add to 90°, the square corner. So the complement is 90 − 35 = 55°. The value 145° is the supplement, which pairs with 180° instead, and 65° comes from using 100 rather than 90. Check the answer: 35 + 55 = 90, exactly a right angle.'
  WHERE section = 'math' AND prompt = 'An angle measures 35°. What is the measure of its complement?' AND options = '["45°", "55°", "65°", "145°"]'::JSONB;

UPDATE questions SET explanation = 'Volume multiplies all three dimensions: 10 × 3 × 4 = 120 cubic units. Take it in steps, since the 10 by 3 base holds 30 cubes and 4 layers of those make 120. Answers like 100 or 110 come from rounding partway through or adding a dimension instead of multiplying by it.'
  WHERE section = 'math' AND prompt = 'A rectangular prism has length 10, width 3, and height 4. What is its volume?' AND options = '["100", "110", "120", "130"]'::JSONB;

UPDATE questions SET explanation = 'Complementary angles add to 90°. The ratio splits that into 1 + 4 = 5 parts of 18° each, so the angles are 18° and 72°, and the larger is 72°. Choosing 18° names the smaller angle, and 80° would leave only 10° for its partner, which is not a 1 to 4 split.'
  WHERE section = 'math' AND prompt = 'Two complementary angles are in ratio 1:4. What is the larger angle?' AND options = '["18°", "54°", "72°", "80°"]'::JSONB;

UPDATE questions SET explanation = 'Circumference equals pi times the diameter, so divide: 18.84 ÷ 3.14 = 6. The question asks for the diameter, so 6 is it; the value 3 is the radius, half as long, and picking it is the usual slip. Check: 3.14 × 6 = 18.84, a bit over three diameters, which is what pi promises.'
  WHERE section = 'math' AND prompt = 'A circle has circumference 18.84. What is its diameter? (Use π ≈ 3.14)' AND options = '["3", "6", "9", "12"]'::JSONB;

UPDATE questions SET explanation = 'A triangle covers half the rectangle built on the same base and height. That rectangle is 14 × 8 = 112, so the triangle is 56. The answer 112 forgets to halve, and 44 comes from treating the numbers like a perimeter. Multiply base by height, then take half, in that order.'
  WHERE section = 'math' AND prompt = 'What is the area of a triangle with base 14 and height 8?' AND options = '["44", "56", "78", "112"]'::JSONB;

UPDATE questions SET explanation = 'Area is length times width, so the width is the area divided by the length: 72 ÷ 9 = 8. Choosing 9 repeats the length given in the question, and 6 would produce an area of 54, not 72. Check by multiplying back: 9 × 8 = 72, matching the area exactly.'
  WHERE section = 'math' AND prompt = 'A rectangle has area 72 and length 9. What is the width?' AND options = '["6", "7", "8", "9"]'::JSONB;

UPDATE questions SET explanation = 'Supplementary angles form a straight line and add to 180°, so the supplement is 180 − 130 = 50°. Choosing 40° comes from using 170 by mistake, and complements cannot apply here at all, because 130° is already past 90°. Check the answer: 130 + 50 = 180, a straight line.'
  WHERE section = 'math' AND prompt = 'An angle measures 130°. What is the measure of its supplement?' AND options = '["40°", "50°", "60°", "70°"]'::JSONB;

UPDATE questions SET explanation = 'Add the squares of the legs to get the hypotenuse squared: 8² + 15² = 64 + 225 = 289, and √289 = 17. Choosing 15 repeats a leg, but the hypotenuse must be longer than either leg, and 16 falls short because 16² = 256. The 8, 15, 17 trio is worth memorizing.'
  WHERE section = 'math' AND prompt = 'A right triangle has legs 8 and 15. What is the hypotenuse?' AND options = '["15", "16", "17", "18"]'::JSONB;

UPDATE questions SET explanation = 'A cube has three equal edges, so its volume is 6 × 6 × 6. Step through it: 6 × 6 = 36, then 36 × 6 = 216. The answer 36 is the area of one face, and 72 is 6 × 12. Volume needs all three dimensions, which is why it grows so much faster than area.'
  WHERE section = 'math' AND prompt = 'What is the volume of a cube with side length 6?' AND options = '["36", "72", "180", "216"]'::JSONB;

UPDATE questions SET explanation = 'Distance equals speed times time: 80 × 2.5 = 200 miles. Break it up, since 2 hours cover 160 miles and the half hour adds 40 more, totaling 200. Choosing 180 would fit a slower train, and 210 would need more than 2.5 hours at 80 mph. Half an hour is worth exactly half of 80.'
  WHERE section = 'math' AND prompt = 'A train travels at 80 mph. How far does it travel in 2.5 hours?' AND options = '["180", "190", "200", "210"]'::JSONB;

UPDATE questions SET explanation = 'Let Diego have d cards, so Carlos has 2d and the total is 3d = 90, giving d = 30 and Carlos 2 × 30 = 60. The value 30 is Diego''s count, not Carlos''s, and 45 splits the cards evenly, which would be right only if they had the same number. Check: 30 + 60 = 90.'
  WHERE section = 'math' AND prompt = 'Carlos has twice as many cards as Diego. Together they have 90. How many does Carlos have?' AND options = '["30", "45", "60", "75"]'::JSONB;

UPDATE questions SET explanation = 'Average speed is total distance divided by total time: 150 ÷ 3 = 50 mph. Check it forward, since 3 hours at 50 mph covers 150 miles. Choosing 45 mph would reach only 135 miles in 3 hours, and 60 mph would overshoot to 180. Test any speed answer by multiplying it back.'
  WHERE section = 'math' AND prompt = 'A car travels 150 miles in 3 hours. What is its average speed?' AND options = '["40 mph", "45 mph", "50 mph", "60 mph"]'::JSONB;

UPDATE questions SET explanation = 'Let Ben be b, so Anna is b + 4 and together they make 2b + 4 = 28. That gives b = 12 and Anna 16. The value 14 splits 28 in half, which would make them the same age, and 20 would leave Ben at 8, a gap of 12. Check: 16 + 12 = 28, with Anna older by 4.'
  WHERE section = 'math' AND prompt = 'Anna is 4 years older than Ben. The sum of their ages is 28. How old is Anna?' AND options = '["14", "16", "18", "20"]'::JSONB;

UPDATE questions SET explanation = 'Percent profit compares the profit to what the store PAID, not to what it charged. The profit is $25 - $15 = $10 on a cost of $15, and 10/15 = 2/3, so the profit is 66 2/3%. Comparing the $10 to the $25 selling price instead gives 40%, which is the usual mix-up. Check: two thirds of $15 is $10.'
  WHERE section = 'math' AND prompt = 'A store buys shirts for $15 each and sells them for $25 each. What is the percent profit?' AND options = '["40%", "50%", "66 2/3%", "75%"]'::JSONB;

UPDATE questions SET explanation = 'Convert the time to hours before dividing: 48 minutes is 48/60 = 0.8 of an hour. Then the speed is 12 ÷ 0.8 = 15 mph. Choosing 12 treats the ride as taking a full hour, but 48 minutes is less than an hour, so the hourly rate must be more than 12. Check: 0.8 × 15 = 12.'
  WHERE section = 'math' AND prompt = 'A cyclist travels 12 miles in 48 minutes. How many miles per hour is this?' AND options = '["12", "15", "18", "20"]'::JSONB;

UPDATE questions SET explanation = 'Work back from the future first. Jake will be 29 in 5 years, so he is 29 − 5 = 24 now, and Lily is half of that, 24 ÷ 2 = 12. Halving 29 straight away gives 14.5, which is why that shortcut fails, and if Lily were 10, Jake would be 20 and only 25 in five years.'
  WHERE section = 'math' AND prompt = 'Jake is twice as old as Lily. In 5 years Jake will be 29. How old is Lily now?' AND options = '["9", "10", "11", "12"]'::JSONB;

UPDATE questions SET explanation = 'Speed is distance divided by time: 5 ÷ 25 = 0.2 km per minute. Test the other choices by multiplying back, since 25 × 0.5 = 12.5 km and 25 × 0.3 = 7.5 km, both well past a 5-km race. Only 0.2 works, because 25 × 0.2 = 5, exactly the distance run.'
  WHERE section = 'math' AND prompt = 'A runner completes a 5-km race in 25 minutes. What is her speed in km per minute?' AND options = '["0.1", "0.2", "0.3", "0.5"]'::JSONB;

UPDATE questions SET explanation = 'Divide to see how many boxfuls fit: 180 ÷ 24 = 7.5. You cannot use half a box, and 7 boxes hold only 7 × 24 = 168 apples, leaving 12 apples with nowhere to go. So round up to 8 boxes, which hold 192. In real situations the leftovers still need a container.'
  WHERE section = 'math' AND prompt = 'A box holds 24 apples. How many boxes are needed to hold 180 apples?' AND options = '["6", "7", "8", "9"]'::JSONB;

UPDATE questions SET explanation = 'Add the two purchases first, then subtract once: 18 + 12 = 30, and 50 − 30 = $20. Choosing $30 reports the amount spent rather than the amount left, and $18 repeats the lunch price. Check the answer: 20 + 18 + 12 = 50, which is what Tom started the day with.'
  WHERE section = 'math' AND prompt = 'Tom had $50. He spent $18 on lunch and $12 on a book. How much does he have left?' AND options = '["$18", "$20", "$22", "$30"]'::JSONB;

UPDATE questions SET explanation = 'Scale the recipe by the same factor as the cookies. Since 36 ÷ 12 = 3, everything triples: 2.5 × 3 = 7.5 cups. Choosing 5 cups only doubles the recipe, which would make 24 cookies, and 6.5 comes from adding rather than multiplying. Flour and cookies have to grow together.'
  WHERE section = 'math' AND prompt = 'A recipe calls for 2.5 cups of flour for 12 cookies. How much flour is needed for 36 cookies?' AND options = '["5 cups", "6.5 cups", "7 cups", "7.5 cups"]'::JSONB;

UPDATE questions SET explanation = 'Split the bill first, then add the tip each person gives: 64 ÷ 2 = $32, and 32 + 5 = $37. Choosing $35 comes from adding a single $5 tip before splitting, and $40 tips more than the problem says. Check: 37 + 37 = 74, which is the $64 bill plus two $5 tips.'
  WHERE section = 'math' AND prompt = 'Two friends split a bill of $64 equally. Each then gives a $5 tip. How much does each person pay in total?' AND options = '["$35", "$37", "$38", "$40"]'::JSONB;

UPDATE questions SET explanation = 'Divide the total by the rate: 3,000 ÷ 60 = 50 minutes. Think in chunks, since 60 liters a minute means 600 liters every 10 minutes, and five of those chunks make 3,000. Choosing 40 min would fill only 2,400 liters, and 60 min would push past the pool to 3,600.'
  WHERE section = 'math' AND prompt = 'A pool holds 3,000 liters. A pump fills it at 60 liters per minute. How long to fill it?' AND options = '["40 min", "45 min", "50 min", "60 min"]'::JSONB;

UPDATE questions SET explanation = 'Two steps here: earn, then spend. Her pay is 12 × 35 = $420, and 420 − 200 = $220. Choosing $240 comes from rounding the hours or the pay upward, and $200 repeats the grocery bill instead of the money left. Check the answer: 220 + 200 = 420, exactly what she earned.'
  WHERE section = 'math' AND prompt = 'Maria earns $12 per hour. She worked 35 hours. She spent $200 on groceries. How much does she have left?' AND options = '["$200", "$220", "$230", "$240"]'::JSONB;

UPDATE questions SET explanation = 'Each gallon covers 30 miles, so ask how many 30s fit inside 210: 210 ÷ 30 = 7 gallons. Count up if that helps: 30, 60, 90, 120, 150, 180, 210, which takes seven steps. Choosing 6 covers only 180 miles, leaving 30 miles unfueled, and 8 gallons would carry the car past the trip.'
  WHERE section = 'math' AND prompt = 'A car uses 1 gallon of gas every 30 miles. How many gallons are needed for a 210-mile trip?' AND options = '["5", "6", "7", "8"]'::JSONB;

UPDATE questions SET explanation = 'Find the discount, then subtract: 15% of 200 is 0.15 × 200 = 30, so the price is 200 − 30 = $170. You can also pay 85% directly, since 0.85 × 200 = 170. Choosing $160 takes 20% off instead, and $175 takes off only 12.5%. A 15% cut should be a bit under a fifth.'
  WHERE section = 'math' AND prompt = 'A $200 TV is on sale for 15% off. What is the sale price?' AND options = '["$160", "$165", "$170", "$175"]'::JSONB;

UPDATE questions SET explanation = 'Dividing by 4 splits the amount into 4 equal parts, so the answer has to be smaller than 2/3. Flip the divisor and multiply: 2/3 × 1/4 = 2/12, which reduces to 1/6. The form 2/12 is the same amount but not in lowest terms, and 8/3 comes from multiplying by 4 instead of dividing.'
  WHERE section = 'math' AND prompt = 'What is 2/3 ÷ 4?' AND options = '["1/4", "1/6", "1/12", "8/3"]'::JSONB;

UPDATE questions SET explanation = 'Turn the score into a fraction of the whole, then into hundredths: 34/40 = 0.85, which is 85%. Another route is that each question is worth 100 ÷ 40 = 2.5 points, and 34 × 2.5 = 85. Choosing 80% would mean 32 correct, and 88% would need 35 correct.'
  WHERE section = 'math' AND prompt = 'A test has 40 questions. A student answers 34 correctly. What percent is correct?' AND options = '["80%", "82%", "85%", "88%"]'::JSONB;

UPDATE questions SET explanation = 'Give both fractions the same denominator: 2/3 = 4/6, so 5/6 + 4/6 = 9/6. Divide top and bottom by 3 to reduce that to 3/2. The form 9/6 names the same number but is not in lowest terms, and 7/9 comes from adding tops and bottoms separately, which is never how fractions add.'
  WHERE section = 'math' AND prompt = 'What is 5/6 + 2/3?' AND options = '["7/9", "7/6", "3/2", "9/6"]'::JSONB;

UPDATE questions SET explanation = 'Percent change compares the change to the starting amount, not the ending one. The increase is 100 − 80 = 20, and 20/80 = 0.25, so 25%. Comparing to the new price gives 20/100 = 20%, which is the trap this question sets. Check: 25% of 80 is 20, and 80 + 20 = 100.'
  WHERE section = 'math' AND prompt = 'A price increased from $80 to $100. What is the percent increase?' AND options = '["20%", "22%", "25%", "30%"]'::JSONB;

UPDATE questions SET explanation = 'A fraction bar means divide, so 3 ÷ 8 = 0.375. You can also scale it, since 3/8 = 375/1000. Choosing 0.3 reads the numerator as tenths, and 0.38 is a rounded version rather than the exact value. Sanity check: 3/8 is a little less than 4/8 = 0.5, and 0.375 fits that.'
  WHERE section = 'math' AND prompt = 'What is 3/8 as a decimal?' AND options = '["0.3", "0.35", "0.375", "0.38"]'::JSONB;

UPDATE questions SET explanation = 'Simplify before converting: 18/24 reduces to 3/4, which is 75 out of 100, so 75%. Choosing 80% would require 19.2 correct out of 24, which is not possible, and 72% does not match any clean fraction here. Check: three quarters of 24 is 18, exactly what the student got right.'
  WHERE section = 'math' AND prompt = 'A student got 18 out of 24 problems correct. What percent is this?' AND options = '["70%", "72%", "75%", "80%"]'::JSONB;

UPDATE questions SET explanation = 'Unlike denominators need a common one, and the smallest number both 5 and 3 divide is 15. Rewrite them: 4/5 = 12/15 and 1/3 = 5/15, so the difference is 7/15. Choosing 3/2 comes from subtracting straight across, which lands above 4/5, and subtraction can never make a number larger.'
  WHERE section = 'math' AND prompt = 'What is 4/5 − 1/3?' AND options = '["3/2", "7/15", "4/15", "7/8"]'::JSONB;

UPDATE questions SET explanation = 'Ten percent of 150 is 15, so 40% is four of those: 4 × 15 = 60. As a decimal, 0.40 × 150 = 60. Choosing 40 repeats the percent number instead of computing the amount, and 75 is half of 150, which would be 50%. A little under half of 150 fits 40% nicely.'
  WHERE section = 'math' AND prompt = 'What is 40% of 150?' AND options = '["40", "55", "60", "75"]'::JSONB;

UPDATE questions SET explanation = 'An increase of 30% makes the result 130% of the original, so 91 = 1.30 × n and n = 91 ÷ 1.30 = 70. Subtracting 30% of 91 instead lands near 65, the tempting wrong answer, but the percent is measured against the starting number, not the new total. Check: 30% of 70 is 21, and 70 + 21 = 91.'
  WHERE section = 'math' AND prompt = 'A number is increased by 30% to get 91. What was the original number?' AND options = '["60", "65", "70", "75"]'::JSONB;

UPDATE questions SET explanation = 'Add the values, then divide by how many there are: 5 + 10 + 15 + 20 + 25 = 75, and 75 ÷ 5 = 15. Because these numbers are evenly spaced, the middle value is also the mean. Choosing 20 or 13 picks a number without balancing the list, and the mean must sit between 5 and 25.'
  WHERE section = 'math' AND prompt = 'Find the mean of: 5, 10, 15, 20, 25.' AND options = '["10", "13", "15", "20"]'::JSONB;

UPDATE questions SET explanation = 'Sort the list first, always: 1, 3, 5, 6, 7, 9, 11. With seven values, the fourth one is the middle, and that is 6. Choosing 7 takes the first number as written, before sorting, and 5 lands one spot early. Three values sit below 6 and three sit above, which is what a median does.'
  WHERE section = 'math' AND prompt = 'Find the median of: 7, 3, 9, 1, 5, 11, 6.' AND options = '["5", "6", "7", "9"]'::JSONB;

UPDATE questions SET explanation = 'The mode is the value that appears most often. Scanning the list, 7 shows up twice while 4, 8, 9, and 12 each appear once, so the mode is 7. Choosing 8 reaches for a middle value, which is the median idea, and 4 is only the smallest. Repetition is all the mode measures.'
  WHERE section = 'math' AND prompt = 'A data set has values: 4, 7, 7, 8, 9, 12. What is the mode?' AND options = '["4", "7", "8", "9"]'::JSONB;

UPDATE questions SET explanation = 'Range is the largest value minus the smallest: 22 − 3 = 19. Scan the whole list for both ends before subtracting, because using 22 − 6 gives 16 and grabbing 18 as the maximum leads to smaller answers too. The range describes the spread of the data, not any single value in it.'
  WHERE section = 'math' AND prompt = 'Find the range of: 14, 6, 22, 9, 18, 3.' AND options = '["16", "18", "19", "20"]'::JSONB;

UPDATE questions SET explanation = 'The mean is the total shared out equally, so add everything first and then divide by how many numbers there are. 72 + 85 + 90 + 68 + 80 = 395, and 395 ÷ 5 = 79. Answering 80 gives the median instead: once the scores are sorted as 68, 72, 80, 85, 90, the value 80 sits in the middle, but the middle value is not the average.'
  WHERE section = 'math' AND prompt = 'Five quiz scores are 72, 85, 90, 68, 80. What is the mean?' AND options = '["77", "79", "80", "83"]'::JSONB;

UPDATE questions SET explanation = 'The least common multiple has to contain every prime factor at its highest power. 12 = 2² × 3, 15 = 3 × 5, and 20 = 2² × 5, so you need two 2s, one 3 and one 5: 2² × 3 × 5 = 60. The value 120 is a common multiple but not the least one, and 30 fails because 30 ÷ 12 is not a whole number.'
  WHERE section = 'math' AND prompt = 'What is the LCM of 12, 15, and 20?' AND options = '["30", "45", "60", "120"]'::JSONB;

UPDATE questions SET explanation = 'Work the parentheses first, then the power, then multiply and divide before adding. 4² = 16, so 16 − 6 = 10, then 10 ÷ 5 = 2 and 3 × 2 = 6. Finally 2 + 6 = 8. Answering 6 means you finished the multiplying and forgot the 2 that is waiting at the front, and 7 or 9 come from adding the 2 before the multiplication.'
  WHERE section = 'math' AND prompt = 'Evaluate: 2 + 3 × (4² − 6) ÷ 5' AND options = '["6", "7", "8", "9"]'::JSONB;

UPDATE questions SET explanation = 'The greatest common factor uses only the primes all three numbers share, each at its lowest power. 84 = 2² × 3 × 7, 126 = 2 × 3² × 7, and 210 = 2 × 3 × 5 × 7, so the shared part is 2 × 3 × 7 = 42. The numbers 14 and 21 do divide all three, but they are not the greatest, and 63 is not even a factor of 84.'
  WHERE section = 'math' AND prompt = 'What is the GCF of 84, 126, and 210?' AND options = '["14", "21", "42", "63"]'::JSONB;

UPDATE questions SET explanation = 'Absolute value strips the sign off a number, so each bar turns its contents positive. That leaves 14 − 6 + 3, which is 8 + 3 = 11. Answering 23 makes every term positive and adds them all, ignoring the subtraction sign that sits outside the bars. Answering 5 subtracts the 3 instead of adding it.'
  WHERE section = 'math' AND prompt = 'Evaluate: |−14| − |−6| + |−3|' AND options = '["5", "11", "17", "23"]'::JSONB;

UPDATE questions SET explanation = 'Powers come first, then multiplication, and subtraction happens last. 3³ = 27 and 2² = 4, so 27 × 4 = 108. Inside the parentheses 6 − 2 = 4, and 4 × 4 = 16. Then 108 − 16 = 92. The near misses 88, 96 and 100 all come from slipping in one of those two products, so if you land on one, redo 27 × 4 and 4 × 4.'
  WHERE section = 'math' AND prompt = 'Evaluate: 3³ × 2² − 4 × (6 − 2)' AND options = '["88", "92", "96", "100"]'::JSONB;

UPDATE questions SET explanation = 'A remainder is what is left over after you pull out as many whole 15s as possible. 15 × 16 = 240, and 253 − 240 = 13. Because 13 is smaller than 15, no further group of 15 fits, so 13 is the remainder. Answers such as 8 or 10 come from stopping a group early or subtracting from a multiple that is not 240.'
  WHERE section = 'math' AND prompt = 'What is the remainder when 253 is divided by 15?' AND options = '["7", "8", "10", "13"]'::JSONB;

UPDATE questions SET explanation = 'Handle both parentheses first, then multiply and divide from left to right. 2³ = 8 and 3² = 9, so the first bracket is 17, and 4 − 1 = 3. Then 17 × 3 = 51 and 51 ÷ 3 = 17. Answering 51 stops before the division. Answering 15 comes from reading 2³ as 2 × 3 = 6, which makes the bracket 15 instead of 17.'
  WHERE section = 'math' AND prompt = 'Evaluate: (2³ + 3²) × (4 − 1) ÷ 3' AND options = '["15", "17", "21", "51"]'::JSONB;

UPDATE questions SET explanation = 'Build the least common multiple from the highest power of each prime you see. 8 = 2³, 12 = 2² × 3, and 18 = 2 × 3², so you need 2³ and 3²: 8 × 9 = 72. The value 144 is a common multiple but twice as big as it needs to be. 36 is not divisible by 8, and 48 is not divisible by 18, so neither works for all three.'
  WHERE section = 'math' AND prompt = 'What is the LCM of 8, 12, and 18?' AND options = '["36", "48", "72", "144"]'::JSONB;

UPDATE questions SET explanation = 'Factorials share most of their factors, so write them out and cancel. 5! = 5 × 4 × 3 × 2 × 1 and 3! = 3 × 2 × 1, so the 3 × 2 × 1 cancels and only 5 × 4 = 20 remains. Dividing works too: 120 ÷ 6 = 20. Answering 15 adds 5 + 4 + 3 + 2 + 1 instead of multiplying, and 10 cancels away too much.'
  WHERE section = 'math' AND prompt = 'Evaluate: 5! ÷ 3! (where n! means n-factorial)' AND options = '["10", "15", "20", "25"]'::JSONB;

UPDATE questions SET explanation = 'A number divisible by both 6 and 8 must be a multiple of their least common multiple, which is 24. Since 48 = 24 × 2, it works: 48 ÷ 6 = 8 and 48 ÷ 8 = 6. The numbers 42 and 54 pass the 6 test but fail the 8 test, and 64 passes the 8 test but fails the 6 test. Each of those checks only half of what the question asks.'
  WHERE section = 'math' AND prompt = 'Which of these is divisible by both 6 and 8?' AND options = '["42", "48", "54", "64"]'::JSONB;

UPDATE questions SET explanation = 'A power of 2 just means repeated doubling, so count the doublings: 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024. That is ten of them, so 2¹⁰ = 1024. Stopping one doubling early gives 512 and stopping two early gives 256, which is the most common slip here. The value 1000 is close, but powers of 2 never land on round thousands.'
  WHERE section = 'math' AND prompt = 'What is 2¹⁰?' AND options = '["256", "512", "1000", "1024"]'::JSONB;

UPDATE questions SET explanation = 'The square root of a product equals the product of the roots, so you can split it: √25 × √36 = 5 × 6 = 30. Multiplying first works too, since 25 × 36 = 900 and √900 = 30. Answering 61 comes from adding 25 and 36 under the root instead of multiplying them, and 25 or 36 means only one of the two factors got a root taken.'
  WHERE section = 'math' AND prompt = 'Evaluate: √(25 × 36)' AND options = '["25", "30", "36", "61"]'::JSONB;

UPDATE questions SET explanation = 'You do not need the giant number, only its remainder pattern. Since 5 = 4 + 1, every 5 you multiply in leaves a remainder of 1, and 1 multiplied by itself any number of times is still 1. Try small cases: 5 ÷ 4 leaves 1, 25 ÷ 4 leaves 1, and 125 ÷ 4 leaves 1. Answering 0 would require 5¹⁰⁰ to be even, but every power of 5 is odd.'
  WHERE section = 'math' AND prompt = 'What is the remainder when 5¹⁰⁰ is divided by 4?' AND options = '["0", "1", "2", "3"]'::JSONB;

UPDATE questions SET explanation = 'Start in the innermost parentheses and work outward, saving the addition of 4 for last. 5 + 1 = 6, then 2 × 6 = 12 and 12 − 4 = 8. Now 3 × 8 = 24, and 4 + 24 = 28. Answering 32 comes from multiplying the bracket by the 4 instead of the 3, and adding 4 + 3 first would give 7 × 8 = 56, which is not even offered.'
  WHERE section = 'math' AND prompt = 'Evaluate: 4 + 3 × [2 × (5 + 1) − 4]' AND options = '["22", "28", "32", "40"]'::JSONB;

UPDATE questions SET explanation = 'With one equation already solved for a variable, substitution is fastest. From x − y = 5 you get x = y + 5. Putting that into 3x + 2y = 20 gives 3y + 15 + 2y = 20, so 5y = 5 and y = 1, which makes x = 6. Check: 18 + 2 = 20. Answering 5 grabs the difference x − y from the second equation rather than x itself.'
  WHERE section = 'math' AND prompt = 'Solve the system: 3x + 2y = 20 and x − y = 5. What is x?' AND options = '["5", "6", "7", "8"]'::JSONB;

UPDATE questions SET explanation = 'Solve one equation for a variable, then substitute. From x + 2y = 11 you get x = 11 − 2y, and 3(11 − 2y) − y = 5 becomes 33 − 7y = 5, so 7y = 28 and y = 4. Then x = 11 − 8 = 3, and 3(3) − 4 = 5 checks out. Answering 3 reports x, but the question asks for y.'
  WHERE section = 'math' AND prompt = 'Solve the system: x + 2y = 11 and 3x − y = 5. What is y?' AND options = '["2", "3", "4", "5"]'::JSONB;

UPDATE questions SET explanation = 'Consecutive integers are evenly spaced, so the middle one is exactly their average. That means the middle number is 102 ÷ 3 = 34, and the three integers are 33, 34 and 35. Answering 33 gives the smallest of the three and 35 gives the largest. Both are in the set, but only 34 sits in the middle.'
  WHERE section = 'math' AND prompt = 'The sum of three consecutive integers is 102. What is the middle integer?' AND options = '["32", "33", "34", "35"]'::JSONB;

UPDATE questions SET explanation = 'To factor x² − 7x + 12 you need two numbers that multiply to 12 and add to 7. The pair 3 and 4 does both, so (x − 3)(x − 4) = 0 and x is 3 or 4. The pair 2 and 6 multiplies to 12 but adds to 8, and 1 and 12 multiplies to 12 but adds to 13, so neither rebuilds the −7x term. 4 and 6 multiply to 24, not 12.'
  WHERE section = 'math' AND prompt = 'If x² − 7x + 12 = 0, what are the values of x?' AND options = '["2 and 6", "3 and 4", "1 and 12", "4 and 6"]'::JSONB;

UPDATE questions SET explanation = 'Name the unknowns before you write anything. Let b be the first number, so the other is 2b − 5. Their sum gives (2b − 5) + b = 22, so 3b = 27 and b = 9, making the other number 2(9) − 5 = 13. Check: 9 + 13 = 22. Answering 9 stops at the number you solved for first, which is the smaller of the two.'
  WHERE section = 'math' AND prompt = 'A number is 5 less than twice another. Their sum is 22. What is the larger number?' AND options = '["9", "11", "13", "15"]'::JSONB;

UPDATE questions SET explanation = 'Use the simpler equation to isolate a variable. From x − y = 1 you get x = y + 1, and substituting into 3x + 2y = 18 gives 3y + 3 + 2y = 18, so 5y = 15 and y = 3. Then x = 4. Check: 12 + 6 = 18. Answering 3 gives y, the value found on the way, not the x that was asked for.'
  WHERE section = 'math' AND prompt = 'Solve the system: 3x + 2y = 18 and x − y = 1. What is x?' AND options = '["3", "4", "5", "6"]'::JSONB;

UPDATE questions SET explanation = 'You need two numbers that multiply to 6 and add to 5, and both signs in the equation are positive, so both numbers must be negative once you solve. Factoring gives (x + 2)(x + 3) = 0, so x = −2 or x = −3. Testing 2 and 3 shows why they fail: 4 + 10 + 6 = 20, not 0. The factors are +2 and +3, but the roots flip sign.'
  WHERE section = 'math' AND prompt = 'If x² + 5x + 6 = 0, what are the values of x?' AND options = '["−2 and −3", "2 and 3", "1 and 6", "−1 and −6"]'::JSONB;

UPDATE questions SET explanation = 'Let n be the smallest, so the four numbers are n, n + 1, n + 2 and n + 3. Their sum is 4n + 6 = 74, so 4n = 68 and n = 17. The four integers are 17, 18, 19 and 20, which really do add to 74. Answering 18 or 19 picks a number that is in the set but is not the smallest, so check which one the question wants.'
  WHERE section = 'math' AND prompt = 'The sum of four consecutive integers is 74. What is the smallest?' AND options = '["16", "17", "18", "19"]'::JSONB;

UPDATE questions SET explanation = 'Solve the equation that isolates a variable most easily. From 2x − y = 3 you get y = 2x − 3, and substituting into x + 2y = 14 gives x + 4x − 6 = 14, so 5x = 20 and x = 4. Then y = 2(4) − 3 = 5. Check: 4 + 10 = 14. Answering 4 reports x, the value found first, instead of y.'
  WHERE section = 'math' AND prompt = 'Solve the system: 2x − y = 3 and x + 2y = 14. What is y?' AND options = '["4", "5", "6", "7"]'::JSONB;

UPDATE questions SET explanation = 'Both people age at the same rate, so add 12 to each age. Let s be the son, so the father is 3s. Then 3s + 12 = 2(s + 12) gives 3s + 12 = 2s + 24 and s = 12. Check: 36 now, and in 12 years 48 is twice 24. Answering 10 fails that check, since 42 is not twice 22.'
  WHERE section = 'math' AND prompt = 'A father is 3 times as old as his son. In 12 years, he will be twice as old. How old is the son now?' AND options = '["10", "11", "12", "14"]'::JSONB;

UPDATE questions SET explanation = 'The Pythagorean theorem adds the squares of the legs, not the legs themselves. c² = 7² + 24² = 49 + 576 = 625, and √625 = 25. Answering 31 adds 7 and 24 directly, but the straight path across is always shorter than going along both legs. The hypotenuse also has to be longer than 24, which rules out 23.'
  WHERE section = 'math' AND prompt = 'A right triangle has legs 7 and 24. What is the hypotenuse?' AND options = '["23", "25", "26", "31"]'::JSONB;

UPDATE questions SET explanation = 'A circle inscribed in a square touches all four sides, so its diameter equals the side, 10, making the radius 5. Area = 3.14 × 5² = 3.14 × 25 = 78.5. Answering 314 uses 10 as the radius instead of the diameter, 100 gives the square''s area rather than the circle''s, and 62.8 is a circumference, which is a length and not an area.'
  WHERE section = 'math' AND prompt = 'A circle is inscribed in a square with side 10. What is the area of the circle? (Use π ≈ 3.14)' AND options = '["62.8", "78.5", "100", "314"]'::JSONB;

UPDATE questions SET explanation = 'Volume of a box is length times width times height, so divide the volume by the two dimensions you already know. 10 × 6 = 60, and 360 ÷ 60 = 6, so the height is 6 cm. Check by multiplying back: 10 × 6 × 6 = 360. Trying the other choices fails that check, since 10 × 6 × 5 = 300 and 10 × 6 × 8 = 480, neither of which is 360.'
  WHERE section = 'math' AND prompt = 'A rectangular prism has volume 360 cm³. Its length is 10 and width is 6. What is its height?' AND options = '["4", "5", "6", "8"]'::JSONB;

UPDATE questions SET explanation = 'Two of these vertices sit on the axes, so the legs are the base and height: 6 along the x-axis and 8 up the y-axis. Area = (1/2) × 6 × 8 = 24. Answering 48 is 6 × 8 with the halving left out, and that is the rectangle around the triangle, which is exactly twice as big. A triangle is always half of its surrounding rectangle.'
  WHERE section = 'math' AND prompt = 'What is the area of a triangle with vertices at (0,0), (6,0), and (0,8)?' AND options = '["20", "24", "28", "48"]'::JSONB;

UPDATE questions SET explanation = 'An exterior angle and the interior angle beside it form a straight line. The third interior angle is 180 − 48 − 67 = 65°, so the exterior angle is 180 − 65 = 115°. Answering 65° gives the interior angle instead of the exterior one. A useful shortcut: an exterior angle equals the two far interior angles added, and 48 + 67 = 115.'
  WHERE section = 'math' AND prompt = 'Two angles of a triangle are 48° and 67°. What is the exterior angle at the third vertex?' AND options = '["65°", "90°", "115°", "180°"]'::JSONB;

UPDATE questions SET explanation = 'Rearrange the Pythagorean theorem: the missing leg squared is the hypotenuse squared minus the known leg squared. 26² − 10² = 676 − 100 = 576, and √576 = 24. Answering 16 subtracts the lengths directly, 26 − 10, but it is the squares that subtract, not the sides. Answering 28 is impossible, since no leg can be longer than the hypotenuse.'
  WHERE section = 'math' AND prompt = 'A right triangle has hypotenuse 26 and one leg 10. What is the other leg?' AND options = '["16", "20", "24", "28"]'::JSONB;

UPDATE questions SET explanation = 'Work the area formula backwards. Area = πr², so 200.96 = 3.14 × r², which gives r² = 64 and r = 8. Always undo the multiplication before undoing the square. Checking the other choices shows why they fail: a radius of 4 gives 3.14 × 16 = 50.24 and a radius of 7 gives about 153.9, both far below 200.96.'
  WHERE section = 'math' AND prompt = 'A circle has area 200.96 square cm. What is its radius? (Use π ≈ 3.14)' AND options = '["4", "6", "7", "8"]'::JSONB;

UPDATE questions SET explanation = 'A cylinder is a circle stacked to a height, so volume is the circle''s area times the height. The circle''s area is 3.14 × 3² = 28.26, and 28.26 × 10 = 282.6. Answering 94.2 comes from using 3 instead of 3² and computing 3.14 × 3 × 10. Answering 188.4 is 2πrh, the curved side surface, which measures area rather than volume.'
  WHERE section = 'math' AND prompt = 'A cylinder has radius 3 and height 10. What is its volume? (Use π ≈ 3.14)' AND options = '["94.2", "188.4", "282.6", "565.2"]'::JSONB;

UPDATE questions SET explanation = 'When a square is inscribed in a circle, the square''s diagonal is the circle''s diameter, 2 × 5 = 10. For any square, area is diagonal² ÷ 2, so the area is 100 ÷ 2 = 50. Answering 100 treats 10 as a side rather than the diagonal, and 78.5 is the circle''s area. The square must be smaller than the circle, so 78.5 was never possible.'
  WHERE section = 'math' AND prompt = 'A square is inscribed in a circle with radius 5. What is the area of the square?' AND options = '["25", "50", "78.5", "100"]'::JSONB;

UPDATE questions SET explanation = 'Co-interior angles sit on the same side of the transversal and between the two parallel lines, and together they make a straight line, so they add to 180°. That gives 180 − 65 = 115°. Answering 65° assumes the two angles are equal, which is true for alternate and corresponding angles but not for same-side ones. Equal angles here would only happen if both were 90°.'
  WHERE section = 'math' AND prompt = 'Two parallel lines are cut by a transversal. One co-interior angle is 65°. What is the other co-interior angle?' AND options = '["65°", "90°", "115°", "180°"]'::JSONB;

UPDATE questions SET explanation = 'Square the legs, add, then take the root. 9² + 40² = 81 + 1600 = 1681, and √1681 = 41. Answering 49 adds the legs as 9 + 40, but the direct path across a triangle is shorter than traveling both legs. A quick sense check: the hypotenuse must be a little more than 40, so 41 fits and 49 is far too long.'
  WHERE section = 'math' AND prompt = 'A right triangle with legs 9 and 40 has what hypotenuse?' AND options = '["41", "42", "43", "49"]'::JSONB;

UPDATE questions SET explanation = 'Rates combine, not times, and a drain counts as a negative rate. In one hour X adds 1/8 of a tank while Y removes 1/12, so the net is 3/24 − 2/24 = 1/24 per hour, meaning 24 hours. Answering 20 hours adds the two times, which works only if they took turns. Check: in 24 hours X fills 3 tanks and Y drains 2, leaving exactly 1.'
  WHERE section = 'math' AND prompt = 'Pipe X fills a tank in 8 hours; Pipe Y drains it in 12 hours. Both open together — how long to fill the tank?' AND options = '["16 hours", "20 hours", "24 hours", "32 hours"]'::JSONB;

UPDATE questions SET explanation = 'A ratio of 3:5 splits the marbles into 3 + 5 = 8 equal parts, so each part is 40 ÷ 8 = 5 marbles, and red gets 3 parts: 15. Check: 15 red plus 25 blue is 40, and 15:25 reduces to 3:5. Answering 24 gives the blue count, and 12 comes from treating red as 3 out of 10 rather than 3 out of 8.'
  WHERE section = 'math' AND prompt = 'A jar has red and blue marbles in ratio 3:5. If there are 40 marbles total, how many are red?' AND options = '["12", "15", "16", "24"]'::JSONB;

UPDATE questions SET explanation = 'Times do not subtract, but rates do. In one hour the pair completes 1/6 of the job and the 10-hour worker completes 1/10, so the other worker does 1/6 − 1/10 = 5/30 − 3/30 = 1/15 each hour, which means 15 hours alone. Answering 12 hours doubles the 6, which would fit only if both workers were identical. Check: in 30 hours one finishes 3 jobs and the other 2, so 5 jobs in 30 hours is one every 6.'
  WHERE section = 'math' AND prompt = 'Two workers together finish a job in 6 hours. One alone takes 10 hours. How long does the other take alone?' AND options = '["12 hours", "15 hours", "18 hours", "20 hours"]'::JSONB;

UPDATE questions SET explanation = 'Adding pure acid raises the acid amount and the total at the same time, so both parts of the fraction change. There are 0.40 × 30 = 12 liters of acid, and (12 + x)/(30 + x) = 0.50 gives 12 + x = 15 + 0.5x, so x = 6. A tempting shortcut says half of 30 is 15, so add 3, but that ignores the growing total. Answering 10 overshoots: 22/40 is 55%.'
  WHERE section = 'math' AND prompt = 'A 30-liter solution is 40% acid. How many liters of pure acid must be added to make it 50% acid?' AND options = '["4", "6", "8", "10"]'::JSONB;

UPDATE questions SET explanation = 'Going upstream the current works against the boat and downstream it helps, so the two speeds differ by twice the current. Upstream is 24 ÷ 3 = 8 mph and downstream is 24 ÷ 2 = 12 mph. The gap of 4 mph is double the current, so the current is 2 mph. Answering 4 forgets to halve that gap. Check: a boat at 10 mph gives 8 upstream and 12 downstream.'
  WHERE section = 'math' AND prompt = 'A boat travels 24 miles upstream in 3 hours and the same distance downstream in 2 hours. What is the speed of the current?' AND options = '["1 mph", "2 mph", "3 mph", "4 mph"]'::JSONB;

UPDATE questions SET explanation = 'Add the rates, then flip. In one hour A paints 1/5 of the fence and B paints 1/7, so together they do 7/35 + 5/35 = 12/35 per hour, and the time is 35/12, about 2.9 hours. Averaging the two times to get 6 hours is the classic error, since together they must beat A''s own 5 hours. The answer also has to be above 2.5 hours, which is what two copies of A would take.'
  WHERE section = 'math' AND prompt = 'Person A can paint a fence in 5 hours. Person B takes 7 hours. Working together, how long? (Round to nearest tenth)' AND options = '["2.5 hours", "2.9 hours", "3.1 hours", "3.5 hours"]'::JSONB;

UPDATE questions SET explanation = 'In a mixture, the blend price lands between the two ingredient prices, closer to whichever one you use more of. Since $6 sits exactly halfway between $4 and $8, the mix is half cashews. Algebraically, 8c + 4(1 − c) = 6 gives 4c = 2 and c = 1/2. Answering 2/3 would push the price up to about $6.67, and 1/3 would drop it to about $5.33.'
  WHERE section = 'math' AND prompt = 'A mixture of nuts costs $6/lb. Cashews cost $8/lb and peanuts cost $4/lb. What fraction of the mix is cashews?' AND options = '["1/4", "1/3", "1/2", "2/3"]'::JSONB;

UPDATE questions SET explanation = 'Percent change is always measured against what you started with, not what you ended with. The drop is $250 − $200 = $50, and 50 ÷ 250 = 0.20, so the decrease is 20%. Answering 25% divides by the new price, 50 ÷ 200, which is the most common trap here. That 25% is actually the increase needed to climb from $200 back up to $250.'
  WHERE section = 'math' AND prompt = 'A price dropped from $250 to $200. What is the percent decrease?' AND options = '["15%", "20%", "25%", "30%"]'::JSONB;

UPDATE questions SET explanation = 'A 20% increase means the new price is 1.20 times the old one, so divide rather than subtract. 156 ÷ 1.20 = 130. Check: 20% of 130 is 26, and 130 + 26 = 156. Answering $125 comes from taking 20% off the $156 instead, which gives 124.8, but the increase was measured against the original price, not the final one.'
  WHERE section = 'math' AND prompt = 'After a 20% increase, a price is $156. What was the original price?' AND options = '["$120", "$125", "$130", "$140"]'::JSONB;

UPDATE questions SET explanation = 'Dividing by a fraction means multiplying by its reciprocal, so flip the second fraction: 2/7 ÷ 4/21 becomes 2/7 × 21/4. Cancel before multiplying, since 7 goes into 21 three times and 2 goes into 4 twice, leaving 3/2. Answering 8/147 multiplies straight across without flipping, and 7/6 flips the wrong fraction.'
  WHERE section = 'math' AND prompt = 'What is 2/7 ÷ 4/21?' AND options = '["3/2", "3", "8/147", "7/6"]'::JSONB;

UPDATE questions SET explanation = 'Successive discounts multiply, they do not add, because the second one is taken off an already smaller price. Paying 80% and then 90% of that leaves 0.80 × 0.90 = 0.72, so 28% came off. Answering 30% adds 20 and 10, the usual trap. Check on $100: it falls to $80, then 10% of $80 is only $8, landing at $72.'
  WHERE section = 'math' AND prompt = 'A store offers successive discounts of 20% and 10%. What is the effective percent discount on the original price?' AND options = '["25%", "28%", "30%", "32%"]'::JSONB;

UPDATE questions SET explanation = 'Multiplication and division rank equally, so go left to right. 5/6 × 3/4 = 15/24, which reduces to 5/8. Then 5/8 ÷ 5/8 = 1, because anything divided by itself is 1. Spotting that the first product matches the divisor saves all the arithmetic. Answering 5/4 or 3/2 generally means the reciprocal was applied to the wrong fraction.'
  WHERE section = 'math' AND prompt = 'What is 5/6 × 3/4 ÷ 5/8?' AND options = '["1/2", "1", "5/4", "3/2"]'::JSONB;

UPDATE questions SET explanation = 'Percent increases multiply rather than add, because the second increase applies to the larger amount. Growing by 10% twice means 1.10 × 1.10 = 1.21, an overall rise of 21%. Answering 20% adds the two percents and misses the growth on the growth. Check on $100: it rises to $110, and 10% of $110 is $11, bringing the total to $121.'
  WHERE section = 'math' AND prompt = 'After two successive 10% increases, what is the overall percent increase?' AND options = '["20%", "21%", "22%", "25%"]'::JSONB;

UPDATE questions SET explanation = 'The mean tells you the total, so work backwards from it. Six scores averaging 82 must add to 82 × 6 = 492. The five known scores total 70 + 75 + 80 + 85 + 90 = 400, so x = 92. Check: 492 ÷ 6 = 82. Answering 94, 96 or 98 would push the total past 492 and lift the mean above 82, so those are all too large.'
  WHERE section = 'math' AND prompt = 'Six test scores are 70, 75, 80, 85, 90, and x. The mean is 82. What is x?' AND options = '["92", "94", "96", "98"]'::JSONB;

UPDATE questions SET explanation = 'Turn the mean into a total. Five scores averaging 82 must sum to 5 × 82 = 410, and the four known scores add to 72 + 85 + 90 + 78 = 325, so the fifth is 410 − 325 = 85. A quick sense check rules out 80 right away: the four known scores average 81.25, so the fifth score has to be above 82 to pull the average up.'
  WHERE section = 'math' AND prompt = 'Four test scores are 72, 85, 90, and 78. The mean of all five scores is 82. What is the fifth score?' AND options = '["80", "83", "85", "88"]'::JSONB;

UPDATE questions SET explanation = 'An outlier drags the mean toward itself but barely moves the median, which only cares about position. The mean here is 150 ÷ 5 = 30, while the median is the middle value, 15. So the mean is greater. Saying the median is greater than the mean reverses the effect of the 93, and saying the mean equals the median ignores how far that one large value pulls the total.'
  WHERE section = 'math' AND prompt = 'A data set has five values: 12, 14, 15, 16, and 93. Which statement is true?' AND options = '["The mean equals the median.", "The mean is greater than the median.", "The median is greater than the mean.", "The mean and median are both 15."]'::JSONB;

UPDATE questions SET explanation = 'A weighted average multiplies each score by its share of the grade, so the heavier test counts more. That gives (0.40 × 68) + (0.60 × 88) = 27.2 + 52.8 = 80. Answering 78 takes the plain average of 68 and 88, ignoring the weights. Since the 88 carries more weight, the answer must sit above 78 and below 88, and 80 fits.'
  WHERE section = 'math' AND prompt = 'A student scored 68 on a test worth 40% of the grade and 88 on a test worth 60% of the grade. What is the weighted average?' AND options = '["76", "78", "80", "82"]'::JSONB;

UPDATE questions SET explanation = 'Range is just the largest value minus the smallest, so rearranging gives the smallest directly: 89 − 35 = 54. The other four values are all between 54 and 89, so they do not affect the range. Answering 52 would make the range 37 and answering 56 would make it 33, so neither matches the stated range of 35.'
  WHERE section = 'math' AND prompt = 'A set of five values has a range of 35. The largest value is 89. Four of the five values are 62, 71, 78, and 89. What must the fifth value be?' AND options = '["52", "54", "56", "58"]'::JSONB;

UPDATE questions SET explanation = 'The mode is whatever appears most often, and there can be more than one. Counting: 3 shows up three times, 5 shows up three times, while 7 and 9 each appear only twice. Since 3 and 5 tie for the top spot, both are modes and the set is bimodal. Choosing 3 only or 5 only assumes a data set is limited to a single mode.'
  WHERE section = 'math' AND prompt = 'A data set contains: 3, 5, 7, 3, 9, 5, 3, 7, 5, 9. What is the mode?' AND options = '["3 only", "5 only", "3 and 5", "7 and 9"]'::JSONB;

UPDATE questions SET explanation = 'Convert each mean into a total. Twenty students averaging 74 have a sum of 1480, and 21 students averaging 75 have a sum of 1575, so the makeup score is 1575 − 1480 = 95. Notice the score has to be far above 74 to drag 21 people up a whole point, which is why 85 and 90 fall short: 90 would only lift the mean to about 74.8.'
  WHERE section = 'math' AND prompt = 'A class of 20 students has a mean test score of 74. One absent student later takes a makeup test. After adding this score, the class mean rises to 75. What did the student score on the makeup test?' AND options = '["85", "90", "95", "100"]'::JSONB;

UPDATE questions SET explanation = 'You cannot average two averages when the groups are different sizes. Instead find both totals: (15 × 80) + (10 × 70) = 1200 + 700 = 1900, and 1900 ÷ 25 = 76. Answering 75 takes the plain average of 80 and 70, which is the trap. Since Group A has more students, the combined mean must lean toward 80, so anything at or below 75 is too low.'
  WHERE section = 'math' AND prompt = 'Group A has 15 students with a mean score of 80. Group B has 10 students with a mean score of 70. What is the mean score of all 25 students combined?' AND options = '["74", "75", "76", "77"]'::JSONB;

UPDATE questions SET explanation = 'The mode is by definition a value that appears in the data, and more often than any other, so 7 has to be there at least twice. The mean of 10 only fixes the total at 50, and the median of 9 only fixes the third value once the numbers are sorted. Neither of those forces 5, 10 or 15 to appear, even though 10 is the mean itself.'
  WHERE section = 'math' AND prompt = 'A data set of five values has a mean of 10, a median of 9, and a mode of 7. Which value must appear in the data set?' AND options = '["5", "7", "10", "15"]'::JSONB;

UPDATE questions SET explanation = 'A wrong score changes the total, and the mean shifts by that error spread over all the values. The original sum is 10 × 82 = 820, and the score was 30 too high, so the true sum is 790 and the mean is 79. Notice 30 spread over 10 scores is exactly 3 less per score: 82 − 3 = 79. Answering 77 or 78 assumes a bigger error than 30.'
  WHERE section = 'math' AND prompt = 'A teacher calculated the mean of 10 quiz scores and got 82. She then discovered she had recorded one score as 90 when it should have been 60. What is the correct mean?' AND options = '["77", "78", "79", "80"]'::JSONB;

UPDATE questions SET explanation = 'The new value has to cover its own place plus lift everyone else. The old sum is 8 × 50 = 400 and the new sum is 9 × 52 = 468, so the ninth value is 68, which is 18 above the original mean of 50. Above by 16 counts only the 2 points each of the eight old values gained and forgets the ninth value''s own 2. Above by 20 overshoots.'
  WHERE section = 'math' AND prompt = 'A data set of 8 values has a mean of 50. A ninth value is added and the mean rises to 52. How much greater than the original mean is the ninth value?' AND options = '["Above by 14", "Above by 16", "Above by 18", "Above by 20"]'::JSONB;

UPDATE questions SET explanation = 'Distance on a grid is the hypotenuse of a right triangle. Going from (1, 1) to (4, 5) means 3 across and 4 up, so the distance is √(3² + 4²) = √25 = 5. Answering 7 adds 3 and 4, but that is the walking distance along the grid, not the straight line. The direct route is always shorter than the two legs combined.'
  WHERE section = 'math' AND prompt = 'What is the distance between the points (1, 1) and (4, 5)?' AND options = '["3", "4", "5", "7"]'::JSONB;

UPDATE questions SET explanation = 'A midpoint is the average of the endpoints, so add each pair of coordinates and halve. For x: (2 + 8) ÷ 2 = 5. For y: (6 + 2) ÷ 2 = 4. The midpoint is (5, 4). Answering (6, 4) subtracts the x-values instead of averaging them, and (4, 4) or (5, 5) mixes up which coordinate belongs where. Notice 5 sits halfway between 2 and 8.'
  WHERE section = 'math' AND prompt = 'Point A is at (2, 6) and Point B is at (8, 2). What are the coordinates of the midpoint of segment AB?' AND options = '["(4, 4)", "(5, 4)", "(6, 4)", "(5, 5)"]'::JSONB;

UPDATE questions SET explanation = 'Perimeter needs all three sides, so find the missing one first. Two vertices sit on the axes, giving legs of 6 and 8, and the hypotenuse is √(36 + 64) = √100 = 10. Then 6 + 8 + 10 = 24. Answering 22 uses 8 twice, as if the slanted side matched the vertical leg, but the hypotenuse must be the longest side.'
  WHERE section = 'math' AND prompt = 'A triangle has vertices at (0, 0), (6, 0), and (0, 8). What is the perimeter?' AND options = '["20", "22", "24", "26"]'::JSONB;

UPDATE questions SET explanation = 'Inside means the distance from the center is less than the radius, so measure each one. From (3, 3) to (7, 3) is 4 units, and 4 is less than 5, so that point is inside. The points (8, 3) and (0, 7) are both exactly 5 away, which puts them on the circle rather than inside it, and (3, 9) is 6 away, so it sits outside.'
  WHERE section = 'math' AND prompt = 'A circle has center (3, 3) and radius 5. Which of the following points lies INSIDE the circle?' AND options = '["(7, 3)", "(3, 9)", "(8, 3)", "(0, 7)"]'::JSONB;

UPDATE questions SET explanation = 'Find each area, then subtract. The diagonal of the square is also the circle''s diameter, so the radius is 5 and the circle''s area is 3.14 × 25 = 78.5. A square''s area is its diagonal squared, halved: 100 ÷ 2 = 50. The leftover ring is 78.5 − 50 = 28.5. The four choices sit close together, so keep 78.5 and 50 exact; rounding early slides you to 26.5 or 30.5.'
  WHERE section = 'math' AND prompt = 'A square has a diagonal of 10 units and is inscribed in a circle (all four corners touch the circle). What is the approximate area of the region inside the circle but outside the square? (Use π ≈ 3.14)' AND options = '["24.5", "26.5", "28.5", "30.5"]'::JSONB;

UPDATE questions SET explanation = 'A ring is the big circle with the small one removed, so subtract the areas, not the radii. That gives 3.14 × (8² − 5²) = 3.14 × (64 − 25) = 3.14 × 39, which is about 122.5. Answering 150.7 matches an inner radius of 4 rather than 5, and subtracting the radii first to get 3.14 × 3² = 28.3 is not even offered, a clue that squaring comes first.'
  WHERE section = 'math' AND prompt = 'A circular ring is formed by two concentric circles. The outer radius is 8 and the inner radius is 5. What is the area of the ring? (Use π ≈ 3.14)' AND options = '["98.0", "110.0", "122.5", "150.7"]'::JSONB;

UPDATE questions SET explanation = 'Split a composite shape into pieces you already know. The rectangle is 12 × 6 = 72. The semicircle spans the 6-unit end, so its radius is 3 and its area is (3.14 × 9) ÷ 2 = 14.13. Total: about 86.1. Forgetting to halve the circle gives 100.3, which sails past 90.1, and using 6 as the radius instead of the diameter overshoots by even more.'
  WHERE section = 'math' AND prompt = 'A composite shape is made of a rectangle 12 units long and 6 units wide, with a semicircle attached to one of the shorter ends. The semicircle''s diameter equals the width of the rectangle. What is the total area? (Use π ≈ 3.14)' AND options = '["80.1", "83.1", "86.1", "90.1"]'::JSONB;

UPDATE questions SET explanation = 'Remaining area means the whole square minus the hole. The square is 10² = 100, and the circle is 3.14 × 4² = 3.14 × 16 = 50.24, so what is left is 100 − 50.24 = 49.76, which rounds to 49.8. Answering 47.8 would need the circle to cover 52.2, and 51.8 would need only 48.2, so recheck the product 3.14 × 16 if you land on either.'
  WHERE section = 'math' AND prompt = 'A circle of radius 4 is cut out of a square with side 10. What is the area of the remaining square? (Use π ≈ 3.14)' AND options = '["45.8", "47.8", "49.8", "51.8"]'::JSONB;

UPDATE questions SET explanation = 'Multiply as if the decimal were not there, then put it back. 7 × 4 = 28, and 0.4 has one digit after the point, so the answer has one digit after the point: 2.8. Answering 0.28 places two decimals instead of one, and 28 drops the decimal entirely. Sense check: 0.4 is a little less than half, so the answer should be a little less than half of 7.'
  WHERE section = 'math' AND prompt = 'What is 7 × 0.4?' AND options = '["2.4", "0.28", "28", "2.8"]'::JSONB;

UPDATE questions SET explanation = 'Compare decimals place by place from the left, padding with zeros so they line up: 0.7002, 0.7000, 0.0750 and 0.6800. The tenths digit settles most of it, and 0.075 has a 0 there, making it the smallest even though 75 looks large. Between 0.7 and 0.7002 the tie breaks in the ten-thousandths place, so 0.7002 wins by a hair.'
  WHERE section = 'math' AND prompt = 'Which of these decimals is the largest?' AND options = '["0.7002", "0.7", "0.075", "0.68"]'::JSONB;

UPDATE questions SET explanation = 'The word of means multiply, and multiplying by 1/3 is the same as dividing by 3. So 27 ÷ 3 = 9. Answering 81 multiplies by 3 instead of dividing, and a fraction of 27 can never come out bigger than 27, so that one can be ruled out at a glance. Answering 3 divides 27 by 9 rather than by 3.'
  WHERE section = 'math' AND prompt = 'What is 1/3 of 27?' AND options = '["12", "3", "9", "81"]'::JSONB;

UPDATE questions SET explanation = 'A fraction becomes a percent when you divide, then scale to hundredths. 3 ÷ 5 = 0.6, and 0.6 × 100 = 60%. Answering 35% just reads the digits 3 and 5 off the fraction, which is the usual trap. Answering 30% treats it as 3 out of 10. Sense check: 3/5 is more than half, so the percent must be above 50.'
  WHERE section = 'math' AND prompt = 'Write 3/5 as a percent.' AND options = '["60%", "30%", "35%", "53%"]'::JSONB;

UPDATE questions SET explanation = 'Dividing by a decimal is easier if you clear it first, and multiplying both numbers by the same amount keeps the answer unchanged. Multiply each by 10: 64 ÷ 8 = 8. Because 0.8 is less than 1, the result has to be bigger than 6.4, which rules out 0.8 and 0.08 immediately. Check: 8 × 0.8 = 6.4.'
  WHERE section = 'math' AND prompt = 'What is 6.4 ÷ 0.8?' AND options = '["8", "0.8", "80", "0.08"]'::JSONB;

UPDATE questions SET explanation = 'Give the fractions a common denominator, then watch for a fraction bigger than 1. Since 2 1/2 is the same as 2 2/4, the sum is 2 2/4 + 1 3/4 = 3 5/4. But 5/4 is more than a whole, so trade it for 1 1/4 and get 4 1/4. Answering 3 3/4 adds the wholes and never carries the extra one, which is why it lands a half short.'
  WHERE section = 'math' AND prompt = 'What is 2 1/2 + 1 3/4?' AND options = '["4 1/4", "3 3/4", "4 1/2", "3 1/4"]'::JSONB;

UPDATE questions SET explanation = 'A ratio splits the class into equal parts, so count the parts first: 4 + 5 = 9. Each part is 36 ÷ 9 = 4 students, and girls take 5 parts, so 5 × 4 = 20. Answering 16 gives the number of boys, since 4 parts is 16. Check: 16 + 20 = 36, and 16 to 20 reduces back to 4:5.'
  WHERE section = 'math' AND prompt = 'The ratio of boys to girls in a class is 4:5. If there are 36 students in all, how many are girls?' AND options = '["20", "18", "24", "16"]'::JSONB;

UPDATE questions SET explanation = 'Find the price of one item, then scale up. $4.50 ÷ 3 = $1.50 each, so 7 notebooks cost 7 × $1.50 = $10.50. Check the rate held: $10.50 ÷ 7 = $1.50, matching the original. Answering $9.50 or $8.75 gives a per-notebook price of about $1.36 or $1.25, which is cheaper than the original rate, so the price would not have stayed the same.'
  WHERE section = 'math' AND prompt = 'If 3 notebooks cost $4.50, how much do 7 notebooks cost at the same rate?' AND options = '["$8.75", "$9.50", "$12.00", "$10.50"]'::JSONB;

UPDATE questions SET explanation = 'Multiplication comes before adding and subtracting, and subtracting a negative adds. First 4 × (−3) = −12, so you have −6 + (−12) = −18. Then taking away −5 means adding 5, giving −13. Answering −23 subtracts the 5 instead of adding it, and 13 loses track of the negatives entirely.'
  WHERE section = 'math' AND prompt = 'Evaluate: −6 + 4 × (−3) − (−5)' AND options = '["−23", "−13", "−5", "13"]'::JSONB;

UPDATE questions SET explanation = 'Read the decimal as a fraction of a power of ten, then reduce. The 6 sits in the tenths place, so 0.6 = 6/10, and dividing both parts by 2 gives 3/5. You can test the other choices by dividing: 2/3 is about 0.667 and 2/5 is 0.4, so neither equals 0.6. Only 3/5 gives exactly 0.6.'
  WHERE section = 'math' AND prompt = 'What is 0.6 expressed as a fraction in lowest terms?' AND options = '["2/3", "3/5", "1/6", "2/5"]'::JSONB;

UPDATE questions SET explanation = 'Scientific notation needs a first factor between 1 and 10, so move the decimal until you reach 4.5, and count every place you moved. From 0.000045 that is five places to the right, and moving right makes the exponent negative: 4.5 × 10⁻⁵. Answering 4.5 × 10⁻⁴ counts only the four zeros and forgets that the 4 itself needed a move too.'
  WHERE section = 'math' AND prompt = 'Express 0.000045 in scientific notation.' AND options = '["4.5 × 10⁻⁴", "4.5 × 10⁻⁵", "4.5 × 10⁵", "4.5 × 10⁻⁶"]'::JSONB;

UPDATE questions SET explanation = 'When powers share a base you add exponents to multiply and subtract to divide, so no big numbers are needed: 3⁴ × 3² = 3⁶, and 3⁶ ÷ 3⁵ = 3¹ = 3. Answering 9 keeps one exponent too many, and answering 1 assumes everything cancels, which would only happen if the top and bottom exponents matched exactly.'
  WHERE section = 'math' AND prompt = 'Evaluate: (3⁴ × 3²) ÷ 3⁵' AND options = '["1", "9", "27", "3"]'::JSONB;

UPDATE questions SET explanation = 'Some percents are friendlier as fractions, and 12.5% is exactly 1/8. So the answer is 320 ÷ 8 = 40. You can also check by scaling: 10% of 320 is 32, and 12.5% must be a bit more than that, which fits 40 and rules out 25 and 4 immediately. Answering 4 has slipped a decimal place somewhere.'
  WHERE section = 'math' AND prompt = 'What is 12.5% of 320?' AND options = '["4", "40", "25", "45"]'::JSONB;

UPDATE questions SET explanation = 'Like terms all carry the same variable, so you only combine the numbers in front and keep the x. Since 5 + 3 − 2 = 6, the answer is 6x. Answering 6 drops the variable, but the x never goes away when you are only counting how many of them there are. Answering 10x adds all three coefficients as though the minus sign were a plus.'
  WHERE section = 'math' AND prompt = 'Simplify: 5x + 3x − 2x' AND options = '["4x", "6", "10x", "6x"]'::JSONB;

UPDATE questions SET explanation = 'Substitute the value in place of the variable and follow the order of operations. y = 3(5) − 4, so multiply first to get 15, then subtract to get 11. Answering 19 adds the 4 instead of subtracting it, and 15 stops after the multiplication and forgets the −4 waiting at the end of the expression.'
  WHERE section = 'math' AND prompt = 'If y = 3x − 4, what is y when x = 5?' AND options = '["19", "15", "11", "7"]'::JSONB;

UPDATE questions SET explanation = 'To undo something added to x, subtract it from both sides. Taking 12 off each side gives x = 5 − 12 = −7. Since 12 is bigger than 5, the answer has to be negative, which rules out 7 and 17 right away. Answering 17 adds 12 instead of subtracting it. Check: −7 + 12 = 5.'
  WHERE section = 'math' AND prompt = 'If x + 12 = 5, what is x?' AND options = '["7", "17", "−7", "−17"]'::JSONB;

UPDATE questions SET explanation = 'Distribute the 3 to both terms inside the parentheses, then collect like terms. 3(2x − 4) = 6x − 12, and adding 5x gives 11x − 12. Answering 11x − 4 multiplies only the 2x by 3 and leaves the −4 untouched, which is the most common slip. Answering 6x − 12 stops before the 5x is added in.'
  WHERE section = 'math' AND prompt = 'Simplify: 3(2x − 4) + 5x' AND options = '["6x − 12", "11x + 12", "11x − 4", "11x − 12"]'::JSONB;

UPDATE questions SET explanation = 'Undo the operations in reverse order: the division wrapped the whole expression, so clear it first. Multiplying both sides by 5 gives x − 3 = 20, and adding 3 gives x = 23. Answering 20 stops before adding the 3 back, and 17 subtracts 3 rather than adding it. Check: (23 − 3) ÷ 5 = 20 ÷ 5 = 4.'
  WHERE section = 'math' AND prompt = 'Solve for x: (x − 3)/5 = 4' AND options = '["23", "20", "17", "7"]'::JSONB;

UPDATE questions SET explanation = 'Peel away the addition first, then divide, keeping the sign attached to the coefficient. Subtracting 7 from both sides gives −3x = 15, and dividing by −3 gives x = −5. Answering 5 drops the negative sign, which is the trap here. Check by substituting: −3(−5) + 7 = 15 + 7 = 22, which matches.'
  WHERE section = 'math' AND prompt = 'Solve for x: −3x + 7 = 22' AND options = '["−5", "5", "9", "−9"]'::JSONB;

UPDATE questions SET explanation = 'Only the a is squared here, not the 2 in front of it, so square before you multiply. a² = 9, then 2 × 9 = 18, and 18 − 5 = 13. Answering 31 squares 2a as (2 × 3)² = 36 and then subtracts 5, which treats the 2 as if it were inside the square. Answering 7 subtracts before doubling.'
  WHERE section = 'math' AND prompt = 'What is the value of 2a² − b when a = 3 and b = 5?' AND options = '["7", "13", "1", "31"]'::JSONB;

UPDATE questions SET explanation = 'Solve as usual, but flip the inequality sign the moment you divide by a negative. Subtracting 5 gives −2x < 6, and dividing by −2 turns it into x > −3. Answering x < −3 keeps the sign pointing the same way, the most common miss. Test x = 0: 5 − 0 = 5, which is less than 11, so 0 must be included, and only x > −3 includes it.'
  WHERE section = 'math' AND prompt = 'Solve the inequality: 5 − 2x < 11' AND options = '["x < 8", "x < −3", "x > 3", "x > −3"]'::JSONB;

UPDATE questions SET explanation = 'Distribute both numbers, watching the sign on the second one, since a negative times a negative is positive. That gives 3x + 6 − 2x + 2, which collects to x + 8. So x + 8 = 14 and x = 6. Answering 10 comes from writing −2x − 2 and losing that sign flip. Check: 3(8) − 2(5) = 24 − 10 = 14.'
  WHERE section = 'math' AND prompt = 'If 3(x + 2) − 2(x − 1) = 14, what is x?' AND options = '["10", "2", "4", "6"]'::JSONB;

UPDATE questions SET explanation = 'Define the unknown as the thing being described, not the thing described in terms of it. Let w be the width, so the length is 2w + 3. Then 2(w + 2w + 3) = 54, so 3w + 3 = 27 and w = 8 cm. Answering 19 cm gives the length instead of the width. Check: 2(8 + 19) = 54.'
  WHERE section = 'math' AND prompt = 'The perimeter of a rectangle is 54 cm. Its length is 3 cm more than twice its width. What is the width?' AND options = '["6 cm", "8 cm", "19 cm", "11 cm"]'::JSONB;

UPDATE questions SET explanation = 'Treat 1/x as a single unknown piece first, then flip at the very end. Subtracting gives 1/x = 1/2 − 1/6 = 3/6 − 1/6 = 1/3, and if 1/x = 1/3 then x = 3. Answering 1/3 stops one step early and reports the reciprocal instead of x. Check: 1/3 + 1/6 = 2/6 + 1/6 = 1/2.'
  WHERE section = 'math' AND prompt = 'If 1/x + 1/6 = 1/2, what is x?' AND options = '["3", "1/3", "4", "6"]'::JSONB;

UPDATE questions SET explanation = 'Two squares with a minus between them always factor as the sum times the difference. Here x² − 9 = x² − 3², so it becomes (x − 3)(x + 3), and the middle terms −3x and +3x cancel when you check. Answering (x − 3)(x − 3) would give x² − 6x + 9, which has an unwanted middle term and the wrong sign on the 9.'
  WHERE section = 'math' AND prompt = 'Factor completely: x² − 9' AND options = '["(x + 9)(x − 1)", "(x − 3)(x + 3)", "(x − 9)(x + 1)", "(x − 3)(x − 3)"]'::JSONB;

UPDATE questions SET explanation = 'Count doublings until you reach the target: 2, 4, 8, 16, 32. That is five factors of 2, so 2⁵ = 32 and x = 5. Answering 4 stops at 16, one doubling short. Answering 16 gives half of 32 rather than the exponent, which mixes up the answer with the number itself.'
  WHERE section = 'math' AND prompt = 'If 2ˣ = 32, what is x?' AND options = '["4", "5", "6", "16"]'::JSONB;

UPDATE questions SET explanation = 'A straight angle opens all the way out into a straight line, which is exactly half of a full turn. Since a full turn is 360°, a straight angle is 180°. Answering 90° describes a right angle, a quarter turn, and 360° is the full rotation back to where you started rather than half of it.'
  WHERE section = 'math' AND prompt = 'How many degrees are in a straight angle?' AND options = '["180°", "90°", "45°", "360°"]'::JSONB;

UPDATE questions SET explanation = 'Perimeter is the distance all the way around, and a rectangle has two lengths and two widths: 2(11 + 4) = 30. Answering 44 multiplies 11 by 4, which gives the area instead, and area is measured in squares rather than in length. Answering 15 adds one length and one width but forgets the other two sides.'
  WHERE section = 'math' AND prompt = 'What is the perimeter of a rectangle with length 11 and width 4?' AND options = '["44", "30", "22", "15"]'::JSONB;

UPDATE questions SET explanation = 'Equilateral means all three sides are equal, which forces all three angles to be equal too. The angles of any triangle add to 180°, so each one is 180 ÷ 3 = 60°. Answering 90° would already use half the total on one angle, leaving too little for the other two, and 45° or 30° would give totals of 135° or 90°, both short of 180°.'
  WHERE section = 'math' AND prompt = 'Each angle of an equilateral triangle measures how many degrees?' AND options = '["45°", "90°", "60°", "30°"]'::JSONB;

UPDATE questions SET explanation = 'A regular polygon has all sides the same length, so divide the perimeter by the number of sides. A hexagon has 6 sides, so each is 48 ÷ 6 = 8. Answering 6 reports the number of sides rather than the side length, and 12 would come from dividing by 4 as though it were a square. Check: 6 × 8 = 48.'
  WHERE section = 'math' AND prompt = 'A regular hexagon has a perimeter of 48. What is the length of one side?' AND options = '["9", "6", "12", "8"]'::JSONB;

UPDATE questions SET explanation = 'A trapezoid''s two bases differ, so the formula uses their average times the height. The average base is (8 + 12) ÷ 2 = 10, and 10 × 5 = 50. Answering 100 adds the bases without halving them, which doubles the answer. Sense check: the trapezoid must be smaller than a 12 by 5 rectangle, whose area is 60.'
  WHERE section = 'math' AND prompt = 'A trapezoid has parallel sides of 8 and 12 and a height of 5. What is its area?' AND options = '["25", "50", "100", "60"]'::JSONB;

UPDATE questions SET explanation = 'A parallelogram is a rectangle with its top slid sideways, so its area is still base times height: 9 × 6 = 54. The slant does not change it. Answering 27 halves the result, which is the triangle formula, not the parallelogram one. Answering 30 computes 2(9 + 6), which is a perimeter rather than an area.'
  WHERE section = 'math' AND prompt = 'A parallelogram has a base of 9 and a height of 6. What is its area?' AND options = '["30", "54", "27", "15"]'::JSONB;

UPDATE questions SET explanation = 'Area uses the radius squared, and 22/7 is chosen here because the 7s cancel neatly. Area = (22/7) × 7² = 22 × 7 = 154. Answering 44 gives the circumference, 2 × (22/7) × 7, which measures the distance around rather than the space inside. Answering 308 doubles the area, and 77 halves it.'
  WHERE section = 'math' AND prompt = 'A circle has a radius of 7. What is its area? (Use π ≈ 22/7)' AND options = '["44", "154", "308", "77"]'::JSONB;

UPDATE questions SET explanation = 'Volume of a cube is edge × edge × edge, so finding the edge means taking a cube root, not dividing. Since 5 × 5 × 5 = 125, the edge is 5 cm. Answering 25 divides 125 by 5 just once and stops, and 25 cm would give a volume of 15,625 cm³. Answering 12.5 cm divides by 10, which has nothing to do with cubing.'
  WHERE section = 'math' AND prompt = 'A cube has a volume of 125 cm³. What is the length of one edge?' AND options = '["12.5 cm", "25 cm", "5 cm", "15 cm"]'::JSONB;

UPDATE questions SET explanation = 'The formula needs the radius, but the question gives the diameter, so halve it first: r = 5. Then volume = 3.14 × 5² × 7 = 3.14 × 25 × 7 = 549.5. Answering 2,198 uses 10 as the radius, which makes the cylinder four times too big. Answering 109.9 forgets to square the radius and computes 3.14 × 5 × 7.'
  WHERE section = 'math' AND prompt = 'A cylinder has a diameter of 10 and a height of 7. What is its volume? (Use π ≈ 3.14)' AND options = '["219.8", "109.9", "2,198", "549.5"]'::JSONB;

UPDATE questions SET explanation = 'Work from the area to the side, then use the Pythagorean theorem on the diagonal. The side is √50, about 7.1, and the diagonal is √(50 + 50) = √100 = 10 units exactly. Answering about 7.1 units gives the side rather than the diagonal, and about 14.1 units treats 10 as the side instead of the diagonal. The diagonal must be longer than a side, but not by much.'
  WHERE section = 'math' AND prompt = 'The area of a square is 50 square units. What is the length of its diagonal?' AND options = '["25 units", "10 units", "About 7.1 units", "About 14.1 units"]'::JSONB;

UPDATE questions SET explanation = 'In an isosceles triangle the height to the base cuts the base in half, which creates a right triangle. That triangle has hypotenuse 13 and one leg 5, so the height is √(169 − 25) = √144 = 12. Answering 6.5 halves the slanted side, but it is the base that gets halved, not the equal sides. Answering 8 would need a base of 20.'
  WHERE section = 'math' AND prompt = 'An isosceles triangle has two equal sides of 13 and a base of 10. What is the height drawn to the base?' AND options = '["11", "8", "12", "6.5"]'::JSONB;

UPDATE questions SET explanation = 'A box has six faces in three matching pairs, so find the three different faces and double the total. The faces are 3 × 4 = 12, 3 × 5 = 15 and 4 × 5 = 20, so the surface area is 2(12 + 15 + 20) = 94. Answering 47 forgets to double, and 60 is 3 × 4 × 5, which is the volume rather than the surface.'
  WHERE section = 'math' AND prompt = 'What is the total surface area of a rectangular prism with dimensions 3, 4, and 5?' AND options = '["47", "120", "94", "60"]'::JSONB;

UPDATE questions SET explanation = 'Centi means one hundredth, so a meter holds 100 centimeters. Going from a bigger unit to a smaller one means more of them, so multiply: 2.5 × 100 = 250 cm. Answering 25 cm multiplies by only 10, and 0.025 cm divides instead of multiplying, which would make 2.5 meters shorter than a fingernail.'
  WHERE section = 'math' AND prompt = 'How many centimeters are in 2.5 meters?' AND options = '["2,500 cm", "25 cm", "250 cm", "0.025 cm"]'::JSONB;

UPDATE questions SET explanation = 'One pound holds 16 ounces, and ounces are smaller than pounds, so multiply: 3 × 16 = 48 ounces. Answering 36 uses 12 per pound, borrowing the inches-in-a-foot number by mistake. Answering 16 gives the ounces in a single pound and forgets to scale up to three, and 30 uses a rough 10 per pound.'
  WHERE section = 'math' AND prompt = 'How many ounces are in 3 pounds?' AND options = '["30", "48", "16", "36"]'::JSONB;

UPDATE questions SET explanation = 'Probability compares the outcomes you want to all the outcomes there are, so the bottom number is the total, not the other color. There are 3 + 5 = 8 marbles and 3 are red, giving 3/8. Answering 3/5 compares red to blue instead of red to the whole bag, and 5/8 is the probability of drawing blue.'
  WHERE section = 'math' AND prompt = 'A bag contains 3 red marbles and 5 blue marbles. What is the probability of drawing a red marble at random?' AND options = '["5/8", "3/5", "3/8", "1/3"]'::JSONB;

UPDATE questions SET explanation = 'Cups are smaller than quarts, so the same amount of water takes more cups, which means you multiply. Since 1 quart is 4 cups, 3 quarts is 3 × 4 = 12 cups. Answering 8 cups uses only 2 quarts, and 6 cups doubles instead of quadrupling. Dividing 3 by 4 would give less than one cup, which cannot be right.'
  WHERE section = 'math' AND prompt = 'A recipe calls for 3 quarts of water. How many cups is that? (1 quart = 4 cups)' AND options = '["8 cups", "6 cups", "16 cups", "12 cups"]'::JSONB;

UPDATE questions SET explanation = 'List the outcomes that actually qualify. Greater than 4 means 5 or 6 only, since 4 itself is not greater than 4. That is 2 of the 6 equally likely faces, so 2/6 = 1/3. Answering 1/2 counts 4 as well, giving 3 of 6, which is the most common slip in questions that say greater than instead of at least.'
  WHERE section = 'math' AND prompt = 'A standard six-sided die is rolled once. What is the probability of rolling a number greater than 4?' AND options = '["2/3", "1/6", "1/2", "1/3"]'::JSONB;

UPDATE questions SET explanation = 'With two coins there are four equally likely outcomes: HH, HT, TH and TT. Only one of them is two heads, so the probability is 1/4. Multiplying works too, since the flips are independent: 1/2 × 1/2 = 1/4. Answering 1/2 gives the chance for a single coin, and 1/3 treats HT and TH as one outcome, but they are separate results.'
  WHERE section = 'math' AND prompt = 'Two fair coins are flipped. What is the probability that both land heads?' AND options = '["1/2", "3/4", "1/4", "1/3"]'::JSONB;

UPDATE questions SET explanation = 'The tennis group is whatever is left over, so total the named choices and subtract from the whole survey. 25 + 15 + 12 = 52, and 60 − 52 = 8 students chose tennis. Check: 25 + 15 + 12 + 8 = 60. Answering 12 repeats the swimming count, and 10 or 5 would make the four groups add to 62 or 57 rather than 60.'
  WHERE section = 'math' AND prompt = 'In a survey of 60 students, 25 chose soccer, 15 chose basketball, and 12 chose swimming. The rest chose tennis. How many chose tennis?' AND options = '["10", "8", "5", "12"]'::JSONB;

UPDATE questions SET explanation = 'A percent of a circle graph is a percent of the people it represents, so multiply. 0.45 × 200 = 90 people. Answering 45 repeats the percent as if it were a headcount, but with 200 responses each percent stands for 2 people. Sense check: 45% is a bit under half, and 90 is a bit under half of 200.'
  WHERE section = 'math' AND prompt = 'A circle graph summarizes 200 survey responses. The section for Option A represents 45% of the graph. How many people chose Option A?' AND options = '["45", "90", "80", "110"]'::JSONB;

UPDATE questions SET explanation = 'List the primes from 1 to 8: 2, 3, 5 and 7. That is four sections, so the probability is 4/8 = 1/2. The number 1 is not prime, because a prime needs exactly two different factors and 1 has only one. Counting 1 as prime gives five sections and the answer 5/8, which is the usual trap here.'
  WHERE section = 'math' AND prompt = 'A spinner has 8 equal sections numbered 1 through 8. What is the probability of landing on a prime number?' AND options = '["1/4", "3/8", "5/8", "1/2"]'::JSONB;

UPDATE questions SET explanation = 'Without replacement, the second draw happens from a smaller bag, so the fractions are not the same. The first red has probability 4/10, and with one red gone the second is 3/9. Multiplying gives 12/90 = 2/15. Answering 4/25 uses 4/10 twice, which would be right only if the first marble were put back before the second draw.'
  WHERE section = 'math' AND prompt = 'A bag holds 4 red and 6 green marbles. Two are drawn without replacement. What is the probability that both are red?' AND options = '["1/6", "2/15", "2/5", "4/25"]'::JSONB;

UPDATE questions SET explanation = 'Square units scale by the square of the length factor, so a yard being 3 feet makes a square yard 3 × 3 = 9 square feet. Then 2 square yards = 2 × 9 = 18 square feet. Answering 6 multiplies by 3 instead of 9, treating area like a length. Answering 9 gives just one square yard, and 36 squares the 6 by mistake.'
  WHERE section = 'math' AND prompt = 'How many square feet are in 2 square yards?' AND options = '["9", "6", "36", "18"]'::JSONB;

UPDATE questions SET explanation = 'Get the speed first, then convert both units. 90 ÷ 1.5 = 60 km/h. One kilometer is 1,000 meters and one hour is 3,600 seconds, so 60,000 ÷ 3,600 is about 16.7 m/s. Answering about 60 m/s keeps the km/h number without converting, and about 1.5 m/s reuses the 1.5 hours from the question rather than a speed.'
  WHERE section = 'math' AND prompt = 'A car travels 90 kilometers in 1.5 hours. What is its speed in meters per second?' AND options = '["About 16.7 m/s", "About 1.5 m/s", "About 60 m/s", "About 25 m/s"]'::JSONB;

UPDATE questions SET explanation = 'Find the unit rate, then multiply by the new amount of time. The club reads 8 ÷ 4 = 2 books per month, so in 10 months it reads 2 × 10 = 20 books. Answering 16 doubles the 8, which would match 8 months, not 10. Check the proportion: 8 out of 4 equals 20 out of 10, since both simplify to 2 per month.'
  WHERE section = 'math' AND prompt = 'A book club read 8 books in 4 months at a steady rate. At that rate, how many books will it read in 10 months?' AND options = '["16", "14", "24", "20"]'::JSONB;

UPDATE questions SET explanation = 'Add the hours first, then the minutes, rolling over at 60. From 6:45, one hour later is 7:45. Adding 50 minutes takes 15 minutes to reach 8:00, leaving 35 more, so the movie ends at 8:35 p.m. Answering 8:45 p.m. rounds the run time up to a full 2 hours, and 7:35 p.m. adds the 50 minutes but forgets the hour.'
  WHERE section = 'math' AND prompt = 'A movie starts at 6:45 p.m. and runs for 1 hour and 50 minutes. What time does it end?' AND options = '["7:35 p.m.", "8:35 p.m.", "8:25 p.m.", "8:45 p.m."]'::JSONB;

UPDATE questions SET explanation = 'Take the discount off first, then add the extra item, since the case is not discounted. The discount is 0.30 × $450 = $135, so the phone costs $450 − $135 = $315, and adding the case gives $330. Answering $135 reports the discount itself rather than what you pay. Shortcut: paying 70% means 0.70 × $450 = $315 in one step.'
  WHERE section = 'math' AND prompt = 'A phone that normally costs $450 is discounted 30%. A $15 case is then added to the purchase. What is the total cost?' AND options = '["$330", "$135", "$345", "$300"]'::JSONB;

UPDATE questions SET explanation = 'Simple interest is earned on the original amount every year, so multiply principal by rate by time: $800 × 0.05 × 3 = $120. Answering $40 gives one year''s interest and forgets the 3 years. Answering $920 adds the interest to the $800 and reports the final balance, but the question asks only for the interest earned.'
  WHERE section = 'math' AND prompt = 'How much simple interest does $800 earn in 3 years at an annual rate of 5%?' AND options = '["$120", "$920", "$40", "$1,200"]'::JSONB;

UPDATE questions SET explanation = 'Split the hours into regular and overtime, because they are paid at different rates. The first 40 hours pay 40 × $16 = $640. The other 6 hours pay time and a half, or 1.5 × $16 = $24 each, giving 6 × $24 = $144. Total: $784. Answering $736 pays all 46 hours at the plain $16 rate and misses the overtime bump.'
  WHERE section = 'math' AND prompt = 'A worker earns $16 per hour for the first 40 hours of a week and time-and-a-half for every hour beyond that. If she works 46 hours, what is her total pay?' AND options = '["$828", "$736", "$640", "$784"]'::JSONB;

UPDATE questions SET explanation = 'When two objects move in opposite directions the gap grows at the sum of their speeds, so combine them: 60 + 75 = 135 mph. Then 405 ÷ 135 = 3 hours. Answering 2.7 hours uses 150 mph, as if both trains matched the faster one. Check: in 3 hours one covers 180 miles and the other 225, and 180 + 225 = 405.'
  WHERE section = 'math' AND prompt = 'Two trains leave the same station at the same time traveling in opposite directions, one at 60 mph and the other at 75 mph. How long until they are 405 miles apart?' AND options = '["3 hours", "4 hours", "2.7 hours", "3.5 hours"]'::JSONB;

UPDATE questions SET explanation = 'The 42 gallons account only for the change in the tank, which is 4/5 − 3/5 = 1/5 of it. If one fifth is 42 gallons, the whole tank is 5 × 42 = 210 gallons. Answering 168 gallons gives 4/5 of the tank rather than all of it, and 105 gallons treats the 42 gallons as 2/5 of the capacity.'
  WHERE section = 'math' AND prompt = 'A tank is 3/5 full. After 42 gallons are added, it is 4/5 full. What is the tank''s total capacity?' AND options = '["105 gallons", "350 gallons", "210 gallons", "168 gallons"]'::JSONB;

-- Verification: expect 250 math rows carrying a long (rewritten) explanation.
SELECT
  'math' AS section,
  COUNT(*) AS total_rows,
  COUNT(*) FILTER (WHERE LENGTH(explanation) > 150) AS long_explanations,
  250 AS expected_long_explanations
FROM questions
WHERE section = 'math';
