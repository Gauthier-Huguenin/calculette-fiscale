import {
  appStoreUrl,
  authorContent,
  authorName,
  authorSameAs,
  getPath,
  guidePages,
  siteUrl,
  type GuideSlug,
  type Locale,
} from "@/lib/site-content";

interface JsonLdProps {
  data: Record<string, unknown>;
}

export function JsonLd({ data }: JsonLdProps) {
  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{
        __html: JSON.stringify(data).replace(/</g, "\\u003c"),
      }}
    />
  );
}

function buildAuthorReference() {
  return {
    "@id": `${siteUrl}${getPath("fr", "author")}#person`,
  };
}

function buildAuthorEntity(locale: Locale) {
  const content = authorContent[locale];

  return {
    ...buildAuthorReference(),
    "@type": "Person",
    name: authorName,
    url: `${siteUrl}${getPath("fr", "author")}`,
    sameAs: authorSameAs,
    jobTitle: content.role,
    description: content.metaDescription,
  };
}

export function buildProfilePageJsonLd(locale: Locale) {
  const content = authorContent[locale];
  const path = getPath(locale, "author");
  const url = `${siteUrl}${path}`;

  return {
    "@context": "https://schema.org",
    "@type": "ProfilePage",
    "@id": `${url}#profile`,
    url,
    name: content.metaTitle,
    description: content.metaDescription,
    inLanguage: locale,
    dateModified: "2026-05-23",
    mainEntity: buildAuthorEntity(locale),
  };
}

export function buildMobileApplicationJsonLd(locale: Locale) {
  return {
    "@context": "https://schema.org",
    "@type": "MobileApplication",
    "@id": `${siteUrl}/#mobile-application`,
    name: "Calculette Fiscale",
    url: siteUrl,
    sameAs: [appStoreUrl],
    applicationCategory: "FinanceApplication",
    operatingSystem: "iOS",
    inLanguage: locale,
    creator: buildAuthorEntity(locale),
  };
}

export function buildGuideArticleJsonLd(slug: GuideSlug) {
  const guide = guidePages[slug];

  return {
    "@context": "https://schema.org",
    "@type": "Article",
    "@id": `${siteUrl}${guide.path}#article`,
    headline: guide.headline,
    description: guide.metaDescription,
    image: `${siteUrl}${guide.image}`,
    inLanguage: "fr",
    dateModified: "2026-05-23",
    mainEntityOfPage: `${siteUrl}${guide.path}`,
    author: buildAuthorReference(),
  };
}
