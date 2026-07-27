-- 014 — Adopt legacy reading questions + credit past attempts

-- ── 1. Adopt the 10 questions from the retired hardcoded reading flow ────────
WITH p(pkey, body) AS (VALUES
  ('bio', 'Far below the ocean''s surface, where sunlight cannot penetrate, lies a world of perpetual darkness. Yet this seemingly inhospitable environment supports an astonishing variety of life. Many deep-sea creatures have evolved the ability to produce their own light through a process called bioluminescence — a biological phenomenon powered by chemical reactions inside specialized cells known as photophores. Scientists estimate that more than 75 percent of deep-sea animals are capable of bioluminescence. Some creatures use it to hunt: the anglerfish dangles a glowing lure to attract prey in the darkness. Others use it to communicate — the firefly squid can coordinate flashing patterns across its entire body to signal potential mates. The Hawaiian bobtail squid has developed a remarkable partnership with bioluminescent bacteria: the bacteria receive nutrients and a protected habitat inside the squid''s body, while their glow allows the squid to blend in with the faint light filtering down from the surface, confusing predators lurking below. Scientists believe we have explored only about five percent of the world''s oceans. Every expedition reveals new species with extraordinary adaptations to crushing pressure, frigid temperatures, and total darkness. Researchers must use specially designed submersibles to collect data — data that continues to reshape our understanding of life on Earth and informs theories about the possibility of life in the subsurface oceans of Jupiter''s moon Europa.'),
  ('silk', 'For more than a millennium, a web of trade routes stretching from China to the Mediterranean Sea connected civilizations that might otherwise have remained isolated. Known today as the Silk Road — a name coined by German geographer Ferdinand von Richthofen in 1877 — these routes carried far more than the precious fabric that gave them their name. Merchants transported spices, glassware, paper, and metals along these paths. But perhaps the most significant cargo was invisible: ideas. Buddhism spread from India to China and Central Asia. Islam traveled eastward from Arabia. Mathematical concepts, astronomical knowledge, and medical techniques crossed borders alongside physical goods. The bubonic plague, which devastated fourteenth-century Europe, also traveled part of its deadly path along Silk Road corridors. The Silk Road was not a single paved highway but a shifting network of paths across deserts, mountain passes, and grasslands. Camels were the preferred means of transport across the harsh terrain of Central Asia. Most merchants traveled only short segments, passing goods from one trading hub to the next — few undertook the entire journey. The Chinese city of Chang''an (present-day Xi''an) served as the eastern terminus, while Constantinople guarded the western gateway into Europe. The Silk Road began to decline after the fifteenth century, when European maritime powers developed faster, cheaper ocean routes to Asia. Sea routes could carry greater volumes of goods more efficiently, and they eventually rendered the overland paths commercially obsolete — though the routes continued to see limited traffic well into the modern era.'),
  ('obs', 'The naturalist who wishes to truly understand the world must first learn to see it. This sounds deceptively simple. We spend our lives surrounded by nature and assume we know it well — yet familiarity and understanding are not the same thing. We can recognize a sparrow without knowing its habits; we can name a flower without grasping its relationship to the insects that sustain it. Real observation demands patience. It requires sitting with a subject long enough for it to begin to reveal itself. The amateur who spends twenty minutes at a pond and records five species has barely skimmed the surface. The naturalist who returns to that same pond across three seasons — through rain and frost and the heavy heat of summer — begins to perceive the intricate rhythms that govern that small world. There is also the matter of record-keeping. The scientific notebook is not merely a place to store facts; it is a discipline of attention. Writing forces clarity. The act of rendering what we have seen into language exposes gaps in our observations and reveals assumptions we did not know we were making. Charles Darwin filled notebook after notebook not because he had discovered the answers, but because the act of recording helped him find the right questions to ask.')
),
q(legacy_id, pkey, prompt, options, correct_index, difficulty, explanation) AS (VALUES
  ('bio-q1', 'bio', 'What is the main topic of this passage?', '["The hunting strategies of deep-sea predators","Bioluminescence and life in the deep ocean","The technology used to explore ocean depths","The relationship between bacteria and squid"]'::JSONB, 1, 1, 'The passage introduces bioluminescence and uses several examples of deep-sea creatures to explore life in the deep ocean. While hunting strategies and technology are mentioned, they support the broader topic rather than being the focus.'),
  ('bio-q2', 'bio', 'According to the passage, how does the Hawaiian bobtail squid benefit from its relationship with bioluminescent bacteria?', '["The bacteria protect the squid from predators by releasing toxic chemicals.","The bacteria''s glow helps the squid attract prey in the dark.","The bacteria''s glow helps the squid match faint surface light, confusing predators below.","The bacteria provide the squid with essential nutrients."]'::JSONB, 2, 2, 'The passage states the bacteria''s glow "allows the squid to blend in with the faint light filtering down from the surface, confusing predators lurking below." It is the bacteria that receive nutrients from the squid — not the other way around.'),
  ('bio-q3', 'bio', 'Based on the passage, why might deep-sea research inform scientists about life on other planets?', '["Deep-sea creatures survive without oxygen, a condition common in outer space.","Life thriving in extreme deep-sea conditions suggests it might exist in similarly harsh environments elsewhere.","Deep-sea submersible technology could be directly adapted for space exploration.","The chemical reactions in bioluminescence could power spacecraft."]'::JSONB, 1, 3, 'The passage notes that deep-sea data "informs theories about the possibility of life in the subsurface oceans of Jupiter''s moon Europa." The underlying inference is that life''s ability to survive extreme conditions on Earth suggests it could do so in similar environments elsewhere.'),
  ('silk-q1', 'silk', 'According to the passage, what was the Silk Road?', '["A single paved road built by China to connect to Europe","A network of trade routes linking China to the Mediterranean","A sea route developed by European merchants in the fifteenth century","A caravan system that transported only silk from China to Arabia"]'::JSONB, 1, 1, 'The passage describes the Silk Road as "a web of trade routes stretching from China to the Mediterranean Sea" and later notes it was "not a single paved highway but a shifting network of paths."'),
  ('silk-q2', 'silk', 'Why did most merchants travel only short segments of the Silk Road rather than the entire route?', '["Governments along the route restricted travel beyond their borders.","Goods were passed from one trading hub to the next rather than carried the whole distance.","Camels could only survive in the desert portions of the route.","Sea routes made the full overland journey unnecessary."]'::JSONB, 1, 2, 'The passage states that merchants passed "goods from one trading hub to the next — few undertook the entire journey." This describes a relay system, not government restrictions or limitations of camels.'),
  ('silk-q3', 'silk', 'Why does the author mention the bubonic plague when describing the Silk Road''s cargo?', '["To argue that the Silk Road caused more harm to civilization than good","To show that the Silk Road transported dangerous goods alongside valuable ones","To illustrate that the Silk Road carried more than trade goods — including disease","To explain why the Silk Road eventually declined in the fifteenth century"]'::JSONB, 2, 2, 'The plague is mentioned in the same paragraph as the spread of religions and knowledge — all listed as "invisible" cargo. The author uses it to reinforce that ideas, culture, and disease all traveled these routes, not just physical goods.'),
  ('silk-q4', 'silk', 'As used in the passage, the word "terminus" most nearly means:', '["A dangerous destination","An endpoint or final stop on a route","A major center of commercial activity","A mountain pass through difficult terrain"]'::JSONB, 1, 3, '"Terminus" derives from Latin meaning "end" or "boundary." In context, Chang''an is the eastern terminus — the endpoint of the Silk Road on the eastern side, mirroring Constantinople on the western side.'),
  ('obs-q1', 'obs', 'What is the author''s main argument in this passage?', '["Scientists should spend more time outdoors than in laboratories.","True understanding of nature requires patience, sustained observation, and careful record-keeping.","Charles Darwin''s notebooks are a model that all scientists should follow.","Familiarity with nature is more valuable than formal scientific training."]'::JSONB, 1, 1, 'All three paragraphs build toward a single argument: genuine understanding of nature requires more than casual familiarity. It takes patience in returning over time and the discipline of writing things down.'),
  ('obs-q2', 'obs', 'According to the passage, why is keeping a scientific notebook valuable?', '["It allows naturalists to share their findings with other scientists.","It preserves rare observations that might otherwise be forgotten.","The act of writing forces clarity and reveals gaps in observation.","It provides proof that a naturalist has visited a particular location."]'::JSONB, 2, 2, 'The passage states that "writing forces clarity" and that recording what we''ve seen "exposes gaps in our observations and reveals assumptions we did not know we were making."'),
  ('obs-q3', 'obs', 'What does the author most likely mean by stating that "familiarity and understanding are not the same thing"?', '["Scientists should avoid studying subjects they are already familiar with.","Knowing a creature''s name or appearance does not mean you understand how it lives and fits into its environment.","Spending time in nature is less useful than reading about it in books.","True understanding can only come through formal scientific education."]'::JSONB, 1, 3, 'The author immediately illustrates this with concrete examples: recognizing a sparrow without knowing its habits, naming a flower without grasping its ecological relationships. Familiarity is surface-level recognition; understanding is deeper knowledge of behavior and connection.')
)
INSERT INTO questions (id, section, passage, prompt, options, correct_index, difficulty, explanation)
SELECT md5(q.legacy_id)::UUID, 'reading'::section_type, p.body,
       q.prompt, q.options, q.correct_index, q.difficulty, q.explanation
