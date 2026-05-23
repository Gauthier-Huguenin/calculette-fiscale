import Image from "next/image";
import Link from "next/link";

import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";
import { JsonLd, buildMobileApplicationJsonLd } from "@/lib/structured-data";
import { appStoreUrl, authorContent, getLanguage, guideOrder, guidePages, homeContent, type Locale } from "@/lib/site-content";

interface MarketingPageProps {
  locale: Locale;
}

const appStoreBadgeByLocale: Record<
  Locale,
  {
    alt: string;
    height: number;
    src: string;
    width: number;
  }
> = {
  fr: {
    alt: "Télécharger dans l'App Store",
    height: 40,
    src: "/images/app-store-badge-fr.svg",
    width: 127,
  },
  en: {
    alt: "Download on the App Store",
    height: 40,
    src: "/images/app-store-badge-en.svg",
    width: 120,
  },
};

export function MarketingPage({ locale }: MarketingPageProps) {
  const content = homeContent[locale];
  const author = authorContent[locale];
  const language = getLanguage(locale);
  const guideLinks = guideOrder.map((slug) => guidePages[slug]);
  const appStoreBadge = appStoreBadgeByLocale[locale];

  return (
    <div className="min-h-screen bg-coal text-ink">
      <JsonLd data={buildMobileApplicationJsonLd(locale)} />
      <SiteHeader locale={locale} />

      <main>
        <section className="mx-auto grid w-full max-w-6xl gap-10 px-5 pb-16 pt-8 sm:px-8 lg:grid-cols-[1.05fr_0.95fr] lg:items-center lg:pb-24 lg:pt-14">
          <div className="space-y-7">
            <p className="text-sm font-semibold uppercase tracking-[0.22em] text-gold">{content.hero.eyebrow}</p>
            <div className="space-y-5">
              <h1 className="max-w-3xl text-5xl font-semibold leading-tight text-ink sm:text-6xl">
                {content.hero.title}
              </h1>
              <p className="max-w-2xl text-2xl font-semibold leading-snug text-ink/86">
                {content.hero.subtitle}
              </p>
              <p className="max-w-2xl text-lg leading-8 text-ink/66">{content.hero.body}</p>
            </div>
            <div className="flex flex-col items-start gap-5 pt-1">
              {appStoreUrl ? (
                <a className="inline-flex rounded-md" href={appStoreUrl} rel="noreferrer">
                  <Image
                    src={appStoreBadge.src}
                    width={appStoreBadge.width}
                    height={appStoreBadge.height}
                    alt={appStoreBadge.alt}
                    className="h-[46px] w-auto"
                  />
                </a>
              ) : (
                <p className="inline-flex min-h-12 items-center rounded-md border border-line px-5 text-base font-semibold text-ink/78">
                  {content.hero.appStoreSoon}
                </p>
              )}
              <Link className="inline-flex text-sm font-semibold text-ink/58 hover:text-ink" href={language.authorHref}>
                {author.homeMention}
              </Link>
            </div>
          </div>

          <div className="grid grid-cols-2 items-end gap-4 sm:gap-5 lg:justify-items-end" aria-label="Captures de l'app Calculette Fiscale">
            <div className="justify-self-end">
              <Image
                src="/images/screenshots/ht-ttc.png"
                width={1284}
                height={2778}
                alt="Mode TVA avec lignes HT, TVA et TTC"
                className="h-auto w-full max-w-[210px] rounded-[28px] border border-line shadow-2xl shadow-black/40"
                priority
              />
            </div>
            <div className="pb-10">
              <Image
                src="/images/screenshots/net-pro.png"
                width={1284}
                height={2778}
                alt="Mode Net pro pour estimer un revenu après cotisations"
                className="h-auto w-full max-w-[210px] rounded-[28px] border border-line shadow-2xl shadow-black/40"
                priority
              />
            </div>
          </div>
        </section>

        <section className="border-y border-line bg-panel/55 px-5 py-14 sm:px-8">
          <div className="mx-auto max-w-6xl">
            <div className="max-w-3xl space-y-3">
              <h2 className="text-3xl font-semibold text-ink">{content.sections.title}</h2>
              <p className="text-lg leading-8 text-ink/64">{content.sections.intro}</p>
            </div>
            <div className="mt-9 grid gap-4 md:grid-cols-2">
              {content.sections.features.map((feature) => (
                <article className="rounded-md border border-line bg-coal p-5" key={feature.title}>
                  <h3 className="text-xl font-semibold text-gold">{feature.title}</h3>
                  <p className="mt-3 leading-7 text-ink/68">{feature.body}</p>
                </article>
              ))}
            </div>
          </div>
        </section>

        {locale === "fr" ? (
          <section className="mx-auto max-w-6xl px-5 py-14 sm:px-8">
            <div className="max-w-3xl space-y-3">
              <h2 className="text-3xl font-semibold text-ink">Guides rapides pour vos calculs</h2>
              <p className="text-lg leading-8 text-ink/64">
                {"Chaque guide part d'une question concrète et montre comment l'app peut aider avant de télécharger."}
              </p>
            </div>
            <div className="mt-9 grid gap-4 md:grid-cols-3">
              {guideLinks.map((guide) => (
                <Link
                  className="rounded-md border border-line bg-panel p-5 transition hover:border-gold/70 hover:bg-panel/80"
                  href={guide.path}
                  key={guide.slug}
                >
                  <p className="text-sm font-semibold uppercase tracking-[0.18em] text-gold">{guide.eyebrow}</p>
                  <h3 className="mt-4 text-xl font-semibold text-ink">{guide.title}</h3>
                  <p className="mt-3 leading-7 text-ink/66">{guide.metaDescription}</p>
                </Link>
              ))}
            </div>
          </section>
        ) : null}

        <section className="mx-auto grid max-w-6xl gap-8 px-5 py-14 sm:px-8 lg:grid-cols-[0.8fr_1.2fr] lg:items-start">
          <div>
            <h2 className="text-3xl font-semibold text-ink">{content.privacy.title}</h2>
            <p className="mt-4 text-lg leading-8 text-ink/66">{content.privacy.body}</p>
          </div>
          <ul className="grid gap-3 sm:grid-cols-2">
            {content.privacy.points.map((point) => (
              <li className="rounded-md border border-line bg-panel px-4 py-4 font-semibold text-ink/80" key={point}>
                {point}
              </li>
            ))}
          </ul>
          <p className="lg:col-span-2 rounded-md border border-line bg-panel px-5 py-4 text-sm leading-6 text-ink/60">
            {content.legal}
          </p>
        </section>
      </main>

      <SiteFooter locale={locale} />
    </div>
  );
}
