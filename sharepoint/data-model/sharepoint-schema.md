# LUWA Maintenance Preventive Backup
## SharePoint Schema v0.1.4

Version : 0.1.4

Date : 2026-10-08

Statut : Validé — référence technique complète

Décisions appliquées : `docs/decisions/technical-decisions-v0.1.2.md` (DEC-01 à DEC-10) et `docs/decisions/technical-decisions-v0.1.3.md` (DEC-11, DEC-12)

---

# Vue d'ensemble

Le stockage repose sur :

- INSPECTIONS
- QUESTIONS
- REGLES_FORMULAIRE
- REPONSES
- PHOTOS_INSPECTIONS

---

# 1. Liste INSPECTIONS

Une ligne = une inspection.

## Colonnes

| Nom | Type SharePoint | Obligatoire | Index |
|------|------|------|------|
| Title | Single line text | Oui | Oui |
| InspectionID | Single line text | Oui | Oui |
| InspectionGUID | Single line text | Oui | Oui |
| TypeInspection | Choice | Oui | Oui |
| NomOuvrage | Single line text | Oui | Oui |
| Inspecteur | Person | Oui | Non |
| DateCreation | DateTime | Oui | Non |
| DateDerniereModification | DateTime | Oui | Non |
| DateSoumission | DateTime | Non | Non |
| StatutInspection | Choice | Oui | Oui |
| StatutTraitement | Choice | Oui | Oui |
| GPSLatitude | Number | Non | Non |
| GPSLongitude | Number | Non | Non |
| InspectionPrecedenteGUID | Single line text | Non | Non |

## Règles de remplissage

Title = InspectionID (DEC-01)

InspectionGUID est la clé principale et la clé relationnelle unique (DEC-03).

Toutes les relations (REPONSES, PHOTOS_INSPECTIONS, InspectionPrecedenteGUID) utilisent InspectionGUID.

InspectionID est un identifiant métier lisible, utilisé uniquement pour l'affichage. Il peut être temporaire pendant la saisie et reçoit sa valeur finale `INS-AAAAMMJJ-NNNNNN` lors de la synchronisation SharePoint ; aucune relation ne dépend de InspectionID (DEC-11).

InspectionGUID est généré immédiatement à la création de l'inspection (DEC-11).

DateDerniereModification est mise à jour à chaque enregistrement ; elle est la date de référence de l'archivage : une inspection est archivable uniquement si Aujourd'hui - DateDerniereModification > 6 mois (DEC-12).

Le commentaire d'inaccessibilité est stocké dans REPONSES sur la question SYS_001.

StatutTraitement = NON_ANALYSE à la création de l'inspection (DEC-02). Valeur par défaut de la colonne : NON_ANALYSE.

InspectionPrecedenteGUID = InspectionGUID de la dernière inspection INACCESSIBLE de l'ouvrage, renseigné uniquement lorsque l'utilisateur sélectionne « Accessible maintenant » (DEC-04). Vide dans tous les autres cas.

## Valeurs StatutInspection

- BROUILLON
- EN_COURS
- TERMINE
- INACCESSIBLE
- ARCHIVE

## Valeurs StatutTraitement

- NON_ANALYSE
- ANALYSE_EN_COURS
- VALIDE
- ACTION_REQUISE
- CLOTURE

---

# 2. Liste QUESTIONS

Catalogue de configuration.

Une ligne = une question.

## Colonnes

| Nom | Type SharePoint | Obligatoire | Index |
|------|------|------|------|
| Title | Single line text | Oui | Non |
| QuestionCode | Single line text | Oui | Oui |
| QuestionParent | Single line text | Non | Oui |
| DisplayGroup | Choice | Oui | Non |
| Formulaire | Choice | Oui | Oui |
| OrdreAffichage | Number | Oui | Non |
| Libelle | Single line text | Oui | Non |
| TypeQuestion | Choice | Oui | Non |
| Obligatoire | Yes/No | Oui | Non |
| CommentaireAutorise | Yes/No | Oui | Non |
| CommentaireObligatoire | Yes/No | Oui | Non |
| PhotoAutorisee | Yes/No | Oui | Non |
| NbPhotosMin | Number | Oui | Non |
| NbPhotosMax | Number | Oui | Non |
| VisibleParDefaut | Yes/No | Oui | Non |
| ValeursPossibles | Multiple line text | Non | Non |
| FormuleCalcul | Multiple line text | Non | Non |

## Règles de remplissage

Title = QuestionCode (DEC-01)

## Valeurs DisplayGroup

- GENERAL
- CORROSION
- SUR_PONT
- SYSTEM

## Valeurs Formulaire

- POTEAU
- LUMINAIRE
- SYSTEM

## Valeurs TypeQuestion

- RADIO
- CHECKBOX
- NUMERIQUE
- PHOTO
- TEXTE
- CALCUL
- SYSTEM

---

# 3. Liste REGLES_FORMULAIRE

Catalogue moteur de règles.

## Colonnes

