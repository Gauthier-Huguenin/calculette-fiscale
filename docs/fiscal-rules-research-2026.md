# Recherche fiscale 2026. Calculette Fiscale

Date de recherche : 2026-05-14T15:43:03+0400
Perimetre : France, V1 iOS, calculs rapides pour TVA, micro-entreprise, objectif net et marge.

Ce document sert de source de verite fonctionnelle pour le moteur de calcul de `Calculette Fiscale`.
Il ne remplace pas les sources officielles. Il documente les constantes retenues, les formules, les limites et les tests attendus pour une implementation deterministe.

## Sources officielles consultees

Sources prioritaires :

- Direction generale des douanes et droits indirects, "Les taux de TVA", mise a jour le 27/04/2021 : https://www.douane.gouv.fr/fiche/les-taux-de-tva
- Entreprendre Service-Public, "Franchise en base de TVA", verifie le 01/01/2026 : https://entreprendre.service-public.gouv.fr/vosdroits/F21746
- impots.gouv.fr, "Je suis micro-entrepreneur ou a la tete d'une micro-entreprise. Ai-je des obligations declaratives en matiere de TVA ?", modifie le 29/04/2026 : https://www.impots.gouv.fr/professionnel/questions/je-suis-micro-entrepreneur-ou-la-tete-dune-micro-entreprise-ai-je-des
- Entreprendre Service-Public, "Quels sont les nouveaux seuils de la micro-entreprise ?", publie le 26/02/2026 : https://entreprendre.service-public.gouv.fr/actualites/A18813
- Entreprendre Service-Public, "Quelles consequences pour un micro-entrepreneur qui depasse les seuils de chiffre d'affaires ?", verifie le 21/02/2026 : https://entreprendre.service-public.gouv.fr/vosdroits/F32353
- Entreprendre Service-Public, "Cotisations sociales d'un micro-entrepreneur : ce qu'il faut savoir", verifie le 01/01/2026 : https://entreprendre.service-public.gouv.fr/vosdroits/F36232
- Entreprendre Service-Public, "Micro-entrepreneur : quand declarer son chiffre d'affaires ?", verifie le 01/01/2026 : https://entreprendre.service-public.gouv.fr/vosdroits/F23257
- Entreprendre Service-Public, "Contribution a la formation professionnelle des entrepreneurs individuels", verifie le 01/01/2026 : https://entreprendre.service-public.gouv.fr/vosdroits/F23459
- impots.gouv.fr, "Le versement liberatoire" : https://www.impots.gouv.fr/professionnel/le-versement-liberatoire
- impots.gouv.fr, "Modalites de declaration et d'imposition du micro-entrepreneur", modifie le 25/08/2025 : https://www.impots.gouv.fr/professionnel/questions/en-tant-que-micro-entrepreneur-quelles-sont-les-modalites-de-declaration-et

## Decisions produit issues de la recherche

1. La V1 couvre uniquement trois profils micro-entreprise simples :
   - `micro_bic_sale`
   - `micro_bic_service`
   - `micro_bnc_service_general`
2. La V1 exclut les professions liberales Cipav par defaut, meme si le taux existe. Ce profil demande un choix explicite, car l'utilisateur doit savoir s'il releve de la Cipav.
3. La V1 calcule un net estime apres cotisations sociales, puis affiche l'impot sur le revenu uniquement si l'utilisateur active l'option de versement liberatoire.
4. La V1 ne calcule pas l'impot progressif du foyer. Le resultat par defaut doit etre libelle "hors impot sur le revenu".
5. La contribution formation professionnelle est affichee dans le detail et dans le montant "a garder prudemment", pas comme ligne principale du net. Elle est annuelle et faible, mais reelle.
6. Le chiffre d'affaires a declarer pour les cotisations est un montant hors taxes encaisse. La TVA payee par le client n'y est pas incluse et aucune charge ne doit etre deduite.
7. L'app peut afficher des alertes de seuils, mais elle ne doit pas pretendre determiner seule le regime fiscal exact de l'utilisateur.

