import { createClient } from '@/lib/supabase/server'
import { redirect, notFound } from 'next/navigation'
import { SECTION_CONFIG, SECTIONS, formatAttemptTime } from '@/lib/constants'
import Link from 'next/link'
import Image from 'next/image'
import Footer from '@/components/ui/Footer'
import AttemptReview from '@/components/quiz/AttemptReview'
import { SECTION_MASTERY_CATEGORY, MATH_FACTS_CATEGORY, GEOGRAPHY_CATEGORY, badgeEmojiStyle, sectionMasteryTier, compareBadges, isSectionComplete } from '@/lib/badges'
import type { Section, QuizAnswer } from '@/types/database'
import { loginUrl, TRACK_HOME } from '@/lib/tracks'
import type { Track } from '@/lib/tracks'
import TrackSwitcher from '@/components/ui/TrackSwitcher'
import { MAX_FACT_POINTS } from '@/lib/math-facts'
import FactGrid from '@/components/math/FactGrid'
import MathRounds from '@/components/math/MathRounds'
import { loadFactHistory, loadRounds, availableTopics } from '@/lib/math-history'
import GeoMap from '@/components/geo/GeoMap'
import GeoRounds from '@/components/geo/GeoRounds'
import { loadGeoHistory, loadGeoRounds, availableGeoKinds } from '@/lib/geo-history'
import { mapCountries, maxGeoPoints } from '@/lib/geo'

export const dynamic = 'force-dynamic'

function getAccentHex(accent: string): string {
  const map: Record<string, string> = {
    amber: '#f59e0b', cyan: '#06b6d4', emerald: '#10b981', rose: '#f43f5e', violet: '#8b5cf6',
  }
  return map[accent] ?? '#ffffff'
}

const RARITY_STYLE: Record<string, { border: string; bg: string; text: string; glow: string }> = {
  Common:    { border: '#1f2937', bg: '#0d1117', text: '#6b7280', glow: 'none' },
  Uncommon:  { border: '#16a34a55', bg: '#0a1a0a', text: '#4ade80', glow: '0 0 16px #22c55e22' },
  Rare:      { border: '#4f46e555', bg: '#0c0c2a', text: '#818cf8', glow: '0 0 20px #6366f133' },
  Epic:      { border: '#7c3aed66', bg: '#160820', text: '#c084fc', glow: '0 0 28px #a855f744' },
  Legendary: { border: '#d9770666', bg: '#1a1200', text: '#fbbf24', glow: '0 0 36px #f59e0b55' },
  Mythic:    { border: '#9333ea99', bg: '#0e0018', text: '#e879f9', glow: '0 0 48px #a855f777' },
  Ascendant: { border: '#06b6d4aa', bg: '#001a1e', text: '#67e8f9', glow: '0 0 56px #06b6d488' },
}

function Stat({ value, label, accent = false }: { value: number; label: string; accent?: boolean }) {
  return (
    <div className={`${accent ? 'bg-amber-500/10 border-amber-500/20' : 'bg-white/5 border-white/10'} border rounded-xl px-4 py-2 text-center`}>
      <div className={`text-2xl font-black ${accent ? 'text-amber-400' : 'text-white'}`}>{value}</div>
      <div className="text-xs text-zinc-400">{label}</div>
    </div>
  )
}

const TRACK_NAME: Record<Track, string> = { hspt: 'HSPT', math: 'Math Facts', geo: 'Geography' }
const HSPT_CATEGORIES = ['First Completion', 'Perfect Score', 'Speed', 'Combo', 'Milestone', SECTION_MASTERY_CATEGORY]

