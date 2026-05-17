'use client'

import { useState } from 'react'
import Link from 'next/link'

export interface DbBadge {
  key: string
  label: string
  icon_emoji: string
  description: string
  rarity: string
  creature: string
  category: string
  lore: string
}

const RARITY: Record<string, { bg: string; border: string; text: string; glow: string; stars: number }> = {
  Common:    { bg: '#0d1117', border: '#1f2937',   text: '#6b7280', glow: 'none',                stars: 1 },
  Uncommon:  { bg: '#0a1a0a', border: '#16a34a55', text: '#4ade80', glow: '0 0 20px #22c55e22', stars: 2 },
  Rare:      { bg: '#0c0c2a', border: '#4f46e555', text: '#818cf8', glow: '0 0 24px #6366f133', stars: 3 },
  Epic:      { bg: '#160820', border: '#7c3aed66', text: '#c084fc', glow: '0 0 32px #a855f744', stars: 4 },
  Legendary: { bg: '#1a1200', border: '#d9770666', text: '#fbbf24', glow: '0 0 40px #f59e0b55', stars: 5 },
  Mythic:    { bg: '#0e0018', border: '#9333ea99', text: '#e879f9', glow: '0 0 56px #a855f777', stars: 6 },
}

const CATEGORY_ORDER = ['First Completion', 'Perfect Score', 'Speed', 'Combo', 'Milestone']

function Stars({ count, color }: { count: number; color: string }) {
  return (
    <div style={{ display: 'flex', gap: 2, justifyContent: 'center' }}>
      {Array.from({ length: 6 }).map((_, i) => (
        <span key={i} style={{
          fontSize: 8, transition: 'all 0.3s',
          color: i < count ? color : '#1f2937',
          filter: i < count ? `drop-shadow(0 0 4px ${color})` : 'none',
        }}>★</span>
      ))}
    </div>
  )
}

function BadgeCard({ badge, earned }: { badge: DbBadge; earned: boolean }) {
  const [open, setOpen] = useState(false)
  const r = RARITY[badge.rarity] ?? RARITY.Common
  return (
    <div
      onClick={() => earned && setOpen(o => !o)}
      style={{
        background: earned ? r.bg : '#080c14',
        border: `1.5px solid ${earned ? r.border : '#111827'}`,
        borderRadius: 16, padding: '18px 14px 14px',
        display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 7,
        opacity: earned ? 1 : 0.28, filter: earned ? 'none' : 'grayscale(1)',
        boxShadow: earned ? r.glow : 'none', transition: 'all 0.25s',
        position: 'relative', cursor: earned ? 'pointer' : 'not-allowed',
      }}
    >
      <Stars count={r.stars} color={r.text} />
      <div style={{ fontSize: 36, lineHeight: 1, filter: earned ? `drop-shadow(0 0 8px ${r.text}55)` : 'blur(8px)' }}>
        {earned ? badge.icon_emoji : '❓'}
      </div>
      <div style={{ fontSize: 12, fontWeight: 800, color: earned ? r.text : '#1f2937', textAlign: 'center', lineHeight: 1.3, fontStyle: 'italic' }}>
        {earned ? badge.label : '???'}
      </div>
      {earned && badge.creature && (
        <div style={{ fontSize: 9, color: r.text + '66', letterSpacing: 1.5, textTransform: 'uppercase', textAlign: 'center' }}>
          {badge.creature}
        </div>
      )}
      <div style={{
        fontSize: 9, fontWeight: 700, letterSpacing: 2, textTransform: 'uppercase',
        color: earned ? r.text + '99' : '#1f2937',
        padding: '2px 8px', borderRadius: 20,
        background: earned ? r.text + '11' : 'transparent',
        border: earned ? `1px solid ${r.text}22` : 'none',
      }}>{badge.rarity}</div>
      <div style={{ fontSize: 10, color: earned ? '#4b5563' : '#111827', textAlign: 'center', lineHeight: 1.5 }}>
        {earned ? badge.description : 'Keep playing to unlock'}
      </div>
      {open && earned && (
        <div style={{
          marginTop: 6, padding: '12px 13px', background: '#00000055', borderRadius: 10,
          border: `1px solid ${r.border}`, fontSize: 11, color: '#9ca3af', lineHeight: 1.8,
          fontStyle: 'italic', textAlign: 'left',
        }}>{badge.lore}</div>
      )}
      {earned && (
        <div style={{ fontSize: 9, color: '#1f2937', marginTop: 2 }}>
          {open ? '▲ hide lore' : '▼ read lore'}
        </div>
      )}
    </div>
  )
}

interface Props {
  displayName: string
  avatarColor: string
  allBadges: DbBadge[]
  earnedKeys: string[]
}

