export type Locale = "fr" | "en";
export type PageKind = "home" | "privacy" | "support" | "author";
export type GuideSlug = "calcul-tva-ht-ttc" | "revenu-net-auto-entrepreneur" | "calcul-marge-tva";

export interface LanguageOption {
  locale: Locale;
  label: string;
  shortLabel: string;
  hrefLang: string;
  homeHref: string;
  privacyHref: string;
  supportHref: string;
  authorHref: string;
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

export interface GuideSection {
  title: string;
  body: string;
  points?: string[];
}

export interface GuidePageContent {
  slug: GuideSlug;
  path: string;
  title: string;
  metaTitle: string;
  metaDescription: string;
  eyebrow: string;
  headline: string;
  intro: string;
  image: string;
  imageAlt: string;
  primaryCta: string;
  sections: GuideSection[];
  appPitch: {
    title: string;
    body: string;
  };
  disclaimer: string;
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

export interface AuthorLink {
  label: string;
  href: string;
}

export interface AuthorContent {
  locale: Locale;
  metaTitle: string;
  metaDescription: string;
  eyebrow: string;
  title: string;
  role: string;
  intro: string;
  body: string;
  appTitle: string;
  appBody: string;
  factsTitle: string;
  facts: string[];
  linksTitle: string;
  links: AuthorLink[];
  homeMention: string;
  guideMention: string;
  footerLabel: string;
}

export const siteUrl = (process.env.NEXT_PUBLIC_SITE_URL || "https://calculette.tax").replace(/\/$/, "");
export const appStoreUrl =
  process.env.NEXT_PUBLIC_APP_STORE_URL ||
  "https://apps.apple.com/fr/app/calculette-fiscale/id6769760817?uo=4";
export const umamiScriptUrl = process.env.NEXT_PUBLIC_UMAMI_SCRIPT_URL?.trim() || "";
export const umamiWebsiteId = process.env.NEXT_PUBLIC_UMAMI_WEBSITE_ID?.trim() || "";
export const supportEmail = "support@calculette.tax";
export const defaultLocale: Locale = "fr";
export const authorName = "Gauthier Huguenin";
export const authorWebsiteUrl = "https://hgnn.io/";
export const authorLinkedInUrl = "https://fr.linkedin.com/in/gauthierhuguenin";
export const authorSameAs = [authorWebsiteUrl, authorLinkedInUrl];

export const guideOrder: GuideSlug[] = [
  "calcul-tva-ht-ttc",
  "revenu-net-auto-entrepreneur",
  "calcul-marge-tva",
];

export const languageOptions: LanguageOption[] = [
  {
    locale: "fr",
    label: "Français",
    shortLabel: "FR",
    hrefLang: "fr",
    homeHref: "/",
    privacyHref: "/privacy",
    supportHref: "/support",
    authorHref: "/gauthier-huguenin",
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
    authorHref: "/en/gauthier-huguenin",
    ogLocale: "en_US",
  },
];

export const guidePages: Record<GuideSlug, GuidePageContent> = {
  "calcul-tva-ht-ttc": {
    slug: "calcul-tva-ht-ttc",
    path: "/calcul-tva-ht-ttc",
    title: "Calcul TVA HT TTC",
    metaTitle: "Calcul TVA HT TTC pour facture - Calculette Fiscale",
    metaDescription:
      "Passez du HT au TTC, retrouvez le HT depuis un TTC et isolez la TVA avec une calculette iPhone pensée pour les montants français.",
    eyebrow: "TVA et factures",
    headline: "Calcul TVA HT TTC pour vos devis et factures",
    intro:
      "Quand vous préparez un prix, il faut voir vite le hors taxe, le TTC et la TVA à mettre de côté. Calculette Fiscale garde ce calcul à portée de main sur iPhone.",
    image: "/images/screenshots/ht-ttc.png",
    imageAlt: "Capture iPhone du mode TVA de Calculette Fiscale",
    primaryCta: "Télécharger la calculette TVA",
    sections: [
      {
        title: "Ce que vous pouvez vérifier",
        body:
          "Le mode TVA aide à passer d'un montant HT à un TTC, à retrouver le HT depuis un TTC, ou à isoler uniquement la TVA.",
        points: ["Taux français usuels", "Taux personnalisé", "Lecture HT, TVA et TTC"],
      },
      {
        title: "Avant d'envoyer un devis",
        body:
          "Vous pouvez tester un prix en quelques secondes, puis copier le résultat principal pour le reprendre dans un message, une note ou un outil de facturation.",
      },
      {
        title: "Limites à garder en tête",
        body:
          "Le bon traitement TVA dépend de votre activité, de votre régime, de votre client et parfois du lieu de l'opération. L'app aide au calcul indicatif, elle ne valide pas votre situation fiscale.",
      },
    ],
    appPitch: {
      title: "Une calculette TVA française, sans compte",
      body:
        "Calculette Fiscale fonctionne sans backend et sans publicité. Les montants saisis restent sur l'iPhone.",
    },
    disclaimer:
      "Les calculs TVA sont indicatifs et ne remplacent pas une déclaration officielle, un expert-comptable ou un conseil fiscal adapté.",
  },
  "revenu-net-auto-entrepreneur": {
    slug: "revenu-net-auto-entrepreneur",
    path: "/revenu-net-auto-entrepreneur",
    title: "Revenu net auto-entrepreneur",
    metaTitle: "Revenu net auto-entrepreneur et charges - Calculette Fiscale",
    metaDescription:
      "Estimez ce qu'il reste après charges en micro-entreprise avec une calculette iPhone pour freelances, indépendants et auto-entrepreneurs.",
    eyebrow: "Micro-entreprise",
    headline: "Revenu net auto-entrepreneur : voir ce qu'il reste",
    intro:
      "Un chiffre d'affaires ne dit pas ce que vous gardez. Calculette Fiscale aide à estimer le net après cotisations pour les profils micro pris en charge en V1.",
    image: "/images/screenshots/net-pro.png",
    imageAlt: "Capture iPhone du mode Net pro de Calculette Fiscale",
    primaryCta: "Estimer mon net sur iPhone",
    sections: [
      {
        title: "Pour décider avant de facturer",
        body:
          "Le mode Net pro part d'un montant de chiffre d'affaires et affiche une estimation du net, avec les lignes qui expliquent ce qui est mis de côté.",
        points: ["Micro-BIC vente", "Micro-BIC prestation", "Micro-BNC prestation"],
      },
      {
        title: "Ce que l'app rend visible",
        body:
          "L'app distingue le montant HT, la TVA quand elle s'applique, les cotisations estimées et le net indicatif. La version Pro affiche aussi les formules et le jeu de règles utilisé.",
      },
      {
        title: "Ce qui n'est pas couvert en V1",
        body:
          "La V1 ne calcule pas l'ACRE, la CFE, le barème progressif de l'impôt sur le revenu, la Cipav, les cas DOM ou les activités mixtes.",
      },
    ],
    appPitch: {
      title: "Pensée pour les indépendants qui décident vite",
      body:
        "Vous pouvez tester un montant, comparer un objectif net et garder un historique local sans créer de compte.",
    },
    disclaimer:
      "Le revenu net affiché est une estimation indicative. Il ne remplace pas une déclaration URSSAF, une déclaration fiscale ou un conseil adapté.",
  },
  "calcul-marge-tva": {
    slug: "calcul-marge-tva",
    path: "/calcul-marge-tva",
    title: "Calcul marge avec TVA",
    metaTitle: "Calcul marge, taux de marge et TVA - Calculette Fiscale",
    metaDescription:
      "Comparez prix d'achat, prix de vente, marge brute HT, taux de marge, taux de marque et TVA nette depuis une calculette iPhone.",
    eyebrow: "Prix et marge",
    headline: "Calcul marge avec TVA : voir ce que rapporte une vente",
    intro:
      "Avant de vendre, il faut savoir si le prix couvre vraiment l'achat, la TVA et la marge attendue. Le mode Marge met les principaux chiffres au même endroit.",
    image: "/images/screenshots/marge.png",
    imageAlt: "Capture iPhone du mode Marge de Calculette Fiscale",
    primaryCta: "Calculer ma marge sur iPhone",
    sections: [
      {
        title: "Les chiffres à comparer",
        body:
          "Le mode Marge compare un prix d'achat et un prix de vente pour afficher la marge brute HT, le taux de marge, le taux de marque et la TVA nette.",
        points: ["Prix d'achat", "Prix de vente", "TVA collectée et déductible"],
      },
      {
        title: "Utile pour les décisions de prix",
        body:
          "Vous pouvez vérifier une vente avant de l'annoncer, tester un prix cible ou comprendre pourquoi un montant TTC flatteur ne donne pas forcément une marge suffisante.",
      },
      {
        title: "Une aide au calcul, pas une comptabilité",
        body:
          "La marge réelle dépend aussi de vos frais, de vos remises, de votre stock, de votre régime TVA et de votre comptabilité. L'app reste un outil de calcul rapide.",
      },
    ],
    appPitch: {
      title: "Une lecture claire avant de vendre",
      body:
        "Calculette Fiscale rassemble TVA, marge et résultat principal dans une interface iPhone simple, avec historique local en Pro.",
    },
    disclaimer:
      "Les résultats de marge sont indicatifs. Ils ne remplacent pas une comptabilité, une déclaration officielle ou un conseil adapté.",
  },
};

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
      subtitle: "TVA, net pro, objectif net et marge pour décider plus vite.",
      body:
        "L'app aide les indépendants, freelances et dirigeants de TPE à comprendre ce qu'il y a derrière un montant avant un devis, une vente ou une décision de prix.",
      appStoreReady: "Télécharger sur l'App Store",
      appStoreSoon: "Bientôt sur l'App Store",
    },
    sections: {
      title: "Quatre calculs pour vos montants du quotidien",
      intro:
        "La V1 couvre les usages qui reviennent avant un devis, une facture ou une décision de prix.",
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

export const authorContent: Record<Locale, AuthorContent> = {
  fr: {
    locale: "fr",
    metaTitle: "Gauthier Huguenin - Créateur de Calculette Fiscale",
    metaDescription:
      "Gauthier Huguenin est le créateur de Calculette Fiscale, une app iPhone française pour calculer TVA, net pro et marge sans compte.",
    eyebrow: "Créateur de l'app",
    title: "Gauthier Huguenin",
    role: "Créateur et développeur de Calculette Fiscale",
    intro:
      "Gauthier Huguenin conçoit Calculette Fiscale comme une app iPhone simple, locale et sans compte pour aider les indépendants à vérifier leurs montants français.",
    body:
      "Le site présente les limites de l'app, les calculs couverts en V1 et les choix de confidentialité. Les montants fiscaux restent calculés de façon déterministe dans l'app, sans backend et sans envoi au développeur.",
    appTitle: "À propos de Calculette Fiscale",
    appBody:
      "Calculette Fiscale couvre les calculs HT, TTC, TVA, net pro, objectif net et marge pour des décisions rapides avant un devis, une facture ou une vente.",
    factsTitle: "Repères",
    facts: [
      "App iOS native en SwiftUI",
      "Calculs fiscaux indicatifs et déterministes",
      "Aucun compte, aucune publicité, aucun backend applicatif",
    ],
    linksTitle: "Profils publics",
    links: [
      { label: "Site professionnel HGNN", href: authorWebsiteUrl },
      { label: "LinkedIn", href: authorLinkedInUrl },
    ],
    homeMention: "Créée par Gauthier Huguenin.",
    guideMention: "Guide publié par Gauthier Huguenin, créateur de Calculette Fiscale.",
    footerLabel: "Gauthier Huguenin",
  },
  en: {
    locale: "en",
    metaTitle: "Gauthier Huguenin - Creator of Calculette Fiscale",
    metaDescription:
      "Gauthier Huguenin is the creator of Calculette Fiscale, a French iPhone app for VAT, net estimates and margin calculations.",
    eyebrow: "App creator",
    title: "Gauthier Huguenin",
    role: "Creator and developer of Calculette Fiscale",
    intro:
      "Gauthier Huguenin builds Calculette Fiscale as a simple, local and account-free iPhone app for checking French business amounts.",
    body:
      "The website documents the app limits, the calculations supported in version 1 and the privacy choices. Tax amounts are calculated deterministically inside the app, without a backend and without sending entries to the developer.",
    appTitle: "About Calculette Fiscale",
    appBody:
      "Calculette Fiscale covers net, gross, VAT, professional net estimates, net goals and margin for quick decisions before a quote, invoice or sale.",
    factsTitle: "Signals",
    facts: [
      "Native SwiftUI iOS app",
      "Indicative and deterministic tax calculations",
      "No account, no ads, no app backend",
    ],
    linksTitle: "Public profiles",
    links: [
      { label: "HGNN professional website", href: authorWebsiteUrl },
      { label: "LinkedIn", href: authorLinkedInUrl },
    ],
    homeMention: "Created by Gauthier Huguenin.",
    guideMention: "Guide published by Gauthier Huguenin, creator of Calculette Fiscale.",
    footerLabel: "Gauthier Huguenin",
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

  if (page === "author") {
    return language.authorHref;
  }

  return language.homeHref;
}

export function getGuidePath(slug: GuideSlug) {
  return guidePages[slug].path;
}
