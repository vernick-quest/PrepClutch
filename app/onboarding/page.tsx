'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { AVATAR_COLORS, normalizeClassCode } from '@/lib/constants'
import { peekNext, takeNext, trackOf, TRACK_HOME } from '@/lib/tracks'
import type { Track } from '@/lib/tracks'

const TRACK_CHOICES: { track: Track; emoji: string; title: string; blurb: string }[] = [
  { track: 'math', emoji: '🧮', title: 'Math Facts', blurb: 'Times tables, fractions, decimals' },
  { track: 'hspt', emoji: '🎓', title: 'HSPT prep',  blurb: 'High school placement test' },
]

export default function OnboardingPage() {
  const router = useRouter()
  const [displayName, setDisplayName] = useState('')
  const [classCode, setClassCode] = useState('')
  const [selectedColor, setSelectedColor] = useState(AVATAR_COLORS[0])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [track, setTrack] = useState<Track | null>(null)

  // Arrived from a Math Facts or HSPT link? Pre-pick that track.
  // sessionStorage only exists in the browser, so this has to happen after the
  // first render.
  useEffect(() => {
    const fromLink = trackOf(peekNext())
    // eslint-disable-next-line react-hooks/set-state-in-effect
    if (fromLink) setTrack(fromLink)
  }, [])

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    if (!track) {
      setError('Pick Math Facts or HSPT prep to start. You can switch any time.')
      return
    }
    if (!displayName.trim()) {
      setError('Please enter a display name.')
      return
    }

    setLoading(true)
    setError('')

    // The class code is optional, but a typo must not silently drop a student
    // into a class of one. Blank = no class (global leaderboard only).
    const code = classCode.trim()
    if (code) {
      const { data: found } = await createClient()
        .from('classes').select('code').eq('code', code).maybeSingle()
      if (!found) {
        setError(`We couldn't find class code ${code}. Check it with your teacher, or leave it blank.`)
        setLoading(false)
        return
      }
    }

    const supabase = createClient()
    const { data: { user } } = await supabase.auth.getUser()

    if (!user) {
      router.push('/login')
      return
    }

    const { error: insertError } = await supabase.from('profiles').insert({
      id: user.id,
      display_name: displayName.trim(),
      class_code: code,
      avatar_color: selectedColor,
    })

    if (insertError) {
      setError('Something went wrong. Please try again.')
      setLoading(false)
      return
    }

    // Saved separately from the insert: before migration 065 the column does
    // not exist, and an unknown column would fail the whole profile insert.
    await supabase.from('profiles').update({ home_track: track }).eq('id', user.id)

    // Follow the link they came in on, unless it belongs to the other track.
    const next = takeNext()
    router.push(next && (trackOf(next) ?? track) === track ? next : TRACK_HOME[track])
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-[#0a0a0f] px-4">
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-0 left-1/4 w-96 h-96 bg-amber-500/10 rounded-full blur-3xl" />
        <div className="absolute bottom-0 right-1/4 w-96 h-96 bg-violet-500/10 rounded-full blur-3xl" />
      </div>

      <div className="relative z-10 w-full max-w-md">
        <div className="text-center mb-8">
          <div className="text-5xl mb-3">👋</div>
          <h1 className="text-3xl font-black text-white mb-2">Set Up Your Profile</h1>
          <p className="text-zinc-400">Just a couple things to get you started.</p>
        </div>

        <form onSubmit={handleSubmit} className="bg-white/5 border border-white/10 rounded-2xl p-8 backdrop-blur-sm space-y-6">
          {/* What they came for. Both live behind this one sign-in; the top bar
              switches between them later. */}
          <div>
            <label className="block text-sm font-medium text-zinc-300 mb-3">What are you here for?</label>
            <div className="grid grid-cols-2 gap-3">
              {TRACK_CHOICES.map(c => (
                <button
                  key={c.track}
                  type="button"
                  onClick={() => setTrack(c.track)}
                  className={`rounded-2xl border p-4 text-left transition-all ${
                    track === c.track
                      ? 'border-amber-500/60 bg-amber-500/10 ring-1 ring-amber-500/40'
                      : 'border-white/10 bg-white/3 hover:border-white/25'
                  }`}
                >
                  <span className="block text-3xl mb-1">{c.emoji}</span>
                  <span className="block font-bold text-white">{c.title}</span>
                  <span className="block text-xs text-zinc-400 mt-0.5">{c.blurb}</span>
                </button>
              ))}
            </div>
            <p className="mt-2 text-xs text-zinc-500">You can switch between them any time from the top bar.</p>
          </div>

          {/* Avatar color picker */}
          <div>
            <label className="block text-sm font-medium text-zinc-300 mb-3">Choose your color</label>
            <div className="flex flex-wrap gap-3">
              {AVATAR_COLORS.map(color => (
                <button
                  key={color}
                  type="button"
                  onClick={() => setSelectedColor(color)}
                  className={`w-10 h-10 rounded-full transition-all ${selectedColor === color ? 'ring-2 ring-white ring-offset-2 ring-offset-[#0a0a0f] scale-110' : 'hover:scale-105'}`}
                  style={{ backgroundColor: color }}
                />
              ))}
            </div>
          </div>

          {/* Preview avatar */}
          <div className="flex justify-center">
            <div
              className="w-20 h-20 rounded-full flex items-center justify-center text-3xl font-black text-white shadow-lg"
              style={{ backgroundColor: selectedColor }}
            >
              {displayName ? displayName[0].toUpperCase() : '?'}
            </div>
          </div>

          {/* Display name */}
          <div>
            <label className="block text-sm font-medium text-zinc-300 mb-2">Display Name</label>
            <input
              type="text"
              value={displayName}
              onChange={e => setDisplayName(e.target.value)}
              placeholder="e.g. Alex Johnson"
              maxLength={30}
              className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-white placeholder-zinc-500 focus:outline-none focus:border-amber-500/50 focus:ring-1 focus:ring-amber-500/30 transition-colors"
            />
          </div>

          {/* Class code */}
          <div>
            <label className="block text-sm font-medium text-zinc-300 mb-2">
              Class Code <span className="font-normal text-zinc-500">(optional)</span>
            </label>
            <input
              type="text"
              value={classCode}
              onChange={e => setClassCode(normalizeClassCode(e.target.value))}
              placeholder="Leave blank if you don't have one"
              className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-white placeholder-zinc-500 focus:outline-none focus:border-amber-500/50 focus:ring-1 focus:ring-amber-500/30 transition-colors font-mono"
            />
            <p className="mt-1 text-xs text-zinc-500">
              Only if a teacher or tutor gave you one. It puts you on your class
              leaderboard. You can add it later from your profile.
            </p>
          </div>

          {error && (
            <p className="text-rose-400 text-sm text-center">{error}</p>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-amber-500 hover:bg-amber-400 disabled:opacity-50 text-black font-bold py-3.5 rounded-xl transition-colors"
          >
            {loading ? 'Setting up…' : "Let's Go! 🚀"}
          </button>
        </form>
      </div>
    </div>
  )
}
