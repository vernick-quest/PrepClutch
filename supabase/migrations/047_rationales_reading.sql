-- 047 — Rewrite reading explanations (228 rows)
--
-- Updates ONE column: explanation. Nothing else is assigned — not prompt,
-- not options, not correct_index, not difficulty — so no student score can
-- move. This file contains UPDATE statements only: nothing is added,
-- removed or restructured, and no history table is touched.
--
-- ORDER-INDEPENDENT OPTIONS GUARD. Migration 019 shuffled every pre-019
-- questions options array, so comparing options to a literal array in the
-- originally authored order matches almost nothing: migration 039 was
-- applied that way and silently updated only ~71 of its 250 rows. 019 only
-- PERMUTED the options, so a live rows option SET is unchanged — the same
-- key 028 relies on. Each WHERE therefore sorts both sides and compares:
--
--   (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
--     = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(<literal>) v)
--
-- Both sides are sorted by the SAME expression inside the same query, so the
-- comparison holds under any database collation. The literal is left in its
-- authored order and never pre-sorted in Python, because Python sorts by code
-- point while Postgres sorts by collation, and these options differ in case,
-- punctuation and leading digits — exactly where the two orders diverge.
--
-- Prompts are NOT unique in this bank and neither are option sets, so both
-- are required. Verified against the reconstructed live section: prompt alone
-- is ambiguous and option set alone is ambiguous, while section + prompt +
-- sorted option set matches exactly one row for every statement below.
--
-- Setting the same text twice is a no-op, so this file is idempotent.
--
-- 12 of the 240 reading rationales are NOT applied here. Migrations 031 and
-- 033 appended paragraphs to 31 passages (the original text survives as the
-- opening paragraph). 11 of these explanations describe the passages FINAL
-- or CLOSING sentence, which is no longer final, and 1 states that the
-- passage never mentions rod cells, which the deepened passage now does.
-- They are listed at the foot of this file for manual review rather than
-- being written to rows they would misdescribe.
--
-- 4 stems reworded by 032 use their CURRENT wording here, not the wording
-- carried in the source rationale file, which predates 032.

UPDATE questions SET explanation = 'The passage traces the fall journey: monarchs leave Canada and the United States and end up in the mountains of central Mexico, where they spend the cold months. Canada is tempting because it appears in that same sentence, but it is where the migration starts, not where the butterflies wait out winter.'
  WHERE section = 'reading' AND prompt = 'According to the passage, where do monarch butterflies spend the winter?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Canada", "The United States", "The mountains of central Mexico", "South America"]'::JSONB) v);

UPDATE questions SET explanation = 'The second sentence gives the distance: monarchs travel up to 3,000 miles from Canada and the United States down to Mexico. That is the only distance figure in the passage. A smaller number like 2,000 miles may feel like a safer guess for an insect, but the text never supports it.'
  WHERE section = 'reading' AND prompt = 'How far can monarch butterflies travel during migration?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Up to 1,000 miles", "Up to 2,000 miles", "Up to 3,000 miles", "Up to 4,000 miles"]'::JSONB) v);

UPDATE questions SET explanation = 'Here navigate describes how butterflies work out their route across thousands of miles using the sun as a compass, so it means finding one''s way. Flying fast is tempting because the passage is about a very long journey, but speed is not what a compass helps with. A compass gives direction, not velocity.'
  WHERE section = 'reading' AND prompt = 'As used in the passage, ''navigate'' most nearly means:'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Fly fast", "Find one''s way", "Avoid danger", "Rest and recover"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage compares two eras: about a week by rail, versus the months required by wagon or ship before the railroad existed. So the answer is several months. About a week is tempting because that number sits right there in the sentence, but it describes travel after the railroad was finished, not before.'
  WHERE section = 'reading' AND prompt = 'Before the railroad, approximately how long did it take to travel to California from the East Coast?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["A few days", "About a week", "Several months", "About a year"]'::JSONB) v);

UPDATE questions SET explanation = 'Combine two things the passage says: the railroad sped up westward settlement, and it created a national market by moving goods efficiently. Those are geographic and economic connection together. The idea that most Americans moved to California overstates things. The passage mentions thousands of families relocating, which is many people but nowhere near most of a nation.'
  WHERE section = 'reading' AND prompt = 'Which conclusion is best supported by the passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The railroad made the wagon industry more profitable.", "The railroad had mostly negative effects on American life.", "The railroad connected economic and geographic parts of the nation.", "The railroad caused most Americans to move to California."]'::JSONB) v);

UPDATE questions SET explanation = 'In this sentence the railroad accelerated westward settlement, meaning families relocated in greater numbers and more quickly than before, so accelerated means sped up. Slowed is the opposite, and it clashes with everything around it about faster travel and a growing national market. When a word sits among improvements, expect it to point upward.'
  WHERE section = 'reading' AND prompt = 'As used in the passage, ''accelerated'' most nearly means:'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Slowed", "Stopped", "Sped up", "Reversed"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage opens by saying the railroad transformed American life, then backs that claim up with faster travel, westward settlement, and a national market. That sweep is the main idea. The 1869 completion date is a true detail from the first sentence, but one fact cannot carry a paragraph built entirely on effects.'
  WHERE section = 'reading' AND prompt = 'What is the main idea of this passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The railroad was completed in 1869.", "Travel to California was once very slow.", "The Transcontinental Railroad greatly changed American society and economy.", "Thousands of families moved west after 1869."]'::JSONB) v);

UPDATE questions SET explanation = 'Festinger described the discomfort people feel when they hold two conflicting beliefs simultaneously, meaning both beliefs are in mind at once. The clash only exists if they overlap in time. Repeatedly is tempting because it also describes something happening more than once, but over and over is not the same as together.'
  WHERE section = 'reading' AND prompt = 'As used in the passage, ''simultaneously'' most nearly means:'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Eventually", "Repeatedly", "At the same time", "Gradually"]'::JSONB) v);

UPDATE questions SET explanation = 'The opening sentence pairs two numbers: rain forests cover about six percent of Earth''s surface yet hold more than half of all plant and animal species. Six percent is the land figure. The 50 percent figure is tempting because it appears in that same sentence, but it describes the share of species, not the share of ground.'
  WHERE section = 'reading' AND prompt = 'What percentage of Earth''s surface do rain forests cover?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["25%", "50%", "6%", "12%"]'::JSONB) v);

UPDATE questions SET explanation = 'Put the two facts together: rain forests shelter over half the world''s species and they pull carbon dioxide out of the air. Losing them costs both, so serious environmental harm follows. Saying carbon dioxide is not harmful runs against the passage, which treats absorbing it as a service rain forests perform for the climate.'
  WHERE section = 'reading' AND prompt = 'Which conclusion is most strongly supported by the passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Most species on Earth live in oceans.", "Destroying rain forests could have significant environmental consequences.", "Rain forests should be converted to farmland.", "Carbon dioxide is not harmful to the environment."]'::JSONB) v);

UPDATE questions SET explanation = 'Rain forests regulate climate by absorbing carbon dioxide, which means they help keep conditions steady, so regulating means controlling. Measuring is tempting because regulate can suggest gauges and readings in other settings, but forests are not taking measurements here. They are acting on the climate rather than recording it.'
  WHERE section = 'reading' AND prompt = 'As used in the passage, ''regulating'' most nearly means:'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Destroying", "Controlling", "Measuring", "Ignoring"]'::JSONB) v);

UPDATE questions SET explanation = 'The Greeks put character first, saying a disciplined, fair-minded person naturally attracts abundance. Later thinkers flipped it, arguing that material security is what frees people to develop morally. Same two ideas, opposite order. Saying the two views agree that virtue and prosperity are unrelated misses that both sides insist on a link, only in different directions.'
  WHERE section = 'reading' AND prompt = 'Which best describes the relationship between the two arguments presented in the passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["They agree that virtue and prosperity are unrelated.", "They offer opposing views on which comes first — virtue or prosperity.", "They both argue that ancient Greeks were correct.", "They suggest that only wealthy people can be virtuous."]'::JSONB) v);

UPDATE questions SET explanation = 'Calling ethical deliberation a luxury treats it as something that takes spare time and security, which people in desperate circumstances rarely have. That is the point the later thinkers build on. Reading it as ethics being only for the wealthy to study goes further than the text, which says desperate people lack the room, not the right.'
  WHERE section = 'reading' AND prompt = 'The phrase ''rarely have the luxury of ethical deliberation'' suggests that:'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Ethics is only for wealthy people to study.", "People in desperate circumstances may not have the time or resources to focus on moral choices.", "Ancient Greeks were wrong about virtue.", "Ethical deliberation is not important."]'::JSONB) v);

UPDATE questions SET explanation = 'The passage raises a question societies have argued over for centuries, then lays out two competing answers without choosing between them. The debated relationship between prosperity and virtue is the main idea. Saying wealth always leads to moral development takes one side of that debate and states it as settled fact, which the passage never does.'
  WHERE section = 'reading' AND prompt = 'What is the main idea of this passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Ancient Greeks were more virtuous than modern people.", "Prosperity and virtue have a debated, complex relationship.", "Material wealth always leads to moral development.", "Ethical deliberation is only possible for the wealthy."]'::JSONB) v);

UPDATE questions SET explanation = 'The Greeks believed character preceded wealth, and the rest of the sentence explains that a fair, disciplined person would then attract abundance, so character comes first in time. Caused is tempting because the sentence does describe a chain of events, but preceded marks order only. One thing can come before another without producing it.'
  WHERE section = 'reading' AND prompt = 'As used in the passage, ''preceded'' most nearly means:'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Followed", "Came before", "Replaced", "Caused"]'::JSONB) v);

UPDATE questions SET explanation = 'The second sentence gives the reason outright: before the press, books were copied by hand, which made them rare and expensive. The idea that most people could not read is tempting because the passage does discuss literacy, but literacy spreading is described as a result of cheap books, not as the reason books were scarce.'
  WHERE section = 'reading' AND prompt = 'Before the printing press, why were books rare?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Paper had not yet been invented.", "Books were copied by hand, making them slow and expensive to produce.", "Governments restricted book production.", "Most people did not know how to read."]'::JSONB) v);

UPDATE questions SET explanation = 'The first sentence dates the invention: Gutenberg built the press around 1440. A year like 1540 is tempting because printing did keep spreading through that century and the numbers look alike, but the passage supplies only one date. With date questions, go back and read the digits instead of trusting memory.'
  WHERE section = 'reading' AND prompt = 'Approximately when was the printing press invented?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["1340", "1440", "1540", "1640"]'::JSONB) v);

UPDATE questions SET explanation = 'The sentence says the press let ideas circulate more freely across regions and social classes, so circulate means to move around and reach many places. Being censored is tempting because censorship often comes up alongside printing, but the passage never mentions it, and the word freely points to ideas spreading rather than being blocked.'
  WHERE section = 'reading' AND prompt = 'As used in the passage, ''circulate'' most nearly means:'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Stop", "Move around freely", "Be censored", "Be destroyed"]'::JSONB) v);

UPDATE questions SET explanation = 'The press made books cheap and helped ideas cross social classes, so the largest gain went to people who had been priced out before. Wealthy nobles are tempting because they were the ones already reading, but they could afford hand-copied books all along. When something becomes affordable, those who could not afford it gain most.'
  WHERE section = 'reading' AND prompt = 'Based on the passage, which group likely benefited MOST from the printing press?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Wealthy nobles who could already afford hand-copied books.", "Church leaders who controlled book production.", "Common people who previously had little access to books.", "Scribes who copied books by hand."]'::JSONB) v);

UPDATE questions SET explanation = 'The passage says the press revolutionized the spread of information, then shows how through cheaper books, spreading literacy, and circulating ideas. That transformation is the main idea. The fact that books were too expensive before 1440 is accurate, but the author supplies it as background to make the change look dramatic, not as the point.'
  WHERE section = 'reading' AND prompt = 'What is the main idea of this passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Gutenberg was an important historical figure.", "Books were too expensive before 1440.", "The printing press transformed how information was shared in Europe.", "Literacy was rare in medieval Europe."]'::JSONB) v);

UPDATE questions SET explanation = 'Before describing what the press did, the author shows the old method: one book at a time, copied by hand, rare and costly. That contrast makes the leap to fast, cheap printing feel as large as it was. Reading it as praise for handmade books misses the tone, since slow and expensive are drawbacks, not virtues.'
  WHERE section = 'reading' AND prompt = 'The author includes the detail about books being ''copied by hand'' primarily to:'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Show that scribes were important workers.", "Provide contrast that highlights how significant the printing press was.", "Argue that handmade books were superior.", "Prove that literacy was impossible before Gutenberg."]'::JSONB) v);

UPDATE questions SET explanation = 'The passage says the glow serves several purposes and then names them: luring prey closer, attracting mates, and confusing predators. An answer covering multiple survival uses matches that list. Helping the creatures see in the dark sounds sensible because light usually means vision, but the passage never says that, and every use it lists affects another animal.'
  WHERE section = 'reading' AND prompt = 'What is the PRIMARY reason deep-sea creatures produce bioluminescence, according to the passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["To help them see in the dark", "To serve multiple survival purposes such as luring prey and attracting mates", "To warm the cold ocean water around them", "To communicate with scientists on the surface"]'::JSONB) v);

UPDATE questions SET explanation = 'In this passage the anglerfish dangles a glowing lure in front of its mouth to draw in unsuspecting smaller fish, so lure means bait, something that pulls an animal closer. Calling it a glowing chemical mixes up two ideas. The chemical process is bioluminescence, the light itself. The lure is what that light is being used as.'
  WHERE section = 'reading' AND prompt = 'What does the word "lure" mean as used in the passage about bioluminescence?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["A type of glowing chemical", "Something used to attract or draw in an animal", "A deep-sea predator", "The process of producing light"]'::JSONB) v);

UPDATE questions SET explanation = 'Independently means unrelated species arrived at the same trait separately, dozens of times over. A trait that keeps reappearing on its own is one that pays off, so producing light must offer a real survival advantage. A shared common ancestor is the opposite reading. Inherited traits do not need to evolve again and again.'
  WHERE section = 'reading' AND prompt = 'Which conclusion can be drawn from the fact that bioluminescence "evolved independently in dozens of different marine species"?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["All deep-sea creatures share a common ancestor", "Producing light must provide a strong survival advantage", "Scientists invented bioluminescence through genetic engineering", "Only anglerfish are capable of producing light"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage introduces bioluminescence, explains that it is a chemical process, and walks through what deep-sea animals use the light for. How and why these creatures make their own light covers all of it. The anglerfish diet is too narrow. That fish appears for one sentence as an example, not as the subject.'
  WHERE section = 'reading' AND prompt = 'What is this passage mainly about?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The diet of the anglerfish", "How and why deep-sea creatures produce their own light", "Why the ocean depths are completely dark", "The history of marine biology research"]'::JSONB) v);

