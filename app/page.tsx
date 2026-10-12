import Link from 'next/link'
import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import TopBar from '@/components/ui/TopBar'
import Footer from '@/components/ui/Footer'

export const dynamic = 'force-dynamic'

// prepclutch.com: the hub. One card per subject, nothing else. Each card opens
// a page that shows only that subject; the top bar moves between them. New
// subjects are new cards here.

interface Subject {
  href:   string
  emoji:  string
  title:  string
  blurb:  string
  stat?:  string
  accent: string
}

export default async function HubPage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/login')

  const { data: profile } = await supabase.from('profiles').select('*').eq('id', user.id).single()
  if (!profile) redirect('/onboarding')

  // Points for each card. Any read can fail softly: a card without its
  // number still works (geo_leaderboard_view does not exist until the
  // Geography migration is applied).
  const [{ data: hspt }, { data: math }, { data: geo }] = await Promise.all([
    supabase.from('leaderboard_view').select('aggregate_score').eq('user_id', user.id).maybeSingle(),
    supabase.from('math_leaderboard_view').select('points, fluent').eq('user_id', user.id).maybeSingle(),
    supabase.from('geo_leaderboard_view').select('points, fluent').eq('user_id', user.id).maybeSingle(),
  ])

  const subjects: Subject[] = [
    {
      href: '/hspt', emoji: '🎓', title: 'HSPT Prep',
      blurb: 'The High School Placement Test: quizzes, training and full practice tests across all 5 sections.',
      stat: hspt ? `${hspt.aggregate_score.toLocaleString()} Clutch Points` : undefined,
      accent: 'from-amber-500/15 border-amber-500/30 hover:border-amber-500/60',
    },
    {
      href: '/math', emoji: '🧮', title: 'Math Facts',
      blurb: 'Times tables, equivalent fractions, and fractions, decimals & percents. Get them right, then get them fast.',
      stat: math ? `${math.points.toLocaleString()} Fact Points · ${math.fluent} cards mastered` : undefined,
      accent: 'from-emerald-500/15 border-emerald-500/30 hover:border-emerald-500/60',
    },
    {
      href: '/geo', emoji: '🌍', title: 'Geography',
      blurb: 'Capitals, flags, money, languages and continents for all 193 countries. Explore the world, one card at a time.',
      stat: geo ? `${geo.points.toLocaleString()} Explorer Points · ${geo.fluent} cards mastered` : undefined,
      accent: 'from-sky-500/15 border-sky-500/30 hover:border-sky-500/60',
    },
  ]

  return (
    <div className="min-h-screen bg-[#0a0a0f] flex flex-col">
      <TopBar profile={profile} isAdmin={profile.is_admin === true} />

      <main className="flex-1 max-w-4xl w-full mx-auto px-4 py-10">
        <h1 className="text-3xl font-black text-white">
          Hey, {profile.display_name.split(' ')[0]}! 👋
        </h1>
        <p className="text-zinc-400 mt-1">What do you want to play today?</p>

        <div className="grid sm:grid-cols-2 gap-4 mt-8">
          {subjects.map(s => (
            <Link
              key={s.href}
              href={s.href}
              className={`group rounded-3xl border bg-gradient-to-br to-transparent p-6 transition-all hover:scale-[1.01] active:scale-[0.99] ${s.accent}`}
            >
              <span className="text-5xl">{s.emoji}</span>
              <h2 className="text-2xl font-black text-white mt-4">{s.title}</h2>
              <p className="text-sm text-zinc-400 mt-1.5 leading-relaxed">{s.blurb}</p>
              <div className="flex items-center justify-between mt-6">
                <span className="text-sm font-semibold text-zinc-200">{s.stat ?? ''}</span>
                <span className="text-sm font-bold text-white group-hover:translate-x-0.5 transition-transform">Open →</span>
              </div>
            </Link>
          ))}

          {/* Where the next subject goes. */}
          <div className="rounded-3xl border border-dashed border-white/10 p-6 flex items-center gap-4">
            <span className="text-3xl opacity-50">🔭</span>
            <div>
              <p className="font-bold text-zinc-400">More subjects on the way</p>
              <p className="text-sm text-zinc-600">All with points, badges and leaderboards.</p>
            </div>
          </div>
        </div>

        <p className="text-center text-xs text-zinc-600 mt-10">PrepClutch · Learning through play</p>
      </main>
      <Footer />
    </div>
  )
}
