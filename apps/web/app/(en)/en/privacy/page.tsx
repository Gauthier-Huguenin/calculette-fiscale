import { PrivacyPage } from "@/components/privacy-page";
import { buildMetadata } from "@/lib/seo-metadata";

export const metadata = buildMetadata("en", "privacy");

export default function EnglishPrivacyPage() {
  return <PrivacyPage locale="en" />;
}
