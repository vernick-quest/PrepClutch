import { isFrac, isPct } from '@/lib/math-facts'
import type { FactCard, Tok } from '@/lib/math-facts'

// Shared by Play and Learn so a card looks and types the same in both.

const SYMBOLS = new Set(['×', '÷', '='])
// 6 covers 0.375 and 37.5, and leaves room for four-digit mental math.
const MAX_CHARS = 6

/** The typed answer after one key. Keys: 0-9, '.', 'back'. */
export function typeKey(s: string, k: string): string {
  if (k === 'back') return s.slice(0, -1)
  if (s.length >= MAX_CHARS) return s
  if (k === '.') return s.includes('.') ? s : (s === '' ? '0.' : s + '.')
  return s === '0' ? k : s + k
}

/** The card's equation with its blank showing `blankText`. Fractions stack;
 *  a percent keeps its % sign tight against the number (or the blank). */
export function Equation({ card, blankText, done }: { card: FactCard; blankText: string; done: boolean }) {
  // Once answered the blank shows the right answer, so it is green.
  const color = done ? 'text-emerald-300 border-emerald-400/60' : 'text-amber-300 border-amber-400/60'
  // Underlined on its own; boxed inside a fraction, where an underline would
  // sit on the fraction bar and read as a second bar.
  const blank = (inFrac: boolean) => (
    <span className={`inline-block min-w-[1.4em] px-1 text-center ${
      inFrac ? 'border-[3px] rounded-lg py-0.5' : 'border-b-4 pb-1'
    } ${color}`}>{blankText}</span>
  )
  return (
    <div className="flex items-center gap-3 sm:gap-4 text-4xl sm:text-6xl font-black text-white tabular-nums">
      {card.parts.map((p, i) => <Token key={i} t={p} blank={blank} />)}
    </div>
  )
}

function Token({ t, blank }: { t: Tok; blank: (inFrac: boolean) => React.ReactNode }) {
  if (t === null) return <>{blank(false)}</>
  if (isPct(t)) {
    return <span className="whitespace-nowrap">{t.pct === null ? blank(false) : t.pct}<span className="text-zinc-400">%</span></span>
  }
  if (isFrac(t)) {
    return (
      <span className="inline-flex flex-col items-center leading-none text-[0.8em]">
        <span>{t.n === null ? blank(true) : t.n}</span>
        <span className="block w-full min-w-[1.2em] border-t-[3px] border-white/80 my-1.5" />
        <span>{t.d === null ? blank(true) : t.d}</span>
      </span>
    )
  }
  return <span className={typeof t === 'string' && SYMBOLS.has(t) ? 'text-zinc-500' : ''}>{t}</span>
}

/** 1-9, then . 0 ⌫, then a full-width ✓. Keys never take focus, so a
 *  keyboard Enter can't re-press the last key tapped. */
export function Keypad({ onPress, canSubmit, disabled = false, submitLabel = '✓' }: {
  onPress: (k: string) => void
  canSubmit: boolean
  disabled?: boolean
  submitLabel?: string
}) {
  return (
    <>
      <div className="grid grid-cols-3 gap-2 mt-1">
        {['1', '2', '3', '4', '5', '6', '7', '8', '9'].map(d => (
          <Key key={d} onClick={() => onPress(d)} disabled={disabled}>{d}</Key>
        ))}
        <Key onClick={() => onPress('.')} disabled={disabled}>.</Key>
        <Key onClick={() => onPress('0')} disabled={disabled}>0</Key>
        <Key onClick={() => onPress('back')} disabled={disabled} muted>⌫</Key>
      </div>
      <button
        onMouseDown={e => e.preventDefault()}
        onClick={() => onPress('enter')}
        disabled={disabled || !canSubmit}
        className="mt-2 h-[clamp(2.75rem,8dvh,3.5rem)] w-full rounded-2xl bg-amber-500 hover:bg-amber-400 disabled:opacity-40 text-black text-2xl font-black transition-colors"
      >
        {submitLabel}
      </button>
    </>
  )
}

function Key({ children, onClick, muted, disabled }: {
  children: React.ReactNode; onClick: () => void; muted?: boolean; disabled?: boolean
}) {
  return (
    <button
      onMouseDown={e => e.preventDefault()}
      onClick={onClick}
      disabled={disabled}
      className={`h-[clamp(2.75rem,9dvh,4rem)] rounded-2xl border text-2xl font-bold transition-colors active:scale-[0.97] disabled:opacity-40 ${
        muted ? 'bg-white/3 border-white/8 text-zinc-400 hover:bg-white/8'
              : 'bg-white/5 border-white/10 text-white hover:bg-white/10'
      }`}
    >
      {children}
    </button>
  )
}
