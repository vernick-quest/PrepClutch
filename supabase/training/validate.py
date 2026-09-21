import re, sys, collections
sys.path.insert(0, __file__.rsplit('/', 1)[0])
from content_vq import VERBAL, QUANT
from content_reading import READING
from content_ml import MATH, LANGUAGE

SECTIONS = {'verbal': VERBAL, 'quantitative': QUANT, 'reading': READING,
            'math': MATH, 'language': LANGUAGE}
COMPUTED = {'quantitative', 'math'}     # every item here must carry a check

POSITIONAL = re.compile(r'\b(?:[Ss]entence|[Oo]ption|[Cc]hoice|[Aa]nswer)\s+[A-D]\b|\([A-D]\)')
NOTATION = [
  (re.compile(r'[0-9)]\s+x\s+[0-9(]'),              'x used as multiplication (use ×)'),
  (re.compile(r'[0-9)]\s+(?:squared|cubed)', re.I),  'spelled-out exponent (use ² ³)'),
  (re.compile(r'square root of [0-9]', re.I),        'spelled-out root (use √)'),
  (re.compile(r'[0-9)]\s+divided by\s+[0-9(]'),       '"divided by" between numbers (use ÷)'),
]

errors, report = [], []
def err(sec, q, msg): errors.append(f"  {sec} #{q.get('sort')}: {msg}")

for sec, qs in SECTIONS.items():
    # ── Section shape ──
    if len(qs) != 15: err(sec, {'sort': '-'}, f"{len(qs)} questions, expected 15")
    sorts = [q['sort'] for q in qs]
    if sorted(sorts) != list(range(1, 16)): err(sec, {'sort': '-'}, f"sort orders not 1..15: {sorted(sorts)}")
    diffs = collections.Counter(q['diff'] for q in qs)
    if diffs != {1: 5, 2: 5, 3: 5}: err(sec, {'sort': '-'}, f"difficulty mix {dict(diffs)}, expected 5/5/5")
    walk = [q['diff'] for q in sorted(qs, key=lambda q: q['sort'])]
    if walk != sorted(walk): err(sec, {'sort': '-'}, f"not easiest-first: {walk}")

    positions = collections.Counter()
    for q in qs:
        opts  = [o[0] for o in q['options']]
        notes = [o[1] for o in q['options']]
        if len(opts) != 4:                   err(sec, q, f"{len(opts)} options")
        if len(set(opts)) != len(opts):      err(sec, q, "duplicate option text")
        if any(not n.strip() for n in notes): err(sec, q, "blank note")
        if opts.count(q['answer']) != 1:      err(sec, q, f"answer {q['answer']!r} appears {opts.count(q['answer'])}x in options")
        else:
            ci = opts.index(q['answer'])
            positions[ci] += 1
            if not notes[ci].startswith('Correct.'):
                err(sec, q, "correct option's note does not start with 'Correct.'")
            for i, n in enumerate(notes):
                if i != ci and n.lower().startswith('correct'):
                    err(sec, q, f"WRONG option {opts[i]!r} has a note starting 'Correct'")
        if not q.get('concept'):              err(sec, q, "missing concept")
        if len(q['explanation']) < 120:       err(sec, q, f"explanation only {len(q['explanation'])} chars")

        # Computed answers must be recomputed, not trusted.
        if sec in COMPUTED and 'check' not in q: err(sec, q, "no check for a computed answer")
        if 'check' in q and not q['check']():   err(sec, q, "CHECK FAILED — answer does not recompute")

        # Positional references break the moment options are reordered.
        for label, text in [('explanation', q['explanation']), *[('note', n) for n in notes]]:
            if POSITIONAL.search(text): err(sec, q, f"positional reference in {label}: {POSITIONAL.search(text).group()!r}")
        for field in [q['prompt'], q['explanation'], *opts, *notes]:
            for rx, why in NOTATION:
                if rx.search(field): err(sec, q, f"notation — {why}: {rx.search(field).group()!r}")

        if sec == 'reading' and 'Vocabulary' not in q['concept'] and not q.get('passage'):
            err(sec, q, "reading question with no passage")

    report.append((sec, positions))

print("ANSWER POSITIONS (A/B/C/D) — the original bank put the key on B 46% of the time")
for sec, p in report:
    row = [p.get(i, 0) for i in range(4)]
    worst = max(row) / 15
    print(f"  {sec:13} {'  '.join(str(n) for n in row)}   max share {worst:.0%}  {'⚠️ skewed' if worst > 0.34 else 'ok'}")

total = sum(len(v) for v in SECTIONS.values())
print(f"\n{total} questions checked")
if errors:
    print(f"\n{len(errors)} PROBLEM(S):"); print("\n".join(errors)); sys.exit(1)
print("\nALL CHECKS PASS")
