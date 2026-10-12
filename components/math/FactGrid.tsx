'use client'

import { useState } from 'react'
import {
  FACT_TABLES, EQUIV_BASES, EQUIV_MULTIPLIERS, EQUIV_FORMS, FDP_BASES, FDP_FORMS,
  factKey, cardState, makeFdpCard,
} from '@/lib/math-facts'
import type { FactOp, FactHistoryRow, CardState, Topic } from '@/lib/math-facts'

type MapTab = FactOp | 'equiv' | 'fdp'
const TABS: [MapTab, string][] = [['mul', '×'], ['div', '÷'], ['equiv', '½'], ['fdp', '%']]

const RANK: Record<CardState, number> = { unseen: 0, struggling: 1, learning: 2, fluent: 3 }

// One cell can stand for several cards (the three forms of 7 × 8, or the four
// forms of ¾ ↔ 6/8). Every card mastered is solid green, some is pale green,
// none but answered right is amber, missed is red, never seen is blank.
function cellStyle(states: CardState[]): string {
  const fluent = states.filter(s => s === 'fluent').length
  if (fluent === states.length) return 'bg-emerald-500/70 text-white'
  if (fluent > 0)               return 'bg-emerald-500/25 text-emerald-100'
  const worst = states.filter(s => s !== 'unseen').sort((x, y) => RANK[x] - RANK[y])[0]
  if (worst === 'struggling') return 'bg-rose-500/30 text-rose-100'
  if (worst === 'learning')   return 'bg-amber-500/25 text-amber-100'
  return 'bg-white/3 text-zinc-600'
}

// Two-line headings keep the table inside a 375px phone.
const FDP_HEAD: Record<string, [string, string]> = {
  fp: ['frac', '→ %'], fd: ['frac', '→ dec'], dp: ['dec', '→ %'],
  pd: ['%', '→ dec'], pf: ['%', '→ frac'], df: ['dec', '→ frac'],
}

export default function FactGrid({ history, topics = ['times', 'equiv', 'fdp'] }: {
  history: Record<string, FactHistoryRow>
  topics?: Topic[]
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

  return (
    <div className="rounded-2xl border border-white/10 bg-white/3 p-4 min-w-0">
      <div className="flex items-center justify-between mb-3">
        <h3 className="text-sm font-bold text-white">Your fact map</h3>
        <div className="flex gap-1">
          {TABS.filter(([t]) => t === 'mul' || t === 'div' || topics.includes(t)).map(([t, label]) => (
            <button
              key={t}
              onClick={() => setTab(t)}
              className={`px-3 py-1 rounded-lg text-sm font-bold ${tab === t ? 'bg-white/10 text-white' : 'text-zinc-500'}`}
            >
              {label}
            </button>
          ))}
        </div>
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
