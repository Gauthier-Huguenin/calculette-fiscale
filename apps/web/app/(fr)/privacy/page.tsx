import { PrivacyPage } from "@/components/privacy-page";
import { buildMetadata } from "@/lib/seo-metadata";

export const metadata = buildMetadata("fr", "privacy");

export default function FrenchPrivacyPage() {
  return <PrivacyPage locale="fr" />;
}
