import type { Viewport } from "next";

import "@/app/globals.css";

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#090908",
};

interface RootLayoutProps {
  children: React.ReactNode;
}

export default function EnglishRootLayout({ children }: RootLayoutProps) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
