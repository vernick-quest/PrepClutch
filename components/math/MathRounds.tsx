import { parseFactKey } from '@/lib/math-facts'
import { formatAttemptTime } from '@/lib/constants'
import type { FactRound } from '@/lib/math-history'

// Recent Math Facts rounds. Each one opens to show every card: the equation,
// what was typed, how long it took, and whether it counted as mastered.
// <details> keeps this a server component with no client JS.

const DECK_LABEL: Record<string, string> = {
  mul: '× Multiplication', div: '÷ Division', times: '× ÷ Times tables',
  equiv: '½ Equivalent fractions', fdp: '% Fractions, decimals & percents',
}
function deckLabel(deck: string): string {
  const [base, table] = deck.split(':')
  const label = DECK_LABEL[base] ?? deck
  return table ? `${label} · ${table}s` : label
}

export default function MathRounds({ rounds, title = '📋 Recent rounds', empty = 'No rounds yet. Your results show up here after each one.' }: {
  rounds: FactRound[]
  title?: string
  empty?: string
}) {
  return (
    <div className="w-full rounded-2xl border border-white/10 bg-white/3 p-3 sm:p-4 min-w-0">
      <h3 className="font-bold text-white mb-3">{title}</h3>
      {rounds.length === 0 ? (
        <p className="text-sm text-zinc-500">{empty}</p>
      ) : (
        <div className="space-y-2">
          {rounds.map(r => {
            const pct = r.cards ? Math.round((r.correct / r.cards) * 100) : 0
            return (
              <details key={r.id} className="group min-w-0 rounded-xl border border-white/5 bg-white/2 open:bg-white/4">
                <summary className="flex items-center gap-3 p-3 cursor-pointer list-none [&::-webkit-details-marker]:hidden">
                  {/* w-0 + flex-1: fills the row but adds no minimum width, so a
                      long title is cut off instead of widening a phone page. */}
                  <div className="flex-1 w-0">
                    <p className="text-sm font-semibold text-white truncate">{deckLabel(r.deck)}</p>
                    <p className="text-[11px] text-zinc-500">{formatAttemptTime(r.completed_at)}</p>
                  </div>
                  <div className="text-right shrink-0">
                    <p className={`font-bold tabular-nums ${pct >= 80 ? 'text-emerald-400' : pct >= 60 ? 'text-amber-400' : 'text-rose-400'}`}>
                      {r.correct}/{r.cards}
                    </p>
                    <p className="text-[11px] text-zinc-500">⚡ {r.fast} fast{r.points > 0 ? ` · +${r.points}` : ''}</p>
                  </div>
                  <span className="text-zinc-600 text-xs group-open:rotate-90 transition-transform">▶</span>
                </summary>
                <div className="px-3 pb-3 grid grid-cols-1 gap-1 min-w-0">
                  {r.answers.map((a, i) => {
                    const card = parseFactKey(a.k)
                    const fast = a.c && card && a.ms <= card.targetMs
                    return (
                      <div key={i} className="flex items-center gap-2 text-xs font-mono min-w-0">
                        <span className={a.c ? (fast ? 'text-emerald-400' : 'text-amber-400') : 'text-rose-400'}>
                          {a.c ? (fast ? '⚡' : '✓') : '✗'}
                        </span>
                        <span className="flex-1 w-0 text-zinc-200 truncate">{card?.full ?? a.k}</span>
                        {!a.c && (
                          <span className="shrink-0 text-rose-300/80">{a.g === '-1' ? 'skipped' : `typed ${a.g}`}</span>
                        )}
                        <span className="shrink-0 text-zinc-500 tabular-nums w-10 text-right">{(a.ms / 1000).toFixed(1)}s</span>
                      </div>
                    )
                  })}
                </div>
              </details>
            )
          })}
        </div>
      )}
    </div>
  )
}
