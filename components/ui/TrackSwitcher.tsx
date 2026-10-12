import Link from 'next/link'
import type { Track } from '@/lib/tracks'

// The site-wide top-bar choice. Each track's page shows only that track; this
// is how you move between them (and the logo goes back to the hub). On the
// hub itself nothing is selected.
export default function TrackSwitcher({ current }: { current?: Track }) {
  const item = (track: Track, href: string, label: string, short: string) => (
    <Link
      href={href}
      aria-current={current === track ? 'page' : undefined}
      className={`px-1.5 min-[380px]:px-2 sm:px-3 py-1.5 rounded-lg text-xs sm:text-sm font-bold whitespace-nowrap transition-colors ${
        current === track ? 'bg-white/10 text-white' : 'text-zinc-500 hover:text-zinc-200'
      }`}
    >
      <span className="sm:hidden">{short}</span>
      <span className="hidden sm:inline">{label}</span>
    </Link>
  )
  return (
    <div className="flex items-center gap-0.5 p-0.5 rounded-xl border border-white/10 bg-white/3">
      {item('hspt', '/hspt', '🎓 HSPT', '🎓 HSPT')}
      {item('math', '/math', '🧮 Math Facts', '🧮 Math')}
      {item('geo', '/geo', '🌍 Geography', '🌍 Geo')}
    </div>
  )
}
