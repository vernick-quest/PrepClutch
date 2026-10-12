// ── Natural Earth projection, forward and inverse ────────────────────────────
//
// The map is drawn in the Natural Earth projection (Šavrič, Jenny, Patterson
// and Hurni, 2011): a pseudo-cylindrical world projection made for maps like
// this one. Countries keep a familiar shape, the poles are flattened lines
// instead of points, and nothing is wildly stretched, which matters to a kid
// learning what Chile or Norway looks like.
//
// Why this one, and how a tap becomes a latitude and longitude:
//   forward   x = λ · L(φ),  y = φ · M(φ)   (two short polynomials)
//   inverse   y depends on φ alone and is strictly increasing, so φ is found
//             by Newton's method on M (converges to 1e-12 in a few steps from
//             φ = y), then λ = x / L(φ) exactly. No lookup tables, no
//             approximation beyond floating point.
// Robinson would need its table inverted; Winkel tripel has no closed form
// for either direction of the inverse. Natural Earth has neither problem.
//
// Every view chooses its own centre meridian λ0, so Oceania is drawn around
// the Pacific instead of being split across the two edges of the map.
//
// Units: x and y are in radians (the world is about 5.45 wide and 2.78 tall).
// Callers scale. No '@/' imports, so the Node checks can load this file.

const D2R = Math.PI / 180
const R2D = 180 / Math.PI

function L(phi: number): number {
  const p2 = phi * phi, p4 = p2 * p2
  return 0.8707 - 0.131979 * p2 + p4 * (-0.013791 + p4 * p2 * (0.003971 - 0.001529 * p2))
}
function M(phi: number): number {
  const p2 = phi * phi, p4 = p2 * p2
  return 1.007226 + p2 * (0.015085 + p4 * (-0.044475 + 0.028874 * p2 - 0.005916 * p4))
}
/** d(φ·M(φ))/dφ, for Newton's method. */
function dYdPhi(phi: number): number {
  const p2 = phi * phi, p4 = p2 * p2
  return 1.007226 + p2 * (3 * 0.015085 + p4 * (-7 * 0.044475 + 9 * 0.028874 * p2 - 11 * 0.005916 * p4))
}

/** Half the height of the world: y at the north pole. */
export const Y_MAX = (Math.PI / 2) * M(Math.PI / 2)

/** Wrap a longitude into [-180, 180). */
export function wrapLon(lon: number): number {
  return ((((lon + 180) % 360) + 360) % 360) - 180
}

/** Degrees to projected [x, y] (y grows NORTH; flip it for SVG). The
 *  longitude is taken relative to lon0 and wrapped, unless `raw` is set:
 *  then lon - lon0 is used as given, so a shape drawn just past the edge of
 *  the map stays in one piece. */
export function project(lon: number, lat: number, lon0 = 0, raw = false): [number, number] {
  const dl = raw ? lon - lon0 : wrapLon(lon - lon0)
  const phi = lat * D2R
  return [dl * D2R * L(phi), phi * M(phi)]
}

/** Projected [x, y] back to degrees, or null outside the world's outline. */
export function invert(x: number, y: number, lon0 = 0): { lat: number; lon: number } | null {
  if (!Number.isFinite(x) || !Number.isFinite(y) || Math.abs(y) > Y_MAX + 1e-9) return null
  let phi = y
  for (let i = 0; i < 25; i++) {
    const step = (phi * M(phi) - y) / dYdPhi(phi)
    phi -= step
    if (Math.abs(step) < 1e-12) break
  }
  phi = Math.max(-Math.PI / 2, Math.min(Math.PI / 2, phi))
  const lam = x / L(phi)
  if (Math.abs(lam) > Math.PI + 1e-9) return null
  return { lat: phi * R2D, lon: wrapLon(lam * R2D + lon0) }
}

/** Great-circle distance in km (mean Earth radius 6371 km). */
export function haversineKm(a: { lat: number; lon: number }, b: { lat: number; lon: number }): number {
  const dLat = (b.lat - a.lat) * D2R
  const dLon = (b.lon - a.lon) * D2R
  const h = Math.sin(dLat / 2) ** 2 + Math.cos(a.lat * D2R) * Math.cos(b.lat * D2R) * Math.sin(dLon / 2) ** 2
  return 2 * 6371 * Math.asin(Math.min(1, Math.sqrt(h)))
}
