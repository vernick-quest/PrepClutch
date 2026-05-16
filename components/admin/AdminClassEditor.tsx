'use client'

import { useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import { useRouter } from 'next/navigation'

interface ClassRow {
  code: string
  name: string
  memberCount: number
}

interface StudentRow {
  id: string
  display_name: string
  class_code: string
}

interface Props {
  classes: ClassRow[]
  students: StudentRow[]
}

export default function AdminClassEditor({ classes, students }: Props) {
  const router = useRouter()
  const [editingClass, setEditingClass] = useState<string | null>(null)
  const [editName, setEditName] = useState('')
  const [editingStudent, setEditingStudent] = useState<string | null>(null)
  const [editCode, setEditCode] = useState('')
  const [saving, setSaving] = useState(false)
  const [msg, setMsg] = useState<{ type: 'error' | 'success'; text: string } | null>(null)

  async function saveClassName(code: string) {
    if (!editName.trim()) return
    setSaving(true)
    setMsg(null)
    const supabase = createClient()
    const { error } = await supabase.from('classes').update({ name: editName.trim() }).eq('code', code)
    if (error) {
      setMsg({ type: 'error', text: `Failed to rename class: ${error.message}` })
    } else {
      setMsg({ type: 'success', text: `Class renamed to "${editName.trim()}"` })
      setEditingClass(null)
      router.refresh()
    }
    setSaving(false)
  }

  async function saveStudentCode(studentId: string) {
    const code = editCode.trim()
    if (code.length !== 5) { setMsg({ type: 'error', text: 'Code must be exactly 5 digits.' }); return }
    setSaving(true)
    setMsg(null)
    const supabase = createClient()
    const { error } = await supabase.from('profiles').update({ class_code: code }).eq('id', studentId)
    if (error) {
      setMsg({ type: 'error', text: `Failed to update student: ${error.message}` })
    } else {
      setMsg({ type: 'success', text: `Student moved to class ${code}` })
      setEditingStudent(null)
      router.refresh()
    }
    setSaving(false)
  }

  return (
    <div className="space-y-8">
      {msg && (
        <div className={`px-4 py-2 rounded-xl text-sm ${msg.type === 'error' ? 'bg-rose-500/10 text-rose-400' : 'bg-emerald-500/10 text-emerald-400'}`}>
          {msg.text}
        </div>
      )}

      {/* Classes */}
      <div>
        <h2 className="text-lg font-bold text-white mb-3">All Classes</h2>
        <div className="space-y-2">
          {classes.length === 0 && <p className="text-zinc-500 text-sm">No classes created yet.</p>}
          {classes.map(cls => (
            <div key={cls.code} className="bg-white/5 border border-white/10 rounded-2xl p-4">
              {editingClass === cls.code ? (
                <div className="flex gap-2 items-center">
                  <input
                    type="text"
                    value={editName}
                    onChange={e => setEditName(e.target.value)}
                    placeholder="Class name"
                    maxLength={60}
                    className="flex-1 bg-white/10 border border-white/20 rounded-xl px-3 py-2 text-white text-sm focus:outline-none focus:border-amber-500/50"
                  />
                  <button onClick={() => saveClassName(cls.code)} disabled={saving} className="px-3 py-2 bg-amber-500 text-black font-bold rounded-xl text-sm disabled:opacity-40">
                    {saving ? '…' : 'Save'}
                  </button>
                  <button onClick={() => setEditingClass(null)} className="px-3 py-2 bg-white/5 text-zinc-400 rounded-xl text-sm">
                    Cancel
                  </button>
                </div>
              ) : (
                <div className="flex items-center gap-3">
                  <div className="flex-1">
                    <div className="font-semibold text-white">{cls.name || <span className="text-zinc-500 italic">Unnamed class</span>}</div>
                    <div className="text-sm font-mono text-amber-400 tracking-widest">{cls.code}</div>
                    <div className="text-xs text-zinc-500 mt-0.5">{cls.memberCount} member{cls.memberCount !== 1 ? 's' : ''}</div>
                  </div>
                  <button
                    onClick={() => { setEditingClass(cls.code); setEditName(cls.name) }}
                    className="text-xs px-3 py-1.5 bg-white/10 hover:bg-white/20 text-zinc-300 rounded-lg transition-colors"
                  >
                    Rename
                  </button>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Students */}
      <div>
        <h2 className="text-lg font-bold text-white mb-3">All Students</h2>
        <div className="space-y-2">
          {students.map(student => (
            <div key={student.id} className="bg-white/3 border border-white/5 rounded-xl p-3 flex items-center gap-3">
              <div className="flex-1 min-w-0">
                <div className="text-sm font-medium text-white truncate">{student.display_name}</div>
                <div className="text-xs text-zinc-500">
                  Class: <span className="font-mono text-zinc-400">{student.class_code}</span>
                </div>
              </div>
              {editingStudent === student.id ? (
                <div className="flex gap-1.5 items-center shrink-0">
                  <input
                    type="text"
                    value={editCode}
                    onChange={e => setEditCode(e.target.value.replace(/\D/g, '').slice(0, 5))}
                    placeholder="new code"
                    className="w-24 bg-white/10 border border-white/20 rounded-lg px-2 py-1 text-white font-mono text-sm focus:outline-none focus:border-amber-500/50"
                  />
                  <button onClick={() => saveStudentCode(student.id)} disabled={saving || editCode.length !== 5} className="px-2 py-1 bg-amber-500 text-black font-bold rounded-lg text-xs disabled:opacity-40">
                    {saving ? '…' : 'Move'}
                  </button>
                  <button onClick={() => setEditingStudent(null)} className="px-2 py-1 bg-white/5 text-zinc-400 rounded-lg text-xs">✕</button>
                </div>
              ) : (
                <button
                  onClick={() => { setEditingStudent(student.id); setEditCode(student.class_code) }}
                  className="text-xs px-2.5 py-1.5 bg-white/5 hover:bg-white/10 text-zinc-400 rounded-lg transition-colors shrink-0"
                >
                  Move class
                </button>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
