// ── Tracks: HSPT prep and Math Facts ─────────────────────────────────────────
//
// PrepClutch is two things behind one login. A student picks one at sign-up
// (profiles.home_track, migration 065) and lands there on every later sign-in;
// the TrackSwitcher in each top bar moves between them at any time.
//
// Sign-in also remembers where a link was pointing. A friend sent to /math
// used to be bounced through Google and dropped on the HSPT dashboard with no
// visible way back.

export type Track = 'hspt' | 'math'

export const TRACK_HOME: Record<Track, string> = { hspt: '/hspt', math: '/math' }

const NEXT_KEY = 'prepclutch:next'

/** An in-app path, or null. Refuses anything that could leave the site
 *  ("//evil.com", "https://...", "/\\evil.com"). */
export function safeNext(raw: string | null | undefined): string | null {
  if (!raw || !raw.startsWith('/') || raw.startsWith('//') || raw.startsWith('/\\')) return null
  if (raw.startsWith('/login') || raw.startsWith('/auth')) return null
  return raw
}

const under = (path: string, root: string) =>
  path === root || path.startsWith(root + '/') || path.startsWith(root + '?')

/** The track a path belongs to, if it clearly belongs to one. Profiles, the
 *  Bestiary and admin belong to both, so they return null. */
export function trackOf(path: string | null): Track | null {
  if (!path) return null
  if (under(path, '/math')) return 'math'
  if (['/hspt', '/quiz', '/training', '/results'].some(r => under(path, r))) return 'hspt'
  return null
}

/** Sign-in that finishes on `path`. Every page that requires a signed-in
 *  student sends visitors here, so a direct link survives the Google round
 *  trip. The bare homepage passes no path: it is the hub, the default. */
export function loginUrl(path: string): string {
  return `/login?next=${encodeURIComponent(path)}`
}

// Kept in sessionStorage across the Google round trip rather than in the
// OAuth redirect URL: Supabase only redirects to allow-listed URLs, and an
// unexpected query string there could send the sign-in to the wrong page.
export function rememberNext(path: string | null) {
  try {
    if (path) window.sessionStorage.setItem(NEXT_KEY, path)
    else window.sessionStorage.removeItem(NEXT_KEY)
  } catch { /* private mode: they land on their home track instead */ }
}

export function takeNext(): string | null {
  try {
    const v = safeNext(window.sessionStorage.getItem(NEXT_KEY))
    window.sessionStorage.removeItem(NEXT_KEY)
    return v
  } catch { return null }
}

export function peekNext(): string | null {
  try { return safeNext(window.sessionStorage.getItem(NEXT_KEY)) } catch { return null }
}
