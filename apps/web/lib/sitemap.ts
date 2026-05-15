import { getPath, languageOptions, siteUrl, type PageKind } from "@/lib/site-content";

export interface SitemapEntry {
  page: PageKind;
  url: string;
  lastModified: Date;
  changeFrequency: "monthly";
  priority: 1 | 0.6;
}

export const sitemapPages: PageKind[] = ["home", "privacy", "support"];
export const sitemapLastModified = new Date("2026-05-15");

export function getSitemapEntries(): SitemapEntry[] {
  return sitemapPages.flatMap((page) =>
    languageOptions.map((language) => ({
      page,
      url: `${siteUrl}${getPath(language.locale, page)}`,
      lastModified: sitemapLastModified,
      changeFrequency: "monthly" as const,
      priority: page === "home" ? 1 : 0.6,
    })),
  );
}
