# LUWA Maintenance Preventive Backup
## SharePoint Schema v0.1

Version : 0.1

Date : 2026-10-08

Statut : Validé

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

Title = InspectionID

InspectionGUID est la clé relationnelle unique.

Toutes les relations (REPONSES, PHOTOS_INSPECTIONS, InspectionPrecedenteGUID) utilisent InspectionGUID.

InspectionID est un identifiant lisible, utilisé uniquement pour l'affichage.

Le commentaire d'inaccessibilité est stocké dans REPONSES sur la question SYS_001.

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
| ReponseID | Single line text | Oui | Oui |
| InspectionGUID | Single line text | Oui | Oui |
| QuestionCode | Single line text | Oui | Oui |
| Valeur | Single line text | Non | Non |
| ValeurNumerique | Number | Non | Non |
| Commentaire | Multiple line text | Non | Non |
| DateEncodage | DateTime | Oui | Oui |
| UtilisateurEncodage | Person | Oui | Non |

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
