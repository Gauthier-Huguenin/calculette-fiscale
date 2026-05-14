# Note produit. Calculette fiscale francaise

Date de reference : 2026-05-14

## Idee en une phrase

Construire une calculette iOS native qui ressemble a une vraie calculatrice de poche, mais pensee pour les montants francais : HT, TTC, TVA, charges, net estime, objectif net, marge et calculs fiscaux courants.

Le positionnement n'est pas "simulateur d'impot". Le positionnement est :

> La Calculette Apple pour savoir combien il reste vraiment.

## Constat de depart

Quand on cherche une application iOS de "calculette fiscale francaise", on trouve surtout trois familles :

- des apps TVA, utiles mais limitees au passage HT/TTC ;
- des simulateurs d'impot, souvent plus proches d'un formulaire que d'une calculette ;
- des calculateurs financiers ou patrimoniaux, complets mais trop lourds pour un usage quotidien.

Il manque une app simple, rapide, native, fiable et francaise qui reponde aux questions pratiques que se posent les independants, dirigeants et freelances avant de facturer, negocier ou encaisser.

## Promesse utilisateur

L'utilisateur tape un montant. L'app repond immediatement aux questions suivantes :

- si je facture ce montant, combien dois-je garder pour la TVA ?
- combien me reste-t-il environ apres cotisations ?
- si je veux garder un montant net, combien dois-je facturer ?
- ce prix TTC correspond a combien en HT ?
- quelle marge je fais vraiment sur cette vente ?
- quel est l'ordre de grandeur fiscal de cette operation ?

Le tout doit rester aussi rapide qu'une calculette, pas comme un outil de declaration.

## Public cible

### Coeur de cible

- Freelances et independants francais.
- Micro-entrepreneurs en prestation de services.
- Consultants, developpeurs, designers, formateurs, createurs de contenu.
- Dirigeants de TPE qui manipulent souvent HT, TTC, TVA, marge et net.

### Cible secondaire

- Artisans et commercants.
- Comptables ou office managers qui veulent un outil de poche.
- Particuliers avances pour PFU, plus-value simple, estimation rapide ou frais.

## Angle differenciant

L'app ne doit pas etre "une calculatrice TVA de plus".

La difference doit etre visible des le premier lancement :

- un vrai clavier de calculette ;
- des touches fiscales francaises ;
- des resultats en langage clair ;
- des formules affichees a la demande ;
- des baremes dates et sources ;
- aucun calcul important confie a une IA probabiliste ;
- une experience offline et instantanee.

La valeur n'est pas seulement de calculer. La valeur est de transformer un montant brut en montant utile pour decider.

## Principes produit

1. Rapidite avant exhaustivite.
2. Calculs deterministes, testes et versionnes.
3. Fiscalite expliquee, mais sans faire semblant de remplacer un expert-comptable.
4. Donnees sensibles locales par defaut.
5. Pas de compte obligatoire.
6. Interface native, calme, dense, utilisable d'une main.
7. V1 assez complete pour ne pas se heurter frontalement aux apps TVA existantes.

## V1 proposee

La V1 doit contenir trois modes principaux et un socle commun.

### Socle commun

- Clavier numerique type calculette.
- Operations classiques : addition, soustraction, multiplication, division, pourcentage, inversion signe, effacer, retour arriere.
- Historique des calculs.
- Copie rapide d'un resultat.
- Format euros francais.
- Arrondis explicites.
- Fonctionnement offline.
- Mode sombre et mode clair.
- Haptics discrets.
- Typographie Inter integree si elle reste lisible et naturelle sur iOS. Fallback SF Pro si necessaire.

### Mode 1. TVA

Objectif : etre meilleure que les apps TVA basiques.

Fonctions :

- HT vers TTC.
- TTC vers HT.
- TVA seule.
- Taux francais : 20 %, 10 %, 5,5 %, 2,1 %.
- Taux personnalise.
- Selection rapide du taux actif.
- Historique montrant la formule, par exemple "100 HT + TVA 20 % = 120 TTC".
- Copie en une ligne : HT, TVA, TTC.

