import { MarketingPage } from "@/components/marketing-page";
import { buildMetadata } from "@/lib/seo-metadata";

export const metadata = buildMetadata("fr", "home");

export default function FrenchHomePage() {
  return <MarketingPage locale="fr" />;
}