FROM q JOIN p ON p.pkey = q.pkey
ON CONFLICT (id) DO NOTHING;

-- ── 2. Group them into passages ─────────────────────────────────────────────
DO $$
DECLARE rec RECORD; new_id UUID;
BEGIN
  FOR rec IN SELECT DISTINCT passage FROM questions
             WHERE passage IS NOT NULL AND passage_id IS NULL LOOP
    SELECT passage_id INTO new_id FROM questions
      WHERE passage = rec.passage AND passage_id IS NOT NULL LIMIT 1;
    IF new_id IS NULL THEN new_id := gen_random_uuid(); END IF;
    UPDATE questions SET passage_id = new_id
      WHERE passage = rec.passage AND passage_id IS NULL;
  END LOOP;
END $$;

-- ── 3. Credit past attempts that used the legacy string ids ─────────────────
INSERT INTO user_question_history AS uqh
  (user_id, question_id, last_answered_at, times_seen, times_correct, times_wrong)
SELECT qa.user_id,
       md5(ans->>'question_id')::UUID,
       MAX(COALESCE(qa.completed_at, qa.started_at)),
       COUNT(*)::INT,
       COUNT(*) FILTER (WHERE (ans->>'selected_index')::INT = (ans->>'correct_index')::INT)::INT,
       COUNT(*) FILTER (WHERE (ans->>'selected_index')::INT IS DISTINCT FROM (ans->>'correct_index')::INT)::INT