Points d'attention :

- Verifier les taux applicables avant publication.
- Ne pas promettre que l'app determine automatiquement le bon taux selon le produit ou service.

### Mode 2. Independant

Objectif : repondre a la vraie question douloureuse : "combien il me reste ?"

Profils V1 valides :

- Micro-BNC prestation.
- Micro-BIC prestation.
- Micro-BIC vente.

Profils repousses apres V1 :

- SASU dividendes ou salaire.
- EURL/TNS.
- Professions liberales Cipav, sauf si un choix explicite est ajoute plus tard.

Fonctions :

- Montant facture HT ou TTC.
- TVA a mettre de cote si assujetti.
- Chiffre d'affaires HT.
- Cotisations sociales estimees selon profil.
- Revenu avant impot estime.
- Montant approximatif "a garder prudemment".
- Option "franchise en base de TVA".

Important :

- Les calculs de cotisations doivent etre presentes comme des estimations.
- Chaque profil doit afficher la date de mise a jour du bareme.
- L'app doit distinguer clairement TVA, cotisations et impot sur le revenu.

### Mode 3. Objectif net

Objectif : aider l'utilisateur a fixer un prix.

Fonctions :

- L'utilisateur saisit le montant qu'il veut garder.
- Il choisit son profil fiscal/social.
- L'app estime le montant HT a facturer.
- L'app affiche le TTC si TVA applicable.
- L'app affiche le detail inverse : objectif net, cotisations estimees, TVA, montant facture.

Exemples de questions traitees :

- "Je veux garder 2 500 euros. Je dois facturer combien ?"
- "Je veux me payer 500 euros sur cette mission. Quel devis HT ?"
- "Je vends une prestation a 1 200 euros HT. Combien je garde environ ?"

### Mode 4. Marge

Ce module fait partie de la V1. Il est important parce qu'il sort l'app de la simple categorie des calculateurs TVA et parle directement aux dirigeants de TPE.

Fonctions :

- Prix d'achat HT ou TTC.
- Prix de vente HT ou TTC.
- Taux de TVA.
- Marge brute.
- Taux de marge.
- Taux de marque.
- TVA collectee et deductible.

Ce module n'est pas strictement fiscal, mais il colle au besoin quotidien des dirigeants.

## Hors scope V1

- Declaration fiscale complete.
- Calcul exact de l'impot sur le revenu avec toutes les cases.
- Optimisation fiscale.
- Conseil personnalise.
- Connexion bancaire.
- Connexion impots.gouv.
- Synchronisation cloud obligatoire.
- LLM qui calcule des montants.
- Gestion multi-utilisateurs.
- Export comptable avance.

## Calculs et fiabilite

Les montants doivent venir d'un moteur de calcul deterministe.

Architecture logique :

- `TaxRuleSet` : version des regles fiscales et sociales utilisees.
- `TaxProfile` : profil utilisateur, par exemple micro-BNC ou micro-BIC.
- `CalculationInput` : montant, sens du calcul, taux, profil.
- `CalculationResult` : resultats numeriques, formule, avertissements.
- `CalculationHistoryEntry` : entree locale dans l'historique.

Chaque calcul important doit avoir :

- une formule lisible ;
- des tests unitaires ;
- une date de mise a jour ;
- une source officielle ou primaire ;
- une phrase de limite, si le calcul est une estimation.

Sources a verifier avant implementation :

- impots.gouv.fr ;
- bofip.impots.gouv.fr ;
- urssaf.fr ;
- service-public.fr ;
- textes officiels lorsque necessaire.

Source interne a utiliser avant implementation :

- `docs/fiscal-rules-research-2026.md`, recherche officielle realisee le 2026-05-14.

## Relation a l'IA

L'IA ne doit pas etre le coeur visible de la V1.

Bonne utilisation possible :

- expliquer un calcul en langage simple ;
- aider a choisir un module ;
- reformuler un resultat ;
- preparer une note a copier ;
- suggerer les donnees manquantes.

Mauvaise utilisation :

