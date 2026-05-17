'use client'

import { useState, useEffect, useRef, useCallback } from 'react'
import { DIFFICULTY_BASE_POINTS, DIFFICULTY_TIME_WEIGHT, IDEAL_TIME } from '@/lib/constants'
import { evaluateBadges, BADGES, type Badge, type BadgeStats } from '@/lib/hspt-badges-config'

// Visual cap for the countdown ring
const MAX_DISPLAY_TIME: Record<string, number> = { Easy: 20, Medium: 60, Hard: 90 }

const PACING_NOTES: Record<string, Record<string, string>> = {
  Verbal: {
    Easy:   "Vocab and logic patterns click fast — read once and choose.",
    Medium: "Analogies need a beat to find the link — trust your first instinct.",
    Hard:   "Complex logic needs re-reading; if stuck at 20s, commit to your best guess.",
  },
  Quantitative: {
    Easy:   "Spot the pattern visually before computing — verify your next term.",
    Medium: "Work backwards from the answer choices if the setup feels slow.",
    Hard:   "Write the pattern rule first, then compute — don't rush the setup.",
  },
  Reading: {
    Easy:   "The answer is directly in the passage — scan for the key word in the question.",
    Medium: "Inference questions need the full context; read before choosing.",
    Hard:   "Author's purpose and tone need careful passage review — budget the extra time.",
  },
  Mathematics: {
    Easy:   "Quick arithmetic — estimate first to sanity-check your answer.",
    Medium: "Write the equation before you compute; don't try to solve in your head.",
    Hard:   "Multi-step problems: write each step. Rushing causes errors.",
  },
  Language: {
    Easy:   "Trust your ear — read the sentence aloud in your head before choosing.",
    Medium: "Eliminate obviously wrong answers first, then compare the remaining two.",
    Hard:   "Identify the subject and verb first; grammar rules apply to the whole structure.",
  },
}

interface ChallengeQuestion {
  id: string
  difficulty: string
  type: string
  question: string
  choices: string[]
  answer: string
  explanation: string
  passage?: string
  _section: string
}

function calcScore(correct: boolean, diff: string, secondsTaken: number, idealSecs: number) {
  if (!correct) return { base: 0, bonus: 0, total: 0, timeSaved: 0 }
  const base      = DIFFICULTY_BASE_POINTS[diff] ?? 10
  const timeSaved = Math.max(0, idealSecs - secondsTaken)
  const bonus     = Math.round(timeSaved * (DIFFICULTY_TIME_WEIGHT[diff] ?? 1) * 0.3 * 10) / 10
  return { base, bonus, total: Math.round((base + bonus) * 10) / 10, timeSaved }
}

function loadStats(): BadgeStats {
  try {
    return {
      earnedBadgeIds:    JSON.parse(localStorage.getItem('hspt_earned_badges')      || '[]'),
      completions:       JSON.parse(localStorage.getItem('hspt_completions')         || '{}'),
      perfectSections:   JSON.parse(localStorage.getItem('hspt_perfect_sections')    || '[]'),
      speedBadgeSections:JSON.parse(localStorage.getItem('hspt_speed_sections')      || '[]'),
      highScoreSections: JSON.parse(localStorage.getItem('hspt_high_score_sections') || '[]'),
      totalCompletions:  Number(localStorage.getItem('hspt_total_completions')       || 0),
    }
  } catch {
    return { earnedBadgeIds:[], completions:{}, perfectSections:[], speedBadgeSections:[], highScoreSections:[], totalCompletions:0 }
  }
}

function saveStats(stats: BadgeStats) {
  localStorage.setItem('hspt_earned_badges',       JSON.stringify(stats.earnedBadgeIds))
  localStorage.setItem('hspt_completions',          JSON.stringify(stats.completions))
  localStorage.setItem('hspt_perfect_sections',     JSON.stringify(stats.perfectSections))
  localStorage.setItem('hspt_speed_sections',       JSON.stringify(stats.speedBadgeSections))
  localStorage.setItem('hspt_high_score_sections',  JSON.stringify(stats.highScoreSections))
  localStorage.setItem('hspt_total_completions',    String(stats.totalCompletions))
}

