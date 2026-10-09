# Lot 3 — Photos, résumé, soumission

Prérequis : lot 2 (mise à jour 2.2) importé et validé.

## Contenu

| Fichier | Où | Remplace |
|------|------|------|
| `01-Flux-LUWA_EnvoyerPhoto.md` | Power Automate (dans la solution) | — (nouveau flux PAU-06) |
| `02-App.OnStart.fx` | App > **OnStart** | OnStart du lot 2.1 (ajoute colPhotos) |
| `04-Screen_Home.pa.yaml` | Arborescence | Screen_Home (récupération locale des photos) |
| `06-Screen_Inspection.pa.yaml` | Arborescence | Screen_Inspection (photos, bouton Résumé) |
| `07-btnInspEvaluer.OnSelect.fx` | (déjà inclus dans l'écran) | Référence du moteur de règles |
| `09-Screen_Resume.pa.yaml` | Arborescence | — (nouvel écran) |

## Étapes

1. **Créer le flux** `LUWA_EnvoyerPhoto` : suivre `01-Flux-LUWA_EnvoyerPhoto.md`.
2. Dans Studio : panneau **Power Automate** (éclair) > **Add flow** > `LUWA_EnvoyerPhoto`.
3. **Data** > PHOTOS_INSPECTIONS > … > **Refresh**.
4. Supprimer **Screen_Home** et **Screen_Inspection** ; coller `04-Screen_Home.pa.yaml`, `06-Screen_Inspection.pa.yaml`
   et `09-Screen_Resume.pa.yaml`.
   Si le contrôle **Camera** est refusé au collage : supprimer `camInspPhoto` du fichier, coller, puis
   Insert > Media > **Camera** dans `conInspPhotos`, le renommer `camInspPhoto` et recopier ses propriétés
   (Camera, X, Y, Width, Height, OnSelect) depuis le fichier.
5. App > **OnStart** : remplacer par `02-App.OnStart.fx` ; … > **Run OnStart**.
6. App > **ConfirmExit** :
   `!IsEmpty(Filter(colReponses, EtatSynchro <> "SYNCHRONISEE")) || !IsEmpty(Filter(colPhotos, EtatSynchro = "EN_ATTENTE"))`
7. Vérificateur : 0 erreur de formule ; Save ; **Publish** (nécessaire pour tester l'appareil photo sur tablette).

## Fonctionnement

- **Photos** : icône 📷 sur chaque question autorisant les photos ; compteur `n/min ✅` ; panneau avec la caméra
  (toucher l'image pour photographier, bouton « Changer de caméra »), miniatures, suppression possible tant que la photo
  n'est pas envoyée. Question PHOTO : réponse `PHOTO_CAPTURED` à la première photo (DEC-10).
  Envoi par le flux à l'enregistrement du brouillon, avant les réponses ; une photo en échec reste « À envoyer ».
- **Résumé** : questions obligatoires sans réponse, photos manquantes, commentaires obligatoires manquants, blocages
  (ex. épaisseur = 0) ; un clic renvoie au formulaire avec la question surlignée.
- **Soumission** : uniquement si le résumé est vide, tout est enregistré et le réseau disponible ;
  statut TERMINE, DateSoumission ; copie locale vidée ; retour à l'accueil. L'inspection n'est plus modifiable
  (consultation en lecture seule dans l'historique).

## Tests

Poteau `TEST 301`, luminaire `TEST 301-1`. Tablette avec l'application mobile Power Apps pour la caméra.

| # | Test | Attendu |
|------|------|------|
| P1 | POT_001 : 📷, prendre 1 photo, Fermer | Compteur `1/1 ✅` ; miniature « À envoyer » |
| P2 | POT_010 : 2 photos | `2/2 ✅` ; réponse PHOTO_CAPTURED |
| P3 | POT_002 = Fait | Compteur `0/2` en rouge (R202) |
| P4 | Supprimer une photo non envoyée (poubelle) | Disparaît ; compteur mis à jour |
| P5 | Enregistrer le brouillon | Photos « Envoyée » ; fichiers dans `PHOTOS_INSPECTIONS/<GUID>/` avec métadonnées (vérification SharePoint) |
| P6 | Résumé avec questions manquantes | Liste des anomalies ; clic → retour à la question surlignée |
| P7 | POT_004_2_A = 0 | Résumé : « Blocage » ; Soumettre désactivé |
| P8 | Tout compléter, Résumé | « ✔ Le formulaire est complet » ; Soumettre actif |
| P9 | Soumettre | Accueil ; TEST 301 n'est plus dans « Reprendre » ; Identification : « ℹ Déjà inspecté : soumise le … » |
| P10 | Historique > TEST 301 | Réponses en libellés, photos visibles, lecture seule |
| P11 | Luminaire `TEST 301-1` : LUM_001 = Non présent + commentaire, Résumé, Soumettre | Soumission possible avec la seule question LUM_001 |
| P12 | Inaccessible avec photo : à faire au lot suivant (panneau SYS_001) | — |

## Mise à jour 3.1 (retours de test du lot 3)

- Bouton **« Valider l'inspection »** grisé tant qu'il reste une question, une photo, un commentaire obligatoire ou un blocage.
- Compteur de l'en-tête **cliquable** : amène à la prochaine question à compléter (surlignée) ; blocages inclus.
- Raison du blocage affichée sur la question (épaisseur sans corrosion = 0).
- Écran **Récapitulatif** (Screen_Resume) : questions affichées, réponse en libellé, commentaire, photos ; toucher une ligne rouvre
  le formulaire sur la question ; « Soumettre l'inspection ».
- Photos : bouton **« Terminé (n photo(s)) »** qui envoie aussitôt les photos prises ; confirmation « Photo n ajoutée » ;
  extension `.png` (la caméra Power Apps produit du PNG).

Étapes : supprimer **Screen_Inspection** et **Screen_Resume**, coller `06-Screen_Inspection.pa.yaml` et `09-Screen_Resume.pa.yaml`, Save, Publish.

## Mise à jour 3.2 (retours de test 3.1)

- **V5** : au retour du récapitulatif (« Modifier »), les réponses et photos en mémoire sont conservées (plus de rechargement
  si c'est la même inspection, variable `gblInspectionChargee`) ; lors d'un vrai chargement, `Refresh` de REPONSES et
  PHOTOS_INSPECTIONS avant lecture.
- En-tête : le texte « Reste … » n'est plus cliquable ; un **bouton** « Aller à la prochaine question à compléter › » le remplace.
- Panneau photos : **« Terminé »** grisé tant que le nombre minimum de photos de la question n'est pas atteint ;
  bouton **« Plus tard »** pour fermer sans valider (la question reste à compléter).

Étapes : App > OnStart (ajout `Set(gblInspectionChargee, "")`) puis Run OnStart ; supprimer **Screen_Inspection**,
coller `06-Screen_Inspection.pa.yaml` ; Save, Publish.
