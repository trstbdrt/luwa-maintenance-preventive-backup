# LUWA Maintenance Preventive Backup
## Écrans Power Apps — App 1 v0.1.4

Version : 0.1.4

Date : 2026-10-08

Références :

- `docs/specification/specification-fonctionnelle-v0.1.md`
- `docs/architecture/architecture-globale-v0.1.md`
- `sharepoint/data-model/sharepoint-schema.md`
- `sharepoint/questions/questions.csv`
- `sharepoint/regles/regles_formulaire.csv`
- `docs/decisions/technical-decisions-v0.1.2.md`
- `docs/decisions/technical-decisions-v0.1.3.md`

Ce document décrit les écrans sans Power Fx. Les comportements sont exprimés en langage naturel.

---

# 0. Principes communs

## Périmètre

App 1 est une application de collecte terrain. Elle ne prend **aucune décision métier**
(pas de création OT, pas de validation technique, pas de classification).

## Pilotage par configuration

Aucun formulaire n'est codé en dur. Les questions affichées, leur caractère obligatoire,
les photos exigées et les affichages conditionnels sont entièrement dérivés de :

- la liste QUESTIONS ;
- la liste REGLES_FORMULAIRE (règles `Actif = Oui`, évaluées par `Priorite` croissante).

## Conventions de nommage

| Préfixe | Usage |
|------|------|
| `gbl` | Variable globale |
| `loc` | Variable de contexte (propre à un écran) |
| `col` | Collection |
| `scr` / `Screen_` | Écran |

## Variables globales

| Variable | Contenu |
|------|------|
| `gblUtilisateur` | Utilisateur connecté (e-mail, nom) |
| `gblTypeInspection` | POTEAU ou LUMINAIRE, choisi sur Screen_Type |
| `gblNomOuvrage` | Ouvrage encodé sur Screen_Identification |
| `gblInspection` | Inspection en cours d'édition (ligne INSPECTIONS, dont InspectionGUID) |
| `gblInspectionConsultee` | Inspection ouverte en lecture seule sur Screen_History |
| `gblEcranRetourHistorique` | Écran vers lequel revenir en quittant Screen_History |

## Collections globales

| Collection | Contenu | Chargement |
|------|------|------|
| `colQuestions` | Catalogue QUESTIONS complet (34 lignes) | Au démarrage |
| `colRegles` | REGLES_FORMULAIRE filtrées sur `Actif = Oui`, triées par `Priorite` | Au démarrage |

Les catalogues sont petits : ils sont chargés une fois et évalués localement.

## Cycle de vie des statuts

| Événement | StatutInspection |
|------|------|
| Inspection créée (type et ouvrage sélectionnés, aucune réponse) | BROUILLON |
| Au moins une réponse enregistrée, non soumise | EN_COURS |
| Soumission réussie | TERMINE |
| Déclaration d'ouvrage inaccessible | INACCESSIBLE |
| Archivage (hors App 1, après 6 mois) | ARCHIVE |

Aucune suppression n'est possible, quel que soit le statut.

## Clé relationnelle

Toutes les écritures dans REPONSES et PHOTOS_INSPECTIONS utilisent `InspectionGUID`.
`InspectionID` (= `Title`) n'est utilisé que pour l'affichage et le nom du dossier photos.

## Mode hors connexion (préparation)

Les collections de travail (`colReponses`, `colPhotos`) sont conçues pour pouvoir être
sauvegardées localement (SaveData / LoadData) dans une version ultérieure.
Le mode hors connexion n'est pas implémenté en v0.1.

---

# 1. Screen_Home

## Objectif

Point d'entrée de l'application : démarrer, reprendre ou consulter une inspection.

## Composants

| Composant | Description |
|------|------|
| En-tête | Nom de l'application, utilisateur connecté |
| Bouton « Nouvelle inspection » | Démarre le parcours de création |
| Bouton « Reprendre inspection » | Affiche la liste des inspections reprenables |
| Galerie « Inspections à reprendre » | Inspections BROUILLON ou EN_COURS **de l'utilisateur courant** (DEC-09) : InspectionID, ouvrage, type, statut, date de dernière modification |
| Bouton « Historique » | Ouvre la consultation des inspections |

