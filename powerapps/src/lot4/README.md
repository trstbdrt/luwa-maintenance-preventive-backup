# Lot 4 — Clé d'ouvrage et dossiers par ouvrage (DEC-29)

Prérequis : lot 3 (mise à jour 3.3) importé. SharePoint déjà préparé (colonnes `CleOuvrage`, `CheminDossier`,
`RapportHTML`, `RapportCSV` dans INSPECTIONS ; clés remplies pour les inspections existantes ; lien « Dossiers ouvrages »
dans le menu ; vue REPONSES « Par inspection »).

## Contenu

| Fichier | Où | Remplace |
|------|------|------|
| `01-Flux-PAU06-modification.md` | Power Automate, flux `LUWA_EnvoyerPhoto` | chemin de dépôt des photos |
| `02-Flux-LUWA_ClasserInspection.md` | Power Automate (dans la solution) | — (nouveau flux PAU-07) |
| `02-App.OnStart.fx` | App > **OnStart** | OnStart du lot 3 (ajoute gblCleOuvrage) |
| `05-Screen_Identification.pa.yaml` | Arborescence | Screen_Identification (clé d'ouvrage, rapport d'inaccessibilité) |
| `07-Screen_History.pa.yaml` | Arborescence | Screen_History (recherche par clé) |
| `09-Screen_Resume.pa.yaml` | Arborescence | Screen_Resume (rapport HTML + CSV à la soumission) |

Screen_Home et Screen_Inspection : inchangés (lot 3).

## Étapes

1. Studio : **Data** > INSPECTIONS > … > **Refresh** (nouvelles colonnes).
2. App > **OnStart** : coller `02-App.OnStart.fx` ; **Run OnStart**.
3. Supprimer **Screen_Identification**, **Screen_History**, **Screen_Resume** ; coller les 3 fichiers yaml
   (renommer l'écran si Studio ajoute « _1 »).
4. Vérificateur : 0 erreur ; Save ; **Publish**.
5. Power Automate : modifier PAU-06 (`01-…`), créer PAU-07 (`02-…`).

## Tests

| # | Test | Attendu |
|------|------|------|
| K1 | Poteau : saisir `e900001`, Rechercher | Ouvrage affiché `E900 001` |
| K2 | Commencer, répondre, enregistrer, revenir ; Identification `E900 001` puis `e900 001` | « Reprendre mon inspection » dans les deux cas |
| K3 | Luminaire `e900001 - 1` | Affiché `E900 001-1` ; informations du poteau parent `E900 001` |
| K4 | Historique : rechercher `e900001` | Inspections de `E900 001` |
| K5 | Soumettre `E900 001` (avec photos) | Dans la minute : `Dossiers ouvrages/E900 001/<date> POTEAU <id>/` avec PDF, CSV et photos ; `CheminDossier` rempli |
| K6 | Soumettre le luminaire `E900 001-1` | Rangé dans `E900 001/E900 001-1/…` |
| K7 | Ouvrir le PDF dans SharePoint | Lisible : en-tête, questions par groupe, réponses en clair, commentaires, nombre de photos |
| K8 | Ouvrir le CSV dans Excel | Colonnes séparées, accents corrects |
| K9 | Historique de l'app sur `E900 001` après rangement | Photos toujours visibles |
| K10 | Inspection inaccessible sur `E900 002` | Dossier `E900 002/<date> POTEAU <id>/` avec PDF (motif) et CSV |
