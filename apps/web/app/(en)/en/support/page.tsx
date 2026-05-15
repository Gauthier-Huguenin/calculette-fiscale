import { SupportPage } from "@/components/support-page";
import { buildMetadata } from "@/lib/seo-metadata";

export const metadata = buildMetadata("en", "support");

export default function EnglishSupportPage() {
  return <SupportPage locale="en" />;
}
