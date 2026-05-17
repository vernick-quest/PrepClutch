import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'
import { NextResponse, type NextRequest } from 'next/server'

export async function GET(request: NextRequest) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')

  if (!code) {
    return NextResponse.redirect(`${origin}/login?error=no_code`)
  }

  const cookieStore = await cookies()

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            )
          } catch {
            // Route Handler context — cookies() is writable here, but keep the
            // try/catch to match the server.ts pattern in case Next.js changes behaviour.
          }
        },
      },
    }
  )

  const { error } = await supabase.auth.exchangeCodeForSession(code)

  if (error) {
    return NextResponse.redirect(
      `${origin}/login?error=${encodeURIComponent(error.message)}`
    )
  }

  const { data: { user } } = await supabase.auth.getUser()
  if (!user) {
    return NextResponse.redirect(`${origin}/login?error=no_user`)
  }

  // Save Google avatar on first login (only if not already set)
  const { data: profile } = await supabase
    .from('profiles')
    .select('id, avatar_url')
    .eq('id', user.id)
    .single()

  const googleAvatar = user.user_metadata?.avatar_url || user.user_metadata?.picture || null
  if (profile && googleAvatar && !(profile as Record<string, unknown>).avatar_url) {
    await supabase.from('profiles').update({ avatar_url: googleAvatar }).eq('id', user.id)
  }

  const destination = profile ? '/' : '/onboarding'
  return NextResponse.redirect(`${origin}${destination}`)
}