UPDATE questions SET explanation = 'Right after saying that some fish use light to lure prey, the author names the anglerfish and describes its dangling glow. That is a general claim followed by one concrete case, which makes the idea easy to picture. Calling anglerfish the most dangerous ocean creature is not the point, since the passage never ranks them against anything.'
  WHERE section = 'reading' AND prompt = 'Why does the author mention the anglerfish specifically?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["To show that anglerfish are the most dangerous ocean creatures", "To provide a specific, concrete example of bioluminescence used for hunting", "To explain how bioluminescence was first discovered", "To argue that all fish should be studied more carefully"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage says deaf communities everywhere developed informal signing on their own, but the first formal school opened in Paris in 1760. Formal and organized point to that school. Hartford is tempting because it names a school too, but the American School for the Deaf came later, in 1817, and grew out of the Paris tradition.'
  WHERE section = 'reading' AND prompt = 'According to the passage, where did sign language first develop in an organized way?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Hartford, Connecticut", "Paris, France", "Throughout ancient Greece", "Washington, D.C."]'::JSONB) v);

UPDATE questions SET explanation = 'Two facts combine: Laurent Clerc was a French teacher shaped by the Paris school, and he helped found the first American school for the deaf in 1817. Knowledge carried by a person carries its history along, so ASL and French Sign Language share roots. Saying ASL developed with no European influence contradicts Clerc''s role entirely.'
  WHERE section = 'reading' AND prompt = 'What inference can be made about ASL based on information in the passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["ASL and French Sign Language share some historical roots", "ASL was invented entirely without any European influence", "ASL is simpler than spoken English", "ASL can only be understood by people who are completely deaf"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage opens by calling sign language complete and complex, traces its formal history from Paris to Hartford, and closes by insisting sign languages have their own grammar. Real languages with a formal history covers all three parts. Naming Clerc the most important figure in language history reaches far past a passage that mentions him once.'
  WHERE section = 'reading' AND prompt = 'What is the main idea of this passage about sign language?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Laurent Clerc was the most important figure in the history of language", "Sign languages are real, complete languages with a formal history of development", "Deaf people communicate less effectively than hearing people", "All sign languages around the world are essentially the same"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage names the driver in its second sentence: energy from the sun evaporates water and starts the cycle. The gravitational pull of the moon is tempting because it really does move ocean water as tides, but tides never appear in this passage, and the cycle described here begins with evaporation rather than with water being pulled around.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what drives the water cycle?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The rotation of the Earth", "Energy from the sun", "The gravitational pull of the moon", "Wind patterns alone"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage says rising vapor cools and condenses into tiny droplets, so condense means changing from gas back into liquid. Freezing into ice crystals is tempting because snow turns up a sentence later, but freezing is liquid becoming solid. The step being described is the one that forms cloud droplets.'
  WHERE section = 'reading' AND prompt = 'What does "condenses" mean as used in the passage about the water cycle?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Evaporates into the air", "Changes from gas back into liquid", "Freezes into ice crystals", "Sinks into the ground"]'::JSONB) v);

UPDATE questions SET explanation = 'The sun''s energy is what evaporates water, and evaporation is the first step everything after it depends on. Weaken that step and the whole cycle slows. The idea that rainfall would increase significantly is tempting because rain feels like the main event, but rain falls from clouds made of vapor, and less evaporation means less vapor to begin with.'
  WHERE section = 'reading' AND prompt = 'Which of the following would most likely happen if the sun''s energy reaching Earth were significantly reduced?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Rainfall would increase significantly", "The water cycle would slow down or weaken", "Clouds would form more quickly", "Rivers would flow faster"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage walks through evaporation, condensation, precipitation, and collection, then explains what the cycle does for the planet. Explaining that continuous process is its purpose. Describing how clouds are formed is too narrow. Clouds get one sentence as a single stage, and the passage keeps moving through the rest of the loop.'
  WHERE section = 'reading' AND prompt = 'What is the passage''s main purpose?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["To argue that humans must protect the water supply", "To explain the continuous process by which water moves through Earth''s systems", "To describe how clouds are formed in detail", "To compare different forms of precipitation"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage says cuneiform was at first used almost exclusively for economic records, tracking grain, livestock, and trade goods. Laws and royal decrees are tempting because they do appear in the list of uses, but the passage places them in the expansion that happened over later centuries, not at the start.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what was cuneiform first used to record?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Laws and royal decrees", "Religious ceremonies", "Economic records such as grain and livestock", "Epic poems and stories"]'::JSONB) v);

UPDATE questions SET explanation = 'Royal decrees sit beside laws and religious texts as things a ruler put into writing, so a decree is an official order from someone in authority. Trade agreements are tempting because the passage does mention trade goods, but that trade belongs to the earlier economic records, and an agreement is a deal between parties rather than a command.'
  WHERE section = 'reading' AND prompt = 'What does the word "decrees" most likely mean in this passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Ancient trade agreements", "Official orders or commands issued by a ruler", "Written prayers to the gods", "Historical maps of the region"]'::JSONB) v);

UPDATE questions SET explanation = 'Cuneiform started with counts of grain and livestock and grew to carry laws, stories, religion, and royal orders. Writing takes on new jobs when there is more to keep track of, so the society itself was growing more complicated. Claiming it stayed simple and unchanged contradicts that steady expansion over centuries.'
  WHERE section = 'reading' AND prompt = 'What does the development of cuneiform over centuries suggest about ancient Mesopotamian society?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Mesopotamian society stayed simple and unchanged", "Society grew more complex, with expanding needs for communication and record-keeping", "Only priests and kings were ever literate", "The economy collapsed after writing was invented"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage introduces cuneiform, describes the reed stylus and clay tablets, names its earliest use, and traces its spread into law and literature. Origin and development covers that whole arc. The plot of the Epic of Gilgamesh is too narrow, appearing at the end as one example of what cuneiform eventually preserved.'
  WHERE section = 'reading' AND prompt = 'What is the passage mainly about?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The plot of the Epic of Gilgamesh", "The geography of ancient Mesopotamia", "The origin and development of cuneiform writing", "Why ancient civilizations needed trade records"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage says the first recorded Games took place in 776 BCE in the city of Olympia. Athens is tempting because it also shows up in the passage, but Athens is where the modern Olympics were revived in 1896, more than two thousand years later. Ancient origin and modern revival are different cities here.'
  WHERE section = 'reading' AND prompt = 'According to the passage, where did the ancient Olympic Games originate?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Athens, Greece", "Sparta, Greece", "Olympia, Greece", "Rome, Italy"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage says a truce was declared during the Games so that competitors could travel safely, which is the reason being asked for. Honoring Zeus is tempting because the Games were held in his honor and the passage says so, but it ties that honor to the Games themselves and gives the truce a separate, practical purpose.'
  WHERE section = 'reading' AND prompt = 'Why was a truce declared during the ancient Olympic Games?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["To honor the god Zeus with a period of peace", "To allow competitors to travel to Olympia without danger", "To give athletes time to rest before competing", "To prevent cheating during the events"]'::JSONB) v);

UPDATE questions SET explanation = 'Two details combine: athletes came from city-states all across Greece, and fighting paused so they could travel. Separate communities suspending conflict for one shared event points to the Games unifying them. Saying the city-states were always at peace goes too far, since a truce was only necessary because they were not.'
  WHERE section = 'reading' AND prompt = 'What can be inferred about the ancient Olympics from the fact that city-states across Greece sent athletes?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The Games were not very well known outside of Olympia", "The Games were a unifying event for otherwise separate Greek communities", "Only the wealthiest city-states participated", "Greek city-states were always at peace with one another"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage says a vaccine introduces a harmless version of a pathogen, such as a weakened or inactivated virus or a piece of its protein, so the immune system can learn it. A full-strength dose is tempting because a vaccine does contain something from the pathogen, but harmless and weakened are the passage''s own words.'
  WHERE section = 'reading' AND prompt = 'According to the passage, how do vaccines teach the immune system to fight disease?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["By introducing a full-strength dose of the disease", "By introducing a harmless form of the pathogen so the immune system learns to fight it", "By injecting antibodies directly from other people", "By strengthening the immune system through nutrition"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage names immunological memory right after describing how the immune system remembers a pathogen and responds rapidly on a second encounter. That recognize-and-react-quickly ability is the definition. A list of diseases a person survived is tempting because memory sounds like a record, but this memory is a working defense, not a history.'
  WHERE section = 'reading' AND prompt = 'What does "immunological memory" mean as used in the passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["A list of diseases a person has survived", "The immune system''s ability to recognize and quickly respond to a previously encountered pathogen", "The process by which vaccines are manufactured", "A type of protein that destroys viruses"]'::JSONB) v);

UPDATE questions SET explanation = 'The author calls antibodies proteins designed to neutralize that specific threat, and the word specific carries the meaning: each antibody matches one pathogen rather than germs in general. That is why a vaccine for one disease does not cover them all. Calling antibodies man-made medications misreads it, since the body produces these proteins itself.'
  WHERE section = 'reading' AND prompt = 'Why does the author describe antibodies as "proteins designed to neutralize that specific threat"?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["To suggest that antibodies are man-made medications", "To emphasize that each antibody targets only one specific pathogen, not all germs", "To explain why vaccines must be refrigerated", "To describe the side effects of vaccination"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage says that on a later encounter the immune system remembers the pathogen and responds rapidly, often stopping the disease before symptoms appear. That means a fast response and probably no illness. The idea that vaccines weaken the immune system reverses the passage, which describes vaccination as training the defense, not wearing it down.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what would most likely happen if a vaccinated person were exposed to the real pathogen?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["They would become very ill because vaccines weaken the immune system", "Their immune system would respond quickly and likely prevent the disease", "They would need to receive another vaccine immediately", "Their body would produce no antibodies at all"]'::JSONB) v);

UPDATE questions SET explanation = 'The first sentence says bees matter not because of their honey but because they pollinate, and the rest explains that pollination is what lets plants produce fruits, vegetables, nuts, and seeds. Honey is a trap the passage sets on purpose. The author names it only to rule it out as the real reason bees matter.'
  WHERE section = 'reading' AND prompt = 'According to the passage, why are bees essential to many ecosystems?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["They produce honey that humans and animals eat", "They pollinate plants that produce food for many species", "They control insect populations by eating harmful pests", "They help spread seeds by carrying them in their legs"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage defines the term as it goes: bees moving flower to flower transfer pollen, and that transfer lets plants reproduce. Making honey from nectar is tempting because nectar sits in the same sentence, but nectar is what bees collect for themselves. The pollen moving between flowers is the part that counts here.'
  WHERE section = 'reading' AND prompt = 'What does "pollination" mean as described in the passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The process of bees making honey from nectar", "The transfer of pollen between flowers that allows plants to reproduce", "A method bees use to communicate danger", "The collection of nectar by bees for energy"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage says roughly one-third of the food humans eat relies on pollination, so losing bees puts that share at risk. Saying only honey production would decline is tempting, but it is the exact idea the passage opens by dismissing. Honey is the small thing, and the food supply built on pollination is the large one.'
  WHERE section = 'reading' AND prompt = 'What would most likely happen to human food supplies if bee populations disappeared entirely?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Food supplies would be largely unaffected", "About one-third of human foods would be at risk", "Only honey production would decline", "Animals would lose food, but humans would be fine"]'::JSONB) v);

UPDATE questions SET explanation = 'After explaining how much food depends on bees, the author names habitat loss, pesticides, and disease as the real causes of a sharp decline. Naming specific threats makes the danger concrete and sets up the warning about food shortages. Reading it as bees thriving despite minor challenges ignores the words sharply and alarming.'
  WHERE section = 'reading' AND prompt = 'Why does the author mention habitat loss, pesticides, and disease?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["To prove that bees are a nuisance to farmers", "To show that bees are thriving despite some minor challenges", "To highlight real threats to bee populations and underscore the seriousness of their decline", "To explain how new bee species are evolving"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage lists what the brain does while the body lies still: it consolidates memories, clears out waste products, and processes emotions during REM sleep. All three belong together. Saying the brain shuts down to save energy contradicts the opening claim that it stays remarkably active and performs critical maintenance work.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what happens in the brain during sleep?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The brain shuts down to save energy", "The brain consolidates memories, clears waste, and processes emotions", "The brain produces growth hormones only during waking hours", "The brain replays the day''s experiences in order"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage explains consolidate as it uses it, describing the transfer of information from short-term to long-term storage, so the word means organizing memories and making them stick. Erasing memories is tempting because sleep does involve clearing things out, but what the brain clears is waste proteins. Consolidating keeps information rather than deleting it.'
  WHERE section = 'reading' AND prompt = 'What does "consolidates" mean as used in the passage about sleep?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Erases memories that are no longer needed", "Strengthens and organizes memories for long-term storage", "Creates new dreams during deep sleep", "Transfers waste products out of the brain"]'::JSONB) v);

UPDATE questions SET explanation = 'Combine two statements: sleep deprivation impairs memory, judgment, and emotional regulation, and teenagers typically need seven to nine hours. Students lean on memory and clear thinking all day, so short sleep costs them there. The claim that sleeping past nine hours improves grades is absent from the passage, which gives a range and never mentions grades.'
  WHERE section = 'reading' AND prompt = 'What can be inferred from the passage about the importance of sleep for students?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Students who sleep more than nine hours will have better grades", "Not getting enough sleep can hurt a student''s ability to remember and think clearly", "Dreams during REM sleep help students study better", "Teenagers need less sleep than adults"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage opens by saying sleep is far more than resting, then shows the brain working through the night on memory, waste, and emotion before calling adequate sleep essential. That is the main idea. Dreams as the most important part is too narrow, since REM and dreams take one sentence among several jobs.'
  WHERE section = 'reading' AND prompt = 'What is the main idea of the passage about sleep?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Dreams are the most important part of sleep", "Sleep is an active and essential process for brain and body health", "Teenagers sleep too much and should spend more time studying", "The brain is less active at night than during the day"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage says jazz grew out of the vibrant African American communities of New Orleans in the late 1800s and early 1900s. Chicago is tempting because it appears later in the same passage, but it shows up as a place jazz traveled to along the Mississippi River, not as the place jazz began.'
  WHERE section = 'reading' AND prompt = 'According to the passage, where did jazz music first develop?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Chicago, Illinois", "New York City", "New Orleans, Louisiana", "Memphis, Tennessee"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage explains the word in the next breath: musicians created music on the spot rather than reading from written scores, so improvisational means invented in the moment. European classical influence is genuinely mentioned in the passage, but it describes where jazz got its harmonic structures, not what improvising means.'
  WHERE section = 'reading' AND prompt = 'What does "improvisational" most likely mean in the context of the passage about jazz?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Based on strict written musical rules", "Created spontaneously in the moment rather than planned in advance", "Influenced by European classical music", "Performed only for large audiences"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage says jazz spread up the Mississippi River to Chicago and then to New York, and rivers were how people and goods moved in that era. Music travels with the people who play it, so migration along those routes fits. Radio is tempting for a modern reader, but broadcasting is never mentioned here.'
  WHERE section = 'reading' AND prompt = 'What can be inferred about the spread of jazz from New Orleans to Chicago and New York?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Jazz spread because musicians were paid to move to other cities", "Jazz traveled with people migrating along river and trade routes", "Radio broadcasts were the main cause of jazz''s spread", "Northern cities invented their own version of jazz independently"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage covers where jazz came from, the traditions blended into it, how it was performed, and how it moved north to Chicago and New York. Origins, influences, and spread holds all of that. Comparing blues and jazz is too narrow, since blues is named once as one ingredient and never contrasted with jazz.'
  WHERE section = 'reading' AND prompt = 'What is the passage mainly about?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The life of a famous jazz musician", "The origins, influences, and spread of jazz as an American art form", "Why New Orleans is the best city for music", "The differences between blues and jazz music"]'::JSONB) v);

