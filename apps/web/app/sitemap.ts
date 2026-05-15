import type { MetadataRoute } from "next";

import { getSitemapEntries } from "@/lib/sitemap";
import { getPath, languageOptions, siteUrl, type PageKind } from "@/lib/site-content";

function buildAlternates(page: PageKind) {
  return {
    languages: Object.fromEntries([
      ...languageOptions.map((language) => [language.hrefLang, `${siteUrl}${getPath(language.locale, page)}`]),
      ["x-default", `${siteUrl}${getPath("fr", page)}`],
    ]),
  };
}

export default function sitemap(): MetadataRoute.Sitemap {
  return getSitemapEntries().map((entry) => ({
    url: entry.url,
    lastModified: entry.lastModified,
    changeFrequency: entry.changeFrequency,
    priority: entry.priority,
    alternates: buildAlternates(entry.page),
  }));
}
