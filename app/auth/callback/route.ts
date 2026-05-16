import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function GET(request: NextRequest) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')

  if (!code) {
    return NextResponse.redirect(`${origin}/login?error=no_code`)
  }

  // Collect cookies the auth exchange wants to set
  const pendingCookies: Array<{ name: string; value: string; options: Record<string, unknown> }> = []

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        // Read from the incoming request — includes the PKCE verifier the browser set
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          pendingCookies.push(...cookiesToSet)
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

  const { data: profile } = await supabase
    .from('profiles')
    .select('id, avatar_url')
    .eq('id', user.id)
    .single()

  // Save Google avatar on first login (only if not already set)
  const googleAvatar = user.user_metadata?.avatar_url || user.user_metadata?.picture || null
  if (profile && googleAvatar && !(profile as Record<string, unknown>).avatar_url) {
    await supabase.from('profiles').update({ avatar_url: googleAvatar }).eq('id', user.id)
  }

  const destination = profile ? '/' : '/onboarding'
  const response = NextResponse.redirect(`${origin}${destination}`)

  // Write session cookies onto the redirect response so the browser carries them forward
  pendingCookies.forEach(({ name, value, options }) => {
    response.cookies.set(name, value, options as Parameters<typeof response.cookies.set>[2])
  })

  return response
}