Phrase juridique recommandee :

> Estimation indicative calculee a partir des baremes sources ci-dessous. Cette calculette ne remplace pas une declaration officielle, un expert-comptable ou un conseil fiscal adapte a votre situation.

## Constantes TVA

Taux de TVA usuels en France metropolitaine :

| Identifiant | Libelle | Taux decimal |
| --- | --- | ---: |
| `vat_standard` | Taux normal | `0.20` |
| `vat_intermediate` | Taux intermediaire | `0.10` |
| `vat_reduced` | Taux reduit | `0.055` |
| `vat_special` | Taux particulier | `0.021` |

Choix produit :

- Taux par defaut : 20 %.
- Taux personnalise autorise.
- L'app ne determine pas automatiquement le bon taux selon le produit ou service.
- Les taux DOM, Corse, importations, operations intracommunautaires et regimes speciaux sont hors scope V1.

Formules TVA :

```text
vat_amount = ht_amount * vat_rate
ttc_amount = ht_amount + vat_amount

ht_amount = ttc_amount / (1 + vat_rate)
vat_amount = ttc_amount - ht_amount
```

Regles d'arrondi :

- Utiliser un type decimal, pas un flottant binaire.
- Conserver la precision interne pendant le calcul.
- Arrondir l'affichage en euros a 2 decimales.
- Pour les tests unitaires, arrondir a 2 decimales en fin de calcul affiche.

Tests TVA minimaux :

| Cas | Entree | Resultat attendu |
| --- | ---: | ---: |
| HT vers TTC 20 % | 100,00 HT | 120,00 TTC, TVA 20,00 |
| TTC vers HT 20 % | 120,00 TTC | 100,00 HT, TVA 20,00 |
| HT vers TTC 5,5 % | 100,00 HT | 105,50 TTC, TVA 5,50 |
| TTC vers HT 5,5 % | 105,50 TTC | 100,00 HT, TVA 5,50 |

## Franchise en base de TVA

Seuils V1 pour une entreprise etablie en France :

| Type d'activite | Seuil de base | Seuil majore |
| --- | ---: | ---: |
| Activite commerciale et hebergement | 85 000 EUR | 93 500 EUR |
| Prestation de services | 37 500 EUR | 41 250 EUR |
| Activite liberale, hors avocats | 37 500 EUR | 41 250 EUR |

Regles fonctionnelles a retenir :

- Si l'entreprise respecte la franchise en base, elle ne facture pas la TVA et ne deduit pas la TVA sur ses achats professionnels.
- Si le chiffre d'affaires depasse le seuil de base, la perte de franchise intervient au 1er janvier de l'annee suivante.
- Si le chiffre d'affaires de l'annee en cours depasse le seuil majore, la TVA s'applique des le premier jour du depassement.
- L'option volontaire pour la TVA prend effet le premier jour du mois au cours duquel elle est declaree et vaut en principe pour deux annees civiles.

Implication dans l'app :

- Toggle simple : `franchiseInBase = true/false`.
- Si `franchiseInBase = true`, afficher "TVA non facturee".
- Si `franchiseInBase = false`, les cotisations et seuils se calculent sur le CAHT, pas sur le TTC.
- Afficher une alerte non bloquante quand un montant annualise approche les seuils.

## Regime micro-fiscal. Seuils 2026, 2027 et 2028

Seuils CAHT du regime micro-entreprise :

| Type d'activite | Seuil CAHT |
| --- | ---: |
| Vente de marchandises et fourniture de logement | 203 100 EUR |
| Prestations de services et professions liberales | 83 600 EUR |

Regles fonctionnelles :

- Le chiffre d'affaires pris en compte est le CAHT effectivement encaisse.
- En premiere annee d'activite, le seuil doit etre prorate selon le nombre de jours d'existence.
- En activite mixte, le CAHT global ne doit pas depasser 203 100 EUR, avec un sous-seuil de 83 600 EUR pour les activites de services et liberales.
- En V1, les activites mixtes sont hors scope. On peut seulement afficher un avertissement.

