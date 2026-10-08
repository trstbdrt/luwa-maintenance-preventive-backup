# LUWA Maintenance Preventive Backup
## Rapport de construction SharePoint

Version : 0.1.5

Date : 2026-10-08

Site : `https://wavenetbe.sharepoint.com/sites/LuwaMaintenancePreventiveBackup`
(titre « Maintenance Préventive Backup », modèle GROUP, langue 1036 — français)

Exécuté par : Tristan Bodart (administrateur du site), via l'API REST SharePoint
depuis une session authentifiée du navigateur.

Source de vérité : `sharepoint/data-model/sharepoint-schema.md` (v0.1.4).
Catalogues : `sharepoint/questions/questions.csv`, `sharepoint/regles/regles_formulaire.csv` (gelés, non modifiés).

---

# 1. Listes créées

État initial constaté avant construction : les listes INSPECTIONS, QUESTIONS, REGLES_FORMULAIRE
et REPONSES **existaient déjà**, vides, avec la seule colonne native `Title`
(non obligatoire, non indexée). Elles ont été **réutilisées** et complétées, pas recréées.

| Liste | Modèle | Historique des versions | Pièces jointes | Title |
|------|------|------|------|------|
| INSPECTIONS | Liste (100) | Activé | Désactivées | Obligatoire, indexée |
| QUESTIONS | Liste (100) | Activé | Désactivées | Obligatoire |
| REGLES_FORMULAIRE | Liste (100) | Activé | Désactivées | Obligatoire |
| REPONSES | Liste (100) | Activé | Désactivées | Obligatoire |

Les autres bibliothèques présentes sur le site (01_Analyse à 05_Exports, Documents, etc.) n'ont pas été modifiées.

---

# 2. Bibliothèque créée

| Bibliothèque | Modèle | Historique des versions | Résultat |
|------|------|------|------|
| PHOTOS_INSPECTIONS | Bibliothèque de documents (101) | Activé | Créée (HTTP 201) |

La structure de dossiers `AAAA/MM/InspectionID/` n'est pas créée à l'avance :
elle sera créée par l'application (guide de construction § 2).

---

# 3. Colonnes créées

55 colonnes créées (toutes HTTP 200), avec un **nom interne identique** au schéma.
Les colonnes multilignes sont en texte brut ; les colonnes Choice n'acceptent pas de valeur de remplissage.

| Liste | Colonnes | Nombre |
|------|------|------|
| INSPECTIONS | InspectionID, InspectionGUID, TypeInspection, NomOuvrage, Inspecteur, DateCreation, DateDerniereModification, DateSoumission, StatutInspection, StatutTraitement (défaut NON_ANALYSE), GPSLatitude, GPSLongitude, InspectionPrecedenteGUID | 13 + Title |
| QUESTIONS | QuestionCode, QuestionParent, DisplayGroup, Formulaire, OrdreAffichage, Libelle, TypeQuestion, Obligatoire, CommentaireAutorise, CommentaireObligatoire, PhotoAutorisee, NbPhotosMin, NbPhotosMax, VisibleParDefaut, ValeursPossibles, FormuleCalcul | 16 + Title |
| REGLES_FORMULAIRE | RuleID, Priorite, Formulaire, QuestionSource, ConditionType, ConditionValeur, Action, QuestionCible, Parametre, Actif, Commentaire | 11 + Title |
| REPONSES | ReponseID, InspectionGUID, QuestionCode, Valeur (multiligne), ValeurNumerique, Commentaire, DateEncodage, UtilisateurEncodage | 8 + Title |
| PHOTOS_INSPECTIONS | InspectionGUID, QuestionCode, NomOuvrage, Auteur, DatePhoto, CompressionVersion | 6 |

## Vérification de la structure

La structure réelle (type, obligatoire, index, valeurs Choice, valeur par défaut) des 58 colonnes
(55 créées + 4 Title, hors Title de la bibliothèque) a été relue via l'API et comparée au schéma.

| Contrôle | Résultat |
|------|------|
| Colonnes manquantes | 0 |
| Nom affiché différent du nom interne | 0 |
| Colonne multiligne en texte enrichi | 0 |
| Types, obligatoire, index, valeurs Choice, valeur par défaut | Conformes au schéma, à l'exception documentée en section 7 (E1) |
| PHOTOS_INSPECTIONS : colonne `Auteur` | Nom interne `Auteur`, distinct de la colonne native `Author` (« Created By ») |

---

# 4. Index créés

22 index créés (tous HTTP 204) et relus via l'API.

| Liste | Index | Nombre |
|------|------|------|
| INSPECTIONS | Title, InspectionID, InspectionGUID, TypeInspection, NomOuvrage, StatutInspection, StatutTraitement | 7 |
| QUESTIONS | QuestionCode, QuestionParent, Formulaire | 3 |
| REGLES_FORMULAIRE | RuleID, Priorite, Formulaire, QuestionSource | 4 |
| REPONSES | ReponseID, InspectionGUID, QuestionCode, DateEncodage | 4 |
| PHOTOS_INSPECTIONS | InspectionGUID, QuestionCode, NomOuvrage, DatePhoto | 4 |

Index prioritaires vérifiés présents :

- INSPECTIONS : InspectionID, InspectionGUID, NomOuvrage, StatutInspection, TypeInspection
- REPONSES : InspectionGUID, QuestionCode, DateEncodage
- PHOTOS_INSPECTIONS : InspectionGUID, QuestionCode, DatePhoto

Les index ont été créés avant l'import des catalogues.

---

# 5. Import questions.csv

