-- 041 — Rewrite verbal explanations (250 rows)
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

UPDATE questions SET explanation = 'Happy describes feeling pleasure or contentment, so joyful is the closest match: both name that same warm feeling. Sad is the exact opposite, and it catches students who grab the first emotion word they see. Angry and tired name feelings too, but neither one means pleased.'
  WHERE section = 'verbal' AND prompt = 'HAPPY most nearly means:' AND options = '["Sad", "Joyful", "Angry", "Tired"]'::JSONB;

UPDATE questions SET explanation = 'Ancient means extremely old, so its opposite is modern, meaning belonging to the present time. Old is a synonym of ancient, not an opposite, and that is the easy slip on antonym questions when you are reading fast. Large and quiet describe size and sound, not age at all.'
  WHERE section = 'verbal' AND prompt = 'ANCIENT is the opposite of:' AND options = '["Old", "Large", "Modern", "Quiet"]'::JSONB;

UPDATE questions SET explanation = 'Follow the chain: every cat is an animal, and every animal needs food, so every cat needs food. That makes the conclusion true. Uncertain would fit only if a premise left a gap, and nothing here is left open. False would require the premises to rule the conclusion out, which they do not.'
  WHERE section = 'verbal' AND prompt = 'All cats are animals. All animals need food. All cats need food — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'Say the link as a sentence: a paintbrush is the main tool of a painter, so a scalpel is the main tool of a surgeon. Hospital is where a scalpel gets used, which is a place rather than a person. Nurse and patient are in that room too, but the surgeon holds the blade.'
  WHERE section = 'verbal' AND prompt = 'Paintbrush is to painter as scalpel is to:' AND options = '["Hospital", "Surgeon", "Nurse", "Patient"]'::JSONB;

UPDATE questions SET explanation = 'Look for the shared job. A hammer, a wrench, and a screwdriver all drive, turn, or loosen hardware, so they belong in a toolbox for building and repair. A paintbrush spreads paint on a surface, which is finishing work. Wrench can feel odd as the least familiar, but it still works on hardware.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others?' AND options = '["Hammer", "Wrench", "Screwdriver", "Paintbrush"]'::JSONB;

UPDATE questions SET explanation = 'Eloquent describes speaking or writing that flows clearly and persuades people, which is what articulate means. Loud is only about volume, and an eloquent speaker can be quiet and still convincing. Brief is about length, and confused is the reverse of expressing ideas clearly.'
  WHERE section = 'verbal' AND prompt = 'ELOQUENT most nearly means:' AND options = '["Loud", "Articulate", "Confused", "Brief"]'::JSONB;

UPDATE questions SET explanation = 'Take the overlap group: the musicians who are also teachers. Every teacher is a college graduate, so those musicians are graduates, which makes the conclusion true. Uncertain tempts you because the first premise says only some, but some means at least one, and one is enough. Cannot be determined fails for the same reason.'
  WHERE section = 'verbal' AND prompt = 'Some musicians are teachers. All teachers are college graduates. Some musicians are college graduates — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Cannot be determined"]'::JSONB;

UPDATE questions SET explanation = 'A sycophant is a person defined by giving flattery, so you need the act that defines a martyr: sacrifice. Courage often goes with martyrs, but many brave people never give anything up. Religion is a common setting for martyrdom rather than its defining act, and victory is not part of the idea.'
  WHERE section = 'verbal' AND prompt = 'Sycophant is to flattery as martyr is to:' AND options = '["Religion", "Sacrifice", "Courage", "Victory"]'::JSONB;

UPDATE questions SET explanation = 'Loquacious describes someone who talks a great deal, so talkative is the match. Silent is the opposite, and it draws readers who guess from the stern sound of the word. Logical shares that loq sound but means reasoning clearly, and lazy says nothing about how much a person speaks.'
  WHERE section = 'verbal' AND prompt = 'LOQUACIOUS most nearly means:' AND options = '["Silent", "Logical", "Talkative", "Lazy"]'::JSONB;

UPDATE questions SET explanation = 'The premises say no reptile is warm-blooded and that some egg-layers are warm-blooded. Those particular egg-layers cannot be reptiles, but nothing tells you about the other egg-layers, so the answer is uncertain. False is the trap: the premises never rule out a cold-blooded reptile that lays eggs.'
  WHERE section = 'verbal' AND prompt = 'No reptiles are warm-blooded. Some egg-layers are warm-blooded. Some egg-layers are reptiles — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Impossible"]'::JSONB;

UPDATE questions SET explanation = 'Bold means acting with courage and confidence when something is risky, which is what brave means. Timid is the opposite, describing someone who shrinks back, and it is the trap for readers moving quickly. Quiet describes how much noise a person makes and tired describes energy; neither is about courage.'
  WHERE section = 'verbal' AND prompt = 'BOLD most nearly means:' AND options = '["Timid", "Brave", "Quiet", "Tired"]'::JSONB;

UPDATE questions SET explanation = 'Swift means moving with great speed, so fast is the match. Slow is its opposite and catches anyone who grabs the first word about speed on the list. Gentle describes how softly something is done, and bright describes light or quick thinking. Only fast measures how quickly something moves.'
  WHERE section = 'verbal' AND prompt = 'SWIFT most nearly means:' AND options = '["Slow", "Gentle", "Fast", "Bright"]'::JSONB;

UPDATE questions SET explanation = 'Gloomy describes a low, unhappy mood, so sad fits best. Cheerful is the opposite feeling. Gloomy can also describe a dark sky, which makes people reach for a weather word, but among these choices only sad names the mood. Hungry and loud describe the body and sound instead of emotion.'
  WHERE section = 'verbal' AND prompt = 'GLOOMY most nearly means:' AND options = '["Cheerful", "Hungry", "Loud", "Sad"]'::JSONB;

UPDATE questions SET explanation = 'Huge means very large in size, and enormous means exactly that. Tiny is the opposite, and it tempts anyone skimming for a size word without checking the direction. Heavy is about weight, and a huge balloon can still be light. Loud is about sound, so only enormous matches size.'
  WHERE section = 'verbal' AND prompt = 'HUGE most nearly means:' AND options = '["Tiny", "Heavy", "Enormous", "Loud"]'::JSONB;

UPDATE questions SET explanation = 'Weary means worn out and tired, usually after long effort. Weak is the close miss: it describes lacking strength, which is not the same as needing rest. Alert is the opposite of weary, and worried describes anxiety in the mind rather than tiredness in the body, so tired is the best fit.'
  WHERE section = 'verbal' AND prompt = 'WEARY most nearly means:' AND options = '["Alert", "Tired", "Worried", "Weak"]'::JSONB;

UPDATE questions SET explanation = 'Filthy means extremely dirty, covered in grime, so dirty is the closest meaning. Messy is the tempting near-miss: a messy room is disorganized but can be perfectly clean. Smelly describes odor, which often goes with filth without being what the word means, and clean is the opposite.'
  WHERE section = 'verbal' AND prompt = 'FILTHY most nearly means:' AND options = '["Clean", "Messy", "Dirty", "Smelly"]'::JSONB;

UPDATE questions SET explanation = 'Chilly means unpleasantly cold, so cold is the match. Breezy describes moving air, and while a breeze can make you feel chilly, wind is not the same as temperature. Wet describes moisture and hot is the opposite. Keep the meaning centered on how cold something feels.'
  WHERE section = 'verbal' AND prompt = 'CHILLY most nearly means:' AND options = '["Hot", "Breezy", "Cold", "Wet"]'::JSONB;

UPDATE questions SET explanation = 'Furious describes anger at full strength, so very angry is the match. Frightened is a strong feeling too, which makes it tempting, but fear and anger are different emotions. Pleased is the opposite in mood, and confused describes not understanding something rather than any level of anger.'
  WHERE section = 'verbal' AND prompt = 'FURIOUS most nearly means:' AND options = '["Pleased", "Confused", "Very angry", "Frightened"]'::JSONB;

UPDATE questions SET explanation = 'Damp means slightly wet, which is exactly what moist means. Dry is the opposite and is the easy slip when you skim. Frozen describes water turned to ice rather than water simply present, and warm describes temperature instead of moisture, since a damp towel can be cool or warm.'
  WHERE section = 'verbal' AND prompt = 'DAMP most nearly means:' AND options = '["Dry", "Moist", "Frozen", "Warm"]'::JSONB;

UPDATE questions SET explanation = 'A foe is someone who opposes you, an enemy. Friend points the other way, and ally is its close cousin: an ally fights on your side, which makes it an opposite of foe rather than a match. Partner also names someone who works with you, not against you.'
  WHERE section = 'verbal' AND prompt = 'FOE most nearly means:' AND options = '["Friend", "Ally", "Enemy", "Partner"]'::JSONB;

UPDATE questions SET explanation = 'Slim describes a narrow, slender build, so thin is the match. Small is the tempting near-miss because it also suggests less of something, but small measures total size while slim measures width. Short describes height only, and weak describes strength, which a slim person may or may not lack.'
  WHERE section = 'verbal' AND prompt = 'SLIM most nearly means:' AND options = '["Short", "Thin", "Small", "Weak"]'::JSONB;

UPDATE questions SET explanation = 'Brave means willing to face danger or difficulty, which is what courageous means. Reckless is the trap: it means taking risks without thinking, while bravery means knowing the danger and acting anyway. Strong describes physical power, and proud describes how someone feels about themselves.'
  WHERE section = 'verbal' AND prompt = 'BRAVE most nearly means:' AND options = '["Reckless", "Courageous", "Strong", "Proud"]'::JSONB;

UPDATE questions SET explanation = 'Generous means freely giving to others, so its opposite is selfish, keeping things for yourself. Kind sits close to generous in meaning rather than against it, which makes it the easy wrong pick on an opposite question. Wealthy is about money owned and humble is about modesty.'
  WHERE section = 'verbal' AND prompt = 'GENEROUS is the opposite of:' AND options = '["Kind", "Wealthy", "Selfish", "Humble"]'::JSONB;

UPDATE questions SET explanation = 'Noisy means full of unwanted sound, so its opposite is quiet, meaning little or no sound. Loud is a synonym of noisy, not an opposite, and it is the classic trap when you read the question as if it asked for a similar word. Soft leans toward quiet but describes gentleness, and busy is about activity.'
  WHERE section = 'verbal' AND prompt = 'NOISY is the opposite of:' AND options = '["Loud", "Busy", "Quiet", "Soft"]'::JSONB;

UPDATE questions SET explanation = 'Difficult means requiring a lot of effort, so its opposite is easy. Hard means the same thing as difficult, so it is a synonym rather than a reversal, and it catches students who stop reading after the first word that fits. Painful is about hurting and boring is about interest, not effort.'
  WHERE section = 'verbal' AND prompt = 'DIFFICULT is the opposite of:' AND options = '["Hard", "Easy", "Painful", "Boring"]'::JSONB;

UPDATE questions SET explanation = 'Victory means winning, so its opposite is defeat, which means losing. Battle names the event where winning or losing happens rather than the reverse of winning, which makes it the tempting miss. Struggle describes hard effort that can end either way, and prize names something a winner receives.'
  WHERE section = 'verbal' AND prompt = 'VICTORY is the opposite of:' AND options = '["Battle", "Prize", "Defeat", "Struggle"]'::JSONB;

UPDATE questions SET explanation = 'Freeze means to turn solid as heat leaves, so its opposite is melt, turning solid to liquid with heat. Cool is tempting because it points the same direction as freeze, only milder, making it a weaker version instead of a reversal. Harden also moves toward solid, and slow is about speed.'
  WHERE section = 'verbal' AND prompt = 'FREEZE is the opposite of:' AND options = '["Cool", "Melt", "Harden", "Slow"]'::JSONB;

UPDATE questions SET explanation = 'Polite means showing good manners, so its opposite is rude, showing bad ones. Friendly sits near polite in meaning rather than against it, which makes it the tempting miss on an opposite question. Shy describes nervousness around people and quiet describes low volume; neither reverses good manners.'
  WHERE section = 'verbal' AND prompt = 'POLITE is the opposite of:' AND options = '["Friendly", "Rude", "Shy", "Quiet"]'::JSONB;

UPDATE questions SET explanation = 'Expand means to get larger, so its opposite is shrink, to become smaller. Grow means nearly the same as expand, so it is a synonym rather than a reversal, and it is the fastest wrong answer to reach for. Spread also means covering more area, and open is about access.'
  WHERE section = 'verbal' AND prompt = 'EXPAND is the opposite of:' AND options = '["Grow", "Open", "Shrink", "Spread"]'::JSONB;

UPDATE questions SET explanation = 'A sharp edge cuts easily, so its opposite is dull, an edge too blunt to cut. Bright is tempting because sharp can also describe a clear image or a quick mind, but bright points the same way as that meaning instead of reversing it. Hard and thin describe material and width.'
  WHERE section = 'verbal' AND prompt = 'SHARP is the opposite of:' AND options = '["Bright", "Dull", "Hard", "Thin"]'::JSONB;

UPDATE questions SET explanation = 'Arrive means to reach a place, so its opposite is depart, to leave it. Come means about the same as arrive, so it is a synonym and the most common wrong pick here. Enter also describes going into somewhere, and land names one particular way of arriving.'
  WHERE section = 'verbal' AND prompt = 'ARRIVE is the opposite of:' AND options = '["Land", "Come", "Depart", "Enter"]'::JSONB;

