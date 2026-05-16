'use client'

import { useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import { useRouter } from 'next/navigation'
import Image from 'next/image'

interface Props {
  userId: string
  currentClassCode: string
  currentClassName?: string | null
  googleAvatarUrl?: string | null
  hasGooglePhoto: boolean
  avatarColor: string
  displayName: string
}

export default function ProfileActions({
  userId,
  currentClassCode,
  currentClassName,
  googleAvatarUrl,
  hasGooglePhoto,
  avatarColor,
  displayName,
}: Props) {
  const router = useRouter()
  const [classInput, setClassInput] = useState('')
  const [newClassName, setNewClassName] = useState('')
  const [classLoading, setClassLoading] = useState(false)
  const [classMsg, setClassMsg] = useState<{ type: 'error' | 'success'; text: string } | null>(null)
  const [showCreate, setShowCreate] = useState(false)
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
    const name = newClassName.trim()
    if (!name) { setClassMsg({ type: 'error', text: 'Give your class a name first.' }); return }
    setClassLoading(true)
    setClassMsg(null)
    const res = await fetch('/api/create-class', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name }),
    })
    const data = await res.json()
    if (data.error) {
      setClassMsg({ type: 'error', text: 'Failed to create class.' })
    } else {
      setClassMsg({ type: 'success', text: `Class "${data.name}" created! Code: ${data.code} — share this with your classmates.` })
      setNewClassName('')
      setShowCreate(false)
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
          <div className="shrink-0">
            {hasGooglePhoto ? (
              <Image src={googleAvatarUrl} alt="Google" width={48} height={48} className="rounded-full" />
            ) : (
              <div className="w-12 h-12 rounded-full flex items-center justify-center text-xl font-black text-white" style={{ backgroundColor: avatarColor }}>
                {displayName[0]?.toUpperCase()}
              </div>
            )}
          </div>
          <div className="flex-1">
            <div className="text-sm font-medium text-white mb-0.5">Profile Photo</div>
            <div className="text-xs text-zinc-400">{hasGooglePhoto ? 'Using Google photo' : 'Using color avatar'}</div>
          </div>
          <button
            onClick={handleToggleGooglePhoto}
            disabled={photoLoading}
            className="text-xs px-3 py-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-zinc-300 transition-colors disabled:opacity-50 shrink-0"
          >
            {photoLoading ? '…' : hasGooglePhoto ? 'Remove' : 'Use Google Photo'}
          </button>
        </div>
      )}

      {/* Class management */}
      <div className="bg-white/5 border border-white/10 rounded-2xl p-5 space-y-4">
        {/* Current class */}
        <div>
          <div className="text-xs text-zinc-500 uppercase tracking-widest mb-1">Current Class</div>
          {currentClassName && (
            <div className="text-white font-semibold text-lg">{currentClassName}</div>
          )}
          <div className="font-mono text-2xl font-black text-amber-400 tracking-[0.3em]">{currentClassCode}</div>
          <div className="text-xs text-zinc-500 mt-1">Share this code so classmates can join your class.</div>
        </div>

        <div className="border-t border-white/10 pt-4 space-y-3">
          {/* Join existing */}
          <div>
            <div className="text-xs text-zinc-400 mb-2">Join a different class</div>
            <div className="flex gap-2">
              <input
                type="text"
                value={classInput}
                onChange={e => setClassInput(e.target.value.replace(/\D/g, '').slice(0, 5))}
                placeholder="5-digit code"
                className="flex-1 bg-white/5 border border-white/10 rounded-xl px-4 py-2.5 text-white font-mono text-base focus:outline-none focus:border-amber-500/50 transition-colors"
              />
              <button
                onClick={handleJoinClass}
                disabled={classLoading || classInput.length !== 5}
                className="px-4 py-2.5 bg-amber-500 hover:bg-amber-400 text-black font-bold rounded-xl text-sm transition-colors disabled:opacity-40"
              >
                Join
              </button>
            </div>
          </div>

          {/* Create new */}
          {!showCreate ? (
            <button
              onClick={() => setShowCreate(true)}
              className="text-xs text-zinc-500 hover:text-zinc-300 transition-colors"
            >
              + Create a new class
            </button>
          ) : (
            <div className="space-y-2">
              <div className="text-xs text-zinc-400">New class name</div>
              <input
                type="text"
                value={newClassName}
                onChange={e => setNewClassName(e.target.value)}
                placeholder="e.g. Mrs. Smith's Class"
                maxLength={60}
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-2.5 text-white text-sm focus:outline-none focus:border-amber-500/50 transition-colors"
              />
              <div className="flex gap-2">
                <button
                  onClick={handleCreateClass}
                  disabled={classLoading || !newClassName.trim()}
                  className="flex-1 py-2.5 bg-amber-500 hover:bg-amber-400 text-black font-bold rounded-xl text-sm transition-colors disabled:opacity-40"
                >
                  {classLoading ? 'Creating…' : 'Create & Get Code'}
                </button>
                <button
                  onClick={() => { setShowCreate(false); setNewClassName('') }}
                  className="px-4 py-2.5 bg-white/5 hover:bg-white/10 text-zinc-400 rounded-xl text-sm transition-colors"
                >
                  Cancel
                </button>
              </div>
            </div>
          )}
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
