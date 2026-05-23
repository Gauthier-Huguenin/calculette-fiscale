import Link from "next/link";

import { authorContent, getLanguage, supportEmail, type Locale } from "@/lib/site-content";

interface SiteFooterProps {
  locale: Locale;
}

export function SiteFooter({ locale }: SiteFooterProps) {
  const language = getLanguage(locale);
  const copyright = locale === "fr" ? "Tous droits réservés." : "All rights reserved.";

  return (
    <footer className="border-t border-line px-5 py-8 text-sm text-ink/60 sm:px-8">
      <div className="mx-auto flex max-w-6xl flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <p>2026 Gauthier Huguenin. {copyright}</p>
        <div className="flex flex-wrap gap-4">
          <Link className="hover:text-ink" href={language.privacyHref}>
            {locale === "fr" ? "Confidentialité" : "Privacy"}
          </Link>
          <Link className="hover:text-ink" href={language.supportHref}>
            Support
          </Link>
          <Link className="hover:text-ink" href={language.authorHref}>
            {authorContent[locale].footerLabel}
          </Link>
          <a className="hover:text-ink" href={`mailto:${supportEmail}`}>
            {supportEmail}
          </a>
        </div>
      </div>
    </footer>
  );
}