## Profils V1

### Profil `micro_bic_sale`

Usage : achat-revente, vente de marchandises, objets, fournitures, denrees a emporter ou consommer, hors cas particuliers.

Constantes :

```text
social_contribution_rate = 0.123
vfl_income_tax_rate = 0.010
cfp_rate = 0.001
income_tax_abatement_rate = 0.71
micro_threshold = 203100
vat_franchise_base_threshold = 85000
vat_franchise_major_threshold = 93500
```

Libelles UI :

- "Micro-BIC vente"
- "Cotisations sociales estimees"
- "Versement liberatoire IR, optionnel : 1 %"
- "CFP annuelle indicative : 0,1 %"

### Profil `micro_bic_service`

Usage : prestations de services relevant des BIC.

Constantes :

```text
social_contribution_rate = 0.212
vfl_income_tax_rate = 0.017
cfp_rate_commercial = 0.001
cfp_rate_artisanal = 0.003
income_tax_abatement_rate = 0.50
micro_threshold = 83600
vat_franchise_base_threshold = 37500
vat_franchise_major_threshold = 41250
```

Decision V1 pour la CFP :

- Ne pas melanger le taux commercial et le taux artisanal dans le resultat principal.
- Dans le detail, afficher "CFP annuelle : 0,1 % a 0,3 % selon activite commerciale ou artisanale".
- Si on ajoute un reglage avance, proposer `commerciale` et `artisanale`.

Libelles UI :

- "Micro-BIC prestation"
- "Cotisations sociales estimees"
- "Versement liberatoire IR, optionnel : 1,7 %"
- "CFP annuelle indicative : 0,1 % a 0,3 %"

### Profil `micro_bnc_service_general`

Usage : activite liberale non reglementee relevant du micro-BNC et affiliee au regime general.

Constantes :

```text
social_contribution_rate = 0.256
vfl_income_tax_rate = 0.022
cfp_rate = 0.002
income_tax_abatement_rate = 0.34
micro_threshold = 83600
vat_franchise_base_threshold = 37500
vat_franchise_major_threshold = 41250
```

Point d'attention important :

- Le taux micro-BNC regime general applicable depuis le 01/01/2026 est 25,6 %, pas 24,6 %.
- Si l'utilisateur releve de la Cipav, le taux social documente est 23,2 %. Ce profil est hors scope V1 sauf choix explicite.

Libelles UI :

- "Micro-BNC prestation"
- "Cotisations sociales estimees"
- "Versement liberatoire IR, optionnel : 2,2 %"
- "CFP annuelle indicative : 0,2 %"

## Versement liberatoire de l'impot sur le revenu

Taux optionnels :

| Profil | Taux |
| --- | ---: |
| Vente ou fourniture de logement | 1,0 % du CAHT |
| Prestations de services BIC | 1,7 % du CAHT |
| BNC | 2,2 % des recettes HT |

Regles produit :

- Option desactivee par defaut.
- Quand l'option est activee, afficher une ligne separee "Versement liberatoire IR".
- Quand l'option est desactivee, afficher "Hors impot sur le revenu".
- Ne pas verifier dans la V1 si l'utilisateur remplit les conditions de revenu fiscal de reference. Ajouter seulement une note : "Option soumise a conditions".

## Abattements fiscaux micro

Abattements utiles pour expliquer, pas pour calculer le net principal :

| Profil | Abattement |
| --- | ---: |
| Micro-BIC vente | 71 % |
| Micro-BIC prestation | 50 % |
| Micro-BNC | 34 % |

Le montant minimum de l'abattement est de 305 EUR.

Usage dans l'app :

- Ne pas deduire cet abattement pour calculer la tresorerie restante. Ce n'est pas une charge sortie de banque.
- L'utiliser seulement dans un detail pedagogique "base fiscale indicative", si l'ecran existe.
- Ne pas calculer le bareme progressif IR en V1.

