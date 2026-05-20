import Image from "next/image";
import Link from "next/link";

import { appStoreUrl, getLanguage, homeContent, type Locale } from "@/lib/site-content";

interface SiteHeaderProps {
  locale: Locale;
}

export function SiteHeader({ locale }: SiteHeaderProps) {
  const content = homeContent[locale];
  const language = getLanguage(locale);
  const alternateLocale: Locale = locale === "fr" ? "en" : "fr";
  const alternateLanguage = getLanguage(alternateLocale);

  return (
    <header className="mx-auto flex w-full max-w-6xl flex-col items-start gap-4 px-5 py-5 sm:flex-row sm:items-center sm:justify-between sm:px-8">
      <Link className="flex items-center gap-3" href={language.homeHref} aria-label="Calculette Fiscale">
        <Image
          src="/images/app-icon.png"
          width={40}
          height={40}
          alt=""
          className="h-10 w-10 rounded-md"
          priority
        />
        <span className="text-sm font-semibold tracking-wide text-ink">Calculette Fiscale</span>
      </Link>

      <nav className="flex flex-wrap items-center gap-x-4 gap-y-2 text-sm font-semibold text-ink/70" aria-label="Navigation">
        <Link className="hover:text-ink" href={language.privacyHref}>
          {content.nav.privacy}
        </Link>
        <Link className="hover:text-ink" href={language.supportHref}>
          {content.nav.support}
        </Link>
        <Link className="hover:text-ink" href={alternateLanguage.homeHref} hrefLang={alternateLanguage.hrefLang}>
          {content.nav.language}
        </Link>
        {appStoreUrl ? (
          <a
            className="hidden rounded-md bg-gold px-3 py-2 text-coal sm:inline-flex"
            href={appStoreUrl}
            rel="noreferrer"
          >
            {content.hero.appStoreReady}
          </a>
        ) : null}
      </nav>
    </header>
  );
}
