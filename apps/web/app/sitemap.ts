import type { MetadataRoute } from "next";

import { getSitemapEntries } from "@/lib/sitemap";

export default function sitemap(): MetadataRoute.Sitemap {
  return getSitemapEntries().map((entry) => ({
    url: entry.url,
    lastModified: entry.lastModified,
    changeFrequency: entry.changeFrequency,
    priority: entry.priority,
    alternates: {
      languages: entry.alternates,
    },
  }));
}
