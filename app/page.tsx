import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import { SECTION_CONFIG, SECTIONS, MAX_SECTION_XP } from '@/lib/constants'
import Link from 'next/link'
import Image from 'next/image'
import Footer from '@/components/ui/Footer'
import type { Section } from '@/types/database'

export const dynamic = 'force-dynamic'

function getAccentHex(accent: string): string {
  const map: Record<string, string> = {
    amber: '#f59e0b',
    cyan: '#06b6d4',
    emerald: '#10b981',
    rose: '#f43f5e',
    violet: '#8b5cf6',
  }
  return map[accent] ?? '#ffffff'
}

export default async function DashboardPage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) redirect('/login')

  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single()

  if (!profile) redirect('/onboarding')

  const { data: leaderboard } = await supabase
    .from('leaderboard_view')
    .select('*')
    .eq('class_code', profile.class_code)
    .order('aggregate_score', { ascending: false })

  const { data: globalLeaderboard } = await supabase
    .from('leaderboard_view')
    .select('*')
    .order('aggregate_score', { ascending: false })
    .limit(50)

  const { data: classRow } = await supabase
    .from('classes')
    .select('name')
    .eq('code', profile.class_code)
    .single()

  const className = classRow?.name || profile.class_code

  const { data: coverageRaw } = await supabase
    .rpc('get_section_coverage', { p_user_id: user.id })

  const coverage = new Map<string, { correct: number; seen: number; total: number }>(
    (coverageRaw ?? []).map((r: { section: string; correct: number; seen: number; total: number }) =>
      [r.section, { correct: r.correct ?? r.seen ?? 0, seen: r.seen ?? 0, total: r.total ?? 0 }]
    )
  )

  const myEntry = leaderboard?.find(e => e.user_id === user.id)
  const myRank = leaderboard?.findIndex(e => e.user_id === user.id) ?? -1
  const isAdmin = (profile as Record<string, unknown>).is_admin === true

  return (
    <div className="min-h-screen bg-[#0a0a0f]">
      {/* Nav */}
      <nav className="border-b border-white/5 sticky top-0 z-50 bg-[#0a0a0f]/80 backdrop-blur-sm">
        <div className="max-w-6xl mx-auto px-4 py-4 flex items-center justify-between">
          <Link href="/" className="text-xl font-black">
            <span className="text-amber-400">Prep</span>
            <span className="text-white">Clutch</span>
          </Link>
          <div className="flex items-center gap-3">
            {isAdmin && (
              <Link href="/admin" className="text-xs bg-violet-500/20 border border-violet-500/30 text-violet-400 px-2 py-1 rounded-full font-mono hover:bg-violet-500/30 transition-colors">
                Admin
              </Link>
            )}
            <Link href="/profile" className="flex items-center gap-2 hover:opacity-80 transition-opacity">
              {profile.avatar_url ? (
                <Image
                  src={profile.avatar_url as string}
                  alt={profile.display_name}
                  width={36}
                  height={36}
                  className="rounded-full shadow-md"
                />
              ) : (
                <div
                  className="w-9 h-9 rounded-full flex items-center justify-center text-sm font-bold text-white shadow-md"
                  style={{ backgroundColor: profile.avatar_color }}
                >
                  {profile.display_name[0].toUpperCase()}
                </div>
              )}
              <span className="text-zinc-300 text-sm hidden sm:block">{profile.display_name}</span>
            </Link>
          </div>
        </div>
      </nav>

      <div className="max-w-6xl mx-auto px-4 py-8 space-y-8">
        {/* Header */}
        <div>
          <h1 className="text-3xl font-black text-white">
            Hey, {profile.display_name.split(' ')[0]}! 👋
          </h1>
          <p className="text-zinc-400 mt-1">
            {myRank === 0
              ? '👑 You\'re #1 in your class!'
              : myRank > 0
              ? `Ranked #${myRank + 1} in ${className}`
              : `Class: ${className}`}
          </p>
        </div>

        {/* Start Practice */}
        <div>
          <h2 className="text-xl font-bold text-white mb-1">⚡ Start Practice</h2>
          <p className="text-zinc-500 text-sm mb-3">Choose a full practice run, or select an individual test section.</p>
          <div className="flex flex-col sm:flex-row gap-2">
            <Link
              href="/quiz/full"
              className="flex items-center gap-3 sm:w-56 bg-amber-500 hover:bg-amber-400 text-black font-bold py-3.5 px-4 rounded-2xl transition-colors group shrink-0"
            >
              <span className="text-xl">🎯</span>
              <span>All Sections</span>
              <span className="ml-auto text-xs opacity-70 group-hover:opacity-100">50 Q</span>
            </Link>
            <div className="grid grid-cols-3 sm:grid-cols-5 gap-2 flex-1">
              {SECTIONS.map(section => {
                const cfg = SECTION_CONFIG[section]
                return (
                  <Link
                    key={section}
                    href={`/quiz/${section}`}
                    className={`flex flex-col items-center gap-1 ${cfg.bg} border ${cfg.border} text-white font-bold py-3 px-2 rounded-xl transition-all hover:scale-[1.02] active:scale-[0.99]`}
                  >
                    <span className="text-xl">{cfg.emoji}</span>
                    <span className="text-[12px] text-center leading-tight">{cfg.label}</span>
                    <span className="text-[10px] text-zinc-400 font-normal">10 Q</span>
                  </Link>
                )
              })}
            </div>
          </div>
        </div>

        <div className="grid lg:grid-cols-3 gap-8">
          {/* Leaderboards */}
          <div className="lg:col-span-2 space-y-8">

            {/* Class leaderboard */}
            <div className="space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-bold text-white">🏆 Class — {className}</h2>
            </div>

            <div className="space-y-2">
              {leaderboard && leaderboard.length > 0 ? leaderboard.map((entry, idx) => {
                const isMe = entry.user_id === user.id
                const rankLabel = idx === 0 ? '👑' : idx === 1 ? '🥈' : idx === 2 ? '🥉' : `#${idx + 1}`

                return (
                  <div
                    key={entry.user_id}
                    className={`rounded-2xl p-4 border transition-all ${
                      isMe
                        ? 'bg-amber-500/10 border-amber-500/30'
                        : 'bg-white/3 border-white/5 hover:border-white/10'
                    }`}
                  >
                    <div className="flex items-center gap-3">
                      <span className="text-xl w-8 text-center font-bold shrink-0">{rankLabel}</span>
                      {entry.avatar_url ? (
                        <Image
                          src={entry.avatar_url}
                          alt={entry.display_name}
                          width={40}
                          height={40}
                          className="rounded-full shrink-0"
                        />
                      ) : (
                        <div
                          className="w-10 h-10 rounded-full flex items-center justify-center text-base font-black text-white shrink-0"
                          style={{ backgroundColor: entry.avatar_color }}
                        >
                          {entry.display_name[0].toUpperCase()}
                        </div>
                      )}
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-1 flex-wrap">
                          {isMe ? (
                            <Link href="/profile" className="font-semibold text-amber-400 hover:text-amber-300 transition-colors">
                              {entry.display_name}
                            </Link>
                          ) : (
                            <Link href={`/profile/${entry.user_id}`} className="font-semibold text-white hover:text-amber-400 transition-colors">
                              {entry.display_name}
                            </Link>
                          )}
                          {isMe && <span className="text-xs text-amber-500/70">(you)</span>}
                        </div>
                        {/* Section mini-bars */}
                        <div className="flex gap-1 mt-2">
                          {SECTIONS.map(section => {
                            const score = entry[`${section}_score` as keyof typeof entry] as number
                            const cfg = SECTION_CONFIG[section]
                            return (
                              <div
                                key={section}
                                className="flex-1"
                                title={`${cfg.label}: ${score} pts`}
                              >
                                <div className="h-1.5 bg-white/10 rounded-full overflow-hidden">
                                  <div
                                    className="h-full rounded-full"
                                    style={{
                                      width: `${Math.min(score / MAX_SECTION_XP * 100, 100)}%`,
                                      backgroundColor: score > 0 ? getAccentHex(cfg.accent) : 'transparent',
                                    }}
                                  />
                                </div>
                              </div>
                            )
                          })}
                        </div>
                      </div>
                      <div className="text-right shrink-0">
                        <div className="text-xl font-black text-white">{entry.aggregate_score} <span className="text-sm font-normal text-zinc-500">pts</span></div>
                      </div>
                    </div>
                  </div>
                )
              }) : (
                <div className="text-center py-16 text-zinc-500 bg-white/2 border border-white/5 rounded-2xl">
                  <p className="text-4xl mb-2">🏫</p>
                  <p>No classmates yet.</p>
                  <p className="text-sm mt-1">Share code <strong className="text-zinc-300">{profile.class_code}</strong> with your class!</p>
                </div>
              )}
            </div>
            </div>

            {/* Global leaderboard */}
            <div className="space-y-4">
              <h2 className="text-xl font-bold text-white">🌍 Global Leaderboard</h2>
              <div className="space-y-2">
                {globalLeaderboard && globalLeaderboard.length > 0 ? globalLeaderboard.map((entry, idx) => {
                  const isMe = entry.user_id === user.id
                  const rankLabel = idx === 0 ? '👑' : idx === 1 ? '🥈' : idx === 2 ? '🥉' : `#${idx + 1}`
                  return (
                    <div
                      key={entry.user_id}
                      className={`rounded-2xl p-4 border transition-all ${
                        isMe
                          ? 'bg-amber-500/10 border-amber-500/30'
                          : 'bg-white/3 border-white/5 hover:border-white/10'
                      }`}
                    >
                      <div className="flex items-center gap-3">
                        <span className="text-xl w-8 text-center font-bold shrink-0">{rankLabel}</span>
                        {entry.avatar_url ? (
                          <Image
                            src={entry.avatar_url}
                            alt={entry.display_name}
                            width={40}
                            height={40}
                            className="rounded-full shrink-0"
                          />
                        ) : (
                          <div
                            className="w-10 h-10 rounded-full flex items-center justify-center text-base font-black text-white shrink-0"
                            style={{ backgroundColor: entry.avatar_color }}
                          >
                            {entry.display_name[0].toUpperCase()}
                          </div>
                        )}
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-1 flex-wrap">
                            {isMe ? (
                              <Link href="/profile" className="font-semibold text-amber-400 hover:text-amber-300 transition-colors">
                                {entry.display_name}
                              </Link>
                            ) : (
                              <Link href={`/profile/${entry.user_id}`} className="font-semibold text-white hover:text-amber-400 transition-colors">
                                {entry.display_name}
                              </Link>
                            )}
                            {isMe && <span className="text-xs text-amber-500/70">(you)</span>}
                            <span className="text-xs text-zinc-600 ml-1">{entry.class_code}</span>
                          </div>
                          <div className="flex gap-1 mt-2">
                            {SECTIONS.map(section => {
                              const score = entry[`${section}_score` as keyof typeof entry] as number
                              const cfg = SECTION_CONFIG[section]
                              return (
                                <div key={section} className="flex-1" title={`${cfg.label}: ${score} pts`}>
                                  <div className="h-1.5 bg-white/10 rounded-full overflow-hidden">
                                    <div
                                      className="h-full rounded-full"
                                      style={{
                                        width: `${Math.min(score / MAX_SECTION_XP * 100, 100)}%`,
                                        backgroundColor: score > 0 ? getAccentHex(cfg.accent) : 'transparent',
                                      }}
                                    />
                                  </div>
                                </div>
                              )
                            })}
                          </div>
                        </div>
                        <div className="text-right shrink-0">
                          <div className="text-xl font-black text-white">{entry.aggregate_score} <span className="text-sm font-normal text-zinc-500">pts</span></div>
                        </div>
                      </div>
                    </div>
                  )
                }) : (
                  <div className="text-center py-8 text-zinc-500 bg-white/2 border border-white/5 rounded-2xl">
                    <p>No global entries yet.</p>
                  </div>
                )}
              </div>
            </div>

          </div>

          {/* Right panel — Progress */}
          <div className="space-y-4">
            <h2 className="text-xl font-bold text-white">📊 Your Progress</h2>
            {myEntry ? (
              <>
                {/* Overall Clutch Points card — no fixed width so large numbers don't clip */}
                <div className="bg-white/5 border border-white/10 rounded-2xl p-4">
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-xs text-zinc-400">Overall Clutch Points</span>
                    <span className="text-2xl font-black text-amber-400 tabular-nums">
                      {myEntry.aggregate_score}
                      <span className="text-sm font-normal text-zinc-500 ml-1">pts</span>
                    </span>
                  </div>
                  <div className="h-2.5 bg-white/10 rounded-full overflow-hidden">
                    <div
                      className="h-full rounded-full bg-amber-500"
                      style={{ width: `${Math.min(myEntry.aggregate_score / (MAX_SECTION_XP * SECTIONS.length) * 100, 100)}%` }}
                    />
                  </div>
                </div>

                {/* Per-section cards */}
                {SECTIONS.map(section => {
                  const score = myEntry[`${section}_score` as keyof typeof myEntry] as number
                  const cov   = coverage.get(section)
                  const cfg   = SECTION_CONFIG[section]
                  const cpPct = Math.min(score / MAX_SECTION_XP * 100, 100)
                  const masteryPct = cov && cov.total > 0
                    ? Math.min((cov.correct / cov.total) * 100, 100)
                    : 0

                  return (
                    <div key={section} className={`${cfg.bg} border ${cfg.border} rounded-2xl p-4`}>
                      {/* Header row */}
                      <div className="flex items-center justify-between mb-3">
                        <div className="flex items-center gap-2">
                          <span className="text-xl">{cfg.emoji}</span>
                          <span className={`text-xs font-semibold ${cfg.color}`}>{cfg.label}</span>
                        </div>
                        <span className="text-sm font-black text-white tabular-nums">
                          {score}
                          <span className="text-xs font-normal text-zinc-500"> / 500 pts</span>
                        </span>
                      </div>

                      {/* Clutch Points bar — primary */}
                      <div className="h-3 bg-white/10 rounded-full overflow-hidden mb-3">
                        <div
                          className="h-full rounded-full transition-all duration-500"
                          style={{
                            width: `${cpPct}%`,
                            backgroundColor: getAccentHex(cfg.accent),
                          }}
                        />
                      </div>

                      {/* Mastery bar — secondary, more subtle */}
                      <div className="flex justify-between items-center mb-1">
                        <span className="text-[10px] text-zinc-600">Questions mastered</span>
                        <span className="text-[10px] text-zinc-600 tabular-nums">
                          {cov ? `${cov.correct} / ${cov.total}` : '— / —'}
                        </span>
                      </div>
                      <div className="h-1.5 bg-white/5 rounded-full overflow-hidden">
                        <div
                          className="h-full rounded-full transition-all duration-500"
                          style={{
                            width: `${masteryPct}%`,
                            backgroundColor: getAccentHex(cfg.accent) + '70',
                          }}
                        />
                      </div>
                    </div>
                  )
                })}
              </>
            ) : (
              <div className="text-center py-12 bg-white/2 border border-white/5 rounded-2xl">
                <p className="text-4xl mb-2">🎯</p>
                <p className="text-zinc-500 text-sm">Complete a quiz to see your progress!</p>
              </div>
            )}
          </div>
        </div>
      </div>
      <Footer />
    </div>
  )
}