UPDATE questions SET explanation = 'Each cone type answers to a different wavelength, and those wavelengths line up with red, green, and blue, so wavelength names a measurable difference in light that corresponds to color. Treating wavelength as brightness is tempting since both describe light, but brightness is about intensity, and the passage ties wavelength to which color appears.'
  WHERE section = 'reading' AND prompt = 'What does "wavelength" suggest about light in the context of this passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Light travels in waves of different sizes, and color is related to those differences", "Light is a solid particle that bounces off objects", "Wavelength refers to the brightness of a color", "Only visible light has a wavelength"]'::JSONB) v);

UPDATE questions SET explanation = 'Put two facts together: each cone type carries the signal for one range of wavelengths, and colorblind people are missing a cone type or have one that does not work properly. A missing cone means the brain never receives part of the information. Seeing only black and white overstates it, since the other cone types still function.'
  WHERE section = 'reading' AND prompt = 'What can be inferred about why colorblind people confuse certain colors?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Their brains are unable to process electrical signals", "Without a functioning cone type, their brain receives incomplete information about certain wavelengths", "They have too many cone cells, creating confusion", "They see the world in black and white only"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage explains how cones detect wavelengths and how the brain combines those signals into the colors we perceive, then uses colorblindness to show what happens when a cone type is missing. Calling the eye the most complex organ in the body is a claim the passage never makes. It stays focused on how color vision works.'
  WHERE section = 'reading' AND prompt = 'What is the main idea of this passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The eye is the most complex organ in the human body", "Color vision works through three types of specialized cells that detect light wavelengths", "Colorblindness is a very common condition that affects everyone slightly", "The brain produces color without any input from the eyes"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage credits Alexander Graham Bell with creating the first practical telephone and receiving the first patent for it. Thomas Watson is tempting because he appears in the famous first call, but he is Bell''s assistant, the person on the other end of the line. The passage names him only inside that quotation.'
  WHERE section = 'reading' AND prompt = 'According to the passage, who is credited with inventing the telephone?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Thomas Watson", "A Scottish engineer in Glasgow", "Alexander Graham Bell", "An unnamed inventor who filed first"]'::JSONB) v);

UPDATE questions SET explanation = 'In this passage the patent is what Bell filed to secure his place in history, beating a rival by hours, so a patent is an official legal claim giving an inventor exclusive rights. A scientific paper is tempting because both are documents about an invention, but a paper explains how something works while a patent establishes ownership.'
  WHERE section = 'reading' AND prompt = 'What does "patent" mean as used in the passage about the telephone?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["A financial prize for inventors", "An official legal document granting the inventor exclusive rights to their invention", "A scientific paper describing how the telephone works", "A government contract to build telephones"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage says other inventors were working on similar devices at the same time, and that Bell filed only hours ahead of one of them. Together those facts show the breakthrough was within several people''s reach and filing order decided the credit. Saying Bell stole the idea is unsupported, since the passage describes a race, not theft.'
  WHERE section = 'reading' AND prompt = 'What does the detail about Bell filing his patent "just hours before a competing inventor" suggest?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Bell stole his ideas from the competing inventor", "The invention of the telephone was not Bell''s idea at all", "Multiple inventors were close to the same breakthrough, and timing determined who got credit", "Bell was not a serious inventor and succeeded only by luck"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage introduces the telephone''s invention, explains where Bell''s ideas came from, quotes the first call, and closes with the patent race. The invention plus the story behind the patent holds all of that. Bell''s full life story is too broad, since the passage offers only the details connected to this one device.'
  WHERE section = 'reading' AND prompt = 'What is the passage mainly about?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The life story of Alexander Graham Bell", "Thomas Watson''s contributions to science", "The invention of the telephone and the story behind Bell''s patent", "How telephones have changed since 1876"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage says stress builds where plates meet until they suddenly slip or grind past one another, releasing energy in waves that shake the ground. That release is the earthquake. Volcanic eruptions are tempting because volcanoes appear here too, but the passage presents them as another result of plate boundaries, not as the cause of quakes.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what causes earthquakes?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The cooling of Earth''s core", "The sudden release of energy when tectonic plates slip or grind", "Pressure from underground rivers and caves", "Volcanic eruptions that shake surrounding rock"]'::JSONB) v);

UPDATE questions SET explanation = 'Tectonic describes the plates as giant rocky slabs that make up Earth''s outer layer and creep along a few centimeters a year, so the word points to large-scale structure and movement of the surface. Saying the plates lie only beneath the oceans is tempting because of the Pacific Ring of Fire, but they cover the entire outer layer.'
  WHERE section = 'reading' AND prompt = 'What does "tectonic" suggest about Earth''s plates, based on context?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["They are temporary and dissolve over millions of years", "They relate to the large-scale structural movements of Earth''s outer layer", "They are found only beneath the oceans", "They are heated by the sun rather than Earth''s interior"]'::JSONB) v);

UPDATE questions SET explanation = 'Two statements combine: earthquakes and volcanoes happen where plates meet, and most of the world''s earthquakes and volcanoes ring the Pacific. Follow that and the Pacific must be edged by many plate boundaries. Warm ocean water is not the reason, since the passage traces the heat driving plates to Earth''s interior rather than to the ocean water itself.'
  WHERE section = 'reading' AND prompt = 'What can be inferred about why the "Ring of Fire" has so many earthquakes and volcanoes?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The Pacific Ocean is unusually warm, heating the plates beneath it", "Several tectonic plate boundaries meet around the Pacific Ocean", "The Ring of Fire is made of different rock than other regions", "Earthquakes in one region trigger earthquakes across the Pacific"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage explains what tectonic plates are, how heat from inside Earth moves them, and how that movement produces both earthquakes and volcanoes. That full chain is the topic. How volcanoes form beneath the sea is too narrow, since volcanoes get one sentence and the passage never limits them to the ocean floor.'
  WHERE section = 'reading' AND prompt = 'What is this passage primarily about?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["How volcanoes form beneath the sea", "The composition of Earth''s inner core", "How tectonic plates move and cause earthquakes and volcanoes", "The history of earthquake measurement"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage splits stars by size at the end: small stars like our sun shed their outer layers and leave a white dwarf, while massive stars collapse and explode in a supernova that may leave a neutron star or black hole. The white dwarf ending is real, but it belongs to the small stars, not the massive ones.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what is the final stage in the life of a massive star?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["They slowly cool into a white dwarf", "They expand permanently into a red giant", "They collapse and explode in a supernova, possibly becoming a neutron star or black hole", "They break apart into smaller stars"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage says fusion ignites once the core grows hot enough, and that this moment is when a star is born and begins burning hydrogen, so fusion is the energy-producing reaction in the core. The supernova is tempting because it is also dramatic and nuclear, but that explosion ends a massive star rather than powering it.'
  WHERE section = 'reading' AND prompt = 'What does "nuclear fusion" most likely mean, based on how the term is used in the passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The process by which stars collect gas and dust from space", "A reaction in a star''s core that produces energy by combining atoms", "The explosion that ends a massive star''s life", "The cooling process that turns a star into a white dwarf"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage follows a star from nebula to fusion to red giant, then splits into two endings depending on the star''s size. That birth-to-death arc is the main idea. Saying all stars end as white dwarfs contradicts the passage, which reserves that ending for small stars and gives massive stars supernovas instead.'
  WHERE section = 'reading' AND prompt = 'What is the main idea of this passage about stars?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Black holes are the most dangerous objects in the universe", "Stars go through a predictable life cycle from birth to death", "Our sun will eventually explode in a supernova", "All stars end as white dwarfs"]'::JSONB) v);

UPDATE questions SET explanation = 'The opening line pushes back on the everyday impression that stars are fixed and unchanging, and the rest of the passage lays out the life cycle that proves otherwise. Correcting that assumption sets up the topic. Trying to frighten readers about the eventual death of our sun is not it, since the passage gives the sun a quiet ending as a white dwarf.'
  WHERE section = 'reading' AND prompt = 'Why does the author begin by saying stars are "not permanent fixtures in the sky"?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["To argue that stars are less important than planets", "To correct a common assumption and set up the main topic of stars'' life cycles", "To frighten readers about the eventual death of our sun", "To explain why ancient people could not study stars"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage defines the effect in its first sentence, cities running several degrees warmer than the rural areas around them, then explains why through heat-storing pavement and heat-producing machines. A tropical weather pattern trapping heat is tempting because the topic is heat, but the causes given here are human-made surfaces and equipment, not weather.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what is an urban heat island?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["A park in the center of a city that gets extra sunlight", "The tendency of cities to be warmer than surrounding rural areas due to human-made surfaces and activities", "A weather pattern that traps heat over tropical cities", "The heating of rivers and lakes caused by industrial waste"]'::JSONB) v);

UPDATE questions SET explanation = 'The phrase appears alongside heat-related illness during summer heat waves, so vulnerable populations means groups more likely than others to be harmed by heat. People who cannot afford air conditioning is tempting and may well be part of that group, but it names one narrow circumstance, while vulnerable covers anyone at heightened risk.'
  WHERE section = 'reading' AND prompt = 'What does "vulnerable populations" most likely mean as used in the passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["City residents who live near factories", "Groups of people who are especially at risk of harm from heat", "Scientists who study urban weather", "People who cannot afford air conditioning"]'::JSONB) v);

UPDATE questions SET explanation = 'Work backward from the causes: dark asphalt soaks up solar energy, while grass and soil reflect more heat and cool quickly. Replacing dark pavement with lighter or planted surfaces removes that cause. Increasing the number of air conditioners would not help, since the passage lists them among the machines that generate heat directly and worsen the problem.'
  WHERE section = 'reading' AND prompt = 'Which of the following is most likely to reduce the urban heat island effect, based on the passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Building more parking lots and highways", "Replacing dark asphalt roads with lighter-colored or vegetated surfaces", "Increasing the number of air conditioners in buildings", "Constructing taller buildings to block sunlight"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage names the effect, explains what causes it through surfaces and machines, and closes with the costs to energy bills, air quality, and health. Causes plus why it matters covers the whole thing. Saying cities should plant more trees is too narrow, and the passage never actually makes that recommendation.'
  WHERE section = 'reading' AND prompt = 'What is this passage mainly about?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Why cities should plant more trees", "What causes the urban heat island effect and why it matters", "The history of city planning and road construction", "Why summer heat waves are becoming more frequent"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage introduces ARPANET as a 1969 network funded by the Department of Defense that linked computers at universities and research labs, which makes it the internet''s ancestor. Calling it a program for browsing websites confuses it with the World Wide Web, which arrived much later, in 1991, from Tim Berners-Lee.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what was ARPANET?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The first personal computer sold to the public", "An early government-funded computer network that was the predecessor to the internet", "A software program for browsing websites", "The organization that manages the internet today"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage defines the word as it uses it, calling protocols the rules governing how computers communicate, rules that were standardized as the network grew. High-speed cables are tempting because networks do run on physical connections, but a protocol is an agreement about how to talk, not the wire the talking travels through.'
  WHERE section = 'reading' AND prompt = 'What does "protocols" mean in the context of this passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["High-speed cables that connect computers", "The rules or standards that govern how computers communicate with each other", "Programs that protect computers from viruses", "A type of hardware used in early computers"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage says the World Wide Web made the internet far easier for ordinary people to navigate, in contrast with the earlier network used by scientists at a handful of universities. Making the internet faster for those scientists is tempting because speed sounds like progress, but the change described is ease of use, not speed.'
  WHERE section = 'reading' AND prompt = 'Why did Tim Berners-Lee''s invention of the World Wide Web matter for ordinary people?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["It made the internet faster for scientists at universities", "It made the internet accessible and easy to navigate for people outside research labs", "It replaced ARPANET with a more secure system", "It reduced the cost of computers so more families could buy them"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage describes echolocation as emitting high-pitched pulses that bounce off objects, with the returning echoes reaching the bat''s large, sensitive ears. Sending sound out and reading what comes back is the whole system. Large eyes are tempting because darkness sounds like a vision problem, but the passage never mentions bat eyesight.'
  WHERE section = 'reading' AND prompt = 'According to the passage, how do bats use echolocation to navigate?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["By using their large eyes to see in very dim light", "By emitting sound pulses and interpreting the returning echoes", "By sensing vibrations through their wings", "By following the magnetic field of the Earth"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage calls bats nocturnal and immediately describes them hunting in total darkness, so nocturnal means active at night. Being capable of seeing in the dark is tempting because it fits the same scene, but nocturnal describes when an animal is awake, and these bats find their way by sound rather than by sight.'
  WHERE section = 'reading' AND prompt = 'What does "nocturnal" mean as used in the passage about bats?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Active during daylight hours", "Active during the night", "Capable of seeing in the dark", "Able to survive without food for weeks"]'::JSONB) v);

UPDATE questions SET explanation = 'A moth is small and moving, and the bat catches it with no light at all while dodging obstacles thinner than a wire. Doing that requires knowing exactly where things are, which points to echolocation being extremely precise. Better eyesight is not the explanation, since the hunt happens in darkness where eyes have nothing to use.'
  WHERE section = 'reading' AND prompt = 'What can be inferred from the fact that bats can catch moths in complete darkness?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Bats have better eyesight than most other animals", "Echolocation provides bats with extremely precise spatial information", "Moths are easy to catch because they fly slowly", "Bats can only hunt when conditions are perfectly quiet"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage explains that an object absorbs some wavelengths and reflects others, and the reflected light reaches the eye, where the brain reads it as color. Saying objects produce their own color through internal chemistry is tempting because color feels like it belongs to the object, but the passage places it in the light and the brain.'
  WHERE section = 'reading' AND prompt = 'According to the passage, how does the color of an object affect how we perceive it?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Objects produce their own color through internal chemistry", "Objects reflect certain wavelengths of light, which the brain interprets as color", "The brain ignores color and focuses on shape instead", "Color perception is the same for all people in all situations"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage uses context to explain why a gray square looks darker on white than on black: what surrounds a color changes how the brain reads it. So context means the surroundings that shape perception. The part of the brain handling color vision is tempting, but context is the incoming information, not the machinery doing the interpreting.'
  WHERE section = 'reading' AND prompt = 'What does "context" mean as used in the passage about color perception?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The wavelength of light reflected by an object", "The surrounding environment that influences how something is perceived", "The part of the brain responsible for color vision", "The history of how humans learned about color"]'::JSONB) v);