// ─── QUESTION DATA ────────────────────────────────────────────────────────────
const ALL_QUESTIONS: Record<string, Omit<ChallengeQuestion, '_section'>[]> = {
  Verbal: [
    { id:"V1", difficulty:"Easy",   type:"Synonym",
      question:"HAPPY most nearly means:",
      choices:["A. Sad","B. Joyful","C. Angry","D. Tired"], answer:"B",
      explanation:"Joyful and happy both mean feeling pleasure or contentment." },
    { id:"V2", difficulty:"Easy",   type:"Antonym",
      question:"ANCIENT is the opposite of:",
      choices:["A. Old","B. Large","C. Modern","D. Quiet"], answer:"C",
      explanation:"Ancient means very old; modern means recent — direct opposites." },
    { id:"V3", difficulty:"Easy",   type:"Logic",
      question:"All cats are animals. All animals need food. All cats need food — true, false, or uncertain?",
      choices:["A. True","B. False","C. Uncertain","D. Neither"], answer:"A",
      explanation:"By syllogism: cats → animals → need food. True." },
    { id:"V4", difficulty:"Medium", type:"Analogy",
      question:"Paintbrush is to painter as scalpel is to:",
      choices:["A. Hospital","B. Surgeon","C. Nurse","D. Patient"], answer:"B",
      explanation:"A paintbrush is the primary tool of a painter; a scalpel is the primary tool of a surgeon." },
    { id:"V5", difficulty:"Medium", type:"Classification",
      question:"Which word does NOT belong with the others?",
      choices:["A. Hammer","B. Wrench","C. Screwdriver","D. Paintbrush"], answer:"D",
      explanation:"Hammer, wrench, screwdriver are repair tools; paintbrush is an art tool." },
    { id:"V6", difficulty:"Medium", type:"Synonym",
      question:"ELOQUENT most nearly means:",
      choices:["A. Loud","B. Articulate","C. Confused","D. Brief"], answer:"B",
      explanation:"Eloquent means expressing ideas fluently and persuasively." },
    { id:"V7", difficulty:"Medium", type:"Logic",
      question:"Some musicians are teachers. All teachers are college graduates. Some musicians are college graduates — true, false, or uncertain?",
      choices:["A. True","B. False","C. Uncertain","D. Cannot be determined"], answer:"A",
      explanation:"Musicians who are teachers must be graduates, so at least some musicians are graduates." },
    { id:"V8", difficulty:"Hard",   type:"Analogy",
      question:"Sycophant is to flattery as martyr is to:",
      choices:["A. Religion","B. Sacrifice","C. Courage","D. Victory"], answer:"B",
      explanation:"A sycophant is defined by flattery; a martyr is defined by sacrifice." },
    { id:"V9", difficulty:"Hard",   type:"Synonym",
      question:"LOQUACIOUS most nearly means:",
      choices:["A. Silent","B. Logical","C. Talkative","D. Lazy"], answer:"C",
      explanation:"Loquacious means tending to talk a great deal." },
    { id:"V10", difficulty:"Hard",  type:"Logic",
      question:"No reptiles are warm-blooded. Some egg-layers are warm-blooded. Some egg-layers are reptiles — true, false, or uncertain?",
      choices:["A. True","B. False","C. Uncertain","D. Impossible"], answer:"C",
      explanation:"Reptiles lay eggs, but whether warm-blooded egg-layers overlap with reptiles cannot be determined." },
  ],
  Quantitative: [
    { id:"Q1", difficulty:"Easy",   type:"Number Series",
      question:"What number comes next?  2, 4, 6, 8, ___",
      choices:["A. 9","B. 10","C. 12","D. 11"], answer:"B",
      explanation:"Adding 2 each time: 8 + 2 = 10." },
    { id:"Q2", difficulty:"Easy",   type:"Number Manipulation",
      question:"A number multiplied by 3 gives 21. What is the number?",
      choices:["A. 6","B. 9","C. 7","D. 8"], answer:"C",
      explanation:"21 ÷ 3 = 7." },
    { id:"Q3", difficulty:"Easy",   type:"Number Series",
      question:"What number comes next?  100, 90, 80, 70, ___",
      choices:["A. 55","B. 65","C. 60","D. 50"], answer:"C",
      explanation:"Subtracting 10 each time: 70 − 10 = 60." },
    { id:"Q4", difficulty:"Medium", type:"Number Series",
      question:"What number comes next?  3, 6, 12, 24, ___",
      choices:["A. 36","B. 42","C. 48","D. 30"], answer:"C",
      explanation:"Each term doubles: 24 × 2 = 48." },
    { id:"Q5", difficulty:"Medium", type:"Comparison",
      question:"Examine: (A) 3/4 vs. (B) 7/10. Which is greater?",
      choices:["A. A is greater","B. B is greater","C. Equal","D. Cannot determine"], answer:"A",
      explanation:"3/4 = 0.75; 7/10 = 0.70. A is greater." },
    { id:"Q6", difficulty:"Medium", type:"Number Manipulation",
      question:"A number is divided by 5, then 8 is added, giving 12. What was the original number?",
      choices:["A. 20","B. 25","C. 15","D. 30"], answer:"A",
      explanation:"12 − 8 = 4; 4 × 5 = 20." },
    { id:"Q7", difficulty:"Medium", type:"Number Series",
      question:"What number comes next?  1, 4, 9, 16, ___",
      choices:["A. 20","B. 25","C. 21","D. 24"], answer:"B",
      explanation:"Perfect squares: 1², 2², 3², 4², 5² = 25." },
    { id:"Q8", difficulty:"Hard",   type:"Number Series",
      question:"What number comes next?  2, 3, 5, 8, 13, ___",
      choices:["A. 18","B. 19","C. 21","D. 20"], answer:"C",
      explanation:"Fibonacci: each = sum of prior two. 8 + 13 = 21." },
    { id:"Q9", difficulty:"Hard",   type:"Comparison",
      question:"Examine: (A) 5² − 3²  vs.  (B) (5−3)². Which is greater?",
      choices:["A. A is greater","B. B is greater","C. Equal","D. Cannot determine"], answer:"A",
      explanation:"A: 25 − 9 = 16.  B: 2² = 4.  A is greater." },
    { id:"Q10", difficulty:"Hard",  type:"Number Manipulation",
      question:"The average of five consecutive even numbers is 18. What is the largest?",
      choices:["A. 20","B. 22","C. 24","D. 26"], answer:"B",
      explanation:"Numbers centered on 18: 14,16,18,20,22. Largest = 22." },
  ],
  Reading: [
    { id:"R1", difficulty:"Easy",   type:"Comprehension",
      passage:"Monarch butterflies migrate up to 3,000 miles from Canada and the US to their wintering grounds in the mountains of central Mexico. Scientists study how they navigate using the sun as a compass.",
      question:"Where do monarchs spend the winter?",
      choices:["A. Canada","B. United States","C. Mountains of central Mexico","D. South America"], answer:"C",
      explanation:"The passage directly states monarchs travel to the mountains of central Mexico." },
    { id:"R2", difficulty:"Easy",   type:"Vocabulary",
      passage:"Monarch butterflies migrate up to 3,000 miles from Canada and the US to their wintering grounds in the mountains of central Mexico. Scientists study how they navigate using the sun as a compass.",
      question:"As used in the passage, 'navigate' most nearly means:",
      choices:["A. Fly fast","B. Find one's way","C. Avoid danger","D. Rest and recover"], answer:"B",
      explanation:"Navigate means to find one's way." },
    { id:"R3", difficulty:"Easy",   type:"Comprehension",
      passage:"Rain forests cover about 6% of Earth's surface but house more than half of the world's plant and animal species. They regulate climate by absorbing large amounts of carbon dioxide.",
      question:"What percentage of Earth's surface do rain forests cover?",
      choices:["A. 25%","B. 50%","C. 6%","D. 12%"], answer:"C",
      explanation:"The passage states rain forests cover about 6% of Earth's surface." },
    { id:"R4", difficulty:"Medium", type:"Inference",
      passage:"In 1869, the Transcontinental Railroad let passengers travel coast-to-coast in about a week — versus months by wagon or ship. It accelerated westward settlement and created a national market for goods.",
      question:"Which conclusion is best supported by the passage?",
      choices:["A. The railroad hurt the wagon industry.","B. The railroad had mostly negative effects.","C. The railroad connected the nation economically and geographically.","D. Most Americans moved to California."], answer:"C",
      explanation:"The passage emphasizes both geographic and economic impact." },
    { id:"R5", difficulty:"Medium", type:"Main Idea",
      passage:"In 1869, the Transcontinental Railroad let passengers travel coast-to-coast in about a week — versus months by wagon or ship. It accelerated westward settlement and created a national market for goods.",
      question:"What is the main idea of this passage?",
      choices:["A. The railroad was completed in 1869.","B. Travel to California was once slow.","C. The Transcontinental Railroad greatly changed American society and economy.","D. Thousands of families moved west."], answer:"C",
      explanation:"The passage's main idea is its sweeping national impact." },
    { id:"R6", difficulty:"Medium", type:"Vocabulary",
      passage:"In 1869, the Transcontinental Railroad let passengers travel coast-to-coast in about a week — versus months by wagon or ship. It accelerated westward settlement and created a national market for goods.",
      question:"As used in the passage, 'accelerated' most nearly means:",
      choices:["A. Slowed","B. Stopped","C. Sped up","D. Reversed"], answer:"C",
      explanation:"Accelerated means increased in speed or rate." },
    { id:"R7", difficulty:"Medium", type:"Comprehension",
      passage:"The printing press, invented by Gutenberg around 1440, let books be produced quickly and cheaply. Before it, books were copied by hand — making them rare and expensive. Literacy spread as ideas circulated freely.",
      question:"Before the printing press, why were books rare?",
      choices:["A. Paper hadn't been invented.","B. Books were copied by hand — slow and expensive.","C. Governments restricted production.","D. Most people couldn't read."], answer:"B",
      explanation:"The passage states books were 'copied by hand, making them rare and expensive.'" },
    { id:"R8", difficulty:"Hard",   type:"Inference",
      passage:"'Cognitive dissonance' (Festinger, 1957) describes the discomfort of holding two conflicting beliefs simultaneously. People resolve it by changing a belief, acquiring new information, or minimizing one conflict. Advertisers design messages that shift audiences toward resolving dissonance in a preferred direction.",
      question:"Why do advertisers use cognitive dissonance principles?",
      choices:["A. To confuse audiences so they buy more.","B. To guide audiences to resolve internal conflicts in ways that favor the advertiser.","C. To introduce psychology to the public.","D. To ensure audiences feel comfortable."], answer:"B",
      explanation:"The passage states advertisers shift audiences toward resolving dissonance 'in a preferred direction.'" },
    { id:"R9", difficulty:"Hard",   type:"Author's Purpose",
      passage:"'Cognitive dissonance' (Festinger, 1957) describes the discomfort of holding two conflicting beliefs simultaneously. People resolve it by changing a belief, acquiring new information, or minimizing one conflict. Advertisers design messages that shift audiences toward resolving dissonance in a preferred direction.",
      question:"The author ends with advertisers primarily to:",
      choices:["A. Criticize the ad industry.","B. Show the concept has real-world applications beyond psychology.","C. Prove dissonance is harmful.","D. Discourage readers from ads."], answer:"B",
      explanation:"The final sentence extends a psychological concept into practical application." },
    { id:"R10", difficulty:"Hard",  type:"Inference",
      passage:"Societies have long debated whether prosperity causes virtue or virtue causes prosperity. Ancient Greeks believed character preceded wealth. Later thinkers argued the reverse: material security frees people to pursue moral development, since desperate people rarely have the luxury of ethical deliberation.",
      question:"The phrase 'luxury of ethical deliberation' suggests:",
      choices:["A. Ethics is only for the wealthy.","B. People in desperate circumstances may lack time or resources for moral choices.","C. Ancient Greeks were wrong.","D. Ethical deliberation is unimportant."], answer:"B",
      explanation:"'Luxury' implies ethical deliberation requires conditions of security that desperate people may not have." },
  ],
  Mathematics: [
    { id:"M1", difficulty:"Easy",   type:"Arithmetic",
      question:"What is 15% of 200?",
      choices:["A. 25","B. 30","C. 35","D. 40"], answer:"B", explanation:"0.15 × 200 = 30." },
    { id:"M2", difficulty:"Easy",   type:"Arithmetic",
      question:"What is 3² + 4²?",
      choices:["A. 25","B. 49","C. 14","D. 7"], answer:"A", explanation:"9 + 16 = 25." },
    { id:"M3", difficulty:"Easy",   type:"Arithmetic",
      question:"What is the remainder when 47 is divided by 6?",
      choices:["A. 4","B. 5","C. 6","D. 3"], answer:"B", explanation:"47 ÷ 6 = 7 remainder 5." },
    { id:"M4", difficulty:"Medium", type:"Algebra",
      question:"If 4x − 5 = 19, what is x?",
      choices:["A. 5","B. 6","C. 7","D. 8"], answer:"B", explanation:"4x = 24 → x = 6." },
    { id:"M5", difficulty:"Medium", type:"Geometry",
      question:"A rectangle has length 12 and width 7. What is the area?",
      choices:["A. 38","B. 74","C. 84","D. 19"], answer:"C", explanation:"Area = 12 × 7 = 84." },
    { id:"M6", difficulty:"Medium", type:"Word Problem",
      question:"Maria drives 60 mph. How long to drive 210 miles?",
      choices:["A. 3 hours","B. 3.5 hours","C. 4 hours","D. 2.5 hours"], answer:"B", explanation:"210 ÷ 60 = 3.5 hours." },
    { id:"M7", difficulty:"Medium", type:"Percent",
      question:"A $120 jacket is 25% off. What is the sale price?",
      choices:["A. $85","B. $90","C. $95","D. $80"], answer:"B", explanation:"25% of 120 = 30; 120 − 30 = $90." },
    { id:"M8", difficulty:"Hard",   type:"Algebra",
      question:"The sum of two consecutive integers is 85. What is the larger integer?",
      choices:["A. 41","B. 42","C. 43","D. 44"], answer:"C", explanation:"n + (n+1) = 85 → n = 42. Larger = 43." },
    { id:"M9", difficulty:"Hard",   type:"Geometry",
      question:"A right triangle has legs 5 and 12. What is the hypotenuse?",
      choices:["A. 11","B. 13","C. 15","D. 17"], answer:"B", explanation:"c² = 25 + 144 = 169 → c = 13." },
    { id:"M10", difficulty:"Hard",  type:"Word Problem",
      question:"Pump A fills a pool in 6 hours; Pump B in 4 hours. Together, how long?",
      choices:["A. 2 hours","B. 2.4 hours","C. 3 hours","D. 5 hours"], answer:"B", explanation:"Combined rate: 1/6 + 1/4 = 5/12 per hour → 12/5 = 2.4 hours." },
  ],
  Language: [
    { id:"L1", difficulty:"Easy",   type:"Punctuation",
      question:"Which sentence uses punctuation correctly?",
      choices:["A. She went to the store, and bought milk.","B. She went to the store and bought milk.","C. She went to the store and, bought milk.","D. She went, to the store and bought milk."], answer:"B",
      explanation:"No comma before 'and' when joining two verbs with the same subject." },
    { id:"L2", difficulty:"Easy",   type:"Capitalization",
      question:"Which sentence is correctly capitalized?",
      choices:["A. We visited the grand canyon last Summer.","B. we visited the Grand Canyon last summer.","C. We visited the Grand Canyon last summer.","D. We visited The Grand Canyon last summer."], answer:"C",
      explanation:"Grand Canyon is a proper noun; 'summer' is not." },
    { id:"L3", difficulty:"Easy",   type:"Spelling",
      question:"Which word is spelled correctly?",
      choices:["A. Recieve","B. Recive","C. Receive","D. Receeve"], answer:"C",
      explanation:"R-E-C-E-I-V-E — 'i before e except after c.'" },
    { id:"L4", difficulty:"Medium", type:"Usage",
      question:"Choose the grammatically correct sentence.",
      choices:["A. Each of the students have completed their project.","B. Each of the students has completed their project.","C. Each of the students have completed his project.","D. Each of the students has completed their projects."], answer:"B",
      explanation:"'Each' is singular → 'has.'" },
    { id:"L5", difficulty:"Medium", type:"Punctuation",
      question:"Which sentence uses the apostrophe correctly?",
      choices:["A. The dog's bone is buried in the yard's.","B. The dogs bone is buried in the yard.","C. The dog's bone is buried in the yard.","D. The dogs' bone is buried in the yard."], answer:"C",
      explanation:"Dog's (singular possessive) is correct." },
    { id:"L6", difficulty:"Medium", type:"Composition",
      question:"Which sentence best fits as a topic sentence about exercise benefits?",
      choices:["A. Many people find exercise boring.","B. Running shoes come in many styles.","C. Regular exercise offers numerous physical and mental health benefits.","D. Some athletes train many hours per day."], answer:"C",
      explanation:"A topic sentence states the paragraph's main idea." },
    { id:"L7", difficulty:"Medium", type:"Usage",
      question:"Choose the correctly written sentence.",
      choices:["A. Between you and I, this is a great idea.","B. Between you and me, this is a great idea.","C. Between you and myself, this is a great idea.","D. Between I and you, this is a great idea."], answer:"B",
      explanation:"'Between' is a preposition requiring object pronouns. 'Me' is correct." },
    { id:"L8", difficulty:"Hard",   type:"Usage",
      question:"Choose the grammatically correct sentence.",
      choices:["A. Neither the coach nor the players was ready.","B. Neither the coach nor the players were ready.","C. Neither the coach nor the players is ready.","D. Neither the coach nor the players are ready."], answer:"B",
      explanation:"With 'neither…nor,' verb agrees with closer subject — 'players' (plural) → 'were.'" },
    { id:"L9", difficulty:"Hard",   type:"Punctuation",
      question:"Which sentence uses the semicolon correctly?",
      choices:["A. She studied hard; but she failed.","B. She studied hard; she passed with high marks.","C. She studied; hard and passed.","D. She; studied hard and passed."], answer:"B",
      explanation:"Semicolons join two independent clauses without a conjunction." },
    { id:"L10", difficulty:"Hard",  type:"Composition",
      question:"Which sentence contains a dangling modifier?",
      choices:["A. Running through the park, the dog chased the squirrel.","B. Running through the park, the squirrel was chased by Sarah.","C. Sarah chased the squirrel through the park.","D. The squirrel ran as Sarah chased it."], answer:"B",
      explanation:"In B, 'Running through the park' modifies 'squirrel' — but Sarah was running." },
  ],
}

