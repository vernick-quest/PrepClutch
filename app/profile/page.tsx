import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import { SECTION_CONFIG, SECTIONS } from '@/lib/constants'
import Link from 'next/link'
import Image from 'next/image'
import Footer from '@/components/ui/Footer'
import SignOutButton from '@/components/ui/SignOutButton'
import ProfileActions from '@/components/profile/ProfileActions'
import type { Section } from '@/types/database'

export const dynamic = 'force-dynamic'

function getAccentHex(accent: string): string {
  const map: Record<string, string> = {
    amber: '#f59e0b', cyan: '#06b6d4', emerald: '#10b981', rose: '#f43f5e', violet: '#8b5cf6',
  }
  return map[accent] ?? '#ffffff'
}

export default async function ProfilePage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/login')

  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single()

  if (!profile) redirect('/onboarding')

  const { data: attempts } = await supabase
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

  const { data: leaderboardEntry } = await supabase
    .from('leaderboard_view')
    .select('*')
    .eq('user_id', user.id)
    .single()

  const totalXP = attempts?.reduce((s, a) => s + (a.total_xp ?? 0), 0) ?? 0
  const totalAttempts = attempts?.length ?? 0
  const earnedKeys = new Set(userAchievements?.map(a => a.achievement_key) ?? [])

  const sectionBests: Record<Section, number> = {} as Record<Section, number>
  for (const section of SECTIONS) {
    const sAttempts = attempts?.filter(a => a.section === section) ?? []
    sectionBests[section] = sAttempts.length > 0
      ? Math.max(...sAttempts.map(a => Math.round((a.score / a.total_questions) * 100)))
      : 0
  }

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
      {/* Nav */}
      <nav className="border-b border-white/5 sticky top-0 z-50 bg-[#0a0a0f]/80 backdrop-blur-sm">
        <div className="max-w-4xl mx-auto px-4 py-4 flex items-center justify-between">
          <Link href="/" className="text-zinc-400 hover:text-white transition-colors text-sm">← Dashboard</Link>
          <h1 className="text-lg font-bold text-white">My Profile</h1>
          <SignOutButton />
        </div>
      </nav>

      <div className="max-w-4xl mx-auto px-4 py-8 space-y-8">
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
              <div className="bg-amber-500/10 border border-amber-500/20 rounded-xl px-4 py-2 text-center">
                <div className="text-2xl font-black text-amber-400">{totalXP}</div>
                <div className="text-xs text-zinc-400">Total XP</div>
              </div>
              <div className="bg-white/5 border border-white/10 rounded-xl px-4 py-2 text-center">
                <div className="text-2xl font-black text-white">{totalAttempts}</div>
                <div className="text-xs text-zinc-400">Quizzes Taken</div>
              </div>
              <div className="bg-white/5 border border-white/10 rounded-xl px-4 py-2 text-center">
                <div className="text-2xl font-black text-white">{leaderboardEntry?.aggregate_score ?? 0}%</div>
                <div className="text-xs text-zinc-400">Overall Score</div>
              </div>
              <div className="bg-white/5 border border-white/10 rounded-xl px-4 py-2 text-center">
                <div className="text-2xl font-black text-white">{earnedKeys.size}</div>
                <div className="text-xs text-zinc-400">Badges Earned</div>
              </div>
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

        {/* Section performance */}
        <div>
          <h3 className="text-xl font-bold text-white mb-4">📊 Performance by Section</h3>
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-3">
            {SECTIONS.map(section => {
              const cfg = SECTION_CONFIG[section]
              const best = sectionBests[section]
              const sectionAttempts = attempts?.filter(a => a.section === section) ?? []
              return (
                <div key={section} className={`${cfg.bg} border ${cfg.border} rounded-2xl p-5`}>
                  <div className="flex items-center gap-2 mb-3">
                    <span className="text-xl">{cfg.emoji}</span>
                    <span className={`font-semibold ${cfg.color}`}>{cfg.label}</span>
                  </div>
                  <div className="text-4xl font-black text-white mb-2">{best}%</div>
                  <div className="h-2 bg-white/10 rounded-full overflow-hidden mb-2">
                    <div className="h-full rounded-full" style={{ width: `${best}%`, backgroundColor: getAccentHex(cfg.accent) }} />
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-xs text-zinc-400">{sectionAttempts.length} attempt{sectionAttempts.length !== 1 ? 's' : ''}</span>
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
              {earnedKeys.size} of {allAchievements?.length ?? 0} creatures collected
            </p>
            <div className="h-1.5 bg-white/10 rounded-full overflow-hidden mt-2 w-48">
              <div
                className="h-full rounded-full transition-all duration-700"
                style={{
                  width: `${allAchievements?.length ? Math.round((earnedKeys.size / allAchievements.length) * 100) : 0}%`,
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
                return (
                  <div key={attempt.id} className="bg-white/3 border border-white/5 rounded-xl p-4 flex items-center gap-4">
                    <span className="text-xl">{cfg?.emoji ?? '🎯'}</span>
                    <div className="flex-1 min-w-0">
                      <div className="text-sm font-medium text-white">{cfg?.label ?? 'Full Practice Test'}</div>
                      <div className="text-xs text-zinc-500">
                        {new Date(attempt.completed_at!).toLocaleDateString()} · {attempt.total_questions} questions
                      </div>
                    </div>
                    <div className="text-right">
                      <div className={`text-lg font-bold ${pct >= 80 ? 'text-emerald-400' : pct >= 60 ? 'text-amber-400' : 'text-rose-400'}`}>{pct}%</div>
                      <div className="text-xs text-amber-500">+{attempt.total_xp} XP</div>
                    </div>
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
      </div>
      <Footer />
    </div>
  )
}
