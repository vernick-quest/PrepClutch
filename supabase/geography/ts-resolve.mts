// Lets the Node scripts here load lib/geo.ts, whose imports are written the
// Next.js way (`./geo-data`, no extension). Node needs the extension, so this
// hook retries a failed relative import with `.ts` added. Import it before
// dynamically importing anything under lib/.
import { registerHooks } from 'node:module'

registerHooks({
  resolve(specifier, context, next) {
    try {
      return next(specifier, context)
    } catch (e) {
      if (specifier.startsWith('.') && !/\.[cm]?[jt]sx?$/.test(specifier)) return next(specifier + '.ts', context)
      throw e
    }
  },
})
