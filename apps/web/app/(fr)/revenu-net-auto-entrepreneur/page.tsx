import { GuidePage } from "@/components/guide-page";
import { buildGuideMetadata } from "@/lib/seo-metadata";

export const metadata = buildGuideMetadata("revenu-net-auto-entrepreneur");

export default function NetIncomeGuidePage() {
  return <GuidePage slug="revenu-net-auto-entrepreneur" />;
}
