import type { MetadataRoute } from "next";

import { getPath, languageOptions, siteUrl, type PageKind } from "@/lib/site-content";

const pages: PageKind[] = ["home", "privacy", "support"];

function buildAlternates(page: PageKind) {
  return {
    languages: Object.fromEntries([
      ...languageOptions.map((language) => [language.hrefLang, `${siteUrl}${getPath(language.locale, page)}`]),
      ["x-default", `${siteUrl}${getPath("fr", page)}`],
    ]),
  };
}

export default function sitemap(): MetadataRoute.Sitemap {
  const lastModified = new Date("2026-05-15");

  return pages.flatMap((page) =>
    languageOptions.map((language) => ({
      url: `${siteUrl}${getPath(language.locale, page)}`,
      lastModified,
      changeFrequency: "monthly" as const,
      priority: page === "home" ? 1 : 0.6,
      alternates: buildAlternates(page),
    })),
  );
}
