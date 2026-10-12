// Shared by the fact map and the start tiles, so a tile's thumbnail is the
// same picture as its map, in the same colours.

import {
  FACT_TABLES, EQUIV_BASES, EQUIV_MULTIPLIERS, EQUIV_FORMS, FDP_BASES, FDP_FORMS,
  factKey, cardState,
} from '@/lib/math-facts'
import type { FactOp, FactHistoryRow, CardState } from '@/lib/math-facts'

export type MapTab = FactOp | 'equiv' | 'fdp'

const RANK: Record<CardState, number> = { unseen: 0, struggling: 1, learning: 2, fluent: 3 }

export type CellTone = 'solid' | 'some' | 'missed' | 'slow' | 'new'

// One cell can stand for several cards (the three forms of 7 × 8, or the four
// forms of ¾ ↔ 6/8). Every card mastered is solid green, some is pale green,
// none but answered right is amber, missed is red, never seen is blank.
export function cellTone(states: CardState[]): CellTone {
  const fluent = states.filter(s => s === 'fluent').length
  if (fluent === states.length) return 'solid'
  if (fluent > 0)               return 'some'
  const worst = states.filter(s => s !== 'unseen').sort((x, y) => RANK[x] - RANK[y])[0]
  if (worst === 'struggling') return 'missed'
  if (worst === 'learning')   return 'slow'
  return 'new'
}

/** Full-size map cells: background and text. */
export const CELL_CLASS: Record<CellTone, string> = {
  solid:  'bg-emerald-500/70 text-white',
  some:   'bg-emerald-500/25 text-emerald-100',
  missed: 'bg-rose-500/30 text-rose-100',
  slow:   'bg-amber-500/25 text-amber-100',
  new:    'bg-white/3 text-zinc-600',
}

/** Thumbnail cells: no text, so a little brighter to read at a few pixels. */
export const MINI_CLASS: Record<CellTone, string> = {
  solid:  'bg-emerald-400',
  some:   'bg-emerald-500/45',
  missed: 'bg-rose-500/70',
  slow:   'bg-amber-500/60',
  new:    'bg-white/10',
}

/** The map for one tab as rows of cells, each cell the states of its cards.
 *  Same grouping as the full fact map; the fraction maps are laid on their
 *  side so the thumbnail is wide rather than tall. */
export function mapCells(tab: MapTab, history: Record<string, FactHistoryRow>): CardState[][][] {
  const st = (k: string) => cardState(history[k])
  if (tab === 'mul' || tab === 'div') {
    return FACT_TABLES.map(a => FACT_TABLES.map(b => (['c', 'l', 'r'] as const).map(f => st(factKey(tab, a, b, f)))))
  }
  if (tab === 'equiv') {
    return EQUIV_MULTIPLIERS.map(k => EQUIV_BASES.map(([a, b]) => EQUIV_FORMS.map(f => st(`eq:${a}:${b}:${k}:${f}`))))
  }
  return FDP_FORMS.map(f => FDP_BASES.map(([a, b]) => [st(`fdp:${a}:${b}:${f}`)]))
}