const SECTIONS = ["Verbal", "Quantitative", "Reading", "Mathematics", "Language"]
const SECTION_COLORS: Record<string, string> = {
  Verbal:"#6366f1", Quantitative:"#0ea5e9", Reading:"#8b5cf6",
  Mathematics:"#f97316", Language:"#14b8a6",
}
const SECTION_ICONS: Record<string, string> = {
  Verbal:"🔤", Quantitative:"🔢", Reading:"📖", Mathematics:"➕", Language:"✏️",
}
const DIFF_COLORS: Record<string, string> = { Easy:"#22c55e", Medium:"#f59e0b", Hard:"#ef4444" }
const FULL_COLOR = "#818cf8"

// ─── QUESTION BUILDERS ────────────────────────────────────────────────────────

function shuffle<T>(arr: T[]): T[] {
  const a = [...arr]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]]
  }
  return a
}

function buildChallenge(sec: string): ChallengeQuestion[] {
  const pool   = ALL_QUESTIONS[sec]
  const easy   = shuffle(pool.filter(q => q.difficulty === "Easy")).slice(0, 3)
  const medium = shuffle(pool.filter(q => q.difficulty === "Medium")).slice(0, 4)
  const hard   = shuffle(pool.filter(q => q.difficulty === "Hard")).slice(0, 3)
  return shuffle([...easy, ...medium, ...hard]).map(q => ({ ...q, _section: sec }))
}