## Variables

| Variable | Usage |
|------|------|
| `locAfficherReprise` | Affiche / masque la galerie de reprise |

## Collections

| Collection | Usage |
|------|------|
| `colQuestions`, `colRegles` | Chargées au démarrage de l'application |
| `colInspectionsAReprendre` | Résultat de la recherche BROUILLON / EN_COURS |

## Sources SharePoint

| Source | Accès |
|------|------|
| INSPECTIONS | Lecture (filtre sur StatutInspection, colonne indexée, et Inspecteur = utilisateur courant) |
| QUESTIONS | Lecture |
| REGLES_FORMULAIRE | Lecture |

## Navigation

| Action | Destination |
|------|------|
| Nouvelle inspection | Screen_Type |
| Sélection d'une inspection à reprendre | Screen_Inspection (`gblInspection` = inspection sélectionnée, réponses et photos rechargées) |
| Historique | Screen_History (`gblEcranRetourHistorique` = Screen_Home) |

---

# 2. Screen_Type

## Objectif

Choisir le formulaire d'inspection. Les deux formulaires sont totalement séparés (décision D001).

## Composants

| Composant | Description |
|------|------|
| Bouton « Poteau » | Équipes au sol |
| Bouton « Luminaire » | Équipes en nacelle |
| Bouton « Retour » | Retour à l'accueil |

## Variables

| Variable | Usage |
|------|------|
| `gblTypeInspection` | POTEAU ou LUMINAIRE |

## Collections

Aucune.

## Sources SharePoint

Aucune.

## Navigation

| Action | Destination |
|------|------|
| Poteau / Luminaire | Screen_Identification |
| Retour | Screen_Home |

---

# 3. Screen_Identification

## Objectif

Identifier l'ouvrage, afficher son historique et ses inspections en cours,
puis démarrer l'inspection ou déclarer l'ouvrage inaccessible.

## Composants

| Composant | Description |
|------|------|
| Rappel du type | POTEAU ou LUMINAIRE |
| Champ « Nom ouvrage » | Saisie manuelle (ex. `E100 511`, `E100 511-1`, `K024 318-2`), sans validation patrimoine |
| Bouton « Rechercher » | Lance la recherche de l'historique de l'ouvrage |
| Bandeau « Dernière inspection » | Statut de la dernière inspection connue : Terminée, En cours, Inaccessible |
| Avertissement de concurrence | « Une inspection est actuellement en cours sur cet ouvrage. » — affiché s'il existe une inspection BROUILLON ou EN_COURS du même ouvrage et du même type (DEC-08) ; informatif, ne bloque jamais |
| Galerie « Inspections précédentes » | Inspections de l'ouvrage ; un clic ouvre Screen_History en lecture seule |
| Bouton « Commencer l'inspection » | Crée l'inspection ; libellé « Accessible maintenant » si la dernière inspection est INACCESSIBLE |
| Bouton « Inspection inaccessible » | Ouvre le panneau d'inaccessibilité |
| Panneau « Ouvrage inaccessible » | Commentaire obligatoire + photos facultatives (support : question système SYS_001) |
| Bouton « Retour » | Retour au choix du type |

## Comportement « Commencer l'inspection »

Création d'une ligne INSPECTIONS :

- InspectionGUID : nouveau GUID ;
- InspectionGUID : généré immédiatement (DEC-11) ;
- InspectionID : éventuellement temporaire pendant la saisie, valeur finale `INS-AAAAMMJJ-NNNNNN` attribuée lors de la synchronisation SharePoint (DEC-11) ; Title = InspectionID ;
- TypeInspection, NomOuvrage, Inspecteur = utilisateur connecté ;
- DateCreation et DateDerniereModification = maintenant ;
- StatutInspection = BROUILLON ;
- StatutTraitement = NON_ANALYSE (DEC-02) ;
- GPSLatitude / GPSLongitude : si disponibles ;
- InspectionPrecedenteGUID : en cas d'« Accessible maintenant », InspectionGUID de la dernière inspection
  INACCESSIBLE de l'ouvrage (DEC-04) ; vide sinon.

