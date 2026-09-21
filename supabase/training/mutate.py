# Positive controls. Each plants ONE fault and must be caught by ITS OWN
# expected message — "the validator failed" is not enough, because a stale
# bytecode cache once made one test report another test's fault.
import subprocess, sys, shutil, os

CLEAN = open('content_ml.py').read()

def run_with(patch, label, expect):
    patched = patch(CLEAN)
    assert patched != CLEAN, f"patch did not apply: {label}"      # a no-op patch proves nothing
    open('content_ml.py', 'w').write(patched)
    shutil.rmtree('__pycache__', ignore_errors=True)
    try:
        r = subprocess.run([sys.executable, '-B', 'validate.py'], capture_output=True, text=True,
                           env={**os.environ, 'PYTHONDONTWRITEBYTECODE': '1'})
        ok = expect in r.stdout
        print(f"  {'CAUGHT' if ok else 'MISSED'}  {label}\n          expected: {expect!r}")
        return ok
    finally:
        open('content_ml.py', 'w').write(CLEAN)

results = [
  run_with(lambda s: s.replace('], answer="18", check', '], answer="30", check', 1),
           "mis-keyed answer", "WRONG option '18' has a note starting 'Correct'"),
  run_with(lambda s: s.replace('180 / 3 * 5 == 300 and', '180 / 3 * 5 == 301 and', 1),
           "wrong arithmetic in a check", "CHECK FAILED"),
  run_with(lambda s: s.replace('Multiply first: 4 × 3 = 12.', 'Multiply first: 4 × 3 = 12, see Sentence B.', 1),
           "positional reference in a note", "positional reference in note: 'Sentence B'"),
  run_with(lambda s: s.replace('Multiply first: 4 × 3 = 12.', 'Multiply first: 4 x 3 = 12.', 1),
           "'x' as multiplication", "x used as multiplication"),
  run_with(lambda s: s.replace('dict(sort=1, diff=1, concept="Order of operations"',
                               'dict(sort=1, diff=2, concept="Order of operations"', 1),
           "difficulty mix broken", "expected 5/5/5"),
  run_with(lambda s: s.replace('"Correct. Multiply first', '"Multiply first', 1),
           "correct note missing its marker", "correct option's note does not start with 'Correct.'"),
]
assert open('content_ml.py').read() == CLEAN, "SOURCE NOT RESTORED"
print(f"\n{sum(results)}/{len(results)} planted faults caught by their own message; source restored byte-identical")
