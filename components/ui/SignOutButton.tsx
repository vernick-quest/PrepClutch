'use client'

import { createClient } from '@/lib/supabase/client'
import { useRouter } from 'next/navigation'

export default function SignOutButton() {
  const router = useRouter()

  async function signOut() {
    const supabase = createClient()
    await supabase.auth.signOut()
    router.push('/login')
  }

  return (
    <button
      onClick={signOut}
      className="text-zinc-500 hover:text-rose-400 transition-colors text-sm"
    >
      Sign out
    </button>
  )
}
