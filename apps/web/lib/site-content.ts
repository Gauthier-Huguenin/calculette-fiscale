export type Locale = "fr" | "en";
export type PageKind = "home" | "privacy" | "support";

export interface LanguageOption {
  locale: Locale;
  label: string;
  shortLabel: string;
  hrefLang: string;
  homeHref: string;
  privacyHref: string;
  supportHref: string;
  ogLocale: string;
}

export interface FeatureItem {
  title: string;
  body: string;
}

export interface QuestionAnswer {
  question: string;
  answer: string;
}

export interface HomeContent {
  locale: Locale;
  nav: {
    privacy: string;
    support: string;
    language: string;
  };
  hero: {
    eyebrow: string;
    title: string;
    subtitle: string;
    body: string;
    appStoreReady: string;
    appStoreSoon: string;
  };
  sections: {
    title: string;
    intro: string;
    features: FeatureItem[];
  };
  privacy: {
    title: string;
    body: string;
    points: string[];
  };
  legal: string;
}

export interface PrivacyContent {
  locale: Locale;
  title: string;
  updatedAt: string;
  intro: string;
  sections: FeatureItem[];
}

export interface SupportContent {
  locale: Locale;
  title: string;
  intro: string;
  emailTitle: string;
  emailBody: string;
  faqTitle: string;
  faq: QuestionAnswer[];
}

export const siteUrl = (process.env.NEXT_PUBLIC_SITE_URL || "https://calculette.tax").replace(/\/$/, "");
export const appStoreUrl = process.env.NEXT_PUBLIC_APP_STORE_URL || "";
export const umamiScriptUrl = process.env.NEXT_PUBLIC_UMAMI_SCRIPT_URL?.trim() || "";
export const umamiWebsiteId = process.env.NEXT_PUBLIC_UMAMI_WEBSITE_ID?.trim() || "";
export const supportEmail = "support@calculette.tax";
export const defaultLocale: Locale = "fr";

export const languageOptions: LanguageOption[] = [
  {
    locale: "fr",
    label: "Français",
    shortLabel: "FR",
    hrefLang: "fr",
    homeHref: "/",
    privacyHref: "/privacy",
    supportHref: "/support",
    ogLocale: "fr_FR",
  },
  {
    locale: "en",
    label: "English",
    shortLabel: "EN",
    hrefLang: "en",
    homeHref: "/en",
    privacyHref: "/en/privacy",
    supportHref: "/en/support",
    ogLocale: "en_US",
  },
];