UPDATE questions SET explanation = 'Tame means an animal is used to people and no longer dangerous, so its opposite is wild, living free and untamed. Gentle describes the calm behavior tame animals usually show, which puts it on the synonym side. Trained is close to tame as well, and safe names a result rather than a reversal.'
  WHERE section = 'verbal' AND prompt = 'TAME is the opposite of:' AND options = '["Gentle", "Trained", "Wild", "Safe"]'::JSONB;

UPDATE questions SET explanation = 'Thick means having a lot of distance from one surface through to the other, so its opposite is thin. Wide is the tempting miss because it also measures across, but width is a different dimension: a board can be wide and still thin. Large and heavy describe overall size and weight.'
  WHERE section = 'verbal' AND prompt = 'THICK is the opposite of:' AND options = '["Wide", "Thin", "Large", "Heavy"]'::JSONB;

UPDATE questions SET explanation = 'A coward runs from danger, so the opposite is a hero, someone who faces danger for others. Warrior tempts you because warriors fight, but warrior names a job and does not by itself mean fearless. Champion names a winner, and villain names someone evil rather than someone brave.'
  WHERE section = 'verbal' AND prompt = 'COWARD is the opposite of:' AND options = '["Villain", "Warrior", "Hero", "Champion"]'::JSONB;

UPDATE questions SET explanation = 'Say the link out loud: a pen is the tool a writer uses, so a brush is the tool a painter uses. Canvas is the surface a brush works on rather than the person using it, and paint is the material it carries. Museum is where the finished work ends up hanging.'
  WHERE section = 'verbal' AND prompt = 'Pen is to writer as brush is to:' AND options = '["Canvas", "Painter", "Paint", "Museum"]'::JSONB;

UPDATE questions SET explanation = 'A puppy is a young dog, so a kitten is a young cat. Lion is the tempting miss, since some books call lion babies kittens, but the everyday pair is kitten and cat. Fur and paw are body parts an animal has, which breaks the young-to-grown pattern entirely.'
  WHERE section = 'verbal' AND prompt = 'Puppy is to dog as kitten is to:' AND options = '["Lion", "Fur", "Cat", "Paw"]'::JSONB;

UPDATE questions SET explanation = 'A glove is worn over the hand, so a boot is worn over the foot. Leg is the near-miss, since tall boots cover part of the leg, but the body part a boot is built for is the foot. Sock and shoe are other coverings rather than body parts.'
  WHERE section = 'verbal' AND prompt = 'Glove is to hand as boot is to:' AND options = '["Leg", "Foot", "Shoe", "Sock"]'::JSONB;

UPDATE questions SET explanation = 'A fin is the body part a fish uses to move through water, so a wing is the body part a bird uses to move through air. Sky names where flying happens, not the animal that owns the wing. Fly is the action itself, and feather is a smaller piece of a wing.'
  WHERE section = 'verbal' AND prompt = 'Fin is to fish as wing is to:' AND options = '["Sky", "Feather", "Bird", "Fly"]'::JSONB;

UPDATE questions SET explanation = 'A library is a place that collects and holds books, so a museum is a place that collects and holds artifacts. History is a subject many museums cover rather than the objects in their cases. Tickets and tours are part of visiting a museum, not what it stores.'
  WHERE section = 'verbal' AND prompt = 'Library is to books as museum is to:' AND options = '["History", "Artifacts", "Tickets", "Tours"]'::JSONB;

UPDATE questions SET explanation = 'A doctor is the professional who works in a hospital, so a chef is the professional who works in a restaurant. Food is what a chef makes, which is a different relationship from a workplace. Recipe and menu are things a chef writes and follows on the job.'
  WHERE section = 'verbal' AND prompt = 'Doctor is to hospital as chef is to:' AND options = '["Food", "Recipe", "Menu", "Restaurant"]'::JSONB;

UPDATE questions SET explanation = 'A cub is a young bear, so a lamb is a young sheep. Goat tempts you because goats and sheep look alike and share a barnyard, but a baby goat is called a kid, not a lamb. Wool is what sheep produce and farm is where they live.'
  WHERE section = 'verbal' AND prompt = 'Cub is to bear as lamb is to:' AND options = '["Goat", "Wool", "Sheep", "Farm"]'::JSONB;

UPDATE questions SET explanation = 'Scissors are the tool and cutting is what you do with them, so a needle is the tool and sewing is what you do with it. Thread is the material a needle carries rather than the action. Knit belongs to knitting needles in particular, and pin names another object, not an action.'
  WHERE section = 'verbal' AND prompt = 'Scissors is to cut as needle is to:' AND options = '["Thread", "Sew", "Knit", "Pin"]'::JSONB;

UPDATE questions SET explanation = 'A floor is the surface below you and a ceiling is the surface above, so the ground below pairs with the sky above. Roof is the tempting miss because a roof also sits overhead, but a roof belongs to a building the way a ceiling does, while sky is the outdoor match for ground.'
  WHERE section = 'verbal' AND prompt = 'Floor is to ceiling as ground is to:' AND options = '["Dirt", "Earth", "Sky", "Roof"]'::JSONB;

UPDATE questions SET explanation = 'Bark is the outer layer that covers and protects a tree, so skin is the outer layer that covers a body. Fur is the near-miss since fur also sits on the outside, but fur grows out of skin instead of being what skin covers. Hair works the same way, and bone is inside.'
  WHERE section = 'verbal' AND prompt = 'Bark is to tree as skin is to:' AND options = '["Hair", "Body", "Bone", "Fur"]'::JSONB;

UPDATE questions SET explanation = 'Feeling sad causes you to cry, so finding something funny causes you to laugh. Smile is the near-miss: a smile is a milder reaction, while laughing matches crying in strength. Joke names a thing that is funny rather than a reaction to it, and play does not fit the pattern.'
  WHERE section = 'verbal' AND prompt = 'Sad is to cry as funny is to:' AND options = '["Joke", "Smile", "Laugh", "Play"]'::JSONB;

UPDATE questions SET explanation = 'A chapter is one division of a book, so a scene is one division of a movie. Stage tempts you because plays also have scenes, but a stage is a place, not something scenes divide. Script is the written text and actor is a person, and scenes are not parts of either.'
  WHERE section = 'verbal' AND prompt = 'Chapter is to book as scene is to:' AND options = '["Actor", "Script", "Movie", "Stage"]'::JSONB;

UPDATE questions SET explanation = 'The mouth is the body part you use to speak, so the ear is the body part you use to hear. Listen is the sharp trap: listening means paying attention on purpose, while hearing is what the ear does on its own, matching how speaking works. Sound and head are not actions.'
  WHERE section = 'verbal' AND prompt = 'Mouth is to speak as ear is to:' AND options = '["Sound", "Head", "Hear", "Listen"]'::JSONB;

UPDATE questions SET explanation = 'Every bird has wings, and a penguin is a bird, so a penguin has wings, and the conclusion is true. Uncertain tempts anyone thinking about the fact that penguins cannot fly, but the premise is about having wings, not using them. Nothing in the premises leaves room for doubt.'
  WHERE section = 'verbal' AND prompt = 'All birds have wings. A penguin is a bird. A penguin has wings — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Impossible"]'::JSONB;

UPDATE questions SET explanation = 'All squares are rectangles, and shape X is a square, so shape X is a rectangle, which makes the conclusion true. Maybe tempts you if you remember that a rectangle is not always a square, but the premise runs from square to rectangle, and that is the direction the question asks about.'
  WHERE section = 'verbal' AND prompt = 'All squares are rectangles. Shape X is a square. Shape X is a rectangle — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Maybe"]'::JSONB;

UPDATE questions SET explanation = 'No fish can climb trees, and Goldie is a fish, so saying Goldie can climb trees contradicts the premises, making the conclusion false. Uncertain is the trap: uncertain is for conclusions the premises leave open, and the word no closes the door completely on any fish climbing.'
  WHERE section = 'verbal' AND prompt = 'No fish can climb trees. Goldie is a fish. Goldie can climb trees — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Maybe"]'::JSONB;

UPDATE questions SET explanation = 'All dogs bark, and Rex is a dog, so Rex barks, which makes the conclusion true. Uncertain tempts students thinking about real dogs that rarely make noise, but on these questions you treat the premises as given facts and follow them exactly, even when the real world is messier.'
  WHERE section = 'verbal' AND prompt = 'All dogs bark. Rex is a dog. Rex barks — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'Only some students like math, so being a student does not tell you which group Maria falls into, and the conclusion is uncertain. True is the trap: some means at least one, never all, so it cannot carry over to a named person. False is wrong too, since Maria might well like math.'
  WHERE section = 'verbal' AND prompt = 'Some students like math. Maria is a student. Maria likes math — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'Follow the chain: every rose is a flower, and every flower needs water, so every rose needs water, and the conclusion is true. Uncertain would be right only if a link were missing, but both premises use all, which connects roses to water with no gap left anywhere.'
  WHERE section = 'verbal' AND prompt = 'All roses are flowers. All flowers need water. All roses need water — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Impossible"]'::JSONB;

UPDATE questions SET explanation = 'Sort by category. Apple, banana, and grape all grow as fruit, the sweet seed-carrying part of a plant. A carrot is a root we eat as a vegetable, so it is the one that does not fit. Banana can feel odd because of its shape, but shape is not what groups these words.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others?' AND options = '["Apple", "Banana", "Carrot", "Grape"]'::JSONB;

UPDATE questions SET explanation = 'These are all things you wear, so look for the smaller shared group. A shirt, pants, and a hat are cloth garments. Shoes are footwear, built with a stiff sole for walking and usually made of leather or rubber. Hat can feel odd for sitting on your head, but it is still cloth clothing.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others?' AND options = '["Shirt", "Pants", "Hat", "Shoes"]'::JSONB;

UPDATE questions SET explanation = 'A robin, a sparrow, and an eagle are all birds, animals with feathers and wings. A salmon is a fish that breathes through gills and lives in water, so it is the outsider. Eagle can feel different because it is a large hunter, but size and diet do not change the group.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others?' AND options = '["Robin", "Sparrow", "Eagle", "Salmon"]'::JSONB;

UPDATE questions SET explanation = 'A circle, a square, and a triangle are flat shapes you can draw on paper, having only length and width. A cube is a solid with depth as well, so it does not belong. Triangle might seem odd for having the fewest sides, but the grouping here is flat versus solid.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others?' AND options = '["Circle", "Square", "Triangle", "Cube"]'::JSONB;

UPDATE questions SET explanation = 'Candid means saying what you truly think without hiding any of it, which is what honest means. Secret is the opposite, describing something kept hidden. Polite is the interesting miss: candid remarks are often blunt, and being polite sometimes means softening the truth. Careful describes caution, not truthfulness.'
  WHERE section = 'verbal' AND prompt = 'CANDID most nearly means:' AND options = '["Secret", "Honest", "Polite", "Careful"]'::JSONB;

UPDATE questions SET explanation = 'Resilient describes bouncing back after something knocks you down, so able to recover is the match. Flexible is the tempting one because both suggest not breaking, but flexible means bending easily rather than returning after damage. Fragile is the opposite, and stubborn means refusing to change your mind.'
  WHERE section = 'verbal' AND prompt = 'RESILIENT most nearly means:' AND options = '["Flexible", "Stubborn", "Able to recover", "Fragile"]'::JSONB;

UPDATE questions SET explanation = 'To scrutinize is to look at something very closely and check every detail, so examine carefully fits. Criticize is the trap: close inspection often turns up faults, but the word itself is about looking, not judging. Ignore is the opposite, and clean thoroughly borrows the care without the looking.'
  WHERE section = 'verbal' AND prompt = 'SCRUTINIZE most nearly means:' AND options = '["Ignore", "Examine carefully", "Clean thoroughly", "Criticize"]'::JSONB;

UPDATE questions SET explanation = 'Vivid describes an image so strong and sharp it almost seems real, so bright and clear is the match. Colorful is the close miss: colors often make a picture vivid, but a vivid memory or description may involve no color at all. Dull is the opposite, and alive is a different idea.'
  WHERE section = 'verbal' AND prompt = 'VIVID most nearly means:' AND options = '["Dull", "Alive", "Bright and clear", "Colorful"]'::JSONB;

UPDATE questions SET explanation = 'As a describing word, novel means new and original, something not done before. Fictional is the trap set by the noun novel, a made-up story, but the question asks about the adjective. Old is the opposite of new, and long describes size rather than the freshness of an idea.'
  WHERE section = 'verbal' AND prompt = 'NOVEL most nearly means:' AND options = '["Old", "Fictional", "New and original", "Long"]'::JSONB;

UPDATE questions SET explanation = 'Diligent describes steady, careful effort kept up over time, so hardworking is the match. Clever is tempting because we praise both, but cleverness is quick thinking while diligence is putting in the work. Lazy is the opposite, and loyal describes sticking by people rather than sticking with a task.'
  WHERE section = 'verbal' AND prompt = 'DILIGENT most nearly means:' AND options = '["Lazy", "Hardworking", "Clever", "Loyal"]'::JSONB;

UPDATE questions SET explanation = 'Dubious means unsure, having doubts about whether something is true. Dangerous is the trap because dubious often appears near shady situations, as in a dubious deal, but the word itself means doubt, not risk. Certain is the opposite, and clever describes intelligence rather than uncertainty.'
  WHERE section = 'verbal' AND prompt = 'DUBIOUS most nearly means:' AND options = '["Certain", "Doubtful", "Dangerous", "Clever"]'::JSONB;

