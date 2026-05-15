import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "HSPT Prep — Ace Your Test",
  description: "Gamified HSPT practice with leaderboards, achievements, and instant feedback.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="h-full">
      <body className="min-h-full flex flex-col bg-[#0a0a0f] text-white antialiased">
        {children}
      </body>
    </html>
  );
}