UPDATE questions SET explanation = 'Combine two pieces: color is something the brain builds, and studies link red to urgency, blue to trust, and yellow to quick attention. Marketers who know that pick colors to produce a feeling on purpose. Always choosing the brightest color misses the point, since blue is chosen here for calm rather than for grabbing the eye.'
  WHERE section = 'reading' AND prompt = 'What can be inferred about why marketers choose specific colors for products and advertisements?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["They choose colors purely for artistic reasons", "They use color strategically to trigger specific emotional responses in consumers", "They always choose the brightest colors to attract attention", "They rely on customers'' favorite colors rather than psychological research"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage covers both halves of its topic: how reflected wavelengths and surrounding context create the color the brain sees, and how marketers use color to shape feelings. An answer naming perception and influence holds both. Focusing on red as the most powerful color is too narrow, since red is one item in a three-color list.'
  WHERE section = 'reading' AND prompt = 'What is the passage mainly about?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Why red is the most powerful color in marketing", "How the brain interprets color and how color can influence perception and behavior", "The physical properties of light and wavelengths", "Why all people perceive color differently"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage names the cues one by one: star positions, ocean swells, the feel of waves under the canoe, the color of the water, cloud formations, and bird behavior. Compasses and maps are tempting because that is what navigation usually means, but the passage opens by placing these voyages long before the compass.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what tools did Pacific Islander navigators use to find their way?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Compasses and early maps drawn on animal skins", "Stars, ocean swells, wave motion, water color, clouds, and birds", "Radio signals and ocean charts", "Magnetic rocks and tidal patterns"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage calls this whole system of reading stars, swells, water, and birds a sophisticated system of wayfinding, so wayfinding is the skill of finding a route from available signs. Reading weather to predict storms is tempting because clouds are on the list, but here clouds are used to locate islands, not to forecast conditions.'
  WHERE section = 'reading' AND prompt = 'What does "wayfinding" most likely mean in this passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Building boats strong enough to cross oceans", "The skill of navigating and finding one''s route using available information", "Reading weather patterns to predict storms", "Swimming from island to island"]'::JSONB) v);

UPDATE questions SET explanation = 'Oral means spoken, so a tradition passed down that way lives in memory and practice rather than on paper. The passage pairs oral tradition with practice, which fits knowledge taught person to person over generations. Knowledge written in books stored in temples is the opposite of oral, and the passage mentions no writing at all.'
  WHERE section = 'reading' AND prompt = 'What does the phrase "passed down through oral tradition" suggest about how this knowledge was preserved?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The knowledge was written in books stored in temples", "The knowledge was spoken and memorized, not written down", "The knowledge was kept secret and shared only with royalty", "The knowledge was learned from European sailors"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage is built around how Pacific Islander navigators crossed open ocean without instruments, listing their natural cues and calling the system sophisticated. That focus on their methods is the main idea. The history of the compass is not the topic, since the compass appears only in the opening line as the thing they did without.'
  WHERE section = 'reading' AND prompt = 'What is the passage mainly about?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Why the Pacific Ocean is the most difficult ocean to cross", "The sophisticated navigation methods used by indigenous Pacific Islander peoples", "The history of the compass and its importance to sailors", "How Polynesian peoples first discovered the Pacific Islands"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage states the rule plainly: when a product is in high demand but supply is limited, sellers can charge more because buyers compete for a scarce resource. Prices falling is tempting because the passage says that too, but it describes the opposite situation, when supply is plentiful and sellers compete for buyers.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what happens to the price of a product when demand increases and supply stays the same?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Prices fall because sellers want to attract buyers", "Prices stay the same regardless of demand", "Prices rise because buyers are competing for a limited supply", "Prices become unpredictable and fluctuate randomly"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage defines the equilibrium price as the point where the quantity sellers want to sell equals the quantity buyers want to buy, which is a balance between the two sides. The highest price ever paid is tempting because equilibrium can sound like a peak, but the word points to two forces evening out, not to a record.'
  WHERE section = 'reading' AND prompt = 'What does "equilibrium" most likely mean as used in the passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The highest price a product has ever sold for", "A point of balance where supply and demand are equal", "The price set by the government for a product", "The average price of all products in an economy"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage supplies the example directly, saying a new technology that makes production cheaper can lower prices. Cheaper production also lets sellers make more, and the passage''s own rule says plentiful supply with steady demand pushes prices down. Sellers raising prices for extra profit ignores that rule, since competition among sellers is what drives prices lower.'
  WHERE section = 'reading' AND prompt = 'What can be inferred about the effect of a new technology that makes production much cheaper?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["It would cause demand to fall because buyers would not trust cheaper products", "It would likely increase supply and lower prices for consumers", "It would have no effect on prices if demand stays the same", "It would cause sellers to raise prices to make more profit"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage introduces supply and demand as the forces that set prices, explains what happens in each direction, defines equilibrium, and gives real examples. Those forces determining prices is the main idea. Calling droughts and technology the biggest threats to the economy is too narrow, since the passage uses them only as illustrations.'
  WHERE section = 'reading' AND prompt = 'What is the main idea of this passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Droughts and technology are the biggest threats to a healthy economy", "Sellers always have more power than buyers in setting prices", "Supply and demand are the forces that determine prices in a market economy", "The equilibrium price never changes once it is established"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage traces democracy''s origins to ancient Athens in the 5th century BCE, where Cleisthenes gave citizens a direct voice in governing. Sparta is tempting because it was another famous Greek city-state of the same era, but it never appears in this passage, and the reforms described belong to Athens alone.'
  WHERE section = 'reading' AND prompt = 'According to the passage, which city is considered the birthplace of democracy?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Rome", "Sparta", "Athens", "Alexandria"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage explains the term as it goes: eligible citizens gathered in an assembly and voted on laws and policies themselves, rather than electing representatives. Voting through elected representatives is exactly what direct democracy is being contrasted with, which makes it the trap. Direct means the citizens do the voting with no one in between.'
  WHERE section = 'reading' AND prompt = 'What does "direct democracy" mean as described in the passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Electing representatives to vote on laws on your behalf", "Citizens voting directly on laws and policies themselves", "A king ruling with the advice of citizens", "A council of nobles making decisions for the public"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage covers where democracy began, how the Athenian assembly worked, who was excluded from it, and why it still mattered. Innovations plus limitations captures both halves. A biography of Cleisthenes is too narrow, since he appears in one sentence as the person who introduced the reforms, not as the subject of the passage.'
  WHERE section = 'reading' AND prompt = 'What is the passage mainly about?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The biography of Cleisthenes and his political career", "The origins of democracy in ancient Athens, including both its innovations and its limitations", "Why democracy failed in ancient Greece", "The differences between ancient and modern voting systems"]'::JSONB) v);

UPDATE questions SET explanation = 'The first sentence gives the strategy: antibiotics attack features bacteria have and human cells lack, such as cell walls, and later sentences add blocking protein production and reproduction. Strengthening the immune system is tempting because both approaches fight infection, but the antibiotics in this passage go after the bacteria directly.'
  WHERE section = 'reading' AND prompt = 'According to the passage, how do antibiotics fight bacterial infections?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["By strengthening the immune system to fight infections faster", "By targeting features of bacteria that human cells lack, such as cell walls and protein production", "By killing all microorganisms in the body, including helpful bacteria", "By lowering body temperature to slow bacterial growth"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage says antibiotics do not work against viruses, and that is precisely why doctors skip them for colds and the flu. The idea that antibiotics are too expensive for minor illnesses is tempting because prescribing does involve money, but the reason given here is biological. An antibiotic has nothing to attack in a virus, so it would make no difference.'
  WHERE section = 'reading' AND prompt = 'Why do doctors not prescribe antibiotics for colds or the flu?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Colds and flu are not serious enough to need medicine", "Colds and flu are caused by viruses, not bacteria, so antibiotics would not work", "Antibiotics are too expensive to use for minor illnesses", "Doctors prefer natural remedies for respiratory infections"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage links overuse to antibiotic resistance, where bacteria evolve to survive drugs that used to kill them, and calls this a serious threat to public health. Harder-to-treat infections follow directly. Antibiotics growing more effective over time reverses that idea, since the passage describes the drugs losing ground rather than gaining it.'
  WHERE section = 'reading' AND prompt = 'What might happen if antibiotics are overused, based on the passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Antibiotics would become more effective over time", "Bacteria would evolve resistance, making infections harder to treat", "Viruses would start responding to antibiotic treatment", "People would develop immunity to bacterial infections naturally"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage credits reefs with three things: supporting extraordinary diversity of life, shielding coastlines from storm waves, and sustaining fishing industries worth billions. Producing the oxygen marine animals breathe is tempting because algae and photosynthesis come up, but the passage says that photosynthesis feeds the corals and never claims reefs supply the ocean''s oxygen.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what role do coral reefs play in the ocean?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["They serve as feeding grounds exclusively for large ocean predators", "They support enormous biodiversity, protect coastlines, and sustain fishing economies", "They produce the oxygen that marine animals breathe", "They are found mainly in the deep ocean far from human populations"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage explains bleaching as stressed corals expelling their algae when ocean temperatures rise. Because those algae feed the coral through photosynthesis, losing them cuts off the energy supply and the coral may die. Calling bleaching a harmless seasonal event contradicts the passage, which ties it to climate change and to the whole ecosystem being threatened.'
  WHERE section = 'reading' AND prompt = 'What does "bleaching" suggest about coral reefs when ocean temperatures rise?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Corals turn brighter colors when they are healthy", "Corals lose their algae and energy source, which can cause them to die", "Warm water causes corals to grow faster", "Bleaching is a natural seasonal event that does not harm reefs"]'::JSONB) v);

UPDATE questions SET explanation = 'Two facts combine: algae supply corals with energy through photosynthesis, and corals that expel their algae may die. Relying on something for food and dying without it is dependence, so corals need algae to survive. Saying algae cause bleaching flips the order, since heat stress causes the bleaching and losing the algae is the result.'
  WHERE section = 'reading' AND prompt = 'What can be inferred about the relationship between corals and algae?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Algae compete with coral for space on the reef", "Coral cannot survive without the energy algae provide through photosynthesis", "Algae are harmful to corals and cause bleaching", "Algae and coral are the same type of organism"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage explains what reefs are and how corals and algae build them, why they matter ecologically and economically, and how warming water threatens them. Structure, importance, and threats covers all three. Banning fishing near reefs is not the topic, since fishing appears once as an industry reefs support and no ban is proposed.'
  WHERE section = 'reading' AND prompt = 'What is the passage mainly about?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Why fishing near coral reefs should be banned", "The structure, importance, and threats facing coral reef ecosystems", "How algae reproduce in warm ocean water", "The history of scientific research on coral reefs"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage traces the path: a vibrating object pushes air molecules into areas of compression and expansion, those pressure waves travel through the medium, and they set the eardrum vibrating. Sound jumping straight to the ear with no medium contradicts the opening point that sound, unlike light, cannot cross empty space.'
  WHERE section = 'reading' AND prompt = 'According to the passage, how does sound travel from its source to your ears?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Sound travels as light waves that are converted into vibrations by the ear", "Sound travels as pressure waves created by vibrations, which cause the eardrum to vibrate", "Sound jumps directly from the source to the eardrum without a medium", "Sound travels through space and is slowed down when it enters the atmosphere"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage ties frequency to pitch and explains it as more waves per second producing a higher pitch, so frequency counts how many waves pass a point each second. Loudness is tempting because volume is the other thing people notice about a sound, but the passage links frequency only to pitch, never to how loud something is.'
  WHERE section = 'reading' AND prompt = 'What does "frequency" mean as used in the passage about sound?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The loudness or volume of a sound", "How many waves pass a point per second", "The distance a sound wave travels", "The material through which sound travels"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage gives the rule: more waves per second produce a higher pitch. Doubling the frequency doubles the waves per second, so the pitch climbs. A lower pitch would require fewer waves per second, which is the opposite change. In this passage frequency and pitch always move in the same direction.'
  WHERE section = 'reading' AND prompt = 'What would most likely happen to the pitch of a sound if its frequency doubled?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The pitch would get lower", "The pitch would stay the same", "The pitch would get higher", "The sound would stop traveling through air"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage explains how vibrations create pressure waves, how those waves move through air, water, or steel, how the ear receives them, and how frequency sets pitch. All of that together is the main idea. Why sound cannot travel in outer space is too narrow, appearing as one contrast in the opening line.'
  WHERE section = 'reading' AND prompt = 'What is the main idea of this passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Why sound cannot travel in outer space", "How sound waves are produced, how they travel, and how their properties determine pitch", "The anatomy of the human ear and how it is protected", "Why some materials conduct electricity better than others"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage is deliberate here: migration appears to be triggered not by cold temperatures directly but by changes in day length, called photoperiod. Dropping autumn temperatures is the answer the passage specifically rules out, which is what makes it so tempting. The signal birds read is light, and the cold merely follows it.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what triggers many birds'' migration each year?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Dropping temperatures in autumn", "The start of rainfall in their habitat", "Changes in the length of daylight hours", "Decreasing food supply in summer"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage defines the word right inside the sentence, calling changes in day length photoperiod. So photoperiod means the amount of daylight in a given stretch of time. A bird''s internal sense of direction is tempting because navigation is discussed, but that comes later with stars and magnetic fields. Photoperiod is about timing, not direction.'
  WHERE section = 'reading' AND prompt = 'What does "photoperiod" mean as used in the passage about bird migration?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The total amount of rainfall in a season", "The length of daylight in a given period", "A bird''s internal sense of direction", "The temperature difference between two seasons"]'::JSONB) v);

