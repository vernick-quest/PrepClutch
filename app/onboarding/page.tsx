'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { AVATAR_COLORS } from '@/lib/constants'

export default function OnboardingPage() {
  const router = useRouter()
  const [displayName, setDisplayName] = useState('')
  const [classCode, setClassCode] = useState('')
  const [selectedColor, setSelectedColor] = useState(AVATAR_COLORS[0])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    if (!displayName.trim() || !classCode.trim()) {
      setError('Please fill in all fields.')
      return
    }

    setLoading(true)
    setError('')

    const supabase = createClient()
    const { data: { user } } = await supabase.auth.getUser()

    if (!user) {
      router.push('/login')
      return
    }

    const { error: insertError } = await supabase.from('profiles').insert({
      id: user.id,
      display_name: displayName.trim(),
      class_code: classCode.trim().toUpperCase(),
      avatar_color: selectedColor,
    })

    if (insertError) {
      setError('Something went wrong. Please try again.')
      setLoading(false)
      return
    }

    router.push('/')
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
            <label className="block text-sm font-medium text-zinc-300 mb-2">Class / Group Code</label>
            <input
              type="text"
              value={classCode}
              onChange={e => setClassCode(e.target.value.toUpperCase())}
              placeholder="e.g. MRS-SMITH-2025"
              maxLength={20}
              className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-white placeholder-zinc-500 focus:outline-none focus:border-amber-500/50 focus:ring-1 focus:ring-amber-500/30 transition-colors font-mono"
            />
            <p className="mt-1 text-xs text-zinc-500">Ask your teacher for the class code.</p>
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
