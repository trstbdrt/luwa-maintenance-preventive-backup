# LUWA Maintenance Preventive Backup
## Guide de construction SharePoint v0.1.3

Version : 0.1.3

Date : 2026-10-08

Public : administrateur SharePoint

Référence : `sharepoint/data-model/sharepoint-schema.md` (v0.1.3) et `docs/decisions/technical-decisions-v0.1.2.md`

---

# 0. Prérequis et principes

## Prérequis

- Un site SharePoint Online dédié (site d'équipe ou de communication).
- Droits **Propriétaire** du site.
- Les fichiers du dépôt à la version `v0.1.1` ou ultérieure :
  - `sharepoint/questions/questions.csv`
  - `sharepoint/regles/regles_formulaire.csv`
- Microsoft Excel (pour la préparation des imports).

## Principes à respecter

1. **Nom interne des colonnes**
   Le nom interne d'une colonne SharePoint est fixé à sa création et ne peut plus être modifié.
   Créer chaque colonne **avec exactement le nom indiqué** (sans espace, sans accent),
   puis, si souhaité, renommer uniquement le nom d'affichage.
   Power Apps et Power Automate utilisent ces noms.

2. **Index avant volumétrie**
   Créer les index **immédiatement après** la création des colonnes, avant tout import
   et avant toute mise en production. Au-delà de 5 000 éléments, les requêtes non indexées
   sont bloquées et la création d'index devient difficile.

3. **Texte multiligne**
   Toutes les colonnes « Multiple line text » sont créées en **texte brut** (pas de texte enrichi),
   afin que `ValeursPossibles`, `FormuleCalcul` et les commentaires ne contiennent pas de balises HTML.

4. **Aucune suppression**
   Conformément à la spécification (section 19) et à la décision D007,
   aucun élément n'est supprimé. Voir section 10 (permissions).

---

# 1. Création des listes

Pour chaque liste : **Site > Nouveau > Liste > Liste vide**.

| Liste | Nom à saisir | Description suggérée |
|------|------|------|
| INSPECTIONS | `INSPECTIONS` | Une ligne = une inspection |
| QUESTIONS | `QUESTIONS` | Catalogue de configuration des questions |
| REGLES_FORMULAIRE | `REGLES_FORMULAIRE` | Catalogue des règles dynamiques |
| REPONSES | `REPONSES` | Une ligne = une réponse |

Paramètres de chaque liste (**Paramètres de la liste**) :

- Contrôle de version : activer l'historique des versions.
- Pièces jointes : désactiver (les photos sont stockées dans PHOTOS_INSPECTIONS).

## Colonne Title

Chaque liste SharePoint possède une colonne native `Title`.

| Liste | Utilisation de Title |
|------|------|
| INSPECTIONS | **Title = InspectionID**, obligatoire, indexée |
| QUESTIONS | **Title = QuestionCode**, obligatoire |
| REGLES_FORMULAIRE | **Title = RuleID**, obligatoire |
| REPONSES | **Title = ReponseID**, obligatoire |

Décision DEC-01. La colonne Title reste obligatoire dans les quatre listes.

---

# 2. Création de la bibliothèque PHOTOS_INSPECTIONS

**Site > Nouveau > Bibliothèque de documents**

- Nom : `PHOTOS_INSPECTIONS`
- Contrôle de version : activé.

## Structure de dossiers

Structure définie par le schéma (DEC-15) :

```
PHOTOS_INSPECTIONS
    550e8400-e29b-41d4-a716-446655440000/
        Photo001.jpg
        Photo002.jpg
```

- Un dossier par inspection, à la racine de la bibliothèque, nommé par son **InspectionGUID**
- Jamais par InspectionID ; aucun renommage lors de l'attribution de l'InspectionID final

Les dossiers sont créés par l'application ou par Power Automate lors de l'enregistrement des photos.
Ils ne sont pas créés à la main.

La relation photo ↔ inspection repose sur la métadonnée `InspectionGUID`, **jamais** sur le nom du dossier.

## Métadonnées

Voir section 3.5.

---

# 3. Colonnes

Pour chaque colonne : **Paramètres de la liste > Créer une colonne**.

Légende : **Obl.** = « Exiger que cette colonne contienne des informations ».

## 3.1 INSPECTIONS

| Nom (interne) | Type SharePoint | Obl. | Index | Paramètres |
|------|------|------|------|------|
| Title | Single line text (native) | Oui | Oui | Contient InspectionID |
| InspectionID | Single line text | Oui | Oui | |
| InspectionGUID | Single line text | Oui | Oui | |
| TypeInspection | Choice | Oui | Oui | Valeurs : POTEAU, LUMINAIRE |
| NomOuvrage | Single line text | Oui | Oui | |
| Inspecteur | Person | Oui | Non | Personnes uniquement |
| DateCreation | DateTime | Oui | Non | Date et heure |
| DateDerniereModification | DateTime | Oui | Non | Date et heure |
| DateSoumission | DateTime | Non | Non | Date et heure |
| StatutInspection | Choice | Oui | Oui | Valeurs : BROUILLON, EN_COURS, TERMINE, INACCESSIBLE, ARCHIVE |
| StatutTraitement | Choice | Oui | Oui | Valeurs : NON_ANALYSE, ANALYSE_EN_COURS, VALIDE, ACTION_REQUISE, CLOTURE ; **valeur par défaut : NON_ANALYSE** (DEC-02) |
| GPSLatitude | Number | Non | Non | Décimales : 6 |
| GPSLongitude | Number | Non | Non | Décimales : 6 |
| InspectionPrecedenteGUID | Single line text | Non | Non | |

## 3.2 QUESTIONS

| Nom (interne) | Type SharePoint | Obl. | Index | Paramètres |
|------|------|------|------|------|
| Title | Single line text (native) | Oui | Non | Contient QuestionCode |
| QuestionCode | Single line text | Oui | Oui | |
| QuestionParent | Single line text | Non | Oui | |
| DisplayGroup | Choice | Oui | Non | Valeurs : GENERAL, CORROSION, SUR_PONT, SYSTEM |
| Formulaire | Choice | Oui | Oui | Valeurs : POTEAU, LUMINAIRE, SYSTEM |
| OrdreAffichage | Number | Oui | Non | Décimales : 0 |
| Libelle | Single line text | Oui | Non | |
| TypeQuestion | Choice | Oui | Non | Valeurs : RADIO, CHECKBOX, NUMERIQUE, PHOTO, TEXTE, CALCUL, SYSTEM |
| Obligatoire | Yes/No | Oui | Non | |
| CommentaireAutorise | Yes/No | Oui | Non | |
| CommentaireObligatoire | Yes/No | Oui | Non | |
| PhotoAutorisee | Yes/No | Oui | Non | |
| NbPhotosMin | Number | Oui | Non | Décimales : 0 |
| NbPhotosMax | Number | Oui | Non | Décimales : 0 |
| VisibleParDefaut | Yes/No | Oui | Non | |
| ValeursPossibles | Multiple line text | Non | Non | Texte brut |
| FormuleCalcul | Multiple line text | Non | Non | Texte brut |

Note : SharePoint ne propose pas l'option « Obligatoire » sur une colonne Yes/No ;
la colonne a toujours une valeur (Oui ou Non).

## 3.3 REGLES_FORMULAIRE

| Nom (interne) | Type SharePoint | Obl. | Index | Paramètres |
|------|------|------|------|------|
| Title | Single line text (native) | Oui | Non | Contient RuleID |
| RuleID | Single line text | Oui | Oui | |
| Priorite | Number | Oui | Oui | Décimales : 0 |
| Formulaire | Choice | Oui | Oui | Valeurs : POTEAU, LUMINAIRE, SYSTEM, ALL |
| QuestionSource | Single line text | Oui | Oui | Contient un QuestionCode ou `FORMULAIRE` |
| ConditionType | Choice | Oui | Non | Valeurs : EQUALS, GREATER_OR_EQUAL, LESS_THAN, VISIBLE, VALIDATION, SAVE, PRESENCE |
| ConditionValeur | Single line text | Oui | Non | |
| Action | Choice | Oui | Non | Valeurs : AFFICHER, AFFICHER_IF_MATCH, WAITING_SECOND_CONDITION, MASQUER_FORMULAIRE, PHOTO_MIN, RENDRE_OBLIGATOIRE, OBLIGATOIRE, COMMENT_OBLIGATOIRE, BLOQUER_CALCUL, BLOQUER_SOUMISSION, VERIFIER, AUTORISER |
| QuestionCible | Single line text | Oui | Non | Contient un QuestionCode ou `*` |
| Parametre | Single line text | Non | Non | |
| Actif | Yes/No | Oui | Non | |
| Commentaire | Multiple line text | Non | Non | Texte brut |

## 3.4 REPONSES

| Nom (interne) | Type SharePoint | Obl. | Index | Paramètres |
|------|------|------|------|------|
| Title | Single line text (native) | Oui | Non | Contient ReponseID |
| ReponseID | Single line text | Oui | Oui | GUID (DEC-03) |
| InspectionGUID | Single line text | Oui | Oui | |
| QuestionCode | Single line text | Oui | Oui | |
| Valeur | Multiple line text | Non | Non | Texte brut (DEC-05) ; PHOTO_CAPTURED pour les questions PHOTO (DEC-10) |
| ValeurNumerique | Number | Non | Non | Décimales : automatique |
| Commentaire | Multiple line text | Non | Non | Texte brut |
| DateEncodage | DateTime | Oui | Oui | Date et heure |
| UtilisateurEncodage | Person | Oui | Non | Personnes uniquement |

## 3.5 PHOTOS_INSPECTIONS (métadonnées)

**Paramètres de la bibliothèque > Créer une colonne**

| Nom (interne) | Type SharePoint | Obl. | Index | Paramètres |
|------|------|------|------|------|
| InspectionGUID | Single line text | Oui | Oui | |
| QuestionCode | Single line text | Oui | Oui | |
| NomOuvrage | Single line text | Oui | Oui | |
| Auteur | Person | Oui | Non | Personnes uniquement |
| DatePhoto | DateTime | Oui | Oui | Date et heure |
| CompressionVersion | Choice | Non | Non | Valeurs : ORIGINAL, COMPRESSEE |

Attention : sur un site en français, la colonne native « Créé par » peut s'afficher
sous un nom proche de « Auteur ». Après création, vérifier que le **nom interne**
de la nouvelle colonne est bien `Auteur` et qu'il n'y a pas de doublon d'affichage.

---

# 4. Types

Correspondance entre les types du schéma et l'interface SharePoint (FR) :

| Type du schéma | Interface SharePoint (FR) | Remarques |
|------|------|------|
| Single line text | Une ligne de texte | 255 caractères maximum |
| Multiple line text | Plusieurs lignes de texte | Texte brut, pas d'ajout illimité de modifications |
| Choice | Choix | Liste déroulante, **sans** « Autoriser les valeurs de remplissage », sans valeur par défaut sauf mention contraire |
| Number | Nombre | |
| Yes/No | Oui/Non | |
| DateTime | Date et heure | Format « Date et heure » |
| Person | Personne ou groupe | « Personnes uniquement », sélection unique |

Les valeurs des colonnes Choice doivent être saisies **exactement** comme dans le schéma
(majuscules, underscore, sans accent), une valeur par ligne.

---

# 5. Index SharePoint obligatoires

**Paramètres de la liste > Colonnes indexées > Créer un nouvel index**

| Liste / bibliothèque | Colonnes à indexer |
|------|------|
| INSPECTIONS | Title, InspectionID, InspectionGUID, TypeInspection, NomOuvrage, StatutInspection, StatutTraitement |
| QUESTIONS | QuestionCode, QuestionParent, Formulaire |
| REGLES_FORMULAIRE | RuleID, Priorite, Formulaire, QuestionSource |
| REPONSES | ReponseID, InspectionGUID, QuestionCode, DateEncodage |
| PHOTOS_INSPECTIONS | InspectionGUID, QuestionCode, NomOuvrage, DatePhoto |

Index critiques identifiés dans la section « Points critiques » du schéma :

- INSPECTIONS : InspectionID, InspectionGUID, NomOuvrage, StatutInspection, TypeInspection
- REPONSES : InspectionGUID, QuestionCode, DateEncodage
- PHOTOS_INSPECTIONS : InspectionGUID, QuestionCode, DatePhoto

Vérifier ensuite que le nombre d'index par liste reste inférieur à 20 (limite SharePoint).

---

# 6. Ordre recommandé de création

| Étape | Action | Raison |
|------|------|------|
| 1 | Créer la liste QUESTIONS, ses colonnes et ses index | Catalogue de référence des autres listes |
| 2 | Importer `questions.csv` (section 7) et contrôler (section 9) | Doit exister avant les règles |
| 3 | Créer la liste REGLES_FORMULAIRE, ses colonnes et ses index | Référence les QuestionCode |
| 4 | Importer `regles_formulaire.csv` (section 8) et contrôler (section 9) | |
| 5 | Créer la liste INSPECTIONS, ses colonnes et ses index | |
| 6 | Créer la liste REPONSES, ses colonnes et ses index | Référence InspectionGUID et QuestionCode |
| 7 | Créer la bibliothèque PHOTOS_INSPECTIONS, ses colonnes et ses index | Référence InspectionGUID et QuestionCode |
| 8 | Appliquer les permissions (section 10) | |
| 9 | Optionnel : import d'essai des fichiers `sharepoint/data-model/*.csv` dans un site de test, puis contrôle | Ne jamais importer ces exemples en production |

---

# 7. Procédure d'import de questions.csv

Fichier source : `sharepoint/questions/questions.csv` (34 lignes, 16 colonnes, UTF-8, séparateur virgule).

## 7.1 Préparation dans Excel

1. Ouvrir Excel > **Données > À partir d'un fichier texte/CSV**.
2. Sélectionner `questions.csv`, origine **65001 : Unicode (UTF-8)**, délimiteur **virgule**.
3. Cliquer **Transformer les données** et forcer **toutes les colonnes en type Texte**
   (évite la conversion de `OrdreAffichage`, des codes ou des formules).
4. Charger dans une feuille.
5. Convertir les colonnes OUI/NON pour le type Oui/Non de SharePoint :
   colonnes `Obligatoire`, `CommentaireAutorise`, `CommentaireObligatoire`,
   `PhotoAutorisee`, `VisibleParDefaut`.
   - `OUI` → valeur Oui de SharePoint
   - `NON` → valeur Non de SharePoint
   La valeur exacte à coller dépend de la langue du site (par exemple `Oui`/`Non` ou `Yes`/`No`) :
   tester d'abord sur une ligne.
6. Conserver tel quel le contenu de `ValeursPossibles` (séparateur `|`) et de `FormuleCalcul`.
7. Ajouter une colonne `Title` égale à `QuestionCode` (DEC-01).

## 7.2 Import

1. Ouvrir la liste QUESTIONS > **Modifier en mode grille**.
2. Vérifier que l'ordre des colonnes de la vue correspond à celui de la feuille Excel
   (créer au besoin une vue dédiée « Import » avec les colonnes dans l'ordre du CSV).
3. Copier les lignes de données depuis Excel (sans l'en-tête) et coller dans la première ligne vide.
4. Attendre l'enregistrement de toutes les lignes, puis **Quitter le mode grille**.

Alternative pour de gros volumes : flux Power Automate lisant le fichier et créant les éléments.
Ce flux n'est pas nécessaire pour 34 lignes.

---

# 8. Procédure d'import de regles_formulaire.csv

Fichier source : `sharepoint/regles/regles_formulaire.csv` (29 lignes, 11 colonnes, UTF-8, séparateur virgule).

Prérequis : QUESTIONS importée et contrôlée.

1. Même préparation Excel qu'en 7.1, toutes colonnes en type Texte.
2. Convertir la colonne `Actif` (OUI/NON) en valeur Oui/Non de SharePoint.
3. Conserver tels quels :
   - `QuestionSource` = `FORMULAIRE` (règles R500 à R600) ;
   - `QuestionCible` = `*` (règles R002, R151, R500 à R600) ;
   - `ConditionValeur` numériques (`30`, `0`) en texte.
4. Ajouter une colonne `Title` égale à `RuleID` (DEC-01).
5. Importer en mode grille, comme en 7.2.

---

# 9. Contrôles post-import

## 9.1 QUESTIONS

| Contrôle | Résultat attendu |
|------|------|
| Nombre total d'éléments | 34 |
| Formulaire = POTEAU | 20 |
| Formulaire = LUMINAIRE | 13 |
| Formulaire = SYSTEM | 1 (SYS_001) |
| QuestionCode en double | 0 |
| Obligatoire = Oui | 30 |
| VisibleParDefaut = Non | 8 |
| CommentaireObligatoire = Oui | 1 (SYS_001) |
| PhotoAutorisee = Non | 5 |
| QuestionParent renseigné | 8 |
| ValeursPossibles renseigné | 26 |
| FormuleCalcul renseigné | 1 (POT_004_2_C) |
| DisplayGroup | GENERAL 23, CORROSION 8, SUR_PONT 2, SYSTEM 1 |
| TypeQuestion | RADIO 22, CHECKBOX 4, PHOTO 2, TEXTE 2, NUMERIQUE 2, CALCUL 1, SYSTEM 1 |
| FormuleCalcul de POT_004_2_C | `((POT_004_2_A-POT_004_2_B)/POT_004_2_A)*100` (sans balise HTML) |

## 9.2 REGLES_FORMULAIRE

| Contrôle | Résultat attendu |
|------|------|
| Nombre total d'éléments | 29 |
| Formulaire | POTEAU 20, ALL 5, LUMINAIRE 2, SYSTEM 2 |
| Actif = Oui | 29 |
| RuleID en double | 0 |
| Action | PHOTO_MIN 8, AFFICHER 7, VERIFIER 3, BLOQUER_SOUMISSION 2, AUTORISER 2, et 1 pour chacune des autres |
| ConditionType | EQUALS 19, VALIDATION 4, PRESENCE 2, GREATER_OR_EQUAL 1, LESS_THAN 1, VISIBLE 1, SAVE 1 |
| Parametre renseigné | 8 (R140, R200, R201, R202, R300, R301, R302, R303) |
| R120 | ConditionType = GREATER_OR_EQUAL, ConditionValeur = 30 |
| R600 | Action = AUTORISER |

## 9.3 Cohérence croisée

Pour chaque règle dont `QuestionSource` ou `QuestionCible` n'est ni `FORMULAIRE` ni `*` :
le code doit exister dans QUESTIONS.

Vue de contrôle conseillée : filtrer REGLES_FORMULAIRE par Formulaire, trier par Priorite,
et vérifier visuellement les codes contre QUESTIONS.

## 9.4 Structure des listes vides

| Contrôle | Résultat attendu |
|------|------|
| INSPECTIONS, REPONSES, PHOTOS_INSPECTIONS | Colonnes et index conformes aux sections 3 et 5 |
| Noms internes | Identiques aux noms du schéma (vérifier dans l'URL des paramètres de colonne : `Field=<NomInterne>`) |
| Colonnes Choice | Valeurs identiques au schéma, sans valeur de remplissage |

---

# 10. Permissions

Exigence fonctionnelle : aucune suppression (spécification section 19, décision D007).

Recommandation technique :

- créer un niveau d'autorisation personnalisé « Contribution sans suppression »
  (copie de « Collaboration » sans « Supprimer des éléments » ni « Supprimer des versions ») ;
- l'attribuer aux techniciens sur INSPECTIONS, REPONSES et PHOTOS_INSPECTIONS ;
- donner aux techniciens un accès **Lecture** seule sur QUESTIONS et REGLES_FORMULAIRE ;
- réserver la modification des catalogues aux administrateurs fonctionnels.
