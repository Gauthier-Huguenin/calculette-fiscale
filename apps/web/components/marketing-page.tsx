import Image from "next/image";

import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";
import { appStoreUrl, homeContent, type Locale } from "@/lib/site-content";

interface MarketingPageProps {
  locale: Locale;
}

export function MarketingPage({ locale }: MarketingPageProps) {
  const content = homeContent[locale];

  return (
    <div className="min-h-screen bg-coal text-ink">
      <SiteHeader locale={locale} />

      <main>
        <section className="mx-auto grid w-full max-w-6xl gap-10 px-5 pb-16 pt-8 sm:px-8 lg:grid-cols-[1.1fr_0.9fr] lg:items-center lg:pb-24 lg:pt-14">
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
            {appStoreUrl ? (
              <a
                className="inline-flex min-h-12 items-center rounded-md bg-gold px-5 text-base font-semibold text-coal"
                href={appStoreUrl}
                rel="noreferrer"
              >
                {content.hero.appStoreReady}
              </a>
            ) : (
              <p className="inline-flex min-h-12 items-center rounded-md border border-line px-5 text-base font-semibold text-ink/78">
                {content.hero.appStoreSoon}
              </p>
            )}
          </div>

          <div className="flex justify-center lg:justify-end">
            <div className="w-full max-w-sm rounded-md border border-line bg-panel p-8">
              <Image
                src="/images/app-icon.png"
                width={160}
                height={160}
                alt="Calculette Fiscale"
                className="mx-auto h-40 w-40 rounded-[32px]"
                priority
              />
              <div className="mt-8 grid grid-cols-2 gap-3 text-sm font-semibold text-ink/74">
                <span className="rounded-md bg-coal px-3 py-3 text-center">HT</span>
                <span className="rounded-md bg-coal px-3 py-3 text-center">TTC</span>
                <span className="rounded-md bg-coal px-3 py-3 text-center">TVA</span>
                <span className="rounded-md bg-coal px-3 py-3 text-center">Marge</span>
              </div>
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
