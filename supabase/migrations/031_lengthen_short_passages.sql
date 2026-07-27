-- 031 — Lengthen passages that were too short for their questions
--
-- Six reading passages carried more questions than their length could support
-- (the worst was 54 words behind 7 questions). Real HSPT passages run 200-250
-- words. Each passage below is brought into that range by APPENDING paragraphs.
--
-- Constraints obeyed:
--   * `passage` is the only column written. No prompt, options, correct_index,
--     explanation, difficulty, section or id is touched, and no attempt or
--     answer-history row is read or written anywhere in this file.
--   * The original passage survives verbatim as the opening paragraph, so every
--     existing answer key and explanation still quotes text that is present.
--   * Added material was checked question by question: it contradicts nothing a
--     question tests, makes no distractor defensible, and does not state outright
--     anything an existing question asks the student to infer.
--   * Every WHERE fragment is taken from the ORIGINAL text (so it still matches
--     after the update), was verified to match exactly one distinct passage in
--     the whole corpus, and contains no % or _ that LIKE would read as a
--     wildcard. A NOT LIKE guard on a phrase from the ADDED text makes each
--     statement idempotent — re-running appends nothing.
--   * One UPDATE per passage, so all rows sharing it stay byte-identical and the
--     app keeps grouping them as a single passage.
--
-- Deliberately NOT included: 'Cognitive Dissonance Explained' (83 words, 3
-- questions). One of its questions asks why the author *ends* with the sentence
-- about advertisers; appending any paragraph moves that sentence out of the final
-- position and invalidates the question. Lengthening it requires editing that
-- question, which is out of scope here.

-- ── Gutenberg and the Printing Press ── 54 → 240 words · 7 questions
UPDATE questions SET passage = 'The printing press, invented by Johannes Gutenberg around 1440, revolutionized the spread of information in Europe. Before its invention, books were copied by hand, making them rare and expensive. The press allowed books to be produced quickly and cheaply, enabling literacy to spread and ideas to circulate more freely across regions and social classes.

Copying was slow work. A single large Bible could occupy a scribe for more than a year, and the parchment it was written on took the skins of over a hundred animals. Such a book belonged to a monastery or a wealthy household, and a scholar had to travel to the book rather than the reverse.

Printing itself was not new. Craftsmen in East Asia had long carved a whole page of text into a single wooden block, and movable type had been tried there as well. Gutenberg''s advance was a system: letters cast individually in metal, hard enough to be reused thousands of times and rearranged into any page, an oil-based ink that would cling to metal, and a screw press adapted from the kind used to squeeze grapes.

The effect compounded. Within fifty years of Gutenberg''s first Bible, presses were working in more than two hundred European towns and had turned out millions of volumes, and a book cost a small fraction of what a copied one had. The scribes lost their trade. Readers who would never have held a book now owned one.'
 WHERE section = 'reading'
   AND passage LIKE '%invented by Johannes Gutenberg around 1440%'
   AND passage NOT LIKE '%oil-based ink%';

-- ── Why Rain Forests Matter ── 41 → 238 words · 4 questions
UPDATE questions SET passage = 'Rain forests cover about 6% of the Earth''s surface but are home to more than half of the world''s plant and animal species. They also play a critical role in regulating the Earth''s climate by absorbing large amounts of carbon dioxide.

That variety is hard to picture from a distance. A single hectare of Amazon forest can hold more than four hundred kinds of tree, while a hectare of northern forest in Canada may hold fewer than ten, each Amazon tree supporting insects, birds, and fungi found nowhere else. Botanists still describe species new to science every year, so the total remains an estimate rather than a count.

The soil beneath all this life is thin and surprisingly poor. Nearly all the nutrients are held in the living plants themselves, and what falls to the ground is taken up again so quickly that little ever accumulates. Land cleared for crops or pasture therefore produces well for only a few seasons before it is exhausted, which pushes the clearing on to the next patch. Burning the felled trees releases the carbon they had stored, so the loss counts twice.

The trees also draw water from the soil and breathe it into the air, and much of the rain that falls on the Amazon has fallen on it once already. How much can be cleared before that cycle weakens enough to dry out what is left is still argued over.'
 WHERE section = 'reading'
   AND passage LIKE '%home to more than half of the world%'
   AND passage NOT LIKE '%the loss counts twice%';

-- ── Debating Wealth and Virtue ── 57 → 240 words · 4 questions
UPDATE questions SET passage = 'Throughout history, societies have debated whether prosperity causes virtue or whether virtue causes prosperity. The ancient Greeks believed that character preceded wealth — that a just and disciplined person would naturally attract abundance. Later thinkers argued the reverse: that material security frees individuals to pursue moral development, since desperate people rarely have the luxury of ethical deliberation.

The older claim was never simply that good people get rich. It was that the qualities which make a person admirable — self-control, honesty, steady judgment — are the same qualities that keep a household or a city from ruin, so that prosperity follows character much as health follows good habits. Some version of this argument reappears whenever a society wants to read success as merit.

The opposing case has its own long history. Reformers in the nineteenth century campaigned for shorter hours and higher wages, arguing that a settled household was the ground in which character grew and that no amount of preaching would substitute for it.

The dispute resists settlement partly because virtue is difficult to measure. Wealth can be counted; honesty and generosity cannot, and what an observer accepts as evidence of good character tends to depend on what that observer already believes about money. Two people can look at the same prosperous neighbor and name different causes. Underneath the old question of which comes first sits a practical one: which of the two a society should try to change.'
 WHERE section = 'reading'
   AND passage LIKE '%causes virtue or whether virtue causes prosperity%'
   AND passage NOT LIKE '%virtue is difficult to measure%';