UPDATE questions SET explanation = 'Tranquil describes a place or mood free from disturbance, so peaceful fits. Boring is the miss to watch for: quiet scenes can feel dull, but tranquil says calm without calling it uninteresting. Slow describes pace and noisy is the opposite, so keep the meaning on stillness.'
  WHERE section = 'verbal' AND prompt = 'TRANQUIL most nearly means:' AND options = '["Noisy", "Boring", "Peaceful", "Slow"]'::JSONB;

UPDATE questions SET explanation = 'To hinder is to get in the way of something, making it harder or slower to happen, so slow down fits best. Help is the opposite. Hide looks and sounds a bit like hinder, which is the trap, but hindering blocks progress rather than concealing anything. Follow is unrelated.'
  WHERE section = 'verbal' AND prompt = 'HINDER most nearly means:' AND options = '["Help", "Slow down", "Hide", "Follow"]'::JSONB;

UPDATE questions SET explanation = 'Frugal describes being careful with money and avoiding waste, which is exactly what thrifty means. Greedy is the tempting miss: a frugal person spends little, but greed means wanting more for yourself, a different attitude. Wasteful is the opposite, and generous describes giving freely to others.'
  WHERE section = 'verbal' AND prompt = 'FRUGAL most nearly means:' AND options = '["Generous", "Wasteful", "Thrifty", "Greedy"]'::JSONB;

UPDATE questions SET explanation = 'Amiable describes a pleasant, easy-to-like manner, so friendly is the match. Admirable looks and sounds close, which is the trap, but it means deserving respect rather than being warm toward people. Capable means skilled at doing things, and hostile is the opposite of amiable.'
  WHERE section = 'verbal' AND prompt = 'AMIABLE most nearly means:' AND options = '["Hostile", "Friendly", "Capable", "Admirable"]'::JSONB;

UPDATE questions SET explanation = 'Benevolent describes wishing others well and acting kindly, so kind-hearted fits. Powerful is the trap because the word often shows up describing a benevolent ruler, but the power comes from the ruler, not from the word itself. Harmful and selfish both point the other way, toward hurting or hoarding.'
  WHERE section = 'verbal' AND prompt = 'BENEVOLENT most nearly means:' AND options = '["Harmful", "Selfish", "Kind-hearted", "Powerful"]'::JSONB;

UPDATE questions SET explanation = 'To ponder is to turn something over in your mind carefully and for a while, so think deeply about fits. Wonder is the near-miss: wondering is a passing curiosity, while pondering is sustained thought. Disagree means taking a side, and measure means finding a size or amount.'
  WHERE section = 'verbal' AND prompt = 'PONDER most nearly means:' AND options = '["Wonder", "Think deeply about", "Disagree", "Measure"]'::JSONB;

UPDATE questions SET explanation = 'Placid describes a person or scene not easily disturbed, so calm is the match. Flat is the tricky one because a placid lake is smooth and level, but flat describes a shape while placid describes an untroubled nature. Pleased names a happy feeling, and upset is the opposite.'
  WHERE section = 'verbal' AND prompt = 'PLACID most nearly means:' AND options = '["Upset", "Flat", "Calm", "Pleased"]'::JSONB;

UPDATE questions SET explanation = 'Meticulous describes work done with care for every small detail, so paying great attention to detail is the match. Slow is the near-miss, since that care often takes time, but speed is not part of the meaning. Strict is about enforcing rules, and careless points the opposite way.'
  WHERE section = 'verbal' AND prompt = 'METICULOUS most nearly means:' AND options = '["Careless", "Paying great attention to detail", "Slow", "Strict"]'::JSONB;

UPDATE questions SET explanation = 'Abundant means there is more than enough of something, so its opposite is scarce, meaning hard to find. Plentiful is a synonym of abundant rather than a reversal, and it is the standard trap on opposite questions. Expensive describes price and common describes how often something appears.'
  WHERE section = 'verbal' AND prompt = 'ABUNDANT is the opposite of:' AND options = '["Plentiful", "Scarce", "Expensive", "Common"]'::JSONB;

UPDATE questions SET explanation = 'Transparent means light passes straight through, the way it does through a window, so its opposite is opaque, which blocks light completely. Clear means the same as transparent, making it a synonym instead of an opposite. Shiny describes how a surface reflects light and fragile describes breaking easily.'
  WHERE section = 'verbal' AND prompt = 'TRANSPARENT is the opposite of:' AND options = '["Clear", "Shiny", "Opaque", "Fragile"]'::JSONB;

UPDATE questions SET explanation = 'Arrogant means thinking you are better than everyone else, so its opposite is humble, holding a modest view of yourself. Proud is the trap: it leans the same direction as arrogant rather than against it. Rude describes bad manners and ignorant describes lacking knowledge, neither about self-importance.'
  WHERE section = 'verbal' AND prompt = 'ARROGANT is the opposite of:' AND options = '["Proud", "Humble", "Rude", "Ignorant"]'::JSONB;

UPDATE questions SET explanation = 'Compulsory means you have to do it because a rule or law says so, so its opposite is optional, meaning you choose. Required means the same as compulsory, which makes it the fastest wrong answer to grab. Forced is another synonym-side choice, and strict describes how firmly rules get enforced.'
  WHERE section = 'verbal' AND prompt = 'COMPULSORY is the opposite of:' AND options = '["Required", "Forced", "Optional", "Strict"]'::JSONB;

UPDATE questions SET explanation = 'Trivial means so small it hardly matters, so its opposite is important. Minor means about the same as trivial, so it is a synonym rather than a reversal, and it catches students reading quickly. Boring describes how interesting something is and simple describes how easy it is.'
  WHERE section = 'verbal' AND prompt = 'TRIVIAL is the opposite of:' AND options = '["Minor", "Important", "Boring", "Simple"]'::JSONB;

UPDATE questions SET explanation = 'To conceal is to keep something out of sight, so its opposite is to reveal, bringing it into view. Hide means the same as conceal, so it is a synonym and the most common wrong pick here. Cover is another way of concealing, and protect means keeping something safe.'
  WHERE section = 'verbal' AND prompt = 'CONCEAL is the opposite of:' AND options = '["Hide", "Cover", "Reveal", "Protect"]'::JSONB;

UPDATE questions SET explanation = 'Timid means lacking courage and holding back, so its opposite is bold, acting with confidence. Shy is a synonym of timid rather than its reverse, and it is the classic trap on this question. Nervous points the same direction, and gentle describes a soft manner rather than courage.'
  WHERE section = 'verbal' AND prompt = 'TIMID is the opposite of:' AND options = '["Shy", "Bold", "Nervous", "Gentle"]'::JSONB;

UPDATE questions SET explanation = 'Humble means not thinking too highly of yourself, so its opposite is arrogant, believing you are better than others. Modest means nearly the same as humble, so it is a synonym instead of an opposite. Quiet describes how much someone speaks and simple describes plainness, not self-image.'
  WHERE section = 'verbal' AND prompt = 'HUMBLE is the opposite of:' AND options = '["Modest", "Quiet", "Arrogant", "Simple"]'::JSONB;

UPDATE questions SET explanation = 'To prolong is to make something last longer, so its opposite is to shorten it. Extend is a synonym of prolong, which makes it the easiest wrong answer to grab. Delay pushes an event later without changing how long it lasts, and continue means keeping something going.'
  WHERE section = 'verbal' AND prompt = 'PROLONG is the opposite of:' AND options = '["Extend", "Shorten", "Delay", "Continue"]'::JSONB;

UPDATE questions SET explanation = 'Hostile means acting like an enemy, unfriendly and threatening, so its opposite is welcoming, greeting others warmly. Unfriendly means nearly the same as hostile, so it is a synonym rather than a reversal. Aggressive also matches hostile, and angry names a feeling that often comes with it.'
  WHERE section = 'verbal' AND prompt = 'HOSTILE is the opposite of:' AND options = '["Unfriendly", "Aggressive", "Welcoming", "Angry"]'::JSONB;

UPDATE questions SET explanation = 'Pessimistic means expecting things to go badly, so its opposite is optimistic, expecting them to go well. Gloomy describes that same dark outlook, which makes it a synonym trap. Negative is another synonym-side choice, and realistic sits in the middle, judging things as they actually are.'
  WHERE section = 'verbal' AND prompt = 'PESSIMISTIC is the opposite of:' AND options = '["Gloomy", "Optimistic", "Realistic", "Negative"]'::JSONB;

UPDATE questions SET explanation = 'Inferior means lower in quality or rank, so its opposite is superior, higher in quality or rank. Lower repeats the meaning of inferior instead of reversing it, and worse does the same, which is why both feel tempting. Secondary means coming after something rather than being better than it.'
  WHERE section = 'verbal' AND prompt = 'INFERIOR is the opposite of:' AND options = '["Lower", "Worse", "Superior", "Secondary"]'::JSONB;

UPDATE questions SET explanation = 'Lenient means going easy on people and punishing lightly, so its opposite is strict, demanding firm obedience. Permissive means nearly the same as lenient, which makes it a synonym trap. Mild leans that same gentle direction, and kind describes warmth rather than how firmly rules get enforced.'
  WHERE section = 'verbal' AND prompt = 'LENIENT is the opposite of:' AND options = '["Kind", "Mild", "Strict", "Permissive"]'::JSONB;

UPDATE questions SET explanation = 'Chaos means complete disorder with nothing in its place, so its opposite is order, everything arranged and organized. Disorder is a synonym of chaos rather than a reversal, and confusion names the feeling chaos creates. Noise often comes with chaos, but a silent room can still be a mess.'
  WHERE section = 'verbal' AND prompt = 'CHAOS is the opposite of:' AND options = '["Disorder", "Confusion", "Order", "Noise"]'::JSONB;

UPDATE questions SET explanation = 'Meager means a very small, insufficient amount, so its opposite is abundant, meaning plenty. Scarce means about the same as meager, so it is a synonym rather than an opposite. Thin describes width and weak describes strength, and neither one reverses the idea of having too little.'
  WHERE section = 'verbal' AND prompt = 'MEAGER is the opposite of:' AND options = '["Thin", "Scarce", "Abundant", "Weak"]'::JSONB;

UPDATE questions SET explanation = 'Warmth causes comfort, so you need the feeling cold causes: discomfort. Winter is a season when cold arrives rather than an effect of it. Snow and ice are forms water takes in the cold, which keeps the pattern on things instead of on how the body feels.'
  WHERE section = 'verbal' AND prompt = 'Warmth is to comfort as cold is to:' AND options = '["Snow", "Discomfort", "Winter", "Ice"]'::JSONB;

UPDATE questions SET explanation = 'An author creates a novel, so a composer creates a symphony. Musician is the tempting one, but a musician performs music instead of being the work that gets created. Piano is an instrument the music is played on, and concert is the event where people hear it.'
  WHERE section = 'verbal' AND prompt = 'Author is to novel as composer is to:' AND options = '["Piano", "Concert", "Symphony", "Musician"]'::JSONB;

UPDATE questions SET explanation = 'A drought is a severe shortage of water, so a famine is a severe shortage of food. Hunger is the trap: it is the result of a famine, not the thing missing. Crops are one source of food, and poverty is a cause that can lead to famine rather than what famine lacks.'
  WHERE section = 'verbal' AND prompt = 'Drought is to water as famine is to:' AND options = '["Hunger", "Food", "Poverty", "Crops"]'::JSONB;

UPDATE questions SET explanation = 'A pedal is what you push to move a bicycle forward, so an oar is what you pull to move a boat. Paddle is a different tool for the same job rather than the vehicle being moved. Water is where boating happens, and a sail uses wind instead of muscle.'
  WHERE section = 'verbal' AND prompt = 'Pedal is to bicycle as oar is to:' AND options = '["Water", "Boat", "Paddle", "Sail"]'::JSONB;

UPDATE questions SET explanation = 'A petal is a part that grows on a flower, so a feather is a part that grows on a bird. Wing is the close miss: feathers do cover wings, but the whole animal matches the whole flower. Pillow and nest are places feathers end up after leaving the bird.'
  WHERE section = 'verbal' AND prompt = 'Petal is to flower as feather is to:' AND options = '["Pillow", "Nest", "Wing", "Bird"]'::JSONB;

UPDATE questions SET explanation = 'A general is the officer who commands an army, so a captain is the officer who commands a ship. Soldier names someone a general leads rather than the thing being led. Rank is the general idea both titles belong to, and battle is the event where an army fights.'
  WHERE section = 'verbal' AND prompt = 'General is to army as captain is to:' AND options = '["Soldier", "Ship", "Rank", "Battle"]'::JSONB;

UPDATE questions SET explanation = 'A rehearsal is the preparation you do before a performance, so practice is the preparation you do before a game. Training is the tempting one, but training is another word for the preparing itself, not the real event it points toward. Sport is the category and skill is the ability.'
  WHERE section = 'verbal' AND prompt = 'Rehearsal is to performance as practice is to:' AND options = '["Sport", "Game", "Training", "Skill"]'::JSONB;

UPDATE questions SET explanation = 'A degree is the unit used to measure temperature, so a pound is the unit used to measure weight. Money is the trap, since the British pound is currency, but this pairing runs from a unit to what it measures. Force and volume are measured in entirely different units.'
  WHERE section = 'verbal' AND prompt = 'Degree is to temperature as pound is to:' AND options = '["Money", "Weight", "Force", "Volume"]'::JSONB;

UPDATE questions SET explanation = 'An architect draws a blueprint to plan a building before it is built, so a sculptor draws a sketch to plan a piece before carving it. Clay is a material to be shaped rather than a plan, and chisel is the tool that shapes it. Museum is where finished work is displayed.'
  WHERE section = 'verbal' AND prompt = 'Architect is to blueprint as sculptor is to:' AND options = '["Clay", "Museum", "Sketch", "Chisel"]'::JSONB;

