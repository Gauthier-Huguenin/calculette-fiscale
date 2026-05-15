# Site internet Calculette Fiscale

Le site public vit dans `apps/web`. Le depot reste organise comme un monorepo
afin de garder l'app iOS, le site public et la documentation de publication dans
le meme historique Git, sans melanger leurs sources.

## Objectif V1

Le site est volontairement minimal pour la soumission Apple :

- fournir une URL marketing publique ;
- fournir une politique de confidentialite publique ;
- fournir une page support avec contact visible ;
- proposer le francais par defaut et l'anglais sous `/en` ;
- ne pas ajouter d'analytics, de cookies, de publicite ou de backend.

## Structure

```text
apps/
  web/
    app/
    components/
    lib/
    public/images/
```

## Routes publiques

- `https://calculette.tax`
- `https://calculette.tax/privacy`
- `https://calculette.tax/support`
- `https://calculette.tax/en`
- `https://calculette.tax/en/privacy`
- `https://calculette.tax/en/support`
- `https://calculette.tax/robots.txt`
- `https://calculette.tax/sitemap.xml`
- `https://calculette.tax/llms.txt`

## Deploiement Coolify

Configurer Coolify sur le dossier applicatif `apps/web`.

- Build command : `npm run build`
- Start command : `npm run start`
- Port : `3000`

Variables publiques :

```bash
NEXT_PUBLIC_SITE_URL=https://calculette.tax
NEXT_PUBLIC_APP_STORE_URL=
```

Renseigner `NEXT_PUBLIC_APP_STORE_URL` quand l'URL App Store finale existe.

## URLs App Store Connect

- Marketing URL : `https://calculette.tax`
- Privacy Policy URL : `https://calculette.tax/privacy`
- Support URL : `https://calculette.tax/support`

## Confidentialite

Le site V1 n'ajoute pas d'analytics, de cookies, de publicite ou de formulaire.
Le contact support utilise un lien `mailto:` vers `support@calculette.tax`.
