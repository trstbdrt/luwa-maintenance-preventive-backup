# Lot 2 — Questionnaire dynamique, moteur de règles, enregistrement, protection hors connexion

Prérequis : Lot 1 importé et validé. Plan général : `powerapps/canvas-app-build-plan.md` ; algorithme : technical design § 5.

## Contenu

| Fichier | Où le coller | Remplace |
|------|------|------|
| `02-App.OnStart.fx` | App > **OnStart** | L'OnStart du lot 1 (ajoute les collections de saisie) |
| `03-App.ConfirmExit.fx` | App > **ConfirmExit** (1re ligne de formule) | — |
| `04-Screen_Home.pa.yaml` | Arborescence (écran) | Screen_Home du lot 1 (ajoute la récupération hors connexion) |
| `06-Screen_Inspection.pa.yaml` | Arborescence (écran) | Screen_Inspection provisoire du lot 1 |
| `08-tmrInspAutoSave.pa.yaml` | Sélectionner **Screen_Inspection** puis coller (contrôle) | — |
| `07-btnInspEvaluer.OnSelect.fx` | Screen_Inspection > btnInspEvaluer > **OnSelect** | Uniquement si l'écran a été collé avant la correction du moteur (voir plus bas) |

`App.Formulas`, Screen_Type, Screen_Identification et Screen_History ne changent pas.

## Étapes dans Studio

1. Supprimer **Screen_Home** et **Screen_Inspection** (… > Delete).
2. Coller `04-Screen_Home.pa.yaml` puis `06-Screen_Inspection.pa.yaml` (Ctrl+V dans l'arborescence).
3. Sélectionner **Screen_Inspection** puis coller `08-tmrInspAutoSave.pa.yaml`.
   Si le collage du minuteur échoue : Insert > Input > **Timer**, le renommer `tmrInspAutoSave`
   et recopier ses propriétés depuis le fichier (Duration, Repeat, AutoStart, Visible, OnTimerEnd).
4. App > **OnStart** : remplacer tout le contenu par `02-App.OnStart.fx`.
5. App > **ConfirmExit** : `!IsEmpty(Filter(colReponses, EtatSynchro <> "SYNCHRONISEE"))` ;
   App > **ConfirmExitMessage** : `"Des réponses ne sont pas encore enregistrées dans SharePoint. Quitter quand même ?"`.
6. App > StartScreen = `Screen_Home` (à vérifier) ; … > **Run OnStart**.
7. Vérificateur (stéthoscope) : 0 erreur de formule. Save.

## Fonctionnement

- **Questionnaire** : questions du formulaire triées par OrdreAffichage, en-tête de groupe (Général, Corrosion, Sur pont)
  à chaque changement de groupe, sous-questions en retrait, `*` sur les questions obligatoires.
- **Moteur de règles** (une seule formule sur le bouton technique masqué `btnInspEvaluer` ; Power Apps interdit les appels en boucle entre boutons) : calcul de la perte d'épaisseur, 3 passes d'évaluation des règles
  (visibilité, condition composée, masquage du formulaire), puis état final (obligatoire, commentaire obligatoire,
  photos minimales, calcul bloqué). Une condition sur une question masquée ou vide est fausse.
- **Enregistrement** : bouton « Enregistrer », automatique toutes les 60 s si des modifications sont en attente
  et que le réseau est disponible, et avant le retour à l'accueil. Création et mise à jour groupées dans REPONSES ;
  DateDerniereModification mise à jour ; BROUILLON → EN_COURS.
- **Protection hors connexion** : après chaque modification, l'inspection en cours est copiée sur l'appareil.
  Si l'application est fermée avant l'enregistrement, l'accueil propose « Reprendre et enregistrer ».
  Fonctionne dans l'**application mobile Power Apps** ; dans un navigateur, la copie locale peut ne pas être disponible.
- **Hors périmètre du lot 2** : photos, résumé et soumission (lot 3) ; création d'une inspection sans réseau (lot 2b).

## Tests du lot 2

Ouvrages de test : poteau `TEST 201`, luminaire `TEST 201-1`.

| # | Test | Attendu |
|------|------|------|
| T21 | Nouvelle > Poteau > `TEST 201` > Commencer | En-têtes Général / Corrosion / Général / Sur pont / Général ; 12 questions visibles ; `*` sur les obligatoires |
| T22 | POT_004 = AVANCEE | POT_004_1, POT_004_2_A, _2_B, _2_C apparaissent en retrait |
| T23 | POT_004_2_A = 6 ; POT_004_2_B = 4,5 ; POT_004_1 = OUI | « Perte calculée : 25 % » ; POT_004_5 apparaît ; pas de test marteau |
| T24 | POT_004_2_B = 4 | Perte 33,3 % ; POT_004_3 (test marteau) apparaît ; POT_004_5 disparaît |
| T25 | POT_004_2_A = 0 | « Calcul impossible… » en rouge ; POT_004_3 et POT_004_5 masquées |
| T26 | POT_004 = SEVERE, puis de nouveau AVANCEE | SEVERE : seule POT_004_4 dans Corrosion ; AVANCEE : les épaisseurs saisies réapparaissent (DEC-19) |
| T27 | POT_010B = OUI | POT_010B_A apparaît avec `*` |
| T28 | 💬 sur POT_001, saisir un commentaire, OK | Le commentaire s'affiche sous la question |
| T29 | Enregistrer | « ✔ Tout est enregistré » ; statut EN_COURS |
| T30 | Modifier POT_001, Enregistrer | Pas de doublon dans REPONSES (vérification SharePoint) |
| T31 | Modifier une réponse puis Accueil | Enregistrement automatique puis retour à l'accueil |
| T32 | Accueil > Reprendre > `TEST 201` | Toutes les réponses et commentaires sont rechargés |
| T33 | Nouvelle > Luminaire > `TEST 201-1` > LUM_001 = NON_PRESENT | Seule LUM_001 reste visible ; 💬 en rouge « Commentaire obligatoire » |
| T34 | Luminaire : cocher puis décocher LUM_002 | Valeur FAIT puis vide (vérification SharePoint après enregistrement) |
| T35 | Attendre 60 s après une modification sans enregistrer | Enregistrement automatique |
| T36 | (Tablette, application mobile) mode avion, répondre, fermer l'application, rouvrir avec réseau | Accueil : « Reprendre et enregistrer » ; les réponses sont retrouvées puis enregistrées |

## Correction du moteur (si l'écran a été collé avant)

La première version utilisait des boutons qui s'appelaient en boucle (`btnInspPasse`, `btnInspPasseSuite`), ce que Power Apps refuse
(« Select of this control results in a Select cycle that is not allowed »). Correction :

1. supprimer `btnInspPasse`, `btnInspPasseSuite` et `btnInspFinaliser` ;
2. coller `07-btnInspEvaluer.OnSelect.fx` dans `btnInspEvaluer` > **OnSelect** (remplace la formule existante).
