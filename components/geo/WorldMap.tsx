'use client'

// ── The world map ────────────────────────────────────────────────────────────
//
// Natural Earth shapes (lib/geo-map.ts), drawn as SVG for a box of the world
// (a continent, or a country's zoom box). The view always fills its
// container exactly, so a tap's screen position maps straight back to a
// latitude and longitude through the projection's inverse.
//
//   highlight   one country lit (fill + outline). If it is too small to see
//               at this zoom (under TINY_PX across), a ring is drawn around
//               its capital as well, so the Vatican-sized ones are findable.
//   onTap       reports taps as { lat, lon }. Drags and pinches are not taps.
//   interactive pinch, drag, wheel and +/- buttons zoom and pan (Pin the map
//               on a phone). Off for "Name that country": nothing to tap.
//   target/guess  Pin the map feedback: the real place, the pin, and the
//               great-circle line between them.
//   marks/zone  Find the country feedback: countries lit right (green) or
//               wrong (red), and a tiny country's ring at its true size.
//   bounds      how far the map may pan and zoom out, when it opens on a
//               smaller box (Pin the map's Europe). Default: the box.
//   shaded      a political map: neighbours in different muted tones
//               (landShades in lib/geo-map.ts) instead of one flat fill.
//
// Neutral land (not a UN member: Kosovo, Western Sahara, Taiwan, Greenland,
// dependencies) is drawn a shade darker and is never highlighted.

import { useEffect, useMemo, useRef, useState, useCallback } from 'react'
import {
  loadMap, fitView, projectShapes, toSvg, fromSvg, greatCircle, sidePx, TINY_PX, landShades, geoCircle,
  LAND_SHADES, NEUTRAL_FILL,
} from '@/lib/geo-map'
import { wrapLon } from '@/lib/geo-projection'
import type { Box, MapShape } from '@/lib/geo-map'

export interface LatLon { lat: number; lon: number }
/** A country lit as feedback, by its shape's a3 (neutral land too). */
export interface MapMark { a3: string; tone: 'good' | 'bad' }

/** The shapes, loaded once per page. `need` false skips the download. */
export function useWorldMap(need = true): { shapes: MapShape[] | null; failed: boolean } {
  const [shapes, setShapes] = useState<MapShape[] | null>(null)
  const [failed, setFailed] = useState(false)
  useEffect(() => {
    if (!need) return
    let live = true
    loadMap().then(s => { if (live) setShapes(s) }).catch(() => { if (live) setFailed(true) })
    return () => { live = false }
  }, [need])
  return { shapes, failed }
}

const MAX_ZOOM = 12
const TAP_SLOP = 8          // px a finger may move and still be a tap
const TAP_MS = 700
const PIN_CROP = 1.6

interface Zoom { k: number; cx: number; cy: number }

