import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "PrepClutch — HSPT prep & Math Facts",
  description: "Gamified HSPT practice and math facts, with leaderboards, badges and instant feedback.",
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
