# Training content — reading. Four passages x three questions (easy, medium,
# hard) plus three standalone vocabulary items. Easies come first, so a student
# meets each passage once with a gentle question, then returns to it later
# with harder ones — spaced revisiting rather than three in a row.

BEES = """When a honeybee finds a good patch of flowers, she does not keep it to herself. She flies back to the hive and performs a dance on the wall of the honeycomb. In this "waggle dance," the bee runs in a straight line while shaking her body from side to side, then circles back and repeats the run.

The dance is a set of directions. The angle of the straight run tells the other bees which way to fly compared to the direction of the sun. The length of the run tells them how far away the flowers are: the longer the bee waggles, the farther the trip. Scientists who studied the dance were amazed that an insect could share such precise information without making a single sound."""

CANAL = """In 1817, the state of New York began digging a canal that many people thought was foolish. Critics called it "Clinton's Ditch," after Governor DeWitt Clinton, who championed the plan. The canal would stretch 363 miles, connecting the Hudson River at Albany to Lake Erie at Buffalo.

When the Erie Canal opened in 1825, the critics were proved wrong. Before the canal, moving goods overland from Buffalo to New York City could take weeks and cost a fortune. By boat, the trip became much faster, and the cost of shipping dropped by roughly ninety percent. Farm goods from the Midwest poured east, and New York City grew into the busiest port in the nation."""

TREES = """Every city should plant more trees along its streets. On a summer afternoon, a shaded sidewalk can be many degrees cooler than one in full sun, and trees cool the air around them as water evaporates from their leaves. That matters to anyone waiting for a bus in July.

Trees also soak up rainwater that would otherwise rush into storm drains and flood low streets. Some people argue that trees are too expensive to plant and care for. But a young tree costs far less than repairing a flooded road, and it keeps working for decades. A city that plants trees today is not spending money; it is saving it."""

OCTOPUS = """An octopus can change color in less than a second. Its skin holds thousands of tiny sacs of pigment called chromatophores, and each sac is ringed by muscles. When the muscles pull, the sac stretches wide and its color spreads across a patch of skin; when they relax, the sac shrinks to a dot too small to see.

Because these muscles are controlled by nerves, an octopus can reshape the patterns on its body almost instantly. It uses this skill to vanish against a rocky seafloor, to startle a predator with a sudden flash of dark color, or to signal to other octopuses. The same animal that can squeeze through a gap the size of a coin can also disappear in plain sight."""

VOCAB = "Choose the word that means the same as the capitalized word."

