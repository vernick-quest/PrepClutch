'use client'

import { useState } from 'react'
import Link from 'next/link'
import { FACT_TABLES, deckHref } from '@/lib/math-facts'
import type { OpMode, FormMode } from '@/lib/math-facts'

const OPS: [OpMode, string][]    = [['mul', '× Multiply'], ['div', '÷ Divide'], ['mixed', '× ÷ Both']]
const TYPES: [FormMode, string][] = [['both', 'All cards'], ['classic', '7 × 8 = ?'], ['missing', '7 × ? = 56']]

function Chip({ on, onClick, children }: { on: boolean; onClick: () => void; children: React.ReactNode }) {
  return (
    <button
      onClick={onClick}
      className={`px-3 py-2 rounded-xl border text-sm font-semibold transition-colors ${
        on ? 'bg-amber-500/15 border-amber-500/50 text-amber-200' : 'bg-white/3 border-white/10 text-zinc-400 hover:border-white/25'
      }`}
    >
      {children}
    </button>
  )
}

export default function MathStart() {
  const [op, setOp]         = useState<OpMode>('mul')
  const [type, setType]     = useState<FormMode>('both')
  const [tables, setTables] = useState<number[]>([])  // empty = all

  const toggle = (n: number) =>
    setTables(t => t.includes(n) ? t.filter(x => x !== n) : [...t, n].sort((a, b) => a - b))

  return (
    <div className="rounded-2xl border border-white/10 bg-white/3 p-5 space-y-4">
      <div className="flex flex-wrap gap-2">
        {OPS.map(([v, label]) => <Chip key={v} on={op === v} onClick={() => setOp(v)}>{label}</Chip>)}
      </div>
      <div className="flex flex-wrap gap-2">
        {TYPES.map(([v, label]) => (
          <Chip key={v} on={type === v} onClick={() => setType(v)}>
            <span className="font-mono">{label}</span>
          </Chip>
        ))}
      </div>
      <div>
        <p className="text-xs text-zinc-500 mb-2">Tables {tables.length === 0 && '· all of them'}</p>
        <div className="flex flex-wrap gap-1.5">
          <Chip on={tables.length === 0} onClick={() => setTables([])}>All</Chip>
          {FACT_TABLES.map(n => (
            <Chip key={n} on={tables.includes(n)} onClick={() => toggle(n)}>
              <span className="tabular-nums">{n}</span>
            </Chip>
          ))}
        </div>
      </div>
      <Link
        href={deckHref({ op, type, tables })}
        className="block text-center bg-amber-500 hover:bg-amber-400 text-black font-bold py-3.5 rounded-2xl transition-colors"
      >
        Start · 20 cards
      </Link>
    </div>
  )
}
