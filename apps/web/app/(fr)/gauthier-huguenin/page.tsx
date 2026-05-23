import { AuthorPage } from "@/components/author-page";
import { buildMetadata } from "@/lib/seo-metadata";

export const metadata = buildMetadata("fr", "author");

export default function FrenchAuthorPage() {
  return <AuthorPage locale="fr" />;
}
