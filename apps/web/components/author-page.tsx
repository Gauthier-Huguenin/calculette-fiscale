import Link from "next/link";

import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";
import { JsonLd, buildProfilePageJsonLd } from "@/lib/structured-data";
import { authorContent, getLanguage, type Locale } from "@/lib/site-content";

interface AuthorPageProps {
  locale: Locale;
}

export function AuthorPage({ locale }: AuthorPageProps) {
  const content = authorContent[locale];
  const language = getLanguage(locale);
  const alternateLocale: Locale = locale === "fr" ? "en" : "fr";
  const alternateLanguage = getLanguage(alternateLocale);

  return (
    <div className="min-h-screen bg-coal text-ink">
      <JsonLd data={buildProfilePageJsonLd(locale)} />
      <SiteHeader locale={locale} />

      <main>
        <article>
          <section className="mx-auto grid w-full max-w-6xl gap-10 px-5 pb-14 pt-8 sm:px-8 lg:grid-cols-[1fr_0.78fr] lg:items-start lg:pb-20 lg:pt-14">
            <div className="space-y-7">
              <Link className="text-sm font-semibold text-ink/62 hover:text-ink" href={language.homeHref}>
                Calculette Fiscale
              </Link>
              <div className="space-y-5">
                <p className="text-sm font-semibold uppercase tracking-[0.22em] text-gold">{content.eyebrow}</p>
                <h1 className="max-w-3xl text-5xl font-semibold leading-tight text-ink sm:text-6xl">
                  {content.title}
                </h1>
                <p className="max-w-2xl text-2xl font-semibold leading-snug text-ink/86">{content.role}</p>
                <p className="max-w-2xl text-lg leading-8 text-ink/68">{content.intro}</p>
              </div>
            </div>

            <aside className="rounded-md border border-line bg-panel p-5">
              <h2 className="text-xl font-semibold text-ink">{content.factsTitle}</h2>
              <ul className="mt-5 space-y-3">
                {content.facts.map((fact) => (
                  <li className="rounded-md border border-line bg-coal px-4 py-3 font-semibold text-ink/78" key={fact}>
                    {fact}
                  </li>
                ))}
              </ul>
            </aside>
          </section>

          <section className="border-y border-line bg-panel/55 px-5 py-14 sm:px-8">
            <div className="mx-auto grid max-w-6xl gap-8 lg:grid-cols-[0.95fr_1.05fr]">
              <div>
                <h2 className="text-3xl font-semibold text-ink">{content.appTitle}</h2>
                <p className="mt-4 text-lg leading-8 text-ink/66">{content.appBody}</p>
              </div>
              <p className="text-lg leading-8 text-ink/68">{content.body}</p>
            </div>
          </section>

          <section className="mx-auto grid max-w-6xl gap-8 px-5 py-14 sm:px-8 lg:grid-cols-[0.8fr_1.2fr]">
            <div>
              <h2 className="text-3xl font-semibold text-ink">{content.linksTitle}</h2>
              <p className="mt-4 leading-7 text-ink/62">
                {locale === "fr"
                  ? "Ces liens aident les moteurs à relier cette app aux profils publics existants."
                  : "These links help search engines connect this app to existing public profiles."}
              </p>
            </div>
            <div className="grid gap-3 sm:grid-cols-2">
              {content.links.map((link) => (
                <a
                  className="rounded-md border border-line bg-panel px-5 py-4 font-semibold text-ink/82 hover:border-gold/70"
                  href={link.href}
                  key={link.href}
                  rel="noreferrer"
                >
                  {link.label}
                </a>
              ))}
              <Link
                className="rounded-md border border-line bg-panel px-5 py-4 font-semibold text-ink/82 hover:border-gold/70"
                href={alternateLanguage.authorHref}
                hrefLang={alternateLanguage.hrefLang}
              >
                {alternateLanguage.label}
              </Link>
            </div>
          </section>
        </article>
      </main>

      <SiteFooter locale={locale} />
    </div>
  );
}
