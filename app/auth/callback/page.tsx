'use client'

import { useEffect, useRef, Suspense } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { createBrowserClient } from '@supabase/ssr'

function CallbackHandler() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const handled = useRef(false)

  useEffect(() => {
    if (handled.current) return
    handled.current = true

    const code = searchParams.get('code')
    const errorParam = searchParams.get('error')

    if (errorParam) {
      router.push(`/login?error=${encodeURIComponent(errorParam)}`)
      return
    }
    if (!code) {
      router.push('/login?error=no_code')
      return
    }

    // Create a client with detectSessionInUrl disabled so the SDK does NOT
    // auto-exchange the ?code= on init. Without this, the SDK consumes the
    // PKCE code verifier automatically, and our explicit call below fails
    // with "code verifier not found" even though the session was established.
    const supabase = createBrowserClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      { auth: { detectSessionInUrl: false, persistSession: true, autoRefreshToken: true } }
    )

    supabase.auth.exchangeCodeForSession(code).then(async ({ data, error }) => {
      if (error) {
        router.push(`/login?error=${encodeURIComponent(error.message)}`)
        return
      }

      const user = data.session?.user
      if (!user) {
        router.push('/login?error=no_user')
        return
      }

      // Save Google avatar on first login
      const { data: profile } = await supabase
        .from('profiles')
        .select('id, avatar_url')
        .eq('id', user.id)
        .single()

      const googleAvatar =
        user.user_metadata?.avatar_url || user.user_metadata?.picture || null
      if (profile && googleAvatar && !profile.avatar_url) {
        await supabase.from('profiles').update({ avatar_url: googleAvatar }).eq('id', user.id)
      }

      router.push(profile ? '/' : '/onboarding')
    })
  }, [router, searchParams])

  return (
    <div className="min-h-screen bg-[#0a0a0f] flex items-center justify-center">
      <div className="text-zinc-400 text-sm animate-pulse">Signing you in…</div>
    </div>
  )
}

export default function AuthCallbackPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-[#0a0a0f] flex items-center justify-center">
        <div className="text-zinc-400 text-sm">Loading…</div>
      </div>
    }>
      <CallbackHandler />
    </Suspense>
  )
}
