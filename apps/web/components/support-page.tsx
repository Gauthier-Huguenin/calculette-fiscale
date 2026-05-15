import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";
import { supportContent, supportEmail, type Locale } from "@/lib/site-content";

interface SupportPageProps {
  locale: Locale;
}

export function SupportPage({ locale }: SupportPageProps) {
  const content = supportContent[locale];

  return (
    <div className="min-h-screen bg-coal text-ink">
      <SiteHeader locale={locale} />
      <main className="mx-auto max-w-4xl px-5 pb-16 pt-8 sm:px-8">
        <p className="text-sm font-semibold uppercase tracking-[0.22em] text-gold">
          {locale === "fr" ? "Aide et contact" : "Help and contact"}
        </p>
        <h1 className="mt-4 text-4xl font-semibold text-ink sm:text-5xl">{content.title}</h1>
        <p className="mt-8 text-lg leading-8 text-ink/70">{content.intro}</p>

        <section className="mt-10 rounded-md border border-line bg-panel p-5">
          <h2 className="text-xl font-semibold text-ink">{content.emailTitle}</h2>
          <p className="mt-3 leading-7 text-ink/66">{content.emailBody}</p>
          <a
            className="mt-5 inline-flex min-h-12 items-center rounded-md bg-gold px-5 font-semibold text-coal"
            href={`mailto:${supportEmail}`}
          >
            {supportEmail}
          </a>
        </section>

        <section className="mt-10">
          <h2 className="text-2xl font-semibold text-ink">{content.faqTitle}</h2>
          <div className="mt-5 space-y-4">
            {content.faq.map((item) => (
              <article className="rounded-md border border-line bg-panel p-5" key={item.question}>
                <h3 className="text-lg font-semibold text-gold">{item.question}</h3>
                <p className="mt-3 leading-7 text-ink/66">{item.answer}</p>
              </article>
            ))}
          </div>
        </section>
      </main>
      <SiteFooter locale={locale} />
    </div>
  );
}
