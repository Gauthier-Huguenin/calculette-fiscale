# Metadonnees App Store Connect

Source : preparation interne pour App Store Connect, mise a jour pour la version
1.0.1 le 2026-05-21T20:58:53+0400.

Ce fichier archive les champs editoriaux et de configuration a renseigner pour
la publication de Calculette Fiscale. Les coordonnees personnelles de
verification Apple ne sont pas archivees en clair dans le depot.

## Sources Apple utilisees

- Metadonnees App Store Connect :
  https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information
- Proprietes localisables et modifiables :
  https://developer.apple.com/help/app-store-connect/reference/app-information/required-localizable-and-editable-properties
- Specifications des captures :
  https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications
- Confidentialite App Store :
  https://developer.apple.com/app-store/app-privacy-details/
- Achats integres :
  https://developer.apple.com/help/app-store-connect/reference/in-app-purchases-and-subscriptions/in-app-purchase-information

Limites Apple retenues au 2026-05-21 :

- Nom : 30 caracteres maximum.
- Sous-titre : 30 caracteres maximum.
- Texte promotionnel : 170 caracteres maximum.
- Description : 4 000 caracteres maximum.
- Mots-cles : 100 octets maximum.
- Nouveautes : 4 000 caracteres maximum.
- Captures : 1 a 10 captures par taille d'ecran, en `.jpeg`, `.jpg` ou `.png`.

## Informations app globales

- Nom : `Calculette Fiscale`
- Sous-titre : `TVA, net pro & marge`
- Bundle ID : `io.hgnn.calculettefiscale`
- SKU recommande : `io.hgnn.calculettefiscale`
- Version marketing : `1.0.1`
- Build : `2`
- Cible minimum : `iOS 17.0`
- Apple Developer Team : `393ZW5QCU6`
- Langue principale : `Francais`
- Localisations V1 : francais uniquement
- Categorie principale recommandee : `Finance`
- Categorie secondaire recommandee : `Utilitaires`
- Classification par age recommandee : `4+`
- Droits relatifs au contenu : l'app ne contient pas, n'affiche pas et n'accede
  pas a du contenu tiers.
- Contrat de licence : contrat type de Licence Utilisateur Final d'Apple.
- Copyright : `2026 Gauthier Huguenin`
- URL d'assistance : `https://calculette.tax/support`
- URL marketing : `https://calculette.tax`
- URL de politique de confidentialite : `https://calculette.tax/privacy`
- Dossier web Coolify : `apps/web`

## Champs App Store, francais

### Nom

```text
Calculette Fiscale
```

Compteur : 18 caracteres sur 30.

### Sous-titre

```text
TVA, net pro & marge
```

Compteur : 20 caracteres sur 30.

### Texte promotionnel

```text
TVA, net pro, objectif net et marge dans une calculette française. Sans compte, sans pub, sans abonnement.
```

Compteur : 106 caracteres sur 170.

### Mots-cles

```text
ttc,horstaxe,micro,autoentrepreneur,freelance,charges,urssaf,devis,prix,facture,cotisations
```

Compteur : 91 octets sur 100.

Notes ASO :

- Ne pas repeter `Calculette Fiscale`, deja couvert par le nom.
- Ne pas repeter `TVA`, `net` ou `marge`, deja couverts par le sous-titre.
- `HT` n'est pas ajoute seul car Apple demande des mots-cles de plus de deux
  caracteres. `horstaxe` couvre l'intention de recherche.
- La fiche garde l'angle `TVA, net pro, marge`, plus differenciant qu'une app
  TVA pure et plus prudent qu'une promesse de declaration fiscale.

### Description

```text
Calculette Fiscale est la calculette française pour comprendre vite ce qu'il y a derrière un montant : TVA, HT, TTC, net pro estimé, objectif net et marge.

Elle aide les indépendants, freelances, micro-entrepreneurs, dirigeants de TPE, artisans, commerçants et consultants à préparer un devis, vérifier un prix ou lire une marge sans ouvrir un tableur.

TVA
Passez du HT au TTC, du TTC au HT, ou calculez uniquement la TVA. Les taux français usuels sont inclus : 20 %, 10 %, 5,5 % et 2,1 %. Vous pouvez aussi saisir un taux personnalisé.

NET PRO
Estimez ce qu'il reste après cotisations pour les profils micro pris en charge dans la V1 : Micro-BIC vente, Micro-BIC prestation et Micro-BNC prestation. L'app distingue le chiffre d'affaires HT, la TVA à mettre de côté, les cotisations estimées et le net indicatif.

OBJECTIF NET
Partez du montant que vous voulez garder et obtenez une estimation du montant HT à facturer, avec le TTC si la TVA s'applique. Pratique pour cadrer une mission, préparer un devis ou vérifier un prix avant de l'annoncer.

MARGE
Comparez un prix d'achat et un prix de vente. Calculette Fiscale calcule la marge brute HT, le taux de marge, le taux de marque, la TVA collectée, la TVA déductible et la TVA nette.

FORMULES
Les résultats Pro affichent le détail du calcul, la formule utilisée, les avertissements utiles et l'identifiant du jeu de règles fiscales. Les barèmes V1 sont datés et sourcés dans la documentation interne de l'app.

CONFIDENTIALITÉ
Pas de compte. Pas de publicité. Pas de backend. Les montants et l'historique restent stockés localement sur votre iPhone. L'achat Pro utilise StoreKit 2, le système d'achat intégré d'Apple.

GRATUIT, PUIS PRO SI VOUS EN AVEZ BESOIN
La calculette standard, le mode TVA et la copie du résultat principal sont gratuits. La version Pro débloque Net pro, Objectif net, Marge, l'historique et le détail complet des formules avec un achat unique, sans abonnement.

Calculette Fiscale fournit des estimations indicatives. Elle ne remplace pas une déclaration officielle, un expert-comptable ou un conseil fiscal adapté à votre situation.
```

