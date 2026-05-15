import type { Viewport } from "next";

import "@/app/globals.css";
import { UmamiAnalytics } from "@/components/umami-analytics";

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
      <body>
        {children}
        <UmamiAnalytics />
      </body>
    </html>
  );
}
