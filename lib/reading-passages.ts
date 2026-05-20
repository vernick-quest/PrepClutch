// ── Reading Comprehension Data Layer ─────────────────────────────────────────
//
// JSON structure for passages and questions.
// Swap out SAMPLE_PASSAGES for DB-fetched data once content is ready.
//
// Difficulty distribution per 10-question section: 3 easy · 4 medium · 3 hard.
// Default layout across 3 passages: [E M H] [E M M H] [E M H]

export type QuestionType =
  | 'main_idea'
  | 'detail'
  | 'inference'
  | 'authors_purpose'
  | 'vocabulary'

export type PassageTopic = 'science' | 'social_studies' | 'humanities'

export interface ReadingQuestion {
  id: string
  text: string
  options: string[]          // always 4 options
  correctIndex: number       // 0-based
  difficulty: 1 | 2 | 3     // 1 = Easy, 2 = Medium, 3 = Hard
  type: QuestionType
  explanation: string
}

export interface ReadingPassage {
  id: string
  title: string
  body: string               // full passage text (may contain \n\n paragraph breaks)
  topic: PassageTopic
  questions: ReadingQuestion[]
}

// ── Sample passages ───────────────────────────────────────────────────────────
// 10 questions total: 3 easy · 4 medium · 3 hard
// Passage 1: 3Q  (E, M, H)
// Passage 2: 4Q  (E, M, M, H)
// Passage 3: 3Q  (E, M, H)