| Contrôle | Attendu | Constaté |
|------|------|------|
| Lignes envoyées / créées / en erreur | 34 / 34 / 0 | 34 / 34 / 0 |
| Éléments dans la liste | 34 | 34 |
| Title = QuestionCode (DEC-01) | 34 | 34 |
| QuestionCode en double | 0 | 0 |
| Formulaire | POTEAU 20, LUMINAIRE 13, SYSTEM 1 | POTEAU 20, LUMINAIRE 13, SYSTEM 1 |
| DisplayGroup | GENERAL 23, CORROSION 8, SUR_PONT 2, SYSTEM 1 | GENERAL 23, CORROSION 8, SUR_PONT 2, SYSTEM 1 |
| TypeQuestion | RADIO 22, CHECKBOX 4, PHOTO 2, TEXTE 2, NUMERIQUE 2, CALCUL 1, SYSTEM 1 | Identique |
| VisibleParDefaut = Oui / Non | 26 / 8 | 26 / 8 |
| Obligatoire = Oui | 30 | 30 |
| Valeurs Oui/Non vides | 0 | 0 |
| QuestionParent existants | Tous | Tous |
| **Contenu intégral** (16 colonnes + Title, 34 lignes) | Empreinte SHA-256 du CSV `fe361665…df8be6` | **Identique** |

## Question système SYS_001

| Champ | Valeur dans SharePoint |
|------|------|
| QuestionCode / Title | SYS_001 / SYS_001 |
| Libelle | Ouvrage inaccessible |
| Formulaire / DisplayGroup / TypeQuestion | SYSTEM / SYSTEM / SYSTEM |
| Obligatoire | Non |
| CommentaireObligatoire | Oui |
| NbPhotosMax | 10 |
| VisibleParDefaut | Oui (conforme au catalogue gelé ; voir OQ-08) |

---

# 6. Import regles_formulaire.csv

| Contrôle | Attendu | Constaté |
|------|------|------|
| Lignes envoyées / créées / en erreur | 29 / 29 / 0 | 29 / 29 / 0 |
| Éléments dans la liste | 29 | 29 |
| Formulaire | POTEAU 20, ALL 5, LUMINAIRE 2, SYSTEM 2 | Identique |
| Actif = Oui | 29 | 29 |
| Références QuestionSource / QuestionCible (hors `FORMULAIRE` et `*`) existantes et du bon formulaire | 0 anomalie | 0 anomalie |
| **Contenu intégral** (11 colonnes + Title, 29 lignes) | Empreinte SHA-256 du CSV `3028f4e8…585fc66` | **Identique** |

La comparaison par empreinte garantit que chaque valeur importée (y compris ValeursPossibles,
FormuleCalcul, ConditionValeur `30` / `0`, Parametre et Commentaire) est strictement identique aux CSV.

---

# 7. Erreurs rencontrées

## Erreurs d'exécution

Aucune. Toutes les requêtes de création, de modification et d'import ont réussi
(201, 200 ou 204). Aucune donnée n'a été supprimée.

## Écarts constatés

| ID | Constat | Impact | Traitement |
|------|------|------|------|
| E1 | `sharepoint-schema.md` déclare `TypeInspection` en Choice **sans section « Valeurs TypeInspection »**. Les valeurs créées (`POTEAU`, `LUMINAIRE`) proviennent de la spécification (§ 6), de `powerapps/screens.md` et du guide de construction (§ 3.1) | Aucun sur le site ; lacune documentaire du schéma | À ajouter au schéma dans une prochaine version (non modifié ici : aucune documentation de conception dans ce sprint) |
| E2 | Les colonnes Oui/Non (Obligatoire, CommentaireAutorise, CommentaireObligatoire, PhotoAutorisee, VisibleParDefaut, Actif) sont marquées « Obligatoire : Oui » dans le schéma, mais SharePoint ne propose pas cette option sur ce type | Aucun : 0 valeur vide après import | Limite connue, déjà décrite dans le guide de construction (§ 3.2) |
| E3 | Les 4 listes existaient avant le sprint (créées manuellement), avec Title non obligatoire et pièces jointes activées | Aucun après correction | Title rendu obligatoire, pièces jointes désactivées |

## Non réalisé dans ce sprint

| Élément | Raison |
|------|------|
| Permissions (checklist SharePoint, étape 6 ; guide § 10) | Hors périmètre des tâches 1 à 5 ; modifie les droits du site (groupe Microsoft 365) : nécessite une décision explicite |
| Tests d'écriture (`powerapps-readiness.md` § 3.2) | Prévus sur un **site de test** ; en production, les éléments de test ne pourraient pas être supprimés (D007) |

---

# 8. Résultat

| Périmètre | Verdict |
|------|------|
| Construction SharePoint (listes, bibliothèque, colonnes, index, catalogues) | **CONFORME** |
| Démarrage Power Apps | **NOT READY** |

## Blocages restants pour le démarrage Power Apps

Selon `docs/build/powerapps-readiness.md`, l'ouverture de Power Apps exige :

1. **Permissions** (§ 2.4) : niveau « Contribution sans suppression » pour les techniciens
   sur INSPECTIONS, REPONSES, PHOTOS_INSPECTIONS ; lecture seule sur QUESTIONS et REGLES_FORMULAIRE.
   **Non configurées.**
2. **Tests d'écriture SharePoint** (§ 3.2) : création d'une inspection (défaut NON_ANALYSE),
   d'une réponse de plus de 255 caractères, d'une réponse PHOTO_CAPTURED, dépôt d'une photo avec métadonnées.
   **Non exécutés** : un site de test est nécessaire.
3. **Contrôles d'environnement** (§ 4) : environnement Power Platform, licences, stratégies DLP, comptes de test.
   **Non vérifiés.**

Dès que ces trois points sont levés, le verdict passe à **READY**.
La structure et les catalogues SharePoint ne nécessitent aucune action supplémentaire.