function buildMiniFullTest(): ChallengeQuestion[] {
  const result: ChallengeQuestion[] = []
  for (const sec of SECTIONS) {
    const pool   = ALL_QUESTIONS[sec]
    const easy   = shuffle(pool.filter(q => q.difficulty === "Easy"))
    const medium = shuffle(pool.filter(q => q.difficulty === "Medium"))
    const q1 = easy[0] ?? medium[0]
    const q2 = medium.find(q => q.id !== q1?.id) ?? shuffle(pool.filter(q => q.difficulty === "Hard"))[0]
    if (q1) result.push({ ...q1, _section: sec })
    if (q2) result.push({ ...q2, _section: sec })
  }
  return result
}

// ─── SHARED STYLES ────────────────────────────────────────────────────────────
const S = {
  root: {
    minHeight:"100vh", background:"#080c14", color:"#e2e8f0",
    fontFamily:"'Georgia','Times New Roman',serif",
    display:"flex", flexDirection:"column" as const, alignItems:"center", padding:"0 0 60px",
  },
  header: {
    width:"100%", textAlign:"center" as const, padding:"40px 24px 24px",
    background:"linear-gradient(180deg,#0d1424 0%,transparent 100%)",
  },
  eyebrow: { fontSize:11, letterSpacing:5, color:"#334155", textTransform:"uppercase" as const, marginBottom:10 },
  title: { fontSize:38, fontWeight:800, letterSpacing:"-1px", margin:"0 0 8px", color:"#f8fafc", textShadow:"0 0 40px rgba(99,102,241,0.4)" },
  sub: { fontSize:14, color:"#475569", margin:0, lineHeight:1.6 },
}

// ─── SVG WIDGETS ─────────────────────────────────────────────────────────────

function CircularTimer({ elapsed, maxDisplay, color }: { elapsed: number; maxDisplay: number; color: string }) {
  const size = 72, stroke = 5, r = (size - stroke) / 2
  const circ = 2 * Math.PI * r
  const dash  = circ * (1 - Math.min(elapsed / maxDisplay, 1))
  const danger = elapsed > maxDisplay * 0.8
  return (
    <svg width={size} height={size} style={{ transform:"rotate(-90deg)" }}>
      <circle cx={size/2} cy={size/2} r={r} fill="none" stroke="#1e293b" strokeWidth={stroke}/>
      <circle cx={size/2} cy={size/2} r={r} fill="none"
        stroke={danger ? "#ef4444" : color} strokeWidth={stroke}
        strokeDasharray={circ} strokeDashoffset={dash}
        style={{ transition:"stroke-dashoffset 0.5s linear, stroke 0.3s" }}/>
      <text x={size/2} y={size/2} textAnchor="middle" dominantBaseline="central"
        fill={danger ? "#ef4444" : "#e2e8f0"} fontSize={16} fontWeight={700}
        style={{ transform:`rotate(90deg)`, transformOrigin:`${size/2}px ${size/2}px`, fontFamily:"monospace" }}>
        {elapsed}s
      </text>
    </svg>
  )
}

function ScoreRing({ value, max, color, label }: { value: number; max: number; color: string; label: string }) {
  const size=90, stroke=6, r=(size-stroke)/2, circ=2*Math.PI*r
  return (
    <div style={{display:"flex",flexDirection:"column",alignItems:"center",gap:4}}>
      <svg width={size} height={size} style={{transform:"rotate(-90deg)"}}>
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke="#1e293b" strokeWidth={stroke}/>
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke={color} strokeWidth={stroke}
          strokeDasharray={circ} strokeDashoffset={circ*(1-Math.min(value/max,1))}
          style={{transition:"stroke-dashoffset 1s ease"}}/>
        <text x={size/2} y={size/2} textAnchor="middle" dominantBaseline="central"
          fill="#f1f5f9" fontSize={15} fontWeight={800}
          style={{transform:`rotate(90deg)`,transformOrigin:`${size/2}px ${size/2}px`,fontFamily:"monospace"}}>
          {Math.round(value)}
        </text>
      </svg>
      <span style={{fontSize:10,color:"#64748b",letterSpacing:1.5,textTransform:"uppercase"}}>{label}</span>
    </div>
  )
}

// ─── BADGE MODAL ─────────────────────────────────────────────────────────────
const RARITY_GLOW: Record<string, string> = {
  Common:"#6b7280", Uncommon:"#22c55e", Rare:"#818cf8",
  Epic:"#c084fc", Legendary:"#fbbf24", Mythic:"#e879f9",
}

