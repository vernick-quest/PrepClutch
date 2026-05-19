import { createClient } from '@/lib/supabase/server'
import { redirect, notFound } from 'next/navigation'
import { SECTION_CONFIG, SECTIONS, MAX_SECTION_XP } from '@/lib/constants'
import Link from 'next/link'
import Image from 'next/image'
import Footer from '@/components/ui/Footer'
import type { Section } from '@/types/database'

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
}

export default async function PublicProfilePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/login')

  // Redirect to own profile page which has extra controls
  if (id === user.id) redirect('/profile')

  const { data: profile } = await supabase.from('profiles').select('*').eq('id', id).single()
  if (!profile) notFound()

  const { data: attempts } = await supabase
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

  const { data: leaderboardEntry } = await supabase
    .from('leaderboard_view')
    .select('*')
    .eq('user_id', id)
    .single()

  const { data: coverageRaw } = await supabase
    .rpc('get_section_coverage', { p_user_id: id })

  const coverage = new Map<string, { correct: number; seen: number; total: number }>(
    (coverageRaw ?? []).map((r: { section: string; correct: number; seen: number; total: number }) =>
      [r.section, { correct: r.correct ?? r.seen ?? 0, seen: r.seen ?? 0, total: r.total ?? 0 }]
    )
  )

  const totalAttempts = attempts?.length ?? 0
  const earnedKeys = new Set(userAchievements?.map(a => a.achievement_key) ?? [])
  const displayAvatarUrl = (profile as Record<string, unknown>).avatar_url as string | null
  const badgeCategories = ['First Completion', 'Perfect Score', 'Speed', 'Combo', 'Milestone']

  return (
    <div className="min-h-screen bg-[#0a0a0f]">
      <nav className="border-b border-white/5 sticky top-0 z-50 bg-[#0a0a0f]/80 backdrop-blur-sm">
        <div className="max-w-4xl mx-auto px-4 py-4 flex items-center justify-between">
          <Link href="/" className="text-zinc-400 hover:text-white transition-colors text-sm">← Dashboard</Link>
          <h1 className="text-lg font-bold text-white">{profile.display_name}</h1>
          <div />
        </div>
      </nav>

      <div className="max-w-4xl mx-auto px-4 py-8 space-y-8">
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
            <div className="flex flex-wrap gap-3 mt-4 justify-center sm:justify-start">
              <div className="bg-amber-500/10 border border-amber-500/20 rounded-xl px-4 py-2 text-center">
                <div className="text-2xl font-black text-amber-400">{leaderboardEntry?.aggregate_score ?? 0}</div>
                <div className="text-xs text-zinc-400">Clutch Points</div>
              </div>
              <div className="bg-white/5 border border-white/10 rounded-xl px-4 py-2 text-center">
                <div className="text-2xl font-black text-white">{totalAttempts}</div>
                <div className="text-xs text-zinc-400">Quizzes Taken</div>
              </div>
              <div className="bg-white/5 border border-white/10 rounded-xl px-4 py-2 text-center">
                <div className="text-2xl font-black text-white">{earnedKeys.size}</div>
                <div className="text-xs text-zinc-400">Badges Earned</div>
              </div>
            </div>
          </div>
        </div>

        {/* Section performance */}
        <div>
          <h3 className="text-xl font-bold text-white mb-4">📊 Performance by Section</h3>
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-3">
            {SECTIONS.map(section => {
              const cfg = SECTION_CONFIG[section]
              const sectionScore = (leaderboardEntry?.[`${section}_score` as keyof typeof leaderboardEntry] as number) ?? 0
              const cov = coverage.get(section)
              const sectionAttempts = attempts?.filter(a => a.section === section) ?? []
              return (
                <div key={section} className={`${cfg.bg} border ${cfg.border} rounded-2xl p-5`}>
                  <div className="flex items-center gap-2 mb-3">
                    <span className="text-xl">{cfg.emoji}</span>
                    <span className={`font-semibold ${cfg.color}`}>{cfg.label}</span>
                  </div>
                  <div className="text-4xl font-black text-white mb-1">{sectionScore} <span className="text-sm font-normal text-zinc-500">pts</span></div>
                  <div className="h-2 bg-white/10 rounded-full overflow-hidden mb-2">
                    <div className="h-full rounded-full" style={{ width: `${Math.min(sectionScore / MAX_SECTION_XP * 100, 100)}%`, backgroundColor: getAccentHex(cfg.accent) }} />
                  </div>
                  {cov ? (
                    <div className="mt-3 pt-3 border-t border-white/5">
                      <div className="flex items-center justify-between text-xs text-zinc-500 mb-1">
                        <span>Mastered</span>
                        <span className="text-zinc-400">{cov.correct}/{cov.total} correct</span>
                      </div>
                      <div className="h-1.5 bg-white/10 rounded-full overflow-hidden">
                        <div className="h-full rounded-full" style={{ width: `${cov.total > 0 ? Math.round(cov.correct / cov.total * 100) : 0}%`, backgroundColor: getAccentHex(cfg.accent), opacity: 0.5 }} />
                      </div>
                    </div>
                  ) : (
                    <div className="text-xs text-zinc-500">{sectionAttempts.length} attempt{sectionAttempts.length !== 1 ? 's' : ''}</div>
                  )}
                </div>
              )
            })}
          </div>
        </div>

        {/* Badges */}
        <div>
          <div className="flex items-center gap-3 mb-4">
            <h3 className="text-xl font-bold text-white">🏅 Badges</h3>
            <span className="text-sm text-zinc-500">{earnedKeys.size} / {allAchievements?.length ?? 0}</span>
          </div>
          {badgeCategories.map(cat => {
            const catBadges = (allAchievements ?? []).filter(b => b.category === cat)
            if (!catBadges.length) return null
            return (
              <div key={cat} className="mb-6">
                <div className="flex items-center gap-3 mb-3">
                  <span className="text-[10px] font-bold text-zinc-500 tracking-[3px] uppercase">{cat}</span>
                  <div className="flex-1 h-px bg-white/5" />
                </div>
                <div className="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-5 gap-2">
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
                        <div className="text-2xl">{earned ? badge.icon_emoji : '❓'}</div>
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
                  <div key={attempt.id} className="bg-white/3 border border-white/5 rounded-xl p-4 flex items-center gap-4">
                    <span className="text-xl">{cfg?.emoji ?? '🎯'}</span>
                    <div className="flex-1">
                      <div className="text-sm font-medium text-white">{cfg?.label ?? 'Full Practice Test'}</div>
                      <div className="text-xs text-zinc-500">{new Date(attempt.completed_at!).toLocaleDateString()} · {attempt.total_questions} Q</div>
                    </div>
                    <div className="text-right">
                      <div className={`text-lg font-bold ${pct >= 80 ? 'text-emerald-400' : pct >= 60 ? 'text-amber-400' : 'text-rose-400'}`}>{attempt.score}/{attempt.total_questions}</div>
                      <div className="text-xs text-amber-500">+{attempt.total_xp} CP</div>
                    </div>
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