L'inspection précédente n'est jamais modifiée.

## Comportement « Ouvrage inaccessible »

- Le commentaire est obligatoire (SYS_001 : CommentaireObligatoire = OUI ; règle R700).
- Les photos sont facultatives (règle R701), jusqu'à 10 (SYS_001 : NbPhotosMax = 10).
- La validation crée :
  - une ligne INSPECTIONS avec StatutInspection = INACCESSIBLE ;
  - une ligne REPONSES sur QuestionCode = SYS_001 contenant le commentaire ;
  - les photos éventuelles dans PHOTOS_INSPECTIONS avec QuestionCode = SYS_001.

## Variables

| Variable | Usage |
|------|------|
| `gblNomOuvrage` | Ouvrage saisi |
| `locDerniereInspection` | Dernière inspection connue de l'ouvrage |
| `locInspectionEnCoursExiste` | Déclenche l'avertissement de concurrence |
| `locAfficherPanneauInaccessible` | Affiche le panneau d'inaccessibilité |
| `locCommentaireInaccessible` | Commentaire saisi dans le panneau |

## Collections

| Collection | Usage |
|------|------|
| `colHistoriqueOuvrage` | Inspections de l'ouvrage (tous statuts, y compris ARCHIVE), triées par date décroissante |
| `colPhotosInaccessible` | Photos prises dans le panneau d'inaccessibilité, avant enregistrement |

## Sources SharePoint

| Source | Accès |
|------|------|
| INSPECTIONS | Lecture (filtre sur NomOuvrage, indexé) ; création |
| REPONSES | Création (SYS_001) |
| PHOTOS_INSPECTIONS | Création (photos SYS_001) |

## Navigation

| Action | Destination |
|------|------|
| Commencer l'inspection / Accessible maintenant | Screen_Inspection |
| Validation de l'inaccessibilité | Screen_Home (message de confirmation) |
| Clic sur une inspection précédente | Screen_History (`gblEcranRetourHistorique` = Screen_Identification) |
| Retour | Screen_Type |

---

# 4. Screen_Inspection

## Objectif

Saisir les réponses, commentaires et photos du formulaire POTEAU ou LUMINAIRE,
avec affichage dynamique piloté par REGLES_FORMULAIRE.

## Composants

| Composant | Description |
|------|------|
| En-tête | InspectionID, ouvrage, type, statut |
| Avertissement de concurrence | Rappel informatif si une autre inspection BROUILLON ou EN_COURS du même type existe sur l'ouvrage (DEC-08) |
| Galerie des questions | Questions du formulaire (`Formulaire` = type), triées par `OrdreAffichage`, regroupées par `DisplayGroup` (GENERAL, CORROSION, SUR_PONT) |
| Sous-questions | Questions ayant un `QuestionParent`, affichées sous leur parent |
| Contrôle de réponse | Selon `TypeQuestion` (voir tableau ci-dessous) |
| Indicateur « obligatoire » | Si `Obligatoire = OUI` ou règle RENDRE_OBLIGATOIRE active |
| Icône 💬 | Visible si `CommentaireAutorise = OUI` ; ouvre le panneau commentaire ; signalée si commentaire obligatoire (`CommentaireObligatoire` ou règle COMMENT_OBLIGATOIRE) |
| Icône 📷 | Visible si `PhotoAutorisee = OUI` ; ouvre le panneau photos ; compteur « n/min » (ex. 0/2, 1/2, 2/2 ✅) |
| Panneau commentaire | Saisie du commentaire de la question |
| Panneau photos | Prise de photo (appareil) ou import (galerie), liste des photos de la question, maximum `NbPhotosMax` |
| Bouton « Enregistrer » | Sauvegarde toujours autorisée (décision D003, règle R600) |
| Bouton « Résumé » | Vérification de complétude avant soumission |
| Bouton « Accueil » | Retour à l'accueil après enregistrement |

## Contrôle selon TypeQuestion

