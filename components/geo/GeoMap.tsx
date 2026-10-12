'use client'

import { useState } from 'react'
import Link from 'next/link'
import {
  CONTINENTS, CONTINENT_LABEL, CONTINENT_SHORT, CONTINENT_EMOJI, GROUPS, GROUP_LABEL,
  GROUP_EMOJI, KINDS_069, KIND_LABEL, geoCardState, deckHref, groupKinds, countryCardKeys,
} from '@/lib/geo-meta'
import type { Continent, KindGroup, GeoHistoryRow, GeoCardState, GeoKind, MapCountry } from '@/lib/geo-meta'
import { pinHref } from '@/lib/geo-pin'
import { cellTone, CELL_CLASS } from '@/components/math/cells'
import Flag from '@/components/geo/Flag'

// The Geography mastery map. Like the Math Facts fact map, the tabs ARE the
// picker: the continent tab and the card-type chip choose both what the map
// shows and what ▶ Play starts, so the two can never disagree. Colours are
// the Math Facts ones (components/math/cells.ts).
//
// World shows one bar per continent. A continent shows one flag tile per
// country, coloured by that country's cards of the chosen type. Tiles wrap,
// so the map fits a 375px phone and a half-width desktop column alike.
//
// `kinds` are the card kinds the catalogue has (availableGeoKinds): the
// Shapes and Cities chips appear once the map migration is applied. City
// cards belong to their country's tile (most countries have none, so on
// the Cities chip only countries with famous cities are shown); tapping a
// tile lists them. 📍 Pin opens Pin the map on the chosen continent (or its
// continent picker, from World).

type Tab = Continent | 'all'
const TABS: Tab[] = ['all', ...CONTINENTS]

const TONE_BAR: Record<string, string> = {
  solid: 'bg-emerald-500/80', some: 'bg-emerald-500/35', slow: 'bg-amber-500/50', missed: 'bg-rose-500/50', new: 'bg-white/5',
}

