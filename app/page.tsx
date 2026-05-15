import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import { SECTION_CONFIG, SECTIONS } from '@/lib/constants'
import Link from 'next/link'
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

  const { data: userAchievements } = await supabase
    .from('user_achievements')
    .select('achievement_key')
    .eq('user_id', user.id)

  const { data: allAchievements } = await supabase
    .from('achievement_definitions')
    .select('*')

  const myEntry = leaderboard?.find(e => e.user_id === user.id)
  const myRank = leaderboard?.findIndex(e => e.user_id === user.id) ?? -1
  const earnedKeys = new Set(userAchievements?.map(a => a.achievement_key) ?? [])

  return (
    <div className="min-h-screen bg-[#0a0a0f]">
      {/* Nav */}
      <nav className="border-b border-white/5 sticky top-0 z-50 bg-[#0a0a0f]/80 backdrop-blur-sm">
        <div className="max-w-6xl mx-auto px-4 py-4 flex items-center justify-between">
          <Link href="/" className="text-xl font-black">
            <span className="text-amber-400">HSPT</span>
            <span className="text-white"> Prep</span>
          </Link>
          <div className="flex items-center gap-3">
            <Link href="/profile" className="flex items-center gap-2 hover:opacity-80 transition-opacity">
              <div
                className="w-9 h-9 rounded-full flex items-center justify-center text-sm font-bold text-white shadow-md"
                style={{ backgroundColor: profile.avatar_color }}
              >
                {profile.display_name[0].toUpperCase()}
              </div>
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
              ? `Ranked #${myRank + 1} in ${profile.class_code}`
              : `Class: ${profile.class_code}`}
          </p>
        </div>

        {/* Score tiles */}
        {myEntry && (
          <div className="grid grid-cols-3 sm:grid-cols-6 gap-3">
            <div className="col-span-1 bg-white/5 border border-white/10 rounded-2xl p-4 flex flex-col items-center justify-center min-h-[80px]">
              <div className="text-2xl font-black text-amber-400">{myEntry.aggregate_score}%</div>
              <div className="text-[10px] text-zinc-400 mt-1 text-center">Overall</div>
            </div>
            {SECTIONS.map(section => {
              const score = (myEntry as Record<string, unknown>)[`${section}_score`] as number
              const cfg = SECTION_CONFIG[section]
              return (
                <div key={section} className={`${cfg.bg} border ${cfg.border} rounded-2xl p-3 flex flex-col items-center justify-center`}>
                  <div className="text-xl font-black" style={{ color: getAccentHex(cfg.accent) }}>{score}%</div>
                  <div className="text-[10px] text-zinc-400 mt-1 text-center leading-tight">{cfg.emoji}</div>
                </div>
              )
            })}
          </div>
        )}

        <div className="grid lg:grid-cols-3 gap-8">
          {/* Leaderboard */}
          <div className="lg:col-span-2 space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-bold text-white">🏆 Leaderboard — {profile.class_code}</h2>
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
                      <div
                        className="w-10 h-10 rounded-full flex items-center justify-center text-base font-black text-white shrink-0"
                        style={{ backgroundColor: entry.avatar_color }}
                      >
                        {entry.display_name[0].toUpperCase()}
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-1 flex-wrap">
                          <span className={`font-semibold ${isMe ? 'text-amber-400' : 'text-white'}`}>
                            {entry.display_name}
                          </span>
                          {isMe && <span className="text-xs text-amber-500/70">(you)</span>}
                        </div>
                        {/* Section mini-bars */}
                        <div className="flex gap-1 mt-2">
                          {SECTIONS.map(section => {
                            const score = (entry as Record<string, unknown>)[`${section}_score`] as number
                            const cfg = SECTION_CONFIG[section]
                            return (
                              <div
                                key={section}
                                className="flex-1"
                                title={`${cfg.label}: ${score}%`}
                              >
                                <div className="h-1.5 bg-white/10 rounded-full overflow-hidden">
                                  <div
                                    className="h-full rounded-full"
                                    style={{
                                      width: `${score}%`,
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
                        <div className="text-xl font-black text-white">{entry.aggregate_score}%</div>
                        <div className="text-xs text-zinc-500">{entry.total_xp} XP</div>
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

          {/* Right panel */}
          <div className="space-y-6">
            {/* Practice CTA */}
            <div>
              <h2 className="text-xl font-bold text-white mb-4">⚡ Start Practice</h2>
              <div className="space-y-2">
                <Link
                  href="/quiz/full"
                  className="flex items-center gap-3 w-full bg-amber-500 hover:bg-amber-400 text-black font-bold py-3.5 px-4 rounded-2xl transition-colors group"
                >
                  <span className="text-xl">🎯</span>
                  <span>Full Practice Test</span>
                  <span className="ml-auto text-xs opacity-70 group-hover:opacity-100">50 Q</span>
                </Link>
                {SECTIONS.map(section => {
                  const cfg = SECTION_CONFIG[section]
                  return (
                    <Link
                      key={section}
                      href={`/quiz/${section}`}
                      className={`flex items-center gap-3 w-full ${cfg.bg} border ${cfg.border} text-white font-medium py-3 px-4 rounded-xl transition-all hover:scale-[1.01] active:scale-[0.99]`}
                    >
                      <span>{cfg.emoji}</span>
                      <span className="text-sm">{cfg.label}</span>
                      <span className="ml-auto text-xs text-zinc-400">10 Q</span>
                    </Link>
                  )
                })}
              </div>
            </div>

            {/* Achievements */}
            <div>
              <h2 className="text-xl font-bold text-white mb-4">🏅 Achievements</h2>
              <div className="bg-white/3 border border-white/5 rounded-2xl p-4">
                {allAchievements && allAchievements.length > 0 ? (
                  <div className="grid grid-cols-2 gap-2">
                    {allAchievements.map(ach => {
                      const earned = earnedKeys.has(ach.key)
                      return (
                        <div
                          key={ach.key}
                          title={`${ach.label}: ${ach.description}`}
                          className={`rounded-xl p-2 text-center transition-all cursor-default ${
                            earned
                              ? 'bg-amber-500/10 border border-amber-500/20'
                              : 'opacity-30 grayscale'
                          }`}
                        >
                          <div className="text-2xl">{ach.icon_emoji}</div>
                          <div className="text-[11px] text-zinc-300 mt-1 leading-tight">{ach.label}</div>
                        </div>
                      )
                    })}
                  </div>
                ) : (
                  <p className="text-zinc-500 text-sm text-center py-6">Complete quizzes to earn achievements!</p>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
      <Footer />
    </div>
  )
}