| TypeQuestion | Contrôle |
|------|------|
| RADIO | Choix unique parmi `ValeursPossibles` (séparateur `\|`) |
| CHECKBOX | Case à cocher ; valeur cochée = valeur de `ValeursPossibles` (ex. FAIT) |
| NUMERIQUE | Saisie numérique |
| CALCUL | Lecture seule ; calculé à partir de `FormuleCalcul` ; non calculé si la règle BLOQUER_CALCUL est active (R150) |
| PHOTO | Aucun champ de saisie ; seulement le panneau photos. À l'enregistrement, une ligne REPONSES avec Valeur = PHOTO_CAPTURED est créée dès qu'au moins une photo existe (DEC-10) |
| TEXTE | Texte libre |
| SYSTEM | Jamais affiché dans ce formulaire (SYS_001 appartient au formulaire SYSTEM) |

## Évaluation des règles

À chaque modification de réponse, les règles actives du formulaire courant
(et celles de `Formulaire = ALL`) sont réévaluées par ordre de `Priorite` :

| Action | Effet à l'écran |
|------|------|
| AFFICHER | Rend visible la question cible |
| WAITING_SECOND_CONDITION + AFFICHER_IF_MATCH | Condition composée : la cible n'est visible que si les deux conditions sont vraies (R130 + R131) |
| MASQUER_FORMULAIRE | Masque les questions restantes du formulaire (R002) |
| RENDRE_OBLIGATOIRE | Rend la cible obligatoire |
| COMMENT_OBLIGATOIRE | Rend le commentaire de la cible obligatoire |
| PHOTO_MIN | Remplace le NbPhotosMin du catalogue par `Parametre` pour la cible tant que la règle est vérifiée (DEC-06) |
| BLOQUER_CALCUL | Empêche le calcul de la cible |
| BLOQUER_SOUMISSION | Empêche la soumission (contrôlé sur Screen_Resume) |

Les règles R150 et R151 ne s'appliquent que si POT_004_2_A est visible et renseignée
(une réponse vide est différente de 0).

Une question masquée n'est ni obligatoire, ni contrôlée à la soumission.

## Comportement « Enregistrer »

- Écrit / met à jour les lignes REPONSES de l'inspection (clé InspectionGUID + QuestionCode ; à la création, ReponseID = Title = nouveau GUID).
- Envoie les photos en attente dans PHOTOS_INSPECTIONS (dossier `AAAA/MM/InspectionID/`,
  métadonnées InspectionGUID, QuestionCode, NomOuvrage, Auteur, DatePhoto, CompressionVersion).
- Met à jour DateDerniereModification (date de référence de l'archivage, DEC-12).
- Passe le statut de BROUILLON à EN_COURS dès qu'au moins une réponse existe.
- Compression des photos : configurable, non systématique ; paramètres listés en DEC-07, stockage à définir.

## Variables

| Variable | Usage |
|------|------|
| `gblInspection` | Inspection en cours |
| `locQuestionActive` | Question dont le panneau commentaire ou photos est ouvert |
| `locAfficherPanneauCommentaire` | Affichage du panneau commentaire |
| `locAfficherPanneauPhotos` | Affichage du panneau photos |
| `locModificationsNonEnregistrees` | Indique des changements non sauvegardés |

## Collections

| Collection | Usage |
|------|------|
| `colQuestionsFormulaire` | Questions du formulaire courant |
| `colReponses` | Réponses de l'inspection (copie de travail) |
| `colPhotos` | Photos de l'inspection (existantes et en attente d'envoi) |
| `colEtatQuestions` | Pour chaque question : visible, obligatoire, commentaire obligatoire, photos min, calcul bloqué — résultat de l'évaluation des règles |

## Sources SharePoint

| Source | Accès |
|------|------|
| INSPECTIONS | Mise à jour (statut, DateDerniereModification) |
| REPONSES | Lecture (filtre InspectionGUID, indexé) ; création ; mise à jour |
| PHOTOS_INSPECTIONS | Lecture (filtre InspectionGUID, indexé) ; création |
| QUESTIONS, REGLES_FORMULAIRE | Via `colQuestions` et `colRegles` |

## Navigation

