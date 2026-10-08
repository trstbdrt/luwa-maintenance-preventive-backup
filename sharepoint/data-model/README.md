# Fichiers de données modèles — SharePoint

Version : 0.1.2

Date : 2026-10-08

---

# Objet

Ce dossier contient des **exemples de données fictives** illustrant le contenu attendu
de chaque liste SharePoint décrite dans `sharepoint-schema.md`.

Ces fichiers servent à :

- comprendre le modèle de données ;
- tester la construction SharePoint (import d'essai) ;
- tester les écrans Power Apps avec un jeu de données cohérent ;
- tester les futurs exports.

---

# Règles

- La **source de vérité** des colonnes est `sharepoint-schema.md`.
- La **source de vérité** du catalogue de questions est `sharepoint/questions/questions.csv`.
- La **source de vérité** des règles est `sharepoint/regles/regles_formulaire.csv`.
- **Aucune donnée réelle** : ouvrages, utilisateurs, GUID, dates et coordonnées sont fictifs.
  - Les noms d'ouvrage reprennent les exemples de format de la spécification (section 7).
  - Les utilisateurs utilisent le domaine réservé `example.com`.
- Encodage : UTF-8, caractères ASCII uniquement, séparateur virgule.
- Dates : ISO 8601 UTC (`AAAA-MM-JJTHH:MM:SSZ`).
- Colonnes Person : représentées par l'adresse e-mail de l'utilisateur.

---

# Scénario couvert par les exemples

| InspectionID | Type | Ouvrage | Statut | Illustre |
|------|------|------|------|------|
| INS-20261008-000001 | POTEAU | E100 511 | TERMINE | Inspection complète et soumissible : corrosion AVANCEE, calcul de perte d'épaisseur (25 %), affichage de POT_004_5 (R130 + R131), photos obligatoires atteintes |
| INS-20261008-000002 | LUMINAIRE | E100 511-1 | EN_COURS | Inspection partiellement complétée (3 réponses) |
| INS-20261008-000003 | POTEAU | K024 318-2 | INACCESSIBLE | Ouvrage inaccessible : commentaire et photo rattachés à SYS_001 |
| INS-20261009-000004 | POTEAU | K024 318-2 | BROUILLON | Nouvelle inspection après "Accessible maintenant", aucune réponse encodée |

Contrôle de l'inspection INS-20261008-000001 au regard des règles :

| Question | Réponse | Photos | Règle / exigence |
|------|------|------|------|
| POT_001 | VALIDE | 1 | NbPhotosMin = 1 |
| POT_002 | VALIDE | 1 | R200 : 1 photo si VALIDE |
| POT_003 | VALIDE | 1 | NbPhotosMin = 1 |
| POT_004 | AVANCEE | 0 | R100 à R103 : affichage de POT_004_1 et POT_004_2_A/B/C |
| POT_004_1 | OUI | 0 | Condition R130 |
| POT_004_2_A / B | 6 / 4.5 | 0 | Numériques |
| POT_004_2_C | 25 | 0 | ((6 - 4.5) / 6) × 100 = 25 ; < 30 donc R131 vraie, R120 fausse (POT_004_3 masquée) |
| POT_004_5 | FAIT | 1 | Affichée par R130 + R131 ; NbPhotosMin = 1 et R140 |
| POT_010 | (photo) | 2 | NbPhotosMin = 2 |
| POT_010B | NON | 0 | R400 / R401 non déclenchées (POT_010B_A masquée) |

---

# inspections.csv

Exemple de contenu de la liste **INSPECTIONS**.

| Colonne | Commentaire |
|------|------|
| Title | Toujours égal à InspectionID (règle de remplissage du schéma) |
| InspectionID | Identifiant lisible `INS-AAAAMMJJ-NNNNNN`, affichage uniquement |
| InspectionGUID | Clé relationnelle unique (format GUID) |
| TypeInspection | POTEAU ou LUMINAIRE |
| NomOuvrage | Encodé manuellement, sans validation patrimoine (POC) |
| Inspecteur | Utilisateur ayant créé l'inspection |
| DateCreation | Création de l'inspection (statut BROUILLON) |
| DateDerniereModification | Dernière sauvegarde |
| DateSoumission | Renseignée uniquement à la soumission (TERMINE) |
| StatutInspection | BROUILLON, EN_COURS, TERMINE, INACCESSIBLE, ARCHIVE |
| StatutTraitement | NON_ANALYSE dans tous les exemples (App 1 ne prend aucune décision métier) |
| GPSLatitude / GPSLongitude | Facultatives ; vides dans deux exemples |
| InspectionPrecedenteGUID | Renseigné dans l'exemple 000004 pour pointer vers l'inspection INACCESSIBLE 000003 (voir risques résiduels du rapport de cohérence) |

---

# reponses.csv

Exemple de contenu de la liste **REPONSES**. Une ligne = une réponse à une question.

| Colonne | Commentaire |
|------|------|
| ReponseID | Identifiant unique de la réponse ; format GUID utilisé dans les exemples (format non fixé par le schéma) |
| InspectionGUID | Clé vers INSPECTIONS |
| QuestionCode | Clé vers QUESTIONS |
| Valeur | Réponses RADIO, CHECKBOX et TEXTE ; valeur prise dans ValeursPossibles |
| ValeurNumerique | Réponses NUMERIQUE et CALCUL |
| Commentaire | Commentaire saisi via l'icône 💬 ; pour SYS_001, commentaire d'inaccessibilité |
| DateEncodage | Date de saisie de la réponse |
| UtilisateurEncodage | Utilisateur ayant saisi la réponse |

Les questions de type PHOTO (POT_010, LUM_012) n'ont pas de ligne de réponse dans les
exemples : leur complétude se mesure au nombre de photos. Ce choix de représentation
n'est pas fixé par le schéma (voir rapport de cohérence).

---

# photos.csv

Exemple des métadonnées de la bibliothèque **PHOTOS_INSPECTIONS**.

| Colonne | Commentaire |
|------|------|
| Name | **Colonne native SharePoint** (nom du fichier), absente du schéma car fournie par la bibliothèque |
| FolderPath | **Information native SharePoint** (dossier du fichier), selon la structure recommandée `AAAA/MM/InspectionID/` |
| InspectionGUID | Clé vers INSPECTIONS |
| QuestionCode | Question à laquelle la photo est rattachée (obligatoire, y compris SYS_001) |
| NomOuvrage | Copie du nom d'ouvrage pour la recherche |
| Auteur | Utilisateur ayant pris ou importé la photo |
| DatePhoto | Date de prise ou d'import |
| CompressionVersion | ORIGINAL ou COMPRESSEE (une photo de faible taille peut rester ORIGINAL) |

---

# questions-model.csv

Gabarit de la liste **QUESTIONS** : en-tête complet identique à `questions.csv`
et une ligne d'exemple par type de question (RADIO, NUMERIQUE, CALCUL, CHECKBOX, PHOTO, TEXTE).

**Ne jamais importer ce fichier dans SharePoint.**
Les codes `EX_*` et les libellés `[EXEMPLE]` sont fictifs.
Le catalogue réel est `sharepoint/questions/questions.csv`.

| Colonne | Commentaire |
|------|------|
| QuestionCode | Code unique |
| QuestionParent | Code de la question parente (sous-questions) |
| DisplayGroup | GENERAL, CORROSION, SUR_PONT, SYSTEM |
| Formulaire | POTEAU, LUMINAIRE, SYSTEM |
| OrdreAffichage | Ordre dans le formulaire |
| Libelle | Texte affiché |
| TypeQuestion | RADIO, CHECKBOX, NUMERIQUE, PHOTO, TEXTE, CALCUL, SYSTEM |
| Obligatoire, CommentaireAutorise, CommentaireObligatoire, PhotoAutorisee, VisibleParDefaut | OUI / NON dans le CSV, Oui/Non dans SharePoint |
| NbPhotosMin / NbPhotosMax | Bornes du nombre de photos |
| ValeursPossibles | Valeurs séparées par `\|` |
| FormuleCalcul | Formule utilisant les codes de questions (type CALCUL) |