function BadgeUnlockedModal({ badges, onDone }: { badges: Badge[]; onDone: () => void }) {
  const [idx, setIdx] = useState(0)
  const badge = badges[idx]
  const color = RARITY_GLOW[badge.rarity] ?? "#818cf8"
  return (
    <div style={{
      position:"fixed", inset:0, background:"rgba(0,0,0,0.88)",
      display:"flex", alignItems:"center", justifyContent:"center",
      zIndex:1000, padding:24,
    }}>
      <style>{`@keyframes popIn{from{opacity:0;transform:scale(0.9)}to{opacity:1;transform:scale(1)}}`}</style>
      <div style={{
        background:"#0d1424", border:`2px solid ${color}55`, borderRadius:24,
        padding:"40px 32px", maxWidth:420, width:"100%", textAlign:"center",
        boxShadow:`0 0 80px ${color}33`, animation:"popIn 0.35s ease",
      }}>
        <div style={{fontSize:11,letterSpacing:4,color,textTransform:"uppercase",marginBottom:16}}>
          🏅 New Badge Unlocked!
        </div>
        <div style={{fontSize:64,marginBottom:16,filter:`drop-shadow(0 0 20px ${color}88)`}}>
          {badge.emoji}
        </div>
        <div style={{fontSize:22,fontWeight:800,color:"#f1f5f9",marginBottom:4}}>{badge.name}</div>
        <div style={{fontSize:12,color,letterSpacing:2,marginBottom:8,textTransform:"uppercase"}}>{badge.creature}</div>
        <div style={{
          fontSize:12,color:"#64748b",marginBottom:16,padding:"3px 12px",
          display:"inline-block",background:color+"11",border:`1px solid ${color}22`,borderRadius:20,
        }}>{badge.rarity}</div>
        <div style={{
          fontSize:13,color:"#94a3b8",lineHeight:1.8,fontStyle:"italic",marginBottom:28,
          padding:"14px 16px",background:"#080c14",borderRadius:12,
          borderLeft:`3px solid ${color}55`,textAlign:"left",
        }}>
          {badge.lore}
        </div>
        {badges.length > 1 && (
          <div style={{fontSize:11,color:"#334155",marginBottom:12}}>{idx + 1} of {badges.length}</div>
        )}
        <button
          onClick={() => idx < badges.length - 1 ? setIdx(i => i + 1) : onDone()}
          style={{
            width:"100%",padding:"14px",borderRadius:12,border:"none",
            background:color,color:"#000",fontSize:15,fontWeight:700,
            cursor:"pointer",fontFamily:"inherit",
          }}
        >
          {idx < badges.length - 1 ? "Next Badge →" : "See Results →"}
        </button>
      </div>
    </div>
  )
}

// ─── PROPS ────────────────────────────────────────────────────────────────────
interface Props {
  displayName: string
  avatarColor: string
}

