import Link from 'next/link'
import Image from 'next/image'
import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { maxGeoPoints, geoCardCount, geoCards, mapCountries } from '@/lib/geo'
import { loadGeoHistory, loadGeoRounds, availableGeoKinds } from '@/lib/geo-history'
import GeoMap from '@/components/geo/GeoMap'
import GeoRounds from '@/components/geo/GeoRounds'
import TopBar from '@/components/ui/TopBar'
import { GEOGRAPHY_CATEGORY, compareBadges } from '@/lib/badges'
import { loginUrl } from '@/lib/tracks'

export const dynamic = 'force-dynamic'

interface LbRow {
  user_id: string; display_name: string; avatar_color: string; avatar_url: string | null
  class_code: string; points: number; fluent: number; capitals: number; flags: number
}

function Board({ title, rows, me }: { title: string; rows: LbRow[]; me: string }) {
  return (
    <div className="space-y-2">
      <h2 className="text-lg font-bold text-white">{title}</h2>
      {rows.length === 0 ? (
        <p className="text-sm text-zinc-500 rounded-2xl border border-white/5 bg-white/2 p-5 text-center">
          No Explorer Points yet. Be the first.
        </p>
      ) : rows.map((r, i) => {
        const isMe = r.user_id === me
        return (
          <div key={r.user_id} className={`flex items-center gap-3 rounded-2xl border p-3 ${
            isMe ? 'bg-sky-500/10 border-sky-500/30' : 'bg-white/3 border-white/5'
          }`}>
            <span className="w-8 text-center font-bold">{i === 0 ? '👑' : i === 1 ? '🥈' : i === 2 ? '🥉' : `#${i + 1}`}</span>
            {r.avatar_url ? (
              <Image src={r.avatar_url} alt={r.display_name} width={32} height={32} className="rounded-full" />
            ) : (
              <div className="w-8 h-8 rounded-full flex items-center justify-center text-sm font-black text-white"
                   style={{ backgroundColor: r.avatar_color }}>
                {r.display_name[0]?.toUpperCase()}
              </div>
            )}
            <div className="flex-1 min-w-0">
              <Link
                href={isMe ? '/profile' : `/profile/${r.user_id}`}
                className={`block font-semibold truncate transition-colors hover:text-sky-300 ${isMe ? 'text-sky-300' : 'text-white'}`}
              >
                {r.display_name}{isMe && <span className="text-xs text-sky-400/70"> (you)</span>}
              </Link>
              <p className="text-[11px] text-zinc-500">🏛️ {r.capitals} · 🚩 {r.flags} · {r.fluent} mastered</p>
            </div>
            <span className="text-lg font-black text-white tabular-nums">{r.points}</span>
          </div>
        )
      })}
    </div>
  )
}

export default async function GeoHomePage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect(loginUrl('/geo'))

  const { data: profile } = await supabase.from('profiles')
    .select('class_code, display_name, avatar_color, avatar_url').eq('id', user.id).single()
  if (!profile) redirect('/onboarding')

  const { ready, rows } = await loadGeoHistory(supabase, user.id)

  const header = <TopBar current="geo" profile={profile} />

  // The Geography migration is applied by hand, maybe after this deploy.
  // Until then: a friendly panel, not an error.
  if (!ready) {
    return (
      <div className="min-h-screen bg-[#0a0a0f]">
        {header}
        <div className="max-w-md mx-auto space-y-6 text-center px-4 py-10">
          <p className="text-5xl">🌍</p>
          <h1 className="text-2xl font-black text-white">Geography is almost ready</h1>
          <p className="text-zinc-400 text-sm">It&rsquo;s waiting on one last setup step. Check back soon.</p>
        </div>
      </div>
    )
  }

  const [rounds, kinds] = await Promise.all([loadGeoRounds(supabase, user.id), availableGeoKinds(supabase)])
  const shapes = kinds.includes('shape')
  const hasClass = (profile.class_code ?? '').trim() !== ''
  const [{ data: global }, { data: klass }] = await Promise.all([
    supabase.from('geo_leaderboard_view').select('*').gt('points', 0)
      .order('points', { ascending: false }).limit(25),
    hasClass
      ? supabase.from('geo_leaderboard_view').select('*').eq('class_code', profile.class_code)
          .order('points', { ascending: false })
      : Promise.resolve({ data: null }),
  ])

  const [{ data: badgeDefs }, { data: myBadges }] = await Promise.all([
    supabase.from('achievement_definitions').select('key, label, icon_emoji, rarity')
      .eq('category', GEOGRAPHY_CATEGORY),
    supabase.from('user_achievements').select('achievement_key').eq('user_id', user.id)
      .like('achievement_key', 'geo_%'),
  ])
  const heldKeys = new Set((myBadges ?? []).map((b: { achievement_key: string }) => b.achievement_key))
  const defs = ((badgeDefs ?? []) as { key: string; label: string; icon_emoji: string; rarity: string }[])
    .slice().sort(compareBadges)

  const cards = geoCards(kinds)
  const points = cards.reduce((s, c) => s + (rows.get(c.key)?.fluent_at ? c.points : 0), 0)
  const fluent = cards.filter(c => rows.get(c.key)?.fluent_at).length

  return (
    <div className="min-h-screen bg-[#0a0a0f]">
      {header}
      <div className="max-w-5xl mx-auto space-y-8 px-4 py-8">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <h1 className="text-3xl font-black text-white">🌍 Geography</h1>
            <p className="text-zinc-400 text-sm mt-1">
              Capitals, flags, money, languages and continents for all 193 countries{shapes ? ', and every country on the map' : ''}.
              A card is mastered when you get it right <em>fast</em>.
            </p>
          </div>
          <div className="text-right">
            <p className="text-3xl font-black text-sky-300 tabular-nums">
              {points}<span className="text-sm font-normal text-zinc-500"> / {maxGeoPoints(kinds)}</span>
            </p>
            <p className="text-xs text-zinc-500">Explorer Points · {fluent} of {geoCardCount(kinds)} cards mastered</p>
            {defs.length > 0 && (
              <Link href="/profile" className="inline-block mt-1 text-xs text-violet-300 hover:text-violet-200">
                🏅 {defs.filter(d => heldKeys.has(d.key)).length} / {defs.length} badges →
              </Link>
            )}
          </div>
        </div>

        <div className="grid lg:grid-cols-2 gap-6">
          <div className="space-y-6 min-w-0">
            <GeoMap history={Object.fromEntries(rows)} countries={mapCountries()} kinds={kinds} />
            <GeoRounds rounds={rounds} />
          </div>
          <div className="space-y-8 min-w-0">
            {hasClass && <Board title="🏆 Class" rows={(klass ?? []) as LbRow[]} me={user.id} />}
            <Board title="🌍 Global" rows={(global ?? []) as LbRow[]} me={user.id} />
          </div>
        </div>
        <p className="text-xs text-zinc-600 text-center">
          Explorer Points are separate from Clutch Points and Fact Points. Facts from Wikidata, flags from flag-icons{shapes ? ', maps from Natural Earth' : ''}.
        </p>
      </div>
    </div>
  )
}