export const homeContent: Record<Locale, HomeContent> = {
  fr: {
    locale: "fr",
    nav: {
      privacy: "Confidentialité",
      support: "Support",
      language: "English",
    },
    hero: {
      eyebrow: "App iPhone pour montants français",
      title: "Calculette Fiscale",
      subtitle: "HT, TTC, TVA, charges, net estimé et marge dans une calculette française simple.",
      body:
        "L'app aide les indépendants, freelances et dirigeants de TPE à comprendre rapidement ce qu'il y a derrière un montant avant un devis, une vente ou une décision de prix.",
      appStoreReady: "Télécharger sur l'App Store",
      appStoreSoon: "Bientôt sur l'App Store",
    },
    sections: {
      title: "Ce que couvre la V1",
      intro: "Le site reste volontairement court pour la soumission Apple. L'app ira plus loin dans l'interface iPhone.",
      features: [
        {
          title: "TVA",
          body:
            "Passez du HT au TTC, du TTC au HT ou calculez la TVA seule avec les taux français usuels et un taux personnalisé.",
        },
        {
          title: "Net pro",
          body:
            "Estimez ce qu'il reste après cotisations pour les profils micro pris en charge en V1.",
        },
        {
          title: "Objectif net",
          body:
            "Partez du montant que vous voulez garder et obtenez une estimation du montant HT à facturer.",
        },
        {
          title: "Marge",
          body:
            "Comparez achat et vente pour voir la marge brute HT, les taux de marge et de marque, puis la TVA nette.",
        },
      ],
    },
    privacy: {
      title: "Conçue pour rester locale",
      body:
        "Calculette Fiscale ne demande pas de compte et ne contient pas de backend. Les montants saisis et l'historique Pro restent sur l'iPhone.",
      points: ["App sans publicité", "App sans analytics SDK", "Site suivi avec Umami sans cookies", "Achat Pro via StoreKit 2"],
    },
    legal:
      "Les résultats fiscaux sont des estimations indicatives. Ils ne remplacent pas une déclaration officielle, un expert-comptable ou un conseil fiscal adapté.",
  },
  en: {
    locale: "en",
    nav: {
      privacy: "Privacy",
      support: "Support",
      language: "Français",
    },
    hero: {
      eyebrow: "iPhone app for French amounts",
      title: "Calculette Fiscale",
      subtitle: "VAT, net estimates, charges and margin in a simple French calculator.",
      body:
        "The app helps freelancers, independent workers and small business owners understand what sits behind an amount before a quote, a sale or a pricing decision.",
      appStoreReady: "Download on the App Store",
      appStoreSoon: "Coming soon to the App Store",
    },
    sections: {
      title: "What version 1 covers",
      intro: "This website is intentionally short for Apple review. The iPhone app carries the full calculator experience.",
      features: [
        {
          title: "VAT",
          body:
            "Convert net to gross, gross to net, or calculate VAT only with common French rates and a custom rate.",
        },
        {
          title: "Professional net",
          body:
            "Estimate what remains after social contributions for the micro business profiles supported in version 1.",
        },
        {
          title: "Net goal",
          body:
            "Start from the amount you want to keep and estimate the net amount to invoice before VAT.",
        },
        {
          title: "Margin",
          body:
            "Compare purchase and sale prices to see gross margin before VAT, margin rates and net VAT.",
        },
      ],
    },
    privacy: {
      title: "Built to stay local",
      body:
        "Calculette Fiscale does not require an account and does not use a backend. Entered amounts and Pro history stay on the iPhone.",
      points: ["No ads in the app", "No analytics SDK in the app", "Website analytics with cookie-free Umami", "Pro purchase through StoreKit 2"],
    },
    legal:
      "Tax results are indicative estimates. They do not replace an official filing, an accountant or tax advice tailored to your situation.",
  },
};

export const privacyContent: Record<Locale, PrivacyContent> = {
  fr: {
    locale: "fr",
    title: "Politique de confidentialité",
    updatedAt: "15 mai 2026",
    intro:
      "Calculette Fiscale est une app iOS de calcul fiscal indicatif. Cette page explique quelles données sont traitées par l'app et par ce site.",
    sections: [
      {
        title: "Données saisies dans l'app",
        body:
          "Vous pouvez saisir des montants, taux, modes de calcul et profils fiscaux simples. Ces informations servent uniquement à afficher les résultats dans l'app et ne sont pas envoyées au développeur.",
      },
      {
        title: "Historique local",
        body:
          "La version Pro peut conserver un historique local des derniers calculs. Cet historique est enregistré sur l'appareil et peut être effacé depuis l'app.",
      },
      {
        title: "Compte, publicité et analytics",
        body:
          "L'app ne nécessite pas de compte, ne contient pas de publicité, ne fait pas de tracking publicitaire et n'intègre pas de SDK d'analytics tiers.",
      },
      {
        title: "Achats intégrés",
        body:
          "La version Pro utilise StoreKit 2, le système d'achat intégré fourni par Apple. Les transactions sont traitées par Apple selon les conditions et la politique de confidentialité d'Apple.",
      },
      {
        title: "Site web",
        body:
          "Ce site public utilise Umami auto-hébergé pour mesurer des visites agrégées sans cookies. Les journaux techniques éventuels de l'hébergeur servent uniquement à maintenir le service.",
      },
      {
        title: "Contact",
        body: `Pour toute question, contactez ${supportEmail}.`,
      },
    ],
  },
  en: {
    locale: "en",
    title: "Privacy Policy",
    updatedAt: "May 15, 2026",
    intro:
      "Calculette Fiscale is an iOS app for indicative French tax calculations. This page explains what data is processed by the app and this website.",
    sections: [
      {
        title: "Data entered in the app",
        body:
          "You may enter amounts, rates, calculation modes and simple tax profiles. This information is only used to display results in the app and is not sent to the developer.",
      },
      {
        title: "Local history",
        body:
          "The Pro version can keep a local history of recent calculations. This history is stored on the device and can be cleared from the app.",
      },
      {
        title: "Account, ads and analytics",
        body:
          "The app does not require an account, does not show ads, does not perform advertising tracking and does not include a third-party analytics SDK.",
      },
      {
        title: "In-app purchases",
        body:
          "The Pro version uses StoreKit 2, Apple's in-app purchase system. Transactions are handled by Apple under Apple's terms and privacy policy.",
      },
      {
        title: "Website",
        body:
          "This public website uses self-hosted Umami to measure aggregate visits without cookies. Any technical hosting logs are only used to maintain the service.",
      },
      {
        title: "Contact",
        body: `For any question, contact ${supportEmail}.`,
      },
    ],
  },
};

