import Link from 'next/link'

export default function Footer() {
  return (
    <footer className="border-t border-white/5 py-6 px-4 mt-auto">
      <div className="max-w-6xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-2 text-xs text-zinc-600">
        <span>© {new Date().getFullYear()} PrepClutch. All rights reserved.</span>
        <div className="flex gap-4">
          <Link href="/privacy" className="hover:text-zinc-400 transition-colors">Privacy Policy</Link>
        </div>
      </div>
    </footer>
  )
}
