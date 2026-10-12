'use client'

import { useState } from 'react'
import {
  FACT_TABLES, EQUIV_BASES, EQUIV_MULTIPLIERS, EQUIV_FORMS, FDP_BASES, FDP_FORMS,
  factKey, cardState, makeFdpCard, deckHref,
} from '@/lib/math-facts'
import type { DeckOptions } from '@/lib/math-facts'
import Link from 'next/link'
import type { FactHistoryRow, CardState, Topic } from '@/lib/math-facts'
import { cellTone, CELL_CLASS, mapCells } from '@/components/math/cells'
import type { MapTab } from '@/components/math/cells'

// The tab bar IS the topic picker: one selection chooses both the map shown
// and what ▶ Play starts, so the mode and its map can never disagree.
const TABS: { id: MapTab; symbol: string; short: string; title: string; deck: Partial<DeckOptions> }[] = [
  { id: 'mul',   symbol: '×', short: 'Multiply',  title: 'Multiplication',                 deck: { op: 'mul' } },
  { id: 'div',   symbol: '÷', short: 'Divide',    title: 'Division',                       deck: { op: 'div' } },
  { id: 'equiv', symbol: '½', short: 'Fractions', title: 'Equivalent fractions',           deck: { topic: 'equiv' } },
  { id: 'fdp',   symbol: '%', short: 'Decimals',  title: 'Fractions, decimals & percents', deck: { topic: 'fdp' } },
]
const BASE: DeckOptions = { topic: 'times', op: 'mixed', type: 'both', tables: [], focus: 'all' }

const cellStyle = (states: CardState[]) => CELL_CLASS[cellTone(states)]

// Two-line headings keep the table inside a 375px phone.
const FDP_HEAD: Record<string, [string, string]> = {
  fp: ['frac', '→ %'], fd: ['frac', '→ dec'], dp: ['dec', '→ %'],
  pd: ['%', '→ dec'], pf: ['%', '→ frac'], df: ['dec', '→ frac'],
}