export default function WorldMap({
  shapes, box, bounds, highlight, onTap, interactive = false, target, guess, marks, zone, shaded = false, className = '', label,
}: {
  shapes: MapShape[]
  box: Box
  bounds?: Box
  highlight?: string
  onTap?: (p: LatLon) => void
  interactive?: boolean
  target?: LatLon | null
  guess?: LatLon | null
  marks?: MapMark[]
  zone?: (LatLon & { km: number }) | null
  shaded?: boolean
  className?: string
  /** Accessible description of what the map shows. */
  label?: string
}) {
  const wrap = useRef<HTMLDivElement>(null)
  const svg = useRef<SVGSVGElement>(null)
  const [size, setSize] = useState<{ w: number; h: number } | null>(null)

  useEffect(() => {
    const el = wrap.current
    if (!el) return
    const ro = new ResizeObserver(([e]) => {
      const { width, height } = e.contentRect
      if (width > 0 && height > 0) setSize(s => (s && s.w === width && s.h === height ? s : { w: width, h: height }))
    })
    ro.observe(el)
    return () => ro.disconnect()
  }, [])

  const lon0 = wrapLon((box.w + box.e) / 2)
  const projected = useMemo(() => projectShapes(shapes, lon0), [shapes, lon0])
  // With bounds to pan within (Pin the map), a portrait phone crops the box's
  // sides rather than shrinking it to the screen's width.
  const base = useMemo(() => (size ? fitView(box, size.w / size.h, 0.04, undefined, bounds ? PIN_CROP : 1) : null), [box, size, bounds])
  // How far the map may pan and zoom out: the bounds, drawn around the same
  // meridian as the box. Without bounds, the box itself (zoom 1 is the floor).
  const outer = useMemo(() => (size && base ? (bounds ? fitView(bounds, size.w / size.h, 0.04, lon0) : base) : null), [bounds, size, base, lon0])
  const kMin = base && outer ? Math.min(1, base.w / outer.w) : 1

  // Zoom belongs to the box it was made on: a new box (a new card, a new
  // round) starts unzoomed.
  const boxKey = `${box.w},${box.s},${box.e},${box.n}`
  const [zoomed, setZoomed] = useState<{ key: string; z: Zoom } | null>(null)
  const zoom = zoomed?.key === boxKey ? zoomed.z : null
  const setZoom = useCallback((z: Zoom) => setZoomed({ key: boxKey, z }), [boxKey])

  const view = useMemo(() => {
    if (!base || !outer) return null
    const z = zoom ?? { k: 1, cx: base.x + base.w / 2, cy: base.y + base.h / 2 }
    const w = base.w / z.k, h = base.h / z.k
    // Keep the view inside the bounds (centred on them if it is wider).
    const clamp = (c: number, lo: number, span: number, size: number) =>
      size >= span ? lo + span / 2 : Math.min(Math.max(c, lo + size / 2), lo + span - size / 2)
    const cx = clamp(z.cx, outer.x, outer.w, w)
    const cy = clamp(z.cy, outer.y, outer.h, h)
    return { x: cx - w / 2, y: cy - h / 2, w, h, k: z.k, cx, cy }
  }, [base, outer, zoom])

  const pxPerUnit = size && view ? size.w / view.w : 1

  // Only shapes near the box are drawn: a continent view is a small part of
  // the world, and a phone should not lay out 55,000 points it cannot see.
  const visible = useMemo(() => {
    if (!outer) return []
    const mx = outer.w * 0.1, my = outer.h * 0.1
    return projected.filter(p => p.x1 >= outer.x - mx && p.x0 <= outer.x + outer.w + mx && p.y1 >= outer.y - my && p.y0 <= outer.y + outer.h + my)
  }, [projected, outer])
  const shades = useMemo(() => (shaded ? landShades(shapes) : null), [shaded, shapes])

  const lit = highlight ? projected.find(p => p.iso === highlight) : undefined
  const litShape = highlight ? shapes.find(s => s.iso === highlight) : undefined
  const tiny = !!litShape && sidePx(litShape.km2, pxPerUnit) < TINY_PX

  // ── Gestures ───────────────────────────────────────────────────────────────
  const pointers = useRef(new Map<number, { x: number; y: number }>())
  const gesture = useRef<{
    tap: { x: number; y: number; t: number } | null
    pan: { x: number; y: number; cx: number; cy: number } | null
    pinch: { d: number; k: number; sx: number; sy: number } | null
  }>({ tap: null, pan: null, pinch: null })

  const toSvgPoint = useCallback((clientX: number, clientY: number) => {
    const el = svg.current
    const m = el?.getScreenCTM()
    if (!el || !m) return null
    const p = new DOMPoint(clientX, clientY).matrixTransform(m.inverse())
    return { x: p.x, y: p.y }
  }, [])

  const zoomAt = useCallback((k: number, sx: number, sy: number, from: Zoom & { x: number; y: number; w: number; h: number }) => {
    if (!base) return
    const nk = Math.min(MAX_ZOOM, Math.max(kMin, k))
    // Keep the SVG point (sx, sy) under the same screen spot.
    const fx = (sx - from.x) / from.w, fy = (sy - from.y) / from.h
    const w = base.w / nk, h = base.h / nk
    setZoom({ k: nk, cx: sx - fx * w + w / 2, cy: sy - fy * h + h / 2 })
  }, [base, kMin, setZoom])

  function onPointerDown(e: React.PointerEvent) {
    pointers.current.set(e.pointerId, { x: e.clientX, y: e.clientY })
    try { e.currentTarget.setPointerCapture(e.pointerId) } catch { /* pointer already gone */ }
    const g = gesture.current
    if (pointers.current.size === 1) {
      g.tap = { x: e.clientX, y: e.clientY, t: performance.now() }
      g.pan = view ? { x: e.clientX, y: e.clientY, cx: view.cx, cy: view.cy } : null
      g.pinch = null
    } else if (pointers.current.size === 2 && interactive && view) {
      const [a, b] = [...pointers.current.values()]
      const mid = toSvgPoint((a.x + b.x) / 2, (a.y + b.y) / 2)
      g.tap = null; g.pan = null
      g.pinch = mid ? { d: Math.hypot(a.x - b.x, a.y - b.y), k: view.k, sx: mid.x, sy: mid.y } : null
    }
  }
  function onPointerMove(e: React.PointerEvent) {
    if (!pointers.current.has(e.pointerId)) return
    pointers.current.set(e.pointerId, { x: e.clientX, y: e.clientY })
    const g = gesture.current
    if (g.tap && Math.hypot(e.clientX - g.tap.x, e.clientY - g.tap.y) > TAP_SLOP) g.tap = null
    if (!interactive || !view) return
    if (pointers.current.size === 1 && g.pan && !g.tap && view.k > kMin + 1e-9) {
      setZoom({ k: view.k, cx: g.pan.cx - (e.clientX - g.pan.x) / pxPerUnit, cy: g.pan.cy - (e.clientY - g.pan.y) / pxPerUnit })
    } else if (pointers.current.size === 2 && g.pinch) {
      const [a, b] = [...pointers.current.values()]
      zoomAt(g.pinch.k * Math.hypot(a.x - b.x, a.y - b.y) / g.pinch.d, g.pinch.sx, g.pinch.sy, view)
    }
  }
  function onPointerUp(e: React.PointerEvent) {
    const g = gesture.current
    const wasTap = g.tap && pointers.current.size === 1 && performance.now() - g.tap.t < TAP_MS
    pointers.current.delete(e.pointerId)
    if (pointers.current.size === 0) { g.pan = null; g.pinch = null }
    if (!wasTap || !onTap) { g.tap = null; return }
    g.tap = null
    const p = toSvgPoint(e.clientX, e.clientY)
    const ll = p ? fromSvg(p.x, p.y, lon0) : null
    if (ll) onTap(ll)
  }
  function onPointerCancel(e: React.PointerEvent) {
    pointers.current.delete(e.pointerId)
    gesture.current = { tap: null, pan: null, pinch: null }
  }

  // Wheel zoom (desktop). Not a React prop: it must be non-passive to stop
  // the page scrolling.
  useEffect(() => {
    const el = svg.current
    if (!el || !interactive || !view) return
    const onWheel = (e: WheelEvent) => {
      e.preventDefault()
      const p = toSvgPoint(e.clientX, e.clientY)
      if (p) zoomAt(view.k * Math.exp(-e.deltaY * 0.0015), p.x, p.y, view)
    }
    el.addEventListener('wheel', onWheel, { passive: false })
    return () => el.removeEventListener('wheel', onWheel)
  }, [interactive, view, toSvgPoint, zoomAt])

  const px = (n: number) => n / pxPerUnit
  const pt = (p: LatLon) => toSvg(p.lon, p.lat, lon0)
  const line = target && guess ? greatCircle(guess, target).map(pt) : null
  const byA3 = (a3: string) => projected.find(p => p.a3 === a3)
  const zonePts = zone ? geoCircle(zone, zone.km).map(pt) : null
  // A ring narrower than a fingertip on screen gets a locator ring around it.
  const zoneSmall = zone ? (zone.km / 6.371) * pxPerUnit < 14 : false

  return (
    <div ref={wrap} className={`relative w-full h-full overflow-hidden bg-[#0d1726] select-none ${className}`}>
      {size && view && (
        <svg
          ref={svg}
          width={size.w}
          height={size.h}
          viewBox={`${view.x} ${view.y} ${view.w} ${view.h}`}
          role="img"
          aria-label={label ?? 'World map'}
          className={`block ${onTap ? 'cursor-crosshair' : ''}`}
          style={{ touchAction: interactive ? 'none' : 'manipulation' }}
          onPointerDown={onPointerDown}
          onPointerMove={onPointerMove}
          onPointerUp={onPointerUp}
          onPointerCancel={onPointerCancel}
        >
          {visible.map(p => (
            <path
              key={p.a3}
              d={p.d}
              fillRule="evenodd"
              fill={shades ? (p.iso ? LAND_SHADES[shades.get(p.a3) ?? 0] : NEUTRAL_FILL) : (p.iso ? '#334155' : '#263040')}
              stroke="#0d1726"
              strokeWidth={0.8}
              strokeLinejoin="round"
              vectorEffect="non-scaling-stroke"
            />
          ))}
          {lit && (
            <path d={lit.d} fillRule="evenodd" fill="#f59e0b" stroke="#fde68a" strokeWidth={1.5}
                  strokeLinejoin="round" vectorEffect="non-scaling-stroke" />
          )}
          {tiny && litShape?.cap && (() => {
            const [x, y] = pt(litShape.cap)
            return (
              <g>
                <circle cx={x} cy={y} r={px(15)} fill="none" stroke="#fbbf24" strokeWidth={3} vectorEffect="non-scaling-stroke" />
                <circle cx={x} cy={y} r={px(3)} fill="#f59e0b" />
              </g>
            )
          })()}
          {marks?.map(m => {
            const p = byA3(m.a3)
            if (!p) return null
            return (
              <path key={`${m.a3}-${m.tone}`} d={p.d} fillRule="evenodd"
                    fill={m.tone === 'good' ? '#10b981' : 'rgba(244, 63, 94, 0.35)'}
                    stroke={m.tone === 'good' ? '#a7f3d0' : '#fb7185'} strokeWidth={m.tone === 'good' ? 1.5 : 2}
                    strokeLinejoin="round" vectorEffect="non-scaling-stroke" />
            )
          })}
          {zonePts && zone && (() => {
            const [x, y] = pt(zone)
            return (
              <g>
                <polygon points={zonePts.map(([a, b]) => `${a},${b}`).join(' ')} fill="rgba(16, 185, 129, 0.18)"
                         stroke="#34d399" strokeWidth={2} strokeDasharray="5 3" vectorEffect="non-scaling-stroke" />
                {zoneSmall && <circle cx={x} cy={y} r={px(16)} fill="none" stroke="#34d399" strokeWidth={2.5} vectorEffect="non-scaling-stroke" />}
                <circle cx={x} cy={y} r={px(3)} fill="#34d399" />
              </g>
            )
          })()}
          {line && (
            <polyline points={line.map(([x, y]) => `${x},${y}`).join(' ')} fill="none" stroke="#f8fafc"
                      strokeWidth={2} strokeDasharray="6 4" vectorEffect="non-scaling-stroke" />
          )}
          {target && (() => {
            const [x, y] = pt(target)
            return (
              <g>
                <circle cx={x} cy={y} r={px(11)} fill="none" stroke="#34d399" strokeWidth={2} vectorEffect="non-scaling-stroke" />
                <circle cx={x} cy={y} r={px(5)} fill="#34d399" stroke="#064e3b" strokeWidth={1.5} vectorEffect="non-scaling-stroke" />
              </g>
            )
          })()}
          {guess && (() => {
            const [x, y] = pt(guess)
            return <circle cx={x} cy={y} r={px(6)} fill="#fb7185" stroke="#4c0519" strokeWidth={1.5} vectorEffect="non-scaling-stroke" />
          })()}
        </svg>
      )}
      {interactive && view && (
        <div className="absolute right-2 bottom-2 flex flex-col gap-1">
          {[
            { t: '+', a: 'Zoom in', f: () => zoomAt(view.k * 1.6, view.cx, view.cy, view) },
            { t: '−', a: 'Zoom out', f: () => zoomAt(view.k / 1.6, view.cx, view.cy, view) },
          ].map(b => (
            <button key={b.t} type="button" onClick={b.f} aria-label={b.a}
                    className="w-9 h-9 rounded-lg bg-black/60 border border-white/15 text-white text-lg font-bold leading-none hover:bg-black/80">
              {b.t}
            </button>
          ))}
        </div>
      )}
    </div>
  )
}