UPDATE questions SET explanation = 'Combine two things the passage says: birds come back to the very same nesting grounds year after year with great precision, and they steer by the sun, the stars, Earth''s magnetic field, and landmarks. Repeating that trip accurately means they carry and use stored location information. The passage never says older birds teach the route, so learned behavior is an assumption it does not support.'
  WHERE section = 'reading' AND prompt = 'What can be inferred about birds that return to the same nesting grounds each year?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["They never encounter any obstacles during migration", "They rely entirely on learned behavior from older birds", "They possess a reliable internal navigation system that stores location information", "They are guided to their nesting grounds by other animals"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage spends its length on two questions: what starts migration, which is the changing length of the day rather than cold itself, and how birds find their way once they go. That pairing is the main idea. Threats from climate change sound related, but the passage only calls migration a response to environmental change and never discusses any danger to birds.'
  WHERE section = 'reading' AND prompt = 'What is the passage primarily about?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The threats that climate change poses to migrating birds", "What triggers bird migration and how birds navigate during their journeys", "Why some birds migrate while others do not", "The specific routes used by different bird species"]'::JSONB) v);

UPDATE questions SET explanation = 'Near the opening the passage says memory begins in the hippocampus, which encodes new experiences by strengthening connections between neurons. The cerebral cortex is tempting because it does hold memories, but only later: consolidation gradually moves memories there for long-term storage. That is the destination, not the starting point, and the question asks where memories are first formed.'
  WHERE section = 'reading' AND prompt = 'According to the passage, where are memories first formed?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The cerebral cortex", "The amygdala", "The hippocampus", "The nervous system outside the brain"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage uses consolidation for the slow process that moves memories from the hippocampus into the cerebral cortex and makes them stable, turning fragile new memories into lasting ones. Forgetting to make room sounds sensible, but the passage never describes memory as a space that fills up. Nothing is erased here; connections are strengthened, especially during sleep.'
  WHERE section = 'reading' AND prompt = 'What does "consolidation" mean as used in the passage about memory?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The process of forgetting old memories to make room for new ones", "The gradual transfer and stabilization of memories into long-term storage", "The experience of recalling a memory under stress", "The destruction of memories during sleep"]'::JSONB) v);

UPDATE questions SET explanation = 'Trace the whole passage: encoding in the hippocampus, fragile early memories, consolidation into the cortex, sleep replaying and strengthening pathways, and the amygdala marking emotional events. That is a multi-step process across several brain regions. Saying the hippocampus is the only part that matters is far too narrow and the passage contradicts it by naming the cortex and amygdala too.'
  WHERE section = 'reading' AND prompt = 'What is the main idea of this passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The hippocampus is the only part of the brain that matters for learning", "The brain forms and stores memories through a multi-step process involving several regions", "Sleep is the most important factor in how smart a person is", "Emotions are stored separately from other types of memories"]'::JSONB) v);

UPDATE questions SET explanation = 'Rapid describes speed, so a rapid decision is one made fast, which makes quick the match. Delayed is the opposite of rapid. Careful is the trap worth understanding: it describes how much thought went into the decision, not how much time it took, and a decision can be both rapid and careful. Speed and care are separate qualities.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a RAPID decision'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["quick", "careful", "delayed", "unpopular"]'::JSONB) v);

UPDATE questions SET explanation = 'Fragile means easily broken or damaged, so delicate, which carries that same sense of needing gentle handling, is the match. Expensive is tempting because we picture fragile things as valuable heirlooms, but plenty of cheap objects are fragile and plenty of costly ones are sturdy. The word says nothing about price, only about how easily something breaks.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a FRAGILE vase'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["heavy", "delicate", "colorful", "expensive"]'::JSONB) v);

UPDATE questions SET explanation = 'Ancient means extremely old, so a ruin that has stood for centuries is aged. Modern is the direct opposite, describing something recent. Hidden and crowded are tempting only because ruins are often overgrown or full of tourists, but neither word says anything about time. This question turns entirely on age, so pick the choice that measures age.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: an ANCIENT ruin'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["modern", "hidden", "aged", "crowded"]'::JSONB) v);

UPDATE questions SET explanation = 'Generous describes freely and openly giving more than expected, so giving captures it. Tiny points the other direction, since a generous gift is a large one. Surprising is worth ruling out carefully: a generous gift may well surprise you, but that describes your reaction to it, not the openhandedness the word itself names.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a GENEROUS gift'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["borrowed", "giving", "tiny", "surprising"]'::JSONB) v);

UPDATE questions SET explanation = 'Vacant means unoccupied, with nothing and nobody in it, so a vacant lot is an empty one, and empty is the plainest word for that. Busy points the opposite way, describing a lot full of activity. Muddy and fenced could both be true of an empty lot, but they describe its ground or its edge rather than whether anything is there.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a VACANT lot'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["muddy", "fenced", "busy", "empty"]'::JSONB) v);

UPDATE questions SET explanation = 'An odor is something you take in through your nose, pleasant or not, so smell is the synonym. Noise is the trap: it is also something a kitchen can be full of, and it is also detected by a sense, but that sense is hearing. Match the word to the right sense and the answer follows quickly.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a strong ODOR in the kitchen'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["smell", "noise", "stain", "glow"]'::JSONB) v);

UPDATE questions SET explanation = 'To assist someone is to help them with what they are doing, which makes help the direct match. Ignore is the opposite, since assisting requires stepping in. Visit is the tempting one: you might well visit a neighbor in order to assist them, but visiting only means going to see someone, with no work or aid involved.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: to ASSIST a neighbor'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["ignore", "hire", "help", "visit"]'::JSONB) v);

UPDATE questions SET explanation = 'Enormous measures size, so an enormous crowd is a huge one. Restless is the trap here because it is a very natural word to attach to a crowd, but it describes how the crowd behaves rather than how many people it holds. Polite and distant likewise describe manner or position, not size, so huge is the only choice that measures the same thing.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: an ENORMOUS crowd'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["polite", "distant", "restless", "huge"]'::JSONB) v);

UPDATE questions SET explanation = 'To conceal something is to put it out of sight while keeping it, so hide is the match. Destroy is tempting because both actions keep evidence from being used, but they are not the same: concealed evidence still exists and can be found later, while destroyed evidence is gone. Examine and report both mean drawing attention to it instead.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: to CONCEAL the evidence'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["hide", "destroy", "examine", "report"]'::JSONB) v);

UPDATE questions SET explanation = 'Weary describes being worn out and low on energy, so tired is the closest match. Lost is the trap, since a traveler who has been walking a long time is easy to picture as both tired and lost, but weary says nothing about knowing the way. Focus on what the word measures, which here is how much energy is left.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a WEARY traveler'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["lost", "tired", "wealthy", "cheerful"]'::JSONB) v);

UPDATE questions SET explanation = 'Cautious means acting carefully in order to avoid risk, so careful is the match. Reckless is its opposite, describing someone who takes risks without thinking. Skilled is the useful trap: skill and caution are separate qualities, and a highly skilled driver can still speed recklessly while a modest one drives with great care.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a CAUTIOUS driver'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["reckless", "elderly", "careful", "skilled"]'::JSONB) v);

UPDATE questions SET explanation = 'To permit something is to let it happen, so allow is the direct match. Deny is the opposite, refusing entry outright. Delay is the tempting near miss, because delaying someone at the door also keeps them waiting, but it means putting off entry rather than granting it. Note too that permit as a noun means a document, which is a different use.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: to PERMIT entry'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["deny", "delay", "charge", "allow"]'::JSONB) v);

UPDATE questions SET explanation = 'Brief measures length of time, so a brief speech is a short one. Boring is the trap because we often expect short talks to be dull or long ones to drag, but the word says nothing about quality: a brief speech can be gripping, and a long one can be too. Famous and loud likewise describe other qualities entirely.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a BRIEF speech'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["short", "boring", "famous", "loud"]'::JSONB) v);

UPDATE questions SET explanation = 'Peaceful means free from noise and disturbance, which is exactly what calm describes. Early is the trap: mornings are early by definition, so the word feels like it belongs, but it tells you the time rather than the mood. Rainy and chilly describe weather, and a morning can be rainy and peaceful at the same time.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a PEACEFUL morning'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["rainy", "calm", "early", "chilly"]'::JSONB) v);

UPDATE questions SET explanation = 'Diligent describes steady, careful effort kept up over time, so hardworking is the match. Gifted is the trap worth learning: it names natural talent, which is a different thing entirely. A diligent student may not be the most talented in the room, and a gifted one may hardly work at all. The word points to effort, not ability.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a DILIGENT student'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["gifted", "hardworking", "popular", "polite"]'::JSONB) v);

UPDATE questions SET explanation = 'Abundant means existing in great quantity, so an abundant harvest is a plentiful one. Ruined points the opposite way. Unexpected is the trap: a huge harvest may well come as a surprise, but that describes how the farmer felt about it rather than how much grain came in. Abundant measures amount and nothing else.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: an ABUNDANT harvest'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["plentiful", "early", "ruined", "unexpected"]'::JSONB) v);

UPDATE questions SET explanation = 'Used as an adjective, novel means new and not tried before, so a novel approach is an original one. Familiar is its opposite. The trap is the other common meaning of the word, novel as a noun meaning a book, which pulls attention away from the sense needed here. Risky is also close but describes danger rather than newness.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a NOVEL approach'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["risky", "simple", "original", "familiar"]'::JSONB) v);

UPDATE questions SET explanation = 'To provoke something is to stir it up or bring it about, so trigger is the match. Prevent is the opposite, stopping the reaction from happening. Predict is the more interesting trap: predicting a reaction means seeing it coming, while provoking it means causing it. One is watching from outside, the other is making it happen.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: to PROVOKE a reaction'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["prevent", "predict", "record", "trigger"]'::JSONB) v);

UPDATE questions SET explanation = 'Reluctant means hesitant and not wanting to do something, so unwilling is the match, and eager is its opposite. Inexperienced is the trap, since we picture a hesitant volunteer as new to the job, but the word describes attitude rather than skill. Someone can be highly experienced and still deeply reluctant to step forward.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a RELUCTANT volunteer'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["unwilling", "inexperienced", "eager", "anonymous"]'::JSONB) v);

UPDATE questions SET explanation = 'Vivid describes something that creates a strong, clear picture in your mind, so striking is the match. Accurate is the trap worth understanding: a vivid description may be completely wrong and still vivid, because the word measures how sharply you can see it rather than how true it is. Lengthy describes size, which is separate again.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a VIVID description'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["lengthy", "striking", "accurate", "confusing"]'::JSONB) v);

UPDATE questions SET explanation = 'To diminish is to become smaller or less, so shrink is the synonym. Swell is the opposite, meaning to grow larger. Settle is the trap, since it also describes something changing over time, but it means coming to rest or sinking into place rather than losing size. Stiffen describes a change in texture, not in size.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: to DIMINISH in size'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["shrink", "swell", "stiffen", "settle"]'::JSONB) v);

UPDATE questions SET explanation = 'Obstinate means refusing to change course no matter what anyone else wants, which is the definition of stubborn. Gentle points the other way. Clumsy is a fair trap because a balky mule looks awkward, but obstinate describes the animal''s will rather than its coordination. A mule can be graceful and still refuse to move an inch.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: an OBSTINATE mule'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["gentle", "clumsy", "stubborn", "aging"]'::JSONB) v);

UPDATE questions SET explanation = 'Plausible means it sounds reasonable enough to be true, so believable is the match. Dishonest is the trap, because we usually reach for plausible when we suspect an excuse is a lie. The word itself makes no ruling on truth: a plausible excuse might be perfectly true, and the point is only that it holds together.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a PLAUSIBLE excuse'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["dishonest", "lengthy", "rehearsed", "believable"]'::JSONB) v);

UPDATE questions SET explanation = 'To scrutinize something is to examine it closely and carefully, so inspect is the match. Sign is the tempting one because scrutinizing a contract is exactly what you do before signing it, but that is the next step, not the same action. Shorten and reject also describe things you might do afterward, once you have read it.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: to SCRUTINIZE the contract'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["sign", "inspect", "shorten", "reject"]'::JSONB) v);

UPDATE questions SET explanation = 'Tranquil means still, quiet, and undisturbed, which is what serene describes. Shallow and frozen are tempting because they are natural words for a lake, but they describe its depth and its temperature rather than its calm. Remote describes where it sits. A lake can be deep, warm, and close to town and still be perfectly tranquil.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a TRANQUIL lake'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["serene", "shallow", "frozen", "remote"]'::JSONB) v);

UPDATE questions SET explanation = 'Eloquent describes speaking fluently and persuasively, choosing words well, which is what articulate means. Nervous is the opposite kind of delivery. Famous is the trap: eloquent speakers often become well known, but fame is the result rather than the quality, and plenty of famous speakers are poor with words. Brief measures length instead.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: an ELOQUENT speaker'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["famous", "nervous", "articulate", "brief"]'::JSONB) v);

UPDATE questions SET explanation = 'To alleviate something is to make it less severe, so relieve is the match. Endure is the trap and a useful contrast: enduring pain means putting up with it while it stays just as bad, whereas alleviating it actually reduces it. Describe and ignore are also responses to pain that leave the pain itself unchanged.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: to ALLEVIATE the pain'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["relieve", "endure", "describe", "ignore"]'::JSONB) v);

UPDATE questions SET explanation = 'Prudent describes acting with good judgment and caution, avoiding needless risk, which is what sensible expresses. Daring points the opposite way, toward risk taken deliberately. Costly is the trap, since money is on your mind with an investment, but price is a separate matter: a prudent investment can be large or small.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a PRUDENT investment'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["daring", "sensible", "costly", "sudden"]'::JSONB) v);

UPDATE questions SET explanation = 'Candid means frank and open, saying what you really think, so honest is the match. Rude is the trap worth sorting out: a candid answer can sting, but plenty of candid answers are kind, and plenty of rude ones are lies. Note also that a candid photo is an unposed one, a related but different use.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a CANDID answer'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["clever", "lengthy", "rude", "honest"]'::JSONB) v);

UPDATE questions SET explanation = 'Inevitable means certain to happen no matter what anyone does, so unavoidable states it directly. Disputed points the other way. Unfortunate is the trap because we most often call bad outcomes inevitable, so the word picks up a gloomy feel, but it only reports certainty. A happy outcome can be just as inevitable.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: an INEVITABLE outcome'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["unfortunate", "unavoidable", "surprising", "disputed"]'::JSONB) v);

UPDATE questions SET explanation = 'To forfeit a game is to give it up and take the loss without playing it out, so surrender is the match. Postpone is the trap: both mean the game does not get played as scheduled, but a postponed game is rescheduled and still yours to win, while a forfeited one is simply lost. Win is the opposite outcome.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: to FORFEIT the game'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["postpone", "win", "surrender", "replay"]'::JSONB) v);

UPDATE questions SET explanation = 'Meager means noticeably small and not enough, so a meager portion is a scanty one. Generous is its opposite, describing a plate piled high. Cold is the trap, because both words are easy to attach to a disappointing meal, but temperature and quantity are different complaints. Meager measures how much food there is.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a MEAGER portion'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["scanty", "spicy", "generous", "cold"]'::JSONB) v);

