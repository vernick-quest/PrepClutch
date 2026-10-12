import Link from 'next/link'
import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { buildPinRound, buildCountryRound, COUNTRIES } from '@/lib/geo'
import { pinReady, countryPinReady } from '@/lib/geo-history'
import { CONTINENTS, CONTINENT_LABEL, CONTINENT_EMOJI, homeHref } from '@/lib/geo-meta'
import type { Continent } from '@/lib/geo-meta'
import { PIN_LEVELS, PIN_LEVEL_LABEL, COUNTRY_LEVEL_LABEL, pinHref } from '@/lib/geo-pin'
import type { PinLevel, PinMode } from '@/lib/geo-pin'
import PinClient from '@/components/geo/PinClient'
import CountryPinClient from '@/components/geo/CountryPinClient'
import RoundGuard from '@/components/ui/RoundGuard'
import TopBar from '@/components/ui/TopBar'
import { loginUrl } from '@/lib/tracks'

export const dynamic = 'force-dynamic'

interface Props { searchParams: Promise<{ c?: string; l?: string; m?: string }> }

const STEPS: { mode: PinMode; title: string; blurb: string }[] = [
  { mode: 'country', title: '🗺️ Countries', blurb: 'Find the country: tap anywhere inside it.' },
  { mode: 'place', title: '📍 Places', blurb: 'Capitals and famous cities. The closer your pin, the more points.' },
]

// /geo/pin?c=eu&l=1&m=country plays a "Find the country" round straight
// away, /geo/pin?c=eu&l=1 a places round. Without a continent (from the
// World tab) it shows the two choices that matter: which step (countries
// first, then places) and where. The picker opens on countries, step 1;
// ?m=place picks places.
export default async function GeoPinPage({ searchParams }: Props) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect(loginUrl('/geo'))

  const p = await searchParams
  const continent = (CONTINENTS as string[]).includes(p.c ?? '') ? p.c as Continent : null
  const level = (PIN_LEVELS as number[]).includes(Number(p.l)) ? Number(p.l) as PinLevel : 1

  if (!continent) {
    const mode: PinMode = p.m === 'place' ? 'place' : 'country'
    const { data: profile } = await supabase.from('profiles')
      .select('class_code, display_name, avatar_color, avatar_url').eq('id', user.id).single()
    if (!profile) redirect('/onboarding')
    const labels = mode === 'country' ? COUNTRY_LEVEL_LABEL : PIN_LEVEL_LABEL
    return (
      <div className="min-h-screen bg-[#0a0a0f]">
        <TopBar current="geo" profile={profile} />
        <div className="max-w-md mx-auto px-4 py-8 space-y-5">
          <div>
            <h1 className="text-2xl font-black text-white">📍 Pin the map</h1>
            <p className="text-sm text-zinc-400 mt-1">Two steps on every continent: find the countries, then the places in them.</p>
          </div>
          <div className="space-y-2">
            {STEPS.map((s, i) => (
              <Link key={s.mode} href={s.mode === 'country' ? '/geo/pin' : '/geo/pin?m=place'} aria-current={s.mode === mode ? 'true' : undefined}
                    className={`flex items-center gap-3 rounded-2xl border p-4 transition-colors min-w-0 ${
                      s.mode === mode ? 'border-sky-400/50 bg-sky-500/15' : 'border-white/10 bg-white/3 hover:border-white/25'
                    }`}>
                <span className={`shrink-0 w-8 h-8 rounded-full flex items-center justify-center text-sm font-black ${s.mode === mode ? 'bg-sky-400 text-black' : 'bg-white/10 text-zinc-300'}`}>{i + 1}</span>
                <span className="w-0 flex-1">
                  <span className="block font-bold text-white truncate">{s.title}</span>
                  <span className="block text-xs text-zinc-400">{s.blurb}</span>
                </span>
              </Link>
            ))}
          </div>
          <p className="text-xs font-bold uppercase tracking-wide text-zinc-500">Pick a continent</p>
          <div className="grid grid-cols-2 gap-2">
            {CONTINENTS.map(ct => (
              <Link key={ct} href={pinHref(ct, 1, mode)}
                    className="rounded-2xl border border-white/10 bg-white/3 hover:border-sky-400/40 hover:bg-sky-500/10 p-4 transition-colors min-w-0">
                <span className="block text-2xl">{CONTINENT_EMOJI[ct]}</span>
                <span className="block mt-1 font-bold text-white truncate">{CONTINENT_LABEL[ct]}</span>
              </Link>
            ))}
          </div>
          <p className="text-xs text-zinc-500">
            Every continent has three levels: {PIN_LEVELS.map(l => labels[l]).join(', ')}. One star (★) passes a level.
          </p>
          <Link href="/geo" className="inline-block text-sm text-sky-300 hover:text-sky-200">← Geography home</Link>
        </div>
      </div>
    )
  }

  const home = homeHref({ continent, group: 'all' })
  // A new round is a new session: remount so "Play again" starts clean.
  if (p.m === 'country') {
    const countries = buildCountryRound(continent, level)
    const names = Object.fromEntries(COUNTRIES.map(c => [c.iso, c.name]))
    const canSave = await countryPinReady(supabase)
    return (
      <RoundGuard round={crypto.randomUUID()} home={home}>
        <CountryPinClient key={countries.map(x => x.iso).join()} countries={countries} names={names}
                          continent={continent} level={level} canSave={canSave} />
      </RoundGuard>
    )
  }
  const places = buildPinRound(continent, level)
  const canSave = await pinReady(supabase)
  return (
    <RoundGuard round={crypto.randomUUID()} home={home}>
      <PinClient key={places.map(x => x.key).join()} places={places} continent={continent} level={level} canSave={canSave} />
    </RoundGuard>
  )
}
