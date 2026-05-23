import { AuthorPage } from "@/components/author-page";
import { buildMetadata } from "@/lib/seo-metadata";

export const metadata = buildMetadata("en", "author");

export default function EnglishAuthorPage() {
  return <AuthorPage locale="en" />;
}
