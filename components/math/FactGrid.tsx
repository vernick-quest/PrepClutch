'use client'

import { useState } from 'react'
import { FACT_TABLES, factKey, cardState } from '@/lib/math-facts'
import type { FactOp, FactHistoryRow, CardState } from '@/lib/math-facts'

const RANK: Record<CardState, number> = { unseen: 0, struggling: 1, learning: 2, fluent: 3 }

// One cell per fact family (a, b), coloured by its three cards together:
// all three mastered is solid green, some is pale green, none but answered
// right is amber, missed is red, never seen is blank.
function cellStyle(states: CardState[]): string {
  const fluent = states.filter(s => s === 'fluent').length
  if (fluent === 3) return 'bg-emerald-500/70 text-white'
  if (fluent > 0)   return 'bg-emerald-500/25 text-emerald-100'
  const worst = states.filter(s => s !== 'unseen').sort((x, y) => RANK[x] - RANK[y])[0]
  if (worst === 'struggling') return 'bg-rose-500/30 text-rose-100'
  if (worst === 'learning')   return 'bg-amber-500/25 text-amber-100'
  return 'bg-white/3 text-zinc-600'
}

export default function FactGrid({ history }: { history: Record<string, FactHistoryRow> }) {
  const [op, setOp] = useState<FactOp>('mul')

  return (
    <div className="rounded-2xl border border-white/10 bg-white/3 p-4">
      <div className="flex items-center justify-between mb-3">
        <h3 className="text-sm font-bold text-white">Your fact map</h3>
        <div className="flex gap-1">
          {(['mul', 'div'] as FactOp[]).map(o => (
            <button
              key={o}
              onClick={() => setOp(o)}
              className={`px-3 py-1 rounded-lg text-sm font-bold ${op === o ? 'bg-white/10 text-white' : 'text-zinc-500'}`}
            >
              {o === 'mul' ? '×' : '÷'}
            </button>
          ))}
        </div>
      </div>
      <div className="overflow-x-auto">
        <table className="mx-auto border-separate border-spacing-0.5 text-[10px] sm:text-xs tabular-nums">
          <thead>
            <tr>
              <th className="w-6 text-zinc-500">{op === 'mul' ? '×' : '÷'}</th>
              {FACT_TABLES.map(b => <th key={b} className="w-6 sm:w-8 text-zinc-500 font-semibold">{b}</th>)}
            </tr>
          </thead>
          <tbody>
            {FACT_TABLES.map(a => (
              <tr key={a}>
                <th className="text-zinc-500 font-semibold">{a}</th>
                {FACT_TABLES.map(b => {
                  const states = (['c', 'l', 'r'] as const).map(f => cardState(history[factKey(op, a, b, f)]))
                  const label = op === 'mul' ? `${a} × ${b} = ${a * b}` : `${a * b} ÷ ${a} = ${b}`
                  return (
                    <td
                      key={b}
                      title={label}
                      className={`h-6 sm:h-8 rounded text-center font-semibold ${cellStyle(states)}`}
                    >
                      {a * b}
                    </td>
                  )
                })}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <p className="text-[11px] text-zinc-500 mt-3 leading-relaxed">
        {op === 'mul' ? 'Row × column = cell.' : 'Cell ÷ row = column.'}{' '}
        <span className="text-emerald-300">Green</span> = mastered (all 3 card types solid),{' '}
        <span className="text-amber-300">amber</span> = right but slow,{' '}
        <span className="text-rose-300">red</span> = missed.
      </p>
    </div>
  )
}