## Formules du mode Independant

Entrees :

```text
input_amount
input_kind = ht | ttc
vat_rate
vat_applicable = true | false
profile
vfl_enabled = true | false
include_cfp_in_prudent_reserve = true
```

Normalisation du chiffre d'affaires :

```text
if vat_applicable and input_kind == ttc:
    ca_ht = input_amount / (1 + vat_rate)
    vat_to_set_aside = input_amount - ca_ht

if vat_applicable and input_kind == ht:
    ca_ht = input_amount
    vat_to_set_aside = input_amount * vat_rate

if not vat_applicable:
    ca_ht = input_amount
    vat_to_set_aside = 0
```

Calculs :

```text
social_contributions = ca_ht * social_contribution_rate
vfl_income_tax = ca_ht * vfl_income_tax_rate if vfl_enabled else 0
cfp_estimate = ca_ht * cfp_rate_or_range

net_before_income_tax = ca_ht - social_contributions
net_after_vfl = ca_ht - social_contributions - vfl_income_tax

prudent_reserve = vat_to_set_aside + social_contributions + vfl_income_tax + cfp_estimate
```

Resultat principal recommande :

- Si VFL desactive : "Il reste environ X EUR avant impot sur le revenu".
- Si VFL active : "Il reste environ X EUR apres cotisations et versement liberatoire".
- Ligne permanente : "TVA a mettre de cote : X EUR", seulement si TVA applicable.
- Detail : cotisations, VFL, CFP, seuils, formule.

Tests micro minimaux :

| Profil | Entree | Options | Resultat attendu |
| --- | ---: | --- | ---: |
| Micro-BIC vente | 1 000 HT | TVA 20 %, VFL off | cotisations 123,00, net avant IR 877,00, TVA 200,00 |
| Micro-BIC prestation | 1 000 HT | TVA 20 %, VFL off | cotisations 212,00, net avant IR 788,00, TVA 200,00 |
| Micro-BNC general | 1 000 HT | TVA 20 %, VFL off | cotisations 256,00, net avant IR 744,00, TVA 200,00 |
| Micro-BNC general | 1 200 TTC | TVA 20 %, VFL off | CAHT 1 000,00, TVA 200,00, cotisations 256,00, net avant IR 744,00 |
| Micro-BNC general | 1 000 HT | TVA 20 %, VFL on | cotisations 256,00, VFL 22,00, net apres VFL 722,00 |

## Formules du mode Objectif net

Objectif V1 : convertir un montant voulu en CAHT a facturer.

Formule par defaut, hors IR :

```text
required_ca_ht = target_net / (1 - social_contribution_rate)
```

Formule avec VFL :

```text
required_ca_ht = target_net / (1 - social_contribution_rate - vfl_income_tax_rate)
```

Formule avec reserve prudente incluant CFP :

```text
required_ca_ht = target_net / (1 - social_contribution_rate - vfl_income_tax_rate - cfp_rate)
```

Puis :

```text
required_vat = required_ca_ht * vat_rate
required_ttc = required_ca_ht + required_vat
```

Tests minimaux :

| Profil | Objectif | Options | Resultat attendu |
| --- | ---: | --- | ---: |
| Micro-BIC vente | 877,00 | hors IR | CAHT 1 000,00 |
| Micro-BIC prestation | 788,00 | hors IR | CAHT 1 000,00 |
| Micro-BNC general | 744,00 | hors IR | CAHT 1 000,00 |
| Micro-BNC general | 722,00 | VFL on | CAHT 1 000,00 |

## Formules du mode Marge

Entrees :

```text
purchase_amount
purchase_kind = ht | ttc
sale_amount
sale_kind = ht | ttc
vat_rate
vat_applicable = true | false
vat_deductible_on_purchase = true | false
```

Normalisation :

```text
purchase_ht = purchase_amount / (1 + vat_rate) if purchase_kind == ttc and vat_applicable else purchase_amount
sale_ht = sale_amount / (1 + vat_rate) if sale_kind == ttc and vat_applicable else sale_amount
```

