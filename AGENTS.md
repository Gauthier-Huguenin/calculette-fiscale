# Instructions pour Codex

## Communication

- Repondre en francais a l'utilisateur.
- Garder les identifiants, noms de fichiers, code et commentaires techniques en anglais lorsque c'est naturel.
- Eviter les em dash. Utiliser un point ou une virgule.

## Projet

- Ce depot est un monorepo.
- L'app iOS vit dans `apps/ios`.
- Les documents produit et fiscaux vivent dans `docs`.
- Les futures plateformes doivent rester separees : `apps/android`, `apps/macos`, `apps/web` ou `sites/www`.
- Le code partage eventuel devra vivre dans `packages`.

## iOS

- App native SwiftUI.
- Garder les vues petites et composees.
- Utiliser des calculs deterministes pour les montants fiscaux.
- Ne jamais confier un calcul fiscal final a un LLM.
- Les constantes fiscales doivent etre versionnees, testees et sourcees dans `docs/fiscal-rules-research-2026.md`.

## Documentation

- Apres tout changement structurel, verifier si `README.md` ou ce fichier doivent etre mis a jour.
- Si un taux, seuil ou bareme fiscal change, mettre a jour la documentation et ajouter un test de regression.
