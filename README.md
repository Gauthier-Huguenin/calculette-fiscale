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
        Views/
    CalculetteFiscaleTests/
docs/
  product-note-calculette-fiscale.md
  fiscal-rules-research-2026.md
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
- UI : SwiftUI
- Cible minimum : iOS 17
- Domaine : calculs deterministes dans `Sources/Domain`, constantes fiscales versionnees avec le jeu de regles `fr-2026-v1-2026-05-14`
- Etat local : `Sources/State`, historique encode en JSON dans `UserDefaults`, limite aux 50 derniers calculs
- Donnees : aucun backend et aucun envoi de montant ou de profil

Build local :

```bash
xcodebuild -project apps/ios/CalculetteFiscale.xcodeproj -scheme CalculetteFiscale -destination 'platform=iOS Simulator,name=iPhone 17' CODE_SIGNING_ALLOWED=NO build
```

Tests :

```bash
xcodebuild -project apps/ios/CalculetteFiscale.xcodeproj -scheme CalculetteFiscale -destination 'platform=iOS Simulator,name=iPhone 17' CODE_SIGNING_ALLOWED=NO test
```

## Documents de reference

- `docs/product-note-calculette-fiscale.md` : note produit, positionnement, V1, UX, modele economique et decisions.
- `docs/fiscal-rules-research-2026.md` : recherche fiscale officielle, constantes, formules, limites et tests attendus pour le moteur de calcul.

## Decisions retenues

- Nom App Store : `Calculette Fiscale`.
- Sous-titre ASO : `TVA, charges & net`.
- Prix V1 Pro : 9,99 euros en achat unique.
- Confidentialite : calculs locaux, pas de backend.
- Repository : monorepo, extensible vers Android, Mac et web.

## V1 iOS

Modes livres :

- TVA : HT vers TTC, TTC vers HT, TVA seule, taux 20 %, 10 %, 5,5 %, 2,1 % et taux personnalise.
- Independant : micro-BIC vente, micro-BIC prestation, micro-BNC prestation regime general, franchise en base, versement liberatoire, detail TVA, cotisations et net estime.
- Objectif net : estimation du montant HT et TTC a facturer pour garder un montant cible.
- Marge : achat HT/TTC, vente HT/TTC, marge brute, taux de marge, taux de marque, TVA collectee, TVA deductible et TVA nette.

Limites V1 :

- Pas d'ACRE, CFE, IR progressif, Cipav, SASU, EURL, DOM, Corse, activites mixtes ou optimisation fiscale.
- Les resultats fiscaux sont des estimations indicatives. Ils ne remplacent pas une declaration officielle ni un conseil adapte.