Calculs :

```text
gross_margin_ht = sale_ht - purchase_ht
margin_rate = gross_margin_ht / purchase_ht
mark_rate = gross_margin_ht / sale_ht

vat_collected = sale_ht * vat_rate if vat_applicable else 0
vat_deductible = purchase_ht * vat_rate if vat_applicable and vat_deductible_on_purchase else 0
net_vat = vat_collected - vat_deductible
```

Libelles :

- "Marge brute HT"
- "Taux de marge"
- "Taux de marque"
- "TVA collectee"
- "TVA deductible"
- "TVA nette"

Tests minimaux :

| Cas | Entree | Resultat attendu |
| --- | --- | --- |
| Achat 60 HT, vente 100 HT | TVA 20 % | marge 40, taux de marge 66,67 %, taux de marque 40,00 %, TVA nette 8 |
| Achat 72 TTC, vente 120 TTC | TVA 20 % | achat HT 60, vente HT 100, marge 40, TVA nette 8 |
| Franchise en base | achat 60, vente 100 | TVA collectee 0, TVA deductible 0 |

## Architecture de donnees recommandee

Types metier :

```text
TaxRuleSet
  id
  country
  effectiveFrom
  checkedAt
  sources[]
  vatRates[]
  microProfiles[]
  vatFranchiseThresholds[]

MicroProfile
  id
  label
  socialContributionRate
  vflIncomeTaxRate
  cfpRate
  cfpRateRange
  incomeTaxAbatementRate
  microThreshold
  vatFranchiseBaseThreshold
  vatFranchiseMajorThreshold
  warnings[]

CalculationResult
  mainAmount
  mainLabel
  lines[]
  formula
  warnings[]
  sourceRuleSetId
```

Regle importante :

- Les constantes doivent etre codees dans un fichier versionne et teste.
- Le LLM peut lire ce document pour comprendre les regles, mais ne doit jamais produire le montant final en remplacant le moteur deterministe.

## Exclusions V1

Exclusions a afficher dans la documentation interne et a ne pas promettre dans l'App Store :

- ACRE et taux reduits de debut d'activite.
- CFE.
- IR progressif du foyer.
- Quotient familial et revenu fiscal de reference.
- Activites mixtes.
- Professions liberales Cipav, sauf profil dedie ulterieur.
- Avocats, auteurs, artistes-interpretes.
- Location meublee, meubles de tourisme classes ou non classes.
- Regimes agricoles, medical, presse, droits d'auteur, marge TVA speciale.
- DOM, Corse, operations internationales, import/export, intracommunautaire.
- TVA deductible partielle, prorata de deduction, regularisations.
- Salaries, SASU, EURL, dividendes, IS, PFU.
- Declaration officielle URSSAF, impots.gouv ou TVA.

## Wording UI recommande

Textes courts :

- "Estimation apres cotisations"
- "Hors impot sur le revenu"
- "TVA a mettre de cote"
- "CAHT retenu pour les cotisations"
- "Versement liberatoire active"
- "CFP annuelle indicative"
- "Baremes verifies le 14/05/2026"
- "Formule utilisee"
- "Franchise en base : TVA non facturee"

Wording de securite :

- "Ce resultat est une estimation."
- "Le calcul suppose que le montant est encaisse."
- "Les seuils peuvent dependre de votre situation exacte."
- "En franchise en base, la TVA n'est pas facturee et n'est pas deductible sur les achats."

## Points a verifier avant soumission App Store

Avant publication, refaire une passe de verification officielle sur :

1. taux micro-social BNC ;
2. seuils de franchise en base de TVA ;
3. seuils micro-fiscal 2026, 2027 et 2028 ;
4. taux du versement liberatoire ;
5. CFP micro-entrepreneur ;
6. formulation juridique de la page App Store.

Si une constante change, incrementer l'identifiant du `TaxRuleSet` et ajouter un test de regression.