| Action | Destination |
|------|------|
| Résumé | Screen_Resume |
| Accueil | Screen_Home (après enregistrement) |

---

# 5. Screen_Resume

## Objectif

Vérifier la complétude de l'inspection et la soumettre (décision D004 :
soumission uniquement si le formulaire est valide).

## Composants

| Composant | Description |
|------|------|
| En-tête | InspectionID, ouvrage, type |
| Synthèse | Nombre de questions visibles, répondues, photos présentes / exigées |
| Liste « Questions obligatoires manquantes » | R500 — un clic renvoie à la question |
| Liste « Photos manquantes » | R501 — question, compteur n/min |
| Liste « Questions conditionnelles non complétées » | R502 |
| Liste « Commentaires obligatoires manquants » | Commentaires exigés par le catalogue ou par COMMENT_OBLIGATOIRE |
| Message de blocage | R151 (épaisseur sans corrosion = 0) et tout BLOQUER_SOUMISSION actif |
| Bouton « Soumettre » | Actif uniquement si aucune anomalie (R503) |
| Bouton « Enregistrer comme brouillon » | Toujours actif (R600) |
| Bouton « Retour à l'inspection » | |

## Comportement « Soumettre »

- StatutInspection = TERMINE ;
- DateSoumission et DateDerniereModification = maintenant ;
- toutes les réponses et photos en attente sont enregistrées avant le changement de statut.

## Variables

| Variable | Usage |
|------|------|
| `locSoumissionPossible` | Vrai si aucune anomalie bloquante |

## Collections

| Collection | Usage |
|------|------|
| `colAnomalies` | Anomalies détectées (type, QuestionCode, libellé, détail) |
| `colReponses`, `colPhotos`, `colEtatQuestions` | Reprises de Screen_Inspection |

## Sources SharePoint

| Source | Accès |
|------|------|
| INSPECTIONS | Mise à jour (statut, dates) |
| REPONSES | Création / mise à jour |
| PHOTOS_INSPECTIONS | Création |

## Navigation

| Action | Destination |
|------|------|
| Clic sur une anomalie | Screen_Inspection, positionné sur la question |
| Retour à l'inspection | Screen_Inspection |
| Enregistrer comme brouillon | Screen_Home |
| Soumettre (succès) | Screen_Home (message de confirmation) |

---

# 6. Screen_History

## Objectif

Consulter les inspections en **lecture seule** (décision D005). Aucune modification possible.

## Composants

| Composant | Description |
|------|------|
| Champ de recherche « Nom ouvrage » | Visible si l'écran est ouvert depuis l'accueil |
| Galerie des inspections | Inspections trouvées (tous statuts, y compris ARCHIVE) : InspectionID, type, statut, dates |
| Détail de l'inspection | En-tête (InspectionID, ouvrage, type, inspecteur, dates, statut) |
| Galerie des réponses | Questions du formulaire avec réponse, commentaire et photos, en lecture seule |
| Visionneuse photos | Affichage des photos d'une question |
| Bouton « Retour » | Retour à l'écran d'origine |

Pour une inspection INACCESSIBLE : affichage du commentaire et des photos SYS_001.

## Variables

| Variable | Usage |
|------|------|
| `gblInspectionConsultee` | Inspection affichée |
| `gblEcranRetourHistorique` | Écran d'origine |
| `locRechercheOuvrage` | Texte de recherche |

## Collections

| Collection | Usage |
|------|------|
| `colHistoriqueResultats` | Inspections trouvées |
| `colReponsesConsultees` | Réponses de l'inspection affichée |
| `colPhotosConsultees` | Photos de l'inspection affichée |

## Sources SharePoint

| Source | Accès |
|------|------|
| INSPECTIONS | Lecture (filtre NomOuvrage, indexé) |
| REPONSES | Lecture (filtre InspectionGUID, indexé) |
| PHOTOS_INSPECTIONS | Lecture (filtre InspectionGUID, indexé) |
| QUESTIONS | Via `colQuestions` (libellés) |

## Navigation

| Action | Destination |
|------|------|
| Retour | `gblEcranRetourHistorique` (Screen_Home ou Screen_Identification) |
