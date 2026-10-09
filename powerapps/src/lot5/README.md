# Lot 5 — Écran d'inspection allégé et export

## Contenu

| Fichier | Où | Remplace |
|------|------|------|
| `06-Screen_Inspection.pa.yaml` | Arborescence | Screen_Inspection (lot 4.1) |
| `07-btnInspEvaluer.OnSelect.fx` | (inclus dans l'écran) | référence du moteur (ajout du numéro de question) |
| `01-Flux-LUWA_Export.md` | Power Automate (dans la solution) | — (nouveau flux PAU-01, DEC-30) |

## Écran d'inspection (5.0)

- En-tête : nom de l'ouvrage en grand + étiquette Poteau / Luminaire ; statut, date et identifiant retirés.
- Pastille unique en haut à droite : « 3 questions · 1 photo à compléter › » (orange, amène à la prochaine question)
  ou « ✓ Tout est complété » (vert).
- Barre de progression fine sous l'en-tête (questions requises complètes / questions requises).
- Questions numérotées ; bandeaux de groupe supprimés ; plus d'astérisque, « (facultatif) » sur les questions non requises ;
  ✓ vert devant chaque question complète.
- Icône 📷 orange tant que les photos minimales manquent.
- Bas d'écran : « ← Accueil » (gauche), « Enregistrer (n) » / « Enregistré ✓ » (centre), « Valider l'inspection › » vert (droite) ;
  légende supprimée ; « ⚠ Hors connexion » affiché seulement sans réseau.

Étapes : supprimer **Screen_Inspection**, coller `06-Screen_Inspection.pa.yaml` (caméra à réinsérer si refusée) ;
**Run OnStart** (pour reconstruire la liste avec les numéros) ; 0 erreur ; Save ; Publish. OnStart inchangé.

## Récapitulatif (5.0)

`09-Screen_Resume.pa.yaml` : les questions du récapitulatif (et du rapport PDF) portent le même numéro que dans le formulaire.
Étapes : supprimer **Screen_Resume**, coller le fichier ; Save ; Publish.
