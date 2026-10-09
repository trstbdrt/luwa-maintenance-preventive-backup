# Lot 6a — File d'envoi sur la tablette (hors connexion, partie 1)

Prérequis : lot 5 importé. Décision : DEC-31.

## Contenu

| Fichier | Où | Remplace |
|------|------|------|
| `02-App.OnStart.fx` | App > OnStart | OnStart lot 5 (ajoute la file `colFile`) |
| `04-Screen_Home.pa.yaml` | Arborescence | Screen_Home |
| `06-Screen_Inspection.pa.yaml` | Arborescence | Screen_Inspection |
| `09-Screen_Resume.pa.yaml` | Arborescence | Screen_Resume |
| `10-Screen_Envois.pa.yaml` | Arborescence | — (nouvel écran) |

Ordre : OnStart + **Run OnStart** d'abord (les écrans utilisent `colFile`), puis les écrans ; caméra à réinsérer si refusée ;
0 erreur ; Save ; Publish.

## Fonctionnement

- **File d'envoi** (`colFile`, sauvegardée sous `luwa_file`) : une ligne par inspection gardée sur la tablette ;
  ses réponses et photos sont sauvegardées à part (`luwa_rep_<GUID>`, `luwa_pho_<GUID>`).
  États : BROUILLON (non soumise), A_ENVOYER (soumise), ENVOI, ERREUR, ENVOYEE (affichée le jour même).
- **Entrent dans la file** : « Accueil » hors connexion (brouillon) ; « Soumettre » hors connexion ou avec des modifications
  non enregistrées (soumise) ; une copie de travail non envoyée retrouvée à l'ouverture (app fermée en cours d'inspection).
- **Envoi automatique** (accueil et écran Envois) : une inspection à la fois, toutes les 3 s s'il reste des envois et qu'il y a
  du réseau (sinon vérification toutes les 20 s). Ordre : fiche (créée si absente) → photos → réponses (sans doublon après
  interruption) → statut (TERMINE pour une soumission, ce qui déclenche le rangement PAU-07 ; EN_COURS pour un brouillon).
  En cas d'échec : ERREUR + message, nouvel essai automatique.
- **Écran Envois** (pastille « ⇅ n à envoyer » / « ✓ Tout est envoyé » en haut de l'accueil) : état de chaque inspection,
  « Envoyer maintenant », compteur n / 20, « Envoyées aujourd'hui » repliable ; un brouillon se rouvre d'un appui.
- **Limites** : alerte à 15 inspections en attente ; à 20, les tuiles « Inspecter… » sont bloquées.
- Valider hors connexion : le récapitulatif s'ouvre directement ; la soumission part dans la file.

## Tests (mode avion sur la tablette, application publiée)

| # | Test | Attendu |
|---|---|---|
| Q1 | En ligne : commencer `TEST 601`, répondre, mode avion, « Accueil » | Message « gardée sur la tablette » ; pastille « ⇅ 1 à envoyer » ; Envois : « Brouillon : à terminer » |
| Q2 | Envois > toucher la ligne | L'inspection se rouvre avec les réponses ; elle quitte la file |
| Q3 | Terminer hors ligne, Valider, Soumettre | « soumise : elle partira dès le retour du réseau » ; Envois : « À envoyer » |
| Q4 | Couper le mode avion, rester sur l'accueil | En moins d'une minute : « ✓ Tout est envoyé » ; SharePoint : TERMINE, réponses, photos, dossier rangé (PAU-07) |
| Q5 | Fermer l'app de force pendant une inspection hors ligne, la rouvrir | La pastille indique 1 à envoyer (brouillon) ; envoi au retour du réseau |
| Q6 | Envois > « Envoyées aujourd'hui » | Les inspections envoyées, avec l'heure |
