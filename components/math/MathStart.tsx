import Link from 'next/link'
import { deckHref } from '@/lib/math-facts'
import type { DeckOptions, Topic, FactHistoryRow } from '@/lib/math-facts'
import { mapCells, cellTone, MINI_CLASS } from '@/components/math/cells'
import type { MapTab } from '@/components/math/cells'

// One tap to play. Each tile starts a 10-card round; the deck builder already
// mixes classic and missing-number cards and serves what the student most
// needs, so there is nothing to configure. Each tile carries a thumbnail of
// its own fact map, the same picture as the full map below in the same
// colours, so the two read as one thing.

const BASE: DeckOptions = { topic: 'times', op: 'mixed', type: 'both', tables: [], focus: 'all' }

const TILES: { id: MapTab; topic: Topic; symbol: string; title: string; opts: Partial<DeckOptions>; px: number }[] = [
  { id: 'mul',   topic: 'times', symbol: '×', title: 'Multiplication',                 opts: { op: 'mul' },        px: 4 },
  { id: 'div',   topic: 'times', symbol: '÷', title: 'Division',                       opts: { op: 'div' },        px: 4 },
  { id: 'equiv', topic: 'equiv', symbol: '½', title: 'Equivalent fractions',           opts: { topic: 'equiv' },   px: 5 },
  { id: 'fdp',   topic: 'fdp',   symbol: '%', title: 'Fractions, decimals & percents', opts: { topic: 'fdp' },     px: 5 },
]

function MiniMap({ cells, px }: { cells: ReturnType<typeof mapCells>; px: number }) {
  return (
    <div
      className="grid gap-px"
      style={{ gridTemplateColumns: `repeat(${cells[0].length}, ${px}px)`, gridAutoRows: `${px}px` }}
      aria-hidden
    >
      {cells.flat().map((states, i) => (
        <span key={i} className={`rounded-[1px] ${MINI_CLASS[cellTone(states)]}`} />
      ))}
    </div>
  )
}

export default function MathStart({ topics, history }: {
  topics: Topic[]
  history: Record<string, FactHistoryRow>
}) {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
      {TILES.filter(t => topics.includes(t.topic)).map(t => {
        const cells = mapCells(t.id, history)
        const states = cells.flat(2)
        const mastered = states.filter(s => s === 'fluent').length
        return (
          <Link
            key={t.id}
            href={deckHref({ ...BASE, ...t.opts })}
            className="group flex items-center gap-3 rounded-2xl border border-white/10 bg-white/3 hover:border-amber-500/50 hover:bg-amber-500/5 p-3.5 transition-all active:scale-[0.99]"
          >
            <span className="w-[118px] h-[60px] shrink-0 rounded-xl bg-black/30 flex items-center justify-center">
              <MiniMap cells={cells} px={t.px} />
            </span>
            <span className="flex-1 min-w-0">
              <span className="block font-bold text-white leading-tight text-sm sm:text-base">
                <span className="text-zinc-400 mr-1">{t.symbol}</span>{t.title}
              </span>
              <span className="block text-[11px] text-zinc-500 mt-1">{mastered} of {states.length} mastered</span>
            </span>
            <span className="shrink-0 w-10 h-10 rounded-full bg-amber-500 group-hover:bg-amber-400 text-black flex items-center justify-center text-base font-black">
              ▶
            </span>
          </Link>
        )
      })}
    </div>
  )
}