UPDATE questions SET explanation = 'The first pair are opposites: reckless means taking risks and cautious means avoiding them. So rude needs its opposite, which is polite. Mean is the trap because it sits close to rude in meaning rather than reversing it. Loud and selfish are other unpleasant traits, not opposites of rudeness.'
  WHERE section = 'verbal' AND prompt = 'Reckless is to cautious as rude is to:' AND options = '["Mean", "Polite", "Loud", "Selfish"]'::JSONB;

UPDATE questions SET explanation = 'Dull and sharp are opposites, so dim needs its opposite, which is bright. Dark is the tempting miss: dark points the same direction as dim rather than reversing it. Night is a time when light is low, and blind describes not being able to see at all.'
  WHERE section = 'verbal' AND prompt = 'Dull is to sharp as dim is to:' AND options = '["Dark", "Night", "Bright", "Blind"]'::JSONB;

UPDATE questions SET explanation = 'A microscope is the signature instrument of a biologist, so a telescope is the signature instrument of an astronomer. Scientist is too broad: it names the whole group instead of the specialist who uses telescopes. Stars are what a telescope points at, and lens is one part of the instrument.'
  WHERE section = 'verbal' AND prompt = 'Microscope is to biologist as telescope is to:' AND options = '["Stars", "Astronomer", "Lens", "Scientist"]'::JSONB;

UPDATE questions SET explanation = 'A trunk is the body feature that makes an elephant instantly recognizable, so a shell is the body feature that marks a turtle. Frog is the near-miss animal, but frogs have smooth skin and no shell. Ocean is where shells wash up, and pearl forms inside a different creature.'
  WHERE section = 'verbal' AND prompt = 'Trunk is to elephant as shell is to:' AND options = '["Ocean", "Pearl", "Turtle", "Frog"]'::JSONB;

UPDATE questions SET explanation = 'An epidemic is disease spreading suddenly in huge amounts, so an avalanche is snow rushing down in huge amounts. Disaster is the trap: it names what an avalanche is rather than the material that moves. Mountain is where it happens, and storm is the weather that may drop the snow first.'
  WHERE section = 'verbal' AND prompt = 'Epidemic is to disease as avalanche is to:' AND options = '["Mountain", "Snow", "Storm", "Disaster"]'::JSONB;

UPDATE questions SET explanation = 'A prologue is the part that comes before the main action of a play, so an introduction is the part that comes before the main text of a book. Chapter is the tempting miss, but a chapter is a piece of the main text, not what comes ahead of it. Index sits at the end.'
  WHERE section = 'verbal' AND prompt = 'Prologue is to play as introduction is to:' AND options = '["Chapter", "Book", "Sentence", "Index"]'::JSONB;

UPDATE questions SET explanation = 'Stingy and generous are opposites, so vague needs its opposite: specific, meaning exact and detailed. Confusing points the same way as vague rather than reversing it, which makes it the common wrong pick. Uncertain describes not knowing something, and hidden describes being out of sight.'
  WHERE section = 'verbal' AND prompt = 'Stingy is to generous as vague is to:' AND options = '["Uncertain", "Hidden", "Specific", "Confusing"]'::JSONB;

UPDATE questions SET explanation = 'A carpenter shapes wood, the raw material worked on, so a blacksmith shapes metal. Anvil is the surface a blacksmith hammers against, a tool rather than a material. Horseshoe is one product that comes out of the shop, and fire is what heats the metal before shaping.'
  WHERE section = 'verbal' AND prompt = 'Carpenter is to wood as blacksmith is to:' AND options = '["Anvil", "Fire", "Metal", "Horseshoe"]'::JSONB;

UPDATE questions SET explanation = 'An island is a patch of land surrounded by ocean, so an oasis is a patch of green surrounded by desert. Water is the tempting one because an oasis has water at its center, but the pattern needs what surrounds it. Sand is what deserts are made of, and palm is a plant growing there.'
  WHERE section = 'verbal' AND prompt = 'Island is to ocean as oasis is to:' AND options = '["Water", "Desert", "Palm", "Sand"]'::JSONB;

UPDATE questions SET explanation = 'This pair works by surprise: lions stand for bravery, so a cowardly lion is the opposite of what you expect. Ballerinas stand for grace, so a clumsy ballerina carries the same twist. Elephant is a poor fit, because heavy animals are not famous for grace, so calling one clumsy surprises nobody.'
  WHERE section = 'verbal' AND prompt = 'Cowardly is to lion as clumsy is to:' AND options = '["Bear", "Ballerina", "Turtle", "Elephant"]'::JSONB;

UPDATE questions SET explanation = 'Volume tells you how much of a quality a sound has, namely loudness, so speed tells you how much of a quality motion has, namely quickness. Distance is one number used to calculate speed rather than the thing speed describes. Time is the other number, and force is what causes motion.'
  WHERE section = 'verbal' AND prompt = 'Volume is to sound as speed is to:' AND options = '["Time", "Motion", "Distance", "Force"]'::JSONB;

UPDATE questions SET explanation = 'All mammals are warm-blooded, and whales are mammals, so whales are warm-blooded, and the conclusion is true. Uncertain tempts students who picture whales living in cold water and swimming like fish, but the premises settle the question before any outside knowledge comes into it.'
  WHERE section = 'verbal' AND prompt = 'All mammals are warm-blooded. Whales are mammals. Whales are warm-blooded — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'Inside these premises, no vegetable is sweet and a carrot is a vegetable, so a carrot is not sweet and the conclusion follows. Depends is the trap, because you know from eating carrots that they taste sweet, but syllogisms are judged only by the premises given, never by real life.'
  WHERE section = 'verbal' AND prompt = 'No vegetables are sweet. Carrots are vegetables. Carrots are not sweet — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Depends"]'::JSONB;

UPDATE questions SET explanation = 'Take the students who are athletes. Every athlete exercises daily, so those students exercise daily, which makes the conclusion true. Uncertain is the trap: the word some feels shaky, but some guarantees at least one student is an athlete, and one is enough for a conclusion that also says some.'
  WHERE section = 'verbal' AND prompt = 'All athletes exercise daily. Some students are athletes. Some students exercise daily — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Impossible"]'::JSONB;

UPDATE questions SET explanation = 'The premises say moons orbit planets and planets orbit a star, but they never say a moon orbits the star itself, so the conclusion is uncertain. True is the trap, because in real astronomy a moon travels around the sun along with its planet. Judge only what the premises actually state.'
  WHERE section = 'verbal' AND prompt = 'All planets orbit a star. Some moons orbit planets. Some moons orbit stars — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Impossible"]'::JSONB;

UPDATE questions SET explanation = 'No honest person lies, and Jordan is honest, so Jordan does not lie. That follows exactly, which makes the conclusion true. Maybe tempts students thinking about real people slipping up, but the premises define honest people as never lying, and the question asks what follows from them.'
  WHERE section = 'verbal' AND prompt = 'No honest person lies. Jordan is honest. Jordan does not lie — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Maybe"]'::JSONB;

UPDATE questions SET explanation = 'Look at the painters who are left-handed. All left-handed people write with their left hand, so those painters do too, and the conclusion is true. Uncertain is the trap, since the first premise says only some painters, but the conclusion also says only some, so the two match.'
  WHERE section = 'verbal' AND prompt = 'Some painters are left-handed. All left-handed people write with their left hand. Some painters write with their left hand — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'Every chef can cook, and some chefs cannot bake. Those particular chefs are people who can cook but cannot bake, so the conclusion is true. Uncertain tempts you because the premises never discuss anyone outside the kitchen, but the conclusion only claims some people, and those chefs supply them.'
  WHERE section = 'verbal' AND prompt = 'All chefs can cook. Some chefs cannot bake. Some people who can cook cannot bake — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Impossible"]'::JSONB;

UPDATE questions SET explanation = 'All rivers flow to the sea, and the Amazon is a river, so the Amazon flows to the sea, and the conclusion is true. Uncertain is the trap for students who start thinking about rivers that end in lakes, but the premise says all rivers, and premises are treated as given.'
  WHERE section = 'verbal' AND prompt = 'All rivers flow to the sea. The Amazon is a river. The Amazon flows to the sea — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'Consider the doctors who are scientists. Every scientist publishes research, so those doctors publish research, and the conclusion is true. Uncertain is the trap, because the word some sounds unreliable, but some means at least one exists, and that one doctor makes the conclusion about some doctors hold.'
  WHERE section = 'verbal' AND prompt = 'Some doctors are scientists. All scientists publish research. Some doctors publish research — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Impossible"]'::JSONB;

UPDATE questions SET explanation = 'No nocturnal animal is active during the day, and owls are nocturnal, so owls are not active during the day. That follows, which makes the conclusion true. Depends is the trap for anyone remembering an owl seen in daylight, but these questions are decided only by the premises on the page.'
  WHERE section = 'verbal' AND prompt = 'No nocturnal animal is active during the day. Owls are nocturnal. Owls are not active during the day — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Depends"]'::JSONB;

UPDATE questions SET explanation = 'Take the tablets that are computers. Every computer needs electricity, so those tablets need electricity, which makes the conclusion true. Uncertain tempts you because the second premise says only some tablets, but the conclusion says only some as well, so nothing is claimed beyond what the premises support.'
  WHERE section = 'verbal' AND prompt = 'All computers need electricity. Some tablets are computers. Some tablets need electricity — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'A sonnet, a villanelle, and a haiku each follow strict rules about line count, rhythm, or syllables, so the poet has a fixed form to fill. Free verse follows no set pattern at all, which is what sets it apart. Villanelle may look unfamiliar, but it is among the most tightly ruled forms.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others?' AND options = '["Sonnet", "Villanelle", "Haiku", "Free verse"]'::JSONB;

UPDATE questions SET explanation = 'A memoir, a biography, and an autobiography all tell the story of a real person and count as nonfiction. A novel is invented, which makes it the odd one. Autobiography can feel different because the subject writes it, but who holds the pen does not change that the events are true.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others?' AND options = '["Memoir", "Biography", "Autobiography", "Novel"]'::JSONB;

UPDATE questions SET explanation = 'A simile, a metaphor, and alliteration are all figures of speech, tools that change how language sounds or what it suggests. A paragraph is a structural block of writing, so it does not fit. Alliteration may seem different since it works on sound, but it is still a writing device.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others?' AND options = '["Simile", "Metaphor", "Alliteration", "Paragraph"]'::JSONB;

UPDATE questions SET explanation = 'Envy, greed, and pride all name failings, traits traditionally listed among the deadly sins. Courage is a virtue, something admired rather than warned against, so it stands apart. Pride is the tricky one, since we praise being proud of hard work, but as a listed sin it means excessive self-regard.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others?' AND options = '["Envy", "Greed", "Pride", "Courage"]'::JSONB;

UPDATE questions SET explanation = 'Mercury, Venus, and Mars are planets, bodies that orbit the sun directly. The Moon orbits Earth instead, which makes it a natural satellite and the odd one here. Mercury can seem different because it is smallest and closest to the sun, but size and distance do not change what it orbits.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others?' AND options = '["Mercury", "Venus", "Moon", "Mars"]'::JSONB;

UPDATE questions SET explanation = 'A soliloquy, a monologue, and an oration all feature one person speaking at length. Dialogue needs at least two speakers trading lines, so it is the outsider. Soliloquy may look like the unusual word, but it means a character speaking thoughts aloud alone, which fits the single-speaker group.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others?' AND options = '["Soliloquy", "Monologue", "Dialogue", "Oration"]'::JSONB;

UPDATE questions SET explanation = 'Granite, marble, and limestone are all natural rock, formed in the ground over long stretches of time. Bronze is a metal alloy people make by mixing copper and tin, so it is the odd one. Marble can feel special because sculptors prize it, but it is still stone cut from a quarry.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others?' AND options = '["Granite", "Marble", "Limestone", "Bronze"]'::JSONB;

UPDATE questions SET explanation = 'A theorem, a hypothesis, and an axiom are all statements used in math, logic, or science: something proved, something proposed for testing, something accepted as given. A stanza is a group of lines in a poem, so it belongs to poetry rather than to reasoning. Hypothesis can feel like the odd one because it is unproven, but it still lives in science.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others?' AND options = '["Theorem", "Hypothesis", "Axiom", "Stanza"]'::JSONB;

UPDATE questions SET explanation = 'Infer, deduce, and conclude all mean reaching a judgment that evidence supports. Speculate means guessing without enough evidence behind it, so it breaks the shared pattern. Infer can look like the odd one because it sounds less certain than deduce, but an inference is still built on evidence you actually have.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others?' AND options = '["Infer", "Deduce", "Speculate", "Conclude"]'::JSONB;

UPDATE questions SET explanation = 'A senate, a parliament, and a congress are all bodies that make laws. The judiciary is the system of courts, which interprets and applies laws instead of writing them, so it sits in a different branch of government. Parliament can seem odd because it is the British term, but its job is the same lawmaking work.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others?' AND options = '["Senate", "Parliament", "Congress", "Judiciary"]'::JSONB;

UPDATE questions SET explanation = 'Truculent describes someone quick to pick a fight, aggressive and bad-tempered, like a player snarling at the referee. Timid is the tempting miss, since truculent sounds a little like timorous, but a timid person avoids conflict rather than seeking it. Reliable and wandering describe trustworthiness and movement, neither of which involves a fighting mood.'
  WHERE section = 'verbal' AND prompt = 'TRUCULENT most nearly means:' AND options = '["Timid", "Eager to argue or fight", "Reliable", "Wandering"]'::JSONB;

