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

export default function FrenchRootLayout({ children }: RootLayoutProps) {
  return (
    <html lang="fr">
      <body>
        {children}
        <UmamiAnalytics />
      </body>
    </html>
  );
}