- calculer directement TVA, cotisations, impot ou net ;
- inventer un bareme ;
- choisir automatiquement un regime fiscal sans garde-fou.

Position recommandee :

> Les calculs sont faits par des formules verifiees. L'IA, si elle arrive plus tard, explique et guide.

## UX attendue

Direction retenue :

- s'inspirer de la Calculette Apple pour la simplicite, la densite et la rapidite ;
- garder une interface de calcul avant tout, avec le resultat fiscal comme prolongement naturel du montant saisi ;
- eviter l'apparence d'un formulaire administratif.

Premier ecran :

- une zone de resultat ;
- un clavier ;
- une rangee de touches fiscales ;
- un segment de mode : TVA, Independant, Objectif net, Marge ;
- un bouton historique.

Onboarding minimal :

- choix du profil : "Je suis en micro", "Je facture avec TVA", "Je ne sais pas encore".
- possibilite de passer.
- aucun compte.

Interactions cles :

- appui court sur `+TVA` : ajoute le taux actif ;
- appui long sur le taux : changer de taux ;
- appui sur le resultat : copier ;
- glisser vers le haut : ouvrir le detail du calcul ;
- historique consultable et effacable localement.

## Ton et contenu

Le ton doit etre rassurant, francais, concret.

Exemples de microcopy :

- "TVA a mettre de cote"
- "Estimation apres cotisations"
- "Montant a facturer"
- "Formule utilisee"
- "Bareme mis a jour le ..."
- "Estimation, pas une declaration"

A eviter :

- jargon fiscal inutile ;
- promesses d'optimisation ;
- messages anxiogenes ;
- claims du type "calcule vos impots exactement".

## Confidentialite

Les montants saisis sont sensibles.

Regles V1 :

- pas de compte ;
- historique local uniquement ;
- pas d'envoi des montants vers un serveur ;
- analytics sans valeur monetaire saisie ;
- pas de tracking publicitaire ;
- politique de confidentialite simple.

Evenements analytics possibles :

- module ouvert ;
- achat pro affiche ;
- achat pro effectue ;
- calcul copie ;
- historique utilise.

Evenements a eviter :

- montant saisi ;
- revenu estime ;
- profil fiscal associe a un identifiant personnel ;
- historique complet.

## Modele economique

Hypothese de depart : achat unique plutot qu'abonnement.

Option recommandee :

- app gratuite ;
- TVA et calculette standard gratuites ;
- modes Independant, Objectif net et Marge dans une version Pro ;
- achat unique a 9,99 euros au lancement ;
- pas de publicite.

Option future :

- abonnement annuel seulement si l'app devient un produit fiscal maintenu avec mises a jour de baremes, modules avances et alertes.

Prix retenu V1 :

**9,99 euros**

Ce prix positionne l'app comme un petit outil professionnel, sans abonnement et sans publicite.

## Positionnement App Store

Nom definitif :

**Calculette Fiscale**

Sous-titre recommande :

**TVA, charges & net**

Promesse App Store :

> HT, TTC, TVA, charges et net estime dans une seule calculette francaise.

Raison du choix :

- La recherche "Calculette Fiscale" est tres peu encombre. Elle ne remonte pas de concurrent direct visible au moment de la verification.
- La recherche "Calculette TVA" est beaucoup plus concurrentielle. Plusieurs apps TVA y sont deja positionnees.
- "Calculette Fiscale" cree une categorie plus large que la TVA seule et laisse de la place aux modules charges, objectif net, marge, micro-entreprise, PFU ou IS.
- "Calculette TVA & Net" reste une bonne formule marketing pour les captures, la description et les textes de conversion, mais le nom principal doit etre plus defensible et moins noye.

Categorie probable :

- Finance en categorie principale.
- Utilitaires en categorie secondaire si possible.

Langue et localisation :

- Produit, interface, microcopy et App Store en francais.
- Pas de version anglaise en V1.
- Les identifiants techniques restent en anglais ou en reverse domain lorsque c'est la convention iOS.

Nom technique recommande :

- Bundle identifier : `io.hgnn.calculettefiscale`
- Display name : `Calculette Fiscale`

