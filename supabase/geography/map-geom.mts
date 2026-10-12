// Point-in-country tests on the generated world map (lib/geo-map.ts shapes),
// shared by validate-map.mts (capitals) and validate-cities.mts (cities).

import './ts-resolve.mts'
import type { MapShape } from '../../lib/geo-map.ts'

const proj = await import('../../lib/geo-projection.ts')

/** Even-odd across all rings, exactly as the SVG fills. */
export function inShape(s: MapShape, lon: number, lat: number): boolean {
  let inside = false
  for (const r of s.rings) {
    for (let i = 0, j = r.length - 2; i < r.length; j = i, i += 2) {
      const xi = r[i], yi = r[i + 1], xj = r[j], yj = r[j + 1]
      if ((yi > lat) !== (yj > lat) && lon < ((xj - xi) * (lat - yi)) / (yj - yi) + xi) inside = !inside
    }
  }
  return inside
}

/** 0 inside the shape, else km to its nearest edge (on a local plane, fine
 *  at these distances). */
export function nearestKm(s: MapShape, lon: number, lat: number): number {
  if (inShape(s, lon, lat)) return 0
  const k = Math.cos(lat * Math.PI / 180) * 111.32
  let best = Infinity
  for (const r of s.rings) {
    for (let i = 0, j = r.length - 2; i < r.length; j = i, i += 2) {
      const ax = proj.wrapLon(r[j] - lon) * k, ay = (r[j + 1] - lat) * 111.32
      const bx = proj.wrapLon(r[i] - lon) * k, by = (r[i + 1] - lat) * 111.32
      const dx = bx - ax, dy = by - ay, l2 = dx * dx + dy * dy
      const t = l2 ? Math.max(0, Math.min(1, -(ax * dx + ay * dy) / l2)) : 0
      best = Math.min(best, Math.hypot(ax + t * dx, ay + t * dy))
    }
  }
  return best
}
