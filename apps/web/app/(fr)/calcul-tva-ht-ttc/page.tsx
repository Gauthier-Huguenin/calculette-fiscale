import { GuidePage } from "@/components/guide-page";
import { buildGuideMetadata } from "@/lib/seo-metadata";

export const metadata = buildGuideMetadata("calcul-tva-ht-ttc");

export default function VatGuidePage() {
  return <GuidePage slug="calcul-tva-ht-ttc" />;
}
