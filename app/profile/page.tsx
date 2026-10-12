import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import { SECTION_CONFIG, SECTIONS, formatAttemptTime } from '@/lib/constants'
import Link from 'next/link'
import Image from 'next/image'
import Footer from '@/components/ui/Footer'
import SignOutButton from '@/components/ui/SignOutButton'
import ProfileActions from '@/components/profile/ProfileActions'
import AttemptReview from '@/components/quiz/AttemptReview'
import { isSectionComplete, compareBadges, MATH_FACTS_CATEGORY, MATH_FACTS_GROUPS, mathFactsGroup, GEOGRAPHY_CATEGORY, GEOGRAPHY_GROUPS, geographyGroup } from '@/lib/badges'
import type { Section, QuizAnswer } from '@/types/database'
import { loginUrl, TRACK_HOME } from '@/lib/tracks'
import type { Track } from '@/lib/tracks'
import TopBar from '@/components/ui/TopBar'
import MathRounds from '@/components/math/MathRounds'
import GeoRounds from '@/components/geo/GeoRounds'
import { allCards, MAX_FACT_POINTS } from '@/lib/math-facts'
import { loadFactHistory, loadRounds } from '@/lib/math-history'
import { geoCards, maxGeoPoints } from '@/lib/geo'
import { loadGeoHistory, loadGeoRounds, availableGeoKinds } from '@/lib/geo-history'

export const dynamic = 'force-dynamic'

function getAccentHex(accent: string): string {
  const map: Record<string, string> = {
    amber: '#f59e0b', cyan: '#06b6d4', emerald: '#10b981', rose: '#f43f5e', violet: '#8b5cf6',
  }
  return map[accent] ?? '#ffffff'
}

const TRACK_NAME: Record<Track, string> = { hspt: 'HSPT', math: 'Math Facts', geo: 'Geography' }

type BadgeDef = { key: string; label: string; icon_emoji: string; description: string; rarity: string; category: string }

