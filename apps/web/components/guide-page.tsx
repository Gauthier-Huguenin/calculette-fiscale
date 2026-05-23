import Image from "next/image";
import Link from "next/link";

import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";
import { JsonLd, buildGuideArticleJsonLd } from "@/lib/structured-data";
import { appStoreUrl, authorContent, guideOrder, guidePages, type GuideSlug } from "@/lib/site-content";

interface GuidePageProps {
  slug: GuideSlug;
}

export function GuidePage({ slug }: GuidePageProps) {
  const guide = guidePages[slug];
  const relatedGuides = guideOrder.filter((relatedSlug) => relatedSlug !== slug).map((relatedSlug) => guidePages[relatedSlug]);

  return (
    <div className="min-h-screen bg-coal text-ink">
      <JsonLd data={buildGuideArticleJsonLd(slug)} />
      <SiteHeader locale="fr" />

      <main>
        <article>
          <section className="mx-auto grid w-full max-w-6xl gap-10 px-5 pb-14 pt-8 sm:px-8 lg:grid-cols-[1fr_0.78fr] lg:items-center lg:pb-20 lg:pt-14">
            <div className="space-y-7">
              <Link className="text-sm font-semibold text-ink/62 hover:text-ink" href="/">
                Calculette Fiscale
              </Link>
              <div className="space-y-5">
                <p className="text-sm font-semibold uppercase tracking-[0.22em] text-gold">{guide.eyebrow}</p>
                <h1 className="max-w-3xl text-4xl font-semibold leading-tight text-ink sm:text-6xl">
                  {guide.headline}
                </h1>
                <p className="max-w-2xl text-lg leading-8 text-ink/68">{guide.intro}</p>
              </div>
              {appStoreUrl ? (
                <a
                  className="inline-flex min-h-12 items-center rounded-md bg-gold px-5 text-base font-semibold text-coal"
                  href={appStoreUrl}
                  rel="noreferrer"
                >
                  {guide.primaryCta}
                </a>
              ) : null}
              <Link className="inline-flex text-sm font-semibold text-ink/58 hover:text-ink" href="/gauthier-huguenin">
                {authorContent.fr.guideMention}
              </Link>
            </div>

            <div className="flex justify-center lg:justify-end">
              <Image
                src={guide.image}
                width={1284}
                height={2778}
                alt={guide.imageAlt}
                className="h-auto w-full max-w-[250px] rounded-[30px] border border-line shadow-2xl shadow-black/40"
                priority
              />
            </div>
          </section>

          <section className="border-y border-line bg-panel/55 px-5 py-14 sm:px-8">
            <div className="mx-auto grid max-w-6xl gap-4 md:grid-cols-3">
              {guide.sections.map((section) => (
                <section className="rounded-md border border-line bg-coal p-5" key={section.title}>
                  <h2 className="text-xl font-semibold text-gold">{section.title}</h2>
                  <p className="mt-3 leading-7 text-ink/68">{section.body}</p>
                  {section.points ? (
                    <ul className="mt-5 space-y-2 text-sm font-semibold text-ink/78">
                      {section.points.map((point) => (
                        <li className="rounded-md bg-panel px-3 py-2" key={point}>
                          {point}
                        </li>
                      ))}
                    </ul>
                  ) : null}
                </section>
              ))}
            </div>
          </section>

          <section className="mx-auto grid max-w-6xl gap-8 px-5 py-14 sm:px-8 lg:grid-cols-[0.9fr_1.1fr]">
            <div>
              <h2 className="text-3xl font-semibold text-ink">{guide.appPitch.title}</h2>
              <p className="mt-4 text-lg leading-8 text-ink/66">{guide.appPitch.body}</p>
              {appStoreUrl ? (
                <a
                  className="mt-6 inline-flex min-h-12 items-center rounded-md bg-gold px-5 text-base font-semibold text-coal"
                  href={appStoreUrl}
                  rel="noreferrer"
                >
                  {"Télécharger sur l'App Store"}
                </a>
              ) : null}
            </div>
            <div className="rounded-md border border-line bg-panel p-5">
              <h2 className="text-xl font-semibold text-ink">Autres calculs utiles</h2>
              <div className="mt-5 grid gap-3">
                {relatedGuides.map((relatedGuide) => (
                  <Link
                    className="rounded-md border border-line bg-coal px-4 py-4 hover:border-gold/70"
                    href={relatedGuide.path}
                    key={relatedGuide.slug}
                  >
                    <p className="text-sm font-semibold uppercase tracking-[0.16em] text-gold">
                      {relatedGuide.eyebrow}
                    </p>
                    <p className="mt-2 font-semibold text-ink">{relatedGuide.title}</p>
                  </Link>
                ))}
              </div>
            </div>
            <p className="lg:col-span-2 rounded-md border border-line bg-panel px-5 py-4 text-sm leading-6 text-ink/60">
              {guide.disclaimer}
            </p>
          </section>
        </article>
      </main>

      <SiteFooter locale="fr" />
    </div>
  );
}
