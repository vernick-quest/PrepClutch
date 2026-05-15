import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function GET(request: NextRequest) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')
  const next = searchParams.get('next') ?? '/'

  const forwardedHost = request.headers.get('x-forwarded-host')
  const baseUrl = forwardedHost ? `https://${forwardedHost}` : origin

  if (!code) {
    return NextResponse.redirect(`${baseUrl}/login?error=auth_failed`)
  }

  // Collect cookies to set — we apply them to the redirect response directly
  // because NextResponse.redirect() creates a new response that won't inherit
  // cookies set via next/headers cookies()
  const cookiesToSet: Array<{ name: string; value: string; options: Record<string, unknown> }> = []

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookies) {
          cookiesToSet.push(...cookies)
        },
      },
    }
  )

  const { error } = await supabase.auth.exchangeCodeForSession(code)

  if (error) {
    console.error('exchangeCodeForSession error:', error.message)
    return NextResponse.redirect(`${baseUrl}/login?error=auth_failed`)
  }

  const { data: { user } } = await supabase.auth.getUser()

  let redirectTo = `${baseUrl}${next}`
  if (user) {
    const { data: profile } = await supabase
      .from('profiles')
      .select('id')
      .eq('id', user.id)
      .single()

    if (!profile) {
      redirectTo = `${baseUrl}/onboarding`
    }
  }

  const response = NextResponse.redirect(redirectTo)

  // Attach auth cookies to the redirect response so the session survives
  cookiesToSet.forEach(({ name, value, options }) => {
    response.cookies.set(name, value, options as Parameters<typeof response.cookies.set>[2])
  })

  return response
}
