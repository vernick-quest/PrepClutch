import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import Link from 'next/link'
import AdminClassEditor from '@/components/admin/AdminClassEditor'

export const dynamic = 'force-dynamic'

export default async function AdminPage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/login')

  const { data: viewerProfile } = await supabase.from('profiles').select('is_admin').eq('id', user.id).single()
  if (!(viewerProfile as Record<string, unknown>)?.is_admin) redirect('/')

  const { data: allProfiles } = await supabase
    .from('profiles')
    .select('id, display_name, class_code')
    .order('display_name')

  const { data: allClasses } = await supabase
    .from('classes')
    .select('code, name, created_at')
    .order('created_at')

  const profiles = allProfiles ?? []
  const classes = allClasses ?? []

  // Count members per class code
  const memberCounts: Record<string, number> = {}
  for (const p of profiles) {
    memberCounts[p.class_code] = (memberCounts[p.class_code] ?? 0) + 1
  }

  const classRows = classes.map(c => ({
    code: c.code,
    name: c.name,
    memberCount: memberCounts[c.code] ?? 0,
  }))

  // Include classes from profiles that aren't in the classes table (legacy codes)
  const knownCodes = new Set(classes.map(c => c.code))
  const legacyCodes = [...new Set(profiles.map(p => p.class_code))].filter(c => !knownCodes.has(c))
  for (const code of legacyCodes) {
    classRows.push({ code, name: '', memberCount: memberCounts[code] ?? 0 })
  }

  return (
    <div className="min-h-screen bg-[#0a0a0f]">
      <nav className="border-b border-white/5 sticky top-0 z-50 bg-[#0a0a0f]/80 backdrop-blur-sm">
        <div className="max-w-4xl mx-auto px-4 py-4 flex items-center justify-between">
          <Link href="/" className="text-zinc-400 hover:text-white transition-colors text-sm">← Dashboard</Link>
          <div className="flex items-center gap-2">
            <span className="text-xs bg-violet-500/20 border border-violet-500/30 text-violet-400 px-2 py-0.5 rounded-full font-mono">ADMIN</span>
            <h1 className="text-lg font-bold text-white">Class Manager</h1>
          </div>
          <div className="text-xs text-zinc-500">{profiles.length} students</div>
        </div>
      </nav>

      <div className="max-w-4xl mx-auto px-4 py-8">
        <AdminClassEditor
          classes={classRows}
          students={profiles}
        />
      </div>
    </div>
  )
}