export default function GeoMap({ history, countries, readOnly = false, kinds: available = KINDS_069 }: {
  history: Record<string, GeoHistoryRow>
  countries: MapCountry[]
  /** Someone else's map (an admin viewing a student): no Play button. */
  readOnly?: boolean
  /** The card kinds the catalogue has. */
  kinds?: GeoKind[]
}) {
  const [tab, setTab] = useState<Tab>('all')
  const [group, setGroup] = useState<KindGroup>('all')
  const [picked, setPicked] = useState<string | null>(null)

  // No Continents chip inside a continent: those questions answer themselves
  // there (deckPool leaves them out of continent rounds too).
  const groups = GROUPS.filter(g => groupKinds(g, available).length > 0 && !(g === 'continents' && tab !== 'all'))
  const kinds = groupKinds(group, available)
  const st = (key: string): GeoCardState => geoCardState(history[key])
  const statesOf = (c: MapCountry) => kinds.flatMap(k => countryCardKeys(c, k).map(st))
  // A tile only for countries with cards of this type (Cities: few do).
  const shown = countries.filter(c => statesOf(c).length > 0)
  const inTab = shown.filter(c => tab === 'all' || c.continent === tab)
  const all = inTab.flatMap(statesOf)
  const mastered = all.filter(s => s === 'fluent').length
  const pickedCountry = inTab.find(c => c.iso === picked)

  return (
    <div className="rounded-2xl border border-white/10 bg-white/3 p-3 sm:p-4 min-w-0">
      {/* Continent tabs */}
      <div className="grid grid-cols-4 gap-1 p-1 rounded-xl bg-black/30">
        {TABS.map(t => (
          <button
            key={t}
            onClick={() => { setTab(t); setPicked(null); if (t !== 'all' && group === 'continents') setGroup('all') }}
            aria-pressed={tab === t}
            className={`rounded-lg py-1.5 px-0.5 transition-colors min-w-0 ${
              tab === t ? 'bg-white/10 text-white' : 'text-zinc-500 hover:text-zinc-300'
            }`}
          >
            <span className="block text-lg leading-none">{t === 'all' ? '🌐' : CONTINENT_EMOJI[t]}</span>
            <span className="block text-[11px] font-semibold mt-1 truncate">{t === 'all' ? 'World' : CONTINENT_SHORT[t]}</span>
          </button>
        ))}
      </div>

      {/* Card types */}
      <div className="flex flex-wrap gap-1.5 mt-2 mb-4">
        {groups.map(g => (
          <button
            key={g}
            onClick={() => setGroup(g)}
            aria-pressed={group === g}
            className={`rounded-full px-2.5 py-1 text-xs font-semibold border transition-colors ${
              group === g ? 'bg-sky-500/20 border-sky-400/50 text-sky-100' : 'border-white/10 text-zinc-500 hover:text-zinc-300'
            }`}
          >
            {GROUP_EMOJI[g]} {GROUP_LABEL[g]}
          </button>
        ))}
      </div>

      <div className="flex items-center justify-between gap-3 mb-3">
        <div className="min-w-0">
          <h3 className="font-bold text-white leading-tight truncate">
            {tab === 'all' ? '🌐 World' : `${CONTINENT_EMOJI[tab]} ${CONTINENT_LABEL[tab]}`}
            {group !== 'all' && <span className="text-zinc-400"> · {GROUP_LABEL[group]}</span>}
          </h3>
          <p className="text-xs text-zinc-400 mt-0.5">
            <span className="font-bold text-white">{mastered}</span> of {all.length} cards mastered
          </p>
        </div>
        {!readOnly && (
          <div className="shrink-0 flex items-center gap-1.5">
            <Link
              href={tab === 'all' ? '/geo/pin' : pinHref(tab, 1)}
              title="Pin the map: find capitals and famous cities on the map"
              className="flex items-center bg-white/5 border border-white/15 hover:border-white/30 text-white font-bold px-3 py-3 rounded-xl transition-colors"
            >
              📍 Pin
            </Link>
            <Link
              href={deckHref({ continent: tab, group })}
              className="flex items-center gap-2 bg-sky-500 hover:bg-sky-400 text-black font-bold px-4 sm:px-5 py-3 rounded-xl transition-colors"
            >
              ▶ Play
            </Link>
          </div>
        )}
      </div>

      {tab === 'all' ? (
        <div className="space-y-2">
          {CONTINENTS.map(ct => {
            const cs = shown.filter(c => c.continent === ct)
            const tones = cs.map(c => cellTone(statesOf(c)))
            const done = cs.flatMap(statesOf).filter(s => s === 'fluent').length
            const total = cs.flatMap(statesOf).length
            return (
              <button key={ct} onClick={() => setTab(ct)} className="w-full text-left group">
                <div className="flex items-center justify-between text-xs mb-1">
                  <span className="font-semibold text-zinc-200 group-hover:text-white">{CONTINENT_EMOJI[ct]} {CONTINENT_LABEL[ct]}</span>
                  <span className="text-zinc-500 tabular-nums">{done} / {total}</span>
                </div>
                {/* One sliver per country, in the map colours. */}
                <div className="flex h-3 rounded-full overflow-hidden gap-px bg-black/30">
                  {tones.map((t, i) => <span key={i} className={`flex-1 ${TONE_BAR[t]}`} />)}
                </div>
              </button>
            )
          })}
        </div>
      ) : (
        <>
          <div className="flex flex-wrap gap-1">
            {inTab.map(c => {
              const tone = cellTone(statesOf(c))
              return (
                <button
                  key={c.iso}
                  onClick={() => setPicked(p => (p === c.iso ? null : c.iso))}
                  title={`${c.name} · ${c.capital}`}
                  aria-label={c.name}
                  aria-pressed={picked === c.iso}
                  className={`rounded-md p-[3px] transition-transform hover:scale-110 ${CELL_CLASS[tone]} ${
                    picked === c.iso ? 'ring-2 ring-sky-300' : ''
                  }`}
                >
                  <Flag iso={c.iso} alt="" className={`w-9 h-[27px] rounded-sm ${tone === 'new' ? 'opacity-40' : ''}`} />
                </button>
              )
            })}
          </div>
          <div className="mt-3 min-h-[3.25rem] rounded-xl bg-black/20 px-3 py-2 text-xs">
            {pickedCountry ? (
              <>
                <p className="font-bold text-white">{pickedCountry.name} <span className="font-normal text-zinc-400">· capital {pickedCountry.capital}</span></p>
                <div className="flex flex-wrap gap-1 mt-1.5">
                  {available.filter(k => k !== 'city').map(k => (
                    <span key={k} className={`rounded px-1.5 py-0.5 text-[10px] font-semibold ${CELL_CLASS[cellTone(countryCardKeys(pickedCountry, k).map(st))]}`}>
                      {KIND_LABEL[k]}
                    </span>
                  ))}
                  {available.includes('city') && pickedCountry.cities.map(x => (
                    <span key={x.key} className={`rounded px-1.5 py-0.5 text-[10px] font-semibold ${CELL_CLASS[cellTone([st(x.key)])]}`}>
                      🏙️ {x.name}
                    </span>
                  ))}
                </div>
              </>
            ) : (
              <p className="text-zinc-500 pt-2">Tap a flag to see that country.</p>
            )}
          </div>
        </>
      )}

      <p className="text-[11px] text-zinc-500 mt-3 leading-relaxed">
        <span className="text-emerald-300">Green</span> = mastered,{' '}
        <span className="text-amber-300">amber</span> = right but slow,{' '}
        <span className="text-rose-300">red</span> = missed.
      </p>
    </div>
  )
}