UPDATE questions SET explanation = 'Tenacious describes holding on and refusing to quit, so persistent is the closest match. Talented is the trap and the useful lesson: a tenacious competitor may be outmatched in raw ability and win anyway by not giving up. The word measures determination, not skill. Arrogant describes attitude toward others instead.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a TENACIOUS competitor'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["talented", "persistent", "arrogant", "cheerful"]'::JSONB) v);

UPDATE questions SET explanation = 'Ambivalent means pulled in two directions at once, holding mixed feelings about the same thing, so conflicted describes it. Hostile is the trap, since ambivalent sounds negative and people often use it that way, but part of an ambivalent response is favorable, which is exactly what makes it hard to resolve. Enthusiastic names only the positive half.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: an AMBIVALENT response'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["enthusiastic", "hostile", "conflicted", "immediate"]'::JSONB) v);

UPDATE questions SET explanation = 'Superfluous means more than is needed, so superfluous detail is unnecessary detail. Confusing is the tempting choice because piling on extra detail often does muddle a reader, but that is an effect it can have rather than what the word claims. A superfluous detail may be perfectly clear and still be one detail too many.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: SUPERFLUOUS detail'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["unnecessary", "confusing", "technical", "colorful"]'::JSONB) v);

UPDATE questions SET explanation = 'Innocuous means causing no harm or offense, which is what harmless means. Insulting is its opposite, and the word is usually used precisely to draw that contrast: an innocuous remark is the kind nobody should take badly. Whispered is a trap because it describes how the remark was said rather than its effect.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: an INNOCUOUS remark'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["clever", "harmless", "insulting", "whispered"]'::JSONB) v);

UPDATE questions SET explanation = 'Laconic means using very few words, which is exactly what terse means. Angry is the trap worth learning, because a one-word answer often feels cold and we read irritation into it, but laconic describes only the length of the reply. Someone perfectly cheerful can be laconic. Delayed describes timing rather than length.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a LACONIC reply'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["angry", "delayed", "terse", "confusing"]'::JSONB) v);

UPDATE questions SET explanation = 'To exacerbate a problem is to make a bad situation worse, so worsen is the match, and solve is its opposite. Explain is the trap, since exacerbate is a formal word that turns up in serious discussions of problems, but explaining a problem leaves it exactly as bad as it was. This word always means the trouble grew.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: to EXACERBATE the problem'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["solve", "explain", "avoid", "worsen"]'::JSONB) v);

UPDATE questions SET explanation = 'Intrepid means showing no fear in the face of danger, so fearless is the synonym. Lost is the opposite kind of adventure story. Famous is the trap: intrepid explorers usually do become well known, but that is what happens afterward rather than the quality the word names, which is courage in the moment.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: an INTREPID explorer'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["fearless", "wealthy", "famous", "lost"]'::JSONB) v);

UPDATE questions SET explanation = 'Spurious means not genuine, so a spurious claim is a false one. Popular is the trap here, because a fake claim can spread widely and be believed by many people, but that describes how many accept it rather than whether it is true. Complicated describes how hard the claim is to follow, which is separate again.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a SPURIOUS claim'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["complicated", "false", "popular", "modest"]'::JSONB) v);

UPDATE questions SET explanation = 'To capitulate is to stop resisting and give in, which is what surrender means. Object is the opposite, standing your ground. Listen is the trap: listening to demands is what you do before deciding, and you can hear someone out and still refuse. Capitulate says the resistance ended and the demands were met.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: to CAPITULATE to demands'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["object", "listen", "surrender", "respond"]'::JSONB) v);

UPDATE questions SET explanation = 'Ephemeral means lasting only a very short time, so short-lived is the match. Every choice here describes duration, which is what makes the item tricky. Long-lasting is the opposite, while recurring and seasonal describe things that come back again and again. An ephemeral trend passes quickly and does not necessarily return at all.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: an EPHEMERAL trend'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["long-lasting", "recurring", "seasonal", "short-lived"]'::JSONB) v);

UPDATE questions SET explanation = 'Garrulous means talking a great deal, so talkative is the match. Nosy is the trap because the two often travel together in our picture of a chatty neighbor, but nosy describes wanting to know your business while garrulous describes how much they say. A garrulous person may talk endlessly about themselves and never ask a thing.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a GARRULOUS neighbor'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["talkative", "nosy", "unfriendly", "elderly"]'::JSONB) v);

UPDATE questions SET explanation = 'To assuage a feeling is to soothe it and make it less painful, so ease is the match. Hide is the trap and a real contrast: hiding guilt leaves it as strong as ever while keeping it out of sight, whereas assuaging it actually lessens it. Admit and deserve describe what someone does about the guilt, not its strength.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: to ASSUAGE her guilt'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["admit", "ease", "hide", "deserve"]'::JSONB) v);

UPDATE questions SET explanation = 'Austere means plain and stripped of decoration or comfort, so bare describes an austere room. Crowded points the other way, toward a room full of things. Elegant is the sharper trap, since a spare, uncluttered room can look very stylish, but austere emphasizes what has been left out rather than how good it looks.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: an AUSTERE room'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["elegant", "crowded", "bare", "damp"]'::JSONB) v);

UPDATE questions SET explanation = 'Precarious means dangerously insecure and likely to give way, so unstable is the best match. Narrow is the trap: a ledge that is narrow may still be perfectly solid rock, and a wide one that is crumbling is far more precarious. The word measures how safely something holds, not its width. Shaded and distant describe other things.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a PRECARIOUS ledge'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["narrow", "shaded", "distant", "unstable"]'::JSONB) v);

UPDATE questions SET explanation = 'To repudiate something is to formally refuse to accept it, so reject is the match, and sign points the other way entirely. Delay is the trap worth naming: delaying a treaty means putting off a decision that could still go either way, while repudiating it means the decision has been made and the answer is no.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: to REPUDIATE the treaty'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["reject", "sign", "translate", "delay"]'::JSONB) v);

UPDATE questions SET explanation = 'Indigent means extremely poor, so impoverished is the match. The trap is a lookalike word rather than a listed option: indigent is easy to confuse with indignant, which means angry at unfair treatment, and grateful is the choice that pulls you toward feelings instead of money. Large describes the family''s size, not its means.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: an INDIGENT family'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["large", "impoverished", "grateful", "distant"]'::JSONB) v);

UPDATE questions SET explanation = 'Magnanimous describes generosity of spirit, especially toward someone you could have treated badly, such as a defeated rival, so generous is the match. Public is the trap: grand gestures often happen in front of an audience, but a magnanimous act done in private is no less magnanimous. Hasty describes speed rather than spirit.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: a MAGNANIMOUS gesture'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["hasty", "public", "generous", "puzzling"]'::JSONB) v);

UPDATE questions SET explanation = 'Inscrutable means impossible to interpret, so an inscrutable expression is unreadable. Angry and pained are the traps, and they fail for the same reason: to call a face angry or pained, you would have to be able to read it. Inscrutable says the opposite, that you cannot tell what the person is feeling at all.'
  WHERE section = 'reading' AND prompt = 'Choose the word that means the same as the underlined word: an INSCRUTABLE expression'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["angry", "familiar", "pained", "unreadable"]'::JSONB) v);

UPDATE questions SET explanation = 'The first paragraph explains that each year''s snow is buried and pressed into solid ice, trapping tiny bubbles of air, and that those bubbles are samples of the atmosphere from the day that snow fell. Meltwater is the tempting answer because ice and melting go together, but nothing in the passage describes the snow melting and refreezing; it is squeezed by weight instead.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what is sealed inside the bubbles found in ice cores?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Samples of the atmosphere from the day the snow fell", "Meltwater that refroze during warm summers", "Dust carried in from other continents", "Seawater pushed upward through the ice sheet"]'::JSONB) v);

UPDATE questions SET explanation = 'The closing sentence sets written records, which do not reach back far, against ice that has kept its measurements accurately for hundreds of thousands of years. Faithfully there means dependably, so reliably fits. Devoutly is tempting because faithful often describes religious devotion, but ice is being praised for accuracy, not belief.'
  WHERE section = 'reading' AND prompt = 'As used in the last sentence of the passage, the word "faithfully" most nearly means'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["reliably", "devoutly", "reluctantly", "briefly"]'::JSONB) v);

UPDATE questions SET explanation = 'The comparison lands right after the point that the layers stack in order, with recent ice on top and ancient ice at the bottom. Tree rings are something readers already know how to read by age, so the author borrows that familiar idea to explain reading a core. Cutting the core into sections is mentioned separately, when the ice is raised, and is not what the comparison is doing.'
  WHERE section = 'reading' AND prompt = 'The author compares an ice core to the rings of a tree mainly in order to'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["show that ice cores are found in forests as well as in Antarctica", "argue that trees record climate more accurately than ice does", "explain how scientists cut a core into sections", "help the reader understand that the layers can be read in order of age"]'::JSONB) v);

UPDATE questions SET explanation = 'The last paragraph says the deepest cores stretch back further than any written account and record both carbon dioxide and temperature, which supports the idea that cores reveal climate long before anyone was writing. The choice about present-day carbon dioxide gets the direction backward: cores preserve air from the past, and the passage never claims they measure today''s atmosphere.'
  WHERE section = 'reading' AND prompt = 'Which conclusion about ice cores is best supported by the passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["They can supply climate information for periods long before any written records existed", "They are the only reliable way to measure present-day carbon dioxide", "They show that temperature and carbon dioxide are unrelated", "They must be drilled every year to remain useful"]'::JSONB) v);

UPDATE questions SET explanation = 'The second paragraph describes exactly what happens when water runs out: the tardigrade pulls in its legs, pushes out most of its moisture, and curls into a barrel shape called a tun, with its chemistry nearly stopped. Burrowing deeper for moisture sounds reasonable for a soil animal, but the passage describes the opposite response, giving up water rather than hunting for it.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what does a tardigrade do when it loses access to water?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["It burrows deeper into the soil to find moisture", "It expels most of its moisture and curls into a form called a tun", "It grows a hard outer shell and continues feeding", "It swims to the sea, where water is always available"]'::JSONB) v);

UPDATE questions SET explanation = 'Hostile here describes conditions that would kill the animal, so life-threatening fits: the passage goes on to list drying out, boiling heat, crushing pressure, and the vacuum of space. Poisonous is tempting because poison is one way conditions can be deadly, but it is narrower than what the passage lists, and no poison is mentioned anywhere.'
  WHERE section = 'reading' AND prompt = 'As used in the passage, the word "hostile" most nearly means'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["crowded", "unfamiliar", "life-threatening", "poisonous"]'::JSONB) v);

UPDATE questions SET explanation = 'Space exposure is the last and most extreme item in a list of what tuns have survived, after years without water, boiling temperatures, and deep-ocean pressures. The author piles these up to show how far the tun state can be pushed. The idea that tardigrades came from space is a leap the passage never makes; they were carried up for an experiment.'
  WHERE section = 'reading' AND prompt = 'The author mentions the orbital experiment in order to'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["show how far scientists must travel to find tardigrades", "suggest that tardigrades originally came from space", "explain why tardigrades are difficult to photograph", "illustrate how extreme the conditions a tun can survive really are"]'::JSONB) v);

UPDATE questions SET explanation = 'The last paragraph makes the point plainly: an active, hydrated tardigrade is fragile, and its survival depends on entering the tun before trouble arrives. So the danger is harsh conditions arriving first. Staying in a tun for years is tempting to pick, but the passage says researchers revived tuns after years in dry moss, so long waits are survivable.'
  WHERE section = 'reading' AND prompt = 'The final paragraph suggests that a tardigrade is most likely to die when'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["conditions worsen before it has entered the tun state", "it remains in the tun state for several years", "it is exposed to boiling water while in a tun", "it has too much food available"]'::JSONB) v);

UPDATE questions SET explanation = 'The first paragraph lays out the trade in both directions. The fungus reaches into soil the roots cannot and delivers water and minerals such as phosphorus; in return the tree sends down sugars made in its leaves, which the fungus cannot make itself. Phosphorus is the trap because it is part of the same exchange, but it flows from fungus to tree, not the other way.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what does the tree give the fungus in their partnership?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Phosphorus drawn from deep soil", "Shelter from sunlight", "Sugars made in its leaves", "Water absorbed through its roots"]'::JSONB) v);

UPDATE questions SET explanation = 'The final sentence sets up a cause and effect: do this to the fungal threads and the trees above grow measurably more slowly. Since those threads carry water and minerals to the trees, only cutting them apart would break the supply and stunt growth. Burying is tempting because the threads are already underground, but burying them would not interrupt anything.'
  WHERE section = 'reading' AND prompt = 'As used in the last sentence of the passage, the word "sever" most nearly means'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["cut", "measure", "fertilize", "bury"]'::JSONB) v);

UPDATE questions SET explanation = 'The third paragraph says researchers disagree about how to describe the arrangement: some call it cooperation among trees, others say the fungus is in charge and moves resources to suit itself. That is an argument over interpretation. Whether carbon moves between trees is not in dispute, since labeled-carbon experiments traced it, and the slower growth after cutting is called undisputed too.'
  WHERE section = 'reading' AND prompt = 'The passage indicates that researchers disagree about'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["whether fungal threads actually connect tree roots", "whether carbon can move between trees at all", "whether cutting fungal threads slows tree growth", "how to interpret the arrangement between the trees and the fungus"]'::JSONB) v);

UPDATE questions SET explanation = 'The author closes by noting that cutting the fungal threads makes the trees above grow measurably more slowly, and opens by saying the forest behaves underground like one connected system. Both point to connections that matter. The idea that trees would do better without fungi is the reverse of that closing result, since removing the network is what slowed them down.'
  WHERE section = 'reading' AND prompt = 'Which statement would the author most likely agree with?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The underground connections between forest trees matter to how the forest grows", "Trees would grow better if fungi were removed from forest soil", "The fungus receives nothing of value from the partnership", "Seedlings on the forest floor are entirely independent of larger trees"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage explains that a leaf keeps making chlorophyll all season to replace what breaks down, and as long as it is being replenished the green overwhelms the other pigments. Saying carotenoids are not yet present is the tempting error and the one the passage is written to correct: the yellows and oranges sit in the leaf all summer, just hidden.'
  WHERE section = 'reading' AND prompt = 'According to the passage, why do leaves look green during the summer?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Carotenoids are not yet present in the leaf", "Chlorophyll is constantly replaced and overwhelms the other pigments", "Sunlight reflects off the surface of the leaf", "Anthocyanin is produced only in warm weather"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage draws this contrast directly. Carotenoids are in the leaf through the whole growing season and only become visible once chlorophyll stops being replaced, while anthocyanin, the red pigment, is manufactured fresh in autumn just before the leaf drops. The reversed version of that statement is the trap, and swapping which pigment is revealed and which is newly made is exactly what the passage rules out.'
  WHERE section = 'reading' AND prompt = 'Based on the passage, how do yellow pigments differ from red ones in autumn leaves?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Yellow pigments were in the leaf all along, while red ones are newly produced", "Red pigments were present all summer, while yellow ones are newly produced", "Both are produced only after the leaf falls from the tree", "Neither is affected by the amount of sunlight a tree receives"]'::JSONB) v);