Compteur : 2 113 caracteres sur 4 000.

## Achats integres

### Calculette Fiscale Pro

- Type : achat integre non-consommable.
- Nom de reference : `Calculette Fiscale Pro`
- Product ID : `pro_lifetime`
- Prix cible : `9,99 EUR`
- Partage familial : non prevu en V1.

Localisation francaise :

- Nom d'affichage : `Calculette Fiscale Pro`
- Description App Store Connect : `Net pro, marge, historique et formules.`

Contraintes Apple :

- Nom d'affichage : 24 caracteres sur 30.
- Description : 39 caracteres sur 45.

## Verification Apple

- Connexion requise : non.
- Compte de test : aucun.
- Achat integre a tester : `pro_lifetime`.
- Mode de publication recommande : publication manuelle apres approbation Apple.
- Reinitialisation de la note moyenne : sans objet pour la V1.

Remarques de verification proposees :

```text
L'app ne necessite pas de compte et ne contient pas de backend. Les montants saisis et l'historique des calculs restent stockes localement sur l'appareil avec UserDefaults. La version Pro utilise StoreKit 2 avec l'achat non-consommable pro_lifetime. Le mode TVA et la copie du resultat principal restent utilisables sans achat. Les modes Net pro, Objectif net, Marge, l'historique et le detail complet des formules sont deverrouilles apres achat ou restauration.
```

## Confidentialite de l'app

Etat recommande pour la V1, sous reserve de verification finale du binaire soumis :

- Apercu page produit : `Donnees non collectees`.
- Texte attendu : `Le developpeur ne collecte aucune donnee avec cette app.`
- Types de donnees collectees par le developpeur : aucun.
- Tracking publicitaire : non.
- Publicite : non.
- Analytics tiers : non detecte dans le code actuel.
- Privacy manifest : `Resources/PrivacyInfo.xcprivacy`, avec declaration de
  `NSPrivacyAccessedAPICategoryUserDefaults` pour l'historique local et l'etat
  Pro.
- Donnees traitees localement : montants saisis, historique des calculs, etat Pro
  cache localement.
- Donnees transmises a Apple : transactions StoreKit gerees par Apple pour
  l'achat integre.

Formulation prudente :

```text
Dans l'etat actuel du code, Calculette Fiscale n'envoie pas les montants saisis au developpeur et n'integre pas de SDK publicitaire ou analytique tiers. Les pratiques de confidentialite doivent etre revues si un SDK, un backend, une synchronisation ou une analytics est ajoute avant soumission.
```

## Accessibilite de l'app

Recommandations a declarer seulement apres verification manuelle sur le build
final :

- Interface sombre.
- Contraste suffisant, si la verification visuelle confirme les contrastes.
- Police plus grande et texte dynamique, si les principaux ecrans restent
  utilisables avec les tailles systeme.
- VoiceOver, si les boutons et resultats sont correctement annonces.
- Differencier sans couleur seule, si les etats importants ne dependent pas
  uniquement de la couleur.
- Animations reduites : l'app n'a pas d'animations complexes en V1.

## Plan de captures App Store

Format prioritaire recommande : iPhone 6,9 pouces en portrait. Fournir 6
captures, avec le meme style visuel que l'app et du texte court.

1. `Tapez un montant. Voyez ce qu'il reste.`
   - Ecran : mode TVA ou resultat principal lisible.
   - Objectif : faire comprendre la promesse en moins de 5 secondes.
2. `HT, TVA, TTC en un geste.`
   - Ecran : mode TVA, taux 20 %, lignes HT, TVA et TTC.
   - Objectif : capter les recherches TVA et HT/TTC.
3. `Estimez votre net pro.`
   - Ecran : mode Net pro avec Micro-BNC ou Micro-BIC.
   - Objectif : montrer la difference avec une simple calculette TVA.
4. `Fixez un prix depuis votre objectif net.`
   - Ecran : mode Objectif net.
   - Objectif : parler devis, mission et prix a facturer.
5. `Controlez votre marge avant de vendre.`
   - Ecran : mode Marge avec achat, vente, taux de marge et TVA nette.
   - Objectif : toucher les dirigeants, artisans et commercants.
6. `Formules claires. Donnees locales.`
   - Ecran : detail du calcul ou historique.
   - Objectif : rassurer sur la transparence et la confidentialite.

Set brut capture le 2026-05-21 : 6 captures simulateur conservees dans
`docs/releases/app-store-screenshots/raw/`. La cinquieme capture regroupe
historique local et formules visibles. La sixieme montre les reglages
personnalisables : taux de TVA, profil micro et options du calcul.

Set final Canva le 2026-05-15 : 6 captures iPhone `1284 x 2778` conservees
dans `docs/releases/app-store-screenshots/canva/`, pretes a etre versees dans
App Store Connect.

## Points a confirmer avant soumission

- Creer l'achat integre `pro_lifetime` dans App Store Connect.
- Refaire une verification officielle des constantes fiscales si une publication
  intervient apres une nouvelle annonce fiscale.
