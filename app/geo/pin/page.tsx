import Link from 'next/link'
import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { buildPinRound } from '@/lib/geo'
import { pinReady } from '@/lib/geo-history'
import { CONTINENTS, CONTINENT_LABEL, CONTINENT_EMOJI } from '@/lib/geo-meta'
import type { Continent } from '@/lib/geo-meta'
import { PIN_LEVELS, PIN_LEVEL_LABEL, pinHref } from '@/lib/geo-pin'
import type { PinLevel } from '@/lib/geo-pin'
import PinClient from '@/components/geo/PinClient'
import TopBar from '@/components/ui/TopBar'
import { loginUrl } from '@/lib/tracks'

export const dynamic = 'force-dynamic'

interface Props { searchParams: Promise<{ c?: string; l?: string }> }

// /geo/pin?c=eu&l=1 plays a round straight away. Without a continent (from
// the World tab) it shows the one choice that matters: where.
export default async function GeoPinPage({ searchParams }: Props) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect(loginUrl('/geo'))

  const p = await searchParams
  const continent = (CONTINENTS as string[]).includes(p.c ?? '') ? p.c as Continent : null
  const level = (PIN_LEVELS as number[]).includes(Number(p.l)) ? Number(p.l) as PinLevel : 1

  if (!continent) {
    const { data: profile } = await supabase.from('profiles')
      .select('class_code, display_name, avatar_color, avatar_url').eq('id', user.id).single()
    if (!profile) redirect('/onboarding')
    return (
      <div className="min-h-screen bg-[#0a0a0f]">
        <TopBar current="geo" profile={profile} />
        <div className="max-w-md mx-auto px-4 py-8 space-y-5">
          <div>
            <h1 className="text-2xl font-black text-white">📍 Pin the map</h1>
            <p className="text-sm text-zinc-400 mt-1">Ten places, capitals and famous cities. Tap where each one is. The closer, the more points.</p>
          </div>
          <div className="grid grid-cols-2 gap-2">
            {CONTINENTS.map(ct => (
              <Link key={ct} href={pinHref(ct, 1)}
                    className="rounded-2xl border border-white/10 bg-white/3 hover:border-sky-400/40 hover:bg-sky-500/10 p-4 transition-colors min-w-0">
                <span className="block text-2xl">{CONTINENT_EMOJI[ct]}</span>
                <span className="block mt-1 font-bold text-white truncate">{CONTINENT_LABEL[ct]}</span>
              </Link>
            ))}
          </div>
          <p className="text-xs text-zinc-500">
            Every continent has three levels: {PIN_LEVELS.map(l => PIN_LEVEL_LABEL[l]).join(', ')}. Pick a level after your first round.
          </p>
          <Link href="/geo" className="inline-block text-sm text-sky-300 hover:text-sky-200">← Geography home</Link>
        </div>
      </div>
    )
  }

  const places = buildPinRound(continent, level)
  const canSave = await pinReady(supabase)
  // A new round is a new session: remount so "Play again" starts clean.
  return <PinClient key={places.map(x => x.key).join()} places={places} continent={continent} level={level} canSave={canSave} />
}