UPDATE questions SET explanation = 'Red depends on anthocyanin, whose production needs sunny days and cool nights, so a warm cloudy autumn gives a duller display; the passage adds that the yellows still arrive on schedule, since carotenoids are already there. Predicting no color change at all goes too far, because losing chlorophyll still uncovers the yellows no matter what the weather does.'
  WHERE section = 'reading' AND prompt = 'Based on the passage, an autumn that is warm and cloudy would most likely produce'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["no color change at all", "brighter reds than usual", "yellows without especially bright reds", "leaves that stay green into winter"]'::JSONB) v);

UPDATE questions SET explanation = 'From the first line onward the author is answering a why question: why leaves turn yellow and orange, what happens to chlorophyll, and why reds work differently. That is explanation. Describing the life cycle of a leaf from bud to fall is the closest wrong answer, but the passage covers only pigments and color, not how a leaf grows or what it does all season.'
  WHERE section = 'reading' AND prompt = 'The author''s main purpose in the passage is to'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["persuade readers to plant more maple trees", "compare autumn in different parts of the world", "describe the life cycle of a single leaf from bud to fall", "explain the causes of the color changes seen in autumn leaves"]'::JSONB) v);

UPDATE questions SET explanation = 'The paragraph on distillation says heating seawater turns it to vapor and the salt stays behind, and cooling that vapor gives pure water. The membrane answer is the trap: membranes are real in this passage, but they belong to reverse osmosis, the newer method where pressure pushes water through and salt cannot follow. Different method, different step.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what happens to salt when seawater is boiled during distillation?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["It is left behind as the water becomes vapor", "It rises with the vapor and is collected separately", "It dissolves completely and disappears", "It passes through a membrane"]'::JSONB) v);

UPDATE questions SET explanation = 'The last paragraph names brine directly as the stream of extremely salty leftover water that every plant produces and has to put somewhere. Fresh water is the tempting mix-up, since a plant produces that too, but it is the product rather than the leftover. Brine is the concentrated remainder that can harm a shallow bay if dumped carelessly.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what is brine?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Seawater that has been heated but not yet cooled", "A membrane used in reverse osmosis", "Fresh water produced by a desalination plant", "Extremely salty leftover water produced by desalination"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage says reverse osmosis needs far less energy than boiling, which matters because distillation on a citywide scale burns so much fuel that those plants were built mainly where energy is cheap. Producing no brine is the trap: the passage states that every plant produces brine, so reverse osmosis has no advantage there at all.'
  WHERE section = 'reading' AND prompt = 'What advantage does reverse osmosis have over distillation, according to the passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["It removes more of the salt", "It requires far less energy", "It produces no leftover brine", "It can be used far from the coast"]'::JSONB) v);

UPDATE questions SET explanation = 'The last sentence says engineers now treat brine disposal as a problem equal in importance to removing the salt, which means a plant is not judged a success until it handles both. Beating the price of a well is tempting but goes against the passage, which says desalination remains expensive compared with pumping from a river or a well.'
  WHERE section = 'reading' AND prompt = 'The last paragraph suggests that engineers now view a desalination plant as successful only if it'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["operates without any use of electricity", "supplies water more cheaply than a well does", "handles its leftover brine responsibly as well as removing salt", "is built beside a shallow bay"]'::JSONB) v);

UPDATE questions SET explanation = 'The opening paragraph draws a line between what was known and what was not: astronomers had the order of the planets and the proportions of their orbits, but no true measure of the system''s size. The exact distance to the sun is the trap, since it is the very thing they lacked and the thing Halley''s transit method was designed to find.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what did astronomers of the 1700s already understand about the solar system?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The exact distance from Earth to the sun", "The order of the planets and the proportions of their orbits", "The chemical composition of Venus", "The reason transits occur only rarely"]'::JSONB) v);

UPDATE questions SET explanation = 'Halley''s method depends on disagreement. Observers standing far apart see the black dot cross the sun along slightly different paths and record slightly different times, and it is the size of that difference that yields the distance. Spreading out is what creates a measurable gap. Clear weather is tempting, since clouds did ruin some observations, but that was bad luck rather than the reason for the plan.'
  WHERE section = 'reading' AND prompt = 'According to the passage, why did observers have to be stationed far apart on Earth?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["So that at least one of them would have clear weather", "So that the transit would be visible in daylight somewhere", "Because the calculation depended on their timings disagreeing slightly", "Because Venus is visible only from the far north and south"]'::JSONB) v);

UPDATE questions SET explanation = 'The sentence about Halley not living to test the idea is followed immediately by the dates of the next transits, 1761 and 1769, which shows the point is how long the wait would be: the plan had to be carried out by people who came after him. Doubt is the tempting reading, but he argued for the method rather than questioning it.'
  WHERE section = 'reading' AND prompt = 'The detail that Halley knew he would not live to test his idea mainly emphasizes'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["how long a wait the test of his idea would require", "that Halley doubted his own method", "that transits of Venus had never been seen before", "that Halley was in poor health"]'::JSONB) v);

UPDATE questions SET explanation = 'The third paragraph describes hundreds of observers from different countries sailing to Siberia, Hudson Bay, and Tahiti on voyages that took months and often ended badly, and still producing a usable figure. That supports a conclusion about cooperation and risk on a large scale. Calling those voyages safe and quick contradicts the paragraph directly.'
  WHERE section = 'reading' AND prompt = 'Which conclusion is best supported by the third paragraph?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Scientific results sometimes require cooperation and risk on a large scale", "Ocean voyages in the 1700s were generally safe and quick", "Cloudy weather made the entire effort worthless", "Only astronomers from one country took part"]'::JSONB) v);

UPDATE questions SET explanation = 'The opening paragraph states that the name Silk Road was invented by a German geographer in the 1800s, long after the routes themselves were busiest. Merchants are the tempting answer because they are the people in the story, but they were traveling these routes centuries earlier and never used the name, which is part of the author''s point.'
  WHERE section = 'reading' AND prompt = 'According to the passage, who invented the name "Silk Road"?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Merchants traveling between Samarkand and Kashgar", "A German geographer in the 1800s", "Buddhist monks who traveled east into China", "Historians studying the spread of plague"]'::JSONB) v);

UPDATE questions SET explanation = 'The second paragraph explains the pattern: a merchant carried goods only to the next market town, sold them there, and turned back, so the cargo changed hands repeatedly and gained value at every exchange. That is why cloth worth little at the start was a luxury at the far end. Taxing once at the final market is invented detail; the passage says nothing about taxes.'
  WHERE section = 'reading' AND prompt = 'Why did goods become more valuable as they moved along the routes?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Because they were taxed only once, at the final market", "Because the routes grew shorter over time", "Because they were resold at each market town along the way", "Because only luxury items were permitted on the caravans"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage says the oasis cities grew wealthy less from what they produced than from where they sat, at the meeting points along the caravan routes. Their own manufactured goods are the trap, since making things is the usual way a city gets rich, but the author is drawing the opposite contrast: position mattered more than production.'
  WHERE section = 'reading' AND prompt = 'The passage indicates that cities such as Samarkand grew wealthy mainly because of'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["the goods they manufactured themselves", "the size of their farms", "their military strength", "their position along the trading routes"]'::JSONB) v);

UPDATE questions SET explanation = 'The last sentence notes that the ruins of these cities sit in places that now seem remote, then adds that the map of what counts as remote can change. Put together, that says today''s out-of-the-way spots were once central to trade. Saying the ruins were never found reverses the sentence, which states plainly that they remain.'
  WHERE section = 'reading' AND prompt = 'The last sentence of the passage suggests that'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["places now considered remote were once at the center of trade", "the ruins of the caravan cities have never been found", "sea routes were more dangerous than overland routes", "trade along the Silk Road never fully stopped"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage gives both numbers: hauling a ton of flour from Buffalo to New York City by wagon cost roughly a hundred dollars before the canal, and freight charges fell to under ten dollars a ton once it opened in 1825. The reversed version, rising from ten to a hundred, uses the same figures in the wrong order, so read which one goes with the wagon.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what happened to the cost of shipping a ton of flour after the canal opened?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["It rose from about ten dollars to about a hundred", "It fell from about a hundred dollars to under ten", "It stayed roughly the same but the trip grew faster", "It fell only after the railroads were built"]'::JSONB) v);

UPDATE questions SET explanation = 'The second paragraph is clear that the shortage was not crops but transport: farmers west of the Appalachians had land and grain, yet no affordable way to reach an eastern buyer, so much of the harvest stayed put. Saying their land produced little grain contradicts that, and eastern buyers are never described as refusing to purchase.'
  WHERE section = 'reading' AND prompt = 'Before the canal was built, what problem did farmers west of the Appalachians face?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Their land produced very little grain", "Eastern buyers refused to purchase western grain", "They had no affordable way to get their grain to eastern buyers", "Wagons were not yet in use in that part of the country"]'::JSONB) v);

UPDATE questions SET explanation = 'The remark that the builders had no engineering school to have attended sits beside the size of the project and the prediction it would bankrupt the state, and is followed by the note that they learned the work by doing it. The author is emphasizing that no established expertise existed. Poor construction is not implied; the canal worked and its tolls repaid the cost.'
  WHERE section = 'reading' AND prompt = 'The author mentions that the builders "had no engineering school to have attended" mainly to show that'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["the canal was built badly and had to be repaired often", "New York refused to hire trained workers", "engineering schools existed but were too expensive", "the project was undertaken without established expertise"]'::JSONB) v);

UPDATE questions SET explanation = 'The final paragraph says railroads eventually took the traffic, yet the pattern of settlement the canal created did not move, which is a way of saying its effects outlived its role as a shipping route. Claiming it never earned back its cost contradicts the same paragraph, which says tolls repaid construction within about a decade.'
  WHERE section = 'reading' AND prompt = 'Which conclusion about the canal is best supported by the final paragraph?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Its effects outlasted its usefulness as a shipping route", "It never earned back the money spent to build it", "Railroads made the canal impossible to operate", "Its tolls were the main source of New York''s wealth"]'::JSONB) v);

UPDATE questions SET explanation = 'Stanton and Mott met at an antislavery convention where the women delegates were seated behind a curtain and forbidden to speak. That detail shows them shut out of the very cause they had traveled to serve, which explains why they went on to organize a meeting about the position of women. The Declaration of Sentiments listing a king''s offenses comes from its model, the Declaration of Independence, not from the curtain.'
  WHERE section = 'reading' AND prompt = 'The detail that the women delegates in London were seated behind a curtain mainly helps explain'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["why the organizers took up women''s exclusion as its own cause", "why the convention was announced only days before it met", "why the Declaration of Sentiments listed the offenses of a king", "why newspapers mocked the convention for several weeks afterward"]'::JSONB) v);

UPDATE questions SET explanation = 'The second paragraph says the Declaration of Sentiments was modeled closely on the Declaration of Independence, matching its structure: where the original listed the offenses of a king, this one listed the legal disadvantages of married women. The Constitution is the tempting swap, since both are founding American documents, but the passage names the one about grievances.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what document was the Declaration of Sentiments modeled on?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The Constitution", "A London antislavery petition", "The Declaration of Independence", "A New York state law"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage says the demand for the vote struck many in the room as so far beyond possibility that it would make the whole convention look ridiculous, and it passed only after Frederick Douglass spoke for it. So the objection was that it seemed hopeless and embarrassing. Douglass speaking against it reverses his role; his support is what saved the resolution.'
  WHERE section = 'reading' AND prompt = 'According to the passage, why was the resolution demanding the vote nearly rejected?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Frederick Douglass spoke against it during the debate", "It had not appeared in the newspaper announcement", "Married women could already vote in most states", "Many present thought it hopeless and embarrassing"]'::JSONB) v);

UPDATE questions SET explanation = 'The final paragraph puts two things side by side: newspapers mocked the convention and some signers withdrew their names, yet the resolution the room judged most extreme, the one for suffrage, became the movement''s central demand and was won in 1920. That is a ridiculed idea becoming the goal. Saying the meeting had no lasting effect ignores that outcome.'
  WHERE section = 'reading' AND prompt = 'The passage''s final paragraph is best described as showing that'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["a proposal ridiculed at the time eventually became the movement''s central goal", "the convention had no lasting effect on American law", "most signers regretted attending the convention", "newspapers of the era generally supported the convention"]'::JSONB) v);

UPDATE questions SET explanation = 'The opening sentence gives the figure directly: some six million Black Americans left the rural South for northern and western cities between roughly 1915 and 1970. Six hundred thousand and one million are tempting because they are large numbers too, but the passage names a specific one, and the scale is part of why the movement reshaped American cities.'
  WHERE section = 'reading' AND prompt = 'According to the passage, about how many Black Americans left the South during the Great Migration?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Six hundred thousand", "One million", "Six million", "Fifteen million"]'::JSONB) v);

UPDATE questions SET explanation = 'The second paragraph explains the timing: the First World War cut off the flow of European immigrants at the very moment northern factories needed workers, which opened jobs paying several times what a day of field labor did. The war did not create factory jobs in the South, and the passage credits it with changing who was available to fill northern jobs.'
  WHERE section = 'reading' AND prompt = 'According to the passage, how did the First World War contribute to the migration?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["It created factory jobs in the South", "It stopped European immigration just as northern factories needed workers", "It ended the sharecropping system", "It lowered the cost of railroad travel"]'::JSONB) v);

UPDATE questions SET explanation = 'The sentence saying no one organized the migration is followed immediately by the explanation that it was made up of individual decisions repeated in millions of households over half a century. The author is stressing that it added up from separate family choices. Saying it happened by accident with no clear causes misses the next paragraph, which lists the reasons plainly.'
  WHERE section = 'reading' AND prompt = 'The author states that no one organized the Great Migration mainly to emphasize that it'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["happened by accident and had no clear causes", "was kept secret from southern landowners", "was directed by northern factory owners", "resulted from millions of separate family decisions"]'::JSONB) v);

UPDATE questions SET explanation = 'The last paragraph calls what migrants found better paid and still bounded, then gives the limits: housing restricted to a few neighborhoods, higher rents there, and better jobs often closed to them. Improvement with restrictions captures both halves. Saying conditions were no different from the South drops the improvement, and the passage notes wages several times higher.'
  WHERE section = 'reading' AND prompt = 'Which statement best captures the passage''s view of what migrants found in the North?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Conditions were an improvement but remained restricted", "Conditions were no different from those in the South", "Migrants generally returned south within a few years", "Migrants encountered no limits on housing or employment"]'::JSONB) v);

