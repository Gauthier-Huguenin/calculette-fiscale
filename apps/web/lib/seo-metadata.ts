import type { Metadata } from "next";

import { getLanguage, getPath, languageOptions, siteUrl, type Locale, type PageKind } from "@/lib/site-content";

interface SeoContent {
  title: string;
  description: string;
}

const seo: Record<PageKind, Record<Locale, SeoContent>> = {
  home: {
    fr: {
      title: "Calculette Fiscale - TVA, charges, net et marge",
      description:
        "La calculette française pour passer du HT au TTC, estimer un net pro, trouver un prix à facturer et vérifier une marge.",
    },
    en: {
      title: "Calculette Fiscale - VAT, net estimates and margin",
      description:
        "A simple iPhone calculator for French VAT, net estimates, charges and margin. No account, no ads and no backend.",
    },
  },
  privacy: {
    fr: {
      title: "Confidentialité - Calculette Fiscale",
      description:
        "Calculette Fiscale fonctionne sans compte, sans publicité et sans backend. Les montants saisis restent stockés localement.",
    },
    en: {
      title: "Privacy Policy - Calculette Fiscale",
      description:
        "Calculette Fiscale works without an account, ads or backend. Entered amounts remain stored locally on the iPhone.",
    },
  },
  support: {
    fr: {
      title: "Support - Calculette Fiscale",
      description:
        "Contactez le support Calculette Fiscale pour l'app iOS, l'achat Pro, la confidentialité et les limites de la V1.",
    },
    en: {
      title: "Support - Calculette Fiscale",
      description:
        "Contact Calculette Fiscale support for the iOS app, Pro purchase, privacy and version 1 limits.",
    },
  },
};

function buildLanguages(page: PageKind) {
  return Object.fromEntries([
    ...languageOptions.map((language) => [language.hrefLang, `${siteUrl}${getPath(language.locale, page)}`]),
    ["x-default", `${siteUrl}${getPath("fr", page)}`],
  ]);
}

export function buildMetadata(locale: Locale, page: PageKind): Metadata {
  const language = getLanguage(locale);
  const content = seo[page][locale];
  const path = getPath(locale, page);
  const image = "/images/app-icon.png";

  return {
    metadataBase: new URL(siteUrl),
    title: content.title,
    description: content.description,
    applicationName: "Calculette Fiscale",
    alternates: {
      canonical: path,
      languages: buildLanguages(page),
    },
    openGraph: {
      title: content.title,
      description: content.description,
      url: path,
      siteName: "Calculette Fiscale",
      images: [
        {
          url: image,
          width: 1024,
          height: 1024,
          alt: "Calculette Fiscale app icon",
        },
      ],
      locale: language.ogLocale,
      type: "website",
    },
    twitter: {
      card: "summary",
      title: content.title,
      description: content.description,
      images: [image],
    },
    icons: {
      icon: image,
      apple: image,
    },
  };
}
