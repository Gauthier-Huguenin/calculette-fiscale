import { GuidePage } from "@/components/guide-page";
import { buildGuideMetadata } from "@/lib/seo-metadata";

export const metadata = buildGuideMetadata("calcul-marge-tva");

export default function MarginGuidePage() {
  return <GuidePage slug="calcul-marge-tva" />;
}
