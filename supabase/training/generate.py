import json, re, sys
from content_vq import VERBAL, QUANT
from content_reading import READING
from content_ml import MATH, LANGUAGE

SECTIONS = [('verbal', VERBAL), ('quantitative', QUANT), ('reading', READING),
            ('math', MATH), ('language', LANGUAGE)]

def lit(s):            # SQL string literal; standard_conforming_strings is on
    return "'" + s.replace("'", "''") + "'"

def jlit(v):
    return lit(json.dumps(v, ensure_ascii=False)) + '::JSONB'

rows, source = [], []
for sec, qs in SECTIONS:
    for q in sorted(qs, key=lambda q: q['sort']):
        opts  = [o[0] for o in q['options']]
        notes = [o[1] for o in q['options']]
        ci    = opts.index(q['answer'])
        key   = f"train-hspt-{sec}-{q['sort']:02d}"
        rows.append(
            f"({lit(key)}, {lit(sec)}, {q['sort']}, {lit(q['concept'])},\n"
            f" {lit(q['prompt'])},\n"
            f" {lit(q['passage']) if q.get('passage') else 'NULL'},\n"
            f" {jlit(opts)}, {ci}, {q['diff']},\n"
            f" {lit(q['explanation'])},\n"
            f" {jlit(notes)})")
        source.append((key, q['prompt'], opts, notes, q['explanation'], q.get('passage')))

HEADER = open('header.sql').read()
FOOTER = open('footer.sql').read()
sql = HEADER + ",\n\n".join(rows) + FOOTER
open('060_training_bank.sql', 'w').write(sql)

# ── Round-trip: decode every literal back and compare with the source ────────
# Catches escaping mistakes (a stray quote, a mangled newline, a JSON escape)
# without needing a database to run the SQL against.
LIT = r"'((?:[^']|'')*)'"
pat = re.compile(r"\(" + LIT + r", " + LIT + r", (\d+), " + LIT + r",\n " + LIT + r",\n (NULL|" + LIT + r"),\n "
                 + LIT + r"::JSONB, (\d), (\d),\n " + LIT + r",\n " + LIT + r"::JSONB\)")
un = lambda s: s.replace("''", "'")
parsed = pat.findall(sql)
bad = 0
for m, (key, prompt, opts, notes, expl, passage) in zip(parsed, source):
    got = dict(key=un(m[0]), prompt=un(m[4]), passage=None if m[5] == 'NULL' else un(m[6]),
               opts=json.loads(un(m[7])), expl=un(m[10]), notes=json.loads(un(m[11])))
    want = dict(key=key, prompt=prompt, passage=passage, opts=opts, expl=expl, notes=notes)
    for f in want:
        if got[f] != want[f]:
            bad += 1; print(f"  MISMATCH {key}.{f}")
print(f"rows generated: {len(rows)} | parsed back: {len(parsed)} | round-trip mismatches: {bad}")
print(f"file: 060_training_bank.sql  {len(sql):,} bytes")
sys.exit(0 if len(parsed) == len(rows) == 75 and bad == 0 else 1)
