# Site internet Calculette Fiscale

Le site public vit dans `apps/web`. Le depot reste organise comme un monorepo
afin de garder l'app iOS, le site public et la documentation de publication dans
le meme historique Git, sans melanger leurs sources.

## Objectif

Le site fournit les pages publiques necessaires a App Store Connect et sert
maintenant aussi de surface d'acquisition organique :

- fournir une URL marketing publique ;
- fournir une politique de confidentialite publique ;
- fournir une page support avec contact visible ;
- proposer des pages SEO en francais pour les principaux cas d'usage ;
- relier l'app a son createur, Gauthier Huguenin, via une page auteur discrete ;
- proposer le francais par defaut et l'anglais sous `/en` ;
- utiliser un tracking web Umami auto-heberge sans cookies ;
- ne pas ajouter de publicite, de formulaire ou de backend applicatif.

## Structure

```text
apps/
  web/
    app/
    components/
    lib/
    public/images/
    public/images/screenshots/
```

## Routes publiques

- `https://calculette.tax`
- `https://calculette.tax/calcul-tva-ht-ttc`
- `https://calculette.tax/revenu-net-auto-entrepreneur`
- `https://calculette.tax/calcul-marge-tva`
- `https://calculette.tax/gauthier-huguenin`
- `https://calculette.tax/privacy`
- `https://calculette.tax/support`
- `https://calculette.tax/en`
- `https://calculette.tax/en/gauthier-huguenin`
- `https://calculette.tax/en/privacy`
- `https://calculette.tax/en/support`
- `https://calculette.tax/robots.txt`
- `https://calculette.tax/sitemap.xml`
- `https://calculette.tax/sitemap-gsc.xml`
- `https://calculette.tax/llms.txt`

Soumettre `https://calculette.tax/sitemap-gsc.xml` dans Google Search Console.
Le sitemap standard garde les alternates linguistiques, le sitemap GSC reste
volontairement simple.

Les pages d'acquisition restent en francais uniquement pour la V1. Elles
utilisent les captures App Store publiees dans `apps/web/public/images/screenshots/`.

La page auteur `/gauthier-huguenin` est le signal principal pour associer
Calculette Fiscale a Gauthier Huguenin. Elle expose aussi un balisage JSON-LD
`ProfilePage` et les pages d'app ou de guides pointent vers la meme entite
`Person`.

## Deploiement Coolify

Configurer Coolify sur le dossier applicatif `apps/web`.

- Runtime variable : `NIXPACKS_NODE_VERSION=22.13.0`
- Install command : `npm ci --include=dev --no-audit --no-fund`
- Build command : `npm run build`
- Start command : `npm run start`
- Port : `3000`

Le lockfile `apps/web/package-lock.json` est volontairement versionne, car
Coolify construit `apps/web` comme application autonome.

Variables publiques :

```bash
NEXT_PUBLIC_SITE_URL=https://calculette.tax
NEXT_PUBLIC_APP_STORE_URL=https://apps.apple.com/fr/app/calculette-fiscale/id6769760817?uo=4
NEXT_PUBLIC_UMAMI_SCRIPT_URL=https://stats.hgnn.io/script.js
NEXT_PUBLIC_UMAMI_WEBSITE_ID=7bc5c49d-c360-42b3-af67-8c02012f8517
```

L'URL App Store finale provient de l'API publique Apple pour le bundle
`io.hgnn.calculettefiscale`.

## URLs App Store Connect

- Marketing URL : `https://calculette.tax`
- Privacy Policy URL : `https://calculette.tax/privacy`
- Support URL : `https://calculette.tax/support`

## Confidentialite

Le site V1 utilise Umami auto-heberge pour des mesures agregees sans cookies.
Il n'ajoute pas de publicite, de formulaire ou de backend applicatif. Le contact
support utilise un lien `mailto:` vers `support@calculette.tax`.