// ─── MAIN COMPONENT ───────────────────────────────────────────────────────────
export default function ChallengeClient({ displayName, avatarColor }: Props) {
  const firstName = displayName.split(' ')[0]
  const initial   = displayName[0]?.toUpperCase() ?? '?'

  const [phase, setPhase]      = useState<string>("lobby")
  const [lobbyMode, setLobby]  = useState<string | null>(null)
  const [section, setSection]  = useState<string | null>(null)
  const [questions, setQuestions] = useState<ChallengeQuestion[]>([])
  const [qIndex, setQIndex]    = useState(0)
  const [answers, setAnswers]  = useState<Record<string, string>>({})
  const [times, setTimes]      = useState<Record<string, number>>({})
  const [elapsed, setElapsed]  = useState(0)
  const [countdown, setCountdown] = useState(3)
  const [selected, setSelected]= useState<string | null>(null)
  const [newBadges, setNewBadges] = useState<Badge[]>([])
  const timerRef  = useRef<ReturnType<typeof setInterval> | null>(null)
  const startRef  = useRef<number>(Date.now())

  useEffect(() => {
    if (phase !== "quiz") return
    startRef.current = Date.now() - elapsed * 1000
    timerRef.current = setInterval(() => {
      setElapsed(Math.floor((Date.now() - startRef.current) / 1000))
    }, 200)
    return () => { if (timerRef.current) clearInterval(timerRef.current) }
  }, [phase, qIndex]) // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    if (phase === "quiz") { setElapsed(0); startRef.current = Date.now() }
  }, [qIndex, phase])

  useEffect(() => {
    if (phase !== "countdown") return
    if (countdown === 0) { setPhase("quiz"); return }
    const t = setTimeout(() => setCountdown(c => c - 1), 1000)
    return () => clearTimeout(t)
  }, [phase, countdown])

  const startChallenge = (sec: string) => {
    setSection(sec)
    setQuestions(sec === "Full" ? buildMiniFullTest() : buildChallenge(sec))
    setQIndex(0); setAnswers({}); setTimes({})
    setSelected(null); setElapsed(0); setCountdown(3)
    setNewBadges([])
    if (sec !== "Full") localStorage.setItem("hspt_last_section", sec)
    setPhase("countdown")
  }

  const finalizeChallenge = useCallback((
    finalAnswers: Record<string, string>,
    finalTimes: Record<string, number>,
    qs: ChallengeQuestion[],
    sec: string
  ) => {
    const scored = qs.map(q => {
      const qSec    = q._section ?? sec
      const idealSecs = IDEAL_TIME[qSec]?.[q.difficulty] ?? 30
      const taken   = finalTimes[q.id] ?? 0
      const correct = finalAnswers[q.id] === q.answer
      return { ...q, taken, correct, idealSecs, ...calcScore(correct, q.difficulty, taken, idealSecs) }
    })

    const correctCount = scored.filter(r => r.correct).length
    const totalBase    = scored.reduce((s, r) => s + r.base,     0)
    const totalIdeal   = scored.reduce((s, r) => s + r.idealSecs, 0)
    const totalTaken   = scored.reduce((s, r) => s + r.taken,    0)
    const maxBase      = 3*10 + 4*20 + 3*35

    const prev = loadStats()
    const completions = { ...prev.completions, [sec]: (prev.completions[sec] ?? 0) + 1 }
    const perfectSections = correctCount === qs.length && !prev.perfectSections.includes(sec)
      ? [...prev.perfectSections, sec] : prev.perfectSections
    const speedBadgeSections = totalTaken <= totalIdeal * 0.6 && !prev.speedBadgeSections.includes(sec)
      ? [...prev.speedBadgeSections, sec] : prev.speedBadgeSections
    const highScoreSections = totalBase >= maxBase * 0.8 && !prev.highScoreSections.includes(sec)
      ? [...prev.highScoreSections, sec] : prev.highScoreSections
    const totalCompletions = prev.totalCompletions + 1

    const updatedStats: BadgeStats = { earnedBadgeIds: prev.earnedBadgeIds, completions, perfectSections, speedBadgeSections, highScoreSections, totalCompletions }
    const newly = evaluateBadges(updatedStats)
    saveStats({ ...updatedStats, earnedBadgeIds: [...prev.earnedBadgeIds, ...newly.map(b => b.id)] })

    setNewBadges(newly)
    setPhase(newly.length > 0 ? "badge_modal" : "results")
  }, [])

  const submitAnswer = useCallback(() => {
    if (!selected) return
    if (timerRef.current) clearInterval(timerRef.current)
    const q = questions[qIndex]
    const nextAnswers = { ...answers, [q.id]: selected }
    const nextTimes   = { ...times,   [q.id]: elapsed  }
    setAnswers(nextAnswers)
    setTimes(nextTimes)
    setSelected(null)
    if (qIndex < questions.length - 1) {
      setQIndex(i => i + 1)
    } else {
      finalizeChallenge(nextAnswers, nextTimes, questions, section!)
    }
  }, [selected, qIndex, questions, elapsed, answers, times, section, finalizeChallenge])

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => { if (e.key === "Enter" && phase === "quiz" && selected) submitAnswer() }
    window.addEventListener("keydown", onKey)
    return () => window.removeEventListener("keydown", onKey)
  }, [submitAnswer, phase, selected])

  const scoredResults = questions.map(q => {
    const qSec    = q._section ?? section!
    const idealSecs = IDEAL_TIME[qSec]?.[q.difficulty] ?? 30
    const taken   = times[q.id] ?? 0
    const correct = answers[q.id] === q.answer
    return { ...q, chosen: answers[q.id], taken, correct, idealSecs, ...calcScore(correct, q.difficulty, taken, idealSecs) }
  })

  const totalScore  = scoredResults.reduce((s, r) => s + r.total, 0)
  const totalBase   = scoredResults.reduce((s, r) => s + r.base,  0)
  const totalBonus  = scoredResults.reduce((s, r) => s + r.bonus, 0)
  const correct     = scoredResults.filter(r => r.correct).length
  const isFullTest  = section === "Full"
  const sectionColor = isFullTest ? FULL_COLOR : (section ? SECTION_COLORS[section] : FULL_COLOR)
  const sectionIcon  = isFullTest ? "📋" : (section ? SECTION_ICONS[section] : "")

  // ─── LOBBY ─────────────────────────────────────────────────────────────────
  if (phase === "lobby") {
    const modeCardBase: React.CSSProperties = {
      background:"#0d1424", borderRadius:16, padding:"22px 24px",
      cursor:"pointer", textAlign:"left", border:"2px solid transparent",
      fontFamily:"inherit", transition:"all 0.2s", width:"100%",
    }
    return (
      <div style={S.root}>
        <div style={S.header}>
          <div style={S.eyebrow}>HSPT Prep</div>
          <h1 style={S.title}>Challenge Mode</h1>
        </div>

        <div style={{maxWidth:560, width:"100%", padding:"0 24px", display:"flex", flexDirection:"column", gap:16}}>

          <div style={{display:"flex", alignItems:"center", gap:12, justifyContent:"center", padding:"4px 0 8px"}}>
            <div style={{width:40,height:40,borderRadius:"50%",background:avatarColor,display:"flex",alignItems:"center",justifyContent:"center",color:"#fff",fontWeight:700,fontSize:16,flexShrink:0}}>
              {initial}
            </div>
            <span style={{fontSize:18, color:"#e2e8f0"}}>
              Welcome back, <strong style={{color:"#f1f5f9"}}>{firstName}</strong>
            </span>
          </div>

          <div style={{display:"flex", flexDirection:"column", gap:10}}>
            <div style={{fontSize:12, color:"#475569", letterSpacing:2, textTransform:"uppercase", marginBottom:2}}>
              Choose a mode
            </div>

            <button
              onClick={() => { setLobby(null); startChallenge("Full") }}
              style={{ ...modeCardBase, border:"2px solid #818cf833" }}
              onMouseEnter={e => { e.currentTarget.style.borderColor="#818cf877"; e.currentTarget.style.background="#818cf811" }}
              onMouseLeave={e => { e.currentTarget.style.borderColor="#818cf833"; e.currentTarget.style.background="#0d1424" }}
            >
              <div style={{fontSize:20, fontWeight:700, color:"#f1f5f9", marginBottom:6}}>
                📋  Mini Full Test
              </div>
              <div style={{fontSize:14, color:"#64748b", lineHeight:1.5}}>
                10 questions across all 5 sections (2 per section)<br/>
                <span style={{color:"#475569"}}>~6 min · Mixed difficulty</span>
              </div>
            </button>

            <button
              onClick={() => setLobby(m => m === "single_section" ? null : "single_section")}
              style={{
                ...modeCardBase,
                border:`2px solid ${lobbyMode === "single_section" ? "#6366f1" : "#6366f122"}`,
                background: lobbyMode === "single_section" ? "#6366f111" : "#0d1424",
              }}
              onMouseEnter={e => {
                if (lobbyMode !== "single_section") {
                  e.currentTarget.style.borderColor="#6366f166"
                  e.currentTarget.style.background="#6366f10d"
                }
              }}
              onMouseLeave={e => {
                if (lobbyMode !== "single_section") {
                  e.currentTarget.style.borderColor="#6366f122"
                  e.currentTarget.style.background="#0d1424"
                }
              }}
            >
              <div style={{fontSize:20, fontWeight:700, color:"#f1f5f9", marginBottom:6}}>
                🎯  Single Section
              </div>
              <div style={{fontSize:14, color:"#64748b", lineHeight:1.5}}>
                10 questions in one subject<br/>
                <span style={{color:"#475569"}}>3 Easy · 4 Medium · 3 Hard</span>
              </div>
            </button>
          </div>

          {lobbyMode === "single_section" && (
            <div style={{
              display:"flex", gap:10, overflowX:"auto", flexWrap:"nowrap",
              padding:"4px 2px", WebkitOverflowScrolling:"touch",
              scrollbarWidth:"none",
            }}>
              {SECTIONS.map(sec => (
                <button key={sec} onClick={() => startChallenge(sec)}
                  style={{
                    flexShrink:0, background:"#0d1424",
                    border:`2px solid ${SECTION_COLORS[sec]}44`,
                    borderRadius:12, padding:"14px 20px",
                    cursor:"pointer", fontFamily:"inherit",
                    display:"flex", flexDirection:"column", alignItems:"center", gap:6,
                    transition:"all 0.2s", minWidth:110,
                  }}
                  onMouseEnter={e => { e.currentTarget.style.background=SECTION_COLORS[sec]+"18"; e.currentTarget.style.borderColor=SECTION_COLORS[sec]+"99" }}
                  onMouseLeave={e => { e.currentTarget.style.background="#0d1424"; e.currentTarget.style.borderColor=SECTION_COLORS[sec]+"44" }}
                >
                  <span style={{fontSize:24}}>{SECTION_ICONS[sec]}</span>
                  <span style={{fontSize:16, fontWeight:600, color:"#f1f5f9", whiteSpace:"nowrap"}}>{sec}</span>
                </button>
              ))}
            </div>
          )}

          <div style={{background:"#0d1424", border:"1px solid #1e293b", borderRadius:14, padding:"18px 22px"}}>
            <div style={{fontSize:12, color:"#475569", letterSpacing:2, textTransform:"uppercase", marginBottom:12}}>
              How scoring works
            </div>
            <div style={{display:"grid", gridTemplateColumns:"1fr 1fr 1fr", gap:10, marginBottom:14}}>
              {["Easy","Medium","Hard"].map(d => (
                <div key={d} style={{background:"#080c14", borderRadius:10, padding:"12px 10px", textAlign:"center", border:`1px solid ${DIFF_COLORS[d]}33`}}>
                  <div style={{fontSize:10, color:DIFF_COLORS[d], fontWeight:700, letterSpacing:1, marginBottom:4}}>{d.toUpperCase()}</div>
                  <div style={{fontSize:22, fontWeight:800, color:"#f1f5f9", lineHeight:1}}>{DIFFICULTY_BASE_POINTS[d]}</div>
                  <div style={{fontSize:10, color:"#475569", marginTop:2}}>base pts</div>
                  <div style={{fontSize:10, color:"#64748b", marginTop:6}}>+{(DIFFICULTY_TIME_WEIGHT[d] ?? 1)*0.3}pt/sec saved</div>
                </div>
              ))}
            </div>
            <div style={{fontSize:12, color:"#475569", lineHeight:1.7, borderTop:"1px solid #1e293b", paddingTop:12}}>
              Wrong answers earn <strong style={{color:"#ef4444"}}>zero points</strong> — full review shown after all 10.
            </div>
          </div>
        </div>
      </div>
    )
  }

  // ─── COUNTDOWN ─────────────────────────────────────────────────────────────
  if (phase === "countdown") return (
    <div style={{...S.root, justifyContent:"center", alignItems:"center", gap:24}}>
      <div style={{fontSize:14, color:"#475569", letterSpacing:3, textTransform:"uppercase"}}>
        {sectionIcon} {isFullTest ? "Mini Full Test" : `${section} Challenge`}
      </div>
      <div style={{fontSize:120, fontWeight:900, color:sectionColor, lineHeight:1, textShadow:`0 0 60px ${sectionColor}88`, animation:"pulse 1s infinite"}}>
        {countdown || "GO!"}
      </div>
      <div style={{fontSize:14, color:"#334155"}}>{countdown > 0 ? "Get ready…" : "Start!"}</div>
      <style>{`@keyframes pulse{0%,100%{opacity:1}50%{opacity:0.6}}`}</style>
    </div>
  )

  // ─── QUIZ ──────────────────────────────────────────────────────────────────
  if (phase === "quiz") {
    const q = questions[qIndex]
    const maxDisplay = MAX_DISPLAY_TIME[q.difficulty] ?? 60
    return (
      <div style={S.root}>
        <div style={{width:"100%", maxWidth:640, padding:"24px 24px 0", display:"flex", alignItems:"center", gap:12}}>
          <div style={{flex:1}}>
            <div style={{display:"flex", justifyContent:"space-between", fontSize:11, color:"#475569", marginBottom:6}}>
              <span>{sectionIcon} {isFullTest ? `${q._section}` : section}</span>
              <span>{qIndex+1} / {questions.length}</span>
            </div>
            <div style={{height:4, background:"#1e293b", borderRadius:4, overflow:"hidden"}}>
              <div style={{height:"100%", background:sectionColor, width:`${(qIndex/questions.length)*100}%`, transition:"width 0.4s ease", borderRadius:4}}/>
            </div>
          </div>
          <CircularTimer elapsed={elapsed} maxDisplay={maxDisplay} color={sectionColor}/>
        </div>

        <div style={{maxWidth:640, width:"100%", padding:"20px 24px", display:"flex", flexDirection:"column", gap:14}}>
          <div style={{display:"flex", gap:8, alignItems:"center"}}>
            <span style={{padding:"3px 10px", borderRadius:20, fontSize:11, fontWeight:700, background:DIFF_COLORS[q.difficulty]+"22", color:DIFF_COLORS[q.difficulty]}}>{q.difficulty}</span>
            <span style={{fontSize:11, color:"#334155"}}>type: {q.type}</span>
          </div>

          {q.passage && (
            <div style={{background:"#0d1424", borderRadius:10, padding:"14px 16px", fontSize:13, lineHeight:1.75, color:"#94a3b8", borderLeft:`3px solid ${sectionColor}55`}}>
              {q.passage}
            </div>
          )}

          <div style={{fontSize:20, color:"#f1f5f9", lineHeight:1.6, fontWeight:600}}>
            {q.question}
          </div>

          <div style={{display:"flex", flexDirection:"column", gap:9}}>
            {q.choices.map(choice => {
              const letter = choice[0], isSelected = selected === letter
              return (
                <button key={letter} onClick={() => setSelected(letter)}
                  style={{
                    background: isSelected ? sectionColor+"22" : "#0d1424",
                    border:`2px solid ${isSelected ? sectionColor : "#1e293b"}`,
                    borderRadius:12, padding:"13px 18px", textAlign:"left",
                    cursor:"pointer", fontSize:16, color: isSelected ? "#f1f5f9" : "#94a3b8",
                    fontFamily:"inherit", transition:"all 0.15s", fontWeight: isSelected ? 600 : 400,
                  }}>
                  {choice}
                </button>
              )
            })}
          </div>

          <button onClick={submitAnswer} disabled={!selected}
            style={{
              padding:"14px", borderRadius:12, border:"none",
              background: selected ? sectionColor : "#1e293b",
              color: selected ? "#fff" : "#334155",
              fontSize:15, fontWeight:700, cursor: selected ? "pointer" : "default",
              fontFamily:"inherit", transition:"all 0.2s",
              boxShadow: selected ? `0 0 24px ${sectionColor}55` : "none",
            }}>
            {qIndex < questions.length - 1 ? "Lock In Answer →" : "Finish Challenge →"}
          </button>
          <div style={{fontSize:11, color:"#334155", textAlign:"center"}}>
            Press Enter to submit · Full review shown after all 10
          </div>
        </div>
      </div>
    )
  }

  // ─── BADGE MODAL ───────────────────────────────────────────────────────────
  if (phase === "badge_modal") return (
    <BadgeUnlockedModal badges={newBadges} onDone={() => setPhase("results")}/>
  )

  // ─── RESULTS ───────────────────────────────────────────────────────────────
  if (phase === "results") {
    const grade = correct>=9?"S":correct>=7?"A":correct>=5?"B":correct>=3?"C":"D"
    const gradeColor = ({S:"#fbbf24",A:"#22c55e",B:"#0ea5e9",C:"#f97316",D:"#ef4444"} as Record<string,string>)[grade]

    return (
      <div style={S.root}>
        <div style={{...S.header, paddingBottom:16}}>
          <div style={S.eyebrow}>{sectionIcon} {isFullTest ? "Mini Full Test" : `${section} Challenge`} · Complete</div>
          <div style={{display:"flex", alignItems:"center", justifyContent:"center", gap:10}}>
            <div style={{width:36,height:36,borderRadius:"50%",background:avatarColor,display:"flex",alignItems:"center",justifyContent:"center",color:"#fff",fontWeight:700,fontSize:14,flexShrink:0}}>
              {initial}
            </div>
            <h1 style={{...S.title, fontSize:28, color:sectionColor, margin:0}}>
              {firstName}&apos;s Results
            </h1>
          </div>
        </div>

        <div style={{maxWidth:640, width:"100%", padding:"0 24px", display:"flex", flexDirection:"column", gap:16}}>

          <div style={{background:"#0d1424", borderRadius:18, padding:"28px 24px", border:`1px solid ${sectionColor}33`, display:"flex", alignItems:"center", justifyContent:"space-around", flexWrap:"wrap", gap:20}}>
            <div style={{textAlign:"center"}}>
              <div style={{fontSize:72, fontWeight:900, color:gradeColor, lineHeight:1, textShadow:`0 0 40px ${gradeColor}88`}}>{grade}</div>
              <div style={{fontSize:11, color:"#475569", letterSpacing:2, marginTop:4}}>GRADE</div>
            </div>
            <ScoreRing value={totalScore} max={280} color={sectionColor} label="Total Score"/>
            <ScoreRing value={totalBase}  max={215} color="#22c55e"      label="Base Pts"/>
            <ScoreRing value={totalBonus} max={65}  color="#fbbf24"      label="Time Bonus"/>
            <div style={{textAlign:"center"}}>
              <div style={{fontSize:40, fontWeight:800, color:"#f1f5f9", lineHeight:1}}>
                {correct}<span style={{fontSize:20, color:"#475569"}}>/{questions.length}</span>
              </div>
              <div style={{fontSize:11, color:"#475569", letterSpacing:2, marginTop:4}}>CORRECT</div>
            </div>
          </div>

          {newBadges.length > 0 && (
            <div style={{background:"#0d1117", border:"1px solid #7c3aed44", borderRadius:14, padding:"14px 18px", display:"flex", gap:12, alignItems:"center", flexWrap:"wrap"}}>
              <span style={{fontSize:12, color:"#c084fc", fontWeight:700}}>🏅 Badges earned this run:</span>
              {newBadges.map(b => <span key={b.id} style={{fontSize:20}} title={b.name}>{b.emoji}</span>)}
            </div>
          )}

          <div style={{background:"#0d1424", borderRadius:14, border:"1px solid #1e293b", overflow:"hidden"}}>
            <div style={{padding:"12px 20px", borderBottom:"1px solid #1e293b", fontSize:11, color:"#475569", letterSpacing:2, textTransform:"uppercase"}}>
              Question Breakdown
            </div>
            {scoredResults.map((r, i) => {
              const over = r.taken > r.idealSecs
              const timeNote = r.timeSaved > 0 ? `+${r.timeSaved}s saved → +${r.bonus}pt` : over ? `${r.taken - r.idealSecs}s over` : "on pace"
              return (
                <div key={r.id} style={{padding:"14px 20px", borderBottom:i<scoredResults.length-1?"1px solid #0f172a":"none", display:"grid", gridTemplateColumns:"28px 70px 80px 1fr auto", gap:10, alignItems:"center"}}>
                  <span style={{fontSize:12, color:"#334155", fontWeight:700}}>Q{i+1}</span>
                  <span style={{padding:"2px 8px", borderRadius:20, fontSize:10, fontWeight:700, background:DIFF_COLORS[r.difficulty]+"22", color:DIFF_COLORS[r.difficulty], textAlign:"center"}}>{r.difficulty}</span>
                  <span style={{fontSize:12, fontWeight:700, color:r.correct?"#22c55e":"#ef4444"}}>{r.correct?"✓ Correct":"✗ Wrong"}</span>
                  <span style={{fontSize:11, color:r.timeSaved>0?"#fbbf24":over?"#f97316":"#475569"}}>{r.taken}s / {r.idealSecs}s · {timeNote}</span>
                  <span style={{fontSize:14, fontWeight:800, color:r.total>0?sectionColor:"#334155", minWidth:48, textAlign:"right"}}>{r.total>0?`+${r.total}`:"0"} pts</span>
                </div>
              )
            })}
          </div>

          <div style={{background:"#0d1424", borderRadius:14, border:"1px solid #1e293b", overflow:"hidden"}}>
            <div style={{padding:"12px 20px", borderBottom:"1px solid #1e293b", fontSize:11, color:"#475569", letterSpacing:2, textTransform:"uppercase"}}>
              Answer Review
            </div>
            {scoredResults.flatMap((r, i) => {
              const qSec = r._section ?? section!
              const secColor = SECTION_COLORS[qSec] ?? sectionColor
              const over = r.taken > r.idealSecs
              const delta = Math.abs(r.taken - r.idealSecs)
              const timingLabel = r.taken === r.idealSecs ? "on pace" : over ? `${delta}s over` : `${delta}s under`
              const timingColor = over ? "#f97316" : r.timeSaved > 0 ? "#fbbf24" : "#475569"
              const pacingNote = PACING_NOTES[qSec]?.[r.difficulty] ?? ""

              const items: React.ReactNode[] = []

              if (isFullTest && (i === 0 || r._section !== scoredResults[i-1]._section)) {
                items.push(
                  <div key={`div-${qSec}-${i}`} style={{padding:"8px 20px", background:"#080c14", borderBottom:"1px solid #1e293b", display:"flex", alignItems:"center", gap:8}}>
                    <span>{SECTION_ICONS[qSec]}</span>
                    <span style={{fontSize:11, fontWeight:700, color:secColor, letterSpacing:2, textTransform:"uppercase"}}>{qSec}</span>
                  </div>
                )
              }

              items.push(
                <div key={r.id} style={{padding:"18px 20px", borderBottom:i<scoredResults.length-1?"1px solid #0f172a":"none"}}>
                  <div style={{display:"flex", gap:8, alignItems:"center", marginBottom:10, flexWrap:"wrap"}}>
                    <span style={{fontSize:12, color:"#334155", fontWeight:700}}>Q{i+1}</span>
                    <span style={{padding:"2px 8px", borderRadius:20, fontSize:10, fontWeight:700, background:DIFF_COLORS[r.difficulty]+"22", color:DIFF_COLORS[r.difficulty]}}>{r.difficulty}</span>
                    <span style={{fontSize:11, color:"#475569"}}>{r.type}</span>
                  </div>

                  {r.passage && (
                    <div style={{fontSize:12, color:"#475569", lineHeight:1.65, marginBottom:10, padding:"10px 14px", background:"#080c14", borderRadius:8, borderLeft:`2px solid ${secColor}44`}}>
                      {r.passage}
                    </div>
                  )}

                  <div style={{fontSize:15, color:"#94a3b8", marginBottom:12, lineHeight:1.6}}>
                    {r.question}
                  </div>

                  <div style={{display:"flex", flexDirection:"column", gap:6}}>
                    {r.choices.map(choice => {
                      const letter = choice[0]
                      const isChosen  = r.chosen === letter
                      const isCorrect = r.answer === letter
                      let bg="#080c14", border="#1e293b", color="#475569"
                      if (isCorrect)       { bg="#16a34a18"; border="#22c55e"; color="#86efac" }
                      else if (isChosen)   { bg="#dc262618"; border="#ef4444"; color="#fca5a5" }
                      return (
                        <div key={letter} style={{background:bg, border:`1.5px solid ${border}`, color, borderRadius:8, padding:"9px 14px", fontSize:14, lineHeight:1.4, display:"flex", justifyContent:"space-between", alignItems:"center"}}>
                          <span>{choice}</span>
                          {isCorrect && <span style={{fontSize:10, color:"#22c55e", fontWeight:700, flexShrink:0, marginLeft:8}}>✓ CORRECT</span>}
                          {isChosen && !isCorrect && <span style={{fontSize:10, color:"#ef4444", fontWeight:700, flexShrink:0, marginLeft:8}}>✗ YOUR PICK</span>}
                        </div>
                      )
                    })}
                  </div>

                  <div style={{marginTop:10, fontSize:13, color:"#64748b", lineHeight:1.7, padding:"10px 14px", background:"#080c14", borderRadius:8, borderLeft:"3px solid #6366f1"}}>
                    <strong style={{color:"#818cf8"}}>Why:</strong> {r.explanation}
                  </div>

                  <div style={{marginTop:8, padding:"10px 14px", background:"#080c1499", borderRadius:8, border:"1px solid #1e293b"}}>
                    <div style={{display:"flex", gap:12, alignItems:"center", flexWrap:"wrap", marginBottom:pacingNote ? 6 : 0}}>
                      <span style={{fontSize:12, color:"#475569"}}>⏱ Ideal: <strong style={{color:"#94a3b8"}}>{r.idealSecs}s</strong></span>
                      <span style={{fontSize:10, color:"#334155"}}>·</span>
                      <span style={{fontSize:12, color:"#475569"}}>Your time: <strong style={{color:"#94a3b8"}}>{r.taken}s</strong></span>
                      <span style={{fontSize:10, color:"#334155"}}>·</span>
                      <span style={{fontSize:12, fontWeight:700, color:timingColor}}>{timingLabel}</span>
                    </div>
                    {pacingNote && (
                      <div style={{fontSize:12, color:"#475569", fontStyle:"italic", lineHeight:1.5}}>
                        &ldquo;{pacingNote}&rdquo;
                      </div>
                    )}
                  </div>
                </div>
              )

              return items
            })}
          </div>

          <div style={{display:"flex", gap:12, flexWrap:"wrap"}}>
            <button onClick={() => startChallenge(section!)}
              style={{flex:1, padding:"14px", borderRadius:12, border:"none", background:sectionColor, color:"#fff", fontSize:14, fontWeight:700, cursor:"pointer", fontFamily:"inherit", boxShadow:`0 0 24px ${sectionColor}55`}}>
              🔄 Retry {isFullTest ? "Full Test" : section}
            </button>
            <button onClick={() => { setPhase("lobby"); setSection(null); setLobby(null) }}
              style={{flex:1, padding:"14px", borderRadius:12, border:"1px solid #1e293b", background:"#0d1424", color:"#94a3b8", fontSize:14, fontWeight:600, cursor:"pointer", fontFamily:"inherit"}}>
              ← Choose Mode
            </button>
          </div>
        </div>
      </div>
    )
  }

  return null
}
