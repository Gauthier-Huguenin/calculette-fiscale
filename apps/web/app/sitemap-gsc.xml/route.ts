import { getSitemapEntries } from "@/lib/sitemap";

export const dynamic = "force-static";

function escapeXml(value: string) {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&apos;");
}

export function GET() {
  const entries = getSitemapEntries()
    .map(
      (entry) => `<url>
<loc>${escapeXml(entry.url)}</loc>
<lastmod>${entry.lastModified.toISOString().slice(0, 10)}</lastmod>
<changefreq>${entry.changeFrequency}</changefreq>
<priority>${entry.priority.toFixed(1)}</priority>
</url>`,
    )
    .join("\n");

  return new Response(`<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${entries}
</urlset>
`, {
    headers: {
      "Content-Type": "application/xml; charset=utf-8",
    },
  });
}