Mots-cles probables :

- calculette fiscale
- calcul TVA
- HT TTC
- micro entreprise
- freelance
- auto entrepreneur
- charges sociales
- revenu net
- marge
- impot

Captures d'ecran a prevoir :

- "Tapez un montant. Voyez ce qu'il reste."
- "HT, TVA, TTC en un geste."
- "Estimez vos charges d'independant."
- "Trouvez le montant a facturer pour un objectif net."
- "Des formules claires, des baremes dates."
- "La calculette TVA & net pour independants francais."

## Risques

### Risque fiscal

Le produit peut etre percu comme un conseil fiscal.

Mitigation :

- disclaimers clairs ;
- sources officielles ;
- calculs dates ;
- language d'estimation ;
- pas de promesse d'exactitude universelle.

### Risque produit

L'app peut devenir trop complexe et perdre son avantage de calculette.

Mitigation :

- clavier toujours central ;
- modules limites ;
- detail accessible seulement a la demande ;
- aucune navigation lourde.

### Risque concurrence

Les apps TVA sont deja presentes.

Mitigation :

- ne pas se battre seulement sur la TVA ;
- gagner sur "combien il reste" ;
- viser les independants et dirigeants, pas seulement les achats TTC.

### Risque maintenance

Les baremes changent.

Mitigation :

- constantes versionnees ;
- ecran "baremes" ;
- changelog fiscal ;
- tests automatises ;
- limiter les profils V1 aux cas maintenables.

## Critere de succes V1

La V1 est reussie si :

- l'utilisateur comprend la promesse en moins de 5 secondes ;
- un calcul HT/TTC prend moins de 3 secondes ;
- un freelance peut estimer son net sans lire une documentation ;
- chaque resultat important est explicable ;
- aucune donnee sensible ne quitte l'app ;
- l'app peut etre maintenue sans dette fiscale ingouvernable.

## Roadmap proposee

### Phase 0. Validation papier

- Choisir le nom.
- Choisir les profils V1.
- Lister les formules exactes.
- Verifier les sources officielles.
- Definir le wording legal.
- Designer l'ecran principal.

### Phase 1. Prototype local

- Calculette standard.
- Mode TVA.
- Historique local.
- Premier design iOS.
- Tests unitaires TVA.

### Phase 2. V1 Pro

- Mode Independant.
- Mode Objectif net.
- Module Marge.
- Paywall achat unique.
- Sources et dates de baremes.
- Tests unitaires de tous les profils.

### Phase 3. TestFlight

- Tester avec 5 a 10 independants.
- Observer les calculs les plus utilises.
- Corriger le vocabulaire.
- Verifier les incomprehensions.

### Phase 4. App Store

- Page App Store optimisee.
- Captures claires.
- Politique de confidentialite.
- Soumission Apple.
- Suivi impressions, installations, conversion Pro.

## Decisions fermees avant creation

Les decisions structurantes sont fermees pour lancer la creation :

1. Le mode Marge fait partie de la V1.
2. Le positionnement reste large : independants et dirigeants, avec un coeur de cible micro-entrepreneur.
3. Le nom App Store est `Calculette Fiscale`.
4. Le sous-titre ASO est `TVA, charges & net`.
5. Le prix V1 Pro est 9,99 euros en achat unique.
6. L'interface est 100 % en francais.
7. L'inspiration principale est la Calculette Apple, adaptee aux resultats fiscaux francais.
8. La confidentialite V1 est locale par defaut, sans backend.
9. Les calculs fiscaux V1 sont documentes dans `docs/fiscal-rules-research-2026.md`.

## Verdict

L'angle est solide si l'app reste une calculette, pas un simulateur administratif.

La differenciation tient en une promesse :

> Transformer n'importe quel montant francais en HT, TTC, TVA, charges, marge et net utile en quelques secondes.

Avec un compte Apple Developer deja disponible et un cout marginal proche de zero, le bon pari est de sortir une V1 ambitieuse mais contenue, puis de laisser les usages reels decider des modules suivants.
