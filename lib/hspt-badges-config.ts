export interface BadgeStats {
  earnedBadgeIds: string[]
  completions: Record<string, number>
  perfectSections: string[]
  speedBadgeSections: string[]
  highScoreSections: string[]
  totalCompletions: number
}

export interface Badge {
  id: string
  name: string
  creature: string
  emoji: string
  category: string
  rarity: string
  description: string
  lore: string
  condition: (stats: BadgeStats) => boolean
  section?: string
  sections?: string[]
}

export const BADGES: Record<string, Badge> = {

  // FIRST COMPLETION
  first_verbal: {
    id:"first_verbal", name:"Baby Wordumph", creature:"Wordumph",
    emoji:"🐣💬", category:"First Completion", rarity:"Common", section:"Verbal",
    description:"Completed your first Verbal challenge.",
    lore:"A Wordumph is a small, pompous creature that knows every word in the dictionary and will absolutely use all of them in one sentence if given the opportunity. This is the baby version. It only knows 'antonym' so far. It is already insufferable.",
    condition:({completions:c})=>(c['Verbal']??0)>=1,
  },
  first_quantitative: {
    id:"first_quantitative", name:"Baby Seriesnake", creature:"Seriesnake",
    emoji:"🐍🔢", category:"First Completion", rarity:"Common", section:"Quantitative",
    description:"Completed your first Quantitative challenge.",
    lore:"A Seriesnake's body IS a number sequence — its head is the first term and its tail predicts the next one. This baby Seriesnake only goes up to 10. It's trying its best. Its tail keeps guessing wrong and it's very embarrassed about it.",
    condition:({completions:c})=>(c['Quantitative']??0)>=1,
  },
  first_reading: {
    id:"first_reading", name:"Baby Pageslobber", creature:"Pageslobber",
    emoji:"📘🤤", category:"First Completion", rarity:"Common", section:"Reading",
    description:"Completed your first Reading challenge.",
    lore:"Pageslobbers absorb knowledge by physically slobbering on books. Scientists are deeply uncomfortable with this. The Pageslobber is not. This baby has slobbered on exactly one passage. It understood the main idea. It is very proud of itself.",
    condition:({completions:c})=>(c['Reading']??0)>=1,
  },
  first_mathematics: {
    id:"first_mathematics", name:"Baby Numbskull", creature:"Numbskull",
    emoji:"💀🔢", category:"First Completion", rarity:"Common", section:"Mathematics",
    description:"Completed your first Mathematics challenge.",
    lore:"Numbskulls look dopey. They have enormous, lumpy heads and a perpetually confused expression. They are in fact mathematical geniuses. This is the baby version, which means it looks even more confused than usual. Do not be fooled. It just solved for x while you were reading this.",
    condition:({completions:c})=>(c['Mathematics']??0)>=1,
  },
  first_language: {
    id:"first_language", name:"Baby Grammarpede", creature:"Grammarpede",
    emoji:"🐛✏️", category:"First Completion", rarity:"Common", section:"Language",
    description:"Completed your first Language challenge.",
    lore:"A Grammarpede is a centipede where each of its one hundred legs is a different punctuation mark. The baby version only has twelve legs so far. Three of them are commas. It will judge you for every run-on sentence you have ever written, including that one.",
    condition:({completions:c})=>(c['Language']??0)>=1,
  },

  // PERFECT SCORE
  perfect_verbal: {
    id:"perfect_verbal", name:"Grand Wordumph", creature:"Grand Wordumph",
    emoji:"🎩💬", category:"Perfect Score", rarity:"Rare", section:"Verbal",
    description:"10/10 correct on a Verbal challenge.",
    lore:"The Grand Wordumph has read every thesaurus ever printed and considers this the bare minimum. It speaks in analogies so layered that linguists need three weeks to unpack one sentence. It reviewed your perfect score, said 'adequate,' and handed you a vocabulary list for next time.",
    condition:({perfectSections:p})=>p.includes("Verbal"),
  },
  perfect_quantitative: {
    id:"perfect_quantitative", name:"Infinite Seriesnake", creature:"Infinite Seriesnake",
    emoji:"🐍♾️", category:"Perfect Score", rarity:"Rare", section:"Quantitative",
    description:"10/10 correct on a Quantitative challenge.",
    lore:"The Infinite Seriesnake has no tail — it goes on forever, each segment the correct next term in an ever-more-complex sequence. Mathematicians have been following it for three years trying to find the pattern. You found it in 34 seconds. The Seriesnake is impressed. It does not show this.",
    condition:({perfectSections:p})=>p.includes("Quantitative"),
  },
  perfect_reading: {
    id:"perfect_reading", name:"Sopping Pageslobber", creature:"Sopping Pageslobber",
    emoji:"📚💦", category:"Perfect Score", rarity:"Rare", section:"Reading",
    description:"10/10 correct on a Reading challenge.",
    lore:"The Sopping Pageslobber has absorbed so many passages it is perpetually drenched. Libraries ban it for obvious reasons. It has perfect recall of every main idea, every inference, every vocabulary word in context. It read your mind to check your work. Your mind was correct. It slobbered approvingly.",
    condition:({perfectSections:p})=>p.includes("Reading"),
  },
  perfect_mathematics: {
    id:"perfect_mathematics", name:"Colossal Numbskull", creature:"Colossal Numbskull",
    emoji:"💀💎", category:"Perfect Score", rarity:"Rare", section:"Mathematics",
    description:"10/10 correct on a Mathematics challenge.",
    lore:"The Colossal Numbskull has a head so large from accumulated math knowledge that it tips over occasionally. It does not care. It rights itself, solves another theorem, and looks confused about everything that isn't a number. Your perfect score caused a small crystal to grow on its enormous skull. You put it there.",
    condition:({perfectSections:p})=>p.includes("Mathematics"),
  },
  perfect_language: {
    id:"perfect_language", name:"Hundred-Legged Grammarpede", creature:"Hundred-Legged Grammarpede",
    emoji:"🐛👑", category:"Perfect Score", rarity:"Rare", section:"Language",
    description:"10/10 correct on a Language challenge.",
    lore:"The Hundred-Legged Grammarpede has all one hundred legs and every one of them is a correctly used punctuation mark. It has never, in its entire life, used a comma splice. It once fainted when someone said 'I could care less.' It reviewed your perfect score and wept a single, grammatically appropriate tear.",
    condition:({perfectSections:p})=>p.includes("Language"),
  },

  // SPEED
  speed_verbal: {
    id:"speed_verbal", name:"Blabbering Wordumph", creature:"Blabbering Wordumph",
    emoji:"🎩💨", category:"Speed", rarity:"Rare", section:"Verbal",
    description:"Blazing speed through a Verbal challenge.",
    lore:"The Blabbering Wordumph talks so fast that its synonyms come out in alphabetical order. It answered all ten verbal questions before it finished clearing its throat. It is now mid-sentence on a different topic entirely. Nobody has ever successfully interrupted one.",
    condition:({speedBadgeSections:s})=>s.includes("Verbal"),
  },
  speed_quantitative: {
    id:"speed_quantitative", name:"Turbo Seriesnake", creature:"Turbo Seriesnake",
    emoji:"🐍💨", category:"Speed", rarity:"Rare", section:"Quantitative",
    description:"Blazing speed through a Quantitative challenge.",
    lore:"The Turbo Seriesnake moves so fast that it laps its own tail and accidentally extends the sequence. Mathematicians chasing the Infinite Seriesnake have never seen one move this fast. You matched its speed. It zipped past and left a number in your hair. That number is the next term.",
    condition:({speedBadgeSections:s})=>s.includes("Quantitative"),
  },
  speed_reading: {
    id:"speed_reading", name:"Frantic Pageslobber", creature:"Frantic Pageslobber",
    emoji:"📘⚡", category:"Speed", rarity:"Rare", section:"Reading",
    description:"Blazing speed through a Reading challenge.",
    lore:"The Frantic Pageslobber ingests passages so quickly that it sometimes slobbers on the questions too. This is considered rude but also impressive. It absorbed all five passages in the time it takes most creatures to read the first sentence. It still got every inference right. It is a menace.",
    condition:({speedBadgeSections:s})=>s.includes("Reading"),
  },
  speed_mathematics: {
    id:"speed_mathematics", name:"Zippy Numbskull", creature:"Zippy Numbskull",
    emoji:"💀💨", category:"Speed", rarity:"Rare", section:"Mathematics",
    description:"Blazing speed through a Mathematics challenge.",
    lore:"The Zippy Numbskull looks confused at all times but solves equations before the pencil hits the paper. Its enormous head gives it so much calculating power that it experiences time slightly differently. By the time you finished reading the problem, it had already checked the answer twice.",
    condition:({speedBadgeSections:s})=>s.includes("Mathematics"),
  },
  speed_language: {
    id:"speed_language", name:"Stampeding Grammarpede", creature:"Stampeding Grammarpede",
    emoji:"🐛💨", category:"Speed", rarity:"Rare", section:"Language",
    description:"Blazing speed through a Language challenge.",
    lore:"The Stampeding Grammarpede moves so fast its hundred legs blur into a grammatical smear. Each step it takes corrects a different error in the English language. It spotted your dangling modifier before you finished the sentence. It fixed it before it moved on. You barely saw it happen.",
    condition:({speedBadgeSections:s})=>s.includes("Language"),
  },

  // 2-SECTION COMBO
  combo_verbal_quant: {
    id:"combo_verbal_quant", name:"The Algebraggart", creature:"Algebraggart",
    emoji:"🧮💬", category:"Combo", rarity:"Epic",
    sections:["Verbal","Quantitative"],
    description:"High score in Verbal AND Quantitative.",
    lore:"An Algebraggart brags about both vocabulary and number sequences simultaneously, often in the same breath. It will compliment your analogy, point out the Fibonacci structure of your sentence, and then correct your synonym — all before you can respond. It is exhausting to be around. It is very proud of this.",
    condition:({highScoreSections:h})=>["Verbal","Quantitative"].every(s=>h.includes(s)),
  },
  combo_verbal_reading: {
    id:"combo_verbal_reading", name:"The Blabberphage", creature:"Blabberphage",
    emoji:"📖💬", category:"Combo", rarity:"Epic",
    sections:["Verbal","Reading"],
    description:"High score in Verbal AND Reading.",
    lore:"A Blabberphage eats books whole and then immediately, at length, tells everyone exactly what they were about. It recounts main ideas, inferences, and vocabulary words in context, using extremely impressive synonyms. It once summarized a novel in thirty-seven analogies. The novel was shorter than the summary.",
    condition:({highScoreSections:h})=>["Verbal","Reading"].every(s=>h.includes(s)),
  },
  combo_verbal_math: {
    id:"combo_verbal_math", name:"The Calculoquist", creature:"Calculoquist",
    emoji:"🗣️🧮", category:"Combo", rarity:"Epic",
    sections:["Verbal","Mathematics"],
    description:"High score in Verbal AND Mathematics.",
    lore:"A Calculoquist is a ventriloquist — but instead of a puppet, it uses algebra. It speaks in elaborate metaphors that, upon examination, also happen to be proofs. Its dummy is a quadratic equation named Gerald. Gerald has never said anything grammatically incorrect. Gerald is terrifying.",
    condition:({highScoreSections:h})=>["Verbal","Mathematics"].every(s=>h.includes(s)),
  },
  combo_verbal_language: {
    id:"combo_verbal_language", name:"The Snootifax", creature:"Snootifax",
    emoji:"🎩📝", category:"Combo", rarity:"Epic",
    sections:["Verbal","Language"],
    description:"High score in Verbal AND Language.",
    lore:"A Snootifax is unbearably correct about everything related to language. It knows every word, uses all of them properly, and will — without being asked — point out when you haven't. It once spent forty-five minutes explaining the difference between 'further' and 'farther' to a parking meter. The parking meter did not change. The Snootifax felt it had made its point.",
    condition:({highScoreSections:h})=>["Verbal","Language"].every(s=>h.includes(s)),
  },
  combo_quant_math: {
    id:"combo_quant_math", name:"The Numberwump", creature:"Numberwump",
    emoji:"🐻🔢", category:"Combo", rarity:"Epic",
    sections:["Quantitative","Mathematics"],
    description:"High score in Quantitative AND Mathematics.",
    lore:"A Numberwump is a large, round, wumpus-adjacent creature that simply loves numbers with its entire body. It collects number series the way other animals collect acorns. It sleeps on a bed of solved equations. When it woke up and saw your scores, it made a sound like a calculator hitting a high note. This is its version of a standing ovation.",
    condition:({highScoreSections:h})=>["Quantitative","Mathematics"].every(s=>h.includes(s)),
  },
  combo_quant_reading: {
    id:"combo_quant_reading", name:"The Inferbat", creature:"Inferbat",
    emoji:"🦇📊", category:"Combo", rarity:"Epic",
    sections:["Quantitative","Reading"],
    description:"High score in Quantitative AND Reading.",
    lore:"The Inferbat reads everything and immediately infers more than is probably warranted. It hangs upside down for optimal comprehension and echolocates inference. It once read a bus schedule and inferred that the author was going through something emotionally. It was statistically likely. The Inferbat is always right.",
    condition:({highScoreSections:h})=>["Quantitative","Reading"].every(s=>h.includes(s)),
  },
  combo_quant_language: {
    id:"combo_quant_language", name:"The Syntactodon", creature:"Syntactodon",
    emoji:"🦕⚙️", category:"Combo", rarity:"Epic",
    sections:["Quantitative","Language"],
    description:"High score in Quantitative AND Language.",
    lore:"The Syntactodon is ancient, enormous, and absolutely will not tolerate a sentence that doesn't also follow a numerical pattern. It roamed the prehistoric era correcting cave paintings for comma splices and arranging boulders into Fibonacci sequences. It is still doing this. It will never stop.",
    condition:({highScoreSections:h})=>["Quantitative","Language"].every(s=>h.includes(s)),
  },
  combo_reading_math: {
    id:"combo_reading_math", name:"The Theorebeast", creature:"Theorebeast",
    emoji:"🐗📐", category:"Combo", rarity:"Epic",
    sections:["Reading","Mathematics"],
    description:"High score in Reading AND Mathematics.",
    lore:"A Theorebeast reads math textbooks for fun. For FUN. It does not consider this unusual. It takes detailed notes in the margins. Its favorite genre is 'proof.' When it finishes a particularly satisfying theorem it closes the book, nods slowly, and makes a sound like 'mmmm.' It has made this sound fourteen thousand times. It will make it again.",
    condition:({highScoreSections:h})=>["Reading","Mathematics"].every(s=>h.includes(s)),
  },
  combo_reading_language: {
    id:"combo_reading_language", name:"The Palimpsestopus", creature:"Palimpsestopus",
    emoji:"🐙📜", category:"Combo", rarity:"Epic",
    sections:["Reading","Language"],
    description:"High score in Reading AND Language.",
    lore:"A Palimpsestopus is an octopus made entirely of layered old manuscripts, and each of its eight arms is holding a different grammar rule. It reads with six arms, edits with one, and uses the last to gesture dramatically at incorrectly placed apostrophes. It cannot believe what it has to deal with.",
    condition:({highScoreSections:h})=>["Reading","Language"].every(s=>h.includes(s)),
  },
  combo_math_language: {
    id:"combo_math_language", name:"The Proofreadacorn", creature:"Proofreadacorn",
    emoji:"🌰✏️", category:"Combo", rarity:"Epic",
    sections:["Mathematics","Language"],
    description:"High score in Mathematics AND Language.",
    lore:"A Proofreadacorn is small, persistent, and always correct. It arrives unannounced, sits on your shoulder, and quietly points out that your equation is wrong AND your sentence is a fragment. It does this in a tiny but confident voice. It has no memory of ever being wrong. This is because it has never been wrong.",
    condition:({highScoreSections:h})=>["Mathematics","Language"].every(s=>h.includes(s)),
  },

  // 3-SECTION COMBO
  combo_v_q_m: {
    id:"combo_v_q_m", name:"The Mathemoggart", creature:"Mathemoggart",
    emoji:"🧮💬🐗", category:"Combo", rarity:"Legendary",
    sections:["Verbal","Quantitative","Mathematics"],
    description:"High score in Verbal, Quantitative, AND Mathematics.",
    lore:"A Mathemoggart is what happens when an Algebraggart and a Numberwump collide at high speed. The result is a creature that brags in three disciplines simultaneously: vocabulary, sequences, and equations. Conversations with one last approximately four hours and are secretly educational. Nobody admits they enjoyed it.",
    condition:({highScoreSections:h})=>["Verbal","Quantitative","Mathematics"].every(s=>h.includes(s)),
  },
  combo_v_r_l: {
    id:"combo_v_r_l", name:"The Snabberphage", creature:"Snabberphage",
    emoji:"📚🎩🐛", category:"Combo", rarity:"Legendary",
    sections:["Verbal","Reading","Language"],
    description:"High score in Verbal, Reading, AND Language.",
    lore:"A Snabberphage is what you get when a Blabberphage and a Snootifax have an argument and a Grammarpede referees. It eats books, describes them using extraordinarily precise vocabulary, and corrects its own grammar mid-sentence. It once hyphenated a word it was physically saying out loud. Nobody questioned it.",
    condition:({highScoreSections:h})=>["Verbal","Reading","Language"].every(s=>h.includes(s)),
  },
  combo_q_m_l: {
    id:"combo_q_m_l", name:"The Syntumberwump", creature:"Syntumberwump",
    emoji:"🦕🐻⚙️", category:"Combo", rarity:"Legendary",
    sections:["Quantitative","Mathematics","Language"],
    description:"High score in Quantitative, Mathematics, AND Language.",
    lore:"A Syntumberwump is a Numberwump that got into a heated argument with a Syntactodon about whether semicolons can separate terms in a series. The resulting fusion loves numbers AND grammar with equal, unsettling intensity. It writes number sequences with perfect punctuation and considers this its greatest achievement. It is correct.",
    condition:({highScoreSections:h})=>["Quantitative","Mathematics","Language"].every(s=>h.includes(s)),
  },
  combo_r_q_m: {
    id:"combo_r_q_m", name:"The Infernumbeast", creature:"Infernumbeast",
    emoji:"🦇🐗🔢", category:"Combo", rarity:"Legendary",
    sections:["Reading","Quantitative","Mathematics"],
    description:"High score in Reading, Quantitative, AND Mathematics.",
    lore:"An Infernumbeast is what happens when a Theorebeast starts hanging upside down and the Inferbat starts solving equations. The resulting creature reads data like passages, processes passages like equations, and infers mathematical proofs from context clues. It finds all of this very normal. It is not very normal.",
    condition:({highScoreSections:h})=>["Reading","Quantitative","Mathematics"].every(s=>h.includes(s)),
  },
  combo_v_r_m: {
    id:"combo_v_r_m", name:"The Blabberore", creature:"Blabberore",
    emoji:"📖💬🐗", category:"Combo", rarity:"Legendary",
    sections:["Verbal","Reading","Mathematics"],
    description:"High score in Verbal, Reading, AND Mathematics.",
    lore:"A Blabberore is a Blabberphage that went through a math phase and never came back out. It now summarizes novels using geometric proofs and describes triangles using extended metaphors. It once explained the Pythagorean theorem using three analogies and a passage about frogs. Everyone understood immediately.",
    condition:({highScoreSections:h})=>["Verbal","Reading","Mathematics"].every(s=>h.includes(s)),
  },
  combo_v_q_l: {
    id:"combo_v_q_l", name:"The Algebraggardpede", creature:"Algebraggardpede",
    emoji:"🧮💬🐛", category:"Combo", rarity:"Legendary",
    sections:["Verbal","Quantitative","Language"],
    description:"High score in Verbal, Quantitative, AND Language.",
    lore:"The Algebraggardpede is an Algebraggart that absorbed a Grammarpede and is now even harder to argue with. It brags about sequences AND vocabulary AND grammar in rapid rotation. Each of its many legs is a punctuation mark or a number. It is very long. It has a lot to say. It is already saying it.",
    condition:({highScoreSections:h})=>["Verbal","Quantitative","Language"].every(s=>h.includes(s)),
  },
  combo_r_m_l: {
    id:"combo_r_m_l", name:"The Proofreadabeast", creature:"Proofreadabeast",
    emoji:"🌰📐📜", category:"Combo", rarity:"Legendary",
    sections:["Reading","Mathematics","Language"],
    description:"High score in Reading, Mathematics, AND Language.",
    lore:"A Proofreadabeast is a Theorebeast that found a Proofreadacorn on its shoulder and decided not to remove it. The Proofreadacorn did not ask for permission. Together they read, solve, and correct everything in their path. The Proofreadacorn points. The Proofreadabeast nods. Nothing escapes them.",
    condition:({highScoreSections:h})=>["Reading","Mathematics","Language"].every(s=>h.includes(s)),
  },
  combo_q_r_l: {
    id:"combo_q_r_l", name:"The Inferbatopus", creature:"Inferbatopus",
    emoji:"🦇🐙🔢", category:"Combo", rarity:"Legendary",
    sections:["Quantitative","Reading","Language"],
    description:"High score in Quantitative, Reading, AND Language.",
    lore:"An Inferbatopus is a Palimpsestopus that merged with an Inferbat during a grammatical dispute. It now hangs upside down from a manuscript, reads everything, edits everything, and then infers seventeen additional things about the author's emotional state and which number sequence they subconsciously encoded in the paragraph spacing. It is usually right.",
    condition:({highScoreSections:h})=>["Quantitative","Reading","Language"].every(s=>h.includes(s)),
  },

  // ALL FIVE
  combo_all_five: {
    id:"combo_all_five", name:"The Grand Snabberumbwump", creature:"Grand Snabberumbwump",
    emoji:"🌟🐉🎩", category:"Combo", rarity:"Mythic",
    sections:["Verbal","Quantitative","Reading","Mathematics","Language"],
    description:"High score in ALL FIVE sections.",
    lore:"Nobody planned the Grand Snabberumbwump. It happened when every single one of the lesser creatures got into an argument about which subject was most important and fused together mid-debate. The result is enormous, pedantic, slightly soggy from Pageslobber residue, covered in punctuation legs, and absolutely correct about everything all the time. It is bragging right now. It cannot stop. It scored perfectly on the HSPT in 1987 and has never emotionally moved on from this achievement. Neither should you.",
    condition:({highScoreSections:h})=>["Verbal","Quantitative","Reading","Mathematics","Language"].every(s=>h.includes(s)),
  },

  // MILESTONE
  milestone_3: {
    id:"milestone_3", name:"The Tryagain", creature:"Tryagain",
    emoji:"🔁🐾", category:"Milestone", rarity:"Uncommon",
    description:"Completed 3 total challenges.",
    lore:"The Tryagain is a creature with no memory of failure and no concept of giving up. It simply appears whenever someone completes their third attempt at something. Nobody knows where it lives in between. It shows up, nods approvingly, and wanders off. It will be back.",
    condition:({totalCompletions:t})=>t>=3,
  },
  milestone_10: {
    id:"milestone_10", name:"The Decadoofus", creature:"Decadoofus",
    emoji:"🏆🤪", category:"Milestone", rarity:"Rare",
    description:"Completed 10 total challenges.",
    lore:"The Decadoofus has done everything ten times. Every time. It has ten horns, ten tails, and an expression that says 'I've seen this before' about literally everything. It arrived when you finished your tenth run, handed you an invisible trophy, tripped over its own tails, and somehow made it look intentional.",
    condition:({totalCompletions:t})=>t>=10,
  },
  milestone_all_sections: {
    id:"milestone_all_sections", name:"The Pentaflop", creature:"Pentaflop",
    emoji:"🌐🫠", category:"Milestone", rarity:"Epic",
    description:"Completed at least one challenge in every section.",
    lore:"The Pentaflop is a creature that has attempted every discipline and is, frankly, a little tired. It respects that you've done the same. It doesn't excel at any one thing. It shows up for all of them. It would rather be napping but here it is. Here you both are. Five sections down. The Pentaflop gives you a tired high five.",
    condition:({completions:c})=>["Verbal","Quantitative","Reading","Mathematics","Language"].every(s=>(c[s]??0)>=1),
  },
  milestone_all_perfect: {
    id:"milestone_all_perfect", name:"The Flawlesswump", creature:"Flawlesswump",
    emoji:"💎🐻", category:"Milestone", rarity:"Mythic",
    description:"Perfect score (10/10) in ALL five sections.",
    lore:"The Flawlesswump looks like a regular Numberwump except every single one of its hairs is a correct answer. It has 4,200 hairs. All of them are right. It achieved a perfect score across all five sections sometime in the early 2000s and has been extremely calm about it ever since. It saw your scores and simply sat down next to you. That's the whole thing. That's the compliment.",
    condition:({perfectSections:p})=>["Verbal","Quantitative","Reading","Mathematics","Language"].every(s=>p.includes(s)),
  },
}

// Returns badges newly earned (not already in earnedBadgeIds)
export function evaluateBadges(stats: BadgeStats): Badge[] {
  return Object.values(BADGES).filter(
    b => !stats.earnedBadgeIds.includes(b.id) && b.condition(stats)
  )
}
