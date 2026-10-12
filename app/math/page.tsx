import Link from 'next/link'
import Image from 'next/image'
import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { MAX_FACT_POINTS, allCards } from '@/lib/math-facts'
import { loadFactHistory, availableTopics } from '@/lib/math-history'
import MathStart from '@/components/math/MathStart'
import TrackSwitcher from '@/components/ui/TrackSwitcher'
import FactGrid from '@/components/math/FactGrid'
import { MATH_FACTS_CATEGORY, compareBadges } from '@/lib/badges'
import { loginUrl } from '@/lib/tracks'

export const dynamic = 'force-dynamic'

interface LbRow {
  user_id: string; display_name: string; avatar_color: string; avatar_url: string | null
  class_code: string; points: number; mul_points: number; div_points: number; fluent: number
}

function Board({ title, rows, me }: { title: string; rows: LbRow[]; me: string }) {
  return (
    <div className="space-y-2">
      <h2 className="text-lg font-bold text-white">{title}</h2>
      {rows.length === 0 ? (
        <p className="text-sm text-zinc-500 rounded-2xl border border-white/5 bg-white/2 p-5 text-center">
          No Fact Points yet. Be the first.
        </p>
      ) : rows.map((r, i) => {
        const isMe = r.user_id === me
        return (
          <div key={r.user_id} className={`flex items-center gap-3 rounded-2xl border p-3 ${
            isMe ? 'bg-amber-500/10 border-amber-500/30' : 'bg-white/3 border-white/5'
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
              <p className={`font-semibold truncate ${isMe ? 'text-amber-400' : 'text-white'}`}>
                {r.display_name}{isMe && <span className="text-xs text-amber-500/70"> (you)</span>}
              </p>
              <p className="text-[11px] text-zinc-500">× {r.mul_points} · ÷ {r.div_points} · {r.fluent} mastered</p>
            </div>
            <span className="text-lg font-black text-white tabular-nums">{r.points}</span>
          </div>
        )
      })}
    </div>
  )
}

export default async function MathHomePage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect(loginUrl('/math'))

  const { data: profile } = await supabase.from('profiles')
    .select('class_code, display_name, avatar_color, avatar_url').eq('id', user.id).single()
  if (!profile) redirect('/onboarding')

  const { ready, rows } = await loadFactHistory(supabase, user.id)

  // Same shape as the HSPT dashboard's bar, so the switch reads as one site.
  const header = (
    <div className="flex items-center justify-between gap-3">
      <div className="flex items-center gap-3">
        <Link href="/" className="text-xl font-black hidden sm:block">
          <span className="text-amber-400">Prep</span><span className="text-white">Clutch</span>
        </Link>
        <TrackSwitcher current="math" />
      </div>
      <Link href="/profile" className="shrink-0 hover:opacity-80 transition-opacity">
        {profile.avatar_url ? (
          <Image src={profile.avatar_url} alt={profile.display_name} width={36} height={36} className="rounded-full" />
        ) : (
          <div className="w-9 h-9 rounded-full flex items-center justify-center text-sm font-bold text-white"
               style={{ backgroundColor: profile.avatar_color }}>
            {profile.display_name?.[0]?.toUpperCase()}
          </div>
        )}
      </Link>
    </div>
  )

  if (!ready) {
    return (
      <div className="min-h-screen bg-[#0a0a0f] px-4 py-10">
        <div className="max-w-md mx-auto space-y-6 text-center">
          {header}
          <p className="text-5xl">🧮</p>
          <h1 className="text-2xl font-black text-white">Math Facts is almost ready</h1>
          <p className="text-zinc-400 text-sm">It&rsquo;s waiting on one last setup step. Check back soon.</p>
        </div>
      </div>
    )
  }

  const topics = await availableTopics(supabase)
  const hasClass = (profile.class_code ?? '').trim() !== ''
  const [{ data: global }, { data: klass }] = await Promise.all([
    supabase.from('math_leaderboard_view').select('*').gt('points', 0)
      .order('points', { ascending: false }).limit(25),
    hasClass
      ? supabase.from('math_leaderboard_view').select('*').eq('class_code', profile.class_code)
          .order('points', { ascending: false })
      : Promise.resolve({ data: null }),
  ])

  // Math Facts badges (migration 063). Empty before it is applied, and the row
  // simply does not render.
  const [{ data: badgeDefs }, { data: myBadges }] = await Promise.all([
    supabase.from('achievement_definitions').select('key, label, icon_emoji, rarity')
      .eq('category', MATH_FACTS_CATEGORY),
    supabase.from('user_achievements').select('achievement_key').eq('user_id', user.id)
      .like('achievement_key', 'facts_%'),
  ])
  const heldKeys = new Set((myBadges ?? []).map((b: { achievement_key: string }) => b.achievement_key))
  const defs = ((badgeDefs ?? []) as { key: string; label: string; icon_emoji: string; rarity: string }[])
    .slice().sort(compareBadges)

  const points = allCards().reduce((s, c) => s + (rows.get(c.key)?.fluent_at ? c.points : 0), 0)
  const fluent = [...rows.values()].filter(r => r.fluent_at).length
  const history = Object.fromEntries(rows)

  return (
    <div className="min-h-screen bg-[#0a0a0f] px-4 py-8">
      <div className="max-w-5xl mx-auto space-y-8">
        {header}
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <h1 className="text-3xl font-black text-white">🧮 Math Facts</h1>
            <p className="text-zinc-400 text-sm mt-1">
              Times tables, equivalent fractions, and fractions, decimals &amp; percents. A card is
              mastered when you get it right <em>fast</em>.
            </p>
          </div>
          <div className="text-right">
            <p className="text-3xl font-black text-amber-400 tabular-nums">
              {points}<span className="text-sm font-normal text-zinc-500"> / {MAX_FACT_POINTS}</span>
            </p>
            <p className="text-xs text-zinc-500">Fact Points · {fluent} of {allCards().length} cards mastered</p>
          </div>
        </div>

        {defs.length > 0 && (
          <Link
            href="/bestiary"
            className="block rounded-2xl border border-violet-500/20 bg-violet-500/5 hover:border-violet-500/40 px-4 py-3 transition-colors"
          >
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm font-bold text-violet-200">🏅 Math Facts badges</span>
              <span className="text-xs text-zinc-400">{heldKeys.size} / {defs.length} · see all →</span>
            </div>
            <div className="flex flex-wrap gap-1.5">
              {defs.map(d => (
                <span
                  key={d.key}
                  title={heldKeys.has(d.key) ? d.label : `${d.label} (not yet)`}
                  className={`text-xl ${heldKeys.has(d.key) ? '' : 'grayscale opacity-25'}`}
                >
                  {d.icon_emoji}
                </span>
              ))}
            </div>
          </Link>
        )}

        <div className="grid lg:grid-cols-2 gap-6">
          <div className="space-y-6 min-w-0">
            <MathStart topics={topics} />
            <FactGrid history={history} topics={topics} />
          </div>
          <div className="space-y-8 min-w-0">
            {hasClass && <Board title="🏆 Class" rows={(klass ?? []) as LbRow[]} me={user.id} />}
            <Board title="🌍 Global" rows={(global ?? []) as LbRow[]} me={user.id} />
          </div>
        </div>
        <p className="text-xs text-zinc-600 text-center">
          Fact Points are separate from Clutch Points. Nothing here changes your HSPT scores.
        </p>
      </div>
    </div>
  )
}