export const SAMPLE_PASSAGES: ReadingPassage[] = [
  {
    id: 'passage-bioluminescence',
    title: 'Life in the Deep Sea',
    topic: 'science',
    body: `Far below the ocean's surface, where sunlight cannot penetrate, lies a world of perpetual darkness. Yet this seemingly inhospitable environment supports an astonishing variety of life. Many deep-sea creatures have evolved the ability to produce their own light through a process called bioluminescence — a biological phenomenon powered by chemical reactions inside specialized cells known as photophores.

Scientists estimate that more than 75 percent of deep-sea animals are capable of bioluminescence. Some creatures use it to hunt: the anglerfish dangles a glowing lure to attract prey in the darkness. Others use it to communicate — the firefly squid can coordinate flashing patterns across its entire body to signal potential mates. The Hawaiian bobtail squid has developed a remarkable partnership with bioluminescent bacteria: the bacteria receive nutrients and a protected habitat inside the squid's body, while their glow allows the squid to blend in with the faint light filtering down from the surface, confusing predators lurking below.

Scientists believe we have explored only about five percent of the world's oceans. Every expedition reveals new species with extraordinary adaptations to crushing pressure, frigid temperatures, and total darkness. Researchers must use specially designed submersibles to collect data — data that continues to reshape our understanding of life on Earth and informs theories about the possibility of life in the subsurface oceans of Jupiter's moon Europa.`,
    questions: [
      {
        id: 'bio-q1',
        text: 'What is the main topic of this passage?',
        options: [
          'The hunting strategies of deep-sea predators',
          'Bioluminescence and life in the deep ocean',
          'The technology used to explore ocean depths',
          'The relationship between bacteria and squid',
        ],
        correctIndex: 1,
        difficulty: 1,
        type: 'main_idea',
        explanation:
          'The passage introduces bioluminescence and uses several examples of deep-sea creatures to explore life in the deep ocean. While hunting strategies and technology are mentioned, they support the broader topic rather than being the focus.',
      },
      {
        id: 'bio-q2',
        text: 'According to the passage, how does the Hawaiian bobtail squid benefit from its relationship with bioluminescent bacteria?',
        options: [
          'The bacteria protect the squid from predators by releasing toxic chemicals.',
          "The bacteria's glow helps the squid attract prey in the dark.",
          "The bacteria's glow helps the squid match faint surface light, confusing predators below.",
          'The bacteria provide the squid with essential nutrients.',
        ],
        correctIndex: 2,
        difficulty: 2,
        type: 'detail',
        explanation:
          "The passage states the bacteria's glow \"allows the squid to blend in with the faint light filtering down from the surface, confusing predators lurking below.\" It is the bacteria that receive nutrients from the squid — not the other way around.",
      },
      {
        id: 'bio-q3',
        text: 'Based on the passage, why might deep-sea research inform scientists about life on other planets?',
        options: [
          'Deep-sea creatures survive without oxygen, a condition common in outer space.',
          'Life thriving in extreme deep-sea conditions suggests it might exist in similarly harsh environments elsewhere.',
          'Deep-sea submersible technology could be directly adapted for space exploration.',
          'The chemical reactions in bioluminescence could power spacecraft.',
        ],
        correctIndex: 1,
        difficulty: 3,
        type: 'inference',
        explanation:
          "The passage notes that deep-sea data \"informs theories about the possibility of life in the subsurface oceans of Jupiter's moon Europa.\" The underlying inference is that life's ability to survive extreme conditions on Earth suggests it could do so in similar environments elsewhere.",
      },
    ],
  },

  {
    id: 'passage-silk-road',
    title: 'The Silk Road',
    topic: 'social_studies',
    body: `For more than a millennium, a web of trade routes stretching from China to the Mediterranean Sea connected civilizations that might otherwise have remained isolated. Known today as the Silk Road — a name coined by German geographer Ferdinand von Richthofen in 1877 — these routes carried far more than the precious fabric that gave them their name.

Merchants transported spices, glassware, paper, and metals along these paths. But perhaps the most significant cargo was invisible: ideas. Buddhism spread from India to China and Central Asia. Islam traveled eastward from Arabia. Mathematical concepts, astronomical knowledge, and medical techniques crossed borders alongside physical goods. The bubonic plague, which devastated fourteenth-century Europe, also traveled part of its deadly path along Silk Road corridors.

The Silk Road was not a single paved highway but a shifting network of paths across deserts, mountain passes, and grasslands. Camels were the preferred means of transport across the harsh terrain of Central Asia. Most merchants traveled only short segments, passing goods from one trading hub to the next — few undertook the entire journey. The Chinese city of Chang'an (present-day Xi'an) served as the eastern terminus, while Constantinople guarded the western gateway into Europe.

The Silk Road began to decline after the fifteenth century, when European maritime powers developed faster, cheaper ocean routes to Asia. Sea routes could carry greater volumes of goods more efficiently, and they eventually rendered the overland paths commercially obsolete — though the routes continued to see limited traffic well into the modern era.`,
    questions: [
      {
        id: 'silk-q1',
        text: 'According to the passage, what was the Silk Road?',
        options: [
          'A single paved road built by China to connect to Europe',
          'A network of trade routes linking China to the Mediterranean',
          'A sea route developed by European merchants in the fifteenth century',
          'A caravan system that transported only silk from China to Arabia',
        ],
        correctIndex: 1,
        difficulty: 1,
        type: 'detail',
        explanation:
          'The passage describes the Silk Road as "a web of trade routes stretching from China to the Mediterranean Sea" and later notes it was "not a single paved highway but a shifting network of paths."',
      },
      {
        id: 'silk-q2',
        text: 'Why did most merchants travel only short segments of the Silk Road rather than the entire route?',
        options: [
          'Governments along the route restricted travel beyond their borders.',
          'Goods were passed from one trading hub to the next rather than carried the whole distance.',
          'Camels could only survive in the desert portions of the route.',
          'Sea routes made the full overland journey unnecessary.',
        ],
        correctIndex: 1,
        difficulty: 2,
        type: 'inference',
        explanation:
          'The passage states that merchants passed "goods from one trading hub to the next — few undertook the entire journey." This describes a relay system, not government restrictions or limitations of camels.',
      },
      {
        id: 'silk-q3',
        text: "Why does the author mention the bubonic plague when describing the Silk Road's cargo?",
        options: [
          'To argue that the Silk Road caused more harm to civilization than good',
          'To show that the Silk Road transported dangerous goods alongside valuable ones',
          'To illustrate that the Silk Road carried more than trade goods — including disease',
          'To explain why the Silk Road eventually declined in the fifteenth century',
        ],
        correctIndex: 2,
        difficulty: 2,
        type: 'authors_purpose',
        explanation:
          'The plague is mentioned in the same paragraph as the spread of religions and knowledge — all listed as "invisible" cargo. The author uses it to reinforce that ideas, culture, and disease all traveled these routes, not just physical goods.',
      },
      {
        id: 'silk-q4',
        text: 'As used in the passage, the word "terminus" most nearly means:',
        options: [
          'A dangerous destination',
          'An endpoint or final stop on a route',
          'A major center of commercial activity',
          'A mountain pass through difficult terrain',
        ],
        correctIndex: 1,
        difficulty: 3,
        type: 'vocabulary',
        explanation:
          "\"Terminus\" derives from Latin meaning \"end\" or \"boundary.\" In context, Chang'an is the eastern terminus — the endpoint of the Silk Road on the eastern side, mirroring Constantinople on the western side.",
      },
    ],
  },

  {
    id: 'passage-observation',
    title: 'The Art of Observation',
    topic: 'humanities',
    body: `The naturalist who wishes to truly understand the world must first learn to see it. This sounds deceptively simple. We spend our lives surrounded by nature and assume we know it well — yet familiarity and understanding are not the same thing. We can recognize a sparrow without knowing its habits; we can name a flower without grasping its relationship to the insects that sustain it.

Real observation demands patience. It requires sitting with a subject long enough for it to begin to reveal itself. The amateur who spends twenty minutes at a pond and records five species has barely skimmed the surface. The naturalist who returns to that same pond across three seasons — through rain and frost and the heavy heat of summer — begins to perceive the intricate rhythms that govern that small world.

There is also the matter of record-keeping. The scientific notebook is not merely a place to store facts; it is a discipline of attention. Writing forces clarity. The act of rendering what we have seen into language exposes gaps in our observations and reveals assumptions we did not know we were making. Charles Darwin filled notebook after notebook not because he had discovered the answers, but because the act of recording helped him find the right questions to ask.`,
    questions: [
      {
        id: 'obs-q1',
        text: "What is the author's main argument in this passage?",
        options: [
          'Scientists should spend more time outdoors than in laboratories.',
          'True understanding of nature requires patience, sustained observation, and careful record-keeping.',
          "Charles Darwin's notebooks are a model that all scientists should follow.",
          'Familiarity with nature is more valuable than formal scientific training.',
        ],
        correctIndex: 1,
        difficulty: 1,
        type: 'main_idea',
        explanation:
          'All three paragraphs build toward a single argument: genuine understanding of nature requires more than casual familiarity. It takes patience in returning over time and the discipline of writing things down.',
      },
      {
        id: 'obs-q2',
        text: 'According to the passage, why is keeping a scientific notebook valuable?',
        options: [
          'It allows naturalists to share their findings with other scientists.',
          'It preserves rare observations that might otherwise be forgotten.',
          'The act of writing forces clarity and reveals gaps in observation.',
          'It provides proof that a naturalist has visited a particular location.',
        ],
        correctIndex: 2,
        difficulty: 2,
        type: 'detail',
        explanation:
          'The passage states that "writing forces clarity" and that recording what we\'ve seen "exposes gaps in our observations and reveals assumptions we did not know we were making."',
      },
      {
        id: 'obs-q3',
        text: 'What does the author most likely mean by stating that "familiarity and understanding are not the same thing"?',
        options: [
          'Scientists should avoid studying subjects they are already familiar with.',
          "Knowing a creature's name or appearance does not mean you understand how it lives and fits into its environment.",
          'Spending time in nature is less useful than reading about it in books.',
          'True understanding can only come through formal scientific education.',
        ],
        correctIndex: 1,
        difficulty: 3,
        type: 'inference',
        explanation:
          "The author immediately illustrates this with concrete examples: recognizing a sparrow without knowing its habits, naming a flower without grasping its ecological relationships. Familiarity is surface-level recognition; understanding is deeper knowledge of behavior and connection.",
      },
    ],
  },
]
