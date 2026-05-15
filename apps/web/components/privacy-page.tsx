import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";
import { privacyContent, type Locale } from "@/lib/site-content";

interface PrivacyPageProps {
  locale: Locale;
}

export function PrivacyPage({ locale }: PrivacyPageProps) {
  const content = privacyContent[locale];

  return (
    <div className="min-h-screen bg-coal text-ink">
      <SiteHeader locale={locale} />
      <main className="mx-auto max-w-4xl px-5 pb-16 pt-8 sm:px-8">
        <p className="text-sm font-semibold uppercase tracking-[0.22em] text-gold">
          {locale === "fr" ? "Données et confidentialité" : "Data and privacy"}
        </p>
        <h1 className="mt-4 text-4xl font-semibold text-ink sm:text-5xl">{content.title}</h1>
        <p className="mt-4 text-sm font-semibold text-ink/54">
          {locale === "fr" ? "Dernière mise à jour" : "Last updated"} : {content.updatedAt}
        </p>
        <p className="mt-8 text-lg leading-8 text-ink/70">{content.intro}</p>

        <div className="mt-10 space-y-5">
          {content.sections.map((section) => (
            <section className="rounded-md border border-line bg-panel p-5" key={section.title}>
              <h2 className="text-xl font-semibold text-ink">{section.title}</h2>
              <p className="mt-3 leading-7 text-ink/66">{section.body}</p>
            </section>
          ))}
        </div>
      </main>
      <SiteFooter locale={locale} />
    </div>
  );
}