// Every badge of a track, earned or not, with what it takes, so a student can
// see the next thing to aim for. Under the same headings as that track's map.
function BadgeGroups({ title, badges, groups, groupOf, earned, tone }: {
  title: string
  badges: BadgeDef[]
  groups: readonly string[]
  groupOf: (key: string) => string
  earned: Set<string>
  tone: string
}) {
  if (badges.length === 0) return null
  return (
    <div className="bg-white/3 border border-white/10 rounded-2xl p-5">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-bold text-white">{title}</h3>
        <span className="text-sm text-zinc-400">{badges.filter(b => earned.has(b.key)).length} / {badges.length}</span>
      </div>
      <div className="space-y-5">
        {groups.map(group => {
          const inGroup = badges.filter(b => groupOf(b.key) === group)
          if (inGroup.length === 0) return null
          return (
            <div key={group}>
              <p className="text-xs font-bold uppercase tracking-wide text-zinc-400 mb-2">
                {group}
                <span className="ml-2 font-normal normal-case text-zinc-600">
                  {inGroup.filter(b => earned.has(b.key)).length} / {inGroup.length}
                </span>
              </p>
              <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-2.5">
                {inGroup.map(b => {
                  const got = earned.has(b.key)
                  return (
                    <div key={b.key} className={`rounded-xl border p-3 ${got ? tone : 'border-white/5 bg-white/2'}`}>
                      <div className={`text-2xl mb-1 ${got ? '' : 'grayscale opacity-30'}`}>{b.icon_emoji}</div>
                      <div className={`text-sm font-bold leading-tight ${got ? 'text-white' : 'text-zinc-500'}`}>{b.label}</div>
                      <div className="text-[11px] text-zinc-500 leading-snug mt-0.5">
                        {got ? '✓ ' : '🔒 '}{b.description}
                      </div>
                    </div>
                  )
                })}
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}

function Stat({ value, label, accent = false }: { value: number; label: string; accent?: boolean }) {
  return (
    <div className={`${accent ? 'bg-amber-500/10 border-amber-500/20' : 'bg-white/5 border-white/10'} border rounded-xl px-4 py-2 text-center`}>
      <div className={`text-2xl font-black ${accent ? 'text-amber-400' : 'text-white'}`}>{value}</div>
      <div className="text-xs text-zinc-400">{label}</div>
    </div>
  )
}

// The profile shows ONE track at a time: the one you came from (?t=math from
// the Math Facts top bar), else your home track. The top bar's track switcher
// flips between them here instead of leaving the page.
export default async function ProfilePage({ searchParams }: { searchParams: Promise<{ t?: string }> }) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect(loginUrl('/profile'))

  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single()

  if (!profile) redirect('/onboarding')

  const asked = (await searchParams).t
  const track: Track = asked === 'hspt' || asked === 'math' || asked === 'geo'
    ? asked
    : (profile as Record<string, unknown>).home_track === 'math' ? 'math' : 'hspt'
  const isAdmin = (profile as Record<string, unknown>).is_admin === true

  const { data: attempts } = track !== 'hspt' ? { data: null } : await supabase
    .from('quiz_attempts')
    .select('*')
    .eq('user_id', user.id)
    .not('completed_at', 'is', null)
    .order('completed_at', { ascending: false })

  const { data: userAchievements } = await supabase
    .from('user_achievements')
    .select('achievement_key, earned_at')
    .eq('user_id', user.id)

  const { data: allAchievements } = await supabase
    .from('achievement_definitions')
    .select('*')
    .order('category')

  const { data: leaderboardEntry } = track !== 'hspt' ? { data: null } : await supabase
    .from('leaderboard_view')
    .select('*')
    .eq('user_id', user.id)
    .single()

  const totalAttempts = attempts?.length ?? 0
  const earnedKeys = new Set(userAchievements?.map(a => a.achievement_key) ?? [])
  const hsptBadges = ((allAchievements ?? []) as BadgeDef[])
    .filter(b => b.category !== MATH_FACTS_CATEGORY && b.category !== GEOGRAPHY_CATEGORY)
  const mathBadges = ((allAchievements ?? []) as BadgeDef[])
    .filter(b => b.category === MATH_FACTS_CATEGORY)
    .sort(compareBadges)
  const geoBadges = ((allAchievements ?? []) as BadgeDef[])
    .filter(b => b.category === GEOGRAPHY_CATEGORY)
    .sort(compareBadges)

  const trackBadges = track === 'math' ? mathBadges : track === 'geo' ? geoBadges : hsptBadges
  const trackEarned = trackBadges.filter(b => earnedKeys.has(b.key)).length

  // Math Facts and Geography: points and mastered cards, worked out the same
  // way their home pages do, plus recent rounds.
  let mathStats = { points: 0, fluent: 0, rounds: [] as Awaited<ReturnType<typeof loadRounds>> }
  if (track === 'math') {
    const [{ rows }, rounds] = await Promise.all([loadFactHistory(supabase, user.id), loadRounds(supabase, user.id)])
    mathStats = {
      points: allCards().reduce((s, c) => s + (rows.get(c.key)?.fluent_at ? c.points : 0), 0),
      fluent: [...rows.values()].filter(r => r.fluent_at).length,
      rounds,
    }
  }
  let geoStats = { points: 0, max: 0, fluent: 0, rounds: [] as Awaited<ReturnType<typeof loadGeoRounds>> }
  if (track === 'geo') {
    const [{ rows }, rounds, kinds] = await Promise.all([
      loadGeoHistory(supabase, user.id), loadGeoRounds(supabase, user.id), availableGeoKinds(supabase),
    ])
    const cards = geoCards(kinds)
    geoStats = {
      points: cards.reduce((s, c) => s + (rows.get(c.key)?.fluent_at ? c.points : 0), 0),
      max: maxGeoPoints(kinds),
      fluent: cards.filter(c => rows.get(c.key)?.fluent_at).length,
      rounds,
    }
  }

  const { data: masteryRaw } = track !== 'hspt' ? { data: null } : await supabase
    .rpc('get_section_mastery', { p_user_id: user.id })

  type MasteryRow = { section: string; score: number; max_score: number; correct: number; seen: number; total: number }
  const mastery = new Map<string, MasteryRow>(
    (masteryRaw ?? []).map((r: MasteryRow) => [r.section, r])
  )

  const googleAvatarUrl = user.user_metadata?.avatar_url || user.user_metadata?.picture || null
  const hasGooglePhoto = !!(profile as Record<string, unknown>).avatar_url
  const displayAvatarUrl = (profile as Record<string, unknown>).avatar_url as string | null

  // Fetch class name if the code is a 5-digit code
  const { data: classRecord } = await supabase
    .from('classes')
    .select('name')
    .eq('code', profile.class_code)
    .single()
  const className = classRecord?.name || null

  return (
    <div className="min-h-screen bg-[#0a0a0f]">
      <TopBar current={track} profile={profile} isAdmin={isAdmin} hrefFor={t => `/profile?t=${t}`} />

      <div className="max-w-4xl mx-auto px-4 py-6 space-y-8">
        <div className="flex items-center justify-between gap-3">
          <Link href={TRACK_HOME[track]} className="text-zinc-400 hover:text-white transition-colors text-sm">← {TRACK_NAME[track]}</Link>
          <h1 className="text-lg font-bold text-white">My Profile</h1>
          <SignOutButton />
        </div>

        {/* Profile header */}
        <div className="bg-white/5 border border-white/10 rounded-3xl p-8 flex flex-col sm:flex-row items-center sm:items-start gap-6">
          <div className="shrink-0">
            {displayAvatarUrl ? (
              <Image
                src={displayAvatarUrl}
                alt={profile.display_name}
                width={96}
                height={96}
                className="rounded-full shadow-2xl"
              />
            ) : (
              <div
                className="w-24 h-24 rounded-full flex items-center justify-center text-4xl font-black text-white shadow-2xl"
                style={{ backgroundColor: profile.avatar_color }}
              >
                {profile.display_name[0].toUpperCase()}
              </div>
            )}
          </div>
          <div className="flex-1 text-center sm:text-left">
            <h2 className="text-3xl font-black text-white">{profile.display_name}</h2>
            <p className="text-zinc-400 mt-1 font-mono text-sm">Class: <span className="text-amber-400 font-bold tracking-widest">{profile.class_code}</span></p>
            <div className="flex flex-wrap gap-3 mt-4 justify-center sm:justify-start">
              {track === 'hspt' && <Stat accent value={leaderboardEntry?.aggregate_score ?? 0} label="Clutch Points" />}
              {track === 'hspt' && <Stat value={totalAttempts} label="Quizzes Taken" />}
              {track === 'math' && <Stat accent value={mathStats.points} label={`Fact Points / ${MAX_FACT_POINTS}`} />}
              {track === 'math' && <Stat value={mathStats.fluent} label="Facts Mastered" />}
              {track === 'geo' && <Stat accent value={geoStats.points} label={`Explorer Points / ${geoStats.max}`} />}
              {track === 'geo' && <Stat value={geoStats.fluent} label="Cards Mastered" />}
              <Stat value={trackEarned} label={`${TRACK_NAME[track]} Badges`} />
            </div>
          </div>
        </div>

        {/* Profile actions: google photo + class change */}
        <ProfileActions
          userId={user.id}
          currentClassCode={profile.class_code}
          currentClassName={className}
          googleAvatarUrl={googleAvatarUrl}
          hasGooglePhoto={hasGooglePhoto}
          avatarColor={profile.avatar_color}
          displayName={profile.display_name}
        />

        {track === 'hspt' && (
          <>
        {/* Section performance */}
        <div>
          <h3 className="text-xl font-bold text-white mb-4">📊 Performance by Section</h3>
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-3">
            {SECTIONS.map(section => {
              const cfg          = SECTION_CONFIG[section]
              const m            = mastery.get(section)
              const sectionScore = m?.score ?? 0
              const maxScore     = m?.max_score ?? 0
              const cpPct        = maxScore > 0 ? Math.min(sectionScore / maxScore * 100, 100) : 0
              return (
                <div key={section} className={`${cfg.bg} border ${cfg.border} rounded-2xl p-5`}>
                  <div className="flex items-center gap-2 mb-3">
                    <span className="text-xl">{cfg.emoji}</span>
                    <span className={`font-semibold ${cfg.color}`}>{cfg.label}</span>
                  </div>
                  <div className="text-3xl font-black text-white mb-0.5">
                    {sectionScore}
                    <span className="text-sm font-normal text-zinc-500"> / {maxScore} pts</span>
                  </div>
                  <div className="h-2.5 bg-white/10 rounded-full overflow-hidden mb-3">
                    <div className="h-full rounded-full transition-all duration-500" style={{ width: `${cpPct}%`, backgroundColor: getAccentHex(cfg.accent) }} />
                  </div>
                  <div className="flex items-center justify-between">
                    <span className={`text-xs ${isSectionComplete(m) ? 'text-cyan-300 font-semibold' : 'text-zinc-600'}`}>
                      {isSectionComplete(m)
                        ? `💪 Complete — ${m!.correct} / ${m!.total}`
                        : m ? `${m.correct} / ${m.total} mastered` : 'No attempts yet'}
                    </span>
                    <Link href={`/quiz/${section}`} className={`text-xs ${cfg.color} hover:underline`}>Practice →</Link>
                  </div>
                </div>
              )
            })}
          </div>
        </div>

        {/* Badge Bestiary */}
        <div className="bg-white/3 border border-white/10 rounded-2xl p-5 flex items-center justify-between">
          <div>
            <h3 className="text-lg font-bold text-white mb-1">🏅 Badge Bestiary</h3>
            <p className="text-zinc-400 text-sm">
              {trackEarned} of {hsptBadges.length} creatures collected
            </p>
            <div className="h-1.5 bg-white/10 rounded-full overflow-hidden mt-2 w-48">
              <div
                className="h-full rounded-full transition-all duration-700"
                style={{
                  width: `${hsptBadges.length ? Math.round((trackEarned / hsptBadges.length) * 100) : 0}%`,
                  background: 'linear-gradient(90deg,#6366f1,#a855f7,#ec4899)',
                }}
              />
            </div>
          </div>
          <Link
            href="/bestiary"
            className="shrink-0 bg-purple-500/20 border border-purple-500/30 text-purple-300 hover:bg-purple-500/30 transition-colors px-4 py-2 rounded-xl text-sm font-semibold"
          >
            View Bestiary →
          </Link>
        </div>

        {/* Recent attempts */}
        {attempts && attempts.length > 0 && (
          <div>
            <h3 className="text-xl font-bold text-white mb-4">📝 Recent Quiz Attempts</h3>
            <div className="space-y-2">
              {attempts.slice(0, 10).map(attempt => {
                const pct = Math.round((attempt.score / attempt.total_questions) * 100)
                const isSection = SECTIONS.includes(attempt.section as Section)
                const cfg = isSection ? SECTION_CONFIG[attempt.section as Section] : null
                const answers = Array.isArray(attempt.answers) ? attempt.answers as QuizAnswer[] : []
                return (
                  <div key={attempt.id} className="bg-white/3 border border-white/5 rounded-xl overflow-hidden">
                    <div className="p-4 flex items-center gap-4">
                      <span className="text-xl">{cfg?.emoji ?? '🎯'}</span>
                      <div className="flex-1 min-w-0">
                        <div className="text-sm font-medium text-white">{cfg?.label ?? 'Full Practice Test'}</div>
                        <div className="text-xs text-zinc-500">
                          {formatAttemptTime(attempt.completed_at!)} · {attempt.total_questions} questions
                        </div>
                      </div>
                      <div className="text-right">
                        <div className={`text-lg font-bold ${pct >= 80 ? 'text-emerald-400' : pct >= 60 ? 'text-amber-400' : 'text-rose-400'}`}>{attempt.score}/{attempt.total_questions}</div>
                        <div className="text-xs text-amber-500">+{attempt.total_xp} CP</div>
                      </div>
                    </div>
                    {answers.length > 0 && <AttemptReview answers={answers} />}
                  </div>
                )
              })}
            </div>
          </div>
        )}

        {(!attempts || attempts.length === 0) && (
          <div className="text-center py-16 bg-white/2 border border-white/5 rounded-2xl">
            <p className="text-4xl mb-3">🎯</p>
            <p className="text-zinc-400 mb-4">No quizzes taken yet.</p>
            <Link href="/quiz/verbal" className="text-amber-400 hover:underline">Start your first quiz →</Link>
          </div>
        )}
          </>
        )}

        {track === 'math' && (
          <>
            <BadgeGroups title="🧮 Math Facts badges" badges={mathBadges} groups={MATH_FACTS_GROUPS}
              groupOf={mathFactsGroup} earned={earnedKeys} tone="border-amber-500/30 bg-amber-500/5" />
            <MathRounds rounds={mathStats.rounds} empty="No Math Facts rounds yet. Your results show up here after each one." />
          </>
        )}

        {/* Empty (and hidden) until the Geography migration is applied. */}
        {track === 'geo' && (
          <>
            <BadgeGroups title="🌍 Geography badges" badges={geoBadges} groups={GEOGRAPHY_GROUPS}
              groupOf={geographyGroup} earned={earnedKeys} tone="border-sky-500/30 bg-sky-500/5" />
            <GeoRounds rounds={geoStats.rounds} empty="No Geography rounds yet. Your results show up here after each one." />
          </>
        )}
      </div>
      <Footer />
    </div>
  )
}
