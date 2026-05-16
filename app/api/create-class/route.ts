import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

export async function POST() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })

  const { data: code, error: fnError } = await supabase.rpc('generate_class_code')
  if (fnError || !code) return NextResponse.json({ error: 'Failed to generate code' }, { status: 500 })

  const { error: insertError } = await supabase.from('classes').insert({ code, created_by: user.id })
  if (insertError) return NextResponse.json({ error: 'Failed to create class' }, { status: 500 })

  await supabase.from('profiles').update({ class_code: code }).eq('id', user.id)

  return NextResponse.json({ code })
}
