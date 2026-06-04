# Calculette Fiscale

Monorepo de l'app iOS `Calculette Fiscale`.

`Calculette Fiscale` est une calculette francaise pour transformer rapidement un montant en HT, TTC, TVA, charges, net estime et marge.

## Structure

```text
apps/
  ios/
    CalculetteFiscale.xcodeproj/
    CalculetteFiscale/
      Sources/
        Domain/
        State/
        Store/
        Views/
      Resources/
        CalculetteFiscale.storekit
        PrivacyInfo.xcprivacy
    CalculetteFiscaleTests/
  web/
    app/
    components/
    lib/
    public/images/
docs/
  product-note-calculette-fiscale.md
  fiscal-rules-research-2026.md
  website/
  releases/
```

Espaces prevus plus tard :

- `apps/android/` pour une app Android.
- `apps/macos/` pour une app Mac.
- `apps/web/` ou `sites/www/` pour le site associe.
- `packages/` pour du code partage non specifique a une plateforme.

## App iOS

- Projet : `apps/ios/CalculetteFiscale.xcodeproj`
- Scheme : `CalculetteFiscale`
- Bundle identifier : `io.hgnn.calculettefiscale`
- Langue V1 : francais
- UI : SwiftUI, interface sombre avec 4 calculettes métier depuis `1.1.0`
- Cible minimum : iOS 17
- Version marketing : `1.1.0`
- Build : `4`
- Domaine : calculs deterministes dans `Sources/Domain`, constantes fiscales versionnees avec le jeu de regles `fr-2026-v1-2026-05-14`
- Etat local : `Sources/State`, historique encode en JSON dans `UserDefaults`, limite aux 50 derniers calculs
- Monetisation : StoreKit 2 dans `Sources/Store`, achat unique non-consommable `pro_lifetime`, fichier local `Resources/CalculetteFiscale.storekit`
- Donnees : aucun backend et aucun envoi de montant ou de profil, manifest de confidentialite dans `Resources/PrivacyInfo.xcprivacy`

Build local :

```bash
xcodebuild -project apps/ios/CalculetteFiscale.xcodeproj -scheme CalculetteFiscale -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /private/tmp/calculette-fiscale-derived CODE_SIGNING_ALLOWED=NO build
```

Tests :

```bash
xcodebuild -project apps/ios/CalculetteFiscale.xcodeproj -scheme CalculetteFiscale -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /private/tmp/calculette-fiscale-derived CODE_SIGNING_ALLOWED=NO test
```

## Site web

Le site public vit dans `apps/web`.

- Stack : Next.js App Router, TypeScript et Tailwind CSS.
- Langue par defaut : francais.
- Anglais : routes sous `/en`.
- URL publique cible : `https://calculette.tax`.
- Pages App Store Connect : `/privacy` et `/support`.
- Page auteur SEO : `/gauthier-huguenin` et `/en/gauthier-huguenin`.
- Analytics web : Umami auto-heberge, sans cookies, configure via variables publiques.
- Donnees app : pas de backend et aucun envoi de montant ou de profil.
- Indexation : `/sitemap.xml` standard et `/sitemap-gsc.xml` pour Google Search Console.
- Donnees structurees : `MobileApplication`, `Article` et page `ProfilePage` pour Gauthier Huguenin.

Commandes depuis la racine :

```bash
npm run dev:web
npm run build:web
npm run typecheck:web
npm run lint:web
```

Coolify doit cibler `apps/web` comme dossier applicatif.

Le depot n'utilise pas GitHub Actions. Le build du site web est realise par
Coolify sur le VPS depuis `apps/web`. Les builds et tests iOS restent des
commandes locales a lancer avec Xcode ou `xcodebuild`.

- Runtime variable : `NIXPACKS_NODE_VERSION=22.13.0`
- Install command : `npm ci --include=dev --no-audit --no-fund`
- Build command : `npm run build`
- Start command : `npm run start`
- Port : `3000`

Le dossier `apps/web` garde son propre `package-lock.json` parce que Coolify
construit ce dossier directement, sans utiliser le lockfile de la racine.

## Tester l'achat Pro localement

Le scheme `CalculetteFiscale` reference `CalculetteFiscale/Resources/CalculetteFiscale.storekit`.
Ce fichier contient le produit local :

- Type : achat integre non-consommable.
- Product id : `pro_lifetime`.
- Nom : `Calculette Fiscale Pro`.
- Prix de test : `9.99`.

Workflow manuel dans Xcode :

1. Ouvrir `apps/ios/CalculetteFiscale.xcodeproj`.
2. Selectionner le scheme `CalculetteFiscale` et un simulateur iPhone.
3. Verifier que la StoreKit Configuration du scheme pointe vers `CalculetteFiscale.storekit`.
4. Lancer l'app et verifier que `Reste net`, `Objectif net`, `TVA` et `Marge` sont utilisables sans achat.
5. Toucher l'historique ou le detail complet.
6. Le paywall doit s'ouvrir. Acheter `Calculette Fiscale Pro` via la feuille StoreKit locale.
7. L'historique et le detail complet doivent se debloquer immediatement.
7. Pour rejouer le scenario, reinitialiser les transactions StoreKit locales dans Xcode, puis relancer l'app.

La restauration utilise `AppStore.sync()` uniquement depuis le bouton `Restaurer mes achats`.
Si le produit StoreKit ne se charge pas, les quatre calculettes de base et la
copie du resume restent utilisables.

Configuration App Store Connect V1 publiee :

- App Store URL : `https://apps.apple.com/fr/app/calculette-fiscale/id6769760817?uo=4`.
- Achat integre non-consommable : `pro_lifetime`.
- Nom : `Calculette Fiscale Pro`.
- Prix cible : `9,99 EUR`.
- Garder l'affichage du prix dans l'app base sur `Product.displayPrice`.

## Documents de reference

- `docs/product-note-calculette-fiscale.md` : note produit, positionnement, V1, UX, modele economique et decisions.
- `docs/fiscal-rules-research-2026.md` : recherche fiscale officielle, constantes, formules, limites et tests attendus pour le moteur de calcul.
- `docs/website/` : structure, routes publiques, configuration Coolify et URLs App Store Connect du site.
- `docs/releases/` : textes de publication App Store, notes de version, metadonnees App Store Connect et brouillons des pages publiques.

## Decisions retenues

- Nom App Store : `Calculette Fiscale`.
- Sous-titre ASO : `TVA, net pro & marge`.
- Prix V1 Pro : 9,99 euros en achat unique.
- Confidentialite : calculs locaux, pas de backend.
- Repository : monorepo, extensible vers Android, Mac et web.

## V1 iOS

Calculettes livrees :

- Reste net : montant facture ou encaisse, HT/TTC, TVA a mettre de cote, cotisations estimees et net indicatif.
- Objectif net : objectif a garder, montant HT a facturer, TTC indicatif si la TVA s'applique, TVA collectee et cotisations estimees.
- TVA : HT vers TTC, TTC vers HT, TVA seule, taux 20 %, 10 %, 5,5 %, 2,1 % et taux personnalise.
- Marge : prix d'achat, prix de vente, HT/TTC, marge brute HT, taux de marge, taux de marque et TVA.
- Gratuit : TVA, Reste net, Objectif net, Marge simple et copie du resume.
- Pro : historique, detail complet des formules et fonctions de confort.

Limites V1 :

- Pas d'ACRE, CFE, IR progressif, Cipav, SASU, EURL, DOM, Corse, activites mixtes ou optimisation fiscale.
- Les resultats fiscaux sont des estimations indicatives. Ils ne remplacent pas une declaration officielle ni un conseil adapte.
