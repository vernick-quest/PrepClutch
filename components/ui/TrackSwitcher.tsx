import Link from 'next/link'
import type { Track } from '@/lib/tracks'

// HSPT ⇄ Math Facts, in the top bar of both dashboards, so nobody who lands
// on one is stranded there.
export default function TrackSwitcher({ current }: { current: Track }) {
  const item = (track: Track, href: string, label: string) => (
    <Link
      href={href}
      aria-current={current === track ? 'page' : undefined}
      className={`px-3 py-1.5 rounded-lg text-xs sm:text-sm font-bold whitespace-nowrap transition-colors ${
        current === track ? 'bg-white/10 text-white' : 'text-zinc-500 hover:text-zinc-200'
      }`}
    >
      {label}
    </Link>
  )
  return (
    <div className="flex items-center gap-0.5 p-0.5 rounded-xl border border-white/10 bg-white/3">
      {item('hspt', '/', '🎓 HSPT')}
      {item('math', '/math', '🧮 Math Facts')}
    </div>
  )
}
