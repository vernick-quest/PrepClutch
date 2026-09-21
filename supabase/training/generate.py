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

import base64
def b64(s):
    # Content travels as base64: letters, digits, + / = only. Supabase's SQL
    # editor rejected the plain-literal version with `relation "a" does not
    # exist` — English inside a string ("...ground; one is picked from a
    # tree") surfacing as SQL. Whatever its preprocessing does, it cannot
    # misread text that contains no quotes, semicolons, $ or -- at all.
    return "convert_from(decode('" + base64.b64encode(s.encode('utf-8')).decode() + "', 'base64'), 'UTF8')"

def b64json(v):
    return b64(json.dumps(v, ensure_ascii=False)) + '::JSONB'

rows, source = [], []
for sec, qs in SECTIONS:
    for q in sorted(qs, key=lambda q: q['sort']):
        opts  = [o[0] for o in q['options']]
        notes = [o[1] for o in q['options']]
        ci    = opts.index(q['answer'])
        key   = f"train-hspt-{sec}-{q['sort']:02d}"
        rows.append(
            f"({lit(key)}, {lit(sec)}, {q['sort']}, {b64(q['concept'])},\n"
            f" {b64(q['prompt'])},\n"
            f" {b64(q['passage']) if q.get('passage') else 'NULL::TEXT'},\n"
            f" {b64json(opts)}, {ci}, {q['diff']},\n"
            f" {b64(q['explanation'])},\n"
            f" {b64json(notes)})")
        source.append((key, q['prompt'], opts, notes, q['explanation'], q.get('passage')))

HEADER = open('header.sql').read()
FOOTER = open('footer.sql').read()
# Same fields, same order, same separators as the SQL checksum in footer.sql.
import hashlib
recs = []
for sec, qs in sorted(SECTIONS, key=lambda x: x[0]):
    for q in sorted(qs, key=lambda q: q['sort']):
        opts = [o[0] for o in q['options']]; notes = [o[1] for o in q['options']]
        # options::TEXT and option_notes::TEXT are Postgres's own JSONB rendering;
        # json.dumps with default separators matches it (proven against PGlite).
        recs.append('|'.join([q['concept'], q['prompt'], q.get('passage') or '',
                              json.dumps(opts, ensure_ascii=False), json.dumps(notes, ensure_ascii=False),
                              q['explanation'], str(opts.index(q['answer'])), str(q['diff'])]))
CHECKSUM = hashlib.md5('#'.join(recs).encode('utf-8')).hexdigest()
sql = HEADER + ",\n\n".join(rows) + FOOTER.replace('{{CHECKSUM}}', CHECKSUM)
open('060_training_bank.sql', 'w').write(sql)

# ── Round-trip: decode every base64 field back and compare with the source ──
B = r"convert_from\(decode\('([A-Za-z0-9+/=]*)', 'base64'\), 'UTF8'\)"
pat = re.compile(r"\('([a-z0-9-]+)', '([a-z]+)', (\d+), " + B + r",\n " + B + r",\n (NULL::TEXT|" + B + r"),\n "
                 + B + r"::JSONB, (\d), (\d),\n " + B + r",\n " + B + r"::JSONB\)")
dec = lambda s: base64.b64decode(s).decode('utf-8')
parsed = pat.findall(sql)
bad = 0
for m, (key, prompt, opts, notes, expl, passage) in zip(parsed, source):
    got = dict(key=m[0], prompt=dec(m[4]), passage=None if m[5] == 'NULL::TEXT' else dec(m[6]),
               opts=json.loads(dec(m[7])), expl=dec(m[10]), notes=json.loads(dec(m[11])))
    want = dict(key=key, prompt=prompt, passage=passage, opts=opts, expl=expl, notes=notes)
    for f in want:
        if got[f] != want[f]:
            bad += 1; print(f"  MISMATCH {key}.{f}")

# ── Nothing an editor could misread may remain inside any string literal ──
literals = re.findall(r"'((?:[^']|'')*)'", re.sub(r'--[^\n]*', '', sql))
risky = [l for l in literals if any(c in l for c in (';', '$')) or '--' in l]
print(f"string literals scanned: {len(literals)} | containing ; $ or --: {len(risky)}")
print(f"rows generated: {len(rows)} | parsed back: {len(parsed)} | round-trip mismatches: {bad}")
print(f"file: 060_training_bank.sql  {len(sql):,} bytes | content checksum {CHECKSUM}")
sys.exit(0 if len(parsed) == len(rows) == 75 and bad == 0 and not risky else 1)