UPDATE questions SET explanation = 'The second paragraph separates what Carnegie paid for from what the town owed: he covered construction only, while the town supplied the site and pledged tax money each year for books and a librarian. Books and the librarian''s salary are tempting because they are named in the same sentence, but as the town''s obligation, which was the whole point of the conditions.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what did Carnegie''s grants pay for?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The librarian''s salary", "The construction of the building", "The purchase of books", "The cost of the land"]'::JSONB) v);

UPDATE questions SET explanation = 'The third paragraph gives his reasoning: handing people things did little good, and a library a community had voted to fund was one that community would actually use. So the yearly tax pledge was a test of commitment. Repaying him is the tempting misread, but that money went to books and staff in the town, never back to Carnegie.'
  WHERE section = 'reading' AND prompt = 'Why did Carnegie require towns to pledge tax money every year?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["To repay him gradually for the cost of the building", "To keep poorer towns from applying", "Because he believed a community that funded a library would use it", "Because the law required public buildings to be locally financed"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage links his beliefs to his own history. He grew up poor and credited his education to a man who opened a private library to working boys, and from that he argued that useful giving supplies people the means to improve themselves through their own effort. Charging a fee cuts against this, since his grants required the library to be free to every resident.'
  WHERE section = 'reading' AND prompt = 'The passage suggests that Carnegie''s experience with a private library opened to working boys'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["convinced him that libraries should charge a small fee", "shaped his belief in giving people the means to improve themselves", "led him to build his first library in Scotland", "made him distrust public education"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage says outright that the conditions mattered more than the buildings, and it is those conditions, a local site, a yearly tax pledge, and free access for everyone, that turned tax-funded free libraries into an ordinary institution. Saying most towns refused over how he made his fortune overstates it: some towns did refuse for that reason, but most said yes.'
  WHERE section = 'reading' AND prompt = 'Which statement about Carnegie''s library program does the passage best support?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The conditions attached to the gift did more to establish libraries than the money alone", "Most towns rejected Carnegie''s offer because of how he had made his fortune", "Carnegie libraries were open only to residents who paid dues", "The libraries closed once Carnegie stopped funding them"]'::JSONB) v);

UPDATE questions SET explanation = 'The second paragraph splits the traffic by direction. Caravans came down from the north carrying slabs of salt, which was scarce and valuable in the south, while boats came upriver with gold, grain, and goods from the forest regions. Gold is the trap because it is the most famous good in the story, but it arrived by river, not by caravan.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what did caravans bring to Timbuktu from the north?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Gold", "Grain", "Salt", "Boats"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage explains that Timbuktu sits where the Niger River comes closest to the Sahara, so the desert caravan route and the river route met there and traders from both could do business. That meeting point is the reason for its trade. Gold mines are tempting, but the gold came from the forest regions upriver rather than from the city itself.'
  WHERE section = 'reading' AND prompt = 'Why did Timbuktu become a center of trade, according to the passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["It had the largest gold mines in West Africa", "It was the capital of a Moroccan empire", "It produced more grain than the surrounding regions", "The desert caravan route and the river route met there"]'::JSONB) v);

UPDATE questions SET explanation = 'The third paragraph opens by saying wealth from the trade paid for something less expected, then describes the centers of learning, the scholars, and the copying of manuscripts as a paid trade. Trade money is what made scholarship possible. The Moroccan army points the other way entirely: it took the city in 1591 and carried leading scholars away.'
  WHERE section = 'reading' AND prompt = 'The passage indicates that scholarship in Timbuktu was made possible mainly by'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["the wealth produced by the city''s trade", "the arrival of the Moroccan army", "the founding of a European university", "the discovery of paper-making in the region"]'::JSONB) v);

UPDATE questions SET explanation = 'The author sets that description against hundreds of thousands of surviving manuscripts that families hid in trunks and buried in sand, a written record of law, astronomy, mathematics, and medicine. Placing them in the same sentence is how the claim gets refuted. Reading it as a statement the author accepts misses the contrast the whole paragraph is built to make.'
  WHERE section = 'reading' AND prompt = 'The last sentence, describing Timbuktu as "a city later described as having no history," is best understood as'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["a statement the author accepts as accurate", "a claim the surviving manuscripts contradict", "an explanation of why the manuscripts were buried", "a quotation from a Timbuktu scholar"]'::JSONB) v);

UPDATE questions SET explanation = 'The second paragraph defines it: lines that are parallel in the real world and run away from the viewer are drawn converging on a single point on the horizon, and that point is the vanishing point. The spot where the viewer must stand is the tempting mix-up, since perspective does fix the viewer in one position, but that is a consequence discussed later, not the definition.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what is the vanishing point?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["The spot where the viewer must stand", "The single point on the horizon where receding parallel lines meet", "The edge of the painted panel", "The point at which a painting is finished"]'::JSONB) v);

UPDATE questions SET explanation = 'The remark comes right before the explanation that these painters were working without a rule nobody had written down yet. The author raises the question of skill in order to dismiss it: what was missing was a method, not talent. Reading it as praise for medieval painting over later work goes further than the passage, which weighs gains against costs rather than ranking the two.'
  WHERE section = 'reading' AND prompt = 'The author says the early painters "were not clumsy" mainly to'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["show that the flatness reflected a missing method, not poor skill", "praise medieval painting as superior to the work that followed", "suggest that early painters worked more quickly than later ones", "explain why so few paintings survive from before about 1420"]'::JSONB) v);

UPDATE questions SET explanation = 'The third paragraph gives the reason directly: the technique spread quickly because it could be taught, being a procedure with steps rather than a talent, so workshops across Italy picked it up within a generation. Being kept secret in one workshop is the opposite of that, and speed of production is never mentioned as a benefit.'
  WHERE section = 'reading' AND prompt = 'According to the passage, why did the technique spread so quickly?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Painters were required by law to use it", "It made paintings much faster to produce", "It was a teachable procedure rather than an inborn talent", "It was kept secret within a single workshop"]'::JSONB) v);

UPDATE questions SET explanation = 'The last paragraph names the trade-off. Perspective is correct from a single viewing position, so it pins the viewer in one spot, while medieval painters had been free to show a figure from whatever angle carried the most meaning. That freedom is what was given up. Bright color never comes up in the passage at all.'
  WHERE section = 'reading' AND prompt = 'The passage suggests that what medieval painters had, and perspective painters gave up, was'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["the ability to paint on wooden panels", "the use of bright color", "an audience that understood their work", "freedom to show a figure from whatever angle carried the most meaning"]'::JSONB) v);

UPDATE questions SET explanation = 'The opening sentence says a haiku is built from seventeen sound units grouped five, seven, and five, which English versions count as syllables set in three lines. Adding five, seven, and five gives seventeen. Fifteen is the tempting near miss because it sits so close to the right total, but no grouping described here adds up to it, and twelve and twenty-one are further off still.'
  WHERE section = 'reading' AND prompt = 'According to the passage, how many syllables does a traditional haiku contain?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Twelve", "Fifteen", "Seventeen", "Twenty-one"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage explains that a seasonal word does the work for the poet: cherry blossoms mean spring, frost means late autumn, a cicada means summer heat, and the reader supplies everything the season implies. Helping reach the syllable count is the trap, since counting is exactly what the author dismisses as the least important part of the form.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what is the purpose of the seasonal word?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["It leaves the reader to fill in the poem''s setting", "It helps the poet reach the required syllable count", "It identifies the poet who wrote the poem", "It marks where the poem should be divided into lines"]'::JSONB) v);

UPDATE questions SET explanation = 'The author calls the three-line, seventeen-syllable description accurate, then says it makes the form sound like a puzzle about counting and goes on to name the seasonal word and the break as what matters more. The complaint is about what it leaves out. Saying it gives the wrong number of syllables misreads that, since the author never disputes the count.'
  WHERE section = 'reading' AND prompt = 'The author calls the standard three-line, seventeen-syllable description "almost useless" because it'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["gives the wrong number of syllables", "applies only to poems written after 1600", "reduces the form to counting and leaves out what matters most", "describes Japanese haiku but not English ones"]'::JSONB) v);

UPDATE questions SET explanation = 'The last paragraph says English haiku often keep the syllable count and drop the rest, which is why so many read like statements chopped into three lines, and closes by saying the restraint was the point. So the shortfall is keeping the rule and losing the restraint. Imitating Basho too closely is not a complaint the passage makes; Basho is held up as the model.'
  WHERE section = 'reading' AND prompt = 'The final paragraph suggests that many English haiku fall short because they'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["are too long to be read aloud", "keep the syllable rule but abandon the restraint that gives the form its power", "use seasonal words that English readers do not recognize", "imitate Basho''s poems too closely"]'::JSONB) v);

UPDATE questions SET explanation = 'The second paragraph places each group by what they paid. A penny bought standing room in the yard, the bare ground right in front of the stage, and the people who stood there were the groundlings. The roofed galleries are the trap: those held benches and cost a penny or two more, which is a different part of the theatre and a different price.'
  WHERE section = 'reading' AND prompt = 'According to the passage, where did the groundlings watch a play?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["In the roofed galleries", "In the lords'' rooms beside the stage", "Standing in the yard in front of the stage", "Outside the theatre walls"]'::JSONB) v);

UPDATE questions SET explanation = 'The third paragraph gives the reason plainly: performances were held in the afternoon because there was no lighting beyond daylight in an open-roofed theatre. A law forbidding plays after dark is the tempting answer because it would produce the same schedule, but the passage names practical light as the cause, not any rule.'
  WHERE section = 'reading' AND prompt = 'According to the passage, why were performances held in the afternoon?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Because most of the audience worked in the evening", "Because the theatre had no lighting other than daylight", "Because plays were forbidden after dark by law", "Because the galleries grew too cold at night"]'::JSONB) v);

UPDATE questions SET explanation = 'Two facts combine here. The Globe had almost no scenery, so a play''s setting had to be established in its lines, which is why characters so often announce where they are. If a modern set shows the place instead, those lines are doing work the scenery has already done. Intermissions are a different matter: the Globe had none, but sets would not require adding them.'
  WHERE section = 'reading' AND prompt = 'The passage suggests that a modern production of a Shakespeare play with elaborate sets would'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["require the audience to stand throughout the performance", "make some of the characters'' spoken descriptions unnecessary", "be impossible to stage without adding several intermissions", "shorten the running time by more than an hour"]'::JSONB) v);

UPDATE questions SET explanation = 'Every detail builds toward the same conclusion: the round shape packed in paying spectators, daylight set the hour, no scenery meant the words carried the setting, and no intermissions meant continuous action, so plays had to hold a restless mixed crowd with words alone. Calling the Globe the largest theatre in England is both unsupported and too small a point to be the main idea.'
  WHERE section = 'reading' AND prompt = 'The main idea of the passage is that'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["the physical conditions of the Globe shaped how its plays were written", "the Globe was the largest theatre in England", "Shakespeare preferred wealthy audiences to poor ones", "outdoor theatres are better suited to drama than indoor ones"]'::JSONB) v);

UPDATE questions SET explanation = 'The opening paragraph describes it as a room a wealthy collector filled with odd objects, a narwhal tusk, a Roman coin, a stuffed crocodile, shown to visitors who had permission to come in. Getting in depended on knowing the owner. A public museum funded by a city is what these rooms later became, after ownership changed, so it names the result rather than the starting point.'
  WHERE section = 'reading' AND prompt = 'According to the passage, what was a cabinet of curiosities?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["A cupboard used to store museum labels", "A room of unusual objects shown to visitors the owner permitted in", "A public museum funded by a city government", "A catalog listing objects for sale"]'::JSONB) v);

UPDATE questions SET explanation = 'The second paragraph names two changes, and the organizational one is that objects grouped together because they were strange were regrouped by category and period, so walking the rooms meant walking through an argument. Returning objects to the countries they came from is tempting because the passage does raise it, but as a recent question, not as the change that made museums.'
  WHERE section = 'reading' AND prompt = 'According to the passage, how did the organization of collections change?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["Objects were arranged by size rather than by owner", "Objects were removed from display and placed in storage", "Objects grouped for their strangeness were regrouped by category and period", "Objects were returned to the countries they came from"]'::JSONB) v);

UPDATE questions SET explanation = 'The author explains that a museum''s arrangement tends to feel like the natural order of things rather than a set of decisions, which is why visitors stop noticing it. Anything that looks inevitable becomes invisible. Saying the choices are explained only in the labels misses the author''s point that the arrangement itself teaches as much as the labels do.'
  WHERE section = 'reading' AND prompt = 'The author says a museum''s arrangement "is easy to overlook" because it'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["is usually hidden from ordinary visitors", "changes too often for visitors to notice", "is explained only in the wall labels", "seems inevitable rather than deliberately chosen"]'::JSONB) v);

UPDATE questions SET explanation = 'The passage argues that regrouping objects by category and period means a visitor is walking through an argument, and that choices about what belongs together and what stays in storage teach as much as the labels. So a museum makes claims through its choices. Saying museums were more useful when private ignores the passage, which notes that admission then depended on knowing the owner.'
  WHERE section = 'reading' AND prompt = 'Which conclusion about museums is best supported by the passage?'
    AND (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text(options) v)
      = (SELECT jsonb_agg(v ORDER BY v) FROM jsonb_array_elements_text('["A museum makes claims through its choices, not only through its objects", "Museums were more useful when they were private", "Objects in storage are more valuable than those on display", "Museums have changed very little since the sixteenth century"]'::JSONB) v);

-- Verification: how many rows in this section carry a long (rewritten)
-- explanation, against the whole section. A partial apply shows up here as
-- a long_explanations count below the expectation.
SELECT
  'reading' AS section,
  COUNT(*) AS total_rows,
  290 AS expected_total_rows,
  COUNT(*) FILTER (WHERE LENGTH(explanation) > 150) AS long_explanations,
  290 AS expected_long_explanations
FROM questions
WHERE section = 'reading';

-- ── Skipped for manual review ────────────────────────────────────────────────
-- These 12 rationales describe a passage that 031/033 has since lengthened.
-- Each needs its explanation re-anchored (or the stem reworded) before it
-- can be applied:
--
--   [  7] Based on the passage, which of the following best describes why advertisers use cognitive disson
--   [  9] The author most likely ends with the sentence about advertisers in order to:
--   [ 11] According to the passage, rain forests help regulate Earth's climate by:
--   [ 19] The passage implies that the printing press contributed most directly to:
--   [ 31] What does the word "syntax" most likely mean as used in the passage about sign language?
--   [ 45] What is this passage mainly about?
--   [ 62] According to the passage, how does the eye detect different colors?
--   [ 85] What is the main idea of this passage?
--   [ 89] Why does the author mention sonar and radar technology at the end of the passage?
--   [104] Why does the author describe Athens' democracy as having "flaws" in the final sentence?
--   [107] What does "antibiotic resistance" mean as described in the passage?
--   [124] Why do strong emotional experiences tend to create more lasting memories?