-- ── The Transcontinental Railroad ── 64 → 239 words · 4 questions
UPDATE questions SET passage = 'In 1869, the completion of the Transcontinental Railroad transformed American life. For the first time, passengers could travel from the East Coast to California in about a week, compared to the months required by wagon or ship. The railroad also accelerated westward settlement, as thousands of families relocated, and it created a national market by allowing goods to be shipped efficiently across the continent.

It was built from both ends at once. The Union Pacific worked west from Omaha; the Central Pacific worked east from Sacramento and had the granite of the Sierra Nevada to get through first, its crews, most of them Chinese immigrants, blasting tunnels at a pace measured in inches a day. The two met at Promontory Summit, Utah, on May 10, 1869.

What changed most was the clock, not the map. A wagon train to California took four to six months, and most sailing voyages around South America took just as long. The businesses built on the old pace — stagecoach lines, wagon freighters, the river ports — lost their customers within a few years. The railroads went on to standardize time itself, dividing the country into zones so schedules could be printed and trusted.

Not everyone gained. The same rails carried hunters and settlers onto the plains, where the bison herds collapsed and the Native nations who depended on them lost their way of life. What had been an expedition had become a ticket.'
 WHERE section = 'reading'
   AND passage LIKE '%Transcontinental Railroad transformed American life%'
   AND passage NOT LIKE '%Promontory Summit%';

-- ── Light in the Ocean Depths ── 89 → 239 words · 5 questions
UPDATE questions SET passage = 'In the pitch-black depths of the ocean, sunlight cannot reach, yet life thrives in spectacular fashion. Many deep-sea creatures produce their own light through a chemical process called bioluminescence. This glow serves several purposes: some fish use it to lure prey closer, while others flash patterns to attract mates or confuse predators. The anglerfish, for example, dangles a glowing lure above its mouth to draw in unsuspecting smaller fish. Scientists believe bioluminescence evolved independently in dozens of different marine species, making it one of nature''s most remarkable repeated inventions.

These animals live under conditions that would destroy most others. The water sits just above freezing, and pressure rises by one atmosphere every ten meters, so a fish a mile down bears over a hundred times the surface pressure. Such fish have soft flesh and light skeletons, and their cells carry compounds that keep proteins from being crushed out of shape.

That is part of why the glow is hard to study: a specimen dragged up in a net arrives warm and depressurized, and a dead animal does not light up. Most of what is known comes from submersibles and remotely operated vehicles that film these animals in place.

Much of the region has never been seen. A quarter of the seafloor has been mapped in detail, and hours of filming over an unvisited ridge still turn up animals nobody has described, some glowing in ways no one can explain.'
 WHERE section = 'reading'
   AND passage LIKE '%In the pitch-black depths of the ocean%'
   AND passage NOT LIKE '%crushed out of shape%';

-- ── Monarch Butterfly Migration ── 58 → 240 words · 3 questions
UPDATE questions SET passage = 'The monarch butterfly undertakes one of the longest migrations of any insect in North America. Each fall, millions of monarchs travel up to 3,000 miles from Canada and the United States to their wintering grounds in the mountains of central Mexico. Scientists are still studying how these butterflies navigate such vast distances using the sun as a compass.

No single butterfly makes the round trip. The monarchs that fly south in the fall are a distinct generation: they emerge in late summer, postpone breeding, and live months rather than weeks. In spring they start north, lay eggs on milkweed, and die; it takes their offspring, and their offspring''s offspring, to finish the journey back.

Their destination is a stand of oyamel fir high on a few mountainsides, where they gather on trunks and branches in numbers dense enough to bend the boughs, in air cool enough to hold them still without freezing.

How each new generation finds groves it has never seen is not fully answered. The sun compass depends on a clock in the antennae that corrects for the hour of the day, and there is evidence of a backup sense of the earth''s magnetic field, but neither accounts for the accuracy of arrival. What is clear is the trend: the forests have been logged, the milkweed the caterpillars need has thinned across the farmland they cross, and the winter clusters now cover far less ground than they did.'
 WHERE section = 'reading'
   AND passage LIKE '%longest migrations of any insect%'
   AND passage NOT LIKE '%oyamel fir%';

-- ── Verification ─────────────────────────────────────────────
-- Expect one row per passage above: word_count between 200 and 240,
-- question_count unchanged, and copies = 1 (all rows share identical text).

WITH touched(title, frag) AS (VALUES
  ('Gutenberg and the Printing Press', 'invented by Johannes Gutenberg around 1440'),
  ('Why Rain Forests Matter', 'home to more than half of the world'),
  ('Debating Wealth and Virtue', 'causes virtue or whether virtue causes prosperity'),
  ('The Transcontinental Railroad', 'Transcontinental Railroad transformed American life'),
  ('Light in the Ocean Depths', 'In the pitch-black depths of the ocean'),
  ('Monarch Butterfly Migration', 'longest migrations of any insect')
)
SELECT t.title,
       array_length(regexp_split_to_array(btrim(q.passage), '\s+'), 1) AS word_count,
       COUNT(*) AS question_count,
       COUNT(DISTINCT q.passage) AS copies
  FROM touched t
  JOIN questions q
    ON q.section = 'reading'
   AND q.passage LIKE '%' || t.frag || '%'
 GROUP BY t.title, word_count
 ORDER BY t.title;