UPDATE questions SET explanation = 'Obsequious means fawning: bowing, flattering, and agreeing with someone far past the point of sincerity, like a waiter who praises every choice you make. Stubborn is nearly the reverse, because an obsequious person gives in instead of digging in. Curious and loud name other traits that have nothing to do with flattery.'
  WHERE section = 'verbal' AND prompt = 'OBSEQUIOUS most nearly means:' AND options = '["Stubborn", "Curious", "Excessively eager to please", "Loud"]'::JSONB;

UPDATE questions SET explanation = 'Inveterate describes a habit so long established that it is unlikely ever to change, as in an inveterate gambler. Stubborn is the trap: it is close, but it describes a person''s will, while inveterate describes how fixed the habit itself has become. Occasional points the opposite way, and curable suggests the habit could easily end.'
  WHERE section = 'verbal' AND prompt = 'INVETERATE most nearly means:' AND options = '["Occasional", "Deeply habitual", "Stubborn", "Curable"]'::JSONB;

UPDATE questions SET explanation = 'Pedantic describes someone fussing over small rules and details in a way that wears everyone out, like a person who corrects your grammar in the middle of your story. Wise is the tempting choice, because pedantic people often sound learned, but real wisdom knows which details matter. Childlike and patient name unrelated qualities.'
  WHERE section = 'verbal' AND prompt = 'PEDANTIC most nearly means:' AND options = '["Wise", "Overly focused on minor rules or details", "Childlike", "Patient"]'::JSONB;

UPDATE questions SET explanation = 'Laconic means saying a great deal in very few words; a laconic answer might be one word long. Wordy is the exact reverse and the most common slip if you are moving fast. Lazy is tempting too, since quiet people can seem uninterested, but laconic describes a person''s style, not the effort they put in.'
  WHERE section = 'verbal' AND prompt = 'LACONIC most nearly means:' AND options = '["Wordy", "Logical", "Using very few words", "Lazy"]'::JSONB;

UPDATE questions SET explanation = 'Insipid means bland, with no flavor, interest, or spark, and it works for soup and for a boring movie alike. Spicy is the reverse and an easy grab, since both words feel like taste words. Offensive is wrong because insipid food does not bother you at all; it only fails to interest you.'
  WHERE section = 'verbal' AND prompt = 'INSIPID most nearly means:' AND options = '["Spicy", "Intelligent", "Lacking flavor or interest", "Offensive"]'::JSONB;

UPDATE questions SET explanation = 'Perfidious describes someone who betrays trust; the root fid means faith, as in fidelity. A perfidious ally secretly helps your enemy. Loyal is the exact opposite and the trap for anyone who spots that faith root without noticing the prefix reverses it. Dangerous comes close in feeling but leaves out the betrayal that defines the word.'
  WHERE section = 'verbal' AND prompt = 'PERFIDIOUS most nearly means:' AND options = '["Loyal", "Treacherous", "Fearless", "Dangerous"]'::JSONB;

UPDATE questions SET explanation = 'Equivocal describes a statement that can be read more than one way, often on purpose, the way an equivocal answer dodges commitment. The word equal hides inside it, which makes fair and balanced tempting, but equivocal is about doubtful meaning rather than fairness. Similar is wrong too, since having two meanings is the point.'
  WHERE section = 'verbal' AND prompt = 'EQUIVOCAL most nearly means:' AND options = '["Fair", "Ambiguous", "Similar", "Balanced"]'::JSONB;

UPDATE questions SET explanation = 'Magnanimous means big-hearted, especially about forgiving people who wronged you; its roots mean great soul, and a magnanimous winner praises the loser. Powerful is the trap, because the magn- part suggests greatness in size or strength, but the greatness here is in generosity. Proud and famous describe status instead of kindness.'
  WHERE section = 'verbal' AND prompt = 'MAGNANIMOUS most nearly means:' AND options = '["Powerful", "Generous and forgiving", "Proud", "Famous"]'::JSONB;

UPDATE questions SET explanation = 'Mendacious means untruthful, as in a mendacious excuse. Accurate is the opposite and worth naming, because both words turn up around reports and statements, so a fast reader can grab it. Threatening and humble describe other qualities; a mendacious person can be perfectly pleasant and still not be telling you the truth.'
  WHERE section = 'verbal' AND prompt = 'MENDACIOUS most nearly means:' AND options = '["Accurate", "Threatening", "Dishonest", "Humble"]'::JSONB;

UPDATE questions SET explanation = 'Ephemeral means lasting only a very short time, like a mayfly or a trend that dies out in a week. Eternal is its direct opposite and the most common miss. Delicate is tempting because short-lived things often feel fragile, but ephemeral measures how long something lasts, not how easily it breaks.'
  WHERE section = 'verbal' AND prompt = 'EPHEMERAL most nearly means:' AND options = '["Eternal", "Delicate", "Lasting only a short time", "Mysterious"]'::JSONB;

UPDATE questions SET explanation = 'Taciturn describes a person who is quiet by nature and rarely speaks up. Secretive is the trap: a taciturn person does not talk much, while a secretive person is actively hiding something. Rude is wrong because saying little is not the same as being unkind, and logical describes how someone thinks rather than how much they talk.'
  WHERE section = 'verbal' AND prompt = 'TACITURN most nearly means:' AND options = '["Rude", "Silent by nature", "Logical", "Secretive"]'::JSONB;

UPDATE questions SET explanation = 'Garrulous means talking on and on, usually about small unimportant things. Boastful is the tempting one, because both involve a lot of talking, but boasting means bragging about yourself while garrulous means endless chatter on any subject. Cheerful and aggressive describe a person''s mood, not how much they say.'
  WHERE section = 'verbal' AND prompt = 'GARRULOUS most nearly means:' AND options = '["Cheerful", "Excessively talkative", "Boastful", "Aggressive"]'::JSONB;

UPDATE questions SET explanation = 'Recondite describes knowledge so specialized that hardly anyone knows it, like a recondite corner of medieval history. Hidden is the near miss: recondite ideas are not deliberately concealed, only deep and unfamiliar. Complex is close as well, but a subject can be complicated and still widely known, so it misses the little-known part.'
  WHERE section = 'verbal' AND prompt = 'RECONDITE most nearly means:' AND options = '["Recovered", "Hidden", "Obscure and little known", "Complex"]'::JSONB;

UPDATE questions SET explanation = 'Intrepid means fearless in the face of danger, the word you want for an explorer who keeps going. Reckless is the strongest trap: both push into danger, but reckless adds carelessness about the risk, while intrepid is bravery without that insult. Cautious is the reverse, and stubborn is about refusing to change course.'
  WHERE section = 'verbal' AND prompt = 'INTREPID most nearly means:' AND options = '["Reckless", "Fearless", "Cautious", "Stubborn"]'::JSONB;

UPDATE questions SET explanation = 'Censure means to express strong, often official disapproval. Its opposite is praise, which expresses strong approval. Criticize and condemn are synonyms of censure rather than reversals, and they are the easy slip when you are reading quickly. Punish goes a step past censure: censure is words, while punishment is action taken afterward.'
  WHERE section = 'verbal' AND prompt = 'CENSURE is the opposite of:' AND options = '["Criticize", "Punish", "Praise", "Condemn"]'::JSONB;

UPDATE questions SET explanation = 'Venerate means to regard someone with deep respect, close to reverence. Despise, looking on someone with contempt, reverses it. Worship and honor are synonyms of venerate, and worship in particular is a fast-reading trap because it sounds even stronger. Fear is an intense feeling toward someone, but it is not the reverse of respect.'
  WHERE section = 'verbal' AND prompt = 'VENERATE is the opposite of:' AND options = '["Worship", "Despise", "Honor", "Fear"]'::JSONB;

UPDATE questions SET explanation = 'Verbose means using far more words than the job needs. The opposite is terse: short, clipped, and to the point. Wordy is a synonym of verbose, so it is the trap for anyone matching the feeling of a word instead of its direction. Eloquent means speaking well, which can happen at any length.'
  WHERE section = 'verbal' AND prompt = 'VERBOSE is the opposite of:' AND options = '["Wordy", "Eloquent", "Terse", "Loud"]'::JSONB;

UPDATE questions SET explanation = 'Tractable means easy to manage or lead, the way a tractable horse follows direction. Obstinate, meaning stubbornly uncooperative, reverses that. Manageable is a synonym of tractable and the likeliest slip in this set. Gentle usually travels along with tractable rather than against it, and simple describes difficulty rather than willingness.'
  WHERE section = 'verbal' AND prompt = 'TRACTABLE is the opposite of:' AND options = '["Manageable", "Gentle", "Obstinate", "Simple"]'::JSONB;

UPDATE questions SET explanation = 'Credulous describes someone who believes claims far too easily. Skeptical, unwilling to believe without proof, is the reversal. Naive and trusting are close synonyms of credulous and are the traps here. Ignorant means lacking knowledge, which is a different problem, since you can know a great deal and still swallow a bad claim.'
  WHERE section = 'verbal' AND prompt = 'CREDULOUS is the opposite of:' AND options = '["Naive", "Skeptical", "Trusting", "Ignorant"]'::JSONB;

UPDATE questions SET explanation = 'Penury means extreme poverty, having almost nothing at all. Wealth, an abundance of money, reverses it. Poverty repeats the meaning of penury instead of opposing it, and it is the fastest trap in this set. Misery often accompanies penury, and debt is a related money trouble rather than the reverse of being poor.'
  WHERE section = 'verbal' AND prompt = 'PENURY is the opposite of:' AND options = '["Misery", "Poverty", "Wealth", "Debt"]'::JSONB;

UPDATE questions SET explanation = 'Candor means speaking frankly and honestly, even when that is uncomfortable. Deceit, deliberately misleading people, reverses it. Honesty and openness are synonyms of candor and become traps if you match the warm feeling of the word instead of its direction. Kindness is a fine quality but not the reverse of truth-telling.'
  WHERE section = 'verbal' AND prompt = 'CANDOR is the opposite of:' AND options = '["Honesty", "Deceit", "Kindness", "Openness"]'::JSONB;

UPDATE questions SET explanation = 'Serene means calm and untroubled. Agitated, meaning stirred up and upset, is the reversal. Peaceful and quiet are near-synonyms of serene, and peaceful especially is easy to grab in a hurry because it feels like the heart of the word. Content means satisfied, which usually travels with serenity rather than against it.'
  WHERE section = 'verbal' AND prompt = 'SERENE is the opposite of:' AND options = '["Peaceful", "Quiet", "Agitated", "Content"]'::JSONB;

UPDATE questions SET explanation = 'Opulent means lavish and showy with wealth, like an opulent ballroom. Austere, meaning plain and stripped of comfort, reverses it. Luxurious and rich are synonyms of opulent, and luxurious is the likeliest miss. Expensive is about price, and something can cost a fortune while still looking severe and bare.'
  WHERE section = 'verbal' AND prompt = 'OPULENT is the opposite of:' AND options = '["Luxurious", "Rich", "Austere", "Expensive"]'::JSONB;

UPDATE questions SET explanation = 'Alacrity means cheerful, quick willingness, as when someone agrees with alacrity. Reluctance, meaning unwillingness, is the opposite. Eagerness is a synonym of alacrity and the main trap. Speed and energy capture the quickness half of alacrity but not the willing attitude behind it, so neither one truly reverses the word.'
  WHERE section = 'verbal' AND prompt = 'ALACRITY is the opposite of:' AND options = '["Eagerness", "Speed", "Reluctance", "Energy"]'::JSONB;

UPDATE questions SET explanation = 'A herald''s job is to announce, so this pair links a role to the action that defines it. An arbiter is brought in to judge a dispute, which is that role''s defining action. Negotiate is the runner-up, but a negotiator works out a deal between the sides while an arbiter decides for them. Punishing belongs to a court.'
  WHERE section = 'verbal' AND prompt = 'Herald is to announce as arbiter is to:' AND options = '["Judge", "Argue", "Negotiate", "Punish"]'::JSONB;

UPDATE questions SET explanation = 'Censure and praise are opposites, disapproval against approval, so the second pair needs the opposite of condemn. To condemn is to declare someone guilty; to acquit is to declare them not guilty. Blame is a synonym of condemn rather than its reverse, and it is the easy grab. Punish follows a condemnation instead of undoing it.'
  WHERE section = 'verbal' AND prompt = 'Censure is to praise as condemn is to:' AND options = '["Blame", "Acquit", "Punish", "Accuse"]'::JSONB;

UPDATE questions SET explanation = 'An iconoclast attacks tradition, so the relationship is an attacker paired with what they attack. A rebel attacks established order. Revolution is tempting because rebels make revolutions, but that is what a rebel creates, not what a rebel fights. Freedom and change are also things a rebel wants rather than opposes.'
  WHERE section = 'verbal' AND prompt = 'Iconoclast is to tradition as rebel is to:' AND options = '["Revolution", "Order", "Freedom", "Change"]'::JSONB;

UPDATE questions SET explanation = 'A dilettante dabbles and lacks real expertise, so each pair names a person and the quality they do not have. A novice lacks mastery. Beginner is the trap: it is a synonym for novice, not something a novice is missing. Enthusiasm and learning are things a novice usually has plenty of already.'
  WHERE section = 'verbal' AND prompt = 'Dilettante is to expertise as novice is to:' AND options = '["Enthusiasm", "Beginner", "Learning", "Mastery"]'::JSONB;

