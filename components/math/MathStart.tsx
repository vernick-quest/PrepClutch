import Link from 'next/link'
import { FACT_TABLES, deckHref } from '@/lib/math-facts'
import type { DeckOptions, Topic } from '@/lib/math-facts'

// One tap to play. Each tile starts a 20-card round; the deck builder already
// mixes classic and missing-number cards and serves what the student most
// needs, so there is nothing for them to configure.

export type TileId = 'mul' | 'div' | 'equiv' | 'fdp'
export type TileProgress = Record<TileId, { mastered: number; total: number }>

const BASE: DeckOptions = { topic: 'times', op: 'mixed', type: 'both', tables: [], focus: 'all' }

const TILES: { id: TileId; topic: Topic; emoji: string; title: string; opts: Partial<DeckOptions> }[] = [
  { id: 'mul',   topic: 'times', emoji: '×',  title: 'Multiplication',              opts: { op: 'mul' } },
  { id: 'div',   topic: 'times', emoji: '÷',  title: 'Division',                    opts: { op: 'div' } },
  { id: 'equiv', topic: 'equiv', emoji: '½',  title: 'Equivalent fractions',        opts: { topic: 'equiv' } },
  { id: 'fdp',   topic: 'fdp',   emoji: '%',  title: 'Fractions, decimals & percents', opts: { topic: 'fdp' } },
]

export default function MathStart({ topics, progress }: { topics: Topic[]; progress: TileProgress }) {
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        {TILES.filter(t => topics.includes(t.topic)).map(t => {
          const p = progress[t.id]
          const pct = p.total ? Math.round((p.mastered / p.total) * 100) : 0
          return (
            <Link
              key={t.id}
              href={deckHref({ ...BASE, ...t.opts })}
              className="group flex items-center gap-4 rounded-2xl border border-white/10 bg-white/3 hover:border-amber-500/50 hover:bg-amber-500/5 p-4 transition-all active:scale-[0.99]"
            >
              <span className="w-12 h-12 shrink-0 rounded-xl bg-white/5 flex items-center justify-center text-2xl font-black text-white">
                {t.emoji}
              </span>
              <span className="flex-1 min-w-0">
                <span className="block font-bold text-white leading-tight">{t.title}</span>
                <span className="block h-1.5 mt-2 rounded-full bg-white/10 overflow-hidden">
                  <span className="block h-full rounded-full bg-emerald-500" style={{ width: `${pct}%` }} />
                </span>
                <span className="block text-[11px] text-zinc-500 mt-1">{p.mastered} of {p.total} mastered</span>
              </span>
              <span className="shrink-0 w-10 h-10 rounded-full bg-amber-500 group-hover:bg-amber-400 text-black flex items-center justify-center text-lg font-black">
                ▶
              </span>
            </Link>
          )
        })}
      </div>

      {/* For "we're doing the 7s this week". Each number starts straight away. */}
      <div className="rounded-2xl border border-white/10 bg-white/3 p-4">
        <p className="text-sm font-bold text-white mb-2.5">Just one times table</p>
        <div className="grid grid-cols-6 sm:grid-cols-12 gap-1.5">
          {FACT_TABLES.map(n => (
            <Link
              key={n}
              href={deckHref({ ...BASE, op: 'mul', tables: [n] })}
              className="h-11 rounded-xl border border-white/10 bg-white/3 hover:border-amber-500/50 hover:bg-amber-500/10 flex items-center justify-center font-bold text-zinc-200 tabular-nums transition-colors"
            >
              {n}
            </Link>
          ))}
        </div>
      </div>
    </div>
  )
}
