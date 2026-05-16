'use client'

import { useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import { useRouter } from 'next/navigation'
import Image from 'next/image'

interface Props {
  userId: string
  currentClassCode: string
  googleAvatarUrl?: string | null
  hasGooglePhoto: boolean
  avatarColor: string
  displayName: string
}

export default function ProfileActions({
  userId,
  currentClassCode,
  googleAvatarUrl,
  hasGooglePhoto,
  avatarColor,
  displayName,
}: Props) {
  const router = useRouter()
  const [classInput, setClassInput] = useState('')
  const [classLoading, setClassLoading] = useState(false)
  const [classMsg, setClassMsg] = useState<{ type: 'error' | 'success'; text: string } | null>(null)
  const [photoLoading, setPhotoLoading] = useState(false)

  async function handleJoinClass() {
    const code = classInput.trim()
    if (code.length !== 5) { setClassMsg({ type: 'error', text: 'Enter a 5-digit class code.' }); return }
    setClassLoading(true)
    setClassMsg(null)
    const supabase = createClient()
    const { error } = await supabase.from('profiles').update({ class_code: code }).eq('id', userId)
    if (error) {
      setClassMsg({ type: 'error', text: 'Failed to update class.' })
    } else {
      setClassMsg({ type: 'success', text: `Joined class ${code}!` })
      setClassInput('')
      router.refresh()
    }
    setClassLoading(false)
  }

  async function handleCreateClass() {
    setClassLoading(true)
    setClassMsg(null)
    const res = await fetch('/api/create-class', { method: 'POST' })
    const data = await res.json()
    if (data.error) {
      setClassMsg({ type: 'error', text: 'Failed to create class.' })
    } else {
      setClassMsg({ type: 'success', text: `Created class ${data.code}! Share this code with your classmates.` })
      router.refresh()
    }
    setClassLoading(false)
  }

  async function handleToggleGooglePhoto() {
    setPhotoLoading(true)
    const supabase = createClient()
    const newUrl = hasGooglePhoto ? null : googleAvatarUrl
    await supabase.from('profiles').update({ avatar_url: newUrl }).eq('id', userId)
    setPhotoLoading(false)
    router.refresh()
  }

  return (
    <div className="space-y-6">
      {/* Google photo toggle */}
      {googleAvatarUrl && (
        <div className="flex items-center gap-4 bg-white/5 border border-white/10 rounded-2xl p-4">
          <div className="relative">
            {hasGooglePhoto ? (
              <Image src={googleAvatarUrl} alt="Google" width={48} height={48} className="rounded-full" />
            ) : (
              <div className="w-12 h-12 rounded-full flex items-center justify-center text-xl font-black text-white" style={{ backgroundColor: avatarColor }}>
                {displayName[0]?.toUpperCase()}
              </div>
            )}
          </div>
          <div className="flex-1">
            <div className="text-sm font-medium text-white mb-1">Profile Photo</div>
            <div className="text-xs text-zinc-400">{hasGooglePhoto ? 'Using Google photo' : 'Using color avatar'}</div>
          </div>
          <button
            onClick={handleToggleGooglePhoto}
            disabled={photoLoading}
            className="text-xs px-3 py-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-zinc-300 transition-colors disabled:opacity-50"
          >
            {photoLoading ? '…' : hasGooglePhoto ? 'Remove' : 'Use Google Photo'}
          </button>
        </div>
      )}

      {/* Class management */}
      <div className="bg-white/5 border border-white/10 rounded-2xl p-5 space-y-4">
        <div>
          <div className="text-sm font-medium text-zinc-300 mb-1">Current Class</div>
          <div className="font-mono text-2xl font-black text-amber-400 tracking-widest">{currentClassCode}</div>
          <div className="text-xs text-zinc-500 mt-1">Share this code with classmates so they can join your class.</div>
        </div>

        <div className="border-t border-white/10 pt-4">
          <div className="text-sm font-medium text-zinc-300 mb-2">Join a different class</div>
          <div className="flex gap-2">
            <input
              type="text"
              value={classInput}
              onChange={e => setClassInput(e.target.value.replace(/\D/g, '').slice(0, 5))}
              placeholder="5-digit code"
              className="flex-1 bg-white/5 border border-white/10 rounded-xl px-4 py-2.5 text-white font-mono text-base focus:outline-none focus:border-amber-500/50 focus:ring-1 focus:ring-amber-500/20 transition-colors"
            />
            <button
              onClick={handleJoinClass}
              disabled={classLoading || classInput.length !== 5}
              className="px-4 py-2.5 bg-amber-500 hover:bg-amber-400 text-black font-bold rounded-xl text-sm transition-colors disabled:opacity-40"
            >
              Join
            </button>
          </div>
          <button
            onClick={handleCreateClass}
            disabled={classLoading}
            className="mt-2 text-xs text-zinc-500 hover:text-zinc-300 transition-colors disabled:opacity-50"
          >
            + Create a new class (auto-generates a 5-digit code)
          </button>
        </div>

        {classMsg && (
          <p className={`text-xs ${classMsg.type === 'error' ? 'text-rose-400' : 'text-emerald-400'}`}>
            {classMsg.text}
          </p>
        )}
      </div>
    </div>
  )
}
