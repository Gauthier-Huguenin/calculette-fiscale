# Archives de publication Calculette Fiscale

Ce dossier conserve les textes et decisions de publication pour chaque version de
Calculette Fiscale.

Il sert de source de verite interne pour :

- les notes App Store en francais ;
- les textes promotionnels App Store ;
- les descriptions, mots-cles, URLs, captures et metadonnees editables ;
- les informations de build, branche, commit et soumission Apple ;
- les textes de verification Apple ;
- les informations d'achat integre ;
- les brouillons des pages publiques support, confidentialite et marketing ;
- les tests realises avant publication ;
- les points encore a confirmer.

Les captures App Store brutes prises localement vivent dans
`docs/releases/app-store-screenshots/raw/`. Les exports finaux prepares pour
App Store Connect vivent dans `docs/releases/app-store-screenshots/canva/`.

## Captures RAW

Les captures RAW iOS 1.0.1 utilisent des fixtures `DEBUG` lancees avec
`CALCULETTE_SCREENSHOT_SCENARIO`.

Scenarios disponibles :

- `01-tva-facture`
- `02-net-pro`
- `03-objectif-net`
- `04-marge`
- `05-historique-local`
- `06-personnalisation`

Format de reference : simulateur iPhone 17 Pro en portrait, `1206 x 2622`.

## Convention

Chaque version doit avoir son propre fichier :

```text
docs/releases/1.0.0.md
docs/releases/1.0.1.md
```

La release GitHub publique ne doit etre creee qu'apres validation et publication
effective de la version par Apple.

Utiliser `template.md` pour preparer les prochaines versions.

## Regles de redaction

- Rediger les textes publics uniquement en francais pour la V1.
- Ne jamais promettre une declaration officielle, une optimisation fiscale ou un
  calcul exact pour toutes les situations.
- Mentionner clairement que les calculs de cotisations et de net sont des
  estimations indicatives.
- Garder les exclusions V1 hors de la promesse App Store : ACRE, CFE, IR
  progressif, activites mixtes, Cipav, SASU, EURL, DOM, Corse, regimes speciaux
  et declarations officielles.
- Conserver les coordonnees personnelles de verification Apple hors depot.
