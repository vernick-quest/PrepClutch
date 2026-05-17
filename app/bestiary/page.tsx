import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import Link from 'next/link'
import BestiaryClient from '@/components/challenge/BestiaryClient'

export const dynamic = 'force-dynamic'

export default async function BestiaryPage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/login')

  const { data: profile } = await supabase
    .from('profiles')
    .select('display_name, avatar_color, is_admin')
    .eq('id', user.id)
    .single()

  if (!profile) redirect('/onboarding')

  const [{ data: allBadges }, { data: userAchievements }] = await Promise.all([
    supabase.from('achievement_definitions').select('key, label, icon_emoji, description, rarity, creature, category, lore').order('category'),
    supabase.from('user_achievements').select('achievement_key').eq('user_id', user.id),
  ])

  const isAdmin   = (profile as Record<string, unknown>).is_admin === true
  const earnedKeys = (userAchievements ?? []).map(a => a.achievement_key)

  return (
    <div className="min-h-screen bg-[#080c14]">
      <nav className="border-b border-white/5 sticky top-0 z-50 bg-[#080c14]/80 backdrop-blur-sm">
        <div className="max-w-6xl mx-auto px-4 py-4 grid grid-cols-3 items-center">
          <Link href="/" className="text-xl font-black">
            <span className="text-amber-400">Prep</span>
            <span className="text-white">Clutch</span>
          </Link>
          <div className="text-center">
            <span className="text-sm font-semibold text-zinc-400 tracking-widest uppercase">Badge Bestiary</span>
          </div>
          <div className="flex items-center gap-3 justify-end">
            {isAdmin && (
              <Link href="/admin" className="text-xs bg-violet-500/20 border border-violet-500/30 text-violet-400 px-2 py-1 rounded-full font-mono hover:bg-violet-500/30 transition-colors">
                Admin
              </Link>
            )}
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

      <BestiaryClient
        displayName={profile.display_name}
        avatarColor={profile.avatar_color}
        allBadges={allBadges ?? []}
        earnedKeys={earnedKeys}
      />
    </div>
  )
}
