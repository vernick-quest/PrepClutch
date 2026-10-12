# Generates migration 063. Content lives here so quoting is done by code, and
# the Supabase editor's string-literal blind spot (a ';' inside a literal
# surfaces as SQL) is checked before anything is written.
import re, sys

CAT = 'Math Facts'
B = []  # key, label, emoji, description, rarity, creature, lore, threshold

# ── Cards mastered, the growing Calcupede ──
for n, label, emoji, rarity, lore in [
  (10,  'Calcupede Hatchling', '🐛', 'Common',
   'A Calcupede is born with no legs at all. Every fact it learns cold, it grows one. This one has ten and keeps counting them out loud, which is fair, because it can now do that very quickly.'),
  (50,  'Calcupede Crawler',   '🐛', 'Uncommon',
   'Fifty legs, fifty facts. The Crawler has stopped tripping over itself and started tripping over smaller Calcupedes, who are slower at their sevens.'),
  (100, 'Calcupede Sprinter',  '🐛', 'Rare',
   'One hundred facts, one hundred legs, all moving at once. It is technically a centipede now, a fact it learned in under three seconds.'),
  (250, 'Calcupede Racer',     '🐛', 'Epic',
   'Two hundred and fifty legs. The Racer no longer works out answers. It simply arrives at them, slightly ahead of the question.'),
  (500, 'Calcupede Titan',     '🐛', 'Legendary',
   'Five hundred legs and the ground shakes when it divides. Teachers have started asking it for the answer key.'),
  (864, 'Calcupede Infinite',  '🐛', 'Ascendant',
   'Every card. Every table. Every missing number, both ways. There is nothing left to learn and the Calcupede has grown so many legs it has lost count, which, for a Calcupede, is the highest honour.'),
]:
  B.append((f'facts_mastered_{n}', label, emoji,
            f'{n} Math Facts cards mastered.' if n < 864 else 'Every one of the 864 Math Facts cards mastered.',
            rarity, 'Calcupede', lore, n))

# ── Times tables ──
KEYCAP = {i: f'{i}️⃣' for i in range(1, 10)}
KEYCAP[10] = '🔟'; KEYCAP[11] = '1️⃣1️⃣'; KEYCAP[12] = '1️⃣2️⃣'
TABLE_RARITY = {1: 'Common', 2: 'Common', 10: 'Common', 5: 'Uncommon', 11: 'Uncommon',
                3: 'Uncommon', 4: 'Uncommon', 6: 'Rare', 9: 'Rare', 12: 'Rare', 7: 'Epic', 8: 'Epic'}
TABLE_LORE = {
  1: 'The Ones Owl knows that anything times one is itself. It considers this the deepest truth in mathematics and will not be told otherwise.',
  2: 'The Doubling Dove sees everything twice, which used to be a problem and is now a talent.',
  3: 'The Triple Toad hops in threes. Nobody knows why. It has never landed on a wrong answer.',
  4: 'The Quad Quokka smiles because it knows four times anything is just doubling twice. It is smiling at you right now.',
  5: 'The High Five Hare counts by fives faster than you can clap. Every answer ends in zero or five and it finds that very relaxing.',
  6: 'The Sixer Snail is slow everywhere except the six times table, where it is suspiciously fast.',
  7: 'The Seven Serpent guards the hardest table of them all. Seven times eight is fifty-six. It hisses this at strangers.',
  8: 'The Octo Owl has eight arms and has memorised eight times everything, one fact per arm, with four arms to spare for snacks.',
  9: 'The Nines Newt knows the finger trick but no longer needs it. The digits of every answer still add up to nine, and it still finds that delightful.',
  10: 'The Tens Tortoise just adds a zero. It is not lazy. It is efficient.',
  11: 'The Eleven Eel saw eleven times eleven coming a mile away. The double digits never fooled it.',
  12: 'The Dozen Dragon holds the top of the table. One hundred and forty-four is its treasure and it sleeps on it.',
}
TABLE_CREATURE = {1: 'Ones Owl', 2: 'Doubling Dove', 3: 'Triple Toad', 4: 'Quad Quokka', 5: 'High Five Hare',
                  6: 'Sixer Snail', 7: 'Seven Serpent', 8: 'Octo Owl', 9: 'Nines Newt', 10: 'Tens Tortoise',
                  11: 'Eleven Eel', 12: 'Dozen Dragon'}
for n in range(1, 13):
  B.append((f'facts_table_{n}', f'Master of the {n}s', KEYCAP[n],
            f'Every {n}s multiplication card mastered, missing-number cards included.',
            TABLE_RARITY[n], TABLE_CREATURE[n], TABLE_LORE[n], n))

# ── Whole operations ──
B.append(('facts_all_mul', 'Multiplication Monarch', '✖️👑', 'All 432 multiplication cards mastered.', 'Legendary',
          'Monarch', 'Every times table, every missing number. The Monarch rules a kingdom of products and has never once had to count on its fingers in public.', 432))
B.append(('facts_all_div', 'Division Duchess', '➗👑', 'All 432 division cards mastered.', 'Legendary',
          'Duchess', 'She splits everything perfectly and fairly. Pizza, treasure, homework. Nobody argues with the Duchess about who got the bigger half.', 432))

# ── Missing numbers ──
B.append(('facts_missing_25', 'Number Detective', '🕵️', '25 missing-number cards mastered.', 'Uncommon',
          'Detective', 'Somebody hid a number. The Detective found it. Twenty-five times. The criminals are getting nervous.', 25))
B.append(('facts_missing_100', 'Master Sleuth', '🔍', '100 missing-number cards mastered.', 'Epic',
          'Sleuth', 'One hundred missing numbers recovered. The Sleuth sees seven times blank equals fifty-six and knows the culprit before the question finishes loading.', 100))

# ── A perfect round ──
B.append(('facts_perfect_round', 'Flawless Ten', '🎯', 'A 10-card round with every card right, and every one fast enough to master.', 'Rare',
          'Flawless', 'Ten cards. Ten right answers. Not one of them slow. It is not luck if it happens ten times in a row.', 10))

def q(s):
  bad = [c for c in (';', '$', '--') if c in s]
  if bad: sys.exit(f'risky characters {bad} in: {s[:60]}')
  return "'" + s.replace("'", "''") + "'"

rows = ',\n\n'.join(
  f"({q(k)}, {q(l)}, {q(e)}, {q(d)}, {q(r)}, {q(c)}, {q(CAT)},\n {q(lo)}, {t})"
  for k, l, e, d, r, c, lo, t in B)

keys = [b[0] for b in B]
assert len(keys) == len(set(keys)) == 23, len(keys)

sql = open(sys.argv[1]).read().replace('__ROWS__', rows).replace('__COUNT__', str(len(B)))
open(sys.argv[2], 'w').write(sql)
print('badges', len(B))
