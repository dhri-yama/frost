import type { Metadata, Viewport } from "next";
import { Big_Shoulders, Newsreader, Sacramento } from "next/font/google";
import "./globals.css";

// Three faces with three jobs: signage for headings, a drinks-menu serif for text, and a neon-tube script for the logo only.
const signage = Big_Shoulders({ subsets: ["latin"], variable: "--font-signage", display: "swap" });
const menu = Newsreader({ subsets: ["latin"], style: ["normal", "italic"], variable: "--font-menu", display: "swap" });
const neon = Sacramento({ subsets: ["latin"], weight: "400", variable: "--font-neon", display: "swap" });

export const metadata: Metadata = {
  title: "Frost: keep the clutter behind the bar",
  description:
    "Frost is a free, open source menu bar organiser for macOS. It hides the icons you don't need and brings them back with one click. Works on macOS 27.",
  openGraph: {
    title: "Frost: keep the clutter behind the bar",
    description: "Hide the menu bar icons you don't need. One click brings them back.",
    type: "website",
  },
};

// The page has one theme: black. Declaring it keeps native controls and scrollbars dark.
export const viewport: Viewport = { colorScheme: "dark", themeColor: "#000000" };

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${signage.variable} ${menu.variable} ${neon.variable}`}>
      <body>{children}</body>
    </html>
  );
}
