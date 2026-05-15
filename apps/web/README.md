# Calculette Fiscale Web

Site public minimal de Calculette Fiscale, construit avec Next.js App Router,
TypeScript et Tailwind CSS.

Le site existe d'abord pour fournir a Apple des pages publiques stables avant la
publication de la V1 iOS.

## Pages

- `/` : accueil en francais, langue par defaut.
- `/privacy` : politique de confidentialite en francais.
- `/support` : support en francais, URL recommandee pour App Store Connect.
- `/en` : accueil en anglais.
- `/en/privacy` : politique de confidentialite en anglais.
- `/en/support` : support en anglais.
- `/robots.txt` et `/sitemap.xml` : fichiers publics pour l'indexation.
- `/llms.txt` : resume court pour les moteurs de recherche IA.

## Configuration

Copier `.env.example` vers `.env.local` en local si necessaire, puis renseigner :

```bash
NEXT_PUBLIC_SITE_URL=https://calculette.tax
NEXT_PUBLIC_APP_STORE_URL=
```

`NEXT_PUBLIC_APP_STORE_URL` reste vide tant que l'URL App Store finale n'existe
pas. Le bouton public affiche alors un etat de pre-lancement.

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

- Build command : `npm run build`
- Start command : `npm run start`
- Port : `3000`

Variables publiques :

```bash
NEXT_PUBLIC_SITE_URL=https://calculette.tax
NEXT_PUBLIC_APP_STORE_URL=
```

Dans App Store Connect, utiliser les URLs publiques suivantes :

- Marketing URL : `https://calculette.tax`
- Privacy Policy URL : `https://calculette.tax/privacy`
- Support URL : `https://calculette.tax/support`
