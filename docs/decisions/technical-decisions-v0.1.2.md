# LUWA Maintenance Preventive Backup
## Décisions techniques v0.1.2

Version : 0.1.2 (figées en v0.1.3)

Date : 2026-10-08

Statut : Validées

Origine : Sprint 0 du backlog (`docs/backlog/build-backlog-v0.1.md`, éléments DEC-01 à DEC-10),
issus du rapport `docs/reviews/repository-consistency-report.md`.

Ces décisions sont **techniques**. Elles n'introduisent aucune nouvelle règle métier
et ne modifient ni `questions.csv`, ni `regles_formulaire.csv`, ni la spécification fonctionnelle.

Application : `sharepoint/data-model/sharepoint-schema.md` (v0.1.3).

---

# Synthèse

| ID | Sujet | Décision | Appliquée dans le schéma |
|------|------|------|------|
| DEC-01 | Colonne Title SharePoint | Title = clé de la ligne dans chaque liste | Oui |
| DEC-02 | StatutTraitement initial | NON_ANALYSE | Oui |
| DEC-03 | Clés techniques | InspectionGUID = clé principale ; InspectionID = affichage ; ReponseID = GUID | Oui |
| DEC-04 | InspectionPrecedenteGUID | Lien vers la dernière inspection INACCESSIBLE (« Accessible maintenant ») | Oui |
| DEC-05 | REPONSES.Valeur | Multiple lines of text | Oui |
| DEC-06 | PHOTO_MIN | La règle active remplace NbPhotosMin du catalogue | Oui |
| DEC-07 | Paramètres de compression | Liste des paramètres figée ; stockage à définir ultérieurement | Non (hors périmètre v0.1.3) |
| DEC-08 | Avertissement de concurrence | BROUILLON et EN_COURS du même type d'inspection | Non (comportement applicatif) |
| DEC-09 | Reprendre inspection | Inspections de l'utilisateur courant uniquement (v0.1) | Non (comportement applicatif) |
| DEC-10 | Questions PHOTO | Une ligne REPONSES avec Valeur = PHOTO_CAPTURED | Oui |

---

# DEC-01 — Title SharePoint

## Contexte

Chaque liste SharePoint possède une colonne native `Title`, obligatoire par défaut.
Le schéma v0.1.1 ne la définissait que pour INSPECTIONS.

## Décision

| Liste | Title |
|------|------|
| INSPECTIONS | InspectionID |
| QUESTIONS | QuestionCode |
| REGLES_FORMULAIRE | RuleID |
| REPONSES | ReponseID |

Title reste obligatoire dans les quatre listes.

## Conséquences

- Lors de l'import de `questions.csv` et de `regles_formulaire.csv`, la colonne Title est
  renseignée à partir de QuestionCode et de RuleID (guide de construction § 7 et § 8).
- Les fichiers sources `questions.csv` et `regles_formulaire.csv` ne sont pas modifiés.

---

# DEC-02 — StatutTraitement initial

## Décision

À la création d'une inspection, `StatutTraitement = NON_ANALYSE`.

## Conséquences

- La colonne Choice StatutTraitement a pour valeur par défaut NON_ANALYSE.
- App 1 n'écrit jamais d'autre valeur (App 1 ne prend aucune décision métier).
- Les autres valeurs (ANALYSE_EN_COURS, VALIDE, ACTION_REQUISE, CLOTURE) sont réservées à App 2.

---

# DEC-03 — Clés techniques

## Décision

| Clé | Rôle |
|------|------|
| InspectionGUID | Clé principale de l'inspection et clé relationnelle unique |
| InspectionID | Identifiant lisible, affichage uniquement |
| ReponseID | GUID |

## Conséquences

- REPONSES, PHOTOS_INSPECTIONS et InspectionPrecedenteGUID référencent uniquement InspectionGUID.
- Aucune relation ne repose sur InspectionID ; un éventuel doublon d'InspectionID
  n'altère pas l'intégrité des données.
- Le mécanisme de génération du compteur `NNNNNN` de l'InspectionID n'est pas fixé par cette décision
  (voir `docs/reviews/build-readiness-v0.1.3.md`, points ouverts).

---

# DEC-04 — InspectionPrecedenteGUID

