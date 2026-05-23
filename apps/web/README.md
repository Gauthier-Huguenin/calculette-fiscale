# Calculette Fiscale Web

Site public de Calculette Fiscale, construit avec Next.js App Router,
TypeScript et Tailwind CSS.

Le site fournit les pages publiques App Store Connect et des pages
d'acquisition en francais pour les recherches liees a la TVA, au net
auto-entrepreneur et a la marge.

## Pages

- `/` : accueil en francais, langue par defaut.
- `/calcul-tva-ht-ttc` : guide francais pour les intentions TVA, HT, TTC et facture.
- `/revenu-net-auto-entrepreneur` : guide francais pour le net et les charges micro-entrepreneur.
- `/calcul-marge-tva` : guide francais pour la marge, le taux de marge et la TVA nette.
- `/gauthier-huguenin` : page auteur francaise pour relier l'app a son createur.
- `/privacy` : politique de confidentialite en francais.
- `/support` : support en francais, URL recommandee pour App Store Connect.
- `/en` : accueil en anglais.
- `/en/gauthier-huguenin` : page auteur en anglais.
- `/en/privacy` : politique de confidentialite en anglais.
- `/en/support` : support en anglais.
- `/robots.txt` et `/sitemap.xml` : fichiers publics pour l'indexation.
- `/sitemap-gsc.xml` : sitemap simple a soumettre dans Google Search Console.
- `/llms.txt` : resume court pour les moteurs de recherche IA.

Les captures publiques de l'app vivent dans `public/images/screenshots/` et
proviennent des exports App Store conserves dans `docs/releases/`.

Les pages publiques exposent des donnees structurees JSON-LD pour l'app
`MobileApplication`, les guides `Article` et la page auteur `ProfilePage` de
Gauthier Huguenin.

## Configuration

Copier `.env.example` vers `.env.local` en local si necessaire, puis renseigner :

```bash
NEXT_PUBLIC_SITE_URL=https://calculette.tax
NEXT_PUBLIC_APP_STORE_URL=https://apps.apple.com/fr/app/calculette-fiscale/id6769760817?uo=4
NEXT_PUBLIC_UMAMI_SCRIPT_URL=https://stats.hgnn.io/script.js
NEXT_PUBLIC_UMAMI_WEBSITE_ID=7bc5c49d-c360-42b3-af67-8c02012f8517
```

Le bouton public pointe vers l'App Store quand `NEXT_PUBLIC_APP_STORE_URL` est
renseigne.

Le script Umami n'est injecte que si `NEXT_PUBLIC_UMAMI_SCRIPT_URL` et
`NEXT_PUBLIC_UMAMI_WEBSITE_ID` sont renseignes.

## Commandes

Depuis la racine du depot :

```bash
npm run dev:web
npm run build:web
npm run typecheck:web
npm run lint:web
```

Depuis `apps/web` :

```bash
npm run dev
npm run build
npm run typecheck
npm run lint
```

## Coolify

Configurer Coolify sur le dossier `apps/web`.

- Runtime variable : `NIXPACKS_NODE_VERSION=22.13.0`
- Install command : `npm ci --include=dev --no-audit --no-fund`
- Build command : `npm run build`
- Start command : `npm run start`
- Port : `3000`

Le lockfile `package-lock.json` de ce dossier doit etre commite. Coolify utilise
`apps/web` comme dossier applicatif et ne voit pas le lockfile de la racine.

Variables publiques :

```bash
NEXT_PUBLIC_SITE_URL=https://calculette.tax
NEXT_PUBLIC_APP_STORE_URL=https://apps.apple.com/fr/app/calculette-fiscale/id6769760817?uo=4
NEXT_PUBLIC_UMAMI_SCRIPT_URL=https://stats.hgnn.io/script.js
NEXT_PUBLIC_UMAMI_WEBSITE_ID=7bc5c49d-c360-42b3-af67-8c02012f8517
```

Dans App Store Connect, utiliser les URLs publiques suivantes :

- Marketing URL : `https://calculette.tax`
- Privacy Policy URL : `https://calculette.tax/privacy`
- Support URL : `https://calculette.tax/support`
