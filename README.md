# Calculette Fiscale

Monorepo de l'app iOS `Calculette Fiscale`.

`Calculette Fiscale` est une calculette francaise pour transformer rapidement un montant en HT, TTC, TVA, charges, net estime et marge.

## Structure

```text
apps/
  ios/
    CalculetteFiscale.xcodeproj/
    CalculetteFiscale/
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
