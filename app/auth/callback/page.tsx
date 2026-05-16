'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'

export default function AuthCallbackPage() {
  const router = useRouter()
  const [status, setStatus] = useState('Signing you in…')

  useEffect(() => {
    const supabase = createClient()

    async function handleCallback() {
      // Exchange the code for a session in the browser so cookies are
      // set directly by the browser — avoids server-side cookie propagation issues
      const code = new URLSearchParams(window.location.search).get('code')

      if (code) {
        const { error } = await supabase.auth.exchangeCodeForSession(code)
        if (error) {
          console.error('Session exchange failed:', error.message)
          router.push('/login?error=auth_failed')
          return
        }
      }

      const { data: { user }, error: userError } = await supabase.auth.getUser()

      if (userError || !user) {
        router.push('/login?error=auth_failed')
        return
      }

      setStatus('Almost there…')

      const { data: profile } = await supabase
        .from('profiles')
        .select('id')
        .eq('id', user.id)
        .single()

      if (profile) {
        router.push('/')
      } else {
        router.push('/onboarding')
      }
    }

    handleCallback()
  }, [router])

  return (
    <div className="min-h-screen bg-[#0a0a0f] flex items-center justify-center">
      <div className="text-center">
        <div className="text-5xl mb-4 animate-pulse">🔐</div>
        <p className="text-zinc-400 text-lg">{status}</p>
      </div>
    </div>
  )
}
