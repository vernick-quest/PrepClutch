import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { loginUrl } from '@/lib/tracks'

export const dynamic = 'force-dynamic'

// A shareable link to HSPT prep, the counterpart of /math. The HSPT dashboard
// lives at /, but a signed-out visitor must be sent to sign-in from HERE:
// bouncing via / first would lose the fact that the link was for HSPT.
export default async function HsptPage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  redirect(user ? '/' : loginUrl('/hspt'))
}
