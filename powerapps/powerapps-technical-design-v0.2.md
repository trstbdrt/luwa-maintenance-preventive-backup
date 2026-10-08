# LUWA Maintenance Preventive Backup
## Power Apps — Technical Design v0.2

Version : 0.2.0

Date : 2026-10-09

Statut : Conception technique pour implémentation

Public : développeur Power Apps (App 1 — inspection terrain)

Référentiel : tag `v0.1.7` et suivants.

Documents de référence (gelés) :

- `docs/specification/specification-fonctionnelle-v0.1.md`
- `docs/architecture/architecture-globale-v0.1.md`
- `sharepoint/data-model/sharepoint-schema.md`
- `sharepoint/questions/questions.csv`
- `sharepoint/regles/regles_formulaire.csv`

Documents complémentaires :

- `powerapps/screens.md` — description fonctionnelle des 6 écrans
- `docs/decisions/technical-decisions-v0.1.2.md` (DEC-01 à DEC-10), `-v0.1.3.md` (DEC-11, DEC-12), `-v0.1.5.md` (DEC-13 à DEC-17)
- `docs/build/powerapps-readiness.md`

Ce document ne contient **aucun Power Fx**. Les comportements sont décrits sous forme d'algorithmes
et de séquences. Il n'introduit aucune règle métier ni décision fonctionnelle : lorsque les documents
de référence ne tranchent pas un point nécessaire à l'implémentation, le point est signalé
dans la section 9 (« Points d'attention ») et n'est pas décidé ici.

---

# Sommaire

1. Architecture applicative
2. Variables globales
3. Variables d'écran
4. Collections
5. Moteur de règles
6. Gestion des photos
7. Gestion des brouillons et des statuts
8. Flux utilisateur complets
9. Points d'attention pour l'implémentation

---

# 1. Architecture applicative

## 1.1 Vue d'ensemble

| Élément | Choix |
|------|------|
| Type d'application | Application canevas |
| Sources de données | Listes SharePoint INSPECTIONS, QUESTIONS, REGLES_FORMULAIRE, REPONSES ; bibliothèque PHOTOS_INSPECTIONS |
| Site | `https://wavenetbe.sharepoint.com/sites/LuwaMaintenancePreventiveBackup` |
| Écrans | Screen_Home, Screen_Type, Screen_Identification, Screen_Inspection, Screen_Resume, Screen_History |
| Catalogues | Chargés une fois au démarrage en collections (`colQuestions`, `colRegles`) |
| Saisie | Travail en collections locales (`colReponses`, `colPhotos`), écriture SharePoint à l'enregistrement |
| Clé | InspectionGUID partout (DEC-03, DEC-11) ; InspectionID = affichage uniquement |
| Hors connexion | Non implémenté en v0.1 ; collections de travail conçues pour SaveData / LoadData |

## 1.2 Conventions

| Préfixe | Portée | Exemple |
|------|------|------|
| `gbl` | Variable globale (toute l'application) | `gblInspection` |
| `loc` | Variable de contexte (un écran) | `locAfficherPanneauPhotos` |
| `col` | Collection | `colReponses` |
| `Screen_` | Écran | `Screen_Inspection` |

Les noms de colonnes SharePoint sont utilisés **à l'identique** dans les collections
(QuestionCode, InspectionGUID, etc.) pour éviter toute table de correspondance.

## 1.3 Couches logiques

```
┌──────────────────────────────────────────────────────────────┐
│ Écrans (6)                                                   │
│   affichent colQuestionsFormulaire + colEtatQuestions        │
│   saisissent dans colReponses / colPhotos                    │
├──────────────────────────────────────────────────────────────┤
│ Moteur de règles (section 5)                                 │
│   entrée : colQuestionsFormulaire, colRegles, colReponses    │
│   sortie : colEtatQuestions, colAnomalies                    │
├──────────────────────────────────────────────────────────────┤
│ Persistance (sections 6 et 7)                                │
│   INSPECTIONS, REPONSES : connecteur SharePoint              │
│   PHOTOS_INSPECTIONS   : envoi de fichiers (voir 6.6)        │
└──────────────────────────────────────────────────────────────┘
```

## 1.4 Flux de navigation

```
                    ┌──────────────┐
          ┌────────►│ Screen_Home  │◄─────────────────────────────┐
          │         └──┬────┬────┬─┘                              │
          │  Nouvelle  │    │    │ Historique                     │
          │            ▼    │    ▼                                │
          │   ┌─────────────┐ │ ┌────────────────┐                │
          │   │ Screen_Type │ │ │ Screen_History │◄──────┐        │
          │   └──────┬──────┘ │ └────────────────┘       │        │
          │          ▼        │ Reprendre                │        │
          │ ┌───────────────────────┐   │                │        │
          │ │ Screen_Identification ├───┼── inspection ──┘        │
          │ └──┬─────────────┬──────┘   │   précédente           │
          │    │ Commencer   │ Inaccessible (validé) ─────────────┤
          │    ▼             │          ▼                         │
          │ ┌───────────────────────────────┐                     │
          │ │ Screen_Inspection             │── Accueil ──────────┤
          │ └──────────────┬────────────────┘                     │
          │       Résumé   ▼    ▲ Retour / clic anomalie          │
          │ ┌───────────────────┴───┐                             │
          └─┤ Screen_Resume         ├── Soumettre / Brouillon ────┘
            └───────────────────────┘
```

| Depuis | Action | Vers | Préparation |
|------|------|------|------|
| Screen_Home | Nouvelle inspection | Screen_Type | Réinitialiser le contexte d'inspection (2.3) |
| Screen_Home | Sélection d'une inspection à reprendre | Screen_Inspection | Charger l'inspection (7.4) |
| Screen_Home | Historique | Screen_History | `gblEcranRetourHistorique` = Screen_Home |
| Screen_Type | Poteau / Luminaire | Screen_Identification | `gblTypeInspection` |
| Screen_Type | Retour | Screen_Home | — |
| Screen_Identification | Commencer / Accessible maintenant | Screen_Inspection | Créer l'inspection (7.2) |
| Screen_Identification | Valider l'inaccessibilité | Screen_Home | Créer l'inspection INACCESSIBLE (7.6) |
| Screen_Identification | Clic sur une inspection précédente | Screen_History | `gblInspectionConsultee`, `gblEcranRetourHistorique` = Screen_Identification |
| Screen_Identification | Retour | Screen_Type | — |
| Screen_Inspection | Résumé | Screen_Resume | Évaluer les règles et les anomalies (5.6) |
| Screen_Inspection | Accueil | Screen_Home | Enregistrer (7.3) puis réinitialiser le contexte |
| Screen_Resume | Clic sur une anomalie | Screen_Inspection | Positionner la galerie sur la question |
| Screen_Resume | Retour à l'inspection | Screen_Inspection | — |
| Screen_Resume | Enregistrer comme brouillon | Screen_Home | Enregistrer (7.3) |
| Screen_Resume | Soumettre (succès) | Screen_Home | Soumettre (7.5) |
| Screen_History | Retour | `gblEcranRetourHistorique` | Vider les collections de consultation |

---

# 2. Variables globales

## 2.1 Tableau de référence

| Variable | Type | Valeur initiale | Source | Cycle de vie |
|------|------|------|------|------|
| `gblUtilisateur` | Enregistrement { Email, NomAffiche } | Utilisateur connecté | Profil de l'utilisateur Power Apps | Défini au démarrage de l'application ; jamais modifié |
| `gblTypeInspection` | Texte (POTEAU \| LUMINAIRE) | Vide | Screen_Type ; ou TypeInspection de l'inspection reprise | Défini sur Screen_Type ou à la reprise ; vidé à la réinitialisation du contexte |
| `gblNomOuvrage` | Texte | Vide | Saisie Screen_Identification ; ou NomOuvrage de l'inspection reprise | Défini à la recherche d'ouvrage ou à la reprise ; vidé à la réinitialisation |
| `gblInspectionGUID` | Texte (GUID) | Vide | Généré à la création de l'inspection (DEC-11) ; ou InspectionGUID de l'inspection reprise | Défini à la création ou à la reprise ; **jamais modifié** ensuite ; vidé à la réinitialisation |
| `gblInspectionID` | Texte | Vide | `TMP-{8 premiers caractères de gblInspectionGUID}` à la création (DEC-13) ; puis valeur lue dans SharePoint (`INS-…`, DEC-14) | Défini à la création ; rafraîchi après chaque enregistrement par relecture de l'élément INSPECTIONS ; vidé à la réinitialisation |
| `gblInspection` | Enregistrement INSPECTIONS | Vide | Élément retourné par SharePoint après création, enregistrement ou chargement | Remplacé après chaque écriture dans INSPECTIONS ; vidé à la réinitialisation |
| `gblInspectionConsultee` | Enregistrement INSPECTIONS | Vide | Élément sélectionné dans une galerie d'historique | Défini à l'ouverture de Screen_History sur une inspection ; vidé au retour |
| `gblEcranRetourHistorique` | Écran | Screen_Home | Écran appelant | Défini avant chaque navigation vers Screen_History |

## 2.2 Règles d'usage

- `gblInspectionGUID` est la **seule** valeur utilisée pour lire ou écrire REPONSES et PHOTOS_INSPECTIONS
  et pour nommer le dossier photos (DEC-15).
- `gblInspectionID` est utilisé **uniquement** pour l'affichage (en-têtes, galeries). Il peut valoir
  `TMP-…` tant que Power Automate n'a pas attribué la valeur finale (DEC-14).
- `gblInspection` reflète l'état SharePoint de l'inspection (statut, dates, ID SharePoint).

## 2.3 Réinitialisation du contexte d'inspection

Exécutée avant « Nouvelle inspection » et au retour à l'accueil depuis une inspection :

1. vider `gblTypeInspection`, `gblNomOuvrage`, `gblInspectionGUID`, `gblInspectionID`, `gblInspection` ;
2. vider `colQuestionsFormulaire`, `colReponses`, `colPhotos`, `colEtatQuestions`, `colAnomalies`,
   `colHistoriqueOuvrage`, `colPhotosInaccessible`.

`colQuestions`, `colRegles` et `gblUtilisateur` ne sont jamais réinitialisés.

---

# 3. Variables d'écran

| Écran | Variable | Type | Valeur initiale | Usage |
|------|------|------|------|------|
| Screen_Home | `locAfficherReprise` | Booléen | Faux | Affiche la galerie des inspections à reprendre |
| Screen_Identification | `locDerniereInspection` | Enregistrement INSPECTIONS | Vide | Dernière inspection connue de l'ouvrage (bandeau, bouton « Accessible maintenant ») |
| Screen_Identification | `locInspectionEnCoursExiste` | Booléen | Faux | Avertissement de concurrence (DEC-08) |
| Screen_Identification | `locAfficherPanneauInaccessible` | Booléen | Faux | Affiche le panneau « Ouvrage inaccessible » |
| Screen_Identification | `locCommentaireInaccessible` | Texte | Vide | Commentaire SYS_001 |
| Screen_Inspection | `locQuestionActive` | Texte (QuestionCode) | Vide | Question dont le panneau commentaire ou photos est ouvert |
| Screen_Inspection | `locAfficherPanneauCommentaire` | Booléen | Faux | Panneau commentaire |
| Screen_Inspection | `locAfficherPanneauPhotos` | Booléen | Faux | Panneau photos |
| Screen_Inspection | `locModificationsNonEnregistrees` | Booléen | Faux | Vrai dès qu'une réponse, un commentaire ou une photo change ; remis à Faux après enregistrement |
| Screen_Inspection | `locInspectionEnCoursExiste` | Booléen | Faux | Rappel de l'avertissement de concurrence |
| Screen_Resume | `locSoumissionPossible` | Booléen | Faux | Vrai si `colAnomalies` est vide |
| Screen_History | `locRechercheOuvrage` | Texte | Vide | Nom d'ouvrage recherché |

---

# 4. Collections

Tailles attendues calculées sur les catalogues v0.1 (34 questions, 29 règles) et sur la volumétrie
de l'architecture (30 000 inspections, environ 15 réponses par inspection).

## 4.1 colQuestions

| Élément | Description |
|------|------|
| Structure | Colonnes de la liste QUESTIONS : QuestionCode, QuestionParent, DisplayGroup, Formulaire, OrdreAffichage, Libelle, TypeQuestion, Obligatoire, CommentaireAutorise, CommentaireObligatoire, PhotoAutorisee, NbPhotosMin, NbPhotosMax, VisibleParDefaut, ValeursPossibles, FormuleCalcul |
| Chargement | Au démarrage de l'application : lecture complète de QUESTIONS |
| Rafraîchissement | Aucun pendant la session (catalogue en lecture seule pour les techniciens) |
| Taille attendue | 34 lignes |

## 4.2 colRegles

| Élément | Description |
|------|------|
| Structure | Colonnes de REGLES_FORMULAIRE : RuleID, Priorite, Formulaire, QuestionSource, ConditionType, ConditionValeur, Action, QuestionCible, Parametre, Commentaire |
| Chargement | Au démarrage : lecture de REGLES_FORMULAIRE filtrée sur Actif = Oui, triée par Priorite croissante |
| Rafraîchissement | Aucun pendant la session |
| Taille attendue | 29 lignes |

## 4.3 colInspectionsAReprendre

| Élément | Description |
|------|------|
| Structure | InspectionGUID, InspectionID, TypeInspection, NomOuvrage, StatutInspection, DateDerniereModification |
| Chargement | Clic sur « Reprendre inspection » : INSPECTIONS filtrée sur StatutInspection ∈ {BROUILLON, EN_COURS} et Inspecteur = utilisateur courant (DEC-09), triée par DateDerniereModification décroissante |
| Rafraîchissement | À chaque affichage de la galerie de reprise |
| Taille attendue | Quelques dizaines par technicien |

## 4.4 colHistoriqueOuvrage

| Élément | Description |
|------|------|
| Structure | InspectionGUID, InspectionID, TypeInspection, NomOuvrage, Inspecteur, StatutInspection, DateCreation, DateDerniereModification, DateSoumission |
| Chargement | Screen_Identification, bouton « Rechercher » : INSPECTIONS filtrée sur NomOuvrage = `gblNomOuvrage` (colonne indexée), tous statuts, triée par DateCreation décroissante |
| Rafraîchissement | À chaque recherche d'ouvrage |
| Taille attendue | Quelques lignes par ouvrage (une à deux inspections par campagne et par type) |
| Dérivés | `locDerniereInspection` = première ligne ; `locInspectionEnCoursExiste` = existe une ligne de même TypeInspection que `gblTypeInspection` au statut BROUILLON ou EN_COURS (DEC-08) |

## 4.5 colHistorique

| Élément | Description |
|------|------|
| Structure | Identique à `colHistoriqueOuvrage` |
| Chargement | Screen_History ouvert depuis l'accueil : recherche par NomOuvrage = `locRechercheOuvrage` (indexé), tous statuts y compris ARCHIVE |
| Rafraîchissement | À chaque recherche |
| Taille attendue | Quelques lignes par ouvrage |

## 4.6 colQuestionsFormulaire

| Élément | Description |
|------|------|
| Structure | Colonnes de `colQuestions` |
| Chargement | À l'entrée dans Screen_Inspection : `colQuestions` filtrée sur Formulaire = `gblTypeInspection`, triée par OrdreAffichage |
| Rafraîchissement | Aucun pendant l'inspection |
| Taille attendue | POTEAU : 20 lignes ; LUMINAIRE : 13 lignes |

## 4.7 colReponses

| Élément | Description |
|------|------|
| Structure | ReponseID (GUID), InspectionGUID, QuestionCode, Valeur, ValeurNumerique, Commentaire, DateEncodage, SharePointID (vide tant que la réponse n'est pas créée dans SharePoint), EtatSynchro (NOUVELLE \| MODIFIEE \| SYNCHRONISEE) |
| Chargement | Création d'inspection : vide. Reprise : REPONSES filtrée sur InspectionGUID = `gblInspectionGUID` (indexée), EtatSynchro = SYNCHRONISEE |
| Rafraîchissement | Modifiée à chaque saisie (réponse, commentaire, calcul, PHOTO_CAPTURED) ; EtatSynchro remis à SYNCHRONISEE après écriture SharePoint |
| Taille attendue | Au plus une ligne par question du formulaire : ≤ 20 (POTEAU), ≤ 13 (LUMINAIRE) |
| Règle | Unicité InspectionGUID + QuestionCode : une saisie met à jour la ligne existante ou en crée une |

Colonnes de valeur selon TypeQuestion (schéma, DEC-10) :

| TypeQuestion | Valeur | ValeurNumerique |
|------|------|------|
| RADIO, CHECKBOX | Valeur de ValeursPossibles | Vide |
| TEXTE | Texte saisi | Vide |
| NUMERIQUE, CALCUL | Vide | Nombre |
| PHOTO | PHOTO_CAPTURED | Vide |
| SYSTEM (SYS_001) | Vide | Vide |

## 4.8 colPhotos

| Élément | Description |
|------|------|
| Structure | PhotoLocaleID (identifiant local unique), InspectionGUID, QuestionCode, NomFichier, Image (contenu de l'image), DatePhoto, Auteur (e-mail), NomOuvrage, CompressionVersion (ORIGINAL \| COMPRESSEE), EtatSynchro (EN_ATTENTE \| ENVOYEE), UrlSharePoint (vide tant que non envoyée) |
| Chargement | Création : vide. Reprise : métadonnées des fichiers de PHOTOS_INSPECTIONS filtrés sur InspectionGUID = `gblInspectionGUID` (indexée), EtatSynchro = ENVOYEE, Image = vignette ou URL du fichier |
| Rafraîchissement | Ajout à chaque capture ou import ; EtatSynchro passe à ENVOYEE après envoi |
| Taille attendue | En pratique moins de 15 photos par inspection ; maximum théorique NbPhotosMax (10) × questions autorisant les photos |

## 4.9 colEtatQuestions

| Élément | Description |
|------|------|
| Structure | QuestionCode, Visible (booléen), Obligatoire (booléen), CommentaireObligatoire (booléen), PhotosMin (nombre), PhotosMax (nombre), CalculBloque (booléen), NbPhotos (nombre), Repondue (booléen) |
| Chargement | Calculée par le moteur de règles (section 5) à l'entrée dans Screen_Inspection |
| Rafraîchissement | Recalculée intégralement après chaque modification de réponse, de commentaire ou de photo |
| Taille attendue | Une ligne par question du formulaire : 20 ou 13 |

Indicateurs globaux produits en même temps (variables ou ligne de synthèse) :
`SoumissionBloquee` (booléen) et `ReglesBloquantes` (liste de RuleID ayant déclenché BLOQUER_SOUMISSION).

## 4.10 colAnomalies

| Élément | Description |
|------|------|
| Structure | TypeAnomalie (QUESTION_OBLIGATOIRE \| PHOTO_MANQUANTE \| QUESTION_CONDITIONNELLE \| COMMENTAIRE_OBLIGATOIRE \| BLOCAGE), QuestionCode, Libelle, Detail, RuleID |
| Chargement | Calculée à l'entrée dans Screen_Resume (section 5.6) |
| Rafraîchissement | À chaque affichage de Screen_Resume |
| Taille attendue | 0 (formulaire valide) à environ 20 |

## 4.11 Collections de consultation et d'inaccessibilité

| Collection | Structure | Chargement | Taille |
|------|------|------|------|
| `colReponsesConsultees` | Comme `colReponses` (sans EtatSynchro) | Screen_History : REPONSES filtrée sur l'InspectionGUID consulté | ≤ 20 |
| `colPhotosConsultees` | Comme `colPhotos` (sans EtatSynchro) | Screen_History : PHOTOS_INSPECTIONS filtrée sur l'InspectionGUID consulté | < 15 en pratique |
| `colPhotosInaccessible` | Comme `colPhotos`, QuestionCode = SYS_001 | Panneau « Ouvrage inaccessible » | 0 à 10 |

---

# 5. Moteur de règles

## 5.1 Principe

Le moteur transforme trois entrées en deux sorties, sans aucune règle codée en dur :

| Entrées | Sorties |
|------|------|
| `colQuestionsFormulaire` (catalogue du formulaire) | `colEtatQuestions` (état de chaque question) |
| `colRegles` (règles actives, triées par Priorite) | `colAnomalies` (à la demande, Screen_Resume) |
| `colReponses`, `colPhotos` (saisie en cours) | |

Seules les règles dont Formulaire = `gblTypeInspection` ou Formulaire = ALL sont considérées
dans Screen_Inspection. Les règles Formulaire = SYSTEM (R700, R701) ne concernent que le panneau
« Ouvrage inaccessible » (section 7.6).

## 5.2 Chargement

1. Au démarrage, lire REGLES_FORMULAIRE filtrée sur Actif = Oui, triée par Priorite croissante → `colRegles`.
2. À l'entrée dans Screen_Inspection, construire `colQuestionsFormulaire` (4.6).
3. Calculer l'état initial (5.3) avec les réponses existantes (vides pour une nouvelle inspection).

## 5.3 Évaluation de l'état des questions

Algorithme exécuté après chaque modification de réponse, de commentaire ou de photo :

**Étape 1 — État de base.** Pour chaque question Q du formulaire :

- Visible = Q.VisibleParDefaut
- Obligatoire = Q.Obligatoire
- CommentaireObligatoire = Q.CommentaireObligatoire
- PhotosMin = Q.NbPhotosMin ; PhotosMax = Q.NbPhotosMax
- CalculBloque = Faux
- NbPhotos = nombre de photos de Q dans `colPhotos`
- Repondue = selon 5.5

SoumissionBloquee = Faux.

**Étape 2 — Calcul.** Pour chaque question de type CALCUL non bloquée, calculer sa valeur à partir de
FormuleCalcul en remplaçant chaque QuestionCode par la ValeurNumerique correspondante
(ex. POT_004_2_C = ((POT_004_2_A − POT_004_2_B) / POT_004_2_A) × 100). Si une opérande est vide,
le résultat est vide. Le résultat est écrit dans `colReponses` (ValeurNumerique).

**Étape 3 — Application des règles.** Parcourir `colRegles` par Priorite croissante.
Pour chaque règle R dont l'Action est une action d'écran (5.4) :

1. Évaluer la condition de R (5.4).
2. Si la condition est vraie, appliquer l'action de R sur sa cible.

**Étape 4 — Stabilisation.** Si l'étape 3 a modifié la visibilité d'au moins une question, recommencer
les étapes 2 et 3 à partir de l'état de base, jusqu'à ce que la visibilité ne change plus
(au plus autant d'itérations que de règles). Avec le catalogue v0.1, une seule passe suffit
car chaque règle n'utilise que des questions rendues visibles par des règles de priorité inférieure
(R100–R103 → R120, R130, R131, R150 → R140) ; la stabilisation protège les évolutions futures du catalogue.

**Étape 5 — Neutralisation des questions masquées.** Pour chaque question non visible :
Obligatoire = Faux, CommentaireObligatoire = Faux, PhotosMin = 0
(« une question masquée n'est ni obligatoire, ni contrôlée à la soumission »).

## 5.4 Conditions et actions

### Évaluation d'une condition

Règle générale : **une condition portant sur une question non visible ou non renseignée est fausse.**
Cette règle reprend l'exigence de R150 / R151 (« uniquement si POT_004_2_A visible et renseignée,
vide différent de 0 ») et s'applique à toutes les conditions de comparaison.

| ConditionType | Condition vraie si |
|------|------|
| EQUALS | La question source est visible et renseignée, et sa valeur est égale à ConditionValeur. Pour une question NUMERIQUE ou CALCUL, comparaison numérique de ValeurNumerique (ex. R150 : POT_004_2_A = 0) ; sinon comparaison de Valeur |
| GREATER_OR_EQUAL | La source est visible et renseignée, et ValeurNumerique ≥ ConditionValeur (ex. R120 : perte ≥ 30) |
| LESS_THAN | La source est visible et renseignée, et ValeurNumerique < ConditionValeur (ex. R131 : perte < 30) |
| VISIBLE | La question source est visible (ConditionValeur = TRUE ; ex. R140) |
| VALIDATION, SAVE | Règles de contrôle global : non évaluées à l'étape 3 (voir 5.6 et 7.3) |
| PRESENCE | Règles du panneau d'inaccessibilité : non évaluées à l'étape 3 (voir 7.6) |

### Application d'une action

| Action | Effet sur `colEtatQuestions` |
|------|------|
| AFFICHER | Cible.Visible = Vrai |
| WAITING_SECOND_CONDITION | Mémorise le résultat de la condition (vrai / faux) pour la cible ; aucun effet seul |
| AFFICHER_IF_MATCH | Cible.Visible = Vrai si la condition de cette règle **et** la condition mémorisée par la règle WAITING_SECOND_CONDITION de même cible sont vraies (R130 + R131 → POT_004_5) |
| MASQUER_FORMULAIRE | Toutes les questions du formulaire **sauf la question source** passent à Visible = Faux (R002 : seule LUM_001 reste visible) ; appliquée en dernier pour la visibilité |
| RENDRE_OBLIGATOIRE | Cible.Obligatoire = Vrai (R401) |
| COMMENT_OBLIGATOIRE | Cible.CommentaireObligatoire = Vrai (R001) |
| PHOTO_MIN | Cible.PhotosMin = Parametre, **en remplacement** de NbPhotosMin (DEC-06) |
| BLOQUER_CALCUL | Cible.CalculBloque = Vrai ; la valeur calculée de la cible est vidée (R150) |
| BLOQUER_SOUMISSION | SoumissionBloquee = Vrai ; RuleID ajouté à ReglesBloquantes (R151) |
| VERIFIER, AUTORISER, OBLIGATOIRE | Sans effet à l'étape 3 (règles de contrôle global ou du panneau SYS_001) |

Remarque sur l'ordre : la règle BLOQUER_CALCUL (R150, priorité 150) intervient après les règles
qui lisent la valeur calculée (R120, R131). Lorsque R150 est vraie, la valeur de POT_004_2_C est vidée ;
à la passe de stabilisation suivante (étape 4), R120 et R131 deviennent fausses car leur source n'est plus renseignée.
L'étape 2 ne calcule pas une question dont CalculBloque était vrai à la passe précédente.

## 5.5 Question « répondue »

| TypeQuestion | Repondue si |
|------|------|
| RADIO, CHECKBOX, TEXTE | Valeur non vide |
| NUMERIQUE, CALCUL | ValeurNumerique renseignée |
| PHOTO | NbPhotos ≥ 1 (ligne PHOTO_CAPTURED présente, DEC-10) |

## 5.6 Contrôles de soumission (Screen_Resume)

Exécutés à l'entrée dans Screen_Resume, après une évaluation complète (5.3).
Chaque contrôle alimente `colAnomalies` :

| Règle | Contrôle | Anomalie |
|------|------|------|
| R500 — QUESTIONS_OBLIGATOIRES | Pour chaque question Visible et Obligatoire : Repondue | QUESTION_OBLIGATOIRE |
| R501 — PHOTOS_OBLIGATOIRES | Pour chaque question Visible : NbPhotos ≥ PhotosMin | PHOTO_MANQUANTE (détail « n/min ») |
| R502 — QUESTIONS_CONDITIONNELLES | Pour chaque question rendue visible par une règle (VisibleParDefaut = NON et Visible) : Repondue | QUESTION_CONDITIONNELLE |
| Commentaires (catalogue, COMMENT_OBLIGATOIRE) | Pour chaque question Visible et CommentaireObligatoire : Commentaire non vide | COMMENTAIRE_OBLIGATOIRE |
| BLOQUER_SOUMISSION (R151) | SoumissionBloquee | BLOCAGE (une ligne par RuleID de ReglesBloquantes, avec le Commentaire de la règle) |
| R503 — ECHEC_VALIDATION | `colAnomalies` non vide | Soumission impossible : `locSoumissionPossible` = Faux |

Interprétation de R502 : « toutes les questions affichées » s'entend des questions affichées
par une règle (ConditionValeur = QUESTIONS_CONDITIONNELLES). Les questions facultatives visibles
par défaut (LUM_012, LUM_013, POT_011) restent facultatives, conformément à la spécification § 12.
Avec le catalogue v0.1, toutes les questions VisibleParDefaut = NON sont Obligatoire = OUI :
R502 ne produit donc pas d'anomalie supplémentaire par rapport à R500.

R600 (SAVE / DRAFT / AUTORISER) : l'enregistrement n'est jamais soumis aux contrôles (7.3).

## 5.7 Résumé des impacts

| Impact | Sources | Règles v0.1 |
|------|------|------|
| Visibilité | VisibleParDefaut ; AFFICHER ; condition composée ; MASQUER_FORMULAIRE | R002, R100–R103, R110, R120, R130 + R131, R400 |
| Caractère obligatoire | Obligatoire ; RENDRE_OBLIGATOIRE ; neutralisation des questions masquées | R401 |
| Commentaire obligatoire | CommentaireObligatoire ; COMMENT_OBLIGATOIRE | R001 |
| Photo minimum | NbPhotosMin ; PHOTO_MIN (remplacement, DEC-06) | R140, R200–R202, R300–R303 |
| Calcul | FormuleCalcul ; BLOQUER_CALCUL | R150 |
| Blocage soumission | BLOQUER_SOUMISSION ; contrôles R500–R503 | R151, R500–R503 |

---

# 6. Gestion des photos

## 6.1 Capture

1. L'utilisateur touche l'icône 📷 d'une question dont PhotoAutorisee = OUI : `locQuestionActive` = QuestionCode,
   `locAfficherPanneauPhotos` = Vrai.
2. Le panneau affiche les photos de la question (`colPhotos` filtrée sur QuestionCode) et le compteur
   « NbPhotos/PhotosMin » (✅ lorsque NbPhotos ≥ PhotosMin).
3. Si NbPhotos < PhotosMax, l'utilisateur peut prendre une photo avec l'appareil photo.
4. La photo est ajoutée à `colPhotos` (6.3) ; `locModificationsNonEnregistrees` = Vrai ; le moteur de règles est réévalué.

## 6.2 Import depuis la galerie

Même séquence que 6.1, l'image provenant de la galerie de l'appareil au lieu de l'appareil photo.
DatePhoto = date et heure de l'import.

## 6.3 Métadonnées

| Métadonnée | Valeur |
|------|------|
| InspectionGUID | `gblInspectionGUID` |
| QuestionCode | `locQuestionActive` (SYS_001 dans le panneau d'inaccessibilité) |
| NomOuvrage | `gblNomOuvrage` |
| Auteur | `gblUtilisateur` |
| DatePhoto | Date et heure de capture ou d'import |
| CompressionVersion | ORIGINAL en l'absence de compression (OQ-06 ouverte, PA-17) ; COMPRESSEE si la photo a été compressée |
| NomFichier | `PhotoNNN.jpg`, NNN = numéro séquentiel sur 3 chiffres dans l'inspection (nombre de photos de l'inspection + 1) |

## 6.4 Stockage temporaire

- Les photos capturées ou importées sont conservées dans `colPhotos` avec EtatSynchro = EN_ATTENTE.
- Elles sont envoyées à SharePoint lors de l'enregistrement (7.3) ou de la soumission (7.5).
- `colPhotos` est conçue pour être sauvegardée localement (SaveData) dans une version ultérieure ;
  en v0.1, une photo non enregistrée est perdue si l'application est fermée
  (`locModificationsNonEnregistrees` permet d'avertir l'utilisateur).

## 6.5 Stockage SharePoint

| Élément | Valeur |
|------|------|
| Bibliothèque | PHOTOS_INSPECTIONS |
| Dossier | `{InspectionGUID}` à la racine de la bibliothèque (DEC-15), créé s'il n'existe pas |
| Fichier | `NomFichier` |
| Métadonnées | InspectionGUID, QuestionCode, NomOuvrage, Auteur, DatePhoto, CompressionVersion |
| Renommage | Jamais, y compris à l'attribution de l'InspectionID final |

## 6.6 Mécanisme d'envoi

Le connecteur SharePoint de Power Apps permet de lire les métadonnées d'une bibliothèque,
mais ne permet pas, de manière standard, de créer un fichier dans une bibliothèque de documents.
L'envoi d'une photo passe donc par un **flux Power Automate appelé depuis l'application**,
qui reçoit le contenu de l'image et ses métadonnées, crée le dossier `{InspectionGUID}` si nécessaire,
crée le fichier et renseigne les métadonnées.

Ce flux est l'élément de backlog **PAU-06** (non construit dans ce sprint, conformément au périmètre).
Le développement des écrans peut commencer sans lui ; l'envoi effectif des photos (PA-16) en dépend.

## 6.7 SYS_001 (ouvrage inaccessible)

- Photos prises dans le panneau d'inaccessibilité : `colPhotosInaccessible`, QuestionCode = SYS_001,
  0 à 10 photos (NbPhotosMax de SYS_001 ; R701 : photo facultative).
- Envoi à la validation du panneau, dans le dossier `{InspectionGUID}` de l'inspection INACCESSIBLE, même mécanisme (6.6).
- Aucune ligne PHOTO_CAPTURED : SYS_001 est de type SYSTEM, pas PHOTO (DEC-10).

## 6.8 PHOTO_CAPTURED

- Pour une question de type PHOTO (POT_010, LUM_012), dès qu'au moins une photo existe,
  `colReponses` contient une ligne QuestionCode = question, Valeur = PHOTO_CAPTURED (DEC-10).
- La ligne est créée au moment où la première photo de la question est ajoutée à `colPhotos`,
  et écrite dans REPONSES à l'enregistrement.
- La complétude reste mesurée par NbPhotos ≥ PhotosMin (POT_010 : 2).

## 6.9 Séquence complète

```
Utilisateur          Écran                    colPhotos / colReponses        SharePoint
    │ 📷 question Q      │                              │                         │
    │──────────────────►│ ouvrir panneau               │                         │
    │ capture / import   │                              │                         │
    │──────────────────►│ ajouter photo (EN_ATTENTE) ─►│                         │
    │                    │ si TypeQuestion = PHOTO et    │                         │
    │                    │ 1re photo : PHOTO_CAPTURED ─►│                         │
    │                    │ réévaluer les règles          │                         │
    │ Enregistrer        │                              │                         │
    │──────────────────►│ pour chaque photo EN_ATTENTE │                         │
    │                    │──────── flux PAU-06 ─────────┼───► dossier {GUID}      │
    │                    │                              │     fichier + métadonnées│
    │                    │ EtatSynchro = ENVOYEE ◄──────┼──── succès              │
    │                    │ écrire colReponses ──────────┼───► REPONSES            │
    │                    │ mettre à jour INSPECTIONS ───┼───► DateDerniereModif.  │
```

En cas d'échec d'envoi d'une photo, elle reste EN_ATTENTE, un message est affiché,
et elle sera renvoyée au prochain enregistrement.

---

# 7. Gestion des brouillons et des statuts

## 7.1 Statuts

| Statut | Défini par | Moment |
|------|------|------|
| BROUILLON | App 1 | Création de l'inspection (aucune réponse) |
| EN_COURS | App 1 | Premier enregistrement contenant au moins une réponse |
| TERMINE | App 1 | Soumission réussie |
| INACCESSIBLE | App 1 | Validation du panneau « Ouvrage inaccessible » |
| ARCHIVE | Power Automate (PAU-03), jamais App 1 | TERMINE ou INACCESSIBLE, Aujourd'hui − DateDerniereModification > 183 jours (DEC-16, DEC-17) |

```
            Commencer                      1er enregistrement            Soumettre
  (rien) ─────────────► BROUILLON ─────────────────────────► EN_COURS ─────────────► TERMINE ──┐
     │                                                                                       │ 183 j
     │ Inaccessible                                                                          ▼
     └──────────────────────────────────────────────────────────────► INACCESSIBLE ──────► ARCHIVE
                                                                                (Power Automate)
```

Aucune transition de retour. Aucune suppression.

## 7.2 Création

Déclenchée par « Commencer l'inspection » ou « Accessible maintenant » (Screen_Identification) :

1. Générer `gblInspectionGUID` (nouveau GUID).
2. `gblInspectionID` = `TMP-` + 8 premiers caractères de `gblInspectionGUID` (DEC-13).
3. Créer l'élément INSPECTIONS :
   Title = InspectionID = `gblInspectionID` ; InspectionGUID ; TypeInspection ; NomOuvrage ;
   Inspecteur = utilisateur ; DateCreation = DateDerniereModification = maintenant ;
   StatutInspection = BROUILLON ; StatutTraitement = NON_ANALYSE (DEC-02) ;
   GPSLatitude / GPSLongitude si disponibles ;
   InspectionPrecedenteGUID = InspectionGUID de `locDerniereInspection` si « Accessible maintenant » (DEC-04), vide sinon.
4. `gblInspection` = élément retourné par SharePoint.
5. Power Automate (PAU-04) attribue ensuite InspectionID = Title = `INS-{DateCreation AAAAMMJJ}-{ID sur 6 chiffres}` (DEC-14).
6. Initialiser `colQuestionsFormulaire`, `colReponses` (vide), `colPhotos` (vide), évaluer `colEtatQuestions`.
7. Naviguer vers Screen_Inspection.

## 7.3 Enregistrement (brouillon)

Toujours autorisé (D003, R600), quel que soit l'état du formulaire. Déclenché par « Enregistrer »,
« Accueil » et « Enregistrer comme brouillon » :

1. Envoyer les photos EN_ATTENTE (6.9).
2. Pour chaque ligne de `colReponses` NOUVELLE : créer l'élément REPONSES
   (Title = ReponseID = GUID, DEC-01 / DEC-03 ; DateEncodage ; UtilisateurEncodage) ;
   pour chaque ligne MODIFIEE : mettre à jour l'élément REPONSES (SharePointID) ;
   passer les lignes à SYNCHRONISEE.
3. Si au moins une modification métier a été enregistrée (réponse, commentaire, photo — DEC-17) :
   mettre à jour INSPECTIONS.DateDerniereModification = maintenant.
4. Si StatutInspection = BROUILLON et `colReponses` contient au moins une ligne : StatutInspection = EN_COURS.
5. Relire l'élément INSPECTIONS : `gblInspection`, `gblInspectionID` (valeur finale si déjà attribuée).
6. `locModificationsNonEnregistrees` = Faux.

## 7.4 Reprise

Depuis la galerie « Inspections à reprendre » (BROUILLON / EN_COURS de l'utilisateur courant, DEC-09) :

1. `gblInspection` = inspection sélectionnée ; `gblInspectionGUID`, `gblInspectionID`, `gblTypeInspection`,
   `gblNomOuvrage` depuis cet élément.
2. Charger `colReponses` (REPONSES filtrée sur InspectionGUID) et `colPhotos`
   (PHOTOS_INSPECTIONS filtrée sur InspectionGUID).
3. Construire `colQuestionsFormulaire` et évaluer `colEtatQuestions`.
4. Naviguer vers Screen_Inspection.

L'ouverture seule ne modifie ni le statut ni DateDerniereModification (DEC-17).

## 7.5 Soumission

1. Évaluation complète et contrôles (5.6). Si `colAnomalies` n'est pas vide : soumission refusée (D004, R503).
2. Enregistrement (7.3).
3. Mise à jour INSPECTIONS : StatutInspection = TERMINE ; DateSoumission = DateDerniereModification = maintenant.
4. Message de confirmation, réinitialisation du contexte (2.3), navigation vers Screen_Home.

Après soumission, l'inspection n'est plus modifiable (consultation en lecture seule, D005).

## 7.6 Inaccessibilité

Depuis le panneau « Ouvrage inaccessible » (Screen_Identification) :

1. Contrôle : `locCommentaireInaccessible` non vide (SYS_001.CommentaireObligatoire = OUI ; R700).
   Photos facultatives (R701), au plus 10.
2. Création de l'inspection comme en 7.2 (étapes 1 à 4), avec StatutInspection = INACCESSIBLE.
3. Création d'un élément REPONSES : QuestionCode = SYS_001, Valeur vide, Commentaire = `locCommentaireInaccessible`.
4. Envoi des photos de `colPhotosInaccessible` (QuestionCode = SYS_001) dans `{InspectionGUID}`.
5. DateSoumission : non renseignée (OQ-07 ouverte).
6. Message de confirmation, réinitialisation du contexte, navigation vers Screen_Home.

## 7.7 Archivage

Réalisé exclusivement par Power Automate (PAU-03). App 1 n'écrit jamais ARCHIVE.
Les inspections archivées restent consultables dans Screen_History.

---

# 8. Flux utilisateur complets

Notation : « Enregistrer » = séquence 7.3 ; « Soumettre » = séquence 7.5.

## 8.1 Inspection luminaire normale

| # | Action | Effet |
|------|------|------|
| 1 | Accueil → Nouvelle inspection → Luminaire | `gblTypeInspection` = LUMINAIRE |
| 2 | Saisie de l'ouvrage (ex. E100 511-1) → Rechercher | Historique affiché ; avertissement si une inspection LUMINAIRE BROUILLON / EN_COURS existe (DEC-08) |
| 3 | Commencer l'inspection | INSPECTIONS créée : `TMP-…`, BROUILLON ; 13 questions LUMINAIRE affichées, toutes visibles par défaut |
| 4 | LUM_001 = VALIDE | Aucune règle déclenchée |
| 5 | LUM_002, LUM_003, LUM_010, LUM_011 cochées (FAIT) ; LUM_004 à LUM_009 renseignées | Questions obligatoires répondues |
| 6 | Facultatif : photos (LUM_012, PHOTO_CAPTURED), commentaires (LUM_013) | Aucun minimum de photo (NbPhotosMin = 0 pour toutes les questions LUMINAIRE) |
| 7 | Enregistrer | REPONSES écrites ; statut EN_COURS ; InspectionID final lu s'il est attribué |
| 8 | Résumé | `colAnomalies` vide |
| 9 | Soumettre | TERMINE ; retour à l'accueil |

## 8.2 Luminaire non présent

| # | Action | Effet |
|------|------|------|
| 1 à 3 | Comme 8.1 | Inspection LUMINAIRE BROUILLON |
| 4 | LUM_001 = NON_PRESENT | R001 : commentaire de LUM_001 obligatoire (💬 signalée) ; R002 : toutes les autres questions masquées, seule LUM_001 reste visible |
| 5 | Commentaire saisi sur LUM_001 | Contrôle commentaire satisfait |
| 6 | Résumé | Seule LUM_001 contrôlée (questions masquées neutralisées, 5.3 étape 5) ; aucune anomalie |
| 7 | Soumettre | TERMINE |

Variante : sans commentaire, Screen_Resume affiche COMMENTAIRE_OBLIGATOIRE (LUM_001) et bloque la soumission.

## 8.3 Inspection poteau — corrosion avancée

| # | Action | Effet |
|------|------|------|
| 1 à 3 | Accueil → Poteau → ouvrage → Commencer | 20 questions POTEAU ; 12 visibles par défaut |
| 4 | POT_001, POT_003 renseignées | Photos minimum : 1 chacune (catalogue) |
| 5 | POT_002 = VALIDE / A_REFAIRE / FAIT | R200 / R201 : 1 photo ; R202 : 2 photos (remplacement, DEC-06) |
| 6 | POT_004 = AVANCEE | R100–R103 : POT_004_1, POT_004_2_A, POT_004_2_B, POT_004_2_C visibles et obligatoires |
| 7 | POT_004_2_A et POT_004_2_B saisies | POT_004_2_C calculée = (A − B) / A × 100 |
| 8a | Perte ≥ 30 | R120 : POT_004_3 (test marteau) visible et obligatoire ; R131 fausse → POT_004_5 masquée |
| 8b | Perte < 30 et POT_004_1 = OUI | R130 + R131 : POT_004_5 visible et obligatoire ; R140 : 1 photo minimum |
| 8c | Perte < 30 et POT_004_1 = NON | POT_004_3 et POT_004_5 masquées |
| 8d | POT_004_2_A = 0 | R150 : calcul bloqué, POT_004_2_C vidée ; R151 : soumission bloquée (anomalie BLOCAGE) |
| 9 | POT_005 à POT_008 = NON_VALIDE | R300–R303 : 1 photo minimum pour la question concernée |
| 10 | POT_010 : 2 photos | PHOTO_CAPTURED ; minimum 2 atteint |
| 11 | POT_010B = OUI | R400 / R401 : POT_010B_A visible et obligatoire |
| 12 | Enregistrer, Résumé, Soumettre | Soumission possible si aucune anomalie ; TERMINE |

## 8.4 Inspection poteau — corrosion sévère

| # | Action | Effet |
|------|------|------|
| 1 à 5 | Comme 8.3 | |
| 6 | POT_004 = SEVERE | R110 : POT_004_4 (surface de perforation) visible et obligatoire ; R100–R103 fausses : POT_004_1, POT_004_2_A/B/C masquées |
| 7 | POT_004_4 renseignée | INF_4CM2 ou SUP_EGAL_4CM2 |
| 8 | Conséquence | POT_004_3 et POT_004_5 restent masquées (leurs règles dépendent de questions masquées, 5.4) |
| 9 | Suite comme 8.3, étapes 9 à 12 | TERMINE |

## 8.5 Inspection inaccessible

| # | Action | Effet |
|------|------|------|
| 1 | Accueil → Nouvelle inspection → type → ouvrage → Rechercher | Historique affiché |
| 2 | Inspection inaccessible | Panneau ouvert |
| 3 | Commentaire saisi (obligatoire, R700) ; 0 à 10 photos (R701) | `colPhotosInaccessible` |
| 4 | Valider | INSPECTIONS créée au statut INACCESSIBLE (`TMP-…` puis `INS-…`) ; REPONSES SYS_001 avec le commentaire ; photos SYS_001 dans `{InspectionGUID}` |
| 5 | Retour à l'accueil | Confirmation |
| Plus tard | Même ouvrage, même type → Rechercher | Bandeau « Inaccessible » ; bouton « Accessible maintenant » |
| Plus tard | Accessible maintenant | Nouvelle inspection BROUILLON avec InspectionPrecedenteGUID = GUID de l'inspection INACCESSIBLE (DEC-04) ; l'inspection INACCESSIBLE n'est pas modifiée |

## 8.6 Reprise d'un brouillon

| # | Action | Effet |
|------|------|------|
| 1 | Accueil → Reprendre inspection | `colInspectionsAReprendre` : BROUILLON / EN_COURS de l'utilisateur (DEC-09) |
| 2 | Sélection d'une inspection | Chargement 7.4 : réponses, photos, état des règles recalculé |
| 3 | Consultation sans modification puis Accueil | Aucune écriture : DateDerniereModification inchangée (DEC-17) |
| 4 | Modification (réponse, commentaire ou photo) puis Enregistrer | Écritures SharePoint ; DateDerniereModification mise à jour ; BROUILLON → EN_COURS si nécessaire |
| 5 | Résumé, Soumettre | TERMINE |

## 8.7 Consultation de l'historique

| # | Action | Effet |
|------|------|------|
| 1 | Accueil → Historique ; ou Screen_Identification → clic sur une inspection précédente | `gblEcranRetourHistorique` défini |
| 2 | Recherche par nom d'ouvrage (depuis l'accueil) | `colHistorique` : tous statuts, y compris ARCHIVE |
| 3 | Sélection d'une inspection | `gblInspectionConsultee` ; chargement de `colReponsesConsultees` et `colPhotosConsultees` |
| 4 | Lecture | Réponses, commentaires et photos en lecture seule ; pour une inspection INACCESSIBLE : commentaire et photos SYS_001 |
| 5 | Retour | Écran d'origine ; aucune écriture, DateDerniereModification inchangée |

---

# 9. Points d'attention pour l'implémentation

Ces points ne sont pas des décisions : ils signalent ce que le développeur doit vérifier
ou ce que les documents de référence ne tranchent pas.

| # | Point | Impact | Référence |
|------|------|------|------|
| PA-1 | **Envoi des fichiers photo** : nécessite un flux Power Automate appelé depuis l'application (6.6) | PA-16 dépend de PAU-06 | Backlog PAU-06 |
| PA-2 | **Délégation** : vérifier dans Studio l'absence d'avertissement de délégation sur les filtres INSPECTIONS (NomOuvrage, StatutInspection, Inspecteur), REPONSES et PHOTOS_INSPECTIONS (InspectionGUID). Le filtre sur la colonne Personne `Inspecteur` (DEC-09) est le plus sensible | Résultats incomplets au-delà de la limite de lignes de données | Index du schéma |
| PA-3 | **Réponses des questions devenues masquées** : les documents ne précisent pas si une réponse saisie puis masquée (ex. POT_004 passe d'AVANCEE à BON) est conservée ou effacée. Le moteur l'ignore (5.4, 5.3 étape 5) ; son sort en base est à décider | Contenu de REPONSES et des exports | `docs/build/open-questions.md`, OQ-12 |
| PA-4 | **Passage BROUILLON → EN_COURS** : « au moins une réponse » est implémenté comme « au moins une ligne dans `colReponses` » (réponse, commentaire seul ou PHOTO_CAPTURED) | Statut affiché | Spécification § 11 |
| PA-5 | **Arrondi du calcul** : aucune règle d'arrondi n'est définie pour POT_004_2_C ; comparer la valeur non arrondie aux seuils de R120 / R131, arrondir seulement à l'affichage | Seuil de 30 % | R120, R131 |
| PA-6 | **InspectionID temporaire affiché** : tant que PAU-04 n'est pas construit, les inspections conservent `TMP-…` | Affichage uniquement | DEC-13, DEC-14 |
| PA-7 | **Compression** : non implémentée tant qu'OQ-06 est ouverte ; CompressionVersion = ORIGINAL | Volume des photos | OQ-06, PA-17 |
| PA-8 | **Pré-requis d'exécution** : permissions des techniciens (accord du propriétaire du site), tests d'écriture sur site de test, environnement Power Platform | Tests avec comptes techniciens | `docs/build/powerapps-readiness.md` |
