'use client'

import { useEffect, useState } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { Suspense } from 'react'

function ConfirmContent() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const [status, setStatus] = useState('Signing you in…')

  useEffect(() => {
    const code = searchParams.get('code')
    if (!code) {
      router.push('/login?error=no_code')
      return
    }

    async function confirm() {
      const supabase = createClient()

      // Exchange the code — browser client saves the session cookie directly
      const { error } = await supabase.auth.exchangeCodeForSession(code!)
      if (error) {
        router.push(`/login?error=${encodeURIComponent(error.message)}`)
        return
      }

      setStatus('Almost there…')

      const { data: { user } } = await supabase.auth.getUser()
      if (!user) {
        router.push('/login?error=no_user')
        return
      }

      const { data: profile } = await supabase
        .from('profiles')
        .select('id')
        .eq('id', user.id)
        .single()

      router.push(profile ? '/' : '/onboarding')
    }

    confirm()
  }, [router, searchParams])

  return (
    <div className="min-h-screen bg-[#0a0a0f] flex items-center justify-center">
      <div className="text-center">
        <div className="text-5xl mb-4 animate-pulse">🔐</div>
        <p className="text-zinc-400 text-lg">{status}</p>
      </div>
    </div>
  )
}

export default function ConfirmPage() {
  return (
    <Suspense>
      <ConfirmContent />
    </Suspense>
  )
}
