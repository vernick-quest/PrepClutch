import Image from 'next/image'
import { flagSrc } from '@/lib/geo-meta'

// A bundled flag SVG (public/flags, flag-icons, MIT). Not emoji: Windows
// draws flag emoji as two letters. Size it with className; the image keeps
// its 4:3 shape. `alt` is passed in because on "pick the flag" cards the
// country's name would give the answer away to anyone who can read it.
export default function Flag({ iso, alt, className = '', priority = false }: {
  iso: string
  alt: string
  className?: string
  priority?: boolean
}) {
  return (
    <Image
      src={flagSrc(iso)}
      alt={alt}
      width={640}
      height={480}
      unoptimized
      priority={priority}
      draggable={false}
      className={`object-contain select-none ${className}`}
    />
  )
}