UPDATE questions SET explanation = 'A pariah is cast out by society, so the pair is an outcast and whatever cast them out. An exile is driven from a homeland. Punishment is tempting since exile is a punishment, but that names the category rather than the place left behind. Crime and prison belong to other parts of a legal story.'
  WHERE section = 'verbal' AND prompt = 'Pariah is to society as exile is to:' AND options = '["Punishment", "Homeland", "Crime", "Prison"]'::JSONB;

UPDATE questions SET explanation = 'Perjury is lying after swearing an oath, so the pair is a crime and the thing it corrupts. Forgery corrupts a document by faking it. Crime is the trap, because forgery certainly is a crime, but that repeats the category instead of naming what gets falsified. Money is only one of many things a forger might fake.'
  WHERE section = 'verbal' AND prompt = 'Perjury is to oath as forgery is to:' AND options = '["Judge", "Crime", "Document", "Money"]'::JSONB;

UPDATE questions SET explanation = 'An ascetic gives up luxury on purpose, so each pair is a person and what that person refuses. A miser refuses generosity, holding tight to every coin. Money is the trap, since misers care about money intensely rather than avoiding it. Poverty describes how a miser may live, not something the miser turns down.'
  WHERE section = 'verbal' AND prompt = 'Ascetic is to luxury as miser is to:' AND options = '["Money", "Generosity", "Poverty", "Saving"]'::JSONB;

UPDATE questions SET explanation = 'A platitude is a tired, unoriginal saying, so the pair is an expression and the quality it lacks. A worn-out cliche lacks freshness in the same way. Speech and language are the settings where such phrases appear, not qualities missing from them. Poetry is one place a writer would work hardest to avoid them.'
  WHERE section = 'verbal' AND prompt = 'Platitude is to originality as cliché is to:' AND options = '["Speech", "Freshness", "Poetry", "Language"]'::JSONB;

UPDATE questions SET explanation = 'An impetuous person acts on impulse and lacks restraint, so each pair names a trait plus the quality missing from it. A profligate person spends wildly and lacks thrift. Extravagance is the trap: that is a synonym for profligate behavior, not something the person is missing. Wealth and spending name resources and actions instead.'
  WHERE section = 'verbal' AND prompt = 'Impetuous is to restraint as profligate is to:' AND options = '["Wealth", "Extravagance", "Thrift", "Spending"]'::JSONB;

UPDATE questions SET explanation = 'An elegy is a poem written to express mourning, so the pair is a poem and the feeling it carries. An ode praises and celebrates its subject. Grief is the trap because it repeats the elegy''s feeling rather than supplying the ode''s. Rhythm and epic name a feature and a form, not a feeling.'
  WHERE section = 'verbal' AND prompt = 'Elegy is to mourning as ode is to:' AND options = '["Grief", "Celebration", "Rhythm", "Epic"]'::JSONB;

UPDATE questions SET explanation = 'A sophist wins arguments through clever deception, so the pair is a person and what defines their trickery. A charlatan pretends to skills he does not have, which is fraud. Wisdom is what a sophist only imitates, not what defines him. Magic and performance describe a stage act rather than a deliberate deception.'
  WHERE section = 'verbal' AND prompt = 'Sophist is to deception as charlatan is to:' AND options = '["Magic", "Fraud", "Wisdom", "Performance"]'::JSONB;

UPDATE questions SET explanation = 'To be solvent is to be free of debt, so the pair links a condition to the trouble it keeps away. Immunity keeps disease away. Vaccine is the trap: a vaccine is how you gain immunity, not what immunity protects you from. Health is the result of immunity, and medicine treats illness after it arrives.'
  WHERE section = 'verbal' AND prompt = 'Solvent is to debt as immunity is to:' AND options = '["Medicine", "Vaccine", "Disease", "Health"]'::JSONB;

UPDATE questions SET explanation = 'The premises state flatly that no selfish act is virtuous, and Alex''s act is given as selfish. That puts it in the group that cannot be virtuous, so the conclusion is not merely unproven, it is ruled out. Uncertain is the trap, but nothing is missing here: the rule covers every selfish act, including Alex''s.'
  WHERE section = 'verbal' AND prompt = 'All virtuous acts are selfless. No selfish act is virtuous. Alex''s act was selfish. Alex''s act was virtuous — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Impossible"]'::JSONB;

UPDATE questions SET explanation = 'Both groups question assumptions, but sharing a habit does not place anyone inside the other group. The premises say all philosophers question assumptions, not that everyone who questions assumptions is a philosopher. Those scientists could all be non-philosophers, which is why True is the trap. False is wrong too, since some of them might be philosophers.'
  WHERE section = 'verbal' AND prompt = 'All philosophers question assumptions. Some scientists question assumptions. Some scientists are philosophers — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'No Medal of Honor recipient is a coward, and Captain Rivera received the medal, which places Rivera outside the group of cowards. The conclusion is therefore ruled out rather than merely unsupported. Uncertain tempts students who feel nothing personal was said about Rivera, but the no-cowards rule applies to every recipient without exception.'
  WHERE section = 'verbal' AND prompt = 'No coward has ever been awarded the Medal of Honor. Captain Rivera was awarded the Medal of Honor. Captain Rivera is a coward — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'Every secondary color can be made by mixing primary colors, and green is named as a secondary color, so green inherits that property. The chain runs all the way through, which is why Uncertain is wrong here. Nothing in the premises hints at an exception, and the conclusion repeats exactly what the opening statement promises.'
  WHERE section = 'verbal' AND prompt = 'All secondary colors are formed by mixing primary colors. Green is a secondary color. Green can be formed from primary colors — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'All haiku sit inside the group of poems, but only some poems rhyme, and the premises never say which ones. The rhyming poems could be entirely sonnets and songs. True is the trap because the pieces look as though they connect. False is wrong as well, since a rhyming haiku is not ruled out.'
  WHERE section = 'verbal' AND prompt = 'Some poems rhyme. All haiku are poems. Some haiku rhyme — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'No democracy allows one-person rule, and Country X allows it, so Country X falls outside the group of democracies. That makes the conclusion false rather than uncertain. Uncertain is the tempting answer whenever premises feel thin, but this pair is enough: the rule admits no exceptions, and Country X breaks it.'
  WHERE section = 'verbal' AND prompt = 'No democracy allows one-person rule. Country X allows one-person rule. Country X is a democracy — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'A soliloquy, an apostrophe, and an aside are all moments when a speaker steps outside ordinary conversation to address the audience, himself, or someone absent. An allegory is different in kind: an entire story whose characters and events stand for something else. Apostrophe is the tempting pick because it is the least familiar term, but it still names a way of speaking.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others?' AND options = '["Soliloquy", "Apostrophe", "Aside", "Allegory"]'::JSONB;

UPDATE questions SET explanation = 'Stoic, Epicurean, and Utilitarian all name views about how a person should live and what makes an action good. Empiricist names a view about where knowledge comes from, namely experience and observation, which is a question about knowing rather than about living. Utilitarian may feel like the odd one as the newest term, but it is still an ethical view.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others?' AND options = '["Stoic", "Epicurean", "Utilitarian", "Empiricist"]'::JSONB;

UPDATE questions SET explanation = 'Anachronism, foreshadowing, and flashback all involve time in a story: something out of its period, a hint of what is coming, a jump backward. Euphony is about sound, the pleasing flow of words read aloud. Anachronism is the tempting pick because it often shows up as an author''s mistake, but it still concerns time.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others?' AND options = '["Anachronism", "Foreshadowing", "Flashback", "Euphony"]'::JSONB;

UPDATE questions SET explanation = 'Hubris, hamartia, and catharsis come from Aristotle''s account of what makes a tragedy work: overreaching pride, the fatal error, and the emotional release an audience feels. A soliloquy is a stagecraft technique, a speech delivered alone, and any kind of play can use one. Catharsis is tempting since it names an audience effect, but Aristotle built it into his theory.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others?' AND options = '["Hubris", "Hamartia", "Catharsis", "Soliloquy"]'::JSONB;

UPDATE questions SET explanation = 'To mend something is to fix what is torn, cracked, or broken, whether that is a sock or a friendship, so repair matches it exactly. Break is the trap, because it names the damage that mending undoes and can look right if you read fast. Lose and hide do nothing about the damage at all.'
  WHERE section = 'verbal' AND prompt = 'MEND most nearly means:' AND options = '["Repair", "Break", "Lose", "Hide"]'::JSONB;

UPDATE questions SET explanation = 'A vacant seat, room, or lot has nobody and nothing in it, which is what empty means. Crowded is the reverse and the common miss when you match topic instead of meaning, since both words describe how full a space is. Noisy and heavy describe sound and weight, which vacancy tells you nothing about.'
  WHERE section = 'verbal' AND prompt = 'VACANT most nearly means:' AND options = '["Crowded", "Empty", "Noisy", "Heavy"]'::JSONB;

UPDATE questions SET explanation = 'A rival is someone going after the same prize, title, or position you want, which is exactly what a competitor is. Helper points the other way, since a rival works against you rather than alongside you. A teacher or a stranger could be anyone at all; neither is defined by wanting the same thing you want.'
  WHERE section = 'verbal' AND prompt = 'RIVAL most nearly means:' AND options = '["Helper", "Teacher", "Competitor", "Stranger"]'::JSONB;

UPDATE questions SET explanation = 'To shout is to push your voice out loud and hard, and yell means the same thing. Whisper sits at the opposite end of the same scale and is the fastest trap here. Sing uses the voice too, but it is about melody rather than volume, and listen is receiving sound instead of producing it.'
  WHERE section = 'verbal' AND prompt = 'SHOUT most nearly means:' AND options = '["Whisper", "Sing", "Listen", "Yell"]'::JSONB;

UPDATE questions SET explanation = 'Wealthy describes a person with a great deal of money or property, which is what rich means. Clever is tempting for anyone thinking about how people get rich, but intelligence and money are separate things. Kind and tall describe character and height, neither of which the word wealthy tells you anything about.'
  WHERE section = 'verbal' AND prompt = 'WEALTHY most nearly means:' AND options = '["Rich", "Kind", "Tall", "Clever"]'::JSONB;

UPDATE questions SET explanation = 'To abandon something is to leave it behind for good and not come back, and to desert it means the same. Rescue is the opposite move, staying with something or pulling it to safety, and it is the trap if you skim. Repair and follow both keep you involved rather than walking away.'
  WHERE section = 'verbal' AND prompt = 'ABANDON most nearly means:' AND options = '["Rescue", "Desert", "Repair", "Follow"]'::JSONB;

UPDATE questions SET explanation = 'Concise means packing the meaning into few words, so brief is the match. Wordy is its opposite and the likeliest slip, since both words come up whenever people talk about length in writing. Unclear is wrong in an important way: concise writing is short and clear, not short and confusing.'
  WHERE section = 'verbal' AND prompt = 'CONCISE most nearly means:' AND options = '["Brief", "Wordy", "Unclear", "Loud"]'::JSONB;

UPDATE questions SET explanation = 'Feeble describes something without strength, whether that is a feeble grip, a feeble light, or a feeble excuse, so weak fits. Sturdy is the opposite and the main trap. Rude describes bad manners and eager describes enthusiasm, neither of which has anything to do with how much strength something has.'
  WHERE section = 'verbal' AND prompt = 'FEEBLE most nearly means:' AND options = '["Sturdy", "Weak", "Eager", "Rude"]'::JSONB;

UPDATE questions SET explanation = 'To provoke someone is to poke at them on purpose until you get a reaction, usually anger, which is what irritate means. Soothe is the reverse and the easiest slip. Ignore is wrong because provoking takes deliberate effort, and forgive describes letting anger go rather than stirring it up.'
  WHERE section = 'verbal' AND prompt = 'PROVOKE most nearly means:' AND options = '["Soothe", "Ignore", "Irritate", "Forgive"]'::JSONB;

UPDATE questions SET explanation = 'The summit is the very top of a mountain, its peak. Base is the tempting miss, because both words belong to mountains, but the base is the bottom. Valley is lower still, the low ground between mountains, and edge names a boundary rather than a height, so neither one reaches the top.'
  WHERE section = 'verbal' AND prompt = 'SUMMIT most nearly means:' AND options = '["Valley", "Base", "Edge", "Peak"]'::JSONB;

UPDATE questions SET explanation = 'To lure is to draw someone toward you by dangling something attractive, which is what tempt means. Repel is the opposite, driving someone away, and it is the trap for readers who match topic rather than direction. Scold and delay involve criticizing or slowing someone down, not enticing them.'
  WHERE section = 'verbal' AND prompt = 'LURE most nearly means:' AND options = '["Repel", "Tempt", "Scold", "Delay"]'::JSONB;

UPDATE questions SET explanation = 'An obstinate person refuses to change course no matter how good your reasons are, and the everyday word for that is stubborn. Careless is the tempting one, since both can look like ignoring advice, but a careless person is not paying attention while an obstinate person has decided. Cheerful and wealthy describe mood and money.'
  WHERE section = 'verbal' AND prompt = 'OBSTINATE most nearly means:' AND options = '["Cheerful", "Stubborn", "Wealthy", "Careless"]'::JSONB;

UPDATE questions SET explanation = 'Prudent means thinking ahead about risk and consequences before acting, so cautious is the closest fit. Reckless is the direct opposite and the fast-reading trap. Generous describes how freely you give and talkative describes how much you say; a prudent person might be either, both, or neither.'
  WHERE section = 'verbal' AND prompt = 'PRUDENT most nearly means:' AND options = '["Reckless", "Cautious", "Generous", "Talkative"]'::JSONB;