export default function BestiaryClient({ displayName, avatarColor, allBadges, earnedKeys }: Props) {
  const firstName = displayName.split(' ')[0]
  const initial   = displayName[0]?.toUpperCase() ?? '?'
  const [catFilter, setCat] = useState('All')

  const earnedSet = new Set(earnedKeys)
  const filtered  = catFilter === 'All' ? allBadges : allBadges.filter(b => b.category === catFilter)
  const pct       = allBadges.length > 0 ? Math.round((earnedKeys.length / allBadges.length) * 100) : 0

  return (
    <div style={{
      minHeight: '100vh', background: '#080c14', color: '#e2e8f0',
      fontFamily: "'Georgia','Times New Roman',serif", paddingBottom: 80,
    }}>
      <div style={{
        textAlign: 'center', padding: '52px 24px 32px',
        background: 'radial-gradient(ellipse at 50% 0%,#1a0828 0%,#080c14 68%)',
      }}>
        <div style={{ fontSize: 10, letterSpacing: 6, color: '#374151', textTransform: 'uppercase', marginBottom: 12 }}>
          HSPT Prep · Bestiary
        </div>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 12, marginBottom: 6 }}>
          <div style={{ width: 40, height: 40, borderRadius: '50%', background: avatarColor, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontWeight: 700, fontSize: 16, flexShrink: 0 }}>
            {initial}
          </div>
          <h1 style={{
            fontSize: 42, fontWeight: 900, margin: 0, color: '#f9fafb', letterSpacing: '-1px',
            textShadow: '0 0 60px rgba(168,85,247,0.5),0 0 120px rgba(99,102,241,0.25)',
          }}>{firstName}&apos;s Collection</h1>
        </div>
        <p style={{ fontSize: 13, color: '#475569', margin: '0 0 24px' }}>
          Every badge is a ridiculous made-up creature. Click earned badges to read their lore.
        </p>

        <div style={{ display: 'flex', justifyContent: 'center', gap: 32, marginBottom: 22 }}>
          {([[earnedKeys.length, '#c084fc', 'Earned'], [allBadges.length, '#374151', 'Total'], [`${pct}%`, '#fbbf24', 'Complete']] as [string | number, string, string][]).map(([v, c, l]) => (
            <div key={l} style={{ textAlign: 'center' }}>
              <div style={{ fontSize: 30, fontWeight: 900, color: c }}>{v}</div>
              <div style={{ fontSize: 9, color: '#374151', letterSpacing: 2, textTransform: 'uppercase' }}>{l}</div>
            </div>
          ))}
        </div>

        <div style={{ maxWidth: 380, margin: '0 auto 24px', height: 4, background: '#111827', borderRadius: 4, overflow: 'hidden' }}>
          <div style={{
            height: '100%', width: `${pct}%`, borderRadius: 4, transition: 'width 0.8s ease',
            background: 'linear-gradient(90deg,#6366f1,#a855f7,#ec4899,#f59e0b)',
          }} />
        </div>

        <div style={{ display: 'flex', gap: 7, justifyContent: 'center', flexWrap: 'wrap' }}>
          {['All', ...CATEGORY_ORDER].map(cat => (
            <button key={cat} onClick={() => setCat(cat)} style={{
              padding: '4px 13px', borderRadius: 20, border: '1px solid', cursor: 'pointer',
              borderColor: catFilter === cat ? '#a855f7' : '#1f2937',
              background:  catFilter === cat ? '#a855f722' : 'transparent',
              color:       catFilter === cat ? '#c084fc' : '#374151',
              fontSize: 11, fontFamily: 'inherit', fontWeight: 700, transition: 'all 0.15s',
            }}>{cat}</button>
          ))}
        </div>
      </div>

      {earnedKeys.length === 0 && (
        <div style={{ textAlign: 'center', padding: '48px 24px', color: '#374151', fontSize: 14 }}>
          Complete a quiz to start earning badges.{' '}
          <Link href="/quiz/verbal" style={{ color: '#818cf8' }}>Start practicing →</Link>
        </div>
      )}

      <div style={{ maxWidth: 920, margin: '28px auto 0', padding: '0 24px' }}>
        {CATEGORY_ORDER.filter(cat => catFilter === 'All' || catFilter === cat).map(cat => {
          const catBadges = filtered.filter(b => b.category === cat)
          if (!catBadges.length) return null
          const catEarned = catBadges.filter(b => earnedSet.has(b.key)).length
          return (
            <div key={cat} style={{ marginBottom: 44 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 14, marginBottom: 16 }}>
                <div style={{ fontSize: 9, fontWeight: 800, color: '#374151', letterSpacing: 3, textTransform: 'uppercase', whiteSpace: 'nowrap' }}>{cat}</div>
                <div style={{ flex: 1, height: 1, background: '#111827' }} />
                <div style={{ fontSize: 9, color: '#1f2937', whiteSpace: 'nowrap' }}>{catEarned}/{catBadges.length}</div>
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill,minmax(155px,1fr))', gap: 12 }}>
                {catBadges.map(badge => (
                  <BadgeCard key={badge.key} badge={badge} earned={earnedSet.has(badge.key)} />
                ))}
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}