export default function FactGrid({ history, topics = ['times', 'equiv', 'fdp'], readOnly = false }: {
  history: Record<string, FactHistoryRow>
  topics?: Topic[]
  /** Someone else's map (an admin viewing a student): no Play button. */
  readOnly?: boolean
}) {
  const [tab, setTab] = useState<MapTab>('mul')
  const st = (k: string) => cardState(history[k])

  let table: React.ReactNode
  let note: string

  if (tab === 'mul' || tab === 'div') {
    table = (
      <table className="mx-auto border-separate border-spacing-0.5 text-[10px] sm:text-xs tabular-nums">
        <thead>
          <tr>
            <th className="w-6 text-zinc-500">{tab === 'mul' ? '×' : '÷'}</th>
            {FACT_TABLES.map(b => <th key={b} className="w-6 sm:w-8 text-zinc-500 font-semibold">{b}</th>)}
          </tr>
        </thead>
        <tbody>
          {FACT_TABLES.map(a => (
            <tr key={a}>
              <th className="text-zinc-500 font-semibold">{a}</th>
              {FACT_TABLES.map(b => (
                <td
                  key={b}
                  title={tab === 'mul' ? `${a} × ${b} = ${a * b}` : `${a * b} ÷ ${a} = ${b}`}
                  className={`h-6 sm:h-8 rounded text-center font-semibold ${cellStyle((['c', 'l', 'r'] as const).map(f => st(factKey(tab, a, b, f))))}`}
                >
                  {a * b}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    )
    note = tab === 'mul' ? 'Row × column = cell.' : 'Cell ÷ row = column.'
  } else if (tab === 'equiv') {
    table = (
      <table className="mx-auto border-separate border-spacing-0.5 text-[10px] sm:text-xs tabular-nums">
        <thead>
          <tr>
            <th />
            {EQUIV_MULTIPLIERS.map(k => <th key={k} className="w-12 sm:w-14 text-zinc-500 font-semibold">× {k}</th>)}
          </tr>
        </thead>
        <tbody>
          {EQUIV_BASES.map(([a, b]) => (
            <tr key={`${a}/${b}`}>
              <th className="pr-1 text-right text-zinc-400 font-semibold">{a}/{b}</th>
              {EQUIV_MULTIPLIERS.map(k => (
                <td
                  key={k}
                  title={`${a}/${b} = ${a * k}/${b * k}`}
                  className={`h-6 sm:h-7 rounded text-center font-semibold ${cellStyle(EQUIV_FORMS.map(f => st(`eq:${a}:${b}:${k}:${f}`)))}`}
                >
                  {a * k}/{b * k}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    )
    note = 'Each cell is four cards: building up to it and simplifying back down.'
  } else {
    table = (
      <table className="mx-auto border-separate border-spacing-0.5 text-[10px] sm:text-xs tabular-nums">
        <thead>
          <tr>
            <th />
            {FDP_FORMS.map(f => (
              <th key={f} className="text-[9px] sm:text-[11px] leading-tight text-zinc-500 font-semibold">
                {FDP_HEAD[f][0]}<br />{FDP_HEAD[f][1]}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {FDP_BASES.map(([a, b]) => (
            <tr key={`${a}/${b}`}>
              <th className="pr-1 text-right text-zinc-400 font-semibold">{a}/{b}</th>
              {FDP_FORMS.map(f => {
                const c = makeFdpCard(a, b, f)
                return (
                  <td key={f} title={c.full} className={`h-6 sm:h-7 px-0.5 sm:px-1 rounded text-center font-semibold ${cellStyle([st(c.key)])}`}>
                    {f === 'fp' || f === 'dp' ? `${c.answer}%` : f === 'pf' || f === 'df' ? `${a}/${b}` : c.answer}
                  </td>
                )
              })}
            </tr>
          ))}
        </tbody>
      </table>
    )
    note = 'Each cell is one card, showing its answer.'
  }

  const current = TABS.find(t => t.id === tab)!
  const states = mapCells(tab, history).flat(2)
  const mastered = states.filter(s => s === 'fluent').length

  return (
    <div className="rounded-2xl border border-white/10 bg-white/3 p-3 sm:p-4 min-w-0">
      <div className="grid grid-cols-4 gap-1 p-1 rounded-xl bg-black/30 mb-4">
        {TABS.filter(t => t.id === 'mul' || t.id === 'div' || topics.includes(t.id)).map(t => (
          <button
            key={t.id}
            onClick={() => setTab(t.id)}
            aria-pressed={tab === t.id}
            className={`rounded-lg py-2 transition-colors ${
              tab === t.id ? 'bg-white/10 text-white' : 'text-zinc-500 hover:text-zinc-300'
            }`}
          >
            <span className="block text-xl font-black leading-none">{t.symbol}</span>
            <span className="block text-[11px] font-semibold mt-1">{t.short}</span>
          </button>
        ))}
      </div>

      <div className="flex items-center justify-between gap-3 mb-3">
        <div className="min-w-0">
          <h3 className="font-bold text-white leading-tight">
            <span className="text-zinc-400 mr-1">{current.symbol}</span>{current.title}
          </h3>
          <p className="text-xs text-zinc-400 mt-0.5">
            <span className="font-bold text-white">{mastered}</span> of {states.length} mastered
          </p>
        </div>
        {!readOnly && <Link
          href={deckHref({ ...BASE, ...current.deck })}
          className="shrink-0 flex items-center gap-2 bg-amber-500 hover:bg-amber-400 text-black font-bold px-5 py-3 rounded-xl transition-colors"
        >
          ▶ Play
        </Link>}
      </div>

      <div className="overflow-x-auto">{table}</div>
      <p className="text-[11px] text-zinc-500 mt-3 leading-relaxed">
        {note}{' '}
        <span className="text-emerald-300">Green</span> = mastered,{' '}
        <span className="text-amber-300">amber</span> = right but slow,{' '}
        <span className="text-rose-300">red</span> = missed.
      </p>
    </div>
  )
}
