import { getPath, guideOrder, guidePages, languageOptions, siteUrl, type PageKind } from "@/lib/site-content";

export interface SitemapEntry {
  url: string;
  lastModified: Date;
  changeFrequency: "monthly";
  priority: 1 | 0.8 | 0.6;
  alternates: Record<string, string>;
}

export const sitemapPages: PageKind[] = ["home", "privacy", "support"];
export const sitemapLastModified = new Date("2026-05-20");

function buildPageAlternates(page: PageKind) {
  return Object.fromEntries([
    ...languageOptions.map((language) => [language.hrefLang, `${siteUrl}${getPath(language.locale, page)}`]),
    ["x-default", `${siteUrl}${getPath("fr", page)}`],
  ]);
}

function buildGuideAlternates(path: string) {
  return {
    fr: `${siteUrl}${path}`,
    "x-default": `${siteUrl}${path}`,
  };
}

export function getSitemapEntries(): SitemapEntry[] {
  const staticEntries = sitemapPages.flatMap((page) =>
    languageOptions.map((language) => ({
      url: `${siteUrl}${getPath(language.locale, page)}`,
      lastModified: sitemapLastModified,
      changeFrequency: "monthly" as const,
      priority: page === "home" ? (1 as const) : (0.6 as const),
      alternates: buildPageAlternates(page),
    })),
  );

  const guideEntries = guideOrder.map((slug) => {
    const guide = guidePages[slug];

    return {
      url: `${siteUrl}${guide.path}`,
      lastModified: sitemapLastModified,
      changeFrequency: "monthly" as const,
      priority: 0.8 as const,
      alternates: buildGuideAlternates(guide.path),
    };
  });

  return [...staticEntries, ...guideEntries];
}
