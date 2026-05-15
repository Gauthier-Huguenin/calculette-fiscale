import Script from "next/script";

import { umamiScriptUrl, umamiWebsiteId } from "@/lib/site-content";

export function UmamiAnalytics() {
  if (!umamiScriptUrl || !umamiWebsiteId) {
    return null;
  }

  return (
    <Script
      src={umamiScriptUrl}
      data-website-id={umamiWebsiteId}
      strategy="afterInteractive"
    />
  );
}