UPDATE questions SET explanation = 'Zealous describes throwing yourself into a cause with intense energy and devotion, which enthusiastic captures. Indifferent is the opposite, caring not at all. Exhausted is tempting because zealous effort wears people out, but the word names the drive itself, not its cost. Dishonest describes character and says nothing about how hard someone pushes.'
  WHERE section = 'verbal' AND prompt = 'ZEALOUS most nearly means:' AND options = '["Enthusiastic", "Indifferent", "Dishonest", "Exhausted"]'::JSONB;

UPDATE questions SET explanation = 'Astute describes someone quick to see what is really going on and to use it well, and shrewd names that same sharp practical intelligence. Silent is tempting, since quiet observers often are astute, but staying quiet is not the same as reading a situation well. Clumsy and wealthy describe coordination and money instead.'
  WHERE section = 'verbal' AND prompt = 'ASTUTE most nearly means:' AND options = '["Clumsy", "Shrewd", "Silent", "Wealthy"]'::JSONB;

UPDATE questions SET explanation = 'Shallow means having little depth, so its reversal is deep. Wide and clear are the traps, because all three words get used about water, but width measures distance across and clarity describes what you can see through. Dry names the absence of water rather than a measure of how far down it goes.'
  WHERE section = 'verbal' AND prompt = 'SHALLOW is the opposite of:' AND options = '["Wide", "Dry", "Deep", "Clear"]'::JSONB;

UPDATE questions SET explanation = 'To accept is to take what is offered; to reject is to refuse it, which reverses the action. Receive and welcome are the traps, since both agree with accepting rather than opposing it, and welcome is especially easy to grab in a hurry. Choose is about picking among possibilities, not about taking or refusing one.'
  WHERE section = 'verbal' AND prompt = 'ACCEPT is the opposite of:' AND options = '["Receive", "Reject", "Welcome", "Choose"]'::JSONB;

UPDATE questions SET explanation = 'To gather is to bring things together into one place; to scatter is to fling them apart, which is the reversal. Collect means nearly the same as gather and is the main trap. Stack arranges things you have already gathered, and count tells you how many there are without moving them anywhere.'
  WHERE section = 'verbal' AND prompt = 'GATHER is the opposite of:' AND options = '["Collect", "Stack", "Scatter", "Count"]'::JSONB;

UPDATE questions SET explanation = 'To praise is to say what is good about someone; to criticize is to say what is wrong, so those two pull in opposite directions. Admire, honor, and applaud are all forms of approval that travel with praise instead of against it, and applaud can look like an answer because it names a distinct action.'
  WHERE section = 'verbal' AND prompt = 'PRAISE is the opposite of:' AND options = '["Criticize", "Admire", "Honor", "Applaud"]'::JSONB;

UPDATE questions SET explanation = 'Wealth is having far more than you need; poverty is having far less, so the two reverse each other. Luxury and comfort are the traps, since both describe what wealth buys rather than its absence. Health matters enormously, but it measures your body rather than your money, so it is not the opposite here.'
  WHERE section = 'verbal' AND prompt = 'WEALTH is the opposite of:' AND options = '["Poverty", "Health", "Comfort", "Luxury"]'::JSONB;

UPDATE questions SET explanation = 'Scarce means there is not enough to go around; plentiful means there is more than enough. Rare is the trap, because it means much the same as scarce and so agrees rather than reverses. Costly usually follows from scarcity instead of opposing it, and hidden describes whether something can be found.'
  WHERE section = 'verbal' AND prompt = 'SCARCE is the opposite of:' AND options = '["Rare", "Plentiful", "Hidden", "Costly"]'::JSONB;

UPDATE questions SET explanation = 'To forbid is to rule that something may not happen; to permit is to allow it, which is the clean reversal. Prevent is the near-synonym trap, since preventing also stops something, though by force rather than by rule. Punish comes after a rule is broken, and ignore means taking no position at all.'
  WHERE section = 'verbal' AND prompt = 'FORBID is the opposite of:' AND options = '["Prevent", "Punish", "Permit", "Ignore"]'::JSONB;

UPDATE questions SET explanation = 'To hasten is to make something happen sooner; to delay is to push it later, so the two reverse each other. Hurry means the same as hasten and is the trap for anyone matching the feeling of speed. Arrive and prepare name events on a schedule rather than a change in that schedule''s timing.'
  WHERE section = 'verbal' AND prompt = 'HASTEN is the opposite of:' AND options = '["Hurry", "Arrive", "Prepare", "Delay"]'::JSONB;

UPDATE questions SET explanation = 'Artificial means made by people rather than occurring on its own, so natural is the reversal. Fake is the trap: it agrees with artificial instead of opposing it, and it draws the eye because it feels like a strong word. Cheap and modern describe price and era, and plenty of artificial things are neither.'
  WHERE section = 'verbal' AND prompt = 'ARTIFICIAL is the opposite of:' AND options = '["Natural", "Fake", "Modern", "Cheap"]'::JSONB;

UPDATE questions SET explanation = 'To diminish is to grow smaller or less; to increase is to grow greater, which reverses it. Shrink and weaken are the traps, since both describe getting smaller or less powerful, exactly what diminish already means. Vanish is an extreme case of diminishing rather than its opposite, so it points the same direction.'
  WHERE section = 'verbal' AND prompt = 'DIMINISH is the opposite of:' AND options = '["Shrink", "Increase", "Vanish", "Weaken"]'::JSONB;

UPDATE questions SET explanation = 'Fertile ground produces abundant growth; barren ground produces nothing, so the two reverse each other. Productive is the trap, because it means nearly the same as fertile. Green and damp describe how land looks and feels, and land can be wet and green while still growing very little of use.'
  WHERE section = 'verbal' AND prompt = 'FERTILE is the opposite of:' AND options = '["Productive", "Green", "Damp", "Barren"]'::JSONB;

UPDATE questions SET explanation = 'To abate is to become less severe, the way a storm abates toward morning. Intensify, growing stronger, is the reversal. Subside, lessen, and soften are all synonyms of abate, and subside is especially tempting because it sounds technical, but every one of them points the same direction as the original word.'
  WHERE section = 'verbal' AND prompt = 'ABATE is the opposite of:' AND options = '["Subside", "Intensify", "Lessen", "Soften"]'::JSONB;

UPDATE questions SET explanation = 'Affable describes someone pleasant and easy to talk with. Surly, meaning rude and bad-tempered, reverses it. Friendly is the trap: it is a synonym of affable, so it cannot be the answer no matter how right it feels. Talkative and generous name other traits an affable person may or may not have.'
  WHERE section = 'verbal' AND prompt = 'AFFABLE is the opposite of:' AND options = '["Friendly", "Surly", "Talkative", "Generous"]'::JSONB;

UPDATE questions SET explanation = 'Transient means passing through, lasting only a short time, so permanent, which lasts indefinitely, is the opposite. Fleeting and brief are synonyms of transient and are the easiest slips in this set. Hollow describes something empty inside, which has nothing to do with how long a thing lasts.'
  WHERE section = 'verbal' AND prompt = 'TRANSIENT is the opposite of:' AND options = '["Fleeting", "Brief", "Permanent", "Hollow"]'::JSONB;

UPDATE questions SET explanation = 'A lucid explanation is easy to follow all the way through, so its reversal is a confusing one. Clear is a synonym of lucid and the main trap, especially since lucid sounds like light. Bright describes actual light rather than understanding, and honest is about truthfulness, which a muddled explanation can still have.'
  WHERE section = 'verbal' AND prompt = 'LUCID is the opposite of:' AND options = '["Clear", "Confusing", "Bright", "Honest"]'::JSONB;

UPDATE questions SET explanation = 'Hot and cold are opposites, so the second pair needs the opposite of day, which is night. Morning is the trap: it is a part of a day rather than its reverse. Sun is what makes daytime bright, and a week is a longer stretch that contains days, so neither one reverses anything.'
  WHERE section = 'verbal' AND prompt = 'Hot is to cold as day is to:' AND options = '["Morning", "Night", "Sun", "Week"]'::JSONB;

UPDATE questions SET explanation = 'A pilot operates an airplane, so the pair is an operator and the vehicle they control. A driver operates a car. Road is the tempting choice because cars and roads go together, but a road is where the driving happens, not the thing being driven. An engine is a part of the vehicle, and a ticket is paperwork.'
  WHERE section = 'verbal' AND prompt = 'Pilot is to airplane as driver is to:' AND options = '["Road", "Car", "Ticket", "Engine"]'::JSONB;

UPDATE questions SET explanation = 'A duckling is the young form of a duck, so each pair is a baby animal and its grown-up version. A piglet grows into a pig. Calf is the trap, because it is also a baby animal, but it is the young of a cow, which puts it on the wrong side of the pair. Farm and mud name surroundings.'
  WHERE section = 'verbal' AND prompt = 'Duckling is to duck as piglet is to:' AND options = '["Farm", "Pig", "Mud", "Calf"]'::JSONB;

UPDATE questions SET explanation = 'A knife is the tool you use to cut, so each pair is a tool and the job it is built for. A broom is built for sweeping. Wash is the tempting one, because cleaning links the two ideas, but you wash with water and a cloth rather than a broom. Digging calls for a shovel, and folding needs only hands.'
  WHERE section = 'verbal' AND prompt = 'Knife is to cut as broom is to:' AND options = '["Sweep", "Wash", "Dig", "Fold"]'::JSONB;

UPDATE questions SET explanation = 'A shoe is worn on the foot, so each pair is an item of clothing and the body part it covers. A hat is worn on the head. Hair is the near miss, since a hat does rest on your hair, but the pattern calls for the body part itself, and the match for foot is head. Coat and glove are other garments.'
  WHERE section = 'verbal' AND prompt = 'Shoe is to foot as hat is to:' AND options = '["Hair", "Head", "Coat", "Glove"]'::JSONB;

UPDATE questions SET explanation = 'A clock is the instrument that measures time, so each pair is an instrument and the quantity it measures. A ruler measures length. Weight would call for a scale, speed for a speedometer, and temperature for a thermometer, so each of those names a quantity that needs a completely different tool.'
  WHERE section = 'verbal' AND prompt = 'Clock is to time as ruler is to:' AND options = '["Length", "Weight", "Speed", "Temperature"]'::JSONB;

UPDATE questions SET explanation = 'A whisper and a shout are the same act at very different intensities, so the second pair needs the strong version of a drizzle, which is a downpour. Mist is the trap: it is even lighter than drizzle, so it moves down the scale instead of up. Cloud and puddle name what comes before and after the rain.'
  WHERE section = 'verbal' AND prompt = 'Whisper is to shout as drizzle is to:' AND options = '["Cloud", "Downpour", "Mist", "Puddle"]'::JSONB;

UPDATE questions SET explanation = 'A hive is the particular home a bee lives in, so the pair is an animal and its dwelling. A bear''s dwelling is a den. Forest is the tempting choice, but that is the wide habitat a bear roams rather than the specific place it sleeps. River and tree are features inside that habitat.'
  WHERE section = 'verbal' AND prompt = 'Bee is to hive as bear is to:' AND options = '["Forest", "Den", "River", "Tree"]'::JSONB;

UPDATE questions SET explanation = 'A flock is the collective word for a group of sheep, so the pair is a group name and the animal it applies to. A school is the group word for fish. Students is the trap, because a school full of students is the more familiar meaning, but that names a building. Birds come in flocks, which repeats the first word instead of matching it.'
  WHERE section = 'verbal' AND prompt = 'Flock is to sheep as school is to:' AND options = '["Fish", "Birds", "Wolves", "Students"]'::JSONB;

UPDATE questions SET explanation = 'A conductor leads an orchestra, so the pair is a leader and the group they direct. A coach leads a team. Whistle is the trap, since it is the coach''s signature object, but the pattern calls for the group rather than the equipment. A stadium is the place they play, and a referee serves both sides.'
  WHERE section = 'verbal' AND prompt = 'Conductor is to orchestra as coach is to:' AND options = '["Whistle", "Team", "Stadium", "Referee"]'::JSONB;

UPDATE questions SET explanation = 'An antidote works against a poison, so the pair is a cure and the harm it undoes. A remedy works against an illness. Recovery is the tempting one, but that is what a remedy produces rather than what it fights. A doctor prescribes remedies and a pharmacy sells them, so neither is the harm being undone.'
  WHERE section = 'verbal' AND prompt = 'Antidote is to poison as remedy is to:' AND options = '["Doctor", "Illness", "Pharmacy", "Recovery"]'::JSONB;

UPDATE questions SET explanation = 'A botanist is the scientist who studies plants, so the pair is a specialist and the subject studied. An entomologist studies insects. Fossils are the trap for anyone reaching for the most science-sounding answer, but those belong to a paleontologist. Stars belong to an astronomer and rocks to a geologist.'
  WHERE section = 'verbal' AND prompt = 'Botanist is to plants as entomologist is to:' AND options = '["Fossils", "Insects", "Stars", "Rocks"]'::JSONB;

UPDATE questions SET explanation = 'A cacophony is sound at its most unpleasant, so the pair is a harsh example and the general category it falls into. A stench is an unpleasant odor. Fragrance is the trap, because it is also a smell word, but a fragrance is pleasant, which flips the relationship around. Silence and taste name a lack of sound and a different sense.'
  WHERE section = 'verbal' AND prompt = 'Cacophony is to sound as stench is to:' AND options = '["Odor", "Silence", "Taste", "Fragrance"]'::JSONB;

