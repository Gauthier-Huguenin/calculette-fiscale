import { MarketingPage } from "@/components/marketing-page";
import { buildMetadata } from "@/lib/seo-metadata";

export const metadata = buildMetadata("en", "home");

export default function EnglishHomePage() {
  return <MarketingPage locale="en" />;
}