| Nom | Type SharePoint | Obligatoire | Index |
|------|------|------|------|
| Title | Single line text | Oui | Non |
| RuleID | Single line text | Oui | Oui |
| Priorite | Number | Oui | Oui |
| Formulaire | Choice | Oui | Oui |
| QuestionSource | Single line text | Oui | Oui |
| ConditionType | Choice | Oui | Non |
| ConditionValeur | Single line text | Oui | Non |
| Action | Choice | Oui | Non |
| QuestionCible | Single line text | Oui | Non |
| Parametre | Single line text | Non | Non |
| Actif | Yes/No | Oui | Non |
| Commentaire | Multiple line text | Non | Non |

## Règles de remplissage

Title = RuleID (DEC-01)

Une action PHOTO_MIN dont la règle est active (Actif = Oui) et dont la condition est vérifiée remplace la valeur NbPhotosMin du catalogue QUESTIONS pour la question cible (DEC-06).

## Valeurs Formulaire

- POTEAU
- LUMINAIRE
- SYSTEM
- ALL

## Valeurs ConditionType

- EQUALS
- GREATER_OR_EQUAL
- LESS_THAN
- VISIBLE
- VALIDATION
- SAVE
- PRESENCE

## Valeurs Action

- AFFICHER
- AFFICHER_IF_MATCH
- WAITING_SECOND_CONDITION
- MASQUER_FORMULAIRE
- PHOTO_MIN
- RENDRE_OBLIGATOIRE
- OBLIGATOIRE
- COMMENT_OBLIGATOIRE
- BLOQUER_CALCUL
- BLOQUER_SOUMISSION
- VERIFIER
- AUTORISER

---

# 4. Liste REPONSES

Une ligne = une réponse.

## Volumétrie estimée

30 000 inspections

×

15 réponses moyennes

=

450 000 lignes+

Les index sont obligatoires.

## Colonnes

| Nom | Type SharePoint | Obligatoire | Index |
|------|------|------|------|
| Title | Single line text | Oui | Non |
| ReponseID | Single line text | Oui | Oui |
| InspectionGUID | Single line text | Oui | Oui |
| QuestionCode | Single line text | Oui | Oui |
| Valeur | Multiple line text | Non | Non |
| ValeurNumerique | Number | Non | Non |
| Commentaire | Multiple line text | Non | Non |
| DateEncodage | DateTime | Oui | Oui |
| UtilisateurEncodage | Person | Oui | Non |

## Règles de remplissage

Title = ReponseID (DEC-01)

ReponseID = GUID (DEC-03)

Valeur est une colonne Multiple line text en texte brut, pour supporter les textes longs (DEC-05). Elle n'est ni indexée ni utilisée comme critère de filtre.

Utilisation des colonnes de valeur selon TypeQuestion :

| TypeQuestion | Valeur | ValeurNumerique |
|------|------|------|
| RADIO, CHECKBOX | Valeur prise dans ValeursPossibles | Vide |
| TEXTE | Texte saisi | Vide |
| NUMERIQUE, CALCUL | Vide | Valeur numérique |
| PHOTO | PHOTO_CAPTURED (DEC-10) | Vide |
| SYSTEM (SYS_001) | Vide | Vide |

Questions PHOTO (POT_010, LUM_012) : une ligne REPONSES est créée avec Valeur = PHOTO_CAPTURED (DEC-10). Les photos elles-mêmes sont stockées dans PHOTOS_INSPECTIONS.

---

# 5. Bibliothèque PHOTOS_INSPECTIONS

Stockage physique.

## Structure recommandée

PHOTOS_INSPECTIONS

    2026/

        10/

            INS-20261008-000123/

                Photo001.jpg

                Photo002.jpg

---

## Métadonnées

| Nom | Type SharePoint | Obligatoire | Index |
|------|------|------|------|
| InspectionGUID | Single line text | Oui | Oui |
| QuestionCode | Single line text | Oui | Oui |
| NomOuvrage | Single line text | Oui | Oui |
| Auteur | Person | Oui | Non |
| DatePhoto | DateTime | Oui | Oui |
| CompressionVersion | Choice | Non | Non |

## Valeurs CompressionVersion

- ORIGINAL
- COMPRESSEE

---

# Points critiques

## Index obligatoires

INSPECTIONS

- InspectionID
- InspectionGUID
- NomOuvrage
- StatutInspection
- TypeInspection

REPONSES

- InspectionGUID
- QuestionCode
- DateEncodage

PHOTOS_INSPECTIONS

- InspectionGUID
- QuestionCode
- DatePhoto

---

## Cas particulier SYS_001

Question système :

SYS_001

Libellé :

Ouvrage inaccessible

Utilisée pour :

- commentaire obligatoire
- photo facultative

Permet de conserver la règle :

Photo ↔ Question

sans exception.

---

# Référence

Compatible avec :

- specification-fonctionnelle-v0.1.md
- architecture-globale-v0.1.md
- questions.csv
- regles_formulaire.csv

Version :

v0.1
