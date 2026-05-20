import { siteUrl, supportEmail } from "@/lib/site-content";

export function GET() {
  const body = [
    "# Calculette Fiscale",
    "",
    "Calculette Fiscale is an iOS app for French VAT, net estimates, charges and margin.",
    "The app is French first, works without an account, has no ads and does not send entered amounts to the developer.",
    "",
    "Important URLs:",
    `- Home: ${siteUrl}`,
    `- Calcul TVA HT TTC: ${siteUrl}/calcul-tva-ht-ttc`,
    `- Revenu net auto-entrepreneur: ${siteUrl}/revenu-net-auto-entrepreneur`,
    `- Calcul marge avec TVA: ${siteUrl}/calcul-marge-tva`,
    `- Privacy: ${siteUrl}/privacy`,
    `- Support: ${siteUrl}/support`,
    `- Contact: ${supportEmail}`,
    "",
    "Tax results are indicative estimates and do not replace official filings or tailored tax advice.",
  ].join("\n");

  return new Response(body, {
    headers: {
      "content-type": "text/plain; charset=utf-8",
    },
  });
}