UPDATE questions SET explanation = 'Anarchy is the complete absence of government, so each pair is a condition and what it is entirely missing. Silence is the complete absence of sound. Music is the tempting choice, but music is only one kind of sound, so silence would be far too broad a match for it. Law and order are things a government provides.'
  WHERE section = 'verbal' AND prompt = 'Anarchy is to government as silence is to:' AND options = '["Sound", "Law", "Music", "Order"]'::JSONB;

UPDATE questions SET explanation = 'Ravenous is hungry taken to the extreme, so each pair is an intense word and its milder version. Exhausted is the extreme form of tired. Rested and awake are the traps, because they relate to tiredness, but they name its opposite rather than a weaker degree of it. Bored describes a different feeling altogether.'
  WHERE section = 'verbal' AND prompt = 'Ravenous is to hungry as exhausted is to:' AND options = '["Rested", "Tired", "Bored", "Awake"]'::JSONB;

UPDATE questions SET explanation = 'The opening statement covers every triangle without exception, and Figure Y is given as a triangle, so the property carries straight over. Uncertain is the trap for students who want more information about Figure Y, but no more is needed here: belonging to the group is enough to guarantee the property.'
  WHERE section = 'verbal' AND prompt = 'All triangles have three sides. Figure Y is a triangle. Figure Y has three sides — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'Every member of the chess club plays chess, and Devon is named as a member, so what holds for all members holds for Devon too. Uncertain is tempting because we know nothing else about Devon, but nothing else is required. The word all leaves no room for a member who does not play.'
  WHERE section = 'verbal' AND prompt = 'All members of the chess club play chess. Devon is a member of the chess club. Devon plays chess — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'The opening statement rules out flying for every penguin, and Pip is a penguin, so the claim that Pip can fly runs straight into that rule. Uncertain is the trap: uncertain is for conclusions the premises leave open, and this one is closed off rather than merely unsupported.'
  WHERE section = 'verbal' AND prompt = 'No penguins can fly. Pip is a penguin. Pip can fly — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'Only some apples are red, so knowing the fruit is an apple does not settle its color; it could be green or yellow. True is the trap for anyone who pictures a red apple by default. False is wrong as well, since the fruit in the bowl might be one of the red ones.'
  WHERE section = 'verbal' AND prompt = 'Some apples are red. The fruit in the bowl is an apple. The fruit in the bowl is red — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'Violins have strings, but so do guitars, cellos, and harps, so stringed instruments in the room need not include a violin at all. The premises run one direction: all violins have strings, not all stringed instruments are violins. True is the trap. False overreaches too, since some of them could be violins.'
  WHERE section = 'verbal' AND prompt = 'All violins have strings. Some instruments in the room have strings. Some instruments in the room are violins — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'The rule points one direction only: every third-grader at Lincoln wears a uniform. It never says that only they do. Nina could be in fifth grade or attend another school entirely and still wear one. True is the trap that comes from reading the rule backward, while False rules out a real possibility.'
  WHERE section = 'verbal' AND prompt = 'All third-graders at Lincoln School wear uniforms. Nina wears a uniform. Nina is a third-grader at Lincoln School — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'Some pets have fur, and no reptile has fur, so those furry pets cannot be reptiles. That gives us at least one pet that is not a reptile, which is exactly what the conclusion claims. Uncertain is tempting because the premises never mention pet reptiles, but the fur rule alone settles it.'
  WHERE section = 'verbal' AND prompt = 'No reptile has fur. Some pets have fur. Some pets are not reptiles — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'Bus 12 runs in the city, which places it inside the group covered by the opening statement, and that statement allows no exceptions among city buses. So Bus 12 is electric. Uncertain is the trap for students waiting to be told something specific about Bus 12, but group membership already tells us.'
  WHERE section = 'verbal' AND prompt = 'All buses in the city are electric. Bus 12 runs in the city. Bus 12 is electric — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'At least one runner is also a swimmer, and no swimmer is a cyclist, so that particular runner cannot be a cyclist. One such runner is all the conclusion needs. Uncertain is the trap here, since the premises never mention runners and cyclists in the same sentence, but the swimmer link connects them.'
  WHERE section = 'verbal' AND prompt = 'Some runners are swimmers. No swimmers are cyclists. Some runners are not cyclists — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'Some menu items are desserts, so at least one dessert is on the menu, and every menu item contains dairy. That dessert therefore contains dairy. Uncertain tempts students who notice that dairy and desserts never appear in one sentence, but the menu rule covers everything on the menu, desserts included.'
  WHERE section = 'verbal' AND prompt = 'Every item on the menu contains dairy. Some items on the menu are desserts. Some desserts contain dairy — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'Every poet is a writer, and no writer is illiterate, so no poet can be illiterate either. The claim that some poets are contradicts that chain outright. Uncertain is the trap whenever a conclusion feels unaddressed, but here the two premises link together and close the door completely.'
  WHERE section = 'verbal' AND prompt = 'All poets are writers. No writers are illiterate. Some poets are illiterate — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'The premise says everyone who passed studied; it does not say everyone who studied passed. Marcus studied, which leaves both outcomes open. True is the trap that comes from reading the rule backward. False is also wrong, because Marcus may well have been one of the students who passed.'
  WHERE section = 'verbal' AND prompt = 'Every student who passed the exam studied. Marcus studied. Marcus passed the exam — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'The premises describe only this orchestra, whose members are all sixteen or older, so no violinist inside it is younger. The conclusion, though, talks about violin players in general, and plenty of them play outside this orchestra and could be under sixteen. False is the trap for readers who stop at the orchestra.'
  WHERE section = 'verbal' AND prompt = 'No member of the orchestra is under sixteen. Some members of the orchestra play the violin. Some violin players are under sixteen — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'All amphibians are cold-blooded, and no cold-blooded creature keeps a constant body temperature, so no amphibian can. The conclusion claims some do, which the chain rules out. Uncertain is the trap when the premises never mention amphibians and body temperature in one sentence, but linking them through cold-blooded settles the matter.'
  WHERE section = 'verbal' AND prompt = 'All amphibians are cold-blooded. No cold-blooded creature keeps a constant body temperature. Some amphibians keep a constant body temperature — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'At least one treaty is ratified, and every ratified treaty is enforceable, so that treaty is enforceable. A single example is all the word some requires. Uncertain is the trap for students who notice we are never told which treaties are ratified, but we do not need to know which ones to know that some exist.'
  WHERE section = 'verbal' AND prompt = 'Some treaties are ratified. All ratified treaties are enforceable. Some treaties are enforceable — true, false, or uncertain?' AND options = '["True", "False", "Uncertain", "Neither"]'::JSONB;

UPDATE questions SET explanation = 'A violin, a cello, and a harp all make sound from vibrating strings that get plucked or bowed. A trumpet makes sound from air buzzing through the player''s lips into brass tubing, so it lacks the shared string. Harp is the tempting odd one because it looks so different, but it is still played by plucking strings.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others: Trumpet, Violin, Cello, Harp?' AND options = '["Trumpet", "Violin", "Cello", "Harp"]'::JSONB;

UPDATE questions SET explanation = 'A carrot, a potato, and an onion are all vegetables we eat from underground, whether root, tuber, or bulb. A cherry is a fruit that grows on a tree above ground, so it fails the shared test. Potato is a tempting pick because it is a tuber rather than a root, but it still grows below the soil.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others: Carrot, Cherry, Potato, Onion?' AND options = '["Carrot", "Cherry", "Potato", "Onion"]'::JSONB;

UPDATE questions SET explanation = 'A robin, an eagle, and a sparrow are birds, with feathers, beaks, and eggs. A bat flies too, but it is a mammal with fur that feeds its young milk. Flight is the trap in this group, because it makes the bat look as though it belongs. Eagle is tempting for its size, but size does not change the category.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others: Robin, Eagle, Bat, Sparrow?' AND options = '["Robin", "Eagle", "Bat", "Sparrow"]'::JSONB;

UPDATE questions SET explanation = 'A chair, a table, and a sofa are all pieces of furniture that rest on the floor and hold either you or your things. A curtain hangs at a window as a covering, so it is not furniture. Table is a tempting pick, since you sit on the other two and not on it, but all three are still furniture.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others: Chair, Table, Sofa, Curtain?' AND options = '["Chair", "Table", "Sofa", "Curtain"]'::JSONB;

UPDATE questions SET explanation = 'Copper, silver, and iron are metals: elements that conduct heat and electricity and can be hammered into shape. Slate is a rock, a layered stone used for roofs and chalkboards, so it misses the shared property. Silver is tempting because we mostly meet it as jewelry or coins, but it is a metal all the same.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others: Copper, Silver, Iron, Slate?' AND options = '["Copper", "Silver", "Iron", "Slate"]'::JSONB;

UPDATE questions SET explanation = 'Whisper, mumble, and shout are all ways of producing speech, differing only in volume and clarity. Listening is the receiving end of the exchange, which puts it on the other side. Mumble is the tempting pick, because it sounds like a failure to communicate, but it is still speech coming out of a mouth.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others: Whisper, Listen, Mumble, Shout?' AND options = '["Whisper", "Listen", "Mumble", "Shout"]'::JSONB;

UPDATE questions SET explanation = 'Mercury, Venus, and Neptune are planets that orbit the Sun. Europa is a moon orbiting Jupiter, so what it circles is a planet rather than the Sun. Mercury is a tempting pick since it shares its name with a metal and a Roman god, but in a list of space objects it is the innermost planet.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others: Mercury, Venus, Europa, Neptune?' AND options = '["Mercury", "Venus", "Europa", "Neptune"]'::JSONB;

UPDATE questions SET explanation = 'A meter, a liter, and a gram are units: the amounts we count in when measuring length, volume, and mass. A thermometer is an instrument that does the measuring, which puts it in a different category. Gram may look odd because it measures mass rather than size, but it is a unit like the other two.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others: Meter, Liter, Gram, Thermometer?' AND options = '["Meter", "Liter", "Gram", "Thermometer"]'::JSONB;

UPDATE questions SET explanation = 'Sprint, jog, and dash all describe running, from an all-out burst to a steady pace. To stroll is to walk slowly for pleasure, with no running involved. Jog is the tempting pick because it is the slowest of the three, but slow running is still running, and running is the property this group shares.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others: Sprint, Jog, Dash, Stroll?' AND options = '["Sprint", "Jog", "Dash", "Stroll"]'::JSONB;

UPDATE questions SET explanation = 'An oak, a maple, and a pine are trees with woody trunks that grow tall. A fern is a low, soft-stemmed plant with fronds and no wood, so it fails the shared test. Pine is a tempting pick, since it stays green all winter while the others drop their leaves, but it is a tree either way.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others: Fern, Oak, Maple, Pine?' AND options = '["Fern", "Oak", "Maple", "Pine"]'::JSONB;

UPDATE questions SET explanation = 'Reluctant, hesitant, and wary all describe holding back before acting, whether from unwillingness, doubt, or caution. Eager describes rushing toward action, which is the opposite pull. Wary is the tempting pick because it adds a sense of danger, but its caution still holds a person back exactly like the other two.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others: Reluctant, Hesitant, Eager, Wary?' AND options = '["Reluctant", "Hesitant", "Eager", "Wary"]'::JSONB;

UPDATE questions SET explanation = 'Candor, sincerity, and frankness all describe saying what you honestly mean. Flattery is praise you do not mean, offered to win someone over, so it fails the shared test of honesty. Frankness is a tempting pick because bluntness can sting, but saying something harshly is still saying it truthfully.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others: Candor, Sincerity, Frankness, Flattery?' AND options = '["Candor", "Sincerity", "Frankness", "Flattery"]'::JSONB;

UPDATE questions SET explanation = 'A novel, an essay, and an editorial are all written in prose, in ordinary sentences and paragraphs. A sonnet is verse, built from fourteen lines with a set meter and rhyme scheme. Editorial is a tempting pick because it is short and appears in newspapers, but its form is still plain prose.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others: Novel, Essay, Sonnet, Editorial?' AND options = '["Novel", "Essay", "Sonnet", "Editorial"]'::JSONB;

UPDATE questions SET explanation = 'Mitigate, alleviate, and ease all mean to make something less severe, such as pain or a penalty. Aggravate means to make it worse, so it runs the opposite direction. Ease is the tempting pick because it is the plain everyday word among three formal ones, but its meaning lines up with the other two.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others: Mitigate, Alleviate, Aggravate, Ease?' AND options = '["Mitigate", "Alleviate", "Aggravate", "Ease"]'::JSONB;

UPDATE questions SET explanation = 'Gullible, naive, and trusting all describe someone who believes what they are told without much resistance. Skeptical describes the opposite habit, doubting a claim until proof turns up. Trusting is the tempting pick because it sounds like a compliment while the others sound like insults, but tone is not the shared property; readiness to believe is.'
  WHERE section = 'verbal' AND prompt = 'Which word does NOT belong with the others: Gullible, Skeptical, Naive, Trusting?' AND options = '["Gullible", "Skeptical", "Naive", "Trusting"]'::JSONB;

-- Verification: expect 250 verbal rows carrying a long (rewritten) explanation.
SELECT
  'verbal' AS section,
  COUNT(*) AS total_rows,
  COUNT(*) FILTER (WHERE LENGTH(explanation) > 150) AS long_explanations,
  250 AS expected_long_explanations
FROM questions
WHERE section = 'verbal';
