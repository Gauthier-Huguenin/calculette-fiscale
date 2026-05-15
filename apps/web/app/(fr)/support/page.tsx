import { SupportPage } from "@/components/support-page";
import { buildMetadata } from "@/lib/seo-metadata";

export const metadata = buildMetadata("fr", "support");

export default function FrenchSupportPage() {
  return <SupportPage locale="fr" />;
}
