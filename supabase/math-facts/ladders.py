# Generates migration 067: a balanced badge ladder on every Math Facts tab.
# Run: python3 -B supabase/math-facts/ladders.py
#
# Content lives here so quoting is done by code, and the Supabase editor's
# string-literal blind spot (; $ -- inside a literal) is refused before
# anything is written.
import sys, pathlib

HERE = pathlib.Path(__file__).parent
ROOT = HERE.parent.parent
CAT = 'Math Facts'
B = []  # key, label, emoji, description, rarity, creature, lore, threshold

# ── Ladder rungs on each tab (the "all" rung already exists for every tab) ──
B += [
  ('facts_mul_10', 'Times Tadpole', '✖️🐣', '10 multiplication cards mastered.', 'Common', 'Times Tadpole',
   'Ten times facts and the Tadpole has already grown its first two legs. It uses them mostly for counting by twos.', 10),
  ('facts_mul_216', 'Times Trailblazer', '✖️🔥', '216 multiplication cards mastered, half of all of them.', 'Rare', 'Trailblazer',
   'Halfway through every times table there is. The Trailblazer can see the twelves from here and is not even slightly worried.', 216),
  ('facts_div_10', 'Share Sprout', '➗🌱', '10 division cards mastered.', 'Common', 'Share Sprout',
   'The Sprout has learned that sharing fairly is just multiplication walking backwards. Ten facts in and it already splits snacks perfectly.', 10),
  ('facts_div_216', 'Split Specialist', '➗🔥', '216 division cards mastered, half of all of them.', 'Rare', 'Split Specialist',
   'Half of every division fact, cut cleanly down the middle. Nobody has ever caught the Specialist with a remainder.', 216),
  ('facts_equiv_10', 'Crust Cadet', '🥖', '10 equivalent-fraction cards mastered.', 'Common', 'Crust Cadet',
   'Every pizza starts with the crust. The Cadet knows a half is two quarters and is working up to the toppings.', 10),
  ('facts_equiv_152', 'Slice Sensei', '🍕🔥', '152 equivalent-fraction cards mastered, half of all of them.', 'Rare', 'Slice Sensei',
   'Half the fractions, mastered. The Sensei can cut a pie into any number of equal slices with its eyes closed, which the kitchen has asked it to stop doing.', 152),
  ('facts_fdp_10', 'Decimal Duckling', '🦆', '10 fraction, decimal and percent cards mastered.', 'Common', 'Decimal Duckling',
   'It waddles in a perfectly straight line because it knows exactly where the decimal point goes. Ten benchmarks down.', 10),
  ('facts_fdp_45', 'Percent Prowler', '💯🔥', '45 fraction, decimal and percent cards mastered, half of all of them.', 'Rare', 'Percent Prowler',
   'Halfway through the benchmarks. The Prowler hears a half and thinks fifty percent before the word has finished.', 45),
]

# ── Division tables, mirroring Master of the 1s-12s ──
KEYCAP = {i: f'{i}️⃣' for i in range(1, 10)}
KEYCAP[10] = '🔟'; KEYCAP[11] = '1️⃣1️⃣'; KEYCAP[12] = '1️⃣2️⃣'
RARITY = {1: 'Common', 2: 'Common', 10: 'Common', 5: 'Uncommon', 11: 'Uncommon',
          3: 'Uncommon', 4: 'Uncommon', 6: 'Rare', 9: 'Rare', 12: 'Rare', 7: 'Epic', 8: 'Epic'}
LORE = {
  1: 'Anything divided by one stays exactly as it was. The Splitter of Ones finds this restful.',
  2: 'Halving is its whole personality. It has never once argued about who got the bigger half.',
  3: 'Splits everything three ways, perfectly. Its friends have stopped bringing odd numbers of cookies.',
  4: 'Quarters everything. Sandwiches, oranges, the afternoon. It is extremely organised.',
  5: 'Divides by five faster than you can count your fingers, and only needs one hand to check.',
  6: 'Six equal shares, every time. It is the most popular guest at any party with a cake.',
  7: 'The division sevens are the hardest shares there are. Fifty-six divided by seven is eight. It whispers this before tests.',
  8: 'Eight shares, eight arms. It hands every one out at the same moment.',
  9: 'Nine-way splits are no problem. The digits still add up to nine and it still finds that delightful.',
  10: 'Divide by ten, take off a zero. It has never needed more than one second.',
  11: 'Splits by eleven without blinking. One hundred and twenty-one divided by eleven is eleven, and it thinks that is a lovely sentence.',
  12: 'The top of the division table. It shares one hundred and forty-four gold coins into twelve perfect piles.',
}
for n in range(1, 13):
  B.append((f'facts_divtable_{n}', f'Master of ÷{n}s', '➗' + KEYCAP[n],
            f'Every {n}s division card mastered, missing-number cards included.',
            RARITY[n], f'Splitter of {n}s', LORE[n], n))

def q(s):
  bad = [c for c in (';', '$', '--') if c in s]
  if bad: sys.exit(f'risky characters {bad} in: {s[:60]}')
  return "'" + s.replace("'", "''") + "'"

keys = [b[0] for b in B]
assert len(keys) == len(set(keys)) == 20, len(keys)

rows = ',\n\n'.join(
  f"({q(k)}, {q(l)}, {q(e)}, {q(d)}, {q(r)}, {q(c)}, {q(CAT)},\n {q(lo)}, {t})"
  for k, l, e, d, r, c, lo, t in B)

sql = (HERE / '067.template.sql').read_text().replace('__ROWS__', rows)
out = ROOT / 'supabase/migrations/067_math_facts_ladders.sql'
out.write_text(sql)
print(f'wrote {out.relative_to(ROOT)}: {len(B)} badges')