READING = [
  # ── Easy ──
  dict(sort=1, diff=1, concept="Vocabulary — word in a phrase",
    prompt=VOCAB + "\na RAPID river",
    options=[
      ("slow", "Slow is the OPPOSITE of rapid — the classic trap on a same-meaning question."),
      ("fast", "Correct. Rapid means moving quickly."),
      ("deep", "Deep describes a river, but it has nothing to do with speed."),
      ("cold", "Cold describes a river too, but not how fast it moves."),
    ], answer="fast",
    explanation="The short phrase gives context, but notice that several choices fit a river — rivers can be deep, cold, or fast. Only one matches the meaning of rapid itself. Do not pick a word just because it fits the noun; pick the one that means the same as the capitalized word."),

  dict(sort=2, diff=1, concept="Reading — finding a detail", passage=BEES,
    prompt="According to the passage, what does the LENGTH of the bee's straight run tell the other bees?",
    options=[
      ("which flowers smell the best", "The passage never mentions smell. The dance is about location, not which flowers are best."),
      ("how many bees should go", "The passage says nothing about how many bees go. It describes only direction and distance."),
      ("which way the sun is moving", "The sun appears as a reference point for DIRECTION, and direction comes from the angle of the run, not its length."),
      ("how far away the flowers are", "Correct. The passage says: the longer the bee waggles, the farther the trip."),
    ], answer="how far away the flowers are",
    explanation="Detail questions are answered by one specific sentence, so go find it. Search for the word 'length': the second paragraph says the length of the run tells them how far away the flowers are. Match your choice to the text — do not answer from what merely sounds reasonable."),

  dict(sort=3, diff=1, concept="Reading — finding a detail", passage=CANAL,
    prompt="According to the passage, the Erie Canal connected the Hudson River to",
    options=[
      ("the Atlantic Ocean", "The Atlantic is never mentioned. The canal ran inland, west from the Hudson."),
      ("New York City", "New York City benefited from the canal, but the canal's western end was at Lake Erie."),
      ("Lake Erie", "Correct. The passage says it connected the Hudson River at Albany to Lake Erie at Buffalo."),
      ("the Mississippi River", "The Mississippi does not appear in the passage at all."),
    ], answer="Lake Erie",
    explanation="Find the sentence that answers it directly: the canal would connect the Hudson River at Albany to Lake Erie at Buffalo. New York City is a trap — it is in the passage and it matters to the story, but it is not what the canal connected to."),

  dict(sort=4, diff=1, concept="Reading — finding a detail", passage=TREES,
    prompt="According to the passage, trees cool the air because",
    options=[
      ("their shade blocks the wind", "Shade blocks sunlight, not wind, and the passage never mentions wind."),
      ("water evaporates from their leaves", "Correct. The passage says trees cool the air around them as water evaporates from their leaves."),
      ("they soak up rainwater", "Soaking up rain is a real benefit in the passage, but it explains flood control, not cooling."),
      ("they grow taller in summer", "Growth is never mentioned."),
    ], answer="water evaporates from their leaves",
    explanation="The trickiest wrong answers are TRUE statements from a different part of the passage. Soaking up rainwater really is in the text — but it answers a different question. Always check that your choice answers the question asked, not just that it appears somewhere."),

  dict(sort=5, diff=1, concept="Reading — finding a detail", passage=OCTOPUS,
    prompt="According to the passage, what are chromatophores?",
    options=[
      ("tiny sacs of pigment in the skin", "Correct. The passage defines them as tiny sacs of pigment in the octopus's skin."),
      ("muscles that move the octopus's arms", "The muscles in the passage surround the pigment sacs; they do not move the arms."),
      ("nerves that control breathing", "Nerves are mentioned, but they control the muscles around the sacs, not breathing."),
      ("patterns on the seafloor", "The seafloor is where an octopus hides, not what a chromatophore is."),
    ], answer="tiny sacs of pigment in the skin",
    explanation="When a passage introduces a technical word, it almost always defines it in the same sentence — look for 'called' or a comma right after the new word. Here: tiny sacs of pigment called chromatophores. The other choices borrow real words from the passage but attach them to the wrong thing."),

  # ── Medium ──
  dict(sort=6, diff=2, concept="Vocabulary — word in a phrase",
    prompt=VOCAB + "\na CAUTIOUS driver",
    options=[
      ("careful", "Correct. A cautious driver takes care to avoid danger."),
      ("speedy", "Speedy is nearly the opposite — caution usually means slowing down."),
      ("skilled", "A driver can be skilled without being cautious. Skill is ability; caution is attitude."),
      ("nervous", "Nervous describes a feeling. A cautious driver may be perfectly calm — caution is about choices, not worry."),
    ], answer="careful",
    explanation="Cautious means careful to avoid danger. The hard part is the near-miss: nervous people are often cautious, so it feels close. But the question asks what the word MEANS, not who tends to act that way. A calm driver can be cautious, and a nervous one can be reckless."),

  dict(sort=7, diff=2, concept="Reading — main idea", passage=BEES,
    prompt="Which title best fits this passage?",
    options=[
      ("How Bees Make Honey", "Honey-making is never described. A title must cover what the passage is actually about."),
      ("A Dance That Gives Directions", "Correct. Both paragraphs build toward one idea: the waggle dance tells other bees where the flowers are."),
      ("Why Bees Fly Toward the Sun", "Bees do not fly toward the sun in the passage; the sun is only a reference for direction. This title misreads a detail."),
      ("The Scientists Who Studied Insects", "Scientists appear in one closing sentence. A title built on a small detail is too narrow."),
    ], answer="A Dance That Gives Directions",
    explanation="A good title covers the WHOLE passage, not one sentence of it. Ask what both paragraphs are about: the first describes the dance, the second explains what it communicates. Titles that fit only a single sentence — or no sentence — are too narrow or simply wrong."),

  dict(sort=8, diff=2, concept="Reading — word in context", passage=CANAL,
    prompt="In the passage, the word \"championed\" most nearly means",
    options=[
      ("defeated", "Defeating a plan is the opposite of what Clinton did — the canal was nicknamed after him because he backed it."),
      ("won a contest for", "This is the everyday meaning of champion, a sports winner. In this sentence the word is an action someone takes toward a plan."),
      ("questioned", "Questioning the plan is what the critics did, not Clinton."),
      ("strongly supported", "Correct. Clinton championed the plan, meaning he argued for it — which is why critics tied his name to it."),
    ], answer="strongly supported",
    explanation="When a familiar word appears in an unusual role, trust the sentence over your first association. Champion usually means a winner, but here it is something a governor does to a plan. The critics attached his name to the canal, so he must have been its leading supporter. Try each choice in the sentence and keep the one that makes sense."),

  dict(sort=9, diff=2, concept="Reading — main idea", passage=TREES,
    prompt="What is the author's main point?",
    options=[
      ("Trees are too expensive for most cities to care for.", "This is the objection the author raises in order to reject it. Mentioning an opposing view is not agreeing with it."),
      ("Waiting for a bus in summer is unpleasant.", "The bus stop is one example of why shade matters, not the point of the passage."),
      ("Cities should plant more street trees because they pay for themselves.", "Correct. The first sentence states the claim, and every paragraph supports it, ending with 'it is saving it.'"),
      ("Storm drains in most cities are poorly built.", "Storm drains appear only as part of the flooding argument."),
    ], answer="Cities should plant more street trees because they pay for themselves.",
    explanation="In a persuasive passage, the main point is the claim everything else supports — usually stated in the first or last sentence. Here the first says cities should plant more trees, and the last explains why it saves money. Be careful with opposing views: an author often mentions one only to answer it."),

  dict(sort=10, diff=2, concept="Reading — cause and effect", passage=OCTOPUS,
    prompt="According to the passage, why can an octopus change its patterns so quickly?",
    options=[
      ("Its skin is extremely thin.", "The thickness of the skin is never mentioned."),
      ("It can see every color around it.", "The passage says nothing about the octopus's eyesight."),
      ("It lives on rocky seafloors.", "The seafloor is where it hides, not what makes the change fast."),
      ("The muscles around its pigment sacs are controlled by nerves.", "Correct. The passage says: because these muscles are controlled by nerves, an octopus can reshape its patterns almost instantly."),
    ], answer="The muscles around its pigment sacs are controlled by nerves.",
    explanation="Cause-and-effect questions often have a signal word in the passage — because, so, as a result. Search for it: 'Because these muscles are controlled by nerves, an octopus can reshape the patterns on its body almost instantly.' The word 'because' points straight at the cause."),

  # ── Hard ──
  dict(sort=11, diff=3, concept="Vocabulary — word in a phrase",
    prompt=VOCAB + "\nan AUSTERE room",
    options=[
      ("luxurious", "Luxurious is the opposite — rich and comfortable. Austere means without comforts."),
      ("crowded", "Austere describes how a room is furnished, not how many people are in it."),
      ("plain and bare", "Correct. An austere room is simple and undecorated, with nothing extra."),
      ("brightly lit", "Lighting is not part of the word's meaning."),
    ], answer="plain and bare",
    explanation="Austere means severely simple — no decoration, no luxury. If you do not know it, notice that it sounds stern; words describing strictness often describe plainness too. Then eliminate what you can: luxurious is the opposite, and crowded and brightly lit describe other qualities of a room entirely."),

  dict(sort=12, diff=3, concept="Reading — inference", passage=BEES,
    prompt="The passage suggests that the scientists were surprised mainly because",
    options=[
      ("bees can see the sun from inside the hive", "The passage never raises whether bees can see the sun as the surprising part."),
      ("the bees' message was precise yet completely silent", "Correct. The last sentence says they were amazed an insect could share such precise information without a single sound — precise and silent together."),
      ("bees live together in large groups", "Living in hives is never presented as surprising."),
      ("flowers tend to grow in patches", "Flowers growing in patches is background, not a discovery."),
    ], answer="the bees' message was precise yet completely silent",
    explanation="Inference questions ask what the passage implies, but the proof is still in the text. The final sentence gives two reasons for the amazement: the information was precise, and it was shared without sound. The right answer must hold both ideas. Choices that are simply true about bees do not explain why the scientists were surprised."),

  dict(sort=13, diff=3, concept="Reading — author's purpose", passage=CANAL,
    prompt="The author mentions the nickname \"Clinton's Ditch\" mainly to",
    options=[
      ("explain how the canal got its official name", "The official name was the Erie Canal. The nickname was an insult, not a title."),
      ("prove that the governor was unpopular", "The nickname mocked the plan, not necessarily the man — and 'prove' is far too strong for a single nickname."),
      ("describe how the canal was dug", "The nickname says nothing about how it was built."),
      ("show that many people doubted the project at first", "Correct. Calling it a ditch mocked the project, and the next paragraph says the critics were proved wrong — the author sets up the doubt so the success lands harder."),
    ], answer="show that many people doubted the project at first",
    explanation="Purpose questions ask WHY the author included something. Look at what comes next: when the canal opened in 1825, the critics were proved wrong. The nickname sets up a doubt that the passage then overturns. Be suspicious of choices with strong words like 'prove' — authors rarely prove anything with one detail."),

  dict(sort=14, diff=3, concept="Reading — how an author argues", passage=TREES,
    prompt="How does the author respond to the argument that trees are too expensive?",
    options=[
      ("by comparing the cost of a tree to the cost of flood damage", "Correct. The author answers one cost with a bigger one: a young tree costs far less than repairing a flooded road."),
      ("by agreeing that most cities cannot afford them", "The author mentions the objection only to answer it — the very next word is 'But.'"),
      ("by listing the prices of different kinds of trees", "No prices appear anywhere in the passage."),
      ("by saying the argument is not worth discussing", "The author does discuss it, with a direct counter-argument."),
    ], answer="by comparing the cost of a tree to the cost of flood damage",
    explanation="When an author writes 'Some people argue...', watch for the 'But' that follows — that is where the author answers. Here the answer compares two costs: a tree now against flood repairs later. These questions test whether you can name the author's MOVE — compare, concede, or dismiss — not just repeat what was said."),

  dict(sort=15, diff=3, concept="Reading — drawing a conclusion", passage=OCTOPUS,
    prompt="Which conclusion is best supported by the passage?",
    options=[
      ("Octopuses change color only when they are frightened.", "'Only' is too strong. The passage also lists hiding and signaling to other octopuses."),
      ("All sea animals can change color quickly.", "The passage is about octopuses alone; 'all sea animals' goes far beyond it."),
      ("An octopus's color changes serve more than one purpose.", "Correct. The passage lists three uses: hiding against the seafloor, startling a predator, and signaling to other octopuses."),
      ("Octopuses cannot see their predators.", "Nothing about octopus eyesight appears in the passage."),
    ], answer="An octopus's color changes serve more than one purpose.",
    explanation="Supported conclusions stay close to the text. Absolute words — only, all, never — are red flags, because one counter-example breaks them. The passage names three different reasons for changing color, which supports 'more than one purpose' and breaks 'only when frightened.'"),
]