FROM quiz_attempts qa
CROSS JOIN LATERAL jsonb_array_elements(
  CASE WHEN jsonb_typeof(qa.answers) = 'array' THEN qa.answers ELSE '[]'::JSONB END
) AS ans
WHERE ans->>'question_id' IN ('bio-q1','bio-q2','bio-q3','silk-q1','silk-q2',
                              'silk-q3','silk-q4','obs-q1','obs-q2','obs-q3')
  AND ans->>'selected_index' ~ '^-?[0-9]+$'
  AND ans->>'correct_index'  ~ '^-?[0-9]+$'
  AND EXISTS (SELECT 1 FROM questions x WHERE x.id = md5(ans->>'question_id')::UUID)
GROUP BY qa.user_id, md5(ans->>'question_id')::UUID
ON CONFLICT (user_id, question_id) DO UPDATE SET
  times_seen       = GREATEST(uqh.times_seen,       EXCLUDED.times_seen),
  times_correct    = GREATEST(uqh.times_correct,    EXCLUDED.times_correct),
  times_wrong      = GREATEST(uqh.times_wrong,      EXCLUDED.times_wrong),
  last_answered_at = GREATEST(uqh.last_answered_at, EXCLUDED.last_answered_at);

-- ── 4. Proof it worked ──────────────────────────────────────────────────────
SELECT 'adopted questions (expect 10)' AS check, COUNT(*)::TEXT AS value
  FROM questions WHERE id IN (SELECT md5(x)::UUID FROM unnest(ARRAY['bio-q1','bio-q2',
    'bio-q3','silk-q1','silk-q2','silk-q3','silk-q4','obs-q1','obs-q2','obs-q3']) x)
UNION ALL
SELECT 'history rows for them', COUNT(*)::TEXT FROM user_question_history
  WHERE question_id IN (SELECT md5(x)::UUID FROM unnest(ARRAY['bio-q1','bio-q2',
    'bio-q3','silk-q1','silk-q2','silk-q3','silk-q4','obs-q1','obs-q2','obs-q3']) x)
UNION ALL
SELECT 'MasterClass reading score', m.score::TEXT
  FROM get_section_mastery('4e52247e-2b70-4eb3-8c30-fd614db886c3') m WHERE m.section='reading'
UNION ALL
SELECT 'TungTung reading score', m.score::TEXT
  FROM get_section_mastery('8dcf1730-c6b5-4c01-9bdc-f462d21c83a9') m WHERE m.section='reading';