export const supportContent: Record<Locale, SupportContent> = {
  fr: {
    locale: "fr",
    title: "Support",
    intro:
      "Besoin d'aide avec Calculette Fiscale ? Le support répond aux questions sur l'app, l'achat Pro, la confidentialité et les limites de la V1.",
    emailTitle: "Contact",
    emailBody: `Écrivez à ${supportEmail}.`,
    faqTitle: "Questions fréquentes",
    faq: [
      {
        question: "L'app remplace-t-elle un expert-comptable ?",
        answer:
          "Non. Calculette Fiscale fournit des estimations indicatives pour aider à décider plus vite. Elle ne remplace pas une déclaration officielle, un expert-comptable ou un conseil fiscal adapté.",
      },
      {
        question: "Quels profils sont pris en charge en V1 ?",
        answer:
          "La V1 couvre trois profils micro simples : Micro-BIC vente, Micro-BIC prestation et Micro-BNC prestation. Les cas ACRE, CFE, IR progressif, Cipav, SASU, EURL, DOM, Corse, activités mixtes et régimes spéciaux sont hors scope V1.",
      },
      {
        question: "Mes montants sont-ils envoyés sur un serveur ?",
        answer:
          "Non. Dans la V1, les montants saisis et l'historique restent stockés localement sur votre iPhone. L'app ne nécessite pas de compte et ne contient pas de backend.",
      },
      {
        question: "Que débloque la version Pro ?",
        answer:
          "La version Pro débloque Net pro, Objectif net, Marge, l'historique et le détail complet des formules. Il s'agit d'un achat unique via l'App Store, sans abonnement.",
      },
    ],
  },
  en: {
    locale: "en",
    title: "Support",
    intro:
      "Need help with Calculette Fiscale? Support covers the app, the Pro purchase, privacy and the limits of version 1.",
    emailTitle: "Contact",
    emailBody: `Email ${supportEmail}.`,
    faqTitle: "Frequently asked questions",
    faq: [
      {
        question: "Does the app replace an accountant?",
        answer:
          "No. Calculette Fiscale provides indicative estimates to help you make decisions faster. It does not replace an official filing, an accountant or tailored tax advice.",
      },
      {
        question: "Which profiles are supported in version 1?",
        answer:
          "Version 1 supports three simple French micro business profiles: Micro-BIC sales, Micro-BIC services and Micro-BNC services. ACRE, CFE, progressive income tax, Cipav, SASU, EURL, overseas territories, Corsica, mixed activities and special regimes are out of scope.",
      },
      {
        question: "Are my amounts sent to a server?",
        answer:
          "No. In version 1, entered amounts and history remain stored locally on your iPhone. The app does not require an account and does not use a backend.",
      },
      {
        question: "What does Pro unlock?",
        answer:
          "Pro unlocks Professional net, Net goal, Margin, history and full formula details. It is a one-time App Store purchase with no subscription.",
      },
    ],
  },
};

export function getLanguage(locale: Locale) {
  return languageOptions.find((language) => language.locale === locale) ?? languageOptions[0];
}

export function getPath(locale: Locale, page: PageKind) {
  const language = getLanguage(locale);

  if (page === "privacy") {
    return language.privacyHref;
  }

  if (page === "support") {
    return language.supportHref;
  }

  return language.homeHref;
}