// One track at a time, like your own profile: the one the link came from
// (a Math Facts leaderboard links ?t=math), else the student's home track.
// The switcher under the name flips between them.
export default async function PublicProfilePage({ params, searchParams }: {
  params: Promise<{ id: string }>
  searchParams: Promise<{ t?: string }>
}) {
  const { id } = await params
  const asked = (await searchParams).t
  const askedTrack: Track | null = asked === 'hspt' || asked === 'math' || asked === 'geo' ? asked : null
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect(loginUrl(`/profile/${id}`))

  // Redirect to own profile page which has extra controls
  if (id === user.id) redirect(askedTrack ? `/profile?t=${askedTrack}` : '/profile')

  const { data: profile } = await supabase.from('profiles').select('*').eq('id', id).single()
  if (!profile) notFound()
  const track: Track = askedTrack ?? ((profile as Record<string, unknown>).home_track === 'math' ? 'math' : 'hspt')

  // Admins get the full picture: this student's email (display names are not
  // unique) and their expandable answer review. Everyone else keeps seeing
  // scores only — classmates must not be able to read each other's answers.
  const { data: viewerProfile } = await supabase
    .from('profiles').select('is_admin').eq('id', user.id).single()
  const viewerIsAdmin = !!(viewerProfile as Record<string, unknown>)?.is_admin

  let studentEmail: string | null = null
  if (viewerIsAdmin) {
    const { data: directory } = await supabase.rpc('get_admin_user_directory')
    studentEmail = (directory ?? [])
      .find((d: { user_id: string }) => d.user_id === id)?.email ?? null
  }

  // Admins also see this student's Math Facts progress (migration 068 lets
  // an admin read it). Everyone else sees only the badges.
  const math = viewerIsAdmin && track === 'math'
    ? await Promise.all([loadFactHistory(supabase, id), loadRounds(supabase, id), availableTopics(supabase)])
    : null
  // Same for Geography (its migration gives admins read access). Before that
  // migration is applied, ready is false and the section does not render.
  const geo = viewerIsAdmin && track === 'geo'
    ? await Promise.all([loadGeoHistory(supabase, id), loadGeoRounds(supabase, id), availableGeoKinds(supabase)])
    : null

  const { data: attempts } = track !== 'hspt' ? { data: null } : await supabase
    .from('quiz_attempts')
    .select('*')
    .eq('user_id', id)
    .not('completed_at', 'is', null)
    .order('completed_at', { ascending: false })

  const { data: userAchievements } = await supabase
    .from('user_achievements')
    .select('achievement_key, earned_at')
    .eq('user_id', id)

  const { data: allAchievements } = await supabase
    .from('achievement_definitions')
    .select('*')
    .order('category')

  const { data: leaderboardEntry } = track !== 'hspt' ? { data: null } : await supabase
    .from('leaderboard_view')
    .select('*')
    .eq('user_id', id)
    .single()

  const { data: masteryRaw } = track !== 'hspt' ? { data: null } : await supabase
    .rpc('get_section_mastery', { p_user_id: id })

  type MasteryRow = { section: string; score: number; max_score: number; correct: number; seen: number; total: number }
  const mastery = new Map<string, MasteryRow>(
    (masteryRaw ?? []).map((r: MasteryRow) => [r.section, r])
  )

  const totalAttempts = attempts?.length ?? 0
  const earnedKeys = new Set(userAchievements?.map(a => a.achievement_key) ?? [])
  const displayAvatarUrl = (profile as Record<string, unknown>).avatar_url as string | null
  const badgeCategories = track === 'math' ? [MATH_FACTS_CATEGORY] : track === 'geo' ? [GEOGRAPHY_CATEGORY] : HSPT_CATEGORIES
  const trackBadges = (allAchievements ?? []).filter(b => badgeCategories.includes(b.category))
  const trackEarned = trackBadges.filter(b => earnedKeys.has(b.key)).length

  // Points for Math Facts and Geography come from the public leaderboards,
  // so classmates see them too; the maps and rounds below stay admin-only.
  const { data: board } = track === 'hspt' ? { data: null } : await supabase
    .from(track === 'math' ? 'math_leaderboard_view' : 'geo_leaderboard_view')
    .select('points, fluent').eq('user_id', id).maybeSingle()
  const maxPoints = track === 'math'
    ? MAX_FACT_POINTS
    : track === 'geo' ? maxGeoPoints(geo ? geo[2] : undefined) : 0

  return (
    <div className="min-h-screen bg-[#0a0a0f]">
      <nav className="border-b border-white/5 sticky top-0 z-50 bg-[#0a0a0f]/80 backdrop-blur-sm">
        <div className="max-w-4xl mx-auto px-4 py-4 flex items-center justify-between">
          <Link href={TRACK_HOME[track]} className="text-zinc-400 hover:text-white transition-colors text-sm">← {TRACK_NAME[track]}</Link>
          <h1 className="text-lg font-bold text-white truncate w-0 flex-1 text-center px-2">{profile.display_name}</h1>
          <div className="w-16 shrink-0" />
        </div>
      </nav>

      <div className="max-w-4xl mx-auto px-4 py-8 space-y-8">
        <div className="flex justify-center">
          <TrackSwitcher current={track} hrefFor={t => `/profile/${id}?t=${t}`} />
        </div>
        {/* Profile header */}
        <div className="bg-white/5 border border-white/10 rounded-3xl p-8 flex flex-col sm:flex-row items-center sm:items-start gap-6">
          <div className="shrink-0">
            {displayAvatarUrl ? (
              <Image src={displayAvatarUrl} alt={profile.display_name} width={96} height={96} className="rounded-full shadow-2xl" />
            ) : (
              <div className="w-24 h-24 rounded-full flex items-center justify-center text-4xl font-black text-white shadow-2xl" style={{ backgroundColor: profile.avatar_color }}>
                {profile.display_name[0].toUpperCase()}
              </div>
            )}
          </div>
          <div className="flex-1 text-center sm:text-left">
            <h2 className="text-3xl font-black text-white">{profile.display_name}</h2>
            <p className="text-zinc-400 mt-1 font-mono text-sm">Class: <span className="text-amber-400 font-bold tracking-widest">{profile.class_code}</span></p>
            {studentEmail && (
              <p className="mt-1 font-mono text-xs text-zinc-500">
                {studentEmail}
                <span className="ml-2 text-[10px] bg-violet-500/20 border border-violet-500/30 text-violet-400 px-1.5 py-0.5 rounded-full not-italic">ADMIN VIEW</span>
              </p>
            )}
            <div className="flex flex-wrap gap-3 mt-4 justify-center sm:justify-start">
              {track === 'hspt' && <Stat accent value={leaderboardEntry?.aggregate_score ?? 0} label="Clutch Points" />}
              {track === 'hspt' && <Stat value={totalAttempts} label="Quizzes Taken" />}
              {track !== 'hspt' && (
                <Stat accent value={board?.points ?? 0}
                  label={`${track === 'math' ? 'Fact' : 'Explorer'} Points${maxPoints ? ` / ${maxPoints}` : ''}`} />
              )}
              {track !== 'hspt' && <Stat value={board?.fluent ?? 0} label={track === 'math' ? 'Facts Mastered' : 'Cards Mastered'} />}
              <Stat value={trackEarned} label={`${TRACK_NAME[track]} Badges`} />
            </div>
          </div>
        </div>

        {/* Section performance */}
        {track === 'hspt' && (
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
                  <div className={`text-xs ${isSectionComplete(m) ? 'text-cyan-300 font-semibold' : 'text-zinc-600'}`}>
                    {isSectionComplete(m)
                      ? `💪 Complete — ${m!.correct} / ${m!.total}`
                      : m ? `${m.correct} / ${m.total} mastered` : 'No attempts yet'}
                  </div>
                </div>
              )
            })}
          </div>
        </div>

        )}

        {/* Badges */}
        <div>
          <div className="flex items-center gap-3 mb-4">
            <h3 className="text-xl font-bold text-white">🏅 Badges</h3>
            <span className="text-sm text-zinc-500">{trackEarned} / {trackBadges.length}</span>
          </div>
          {badgeCategories.map(cat => {
            // Easiest first, same ordering the Bestiary uses. The query only
            // orders by category, so without this the section-mastery biceps
            // come back scrambled.
            const catBadges = (allAchievements ?? [])
              .filter(b => b.category === cat)
              .slice()
              .sort((a, b) => compareBadges(
                { key: a.key, rarity: a.rarity ?? '', label: a.label ?? '' },
                { key: b.key, rarity: b.rarity ?? '', label: b.label ?? '' },
              ))
            if (!catBadges.length) return null
            // Section mastery holds exactly six tiers per section, so pinning
            // it to six columns puts one section per row and the arm grows
            // left to right. Four columns would split every section in half.
            const gridCols = cat === SECTION_MASTERY_CATEGORY
              ? 'grid grid-cols-2 sm:grid-cols-6 gap-2'
              : 'grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-5 gap-2'
            return (
              <div key={cat} className="mb-6">
                <div className="flex items-center gap-3 mb-3">
                  <span className="text-[10px] font-bold text-zinc-500 tracking-[3px] uppercase">{cat}</span>
                  <div className="flex-1 h-px bg-white/5" />
                </div>
                <div className={gridCols}>
                  {catBadges.map(badge => {
                    const earned = earnedKeys.has(badge.key)
                    const r = RARITY_STYLE[badge.rarity ?? 'Common'] ?? RARITY_STYLE.Common
                    return (
                      <div key={badge.key} className="rounded-xl p-3 flex flex-col items-center gap-1.5 text-center" style={{
                        background: earned ? r.bg : '#080c14',
                        border: `1px solid ${earned ? r.border : '#111827'}`,
                        opacity: earned ? 1 : 0.25,
                        filter: earned ? 'none' : 'grayscale(1)',
                      }}>
                        <div style={earned && sectionMasteryTier(badge.key) > 0
                          ? badgeEmojiStyle(badge.key, 24, r.text)
                          : { fontSize: 24, lineHeight: 1 }}>
                          {earned ? badge.icon_emoji : '❓'}
                        </div>
                        <div className="text-[10px] font-bold" style={{ color: earned ? r.text : '#1f2937' }}>
                          {earned ? badge.label : '???'}
                        </div>
                      </div>
                    )
                  })}
                </div>
              </div>
            )
          })}
        </div>

        {/* Math Facts, admins only */}
        {math && math[0].ready && (
          <div className="space-y-4">
            <h3 className="text-xl font-bold text-white">🧮 Math Facts</h3>
            <div className="grid lg:grid-cols-2 gap-4">
              <FactGrid history={Object.fromEntries(math[0].rows)} topics={math[2]} readOnly />
              <MathRounds rounds={math[1]} title="📋 Their recent rounds" empty="No Math Facts rounds yet." />
            </div>
          </div>
        )}

        {/* Geography, admins only */}
        {geo && geo[0].ready && (
          <div className="space-y-4">
            <h3 className="text-xl font-bold text-white">🌍 Geography</h3>
            <div className="grid lg:grid-cols-2 gap-4">
              <GeoMap history={Object.fromEntries(geo[0].rows)} countries={mapCountries()} kinds={geo[2]} readOnly />
              <GeoRounds rounds={geo[1]} title="📋 Their recent rounds" empty="No Geography rounds yet." />
            </div>
          </div>
        )}

        {/* Recent attempts */}
        {attempts && attempts.length > 0 && (
          <div>
            <h3 className="text-xl font-bold text-white mb-4">📝 Quiz History</h3>
            <div className="space-y-2">
              {attempts.slice(0, 20).map(attempt => {
                const pct = Math.round((attempt.score / attempt.total_questions) * 100)
                const isSection = SECTIONS.includes(attempt.section as Section)
                const cfg = isSection ? SECTION_CONFIG[attempt.section as Section] : null
                return (
                  <div key={attempt.id} className="bg-white/3 border border-white/5 rounded-xl p-4">
                    <div className="flex items-center gap-4">
                      <span className="text-xl">{cfg?.emoji ?? '🎯'}</span>
                      <div className="flex-1">
                        <div className="text-sm font-medium text-white">{cfg?.label ?? 'Full Practice Test'}</div>
                        <div className="text-xs text-zinc-500">{formatAttemptTime(attempt.completed_at!)} · {attempt.total_questions} Q</div>
                      </div>
                      <div className="text-right">
                        <div className={`text-lg font-bold ${pct >= 80 ? 'text-emerald-400' : pct >= 60 ? 'text-amber-400' : 'text-rose-400'}`}>{attempt.score}/{attempt.total_questions}</div>
                        <div className="text-xs text-amber-500">+{attempt.total_xp} CP</div>
                      </div>
                    </div>
                    {/* Admins only — a classmate must not be able to read this
                        student's questions and answers. */}
                    {viewerIsAdmin && attempt.answers && (
                      <AttemptReview answers={attempt.answers as QuizAnswer[]} />
                    )}
                  </div>
                )
              })}
            </div>
          </div>
        )}
      </div>
      <Footer />
    </div>
  )
}