## Décision

Interprétation retenue :
`InspectionPrecedenteGUID` contient l'InspectionGUID de la **dernière inspection INACCESSIBLE**
de l'ouvrage lorsqu'un utilisateur sélectionne **« Accessible maintenant »**.

## Conséquences

- Colonne vide dans tous les autres cas.
- L'inspection INACCESSIBLE précédente n'est jamais modifiée (architecture § 9).

---

# DEC-05 — REPONSES.Valeur

## Décision

Dans le modèle, le type de `REPONSES.Valeur` passe de **Single line text** à **Multiple lines of text**.

## Motif

Support des commentaires longs : les réponses de type TEXTE (LUM_013, POT_011 « Commentaires generaux »)
peuvent dépasser la limite de 255 caractères d'une colonne Single line text.

## Conséquences

- Colonne créée en texte brut (pas de texte enrichi).
- Une colonne Multiple lines of text ne peut pas être indexée ni utilisée dans un filtre délégable :
  Valeur n'est donc jamais un critère de recherche. Les recherches se font sur InspectionGUID et QuestionCode (indexés).

---

# DEC-06 — PHOTO_MIN

## Décision

Lorsqu'une règle PHOTO_MIN est active, sa valeur (`Parametre`) **remplace** la valeur `NbPhotosMin`
du catalogue QUESTIONS pour la question cible.

« Active » s'entend : règle `Actif = Oui` **et** condition de la règle vérifiée.

## Conséquences

| Question | NbPhotosMin catalogue | Règle | Minimum appliqué |
|------|------|------|------|
| POT_002 = VALIDE | 0 | R200 (1) | 1 |
| POT_002 = A_REFAIRE | 0 | R201 (1) | 1 |
| POT_002 = FAIT | 0 | R202 (2) | 2 |
| POT_005 à POT_008 = NON_VALIDE | 0 | R300 à R303 (1) | 1 |
| POT_005 à POT_008, autre valeur | 0 | aucune | 0 |
| POT_004_5 visible | 1 | R140 (1) | 1 |

Sans règle active, `NbPhotosMin` du catalogue s'applique.

---

# DEC-07 — Paramètres de compression

## Décision

Paramètres de configuration futurs :

- CompressionEnabled
- CompressionThreshold
- CompressionQuality
- MaxResolution

Le stockage de ces paramètres sera défini dans une version future.

## Conséquences

- Aucune liste de configuration n'est créée en v0.1.3.
- La règle validée reste applicable : la compression n'est pas systématique (architecture § 13).
- La métadonnée `CompressionVersion` (ORIGINAL / COMPRESSEE) de PHOTOS_INSPECTIONS est inchangée.

---

# DEC-08 — Avertissement de concurrence

## Décision

L'avertissement « Une inspection est actuellement en cours sur cet ouvrage. » s'applique uniquement
aux inspections du **même ouvrage**, du **même type d'inspection**, dont le statut est :

- BROUILLON
- EN_COURS

## Conséquences

- Aucun blocage (décision D006, spécification § 9).
- Une inspection POTEAU en cours ne déclenche pas d'avertissement sur une inspection LUMINAIRE du même ouvrage.

---

# DEC-09 — Reprendre inspection

## Décision

Dans la v0.1, la fonction « Reprendre inspection » liste **uniquement les inspections de l'utilisateur courant**
(Inspecteur = utilisateur connecté) au statut BROUILLON ou EN_COURS.

---

# DEC-10 — Questions PHOTO

## Décision

Pour une question de type PHOTO, une ligne REPONSES est créée avec :

- `Valeur = PHOTO_CAPTURED`

Exemples : POT_010, LUM_012.

## Conséquences

- La ligne est créée lorsque au moins une photo est enregistrée pour la question.
- La complétude d'une question PHOTO reste mesurée par le nombre de photos
  (NbPhotosMin ou PHOTO_MIN selon DEC-06).
- `PHOTO_CAPTURED` est une valeur technique : elle ne figure pas dans `ValeursPossibles`
  (les questions PHOTO n'en ont pas) et `questions.csv` n'est pas modifié.
- La question système SYS_001 (TypeQuestion = SYSTEM) n'est pas concernée.
