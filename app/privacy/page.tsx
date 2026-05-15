import Link from 'next/link'

export const metadata = {
  title: 'Privacy Policy — PrepClutch',
}

export default function PrivacyPage() {
  return (
    <div className="min-h-screen bg-[#0a0a0f] py-16 px-4">
      <div className="max-w-3xl mx-auto">
        <div className="mb-10">
          <Link href="/" className="text-amber-400 hover:underline text-sm">← Back to PrepClutch</Link>
        </div>

        <h1 className="text-4xl font-black text-white mb-2">Privacy Policy</h1>
        <p className="text-zinc-500 text-sm mb-10">Last updated: May 14, 2025</p>

        <div className="space-y-10 text-zinc-300 leading-relaxed">

          <section>
            <h2 className="text-xl font-bold text-white mb-3">1. Overview</h2>
            <p>
              PrepClutch ("we," "us," or "our") is an educational test preparation platform designed to help
              students practice for the High School Placement Test (HSPT). This Privacy Policy explains what
              information we collect, how we use it, and the choices you have regarding your data.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-bold text-white mb-3">2. Information We Collect</h2>
            <ul className="space-y-3 list-none">
              <li className="flex gap-3">
                <span className="text-amber-400 shrink-0">•</span>
                <span><strong className="text-white">Account information:</strong> When you sign in with Google, we receive your name and email address from Google. We store only your display name and a class/group code you choose.</span>
              </li>
              <li className="flex gap-3">
                <span className="text-amber-400 shrink-0">•</span>
                <span><strong className="text-white">Quiz activity:</strong> We store your quiz answers, scores, time taken per question, and XP earned to power the leaderboard and achievement system.</span>
              </li>
              <li className="flex gap-3">
                <span className="text-amber-400 shrink-0">•</span>
                <span><strong className="text-white">Profile preferences:</strong> Your chosen avatar color and display name.</span>
              </li>
            </ul>
          </section>

          <section>
            <h2 className="text-xl font-bold text-white mb-3">3. How We Use Your Information</h2>
            <ul className="space-y-3 list-none">
              <li className="flex gap-3">
                <span className="text-amber-400 shrink-0">•</span>
                <span>To display your scores, progress, and rank on the class leaderboard</span>
              </li>
              <li className="flex gap-3">
                <span className="text-amber-400 shrink-0">•</span>
                <span>To track achievements and award XP</span>
              </li>
              <li className="flex gap-3">
                <span className="text-amber-400 shrink-0">•</span>
                <span>To identify you within your class group (by class code)</span>
              </li>
              <li className="flex gap-3">
                <span className="text-amber-400 shrink-0">•</span>
                <span>We do <strong className="text-white">not</strong> sell your data, show you ads, or share your information with third parties for marketing purposes</span>
              </li>
            </ul>
          </section>

          <section>
            <h2 className="text-xl font-bold text-white mb-3">4. Data Storage</h2>
            <p>
              Your data is stored securely using <a href="https://supabase.com" className="text-amber-400 hover:underline" target="_blank" rel="noopener noreferrer">Supabase</a>, which is hosted on AWS infrastructure.
              Authentication is handled by Supabase Auth using Google OAuth — we never see or store your Google password.
              All data is encrypted in transit via HTTPS.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-bold text-white mb-3">5. Children's Privacy</h2>
            <p>
              PrepClutch is intended for use by middle and high school students, typically ages 12 and up,
              under the supervision of a teacher or parent. We do not knowingly collect personal information
              from children under 13 without parental or school consent. If you believe a child under 13 has
              provided us personal information without appropriate consent, please contact us so we can
              delete it promptly.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-bold text-white mb-3">6. Your Rights</h2>
            <ul className="space-y-3 list-none">
              <li className="flex gap-3">
                <span className="text-amber-400 shrink-0">•</span>
                <span><strong className="text-white">Access:</strong> You can view all your quiz history and scores on your Profile page.</span>
              </li>
              <li className="flex gap-3">
                <span className="text-amber-400 shrink-0">•</span>
                <span><strong className="text-white">Deletion:</strong> You may request deletion of your account and all associated data by contacting us at the email below.</span>
              </li>
              <li className="flex gap-3">
                <span className="text-amber-400 shrink-0">•</span>
                <span><strong className="text-white">Correction:</strong> You can update your display name and class code at any time from your profile.</span>
              </li>
            </ul>
          </section>

          <section>
            <h2 className="text-xl font-bold text-white mb-3">7. Cookies & Sessions</h2>
            <p>
              We use cookies solely to maintain your login session. We do not use tracking cookies,
              analytics cookies, or advertising cookies.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-bold text-white mb-3">8. Changes to This Policy</h2>
            <p>
              We may update this policy from time to time. We will note the date of the last update at the
              top of this page. Continued use of PrepClutch after changes constitutes acceptance of the
              updated policy.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-bold text-white mb-3">9. Contact</h2>
            <p>
              Questions about this policy? Email us at{' '}
              <a href="mailto:vernick@gmail.com" className="text-amber-400 hover:underline">vernick@gmail.com</a>.
            </p>
          </section>

        </div>

        <div className="mt-16 pt-8 border-t border-white/10 text-center text-zinc-600 text-sm">
          © {new Date().getFullYear()} PrepClutch. All rights reserved.
        </div>
      </div>
    </div>
  )
}
