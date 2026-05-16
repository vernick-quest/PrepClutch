import { NextResponse } from 'next/server'

// Hand off to the client page so the browser can save the session cookie itself
export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')

  if (!code) {
    return NextResponse.redirect(`${origin}/login?error=no_code`)
  }

  // Pass the code to the client page — it will exchange and store the cookie
  const url = new URL('/auth/confirm', origin)
  url.searchParams.set('code', code)
  return NextResponse.redirect(url.toString())
}
