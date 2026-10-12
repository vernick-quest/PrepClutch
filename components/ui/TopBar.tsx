import Link from 'next/link'
import Image from 'next/image'
import TrackSwitcher from '@/components/ui/TrackSwitcher'
import type { Track } from '@/lib/tracks'

// The one top bar for the hub and every track: logo (back to the hub), the
// track switcher, and the student. Each track's page shows only that track;
// this bar is how you move between them.
export default function TopBar({ current, profile, isAdmin = false, hrefFor }: {
  current?: Track
  /** Where each track in the switcher goes (the profile: its own tabs). */
  hrefFor?: (t: Track) => string
  profile: { display_name: string; avatar_color: string; avatar_url?: string | null }
  isAdmin?: boolean
}) {
  return (
    <nav
      className="border-b border-white/5 sticky z-50 bg-[#0a0a0f]/80 backdrop-blur-sm"
      style={{ top: 'env(safe-area-inset-top, 0px)' }}
    >
      <div className="max-w-6xl mx-auto px-4 py-3 flex items-center justify-between gap-2">
        <div className="flex items-center gap-2 sm:gap-3 min-w-0">
          {/* text-base under 380px: with three tracks in the switcher, a 360px
              phone has no room for the larger logo. */}
          <Link href="/" className="text-base min-[380px]:text-lg sm:text-xl font-black shrink-0" aria-label="PrepClutch home">
            <span className="text-amber-400">Prep</span><span className="text-white">Clutch</span>
          </Link>
          <TrackSwitcher current={current} hrefFor={hrefFor} />
        </div>
        <div className="flex items-center gap-2 sm:gap-3 shrink-0">
          {isAdmin && (
            <Link href="/admin" className="hidden sm:inline text-xs bg-violet-500/20 border border-violet-500/30 text-violet-400 px-2 py-1 rounded-full font-mono hover:bg-violet-500/30 transition-colors">
              Admin
            </Link>
          )}
          {/* The profile opens on the track you came from. */}
          <Link href={current ? `/profile?t=${current}` : '/profile'} className="flex items-center gap-2 hover:opacity-80 transition-opacity">
            {profile.avatar_url ? (
              <Image src={profile.avatar_url} alt={profile.display_name} width={34} height={34} className="rounded-full shadow-md" />
            ) : (
              <div
                className="w-[34px] h-[34px] rounded-full flex items-center justify-center text-sm font-bold text-white shadow-md"
                style={{ backgroundColor: profile.avatar_color }}
              >
                {profile.display_name?.[0]?.toUpperCase()}
              </div>
            )}
            <span className="text-zinc-300 text-sm hidden md:block">{profile.display_name}</span>
          </Link>
        </div>
      </div>
    </nav>
  )
}
