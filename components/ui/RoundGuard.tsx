'use client'

// ── One visit per round ──────────────────────────────────────────────────────
//
// Back and Forward don't re-run a page: the router replays the server payload
// it cached, so a round the student already finished (or walked away from)
// came back at question 1 with the same questions in the same order, ready to
// be answered again. Each round page now mints a fresh id on the server
// (`crypto.randomUUID()`); a replayed payload carries an id this tab has already
// seen, and that round is over — send the student home instead.
//
// Renders nothing until it has checked, so a stale round never starts its
// clock. Without sessionStorage it lets the round through (fail open: a kid
// who can't replay a round is better than one who can't play at all).

import { useEffect, useRef, useState } from 'react'
import { useRouter } from 'next/navigation'

const KEY = 'pc:rounds'
const KEEP = 100

function seenBefore(round: string): boolean {
  try {
    const seen: string[] = JSON.parse(sessionStorage.getItem(KEY) ?? '[]')
    if (seen.includes(round)) return true
    sessionStorage.setItem(KEY, JSON.stringify([...seen, round].slice(-KEEP)))
  } catch { /* storage blocked: fail open */ }
  return false
}

export default function RoundGuard({ round, home, children }: {
  round: string
  home: string
  children: React.ReactNode
}) {
  const router = useRouter()
  const [open, setOpen] = useState<string | null>(null)
  // The round this mount claimed. Strict Mode runs effects twice; the second
  // pass must not mistake our own claim for a replay.
  const claimed = useRef<string | null>(null)

  useEffect(() => {
    if (claimed.current === round || !seenBefore(round)) {
      claimed.current = round
      setOpen(round)
    } else {
      router.replace(home)
    }
  }, [round, home, router])

  return open === round ? <>{children}</> : null
}
